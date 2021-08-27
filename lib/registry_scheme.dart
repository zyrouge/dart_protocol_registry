class ProtocolScheme {
  ProtocolScheme({
    required this.scheme,
    this.appName,
    this.appPath,
  });

  /// URI Scheme without `://` (Example: `your-app`)
  final String scheme;

  /// Name of the application. Required for Linux desktop entry.
  final String? appName;

  /// Path of your app. Required when passing to `add`. Usually this is `Platform.resolvedExecutable`.
  final String? appPath;
}
