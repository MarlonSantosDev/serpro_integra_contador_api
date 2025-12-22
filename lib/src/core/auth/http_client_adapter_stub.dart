import 'dart:typed_data';

/// Stub implementation para conditional exports
///
/// Este arquivo existe apenas para resolução de exports condicionais.
/// Nunca é executado em runtime - o compilador escolhe automaticamente:
/// - Desktop/Mobile → http_client_adapter_io.dart
/// - Web → http_client_adapter_web.dart
class HttpClientAdapter {
  /// Configura mTLS com certificado a partir de bytes
  Future<void> configureMtlsFromBytes(
    Uint8List certBytes,
    String certPassword,
  ) async {
    throw UnimplementedError(
      'Utilize a implementação específica da plataforma.',
    );
  }

  /// Configura mTLS com certificado se fornecido
  Future<void> configureMtls(
    String? certPath,
    String? certPassword,
    bool isProduction,
  ) async {
    throw UnimplementedError(
      'Utilize a implementação específica da plataforma.',
    );
  }

  /// Configura mTLS com certificado via Base64 ou arquivo
  Future<void> configureMtlsUnified({
    String? certBase64,
    String? certPath,
    String? certPassword,
    required bool isProduction,
  }) async {
    throw UnimplementedError(
      'Utilize a implementação específica da plataforma.',
    );
  }

  /// Executa uma requisição POST
  Future<Map<String, dynamic>> post(
    dynamic uri,
    Map<String, String> headers,
    String body,
  ) async {
    throw UnimplementedError(
      'Utilize a implementação específica da plataforma.',
    );
  }

  /// Libera recursos alocados
  void dispose() {
    throw UnimplementedError(
      'Utilize a implementação específica da plataforma.',
    );
  }

  /// Retorna true se mTLS está habilitado
  bool get isMtlsEnabled => throw UnimplementedError(
    'Utilize a implementação específica da plataforma.',
  );
}
