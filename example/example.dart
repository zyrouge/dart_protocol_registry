import 'dart:io';
import 'package:protocol_registry/protocol_registry.dart';

final ProtocolScheme scheme = ProtocolScheme(
  appName: 'Test App',
  scheme: 'some-thing-that-doesnt-exist',
  appPath: Platform.resolvedExecutable,
);

Future<void> main(List<String> args) async {
  /** Get the registry */
  final ProtocolRegistryModel registry = getRegistry();

  /** Query */
  await registry.find(scheme);
  await registry.exists(scheme);

  /** Add */
  await registry.add(scheme);

  /** Remove */
  await registry.remove(scheme);
}
