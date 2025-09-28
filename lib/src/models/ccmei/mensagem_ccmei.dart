class MensagemCcmei {
  final String codigo;
  final String texto;

  MensagemCcmei({required this.codigo, required this.texto});

  factory MensagemCcmei.fromJson(Map<String, dynamic> json) {
    return MensagemCcmei(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
