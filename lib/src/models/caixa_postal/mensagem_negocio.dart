/// Mensagem de negócio retornada pela API do Caixa Postal
class MensagemNegocio {
  final String codigo;
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo'] as String? ?? '', texto: json['texto'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
