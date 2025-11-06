import 'dart:convert';
import 'mensagem.dart';

class ConsultarPedidosResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ParcelamentosData? dados;

  ConsultarPedidosResponse({required this.status, required this.mensagens, this.dados});

  factory ConsultarPedidosResponse.fromJson(Map<String, dynamic> json) {
    ParcelamentosData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = ParcelamentosData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarPedidosResponse(
      status: json['status']?.toString() ?? '',
      mensagens: (json['mensagens'] as List?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get sucesso => status == '200';

  /// Mensagem principal de sucesso ou erro
  String get mensagemPrincipal {
    if (mensagens.isNotEmpty) {
      return mensagens.first.texto;
    }
    return sucesso ? 'Requisição efetuada com sucesso.' : 'Erro na requisição.';
  }

  /// Verifica se há parcelamentos disponíveis
  bool get temParcelamentos {
    return dados?.parcelamentos.isNotEmpty ?? false;
  }

  /// Quantidade de parcelamentos encontrados
  int get quantidadeParcelamentos {
    return dados?.parcelamentos.length ?? 0;
  }

  /// Lista de parcelamentos ativos
  List<Parcelamento> get parcelamentosAtivos {
    return dados?.parcelamentos.where((p) => p.isAtivo).toList() ?? [];
  }

  /// Lista de parcelamentos encerrados
  List<Parcelamento> get parcelamentosEncerrados {
    return dados?.parcelamentos.where((p) => p.isEncerrado).toList() ?? [];
  }
}

class ParcelamentosData {
  final List<Parcelamento> parcelamentos;

  ParcelamentosData({required this.parcelamentos});

  factory ParcelamentosData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ParcelamentosData(
        parcelamentos: (json['parcelamentos'] as List?)?.map((e) => Parcelamento.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      );
    } catch (e) {
      return ParcelamentosData(parcelamentos: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {'parcelamentos': parcelamentos.map((e) => e.toJson()).toList()};
  }
}

class Parcelamento {
  final int numero;
  final int dataDoPedido;
  final String situacao;
  final int dataDaSituacao;

  Parcelamento({required this.numero, required this.dataDoPedido, required this.situacao, required this.dataDaSituacao});

  factory Parcelamento.fromJson(Map<String, dynamic> json) {
    return Parcelamento(
      numero: int.tryParse(json['numero']?.toString() ?? '0') ?? 0,
      dataDoPedido: int.tryParse(json['dataDoPedido']?.toString() ?? '0') ?? 0,
      situacao: json['situacao']?.toString() ?? '',
      dataDaSituacao: int.tryParse(json['dataDaSituacao']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'dataDoPedido': dataDoPedido, 'situacao': situacao, 'dataDaSituacao': dataDaSituacao};
  }

  /// Formata a data do pedido (AAAAMMDD)
  String get dataDoPedidoFormatada {
    final dataStr = dataDoPedido.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata a data da situação (AAAAMMDD)
  String get dataDaSituacaoFormatada {
    final dataStr = dataDaSituacao.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Verifica se o parcelamento está ativo
  bool get isAtivo => situacao.toLowerCase().contains('em parcelamento');

  /// Verifica se o parcelamento está encerrado
  bool get isEncerrado => situacao.toLowerCase().contains('encerrado');

  /// Verifica se o parcelamento está cancelado
  bool get isCancelado => situacao.toLowerCase().contains('cancelado');

  /// Verifica se o parcelamento está suspenso
  bool get isSuspenso => situacao.toLowerCase().contains('suspenso');

  /// Verifica se o parcelamento está em análise
  bool get isEmAnalise => situacao.toLowerCase().contains('análise') || situacao.toLowerCase().contains('analise');

  /// Verifica se o parcelamento foi aprovado
  bool get isAprovado => situacao.toLowerCase().contains('aprovado');

  /// Verifica se o parcelamento foi rejeitado
  bool get isRejeitado => situacao.toLowerCase().contains('rejeitado');

  @override
  String toString() {
    return 'Parcelamento $numero: $situacao (${dataDoPedidoFormatada})';
  }
}
