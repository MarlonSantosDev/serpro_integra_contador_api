import 'dart:convert';
import 'defis_response.dart';

/// Response para consultar declarações transmitidas na DEFIS
class ConsultarDeclaracoesResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final List<Declaracao> dados;

  ConsultarDeclaracoesResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarDeclaracoesResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDeclaracoesResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((e) => MensagemDefis.fromJson(e)).toList(),
      dados: (jsonDecode(json['dados']) as List).map((e) => Declaracao.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.map((e) => e.toJson()).toList()};
  }
}

/// Modelo para declaração na lista de declarações
class Declaracao {
  final int idDefis;
  final int ano;
  final String dataTransmissao;
  final String situacao;
  final String? declaracaoPdf;
  final String? reciboPdf;

  Declaracao({required this.idDefis, required this.ano, required this.dataTransmissao, required this.situacao, this.declaracaoPdf, this.reciboPdf});

  factory Declaracao.fromJson(Map<String, dynamic> json) {
    return Declaracao(
      idDefis: int.parse(json['idDefis'].toString()),
      ano: int.parse(json['anoCalendario'].toString()),
      dataTransmissao: json['dataHora'].toString(),
      situacao: json['situacao'].toString(),
      declaracaoPdf: json['declaracaoPdf']?.toString(),
      reciboPdf: json['reciboPdf']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDefis': idDefis,
      'ano': ano,
      'dataTransmissao': dataTransmissao,
      'situacao': situacao,
      'declaracaoPdf': declaracaoPdf,
      'reciboPdf': reciboPdf,
    };
  }
}
