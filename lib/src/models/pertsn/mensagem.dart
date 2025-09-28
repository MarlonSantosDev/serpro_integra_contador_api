class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo'].toString(),
      texto: json['texto'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se a mensagem é de sucesso
  bool get isSucesso => codigo.contains('[Sucesso-PERTSN]');

  /// Verifica se a mensagem é de aviso
  bool get isAviso => codigo.contains('[Aviso-PERTSN]');

  /// Verifica se a mensagem é de erro
  bool get isErro => codigo.contains('[Erro-PERTSN]');

  /// Verifica se a mensagem é de entrada incorreta
  bool get isEntradaIncorreta => codigo.contains('[EntradaIncorreta-PERTSN]');

  /// Obtém o tipo da mensagem
  String get tipo {
    if (isSucesso) return 'Sucesso';
    if (isAviso) return 'Aviso';
    if (isErro) return 'Erro';
    if (isEntradaIncorreta) return 'Entrada Incorreta';
    return 'Desconhecido';
  }
}
