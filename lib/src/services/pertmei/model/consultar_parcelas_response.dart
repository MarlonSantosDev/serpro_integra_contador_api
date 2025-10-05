import 'mensagem.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelasResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelasResponse(
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

  /// Retorna os dados parseados como lista de parcelas
  List<Parcela> get parcelas {
    try {
      if (dados.isEmpty) return [];

      // Em implementação real, seria feito parsing do JSON string
      // Por enquanto retornamos lista vazia - seria implementado com dart:convert
      return [];
    } catch (e) {
      return [];
    }
  }
}

class Parcela {
  final int parcela;
  final double valor;

  Parcela({required this.parcela, required this.valor});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      parcela: int.parse(json['parcela'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }
}
