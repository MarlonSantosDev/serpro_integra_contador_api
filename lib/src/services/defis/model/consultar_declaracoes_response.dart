import 'dart:convert';
import 'defis_response.dart';

/// Response para consultar declarações transmitidas na DEFIS
class ConsultarDeclaracoesResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final List<Declaracao> dados;

  ConsultarDeclaracoesResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarDeclaracoesResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDeclaracoesResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((e) => MensagemDefis.fromJson(e))
          .toList(),
      dados: (jsonDecode(json['dados']) as List)
          .map((e) => Declaracao.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para declaração na lista de declarações
class Declaracao {
  final int anoCalendario;
  final String idDefis;
  final String tipo;
  final int dataHora;

  Declaracao({
    required this.anoCalendario,
    required this.idDefis,
    required this.tipo,
    required this.dataHora,
  });

  factory Declaracao.fromJson(Map<String, dynamic> json) {
    return Declaracao(
      anoCalendario: int.parse(json['anoCalendario'].toString()),
      idDefis: json['idDefis'].toString(),
      tipo: json['tipo'].toString(),
      dataHora: int.parse(json['dataHora'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anoCalendario': anoCalendario,
      'idDefis': idDefis,
      'tipo': tipo,
      'dataHora': dataHora,
    };
  }
}
