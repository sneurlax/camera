import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'camera_plugin_bindings_generated.dart';

const String _libName = 'camera_plugin';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final CameraPluginBindings _bindings = CameraPluginBindings(_dylib);

Future<Uint8List?> captureImage() async {
  final Pointer<Uint8> buffer = calloc.allocate<Uint8>(1024 * 1024);
  final Pointer<UnsignedLong> length = calloc<UnsignedLong>();

  bool result;
  try {
    result = _bindings.capture_image(buffer, length);
  } catch (e) {
    print('Error capturing image: $e');
    print('Last error from Rust: ${_getLastError()}');
    calloc.free(buffer);
    calloc.free(length);
    return null;
  }

  if (!result) {
    print('Failed to capture image');
    print('Last error from Rust: ${_getLastError()}');
    calloc.free(buffer);
    calloc.free(length);
    return null;
  }

  final int imageLength = length.value;
  final Uint8List imageBytes = buffer.asTypedList(imageLength);

  calloc.free(buffer);
  calloc.free(length);

  return imageBytes;
}

bool initializeCamera() {
  try {
    bool result = _bindings.initialize_camera();
    if (!result) {
      print('Failed to initialize camera');
      print('Last error from Rust: ${_getLastError()}');
    }
    return result;
  } catch (e) {
    print('Error initializing camera: $e');
    print('Last error from Rust: ${_getLastError()}');
    return false;
  }
}

String _getLastError() {
  final Pointer<Utf8> errorPtr = _bindings.get_last_error().cast<Utf8>();
  final String error = errorPtr.toDartString();
  calloc.free(errorPtr);
  return error;
}
