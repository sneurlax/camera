//! C ABI for the camera_control crate.
//!
//! This is the surface the Dart FFI backend binds to. Keep it small and
//! stable: integer handles, JSON for device lists, no Rust types across the
//! boundary.

// The exported functions take raw pointers the caller is responsible for; the
// derefs here are expected at an FFI boundary rather than a smell.
#![allow(clippy::not_unsafe_ptr_arg_deref)]

use std::collections::HashMap;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::Mutex;

#[cfg(any(target_os = "macos", target_os = "ios"))]
mod avfoundation;

mod device;
pub(crate) use device::{Device, PixelFormat};

/// A frame handed across the FFI boundary.
///
/// Field order and types must match the Dart `_CFrame` struct exactly. `data`
/// points at a heap buffer owned by this struct until `camera_control_frame_free`.
#[repr(C)]
pub struct CFrame {
    pub data: *mut u8,
    pub length: i32,
    pub width: i32,
    pub height: i32,
    /// Pixel format index, matching the Dart `PixelFormat` enum order.
    pub pixel_format: i32,
    /// Capture timestamp in microseconds.
    pub timestamp_us: i64,
}

/// A frame produced by a platform capture session.
pub(crate) struct Frame {
    pub data: Vec<u8>,
    pub width: i32,
    pub height: i32,
    pub pixel_format: PixelFormat,
    pub timestamp_us: i64,
}

/// Trait every platform capture session implements.
pub(crate) trait FrameSource: Send {
    /// Block until the next frame is available, or return an error.
    fn capture(&mut self) -> Result<Frame, ()>;
    /// Stop the session and release resources.
    fn close(&mut self);
}

/// Active capture sessions, keyed by handle.
static SESSIONS: Mutex<Option<HashMap<i32, Box<dyn FrameSource>>>> = Mutex::new(None);

/// Next handle to hand out. Positive on success, <= 0 reserved for errors.
static NEXT_HANDLE: AtomicI32 = AtomicI32::new(1);

/// Enumerate cameras and their formats, as a JSON array string.
///
/// Caller owns the returned pointer and must free it with
/// `camera_control_string_free`. Returns null on failure.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_enumerate() -> *mut c_char {
    let devices = platform_enumerate();
    let json = device::devices_to_json(&devices);
    match CString::new(json) {
        Ok(s) => s.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a string returned by this library.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_string_free(s: *mut c_char) {
    if s.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(s));
    }
}

/// Open a device by id. Returns a handle > 0, or <= 0 on error.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_open(device_id: *const c_char) -> c_int {
    let id = unsafe {
        if device_id.is_null() {
            return -1;
        }
        match CStr::from_ptr(device_id).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2,
        }
    };
    let source = match platform_open(&id) {
        Ok(s) => s,
        Err(_) => return -3,
    };
    let handle = NEXT_HANDLE.fetch_add(1, Ordering::SeqCst);
    let mut guard = SESSIONS.lock().unwrap();
    guard
        .get_or_insert_with(HashMap::new)
        .insert(handle, source);
    handle
}

/// Capture one frame into `out`. Returns 0 on success, < 0 on error.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_capture(handle: c_int, out: *mut CFrame) -> c_int {
    if out.is_null() {
        return -1;
    }
    let mut guard = SESSIONS.lock().unwrap();
    let map = match guard.as_mut() {
        Some(m) => m,
        None => return -2,
    };
    let source = match map.get_mut(&handle) {
        Some(s) => s,
        None => return -3,
    };
    let frame = match source.capture() {
        Ok(f) => f,
        Err(_) => return -4,
    };
    // Move the buffer to the heap and hand ownership to the caller.
    let mut data = frame.data.into_boxed_slice();
    let ptr = data.as_mut_ptr();
    let len = data.len() as i32;
    std::mem::forget(data);
    unsafe {
        (*out).data = ptr;
        (*out).length = len;
        (*out).width = frame.width;
        (*out).height = frame.height;
        (*out).pixel_format = frame.pixel_format as i32;
        (*out).timestamp_us = frame.timestamp_us;
    }
    0
}

/// Free a frame buffer filled by `camera_control_capture`.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_frame_free(frame: *mut CFrame) {
    if frame.is_null() {
        return;
    }
    unsafe {
        let f = &mut *frame;
        if !f.data.is_null() && f.length > 0 {
            let len = f.length as usize;
            drop(Vec::from_raw_parts(f.data, len, len));
            f.data = std::ptr::null_mut();
            f.length = 0;
        }
    }
}

/// Close a session and release its resources.
#[unsafe(no_mangle)]
pub extern "C" fn camera_control_close(handle: c_int) {
    let mut guard = SESSIONS.lock().unwrap();
    if let Some(map) = guard.as_mut() {
        if let Some(mut source) = map.remove(&handle) {
            source.close();
        }
    }
}

// Platform dispatch. Each host compiles in its own implementation; hosts with
// no implementation yet fall back to an empty device list and open errors.

#[cfg(any(target_os = "macos", target_os = "ios"))]
fn platform_enumerate() -> Vec<Device> {
    avfoundation::enumerate()
}

#[cfg(any(target_os = "macos", target_os = "ios"))]
fn platform_open(id: &str) -> Result<Box<dyn FrameSource>, ()> {
    avfoundation::open(id)
}

#[cfg(not(any(target_os = "macos", target_os = "ios")))]
fn platform_enumerate() -> Vec<Device> {
    Vec::new()
}

#[cfg(not(any(target_os = "macos", target_os = "ios")))]
fn platform_open(_id: &str) -> Result<Box<dyn FrameSource>, ()> {
    Err(())
}
