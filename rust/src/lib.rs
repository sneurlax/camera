use opencv::{
    core, imgcodecs, prelude::*, videoio,
};
use std::os::raw::c_ulong;
use std::ffi::CString;

#[no_mangle]
pub extern "C" fn initialize_camera() -> bool {
    let mut cam = match videoio::VideoCapture::new(0, videoio::CAP_ANY) {
        Ok(cam) => cam,
        Err(e) => {
            eprintln!("Failed to create VideoCapture: {:?}", e);
            return false;
        }
    };

    let is_opened = videoio::VideoCapture::is_opened(&cam).unwrap_or(false);
    if !is_opened {
        eprintln!("Camera failed to open");
    }
    is_opened
}

#[no_mangle]
pub extern "C" fn capture_image(buffer: *mut u8, len: *mut c_ulong) -> bool {
    let mut cam = match videoio::VideoCapture::new(0, videoio::CAP_ANY) {
        Ok(cam) => cam,
        Err(e) => {
            eprintln!("Failed to create VideoCapture: {:?}", e);
            return false;
        }
    };

    if !videoio::VideoCapture::is_opened(&cam).unwrap_or(false) {
        eprintln!("Camera is not opened");
        return false;
    }

    let mut img = core::Mat::default();
    match cam.read(&mut img) {
        Ok(_) => {
            if img.size().unwrap().width <= 0 {
                eprintln!("Captured image is empty");
                return false;
            }
        },
        Err(e) => {
            eprintln!("Failed to read from camera: {:?}", e);
            return false;
        }
    }

    let mut buf = opencv::core::Vector::<u8>::new();
    let params = opencv::core::Vector::new();

    match imgcodecs::imencode(".png", &img, &mut buf, &params) {
        Ok(_) => {},
        Err(e) => {
            eprintln!("Failed to encode image: {:?}", e);
            return false;
        }
    }

    let vec_buf: Vec<u8> = buf.to_vec();

    unsafe {
        *len = vec_buf.len() as c_ulong;
        std::ptr::copy_nonoverlapping(vec_buf.as_ptr(), buffer, vec_buf.len());
    }

    true
}

#[no_mangle]
pub extern "C" fn get_last_error() -> *const i8 {
    // This is a placeholder. In a real implementation, you'd want to store the last error message
    // in a thread-local variable and return it here.
    let error_message = CString::new("No error information available").unwrap();
    error_message.into_raw()
}
