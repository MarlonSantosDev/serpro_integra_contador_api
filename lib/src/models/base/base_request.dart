import '../../util/document_utils.dart';

/// Classe base para todas as requisições à API do SERPRO Integra Contador
///
/// Esta classe simplifica a criação de requisições ao centralizar os dados comuns:
/// - Dados do contribuinte (CPF/CNPJ)
/// - Dados do pedido (ID do sistema, serviço e dados específicos)
///
/// Os dados de contratante e autorPedidoDados são gerenciados automaticamente pelo ApiClient
/// para evitar repetição de código e garantir consistência.
class BaseRequest {
  /// Número do documento do contribuinte (CPF ou CNPJ)
  final String contribuinteNumero;

  /// Tipo do documento (1 = CPF, 2 = CNPJ) - detectado automaticamente
  final int contribuinteTipo;

  /// Dados específicos do pedido (ID do sistema, serviço e dados)
  final PedidoDados pedidoDados;

  /// Construtor que detecta automaticamente o tipo de documento
  ///
  /// [contribuinteNumero]: CPF ou CNPJ do contribuinte
  /// [pedidoDados]: Dados específicos do pedido
  BaseRequest({required this.contribuinteNumero, required this.pedidoDados})
    : contribuinteTipo = DocumentUtils.detectDocumentType(contribuinteNumero);

  /// Cria o JSON completo da requisição incluindo dados de autenticação
  ///
  /// Este método é chamado internamente pelo ApiClient para montar a requisição final.
  /// Os dados de contratante e autorPedidoDados são fornecidos pelo ApiClient baseado
  /// na autenticação atual ou nos parâmetros customizados da requisição.
  ///
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [contratanteTipo]: Tipo do documento do contratante (sempre 2 para CNPJ)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor da requisição
  /// [autorPedidoDadosTipo]: Tipo do documento do autor (1 = CPF, 2 = CNPJ)
  ///
  /// Retorna: Map com a estrutura completa da requisição para a API
  Map<String, dynamic> toJsonWithAuth({
    required String contratanteNumero,
    required int contratanteTipo,
    required String autorPedidoDadosNumero,
    required int autorPedidoDadosTipo,
  }) {
    return {
      'contratante': {
        'numero': DocumentUtils.cleanDocumentNumber(contratanteNumero),
        'tipo': contratanteTipo,
      },
      'autorPedidoDados': {
        'numero': DocumentUtils.cleanDocumentNumber(autorPedidoDadosNumero),
        'tipo': autorPedidoDadosTipo,
      },
      'contribuinte': {
        'numero': DocumentUtils.cleanDocumentNumber(contribuinteNumero),
        'tipo': contribuinteTipo,
      },
      'pedidoDados': pedidoDados.toJson(),
    };
  }
}

/// Classe que encapsula os dados específicos de cada pedido à API
///
/// Cada serviço da API do SERPRO tem seu próprio ID de sistema e serviço,
/// além dos dados específicos que variam conforme a operação solicitada.
class PedidoDados {
  /// Identificador único do sistema que está fazendo a requisição
  /// Geralmente é um código fornecido pelo SERPRO para identificar o sistema cliente
  final String idSistema;

  /// Identificador único do serviço específico sendo solicitado
  /// Cada endpoint da API tem seu próprio ID de serviço
  final String idServico;

  /// Versão do sistema (opcional, padrão é '1.0')
  final String? versaoSistema;

  /// Dados específicos do pedido (geralmente JSON stringificado)
  /// O conteúdo varia conforme o serviço sendo utilizado
  final String dados;

  /// Construtor para criar dados de pedido
  ///
  /// [idSistema]: ID do sistema cliente
  /// [idServico]: ID do serviço específico
  /// [versaoSistema]: Versão do sistema (opcional)
  /// [dados]: Dados específicos do pedido
  PedidoDados({
    required this.idSistema,
    required this.idServico,
    this.versaoSistema,
    required this.dados,
  });

  /// Cria PedidoDados a partir de JSON (para deserialização)
  factory PedidoDados.fromJson(Map<String, dynamic> json) {
    return PedidoDados(
      idSistema: json['idSistema'].toString(),
      idServico: json['idServico'].toString(),
      versaoSistema: json['versaoSistema']?.toString(),
      dados: json['dados'].toString(),
    );
  }

  /// Converte PedidoDados para JSON (para serialização)
  Map<String, dynamic> toJson() {
    return {
      'idSistema': idSistema,
      'idServico': idServico,
      'versaoSistema': versaoSistema ?? '1.0',
      'dados': dados,
    };
  }
}
