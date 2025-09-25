import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/core/auth/authentication_model.dart';

class ApiClient {
  final String _baseUrl = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';

  AuthenticationModel? _authModel;

  // TODO: Implementar lógica de autenticação com certificado digital
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

  Future<Map<String, dynamic>> post(String endpoint, BaseRequest request) async {
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    // Cria o JSON completo usando os dados de autenticação
    final requestBody = request.toJsonWithAuth(
      contratanteNumero: _authModel!.contratanteNumero,
      contratanteTipo: _authModel!.contratanteTipo,
      autorPedidoDadosNumero: _authModel!.autorPedidoDadosNumero,
      autorPedidoDadosTipo: _authModel!.autorPedidoDadosTipo,
    );

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer ${_authModel!.accessToken}', 'jwt_token': _authModel!.jwtToken, 'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

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

  /// Getter para verificar se o cliente está autenticado
  bool get isAuthenticated => _authModel != null;

  /// Getter para obter os dados de autenticação (apenas para debugging)
  AuthenticationModel? get authModel => _authModel;
}
