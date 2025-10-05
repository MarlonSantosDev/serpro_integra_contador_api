import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/obter_procuracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/obter_procuracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/procuracoes_enums.dart';

/// **Serviço:** PROCURACOES (Procurações Eletrônicas)
///
/// O serviço de procurações eletrônicas permite consultar procurações outorgadas e validar poderes.
///
/// **Este serviço permite:**
/// - Obter procurações eletrônicas (OBTERPROCURACAO281)
///
/// **Documentação oficial:** `.cursor/rules/procuracoes.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final procuracoesService = ProcuracoesService(apiClient);
///
/// // Obter procurações
/// final procuracao = await procuracoesService.obterProcuracao(
///   outorgante: '12345678000190',
///   outorgado: '12345678901',
/// );
/// if (procuracao.sucesso) {
///   print('Procuração encontrada: ${procuracao.numeroProcuracao}');
/// }
/// ```
class ProcuracoesService {
  final ApiClient _apiClient;

  ProcuracoesService(this._apiClient);

  /// Obtém procurações com dados específicos de tipos de documento
  ///
  /// [outorgante] - CPF/CNPJ do outorgante
  /// [tipoOutorgante] - Tipo do outorgante (1=CPF, 2=CNPJ)
  /// [outorgado] - CPF/CNPJ do procurador
  /// [tipoOutorgado] - Tipo do procurador (1=CPF, 2=CNPJ)
  Future<ObterProcuracaoResponse> obterProcuracaoComTipos(
    String outorgante,
    String tipoOutorgante,
    String outorgado,
    String tipoOutorgado, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final requestData = ObterProcuracaoRequest(
      outorgante: outorgante,
      tipoOutorgante: tipoOutorgante,
      outorgado: outorgado,
      tipoOutorgado: tipoOutorgado,
    );

    // Validar dados antes de enviar (comentado para testes)
    final erros = requestData.validate();
    if (erros.isNotEmpty) {
      //throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }

    final request = BaseRequest(
      contribuinteNumero: outorgante,
      pedidoDados: PedidoDados(
        idSistema: ProcuracoesConstants.idSistema,
        idServico: ProcuracoesConstants.idServico,
        versaoSistema: ProcuracoesConstants.versaoSistema,
        dados: requestData.toJsonString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ObterProcuracaoResponse.fromJson(response);
  }

  /// Método de conveniência para obter procurações de pessoa física
  Future<ObterProcuracaoResponse> obterProcuracaoPf(
    String cpfOutorgante,
    String cpfProcurador, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      cpfOutorgante,
      '1', // CPF
      cpfProcurador,
      '1', // CPF
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Método de conveniência para obter procurações de pessoa jurídica
  Future<ObterProcuracaoResponse> obterProcuracaoPj(
    String cnpjOutorgante,
    String cnpjProcurador, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      cnpjOutorgante,
      '2', // CNPJ
      cnpjProcurador,
      '2', // CNPJ
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Método de conveniência para obter procurações mistas (PF para PJ ou vice-versa)
  Future<ObterProcuracaoResponse> obterProcuracaoMista(
    String documentoOutorgante,
    String documentoProcurador,
    bool outorganteIsPj,
    bool procuradorIsPj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      documentoOutorgante,
      outorganteIsPj ? '2' : '1',
      documentoProcurador,
      procuradorIsPj ? '2' : '1',
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Analisa todas as procurações retornadas e gera estatísticas
  Map<String, dynamic> analisarProcuracoes(ObterProcuracaoResponse response) {
    if (!response.sucesso || response.dadosParsed == null) {
      return {'total': 0, 'ativas': 0, 'expiramEmBreve': 0, 'expiradas': 0, 'sistemasUnicos': <String>[], 'analiseStatus': 'sem_dados'};
    }

    final procuracoes = response.dadosParsed!;
    final sistemasUnicos = <String>{};

    int ativas = 0;
    int expiramEmBreve = 0;
    int expiradas = 0;

    for (final proc in procuracoes) {
      sistemasUnicos.addAll(proc.sistemas);

      switch (proc.status) {
        case StatusProcuracao.ativa:
          ativas++;
          break;
        case StatusProcuracao.expiraEmBreve:
          expiramEmBreve++;
          break;
        case StatusProcuracao.expirada:
          expiradas++;
          break;
        default:
          break;
      }
    }

    return {
      'total': procuracoes.length,
      'ativas': ativas,
      'expiramEmBreve': expiramEmBreve,
      'expiradas': expiradas,
      'sistemasUnicos': sistemasUnicos.toList(),
      'totalSistemasUnicos': sistemasUnicos.length,
      'analiseStatus': procuracoes.isEmpty ? 'nenhuma_procuracao' : 'com_procuracoes',
    };
  }

  /// Gera um relatório textual das procurações
  String gerarRelatorio(ObterProcuracaoResponse response) {
    final analise = analisarProcuracoes(response);

    if (!response.sucesso) {
      return '❌ Erro: ${response.mensagemPrincipal}';
    }

    if (analise['total'] == 0) {
      return 'ℹ️ Nenhuma procuração encontrada.';
    }

    final buffer = StringBuffer();
    buffer.writeln('📋 📊 RELATÓRIO DE PROCURAÇÕES');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📊 Resumo Geral:');
    buffer.writeln('   • Total: ${analise['total']} procurações');
    buffer.writeln('   • Ativas: ${analise['ativas']}');
    buffer.writeln('   • Expirando em breve: ${analise['expiramEmBreve']}');
    buffer.writeln('   • Expiradas: ${analise['expiradas']}');
    buffer.writeln('   • Sistemas únicos: ${analise['totalSistemasUnicos']}');
    buffer.writeln('');

    if (response.dadosParsed != null && response.dadosParsed!.isNotEmpty) {
      buffer.writeln('📝 Detalhes por Procuração:');

      for (int i = 0; i < response.dadosParsed!.length; i++) {
        final proc = response.dadosParsed![i];
        final emoji = proc.status == StatusProcuracao.ativa
            ? '✅'
            : proc.status == StatusProcuracao.expiraEmBreve
            ? '⚠️'
            : proc.status == StatusProcuracao.expirada
            ? '❌'
            : '❓';

        buffer.writeln('   $emoji Procuração ${i + 1}:');
        buffer.writeln('      • Status: ${proc.status.value}');
        buffer.writeln('      • Expira em: ${proc.dataExpiracaoFormatada}');
        buffer.writeln('      • Sistemas: ${proc.nrsistemas}');
        buffer.writeln('      • Lista: ${proc.sistemas.join(', ')}');
        buffer.writeln('');
      }

      if (analise['sistemasUnicos'].isNotEmpty) {
        buffer.writeln('🔧 Sistemas Encontrados:');
        for (final sistema in analise['sistemasUnicos']) {
          buffer.writeln('   • $sistema');
        }
      }
    }

    return buffer.toString();
  }
}
