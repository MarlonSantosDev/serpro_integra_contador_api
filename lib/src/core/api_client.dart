import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/core/auth/authentication_model.dart';
import 'package:serpro_integra_contador_api/src/util/document_utils.dart';
import 'package:serpro_integra_contador_api/src/util/request_tag_generator.dart';
import 'package:serpro_integra_contador_api/src/models/autenticaprocurador/cache_model.dart';

/// Cliente principal para comunicação com a API do SERPRO Integra Contador
///
/// Esta classe gerencia:
/// - Autenticação com a API usando certificados cliente (mTLS)
/// - Cache de tokens de procurador para otimizar performance
/// - Headers de autenticação automáticos
/// - Tratamento de erros padronizado
///
/// IMPORTANTE: A autenticação real requer certificados cliente (mTLS) que não são
/// suportados nativamente pelo pacote http do Dart. Para produção, será necessário
/// implementar suporte nativo ou usar pacotes específicos como flutter_client_ssl.
class ApiClient {
  /// URL base para ambiente de demonstração/teste
  final String _baseUrlDemo = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';

  /// URL base para ambiente de produção (comentada para evitar uso acidental)
  //final String _baseUrlProd = 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1';

  /// Modelo de autenticação contendo tokens e dados do contratante/autor
  AuthenticationModel? _authModel;

  /// Cache do token de procurador para evitar reautenticações desnecessárias
  CacheModel? _procuradorCache;

