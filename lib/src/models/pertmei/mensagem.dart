class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
