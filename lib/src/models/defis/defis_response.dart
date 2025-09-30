/// Classes compartilhadas para responses do DEFIS

/// Mensagem padrão do DEFIS
class MensagemDefis {
  final String codigo;
  final String texto;

  MensagemDefis({required this.codigo, required this.texto});

  factory MensagemDefis.fromJson(Map<String, dynamic> json) {
    return MensagemDefis(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
