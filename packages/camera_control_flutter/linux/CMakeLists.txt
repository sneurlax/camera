# Builds the camera_control Rust crate via cargokit and bundles the resulting
# libcamera_control.so with the Flutter app.
cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "camera_control_flutter")
project(${PROJECT_NAME} LANGUAGES CXX)

include("${CMAKE_CURRENT_SOURCE_DIR}/../cargokit/cmake/cargokit.cmake")

# apply_cargokit(<target> <manifest_dir, relative to this file> <lib_name> <force-link symbol>)
# The crate lives at the repo root, shared with the pure-Dart camera_control package.
apply_cargokit(${PROJECT_NAME} ../../../native/camera_control_native camera_control "")

set(camera_control_flutter_bundled_libraries
  "${${PROJECT_NAME}_cargokit_lib}"
  PARENT_SCOPE
)
