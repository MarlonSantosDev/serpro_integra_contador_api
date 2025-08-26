import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../models/dados_entrada.dart';
import '../models/dados_saida.dart';
import '../models/identificacao.dart';
import '../models/pedido_dados.dart';
import '../models/problem_details.dart';
import '../exceptions/api_exception.dart';

/// Configuração do cliente da API
@immutable
class ApiConfig {
  /// URL base da API
  final String baseUrl;

  /// Timeout para requisições
  final Duration timeout;

  /// Número máximo de tentativas
  final int maxRetries;

  /// Delay entre tentativas
  final Duration retryDelay;

  /// Headers customizados
  final Map<String, String> customHeaders;

  const ApiConfig({this.baseUrl = 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1', this.timeout = const Duration(seconds: 30), this.maxRetries = 3, this.retryDelay = const Duration(seconds: 2), this.customHeaders = const {}});

  ApiConfig copyWith({String? baseUrl, Duration? timeout, int? maxRetries, Duration? retryDelay, Map<String, String>? customHeaders}) {
    return ApiConfig(baseUrl: baseUrl ?? this.baseUrl, timeout: timeout ?? this.timeout, maxRetries: maxRetries ?? this.maxRetries, retryDelay: retryDelay ?? this.retryDelay, customHeaders: customHeaders ?? this.customHeaders);
  }
}

/// Resultado de uma operação da API
@immutable
class ApiResult<T> {
  /// Dados retornados (em caso de sucesso)
  final T? data;

  /// Erro ocorrido (em caso de falha)
  final IntegraContadorException? error;

  /// Indica se a operação foi bem-sucedida
  final bool isSuccess;

  const ApiResult._({this.data, this.error, required this.isSuccess});

  /// Cria um resultado de sucesso
  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  /// Cria um resultado de erro
  factory ApiResult.failure(IntegraContadorException error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  /// Verifica se houve falha
  bool get isFailure => !isSuccess;

  /// Executa uma função se o resultado for sucesso
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(mapper(data!));
      } catch (e) {
        return ApiResult.failure(ExceptionFactory.network('Erro ao processar dados: $e'));
      }
    }
    return ApiResult.failure(error!);
  }

  /// Executa uma função assíncrona se o resultado for sucesso
  Future<ApiResult<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    if (isSuccess && data != null) {
      try {
        final result = await mapper(data!);
        return ApiResult.success(result);
      } catch (e) {
        return ApiResult.failure(ExceptionFactory.network('Erro ao processar dados: $e'));
      }
    }
    return ApiResult.failure(error!);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success($data)';
    } else {
      return 'ApiResult.failure($error)';
    }
  }
}

/// Serviço principal para interação com a API Integra Contador
class IntegraContadorService {
  final String _jwtToken;
  final String? _procuradorToken;
  final ApiConfig _config;
  final http.Client _httpClient;

  IntegraContadorService({required String jwtToken, String? procuradorToken, ApiConfig? config, http.Client? httpClient}) : _jwtToken = jwtToken, _procuradorToken = procuradorToken, _config = config ?? const ApiConfig(), _httpClient = httpClient ?? http.Client();

  /// Headers padrão para requisições
  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{'Content-Type': 'application/json', 'Authorization': 'Bearer $_jwtToken', 'User-Agent': 'IntegraContadorDart/1.0.0', ..._config.customHeaders};

    if (_procuradorToken != null) {
      headers['autenticar_procurador_token'] = _procuradorToken!;
    }

