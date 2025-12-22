import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/services/sitfis/model/solicitar_protocolo_request.dart';
import 'package:serpro_integra_contador_api/src/services/sitfis/model/solicitar_protocolo_response.dart';
import 'package:serpro_integra_contador_api/src/services/sitfis/model/emitir_relatorio_request.dart';
import 'package:serpro_integra_contador_api/src/services/sitfis/model/emitir_relatorio_response.dart';

/// **Serviço:** SITFIS (Situação Fiscal)
///
/// Serviço para emissão de relatórios de situação fiscal de contribuintes
/// (Pessoa Física e Jurídica) na Receita Federal e Procuradoria-Geral da Fazenda Nacional.
///
/// **Este serviço permite:**
/// - Solicitar protocolo para geração do relatório (APOIAR)
/// - Emitir relatório de situação fiscal em PDF (EMITIR)
///
/// **Fluxo de uso:**
/// 1. Solicitar protocolo (retorna tempo de espera)
/// 2. Aguardar tempo indicado
/// 3. Emitir relatório com o protocolo
///
/// **Documentação oficial:** `.cursor/rules/sitfis/`
///
/// **Exemplo de uso:**
/// ```dart
/// final sitfisService = SitfisService(apiClient);
///
/// // 1. Solicitar protocolo
/// final protocolo = await sitfisService.solicitarProtocoloRelatorio('12345678901');
/// await Future.delayed(Duration(seconds: protocolo.tempoEspera));
///
/// // 2. Emitir relatório
/// final relatorio = await sitfisService.emitirRelatorioSituacaoFiscal(
///   '12345678901',
///   protocolo.numeroProtocolo,
/// );
/// print('PDF: ${relatorio.pdfBase64}');
/// ```
class SitfisService {
  final ApiClient _apiClient;

  SitfisService(this._apiClient);

  /// Solicita protocolo para emissão do relatório de situação fiscal
  ///
  /// Este método faz uma chamada ao endpoint `/Apoiar` para solicitar
  /// um protocolo que será usado posteriormente para emitir o relatório.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte (apenas números)
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [SolicitarProtocoloResponse] com o protocolo e tempo de espera
  Future<SolicitarProtocoloResponse> solicitarProtocoloRelatorio(
    String contribuinteNumero, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = SolicitarProtocoloRequest(
      contribuinteNumero: contribuinteNumero,
    );

    final response = await _apiClient.post(
      '/Apoiar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return SolicitarProtocoloResponse.fromJson(response);
  }

  /// Emite o relatório de situação fiscal usando o protocolo obtido
  ///
  /// Este método faz uma chamada ao endpoint `/Emitir` para gerar
  /// o relatório de situação fiscal em formato PDF.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte (apenas números)
  /// [protocoloRelatorio] - Protocolo obtido na solicitação anterior
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [EmitirRelatorioResponse] com o PDF do relatório ou tempo de espera
  Future<EmitirRelatorioResponse> emitirRelatorioSituacaoFiscal(
    String contribuinteNumero,
    String protocoloRelatorio, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EmitirRelatorioRequest(
      contribuinteNumero: contribuinteNumero,
      protocoloRelatorio: protocoloRelatorio,
    );

    final response = await _apiClient.post(
      '/Emitir',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return EmitirRelatorioResponse.fromJson(response);
  }
}
