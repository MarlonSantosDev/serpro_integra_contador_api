class DteResponse {
  final String type;
  final String title;
  final int status;
  final String detail;
  final String instance;

  DteResponse({required this.type, required this.title, required this.status, required this.detail, required this.instance});

  factory DteResponse.fromJson(Map<String, dynamic> json) {
    return DteResponse(type: json['type'] as String, title: json['title'] as String, status: json['status'] as int, detail: json['detail'] as String, instance: json['instance'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'title': title, 'status': status, 'detail': detail, 'instance': instance};
  }
}
