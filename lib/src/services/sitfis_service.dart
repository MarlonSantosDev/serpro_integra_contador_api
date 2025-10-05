import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/solicitar_protocolo_request.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/solicitar_protocolo_response.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/emitir_relatorio_request.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/emitir_relatorio_response.dart';

/// Serviço para integração com o SITFIS (Situação Fiscal)
///
/// O SITFIS é um sistema que fornece relatórios de situação fiscal
/// de contribuintes Pessoa Jurídica e Pessoa Física no âmbito da
/// Receita Federal do Brasil e Procuradoria-Geral da Fazenda Nacional.
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
    final request = SolicitarProtocoloRequest(contribuinteNumero: contribuinteNumero);

    final response = await _apiClient.post('/Apoiar', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
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
    final request = EmitirRelatorioRequest(contribuinteNumero: contribuinteNumero, protocoloRelatorio: protocoloRelatorio);

    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return EmitirRelatorioResponse.fromJson(response);
  }
}
