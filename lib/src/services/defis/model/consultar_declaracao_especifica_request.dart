/// Request para consultar uma declaração específica transmitida na DEFIS
class ConsultarDeclaracaoEspecificaRequest {
  final String idDefis;

  ConsultarDeclaracaoEspecificaRequest({required this.idDefis});

  factory ConsultarDeclaracaoEspecificaRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarDeclaracaoEspecificaRequest(
      idDefis: json['idDefis'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'idDefis': idDefis};
  }
}
