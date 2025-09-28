import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/core/auth/authentication_model.dart';
import 'package:serpro_integra_contador_api/src/util/document_utils.dart';
import 'package:serpro_integra_contador_api/src/models/autenticaprocurador/cache_model.dart';

class ApiClient {
  final String _baseUrl = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';

  AuthenticationModel? _authModel;
  CacheModel? _procuradorCache;

  Future<void> authenticate({
    required String consumerKey,
    required String consumerSecret,
    required String certPath,
    required String certPassword,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    // Esta é uma implementação simplificada.
    // A autenticação real requer uma chamada HTTP com certificado cliente (mTLS).
    // O pacote http padrão do Dart não suporta isso diretamente.
    // Em um app Flutter, pode ser necessário usar pacotes como `flutter_client_ssl`
    // ou código nativo.

    // Exemplo de como a requisição seria:
    /*
    final credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
    final response = await http.post(
      Uri.parse(_authUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Role-Type': 'TERCEIROS',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
      // A parte do certificado é a que precisa de suporte especial
    );

    if (response.statusCode == 200) {
      final authData = json.decode(response.body);
      _authModel = AuthenticationModel(
        accessToken: authData['access_token'],
        jwtToken: authData['jwt_token'],
        expiresIn: authData['expires_in'],
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );
    } else {
      throw Exception('Falha na autenticação: ${response.body}');
    }
    */

    // Valores de exemplo para desenvolvimento
    _authModel = AuthenticationModel(
      accessToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      jwtToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      expiresIn: 3600,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    BaseRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
    String? procuradorToken,
  }) async {
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    // Usa os dados customizados se fornecidos, senão usa os dados padrão da autenticação
    final finalContratanteNumero = contratanteNumero ?? _authModel!.contratanteNumero;
    final finalAutorPedidoDadosNumero = autorPedidoDadosNumero ?? _authModel!.autorPedidoDadosNumero;

    // Cria o JSON completo usando os dados de autenticação (padrão ou customizados)
    final requestBody = request.toJsonWithAuth(
      contratanteNumero: finalContratanteNumero,
      contratanteTipo: DocumentUtils.detectDocumentType(finalContratanteNumero),
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      autorPedidoDadosTipo: DocumentUtils.detectDocumentType(finalAutorPedidoDadosNumero),
    );

    // Preparar headers
    final headers = <String, String>{
      'Authorization': 'Bearer ${_authModel!.accessToken}',
      'jwt_token': _authModel!.jwtToken,
      'Content-Type': 'application/json',
    };

    // Adicionar token de procurador se fornecido
    if (procuradorToken != null && procuradorToken.isNotEmpty) {
      headers['autenticar_procurador_token'] = procuradorToken;
    }

    final response = await http.post(Uri.parse('$_baseUrl$endpoint'), headers: headers, body: json.encode(requestBody));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (responseBody.isNotEmpty && responseBody['mensagens'][0]['codigo'] == "ERRO") {
        responseBody = {
          "rota": endpoint,
          "status": response.statusCode,
          "idSistema": requestBody['pedidoDados']['idSistema'],
          "idServico": requestBody['pedidoDados']['idServico'],
          "mensagens": "${responseBody['mensagens'][0]['texto']}",
        };
        throw Exception(responseBody);
      }
      return responseBody;
    } else {
      // Lança uma exceção com o corpo da resposta para depuração
      throw Exception('Falha na requisição: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Autentica procurador usando termo de autorização
  Future<Map<String, dynamic>> autenticarProcurador({
    required String termoAutorizacaoBase64,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    final requestBody = {'termoAutorizacao': termoAutorizacaoBase64};

    final response = await http.post(
      Uri.parse('$_baseUrl/AutenticarProcurador'),
      headers: {'Authorization': 'Bearer ${_authModel!.accessToken}', 'jwt_token': _authModel!.jwtToken, 'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Salvar cache se autenticação foi bem-sucedida
      if (responseBody['autenticar_procurador_token'] != null) {
        _procuradorCache = CacheModel.fromResponse(
          token: responseBody['autenticar_procurador_token'],
          headers: response.headers,
          contratanteNumero: contratanteNumero,
          autorPedidoDadosNumero: autorPedidoDadosNumero,
        );
      }

      return responseBody;
    } else {
      throw Exception('Falha na autenticação de procurador: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Verifica se existe token de procurador válido em cache
  bool get hasProcuradorToken => _procuradorCache?.isTokenValido ?? false;

  /// Obtém token de procurador do cache
  String? get procuradorToken => _procuradorCache?.token;

  /// Define token de procurador manualmente
  void setProcuradorToken(String token, {required String contratanteNumero, required String autorPedidoDadosNumero}) {
    _procuradorCache = CacheModel(
      token: token,
      dataCriacao: DateTime.now(),
      dataExpiracao: DateTime.now().add(const Duration(hours: 24)),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Limpa cache de procurador
  void clearProcuradorCache() {
    _procuradorCache = null;
  }

  /// Obtém informações do cache de procurador
  Map<String, dynamic>? get procuradorCacheInfo {
    if (_procuradorCache == null) return null;

    return {
      'token': _procuradorCache!.token.substring(0, 8) + '...',
      'is_valido': _procuradorCache!.isTokenValido,
      'expira_em_breve': _procuradorCache!.expiraEmBreve,
      'tempo_restante_horas': _procuradorCache!.tempoRestante.inHours,
      'contratante_numero': _procuradorCache!.contratanteNumero,
      'autor_pedido_dados_numero': _procuradorCache!.autorPedidoDadosNumero,
    };
  }

  /// Getter para verificar se o cliente está autenticado
  bool get isAuthenticated => _authModel != null;

  /// Getter para obter os dados de autenticação (apenas para debugging)
  AuthenticationModel? get authModel => _authModel;
}
