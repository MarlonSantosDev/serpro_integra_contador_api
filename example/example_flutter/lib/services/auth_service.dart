import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Serviço centralizado para gerenciar autenticação
class AuthService {
  static ApiClient? _apiClient;
  static bool _isAuthenticated = false;

  static ApiClient? get apiClient => _apiClient;
  static bool get isAuthenticated => _isAuthenticated;

  /// Autentica o cliente da API
  static Future<void> authenticate({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
    String? certificadoDigitalBase64,
    String? certificadoDigitalPath,
    String? senhaCertificado,
    String ambiente = 'trial',
    String? urlServidor,
  }) async {
    _apiClient = ApiClient();
    
    await _apiClient!.authenticate(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      certificadoDigitalBase64: certificadoDigitalBase64,
      certificadoDigitalPath: certificadoDigitalPath,
      senhaCertificado: senhaCertificado,
      ambiente: ambiente,
      urlServidor: urlServidor,
    );
    
    _isAuthenticated = true;
  }

  /// Limpa a autenticação
  static void clear() {
    _apiClient = null;
    _isAuthenticated = false;
  }
}

