import 'defis_response.dart';

/// Response para consultar a última declaração transmitida na DEFIS
class ConsultarUltimaDeclaracaoResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final UltimaDeclaracao dados;

  ConsultarUltimaDeclaracaoResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarUltimaDeclaracaoResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarUltimaDeclaracaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((e) => MensagemDefis.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: UltimaDeclaracao.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.toJson(),
    };
  }
}

/// Modelo para última declaração
class UltimaDeclaracao {
  final int idDefis;
  final int ano;
  final String dataTransmissao;
  final String situacao;
  final String? declaracaoPdf;
  final String? reciboPdf;

  UltimaDeclaracao({
    required this.idDefis,
    required this.ano,
    required this.dataTransmissao,
    required this.situacao,
    this.declaracaoPdf,
    this.reciboPdf,
  });

  factory UltimaDeclaracao.fromJson(Map<String, dynamic> json) {
    return UltimaDeclaracao(
      idDefis: int.parse(json['idDefis'].toString()),
      ano: int.parse(json['ano'].toString()),
      dataTransmissao: json['dataTransmissao'].toString(),
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
