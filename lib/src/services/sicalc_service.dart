import '../core/api_client.dart';
import '../models/sicalc/sicalc_request.dart';
import '../models/sicalc/sicalc_response.dart';
import '../util/sicalc_utils.dart';

/// Serviço para integração com SICALC (Sistema de Cálculo de Acréscimos Legais)
class SicalcService {
  final ApiClient _apiClient;

  SicalcService(this._apiClient);

  /// Consolidar e emitir um DARF
  ///
  /// Este serviço:
  /// - Monta uma chamada para a funcionalidade de consolidação (cálculo da multa e dos juros)
  /// - Gera o documento PDF do DARF a partir do resultado da consolidação
  /// - Devolve o resultado do cálculo e o PDF do DARF
  ///
  /// [request]: Dados da requisição para consolidação e emissão do DARF
  ///
  /// Retorna: ConsolidarEmitirDarfResponse com os dados consolidados e PDF do DARF
  Future<ConsolidarEmitirDarfResponse> consolidarEmitirDarf(ConsolidarEmitirDarfRequest request) async {
    try {
      // Validar dados da requisição
      final erros = request.validarDados();
      if (erros.isNotEmpty) {
        throw Exception('Dados inválidos: ${erros.join(', ')}');
      }

      // Obter endpoint correto
      final endpoint = SicalcUtils.obterEndpoint(request.pedidoDados.idServico);

      // Fazer a requisição
      final response = await _apiClient.post(endpoint, request);

      // Processar resposta
      return ConsolidarEmitirDarfResponse.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao consolidar e emitir DARF: $e');
    }
  }

  /// Consultar receitas do SICALC
  ///
  /// Este serviço consulta as receitas de apoio do SICALC para validar
  /// códigos de receita e obter informações sobre campos obrigatórios/opcionais.
  ///
  /// [request]: Dados da requisição para consulta de receitas
  ///
  /// Retorna: ConsultarReceitasResponse com informações da receita
  Future<ConsultarReceitasResponse> consultarReceitas(ConsultarReceitasRequest request) async {
    try {
      // Validar dados da requisição
      final erros = request.validarDados();
      if (erros.isNotEmpty) {
        throw Exception('Dados inválidos: ${erros.join(', ')}');
      }

      // Obter endpoint correto
      final endpoint = SicalcUtils.obterEndpoint(request.pedidoDados.idServico);

      // Fazer a requisição
      final response = await _apiClient.post(endpoint, request);

      // Processar resposta
      return ConsultarReceitasResponse.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao consultar receitas: $e');
    }
  }

  /// Consolidar e emitir código de barras do DARF
  ///
  /// Este serviço:
  /// - Monta uma chamada para a funcionalidade de consolidação (cálculo de multa e juros)
  /// - Gera o código de barras do DARF a partir do resultado da consolidação
  /// - Devolve o resultado do cálculo e os campos do código de barras
  ///
  /// [request]: Dados da requisição para geração do código de barras
  ///
  /// Retorna: GerarCodigoBarrasResponse com os dados consolidados e código de barras
  Future<GerarCodigoBarrasResponse> gerarCodigoBarras(GerarCodigoBarrasRequest request) async {
    try {
      // Validar dados da requisição
      final erros = request.validarDados();
      if (erros.isNotEmpty) {
        throw Exception('Dados inválidos: ${erros.join(', ')}');
      }

      // Obter endpoint correto
      final endpoint = SicalcUtils.obterEndpoint(request.pedidoDados.idServico);

      // Fazer a requisição
      final response = await _apiClient.post(endpoint, request);

      // Processar resposta
      return GerarCodigoBarrasResponse.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao gerar código de barras: $e');
    }
  }

  /// Método auxiliar para criar requisição de DARF de pessoa física
  static ConsolidarEmitirDarfRequest criarDarfPessoaFisica({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String codigoReceita,
    required String codigoReceitaExtensao,
    required String tipoPA,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    String? observacao,
  }) {
    return ConsolidarEmitirDarfRequest(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      tipoPA: tipoPA,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      observacao: observacao,
    );
  }

