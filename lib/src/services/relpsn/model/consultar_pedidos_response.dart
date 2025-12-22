import 'dart:convert';
import 'mensagem.dart';

class ConsultarPedidosResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ParcelamentosData? dados;

  ConsultarPedidosResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

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
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List)
          .map((e) => Mensagem.fromJson(e))
          .toList(),
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
}

class ParcelamentosData {
  final List<Parcelamento> parcelamentos;

  ParcelamentosData({required this.parcelamentos});

  factory ParcelamentosData.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return ParcelamentosData(
      parcelamentos: (json['parcelamentos'] as List)
          .map((e) => Parcelamento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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

  Parcelamento({
    required this.numero,
    required this.dataDoPedido,
    required this.situacao,
    required this.dataDaSituacao,
  });

  factory Parcelamento.fromJson(Map<String, dynamic> json) {
    return Parcelamento(
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao'].toString(),
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
    };
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
}
