import 'dart:convert';
import 'mensagem.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ListaParcelasData? dados;

  ConsultarParcelasResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json) {
    ListaParcelasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = ListaParcelasData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarParcelasResponse(
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

  /// Verifica se há parcelas disponíveis
  bool get temParcelas {
    return dados?.listaParcelas.isNotEmpty ?? false;
  }

  /// Quantidade de parcelas disponíveis
  int get quantidadeParcelas {
    return dados?.listaParcelas.length ?? 0;
  }

  /// Retorna os dados parseados como lista de parcelas
  List<Parcela> get parcelas {
    return dados?.listaParcelas ?? [];
  }
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ListaParcelasData(
        listaParcelas: (json['listaParcelas'] as List?)?.map((e) => Parcela.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      );
    } catch (e) {
      return ListaParcelasData(listaParcelas: []);
    }
  }

  Map<String, dynamic> toJson() {
    return {'listaParcelas': listaParcelas.map((e) => e.toJson()).toList()};
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