  /// Método auxiliar para criar requisição de DARF de pessoa jurídica
  static ConsolidarEmitirDarfRequest criarDarfPessoaJuridica({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String codigoReceita,
    required String codigoReceitaExtensao,
    required String tipoPA,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    int? cota,
    String? observacao,
  }) {
    return ConsolidarEmitirDarfRequest(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      tipoPA: tipoPA,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      cota: cota,
      observacao: observacao,
    );
  }

  /// Método auxiliar para criar requisição de código de barras
  static GerarCodigoBarrasRequest criarCodigoBarras({
    required String contribuinteNumero,
    required String uf,
    required int municipio,
    required String codigoReceita,
    required String codigoReceitaExtensao,
    required String tipoPA,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    String? observacao,
  }) {
    return GerarCodigoBarrasRequest(
      contribuinteNumero: contribuinteNumero,
      uf: uf,
      municipio: municipio,
      codigoReceita: codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao,
      tipoPA: tipoPA,
      dataPA: dataPA,
      vencimento: vencimento,
      valorImposto: valorImposto,
      dataConsolidacao: dataConsolidacao,
      observacao: observacao,
    );
  }

  /// Método auxiliar para criar requisição de consulta de receitas
  static ConsultarReceitasRequest criarConsultaReceitas({required String contribuinteNumero, required String codigoReceita}) {
    return ConsultarReceitasRequest(contribuinteNumero: contribuinteNumero, codigoReceita: codigoReceita);
  }

  /// Valida se uma receita permite código de barras
  Future<bool> receitaPermiteCodigoBarras(String codigoReceita) async {
    try {
      final request = criarConsultaReceitas(
        contribuinteNumero: '00000000000', // CPF genérico para consulta
        codigoReceita: codigoReceita,
      );

      final response = await consultarReceitas(request);

      if (response.receita?.extensoes.isNotEmpty == true) {
        return response.receita!.extensoes.any((extensao) => extensao.informacoes.codigoBarras);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações sobre campos obrigatórios de uma receita
  Future<Map<String, dynamic>?> obterInfoReceita(String codigoReceita) async {
    try {
      final request = criarConsultaReceitas(
        contribuinteNumero: '00000000000', // CPF genérico para consulta
        codigoReceita: codigoReceita,
      );

      final response = await consultarReceitas(request);

      if (response.receita != null) {
        return {
          'codigoReceita': response.receita!.codigoReceita,
          'descricaoReceita': response.receita!.descricaoReceita,
          'extensoes': response.receita!.extensoes
              .map(
                (e) => {
                  'obrigatorios': {
                    'codigoReceita': e.obrigatorios.codigoReceita,
                    'codigoReceitaExtensao': e.obrigatorios.codigoReceitaExtensao,
                    'cota': e.obrigatorios.cota,
                    'dataConsolidacao': e.obrigatorios.dataConsolidacao,
                    'dataPA': e.obrigatorios.dataPA,
                    'referencia': e.obrigatorios.referencia,
                    'tipoPA': e.obrigatorios.tipoPA,
                    'valorImposto': e.obrigatorios.valorImposto,
                    'vencimento': e.obrigatorios.vencimento,
                  },
                  'opcionais': {
                    'cno': e.opcionais.cno,
                    'cnpjPrestador': e.opcionais.cnpjPrestador,
                    'municipio': e.opcionais.municipio,
                    'observacao': e.opcionais.observacao,
                    'referencia': e.opcionais.referencia,
                    'uf': e.opcionais.uf,
                    'valorJuros': e.opcionais.valorJuros,
                    'valorMulta': e.opcionais.valorMulta,
                  },
                  'informacoes': {
                    'calculado': e.informacoes.calculado,
                    'codigoBarras': e.informacoes.codigoBarras,
                    'codigoReceitaExtensao': e.informacoes.codigoReceitaExtensao,
                    'criacao': e.informacoes.criacao,
                    'descricaoReceitaExtensao': e.informacoes.descricaoReceitaExtensao,
                    'descricaoReferencia': e.informacoes.descricaoReferencia,
                    'exigeMatriz': e.informacoes.exigeMatriz,
                    'extincao': e.informacoes.extincao,
                    'manual': e.informacoes.manual,
                    'pf': e.informacoes.pf,
                    'pj': e.informacoes.pj,
                    'tipoPeriodoApuracao': e.informacoes.tipoPeriodoApuracao,
                    'vedaValor': e.informacoes.vedaValor,
                  },
                },
              )
              .toList(),
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
