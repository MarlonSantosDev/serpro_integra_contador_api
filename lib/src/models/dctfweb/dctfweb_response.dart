class DctfWebResponse {
  final String status;
  final String mensagem;
  final Map<String, dynamic> detalhes;

  DctfWebResponse({
    required this.status,
    required this.mensagem,
    required this.detalhes,
  });

  factory DctfWebResponse.fromJson(Map<String, dynamic> json) {
    return DctfWebResponse(
      status: json['status'] as String,
      mensagem: json['mensagem'] as String,
      detalhes: json['detalhes'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagem': mensagem, 'detalhes': detalhes};
  }
}
