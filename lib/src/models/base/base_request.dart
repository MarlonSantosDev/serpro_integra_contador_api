import '../../util/document_utils.dart';

/// Requisição base simplificada - apenas com os dados do pedido
/// Os dados de contratante, autorPedidoDados e contribuinte são gerenciados pelo ApiClient
class BaseRequest {
  final String contribuinteNumero;
  final int contribuinteTipo;
  final PedidoDados pedidoDados;

  BaseRequest({required this.contribuinteNumero, required this.pedidoDados})
    : contribuinteTipo = DocumentUtils.detectDocumentType(contribuinteNumero);

  /// Cria o JSON completo incluindo dados de autenticação
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

class PedidoDados {
  final String idSistema;
  final String idServico;
  final String? versaoSistema;
  final String dados;

  PedidoDados({
    required this.idSistema,
    required this.idServico,
    this.versaoSistema,
    required this.dados,
  });

  factory PedidoDados.fromJson(Map<String, dynamic> json) {
    return PedidoDados(
      idSistema: json['idSistema'] as String,
      idServico: json['idServico'] as String,
      versaoSistema: json['versaoSistema'] as String?,
      dados: json['dados'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSistema': idSistema,
      'idServico': idServico,
      'versaoSistema': versaoSistema ?? '1.0',
      'dados': dados,
    };
  }
}

// Classes mantidas para compatibilidade, mas não são mais usadas diretamente nos serviços
@Deprecated(
  'Use os dados de autenticação do ApiClient ao invés de criar manualmente',
)
class Contratante {
  final String numero;
  final int tipo;

  Contratante({required this.numero, required this.tipo});

  factory Contratante.fromJson(Map<String, dynamic> json) {
    return Contratante(
      numero: json['numero'] as String,
      tipo: json['tipo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}

@Deprecated(
  'Use os dados de autenticação do ApiClient ao invés de criar manualmente',
)
class AutorPedidoDados {
  final String numero;
  final int tipo;

  AutorPedidoDados({required this.numero, required this.tipo});

  factory AutorPedidoDados.fromJson(Map<String, dynamic> json) {
    return AutorPedidoDados(
      numero: json['numero'] as String,
      tipo: json['tipo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}

@Deprecated(
  'Use os dados de autenticação do ApiClient ao invés de criar manualmente',
)
class Contribuinte {
  final String numero;
  final int tipo;

  Contribuinte({required this.numero, required this.tipo});

  factory Contribuinte.fromJson(Map<String, dynamic> json) {
    return Contribuinte(
      numero: json['numero'] as String,
      tipo: json['tipo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}
