import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/obter_procuracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/obter_procuracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/procuracoes/model/procuracoes_enums.dart';

/// **Serviço:** PROCURACOES (Procurações Eletrônicas)
///
/// O serviço de procurações eletrônicas permite consultar procurações outorgadas e validar poderes.
///
/// **Este serviço disponibiliza APENAS 1 serviço oficial da API SERPRO:**
/// - **OBTERPROCURACAO41**: Obter procurações eletrônicas entre outorgante e procurador
///
/// **Documentação oficial:** `.cursor/rules/procuracoes.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final procuracoesService = ProcuracoesService(apiClient);
///
/// // Obter procurações (detecta automaticamente CPF/CNPJ)
/// final procuracao = await procuracoesService.consultarProcuracao(
///   outorgante: '12345678000190',
///   // outorgado é opcional se o usuário já estiver autenticado
/// );
///
/// if (procuracao.sucesso) {
///   print('Procuração encontrada com sucesso!');
/// }
/// ```
class ProcuracoesService {
  final ApiClient _apiClient;

  ProcuracoesService(this._apiClient);

  /// Consulta procurações eletrônicas entre um outorgante e um procurador.
  ///
  /// Este método detecta automaticamente se os documentos informados são CPF ou CNPJ.
  ///
  /// [outorgante] - CPF ou CNPJ do outorgante (quem passou a procuração)
  /// [outorgado] - (Opcional) CPF ou CNPJ do procurador. Se não informado, utiliza o documento do usuário autenticado.
  /// [contratanteNumero] - (Opcional) CNPJ do contratante. Se não informado, usa o da autenticação.
  /// [autorPedidoDadosNumero] - (Opcional) CPF/CNPJ do autor. Se não informado, usa o da autenticação.
  Future<ObterProcuracaoResponse> consultarProcuracao({
    required String outorgante,
    String? outorgado,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Tenta obter o outorgado do parâmetro ou da autenticação
    final outorgadoFinal = outorgado ?? _apiClient.autorPedidoDadosNumero;

    if (outorgadoFinal == null || outorgadoFinal.isEmpty) {
      throw ArgumentError(
        'CPF/CNPJ do outorgado (procurador) não informado e não foi possível obter da autenticação. '
        'Certifique-se de que o cliente esteja autenticado ou informe o parâmetro "outorgado".',
      );
    }

    // Cria o request que já detecta automaticamente os tipos de documento
    final requestData = ObterProcuracaoRequest.fromDocuments(
      outorgante: outorgante,
      outorgado: outorgadoFinal,
    );

    // Valida dados antes de enviar
    final erros = requestData.validate();
    if (erros.isNotEmpty) {
      // Em produção, você pode querer lançar uma exceção ou retornar erro
      // throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }

    final request = BaseRequest(
      contribuinteNumero:
          requestData.outorgante, // O contribuinte é o outorgante
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

  /// Método legado para compatibilidade interna.
  /// Recomendado usar [consultarProcuracao] que é mais simples.
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

  /// Analisa todas as procurações retornadas e gera estatísticas
  Map<String, dynamic> analisarProcuracoes(ObterProcuracaoResponse response) {
    if (!response.sucesso || response.dados == null) {
      return {
        'total': 0,
        'ativas': 0,
        'expiramEmBreve': 0,
        'expiradas': 0,
        'sistemasUnicos': <String>[],
        'analiseStatus': 'sem_dados',
      };
    }

    final procuracoes = response.dados!;
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
      'analiseStatus': procuracoes.isEmpty
          ? 'nenhuma_procuracao'
          : 'com_procuracoes',
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

    if (response.dados != null && response.dados!.isNotEmpty) {
      buffer.writeln('📝 Detalhes por Procuração:');

      for (int i = 0; i < response.dados!.length; i++) {
        final proc = response.dados![i];
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
