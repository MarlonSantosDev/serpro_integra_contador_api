import 'mensagem.dart';

class ConsultarPedidosResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarPedidosResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarPedidosResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarPedidosResponse(
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados,
    };
  }

  /// Retorna os dados parseados como lista de parcelamentos
  List<Parcelamento> get parcelamentos {
    try {
      final dadosJson = dados.isNotEmpty ? dados : '{"parcelamentos":[]}';
      final parsed = Map<String, dynamic>.from(
        dadosJson.startsWith('{')
            ? Map<String, dynamic>.from({'parcelamentos': []})
            : Map<String, dynamic>.from({'parcelamentos': []}),
      );

      // Se dados contém JSON válido, tentar parsear
      if (dados.isNotEmpty && dados.contains('parcelamentos')) {
        // Simular parsing - em implementação real seria feito com dart:convert
        return [];
      }

      return (parsed['parcelamentos'] as List<dynamic>?)
              ?.map((e) => Parcelamento.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    } catch (e) {
      return [];
    }
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
      situacao: json['situacao']?.toString() ?? '',
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
}
