import 'dart:io';
import './model.dart';
import '../registry_scheme.dart';

class WindowsProtocolRegistry extends ProtocolRegistryModel {
  @override
  Future<String?> find(ProtocolScheme scheme) async {
    final ProcessResult result1 = await Process.run(
      'REG',
      <String>[
        'QUERY',
        'HKCU\\Software\\Classes\\${scheme.scheme}',
        '/v',
        '"URL Protocol"'
      ],
    );

    final ProcessResult result2 = await Process.run(
      'REG',
      <String>[
        'QUERY',
        'HKCU\\Software\\Classes\\${scheme.scheme}\\shell\\open\\command',
        '/s'
      ],
    );

    try {
      return result1.stdout.toString().contains("URL Protocol")
          ? RegExp(
              '.*?\\n\\s+\\(Default\\)\\s+REG_SZ\\s+"?([^ "]+)',
            ).firstMatch(result2.stdout.toString())?.group(1)?.trim()
          : null;
    } catch (_) {}
  }

  @override
  Future<bool> exists(ProtocolScheme scheme) async {
    return await find(scheme) != null;
  }

  @override
  Future<bool> add(ProtocolScheme scheme) async {
    if (scheme.appPath == null) {
      throw ArgumentError.notNull('scheme.appPath');
    }

    final ProcessResult result1 = await Process.run(
      'REG',
      <String>[
        'ADD',
        'HKCU\\Software\\Classes\\${scheme.scheme}',
        '/v',
        '"URL Protocol"',
        '/f'
      ],
    );

    final ProcessResult result2 = await Process.run(
      'REG',
      <String>[
        'ADD',
        'HKCU\\Software\\Classes\\${scheme.scheme}\\shell\\open\\command',
        '/ve',
        '/d',
        '"${scheme.appPath}" "%1"',
        '/t',
        'REG_SZ',
        '/f'
      ],
    );

    return _isSuccessful(result1.stdout.toString()) &&
        _isSuccessful(result2.stdout.toString());
  }

  @override
  Future<bool> remove(ProtocolScheme scheme) async {
    final ProcessResult result1 = await Process.run(
      'REG',
      <String>[
        'DELETE',
        'HKCU\\Software\\Classes\\${scheme.scheme}',
        '/v',
        '"URL Protocol"',
        '/f'
      ],
    );

    final ProcessResult result2 = await Process.run(
      'REG',
      <String>[
        'DELETE',
        'HKCU\\Software\\Classes\\${scheme.scheme}\\shell\\open\\command',
        '/f'
      ],
    );

    return _isSuccessful(result1.stdout.toString()) &&
        _isSuccessful(result2.stdout.toString());
  }

  bool _isSuccessful(String res) =>
      res.contains('The operation completed successfully.');
}
