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
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

  /// Verifica se há parcelamentos disponíveis
  bool get temParcelamentos {
    return dados?.parcelamentos.isNotEmpty ?? false;
  }

  /// Quantidade de parcelamentos encontrados
  int get quantidadeParcelamentos {
    return dados?.parcelamentos.length ?? 0;
  }

  /// Retorna os dados parseados como lista de parcelamentos
  List<Parcelamento> get parcelamentos {
    return dados?.parcelamentos ?? [];
  }
}

class ParcelamentosData {
  final List<Parcelamento> parcelamentos;

  ParcelamentosData({required this.parcelamentos});

  factory ParcelamentosData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return ParcelamentosData(
        parcelamentos:
            (json['parcelamentos'] as List?)
                ?.map((e) => Parcelamento.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
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
