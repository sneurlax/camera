//! AVFoundation capture backend (macOS/iOS). Placeholder pending implementation.

use crate::{Device, FrameSource};

pub fn enumerate() -> Vec<Device> {
    Vec::new()
}

pub fn open(_id: &str) -> Result<Box<dyn FrameSource>, ()> {
    Err(())
}
