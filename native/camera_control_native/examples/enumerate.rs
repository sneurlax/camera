//! Print the cameras the host exposes, with their formats.
//!
//! Run with: cargo run --example enumerate

use std::ffi::CStr;

use camera_control::camera_control_enumerate;
use camera_control::camera_control_string_free;

fn main() {
    let ptr = camera_control_enumerate();
    if ptr.is_null() {
        eprintln!("enumerate returned null");
        return;
    }
    // SAFETY: the library returned a valid C string we now own.
    let json = unsafe { CStr::from_ptr(ptr) }
        .to_string_lossy()
        .into_owned();
    camera_control_string_free(ptr);
    println!("{json}");
}
