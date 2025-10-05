/// Classe base para respostas do sistema PARCMEI-ESP
class ParcmeiEspecialResponse {
  final String status;
  final List<dynamic> mensagens;
  final String dados;

  ParcmeiEspecialResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ParcmeiEspecialResponse.fromJson(Map<String, dynamic> json) {
    return ParcmeiEspecialResponse(
      status: json['status']?.toString() ?? '',
      mensagens: json['mensagens'] as List<dynamic>? ?? [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados};
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get sucesso => status == '200';

  /// Verifica se há dados disponíveis
  bool get temDados => dados.isNotEmpty;

  /// Verifica se há mensagens
  bool get temMensagens => mensagens.isNotEmpty;
}