    return headers;
  }

  /// Executa uma requisição POST com retry automático
  Future<ApiResult<DadosSaida>> _executeRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${_config.baseUrl}$endpoint');
    print('url: $url');
    print('body: ${jsonEncode(body)}');
    print('headers: ${_defaultHeaders}');

    for (int attempt = 1; attempt <= _config.maxRetries; attempt++) {
      try {
        final response = await _httpClient.post(url, headers: _defaultHeaders, body: jsonEncode(body)).timeout(_config.timeout);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final dadosSaida = DadosSaida.fromJson(responseData);
          return ApiResult.success(dadosSaida);
        } else {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final problemDetails = ProblemDetails.fromJson(errorData);
          final exception = ExceptionFactory.fromProblemDetails(problemDetails);

          // Não tenta novamente para erros de cliente (4xx)
          if (response.statusCode >= 400 && response.statusCode < 500) {
            return ApiResult.failure(exception);
          }

          // Para erros de servidor (5xx), tenta novamente
          if (attempt == _config.maxRetries) {
            return ApiResult.failure(exception);
          }
        }
      } on SocketException catch (e) {
        final exception = ExceptionFactory.network('Erro de conectividade: ${e.message}');
        if (attempt == _config.maxRetries) {
          return ApiResult.failure(exception);
        }
      } on TimeoutException catch (_) {
        final exception = ExceptionFactory.timeout(duration: _config.timeout);
        if (attempt == _config.maxRetries) {
          return ApiResult.failure(exception);
        }
      } on FormatException catch (e) {
        final exception = ExceptionFactory.network('Resposta inválida do servidor: ${e.message}');
        return ApiResult.failure(exception);
      } catch (e) {
        final exception = ExceptionFactory.network('Erro inesperado: $e');
        if (attempt == _config.maxRetries) {
          return ApiResult.failure(exception);
        }
      }

      // Aguarda antes da próxima tentativa
      if (attempt < _config.maxRetries) {
        await Future.delayed(_config.retryDelay);
      }
    }

    return ApiResult.failure(ExceptionFactory.network('Falha após ${_config.maxRetries} tentativas'));
  }

  /// Executa operação de apoio
  Future<ApiResult<DadosSaida>> apoiar(DadosEntrada dadosEntrada) async {
    return _executeRequest('/Apoiar', dadosEntrada.toJson());
  }

  /// Executa consulta
  Future<ApiResult<DadosSaida>> consultar(PedidoDados pedidoDados) async {
    return _executeRequest('/Consultar', pedidoDados.toJson());
  }

  /// Executa declaração
  Future<ApiResult<DadosSaida>> declarar(PedidoDados pedidoDados) async {
    return _executeRequest('/Declarar', pedidoDados.toJson());
  }

  /// Executa emissão
  Future<ApiResult<DadosSaida>> emitir(PedidoDados pedidoDados) async {
    return _executeRequest('/Emitir', pedidoDados.toJson());
  }

  /// Executa monitoramento
  Future<ApiResult<DadosSaida>> monitorar(PedidoDados pedidoDados) async {
    return _executeRequest('/Monitorar', pedidoDados.toJson());
  }

  /// Consulta situação fiscal de pessoa física ou jurídica
  Future<ApiResult<DadosSaida>> consultarSituacaoFiscal({required String documento, required String anoBase, bool incluirDebitos = false, bool incluirCertidoes = false}) async {
    final pedido = PedidoDados(identificacao: documento.length == 11 ? Identificacao.cpf(documento) : Identificacao.cnpj(documento), servico: 'SITFIS.CONSULTAR', parametros: {'ano_base': anoBase, 'incluir_debitos': incluirDebitos, 'incluir_certidoes': incluirCertidoes});

    return consultar(pedido);
  }

  /// Consulta dados de empresa
  Future<ApiResult<DadosSaida>> consultarDadosEmpresa({required String cnpj, bool incluirSocios = false, bool incluirAtividades = false, bool incluirEndereco = false}) async {
    final pedido = PedidoDados(identificacao: Identificacao.cnpj(cnpj), servico: 'EMPRESA.CONSULTAR', parametros: {'incluir_socios': incluirSocios, 'incluir_atividades': incluirAtividades, 'incluir_endereco': incluirEndereco});

    return consultar(pedido);
  }

  /// Envia declaração IRPF
  Future<ApiResult<DadosSaida>> enviarDeclaracaoIRPF({required String cpf, required String anoCalendario, required String tipoDeclaracao, required String arquivoDeclaracao, String? hashArquivo}) async {
    final pedido = PedidoDados(identificacao: Identificacao.cpf(cpf), servico: 'IRPF.DECLARAR', parametros: {'ano_calendario': anoCalendario, 'tipo_declaracao': tipoDeclaracao, 'arquivo_declaracao': arquivoDeclaracao, 'hash_arquivo': hashArquivo});

    return declarar(pedido);
  }

  /// Emite DARF
  Future<ApiResult<DadosSaida>> emitirDARF({required String documento, required String codigoReceita, required String periodoApuracao, required String valorPrincipal, String? valorMulta, String? valorJuros, required DateTime dataVencimento}) async {
    final pedido = PedidoDados(identificacao: documento.length == 11 ? Identificacao.cpf(documento) : Identificacao.cnpj(documento), servico: 'SICALC.EMITIR_DARF', parametros: {'codigo_receita': codigoReceita, 'periodo_apuracao': periodoApuracao, 'valor_principal': valorPrincipal, 'valor_multa': valorMulta, 'valor_juros': valorJuros, 'data_vencimento': dataVencimento.toIso8601String()});

    return emitir(pedido);
  }

  /// Monitora processamento
  Future<ApiResult<DadosSaida>> monitorarProcessamento({required String documento, required String numeroProtocolo, required String tipoOperacao}) async {
    final pedido = PedidoDados(identificacao: documento.length == 11 ? Identificacao.cpf(documento) : Identificacao.cnpj(documento), servico: 'GERENCIADOR.MONITORAR', parametros: {'numero_protocolo': numeroProtocolo, 'tipo_operacao': tipoOperacao});

    return monitorar(pedido);
  }

  /// Valida certificado digital
  Future<ApiResult<DadosSaida>> validarCertificado({required String certificadoBase64, required String senha, bool validarCadeia = true}) async {
    final dadosEntrada = DadosEntrada.validacaoCertificado(certificadoBase64: certificadoBase64, senha: senha, validarCadeia: validarCadeia);

    return apoiar(dadosEntrada);
  }

  /// Testa conectividade com a API
  Future<ApiResult<bool>> testarConectividade() async {
    try {
      final url = Uri.parse('${_config.baseUrl}/health');
      final response = await _httpClient.get(url, headers: _defaultHeaders).timeout(const Duration(seconds: 10));

      return ApiResult.success(response.statusCode == 200);
    } catch (e) {
      return ApiResult.failure(ExceptionFactory.network('Falha no teste de conectividade: $e'));
    }
  }

  /// Libera recursos
  void dispose() {
    _httpClient.close();
  }
}