  /// Autentica o cliente com a API do SERPRO usando certificados cliente (mTLS)
  ///
  /// [consumerKey] e [consumerSecret]: Credenciais OAuth2 fornecidas pelo SERPRO
  /// [certPath]: Caminho para o certificado cliente (.p12 ou .pfx)
  /// [certPassword]: Senha do certificado cliente
  /// [contratanteNumero]: CNPJ da empresa que contratou o serviço na Loja Serpro
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor da requisição (pode ser procurador/contador)
  ///
  /// ATENÇÃO: Esta é uma implementação simplificada para desenvolvimento.
  /// A autenticação real requer uma chamada HTTP com certificado cliente (mTLS).
  /// O pacote http padrão do Dart não suporta isso diretamente.
  /// Para produção, será necessário usar pacotes como `flutter_client_ssl` ou código nativo.
  Future<void> authenticate({
    required String consumerKey,
    required String consumerSecret,
    required String certPath,
    required String certPassword,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
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

    // IMPLEMENTAÇÃO TEMPORÁRIA: Valores de exemplo para desenvolvimento
    // Em produção, estes valores devem vir da resposta real da API após autenticação mTLS
    _authModel = AuthenticationModel(
      accessToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      jwtToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      expiresIn: 3600, // Token válido por 1 hora
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Executa uma requisição POST para a API do SERPRO
  ///
  /// [endpoint]: Caminho do endpoint (ex: '/Ccmei/Emitir')
  /// [request]: Objeto BaseRequest contendo os dados da requisição
  /// [contratanteNumero]: CNPJ do contratante (opcional, usa o padrão se não fornecido)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor (opcional, usa o padrão se não fornecido)
  /// [procuradorToken]: Token de procurador para operações que requerem procuração
  ///
  /// Retorna: Map com a resposta da API ou lança exceção em caso de erro
  Future<Map<String, dynamic>> post(
    String endpoint,
    BaseRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
    String? procuradorToken,
  }) async {
    // Verificar se o cliente foi autenticado antes de fazer requisições
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    // Usar dados customizados se fornecidos, senão usar os dados padrão da autenticação
    // Isso permite flexibilidade para diferentes cenários de uso
    final finalContratanteNumero = contratanteNumero ?? _authModel!.contratanteNumero;
    final finalAutorPedidoDadosNumero = autorPedidoDadosNumero ?? _authModel!.autorPedidoDadosNumero;

    // Cria o JSON completo usando os dados de autenticação (padrão ou customizados)
    final requestBody = request.toJsonWithAuth(
      contratanteNumero: finalContratanteNumero,
      contratanteTipo: DocumentUtils.detectDocumentType(finalContratanteNumero),
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      autorPedidoDadosTipo: DocumentUtils.detectDocumentType(finalAutorPedidoDadosNumero),
    );

    // Preparar headers obrigatórios para autenticação com a API
    final headers = <String, String>{
      'Authorization': 'Bearer ${_authModel!.accessToken}', // Token OAuth2
      'jwt_token': _authModel!.jwtToken, // Token JWT adicional
      'Content-Type': 'application/json', // Tipo de conteúdo da requisição
    };

    // Adicionar token de procurador se fornecido (necessário para operações que requerem procuração)
    if (procuradorToken != null && procuradorToken.isNotEmpty) {
      headers['autenticar_procurador_token'] = procuradorToken;
    }

    // Gerar e adicionar identificador de requisição (X-Request-Tag)
    final requestTag = RequestTagGenerator.generateRequestTag(
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      contribuinteNumero: request.contribuinteNumero,
      idServico: request.pedidoDados.idServico,
    );
    headers['X-Request-Tag'] = requestTag;

    // Executar requisição HTTP POST para o endpoint da API
    final response = await http.post(Uri.parse('$_baseUrlDemo$endpoint'), headers: headers, body: json.encode(requestBody));

    // Verificar se a requisição foi bem-sucedida (status 2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Verificar se a API retornou um erro de negócio (mesmo com status HTTP 200)
      // A API do SERPRO pode retornar status 200 mas com código de erro nas mensagens
      if (responseBody.isNotEmpty && responseBody['mensagens'][0]['codigo'] == "ERRO") {
        // Reformatar resposta de erro para facilitar tratamento
        responseBody = {
          "rota": endpoint,
          "status": response.statusCode,
          "idSistema": requestBody['pedidoDados']['idSistema'],
          "idServico": requestBody['pedidoDados']['idServico'],
          "mensagens": "${responseBody['mensagens'][0]['texto']}",
          "body": json.encode(requestBody),
        };
        throw Exception(responseBody);
      }
      return responseBody;
    } else {
      // Lançar exceção com detalhes do erro HTTP para facilitar depuração
      throw Exception('Falha na requisição: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Autentica procurador usando termo de autorização assinado digitalmente
  ///
  /// Este método é usado quando um procurador precisa realizar operações em nome do contribuinte.
  /// O termo de autorização deve estar assinado digitalmente e codificado em Base64.
  ///
  /// [termoAutorizacaoBase64]: Termo de autorização assinado e codificado em Base64
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [autorPedidoDadosNumero]: CPF/CNPJ do procurador
  ///
  /// Retorna: Map com token de procurador e informações de cache
  Future<Map<String, dynamic>> autenticarProcurador({
    required String termoAutorizacaoBase64,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    // Verificar se o cliente principal foi autenticado primeiro
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    // Preparar corpo da requisição com o termo de autorização
    final requestBody = {'termoAutorizacao': termoAutorizacaoBase64};

    // Gerar identificador de requisição para autenticação de procurador
    final requestTag = RequestTagGenerator.generateRequestTag(
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      contribuinteNumero: contratanteNumero, // Para autenticação, usar contratante como contribuinte
      idServico: 'AUTENTICARPROCURADOR', // Código específico para autenticação
    );

    // Executar requisição para autenticar procurador
    final response = await http.post(
      Uri.parse('$_baseUrlDemo/AutenticarProcurador'),
      headers: {
        'Authorization': 'Bearer ${_authModel!.accessToken}',
        'jwt_token': _authModel!.jwtToken,
        'Content-Type': 'application/json',
        'X-Request-Tag': requestTag,
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Salvar token de procurador em cache se autenticação foi bem-sucedida
      // Isso evita reautenticações desnecessárias durante a sessão
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
  ///
  /// Retorna true se há um token válido e não expirado
  bool get hasProcuradorToken => _procuradorCache?.isTokenValido ?? false;

  /// Obtém token de procurador do cache
  ///
  /// Retorna null se não há token ou se está expirado
  String? get procuradorToken => _procuradorCache?.token;

  /// Define token de procurador manualmente
  ///
  /// Útil para casos onde o token foi obtido externamente ou para testes
  /// [token]: Token de procurador válido
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [autorPedidoDadosNumero]: CPF/CNPJ do procurador
  void setProcuradorToken(String token, {required String contratanteNumero, required String autorPedidoDadosNumero}) {
    _procuradorCache = CacheModel(
      token: token,
      dataCriacao: DateTime.now(),
      dataExpiracao: DateTime.now().add(const Duration(hours: 24)), // Token válido por 24 horas
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Limpa cache de procurador
  ///
  /// Força a reautenticação na próxima operação que requerer procuração
  void clearProcuradorCache() {
    _procuradorCache = null;
  }

  /// Obtém informações do cache de procurador para debugging e monitoramento
  ///
  /// Retorna informações úteis sobre o estado do cache sem expor o token completo
  Map<String, dynamic>? get procuradorCacheInfo {
    if (_procuradorCache == null) return null;

    return {
      'token': _procuradorCache!.token.substring(0, 8) + '...', // Apenas primeiros 8 caracteres por segurança
      'is_valido': _procuradorCache!.isTokenValido,
      'expira_em_breve': _procuradorCache!.expiraEmBreve,
      'tempo_restante_horas': _procuradorCache!.tempoRestante.inHours,
      'contratante_numero': _procuradorCache!.contratanteNumero,
      'autor_pedido_dados_numero': _procuradorCache!.autorPedidoDadosNumero,
    };
  }

  /// Verifica se o cliente está autenticado
  ///
  /// Retorna true se há um modelo de autenticação válido
  bool get isAuthenticated => _authModel != null;

  /// Obtém os dados de autenticação (apenas para debugging)
  ///
  /// ATENÇÃO: Este getter expõe informações sensíveis. Use apenas para debugging.
  AuthenticationModel? get authModel => _authModel;
}
