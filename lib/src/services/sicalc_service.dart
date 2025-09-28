import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/consolidar_darf_request.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/consolidar_darf_response.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/consultar_receita_request.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/consultar_receita_response.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/gerar_codigo_barras_request.dart';
import 'package:serpro_integra_contador_api/src/models/sicalc/gerar_codigo_barras_response.dart';
import 'package:serpro_integra_contador_api/src/util/sicalc_utils.dart';
import 'package:serpro_integra_contador_api/src/util/document_utils.dart';

/// Serviço para integração com SICALC
///
/// Implementa todos os serviços disponíveis do Integra SICALC:
/// - Consolidar e Emitir um DARF (CONSOLIDARGERARDARF51)
/// - Consultar Código de Receita Sicalc (CONSULTAAPOIORECEITAS52)
/// - Consolidar e Emitir o Código de Barras de um DARF Calculado (GERARDARFCODBARRA53)
class SicalcService {
  final ApiClient _apiClient;

  SicalcService(this._apiClient);

  /// Consolidar e Emitir um DARF (CONSOLIDARGERARDARF51)
  ///
  /// Baseado nos parâmetros de entrada fornecidos pelo chamador, o serviço monta uma chamada
  /// para a funcionalidade de consolidação (cálculo da multa e dos juros), gera o documento
  /// PDF do DARF a partir do resultado da consolidação e devolve ao chamador o resultado
  /// do cálculo, o PDF do DARF e o número do documento.
  Future<ConsolidarDarfResponse> consolidarEGerarDarf({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required int codigoReceita,
    required int codigoReceitaExtensao,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int? numeroReferencia,
    String? tipoPA,
    int? cota,
    double? valorMulta,
    double? valorJuros,
    bool? ganhoCapital,
    String? dataAlienacao,
    String? observacao,
    int? cno,
    int? cnpjPrestador,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validar dados de entrada
    final erros = SicalcUtils.validarDadosConsolidacao(
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      tipoPA: tipoPA,
      cota: cota,
      valorMulta: valorMulta,
      valorJuros: valorJuros,
      dataAlienacao: dataAlienacao,
      observacao: observacao,
      cno: cno,
      cnpjPrestador: cnpjPrestador,
      tipoPessoa: DocumentUtils.detectDocumentType(contribuinteNumero),
    );

    if (erros.isNotEmpty) {
      throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }

    final request = ConsolidarDarfRequest(
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      numeroReferencia: numeroReferencia,
      tipoPA: tipoPA,
      dataPA: dataPA,
      vencimento: vencimento,
      cota: cota,
      valorImposto: valorImposto,
      valorMulta: valorMulta,
      valorJuros: valorJuros,
      ganhoCapital: ganhoCapital,
      dataAlienacao: dataAlienacao,
      dataConsolidacao: dataConsolidacao,
      observacao: observacao,
      cno: cno,
      cnpjPrestador: cnpjPrestador,
    );

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'SICALC',
        idServico: 'CONSOLIDARGERARDARF51',
        versaoSistema: '2.9',
        dados: request.toDadosJson(),
      ),
    );

