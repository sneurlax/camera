#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_control_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_control_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter integration for camera_control.'
  s.description      = <<-DESC
Cross-platform camera access for Flutter with no system dependencies.
                       DESC
  s.homepage         = 'https://github.com/ManyMath/camera_control'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'sneurlax' => 'sneurlax@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  # Build the camera_control Rust crate (static lib) via cargokit and
  # force-link it into the plugin framework.
  s.script_phase = {
    :name => 'Build camera_control',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../../../native/camera_control_native camera_control',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ['${BUILT_PRODUCTS_DIR}/libcamera_control.a'],
  }

  s.dependency 'FlutterMacOS'

  # The Rust static lib calls AVFoundation; objc2's link directives only apply
  # when cargo links, so the frameworks must be named here for the final link.
  s.frameworks = 'AVFoundation', 'CoreMedia', 'CoreVideo', 'Foundation'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libcamera_control.a',
  }
  s.swift_version = '5.0'
end
