import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import './model.dart';
import '../registry_scheme.dart';

class LinuxProtocolRegistry extends ProtocolRegistryModel {
  @override
  Future<String?> find(ProtocolScheme scheme) async {
    final String? filename = await findDesktopFileWithScheme(scheme);
    if (filename != null) {
      final File? file = await findDesktopFile(filename);
      if (file != null) {
        final String content = await file.readAsString();
        try {
          return RegExp(r'^Exec=([^%u\n]+)', multiLine: true)
              .firstMatch(content)
              ?.group(1);
        } catch (_) {}
      }
    }
  }

  @override
  Future<bool> exists(ProtocolScheme scheme) async {
    return await find(scheme) != null;
  }

  @override
  Future<bool> add(ProtocolScheme scheme) async {
    final String entry = getEntry(scheme);
    final String path = getDesktopFilePath(scheme);

    final File file = File(path);
    if (await file.exists() == false) {
      await file.create(recursive: true);
      await file.writeAsString(entry);
    } else {
      final List<String> lines = (await file.readAsString()).split('\n');
      final List<String> mimes = lines
              .firstWhereOrNull(
                (final String x) => x.startsWith('MimeType='),
              )
              ?.replaceFirst('MimeType=', '')
              .split(';') ??
          <String>[];

      lines.removeWhere((final String x) => x.startsWith('MimeType='));

      if (!mimes.contains(scheme.scheme)) {
        mimes.add(scheme.scheme);
      }

      await file.writeAsString(
        <String>[...lines, 'MimeType=${mimes.join(';')}'].join('\n'),
      );
    }

    await installDesktopFile(path, scheme);
    return true;
  }

  @override
  Future<bool> remove(ProtocolScheme scheme) async {
    final String? filename = await findDesktopFileWithScheme(scheme);

    if (filename != null) {
      final File? file = await findDesktopFile(filename);
      if (file != null) {
        await file.writeAsString(
          (await file.readAsString()).split('\n').map((final String x) {
            if (x.startsWith('MimeType=')) {
              final List<String> mimes =
                  x.replaceFirst('MimeType=', '').split(';');
              mimes.remove(scheme.scheme);
              return 'MimeType=${mimes.join(';')}';
            }
            return x;
          }).join('\n'),
        );

        return true;
      }
    }

    return false;
  }

  /// Returns content of `.desktop` file with only `Name` and `Exec`.
  String getEntry(ProtocolScheme scheme) {
    if (scheme.appPath == null) {
      throw ArgumentError.notNull('scheme.appPath');
    }

    if (scheme.appName == null) {
      throw ArgumentError.notNull('scheme.appName');
    }

    return '''
[Desktop Entry]
Name=${scheme.appName}
Exec=${scheme.appPath} %u
Type=Application
MimeType=x-scheme-handler/${scheme.scheme};
'''
        .trim();
  }

  /// Returns suitable path for the scheme's `.desktop` file.
  String getDesktopFilePath(ProtocolScheme scheme) => p.join(
        Platform.environment['HOME']!,
        '.local',
        'share',
        'applications',
        '${scheme.scheme}.desktop',
      );

  /// Used to install a `.desktop` file. Recommended to pass path from [getDesktopFilePath] to [path].
  Future<void> installDesktopFile(String path, ProtocolScheme scheme) async =>
      Process.run(
        'xdg-mime',
        <String>['default', path, 'x-scheme-handler/${scheme.scheme}'],
      );

  /// Tries to resolve path from a `./desktop` filename. Only checks the `~/.local/share/applications` folder.
  Future<File?> findDesktopFile(String filename) async {
    final File file = File(
      getDesktopFilePath(
        ProtocolScheme(
          scheme: filename.replaceFirst(RegExp(r'\.desktop$'), ''),
        ),
      ),
    );
    return await file.exists() ? file : null;
  }

  /// Returns the `.desktop` filename that contains the [scheme.scheme].
  Future<String?> findDesktopFileWithScheme(ProtocolScheme scheme) async {
    final ProcessResult result = await Process.run(
      'xdg-mime',
      <String>['query', 'default', 'x-scheme-handler/${scheme.scheme}'],
    );
    final String filename = result.stdout.toString().trim();
    return filename.isNotEmpty ? filename : null;
  }
}
