class MensagemCcmei {
  final String codigo;
  final String texto;

  MensagemCcmei({required this.codigo, required this.texto});

  factory MensagemCcmei.fromJson(Map<String, dynamic> json) {
    return MensagemCcmei(codigo: json['codigo'] as String, texto: json['texto'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
