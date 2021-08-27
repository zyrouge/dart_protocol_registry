import 'package:flutter_test/flutter_test.dart';
import 'package:protocol_registry/protocol_registry.dart';

final ProtocolScheme scheme = ProtocolScheme(
  appName: 'Test App',
  scheme: 'some-thing-that-doesnt-exist',
  appPath: 'testing',
);

void main() {
  final ProtocolRegistryModel registry = getRegistry();

  test('.find', () async {
    final String? found = await registry.find(scheme);
    expect(found, null);
  });

  test('.exists', () async {
    final bool exists = await registry.exists(scheme);
    expect(exists, false);
  });

  test('.add', () async {
    final bool added = await registry.add(scheme);
    expect(added, true);
  });

  test('.find', () async {
    final String? found = await registry.find(scheme);
    expect(found, scheme.appPath);
  });

  test('.exists', () async {
    final bool exists = await registry.exists(scheme);
    expect(exists, true);
  });

  test('.remove', () async {
    final bool removed = await registry.remove(scheme);
    expect(removed, true);
  });
}
