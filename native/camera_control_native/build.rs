// Embed an Info.plist (with NSCameraUsageDescription) into binaries on Apple
// platforms.
//
// macOS TCC denies camera access to a non-bundled executable that has no
// NSCameraUsageDescription, so AVFoundation enumeration returns nothing. The
// Flutter plugin gets this from its app bundle; for the crate's own example and
// test binaries we link the plist into a __TEXT,__info_plist section so they can
// prompt and capture when run from a real terminal. The cdylib/staticlib (the
// FFI library bundled by the Flutter plugin) does not need this.

use std::path::Path;

fn main() {
    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();
    if target_os != "macos" && target_os != "ios" {
        return;
    }
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let plist = Path::new(&manifest_dir).join("Info.plist");
    println!("cargo::rerun-if-changed=Info.plist");
    // -sectcreate places the plist where TCC looks for it in a bare binary.
    let arg = format!("-Wl,-sectcreate,__TEXT,__info_plist,{}", plist.display());
    println!("cargo::rustc-link-arg-bins={arg}");
    println!("cargo::rustc-link-arg-examples={arg}");
    println!("cargo::rustc-link-arg-tests={arg}");
}
