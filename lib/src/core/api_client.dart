import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';

class ApiClient {
  final String _baseUrl = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';
  final String _authUrl = 'https://autenticacao.sapi.serpro.gov.br/authenticate';

  String? _accessToken;
  String? _jwtToken;

  // TODO: Implementar lógica de autenticação com certificado digital
  Future<void> authenticate(String consumerKey, String consumerSecret, String certPath, String certPassword) async {
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
      _accessToken = authData['access_token'];
      _jwtToken = authData['jwt_token'];
    } else {
      throw Exception('Falha na autenticação: ${response.body}');
    }
    */

    // Valores de exemplo para desenvolvimento
    _accessToken = '06aef429-a981-3ec5-a1f8-71d38d86481e';
    _jwtToken = '06aef429-a981-3ec5-a1f8-71d38d86481e';
  }

  Future<Map<String, dynamic>> post(String endpoint, BaseRequest request) async {
    if (_accessToken == null || _jwtToken == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    final response = await http.post(Uri.parse('$_baseUrl$endpoint'), headers: {'Authorization': 'Bearer $_accessToken', 'jwt_token': _jwtToken!, 'Content-Type': 'application/json'}, body: json.encode(request.toJson()));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      // Lança uma exceção com o corpo da resposta para depuração
      throw Exception('Falha na requisição: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }
}
