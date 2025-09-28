/// Request para consultar a última declaração transmitida na DEFIS
class ConsultarUltimaDeclaracaoRequest {
  final int ano;

  ConsultarUltimaDeclaracaoRequest({required this.ano});

  factory ConsultarUltimaDeclaracaoRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarUltimaDeclaracaoRequest(
      ano: int.parse(json['ano'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ano': ano};
  }
}
