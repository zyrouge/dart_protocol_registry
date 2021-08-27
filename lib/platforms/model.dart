import '../registry_scheme.dart';

abstract class ProtocolRegistryModel {
  /// Used to get the application path of the scheme if its already registered.
  Future<String?> find(ProtocolScheme scheme);

  /// Check if the scheme is already registered.
  Future<bool> exists(ProtocolScheme scheme);

  /// Used to add a scheme.
  Future<bool> add(ProtocolScheme scheme);

  /// Used to remove a scheme.
  Future<bool> remove(ProtocolScheme scheme);
}
