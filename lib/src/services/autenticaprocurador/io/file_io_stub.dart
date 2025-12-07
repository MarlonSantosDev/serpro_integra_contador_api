import 'dart:typed_data';

/// Implementação stub para Web - não suporta operações de arquivo
///
/// Em Web, o certificado deve ser fornecido via Base64.
/// Operações de arquivo e processo não são suportadas.
class FileIO {
  /// Verifica se a plataforma suporta operações de arquivo
  static bool get isSupported => false;

  /// Verifica se é plataforma Web
  static bool get isWeb => true;

  /// Verifica se é plataforma Desktop (Windows, Linux, macOS)
  static bool get isDesktop => false;

  /// Verifica se é plataforma Mobile (Android, iOS)
  static bool get isMobile => false;

  /// Lê bytes de um arquivo - não suportado em Web
  static Future<Uint8List> readFileAsBytes(String path) async {
    throw UnsupportedError(
      '📱 Leitura de arquivo não suportada em Web.\n'
      'Use certificadoBase64 em vez de certificadoPath.',
    );
  }

  /// Verifica se um arquivo existe - não suportado em Web
  static Future<bool> fileExists(String path) async {
    return false;
  }

  /// Executa processo OpenSSL - não suportado em Web
  static Future<String?> runOpenSSLConversion(String pfxPath, String password) async {
    return null;
  }

  /// Salva arquivo temporário - não suportado em Web
  static Future<String> saveTempFile(Uint8List bytes, String extension) async {
    throw UnsupportedError('Arquivos temporários não suportados em Web');
  }

  /// Deleta arquivo - não suportado em Web
  static Future<void> deleteFile(String path) async {
    // No-op em Web
  }
}

