/// Modelo para mensagens de negócio dos eventos de atualização
class MensagemEventosAtualizacao {
  final String codigo;
  final String texto;

  MensagemEventosAtualizacao({required this.codigo, required this.texto});

  factory MensagemEventosAtualizacao.fromJson(Map<String, dynamic> json) {
    return MensagemEventosAtualizacao(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se a mensagem indica sucesso
  bool get isSucesso => codigo.contains('Sucesso');

  /// Verifica se a mensagem indica erro
  bool get isErro => codigo.contains('Erro') || codigo.contains('EntradaIncorreta');

  /// Verifica se a mensagem é um aviso
  bool get isAviso => codigo.contains('Aviso');
}
