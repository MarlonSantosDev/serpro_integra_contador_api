/// Classes compartilhadas para responses do DEFIS

class DefisResponse {
  DefisResponse();

  factory DefisResponse.fromJson(Map<String, dynamic> json) {
    return DefisResponse();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

/// Mensagem padrão do DEFIS
class MensagemDefis {
  final String codigo;
  final String texto;

  MensagemDefis({required this.codigo, required this.texto});

  factory MensagemDefis.fromJson(Map<String, dynamic> json) {
    return MensagemDefis(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}

/// Modelo para última declaração (usado em consultas específicas)
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
