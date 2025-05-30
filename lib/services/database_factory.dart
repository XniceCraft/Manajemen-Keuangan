import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

sqflite.DatabaseFactory getDatabaseFactory() {
  if (kIsWeb) {
    return ffi_web.databaseFactoryFfiWeb;
  }
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    ffi.sqfliteFfiInit();
    return ffi.databaseFactoryFfi;
  }
  return sqflite.databaseFactory;
}
