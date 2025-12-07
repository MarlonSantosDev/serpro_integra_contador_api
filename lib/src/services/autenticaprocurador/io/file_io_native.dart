import 'dart:io';
import 'dart:typed_data';

/// Implementação nativa para Desktop/Mobile - suporta operações de arquivo
///
/// Em Desktop/Mobile, permite leitura de arquivos de certificado
/// e conversão via OpenSSL (quando disponível).
class FileIO {
  /// Verifica se a plataforma suporta operações de arquivo
  static bool get isSupported => true;

  /// Verifica se é plataforma Web
  static bool get isWeb => false;

  /// Verifica se é plataforma Desktop (Windows, Linux, macOS)
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Verifica se é plataforma Mobile (Android, iOS)
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Lê bytes de um arquivo
  static Future<Uint8List> readFileAsBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('Arquivo não encontrado', path);
    }
    return await file.readAsBytes();
  }

  /// Verifica se um arquivo existe
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Executa conversão PFX -> PEM via OpenSSL (apenas Desktop)
  ///
  /// Retorna o conteúdo PEM convertido ou null se falhar
  static Future<String?> runOpenSSLConversion(String pfxPath, String password) async {
    if (!isDesktop) return null;

    final tempDir = Directory.systemTemp;
    final pemPath = '${tempDir.path}/serpro_pem_${DateTime.now().millisecondsSinceEpoch}.pem';

    // Lista de possíveis locais do OpenSSL
    final opensslPaths = Platform.isWindows
        ? [
            'C:\\Program Files\\Git\\mingw64\\bin\\openssl.exe',
            'C:\\Program Files\\Git\\usr\\bin\\openssl.exe',
            'C:\\Strawberry\\c\\bin\\openssl.exe',
            'openssl',
          ]
        : ['openssl'];

    // Argumentos para diferentes versões do OpenSSL
    final argsVariants = [
      ['-in', pfxPath, '-out', pemPath, '-nodes', '-provider', 'legacy', '-provider', 'default', '-passin', 'pass:$password'],
      ['-in', pfxPath, '-out', pemPath, '-nodes', '-legacy', '-passin', 'pass:$password'],
      ['-in', pfxPath, '-out', pemPath, '-nodes', '-passin', 'pass:$password'],
    ];

    for (final opensslPath in opensslPaths) {
      // Verificar se existe (para caminhos absolutos)
      if (opensslPath != 'openssl' && !await File(opensslPath).exists()) continue;

      for (final args in argsVariants) {
        try {
          final result = await Process.run(
            opensslPath,
            ['pkcs12', ...args],
            runInShell: Platform.isWindows,
          );

          if (result.exitCode == 0) {
            final pemFile = File(pemPath);
            if (await pemFile.exists()) {
              final pemContent = await pemFile.readAsString();
              if (pemContent.contains('-----BEGIN') && pemContent.contains('PRIVATE KEY')) {
                await pemFile.delete();
                return pemContent;
              }
            }
          }
        } catch (_) {
          continue;
        }

        // Limpar arquivo se existir
        try {
          await File(pemPath).delete();
        } catch (_) {}
      }
    }

    return null;
  }

  /// Salva bytes em arquivo temporário
  static Future<String> saveTempFile(Uint8List bytes, String extension) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/serpro_cert_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await tempFile.writeAsBytes(bytes);
    return tempFile.path;
  }

  /// Deleta um arquivo
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignorar erros de deleção
    }
  }
}

