# protocol_registry

Register/query/remove URI Schemes without hassle. Available for Windows and Linux.

## Installation

```bash
flutter pub add protocol_registry
```

## Usage


```dart
/** Get the registry */
final ProtocolRegistryModel registry = getRegistry();

/** Query */
await registry.find(scheme);
await registry.exists(scheme);

/** Add */
await registry.add(scheme);

/** Remove */
await registry.remove(scheme);
```

Check [./example](./example) for examples.

## Additional information

This package has not been completely tested on Linux. MacOS schemes can be added by modifying the `Info.plist` file. Contributions are always welcomed.
