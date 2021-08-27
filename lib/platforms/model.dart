import '../registry_scheme.dart';

abstract class ProtocolRegistryModel {
  Future<String?> find(ProtocolScheme scheme);
  Future<bool> exists(ProtocolScheme scheme);
  Future<bool> add(ProtocolScheme scheme);
  Future<bool> remove(ProtocolScheme scheme);
}
