import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/services/pagtoweb/model/pagtoweb_request.dart';
import 'package:serpro_integra_contador_api/src/services/pagtoweb/model/pagtoweb_response.dart';

/// **Serviço:** PAGTOWEB (Sistema de Pagamentos do Simples Nacional)
///
/// O PAGTOWEB é o sistema para consulta de pagamentos do Simples Nacional.
///
/// **Este serviço permite:**
/// - Consultar pagamentos (PAGAMENTOS71)
/// - Emitir comprovante de pagamento (EMITECOMPROVANTEPAGAMENTO72)
/// - Contar documentos de pagamento (CONTACONSDOCARRPG73)
///
/// **Documentação oficial:** `.cursor/rules/pagtoweb.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final pagtoWebService = PagtoWebService(apiClient);
///
/// // Consultar pagamentos
/// final pagamentos = await pagtoWebService.consultarPagamentos(
///   contribuinteNumero: '12345678000190',
///   dataInicial: '2024-01-01',
///   dataFinal: '2024-12-31',
/// );
/// print('Total de pagamentos: ${pagamentos.totalRegistros}');
///
/// // Emitir comprovante
/// final comprovante = await pagtoWebService.emitirComprovante(
///   numeroDocumento: '123456789',
///   codigoTipoDocumento: '001',
/// );
/// print('Comprovante PDF: ${comprovante.pdfBase64}');
/// ```
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
    final request = EmitirComprovanteRequest(contribuinteNumero: contribuinteNumero, numeroDocumento: numeroDocumento);

    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    return EmitirComprovanteResponse.fromJson(response);
  }

  // ===== MÉTODOS ESPECÍFICOS PARA CADA SERVIÇO =====

  /// 1. Consulta Pagamento: quando pesquisado por intervaloDataArrecadacao
  Future<ConsultarPagamentosResponse> consultarPagamentosPorIntervaloDataArrecadacao({
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

  /// 2. Consulta Pagamento: quando pesquisado por codigoReceitaLista
  Future<ConsultarPagamentosResponse> consultarPagamentosPorCodigoReceitaLista({
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

  /// 3. Consulta Pagamento: quando pesquisado por intervaloValorTotalDocumento
  Future<ConsultarPagamentosResponse> consultarPagamentosPorIntervaloValorTotalDocumento({
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

  /// 4. Conta Consulta Pagamento: quando pesquisado por intervaloDataArrecadacao
  Future<ContarPagamentosResponse> contarPagamentosPorIntervaloDataArrecadacao({
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

  /// 5. Conta Consulta Pagamento: quando pesquisado por codigoReceitaLista
  Future<ContarPagamentosResponse> contarPagamentosPorCodigoReceitaLista({
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

  /// 6. Conta Consulta Pagamento: quando pesquisado por intervaloValorTotalDocumento
  Future<ContarPagamentosResponse> contarPagamentosPorIntervaloValorTotalDocumento({
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

  /// 7. Emitir Comprovante de Pagamento
  Future<EmitirComprovanteResponse> emitirComprovantePagamento({
    required String contribuinteNumero,
    required String numeroDocumento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return emitirComprovante(
      contribuinteNumero: contribuinteNumero,
      numeroDocumento: numeroDocumento,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
