import 'defis_response.dart';

/// Response para consultar uma declaração específica transmitida na DEFIS
class ConsultarDeclaracaoEspecificaResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final UltimaDeclaracao dados;

  ConsultarDeclaracaoEspecificaResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarDeclaracaoEspecificaResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDeclaracaoEspecificaResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemDefis.fromJson(e as Map<String, dynamic>)).toList(),
      dados: UltimaDeclaracao.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}
