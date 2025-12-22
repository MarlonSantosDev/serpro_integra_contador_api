/// Modelo base para respostas RELPMEI seguindo padrão dos outros serviços
abstract class RelpmeiBaseResponse {
  /// Status da resposta HTTP
  final int status;

  /// Lista de mensagens de retorno
  final List<MensagemRelpmei> mensagens;

  /// Dados retornados como string JSON
  final String dados;

  RelpmeiBaseResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  /// Converte status contêm sucesso
  bool get sucesso => status == 200 && dados.isNotEmpty;

  /// Verifica se há dados válidos
  bool get hasData => dados.isNotEmpty;

  factory RelpmeiBaseResponse.fromJson(Map<String, dynamic> json) {
    return GenericRelpmeiResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((m) => MensagemRelpmei.fromJson(m))
          .toList(),
      dados: json['dados'].toString(),
    );
  }
}

/// Implementação genérica para respostas RELPMEI
class GenericRelpmeiResponse extends RelpmeiBaseResponse {
  GenericRelpmeiResponse({
    required super.status,
    required super.mensagens,
    required super.dados,
  });
}

/// Mensagem de resposta RELPMEI
class MensagemRelpmei {
  /// Código da mensagem
  final String codigo;

  /// Texto da mensagem
  final String texto;

  MensagemRelpmei({required this.codigo, required this.texto});

  factory MensagemRelpmei.fromJson(Map<String, dynamic> json) {
    return MensagemRelpmei(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'codigo': codigo, 'texto': texto};
}