/// Builder para facilitar a criação do serviço
class IntegraContadorServiceBuilder {
  String? _jwtToken;
  String? _procuradorToken;
  ApiConfig? _config;
  http.Client? _httpClient;

  /// Define o token JWT
  IntegraContadorServiceBuilder withJwtToken(String token) {
    _jwtToken = token;
    return this;
  }

  /// Define o token de procurador
  IntegraContadorServiceBuilder withProcuradorToken(String token) {
    _procuradorToken = token;
    return this;
  }

  /// Define a configuração da API
  IntegraContadorServiceBuilder withConfig(ApiConfig config) {
    _config = config;
    return this;
  }

  /// Define o cliente HTTP customizado
  IntegraContadorServiceBuilder withHttpClient(http.Client client) {
    _httpClient = client;
    return this;
  }

  /// Define timeout personalizado
  IntegraContadorServiceBuilder withTimeout(Duration timeout) {
    _config = (_config ?? const ApiConfig()).copyWith(timeout: timeout);
    return this;
  }

  /// Define número máximo de tentativas
  IntegraContadorServiceBuilder withMaxRetries(int maxRetries) {
    _config = (_config ?? const ApiConfig()).copyWith(maxRetries: maxRetries);
    return this;
  }

  /// Constrói o serviço
  IntegraContadorService build() {
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      throw ArgumentError('JWT Token é obrigatório');
    }

    return IntegraContadorService(jwtToken: _jwtToken!, procuradorToken: _procuradorToken, config: _config, httpClient: _httpClient);
  }
}
