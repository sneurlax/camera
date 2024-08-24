// Selects the native backend implementation by platform.
//
// On the web we cannot use `dart:ffi`, so the conditional import swaps in a
// web implementation. Everywhere else we get the FFI backend.
export 'native_backend_ffi.dart'
    if (dart.library.js_interop) 'native_backend_web.dart';
