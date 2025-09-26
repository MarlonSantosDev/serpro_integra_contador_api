/// Modelo de resposta básico para declaração PGDASD (mantido para compatibilidade)
///
/// Este modelo é mantido para compatibilidade com versões anteriores.
/// Para novos desenvolvimentos, use EntregarDeclaracaoResponse.
class DeclararResponse {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;

  DeclararResponse({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  factory DeclararResponse.fromJson(Map<String, dynamic> json) {
    return DeclararResponse(
      type: json['type'] as String,
      title: json['title'] as String,
      status: json['status'] as int,
      detail: json['detail'] as String,
      instance: json['instance'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'status': status,
      'detail': detail,
      'instance': instance,
    };
  }
}