    final endpoint = SicalcUtils.obterEndpoint('CONSOLIDARGERARDARF51');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsolidarDarfResponse.fromJson(response);
  }

  /// Consultar Código de Receita Sicalc (CONSULTAAPOIORECEITAS52)
  ///
  /// Este serviço retorna os dados de apoio de uma receita, como a descrição,
  /// o tipo de pessoa, o período de apuração, entre outros.
  Future<ConsultarReceitaResponse> consultarCodigoReceita({
    required String contribuinteNumero,
    required int codigoReceita,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validar código da receita
    if (!SicalcUtils.isValidCodigoReceita(codigoReceita)) {
      throw ArgumentError('Código da receita inválido: $codigoReceita');
    }

    final request = ConsultarReceitaRequest(codigoReceita: codigoReceita);

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'SICALC',
        idServico: 'CONSULTAAPOIORECEITAS52',
        versaoSistema: '2.9',
        dados: request.toDadosJson(),
      ),
    );

    final endpoint = SicalcUtils.obterEndpoint('CONSULTAAPOIORECEITAS52');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarReceitaResponse.fromJson(response);
  }

  /// Consolidar e Emitir o Código de Barras de um DARF Calculado (GERARDARFCODBARRA53)
  ///
  /// Este serviço gera o código de barras de um DARF já calculado.
  Future<GerarCodigoBarrasResponse> gerarCodigoBarrasDarf({
    required String contribuinteNumero,
    required int numeroDocumento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validar número do documento
    if (!SicalcUtils.isValidNumeroDocumento(numeroDocumento)) {
      throw ArgumentError('Número do documento inválido: $numeroDocumento');
    }

    final request = GerarCodigoBarrasRequest(numeroDocumento: numeroDocumento);

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'SICALC',
        idServico: 'GERARDARFCODBARRA53',
        versaoSistema: '2.9',
        dados: request.toDadosJson(),
      ),
    );

    final endpoint = SicalcUtils.obterEndpoint('GERARDARFCODBARRA53');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return GerarCodigoBarrasResponse.fromJson(response);
  }

  // MÉTODOS DE CONVENIÊNCIA PARA DIFERENTES TIPOS DE DARF

  /// Gera DARF para Pessoa Física (IRPF)
  Future<ConsolidarDarfResponse> gerarDarfPessoaFisica({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int codigoReceita = 190,
    int codigoReceitaExtensao = 1,
    String? observacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consolidarEGerarDarf(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      tipoPA: 'ME', // Mensal para PF
      observacao: observacao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF para Pessoa Jurídica (IRPJ)
  Future<ConsolidarDarfResponse> gerarDarfPessoaJuridica({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int codigoReceita = 220,
    int codigoReceitaExtensao = 1,
    String? observacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consolidarEGerarDarf(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      tipoPA: 'TR', // Trimestral para PJ
      observacao: observacao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF para PIS/PASEP
  Future<ConsolidarDarfResponse> gerarDarfPisPasep({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int codigoReceita = 1162,
    int codigoReceitaExtensao = 1,
    String? observacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consolidarEGerarDarf(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      tipoPA: 'ME', // Mensal
      observacao: observacao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF para COFINS
  Future<ConsolidarDarfResponse> gerarDarfCofins({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int codigoReceita = 1163,
    int codigoReceitaExtensao = 1,
    String? observacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consolidarEGerarDarf(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      tipoPA: 'ME', // Mensal
      observacao: observacao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  // MÉTODOS DE UTILIDADE

  /// Consulta informações de uma receita antes de gerar o DARF
  Future<ConsultarReceitaResponse> consultarReceitaAntesGerar({
    required String contribuinteNumero,
    required int codigoReceita,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarCodigoReceita(
      contribuinteNumero: contribuinteNumero,
      codigoReceita: codigoReceita,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF e em seguida gera o código de barras
  Future<GerarCodigoBarrasResponse> gerarDarfECodigoBarras({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required int codigoReceita,
    required int codigoReceitaExtensao,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int? numeroReferencia,
    String? tipoPA,
    int? cota,
    double? valorMulta,
    double? valorJuros,
    bool? ganhoCapital,
    String? dataAlienacao,
    String? observacao,
    int? cno,
    int? cnpjPrestador,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // 1. Gerar DARF
    final darfResponse = await consolidarEGerarDarf(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      numeroReferencia: numeroReferencia,
      tipoPA: tipoPA,
      cota: cota,
      valorMulta: valorMulta,
      valorJuros: valorJuros,
      ganhoCapital: ganhoCapital,
      dataAlienacao: dataAlienacao,
      observacao: observacao,
      cno: cno,
      cnpjPrestador: cnpjPrestador,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    if (!darfResponse.sucesso || darfResponse.dados == null) {
      throw Exception('Falha ao gerar DARF: ${darfResponse.mensagemPrincipal}');
    }

    // 2. Gerar código de barras
    return gerarCodigoBarrasDarf(
      contribuinteNumero: contribuinteNumero,
      numeroDocumento: darfResponse.dados!.numeroDocumento,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Valida se um código de receita é compatível com o tipo de pessoa do contribuinte
  Future<bool> validarCompatibilidadeReceita({
    required String contribuinteNumero,
    required int codigoReceita,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    try {
      final response = await consultarCodigoReceita(
        contribuinteNumero: contribuinteNumero,
        codigoReceita: codigoReceita,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      if (!response.sucesso || response.dados == null) {
        return false;
      }

      final tipoPessoaContribuinte = DocumentUtils.detectDocumentType(
        contribuinteNumero,
      );
      return SicalcUtils.validarCompatibilidadeReceitaTipoPessoa(
        codigoReceita,
        tipoPessoaContribuinte,
      );
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações detalhadas de uma receita
  Future<Map<String, dynamic>?> obterInfoReceita({
    required String contribuinteNumero,
    required int codigoReceita,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    try {
      final response = await consultarCodigoReceita(
        contribuinteNumero: contribuinteNumero,
        codigoReceita: codigoReceita,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      if (!response.sucesso || response.dados == null) {
        return null;
      }

      final dados = response.dados!;
      return {
        'codigoReceita': dados.codigoReceita,
        'descricaoReceita': dados.descricaoReceita,
        'tipoPessoa': dados.tipoPessoaFormatado,
        'tipoPeriodoApuracao': dados.tipoPeriodoFormatado,
        'observacoes': dados.observacoes,
        'ativa': dados.ativa,
        'vigente': dados.isVigente,
        'dataInicioVigencia': dados.dataInicioVigencia,
        'dataFimVigencia': dados.dataFimVigencia,
        'compativelComContribuinte':
            SicalcUtils.validarCompatibilidadeReceitaTipoPessoa(
              codigoReceita,
              DocumentUtils.detectDocumentType(contribuinteNumero),
            ),
      };
    } catch (e) {
      return null;
    }
  }
}
