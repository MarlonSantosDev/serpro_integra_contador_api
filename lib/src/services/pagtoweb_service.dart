import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/pagtoweb/pagtoweb_request.dart';
import 'package:serpro_integra_contador_api/src/models/pagtoweb/pagtoweb_response.dart';

/// Serviço para integração com PAGTOWEB
///
/// Implementa todos os serviços disponíveis do Integra PAGTOWEB:
/// - Consultar Pagamentos (PAGAMENTOS71)
/// - Contar Pagamentos (CONTACONSDOCARRPG73)
/// - Emitir Comprovante de Pagamento (EMITECOMPROVANTEPAGAMENTO72)
class PagtoWebService {
  final ApiClient _apiClient;

  PagtoWebService(this._apiClient);

  /// Consulta pagamentos com filtros opcionais
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [dataInicial] Data inicial do intervalo (formato: AAAA-MM-DD)
  /// [dataFinal] Data final do intervalo (formato: AAAA-MM-DD)
  /// [codigoReceitaLista] Lista de códigos de receita
  /// [valorInicial] Valor inicial do intervalo
  /// [valorFinal] Valor final do intervalo
  /// [numeroDocumentoLista] Lista de números de documento
  /// [codigoTipoDocumentoLista] Lista de tipos de documento
  /// [primeiroDaPagina] Índice do primeiro item da página (padrão: 0)
  /// [tamanhoDaPagina] Tamanho da página (padrão: 100)
  /// [contratanteNumero] Número do contratante (opcional)
  /// [autorPedidoDadosNumero] Número do autor do pedido (opcional)
  Future<ConsultarPagamentosResponse> consultarPagamentos({
    required String contribuinteNumero,
    String? dataInicial,
    String? dataFinal,
    List<String>? codigoReceitaLista,
    double? valorInicial,
    double? valorFinal,
    List<String>? numeroDocumentoLista,
    List<String>? codigoTipoDocumentoLista,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ConsultarPagamentosRequest(
      contribuinteNumero: contribuinteNumero,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      codigoReceitaLista: codigoReceitaLista,
      valorInicial: valorInicial,
      valorFinal: valorFinal,
      numeroDocumentoLista: numeroDocumentoLista,
      codigoTipoDocumentoLista: codigoTipoDocumentoLista,
      primeiroDaPagina: primeiroDaPagina,
      tamanhoDaPagina: tamanhoDaPagina,
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarPagamentosResponse.fromJson(response);
  }

  /// Conta pagamentos com filtros opcionais
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [dataInicial] Data inicial do intervalo (formato: AAAA-MM-DD)
  /// [dataFinal] Data final do intervalo (formato: AAAA-MM-DD)
  /// [codigoReceitaLista] Lista de códigos de receita
  /// [valorInicial] Valor inicial do intervalo
  /// [valorFinal] Valor final do intervalo
  /// [numeroDocumentoLista] Lista de números de documento
  /// [codigoTipoDocumentoLista] Lista de tipos de documento
  /// [contratanteNumero] Número do contratante (opcional)
  /// [autorPedidoDadosNumero] Número do autor do pedido (opcional)
  Future<ContarPagamentosResponse> contarPagamentos({
    required String contribuinteNumero,
    String? dataInicial,
    String? dataFinal,
    List<String>? codigoReceitaLista,
    double? valorInicial,
    double? valorFinal,
    List<String>? numeroDocumentoLista,
    List<String>? codigoTipoDocumentoLista,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ContarPagamentosRequest(
      contribuinteNumero: contribuinteNumero,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      codigoReceitaLista: codigoReceitaLista,
      valorInicial: valorInicial,
      valorFinal: valorFinal,
      numeroDocumentoLista: numeroDocumentoLista,
      codigoTipoDocumentoLista: codigoTipoDocumentoLista,
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ContarPagamentosResponse.fromJson(response);
  }

  /// Emite comprovante de pagamento
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [numeroDocumento] Número do documento de arrecadação
  /// [contratanteNumero] Número do contratante (opcional)
  /// [autorPedidoDadosNumero] Número do autor do pedido (opcional)
  Future<EmitirComprovanteResponse> emitirComprovante({
    required String contribuinteNumero,
    required String numeroDocumento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EmitirComprovanteRequest(
      contribuinteNumero: contribuinteNumero,
      numeroDocumento: numeroDocumento,
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return EmitirComprovanteResponse.fromJson(response);
  }

  // ===== MÉTODOS DE CONVENIÊNCIA =====

  /// Consulta pagamentos por intervalo de data
  Future<ConsultarPagamentosResponse> consultarPagamentosPorData({
    required String contribuinteNumero,
    required String dataInicial,
    required String dataFinal,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarPagamentos(
      contribuinteNumero: contribuinteNumero,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      primeiroDaPagina: primeiroDaPagina,
      tamanhoDaPagina: tamanhoDaPagina,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta pagamentos por códigos de receita
  Future<ConsultarPagamentosResponse> consultarPagamentosPorReceita({
    required String contribuinteNumero,
    required List<String> codigoReceitaLista,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarPagamentos(
      contribuinteNumero: contribuinteNumero,
      codigoReceitaLista: codigoReceitaLista,
      primeiroDaPagina: primeiroDaPagina,
      tamanhoDaPagina: tamanhoDaPagina,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta pagamentos por intervalo de valor
  Future<ConsultarPagamentosResponse> consultarPagamentosPorValor({
    required String contribuinteNumero,
    required double valorInicial,
    required double valorFinal,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarPagamentos(
      contribuinteNumero: contribuinteNumero,
      valorInicial: valorInicial,
      valorFinal: valorFinal,
      primeiroDaPagina: primeiroDaPagina,
      tamanhoDaPagina: tamanhoDaPagina,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta pagamentos por números de documento
  Future<ConsultarPagamentosResponse> consultarPagamentosPorDocumento({
    required String contribuinteNumero,
    required List<String> numeroDocumentoLista,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarPagamentos(
      contribuinteNumero: contribuinteNumero,
      numeroDocumentoLista: numeroDocumentoLista,
      primeiroDaPagina: primeiroDaPagina,
      tamanhoDaPagina: tamanhoDaPagina,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Conta pagamentos por intervalo de data
  Future<ContarPagamentosResponse> contarPagamentosPorData({
    required String contribuinteNumero,
    required String dataInicial,
    required String dataFinal,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return contarPagamentos(
      contribuinteNumero: contribuinteNumero,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Conta pagamentos por códigos de receita
  Future<ContarPagamentosResponse> contarPagamentosPorReceita({
    required String contribuinteNumero,
    required List<String> codigoReceitaLista,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return contarPagamentos(
      contribuinteNumero: contribuinteNumero,
      codigoReceitaLista: codigoReceitaLista,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Conta pagamentos por intervalo de valor
  Future<ContarPagamentosResponse> contarPagamentosPorValor({
    required String contribuinteNumero,
    required double valorInicial,
    required double valorFinal,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return contarPagamentos(
      contribuinteNumero: contribuinteNumero,
      valorInicial: valorInicial,
      valorFinal: valorFinal,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Conta pagamentos por números de documento
  Future<ContarPagamentosResponse> contarPagamentosPorDocumento({
    required String contribuinteNumero,
    required List<String> numeroDocumentoLista,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return contarPagamentos(
      contribuinteNumero: contribuinteNumero,
      numeroDocumentoLista: numeroDocumentoLista,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
