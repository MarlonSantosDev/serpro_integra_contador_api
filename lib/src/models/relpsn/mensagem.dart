/// Classe comum para mensagens de resposta do RELPSN
class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(codigo: json['codigo'] as String, texto: json['texto'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
