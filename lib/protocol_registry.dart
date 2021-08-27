library protocol_registry;

import 'dart:io';
import './platforms/linux.dart';
import './platforms/model.dart';
import './platforms/windows.dart';

export './platforms/linux.dart';
export './platforms/model.dart';
export './platforms/windows.dart';
export 'registry_scheme.dart';

/// Gives the corresponding registry of the platform. Supports Windows and MacOS.
ProtocolRegistryModel getRegistry() {
  if (Platform.isLinux) return LinuxProtocolRegistry();
  if (Platform.isWindows) return WindowsProtocolRegistry();

  throw UnsupportedError('Unsupported Platform');
}
