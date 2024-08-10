use cbindgen::{Config, Language};
use std::env;

fn main() {
    // Path to the crate directory
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    // Generate the C header
    cbindgen::generate_with_config(
        &crate_dir,
        Config {
            language: Language::C,
            include_guard: Some("CAMERA_PLUGIN_BINDINGS_H".into()),
            ..Default::default()
        },
    )
    .unwrap()
    .write_to_file("camera_plugin_bindings.h");
}
