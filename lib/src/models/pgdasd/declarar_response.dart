class DeclararResponse {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;

  DeclararResponse({required this.type, required this.title, required this.status, required this.detail, required this.instance});

  factory DeclararResponse.fromJson(Map<String, dynamic> json) {
    return DeclararResponse(type: json['type'] as String, title: json['title'] as String, status: json['status'] as int, detail: json['detail'] as String, instance: json['instance'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'title': title, 'status': status, 'detail': detail, 'instance': instance};
  }
}
