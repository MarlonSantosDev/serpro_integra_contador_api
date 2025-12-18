library;

/// Classes comuns para respostas DCTFWeb

/// Mensagem específica do DCTFWeb
class MensagemDctf {
  final String codigo;
  final String texto;

  MensagemDctf({required this.codigo, required this.texto});

  factory MensagemDctf.fromJson(Map<String, dynamic> json) {
    return MensagemDctf(codigo: json['codigo']?.toString() ?? '', texto: json['texto']?.toString() ?? '');
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSucesso => codigo == '00' || texto.toLowerCase().contains('sucesso');

  /// Verifica se é uma mensagem de erro
  bool get isErro => codigo != '00' && !isSucesso;

  /// Obtém o tipo da mensagem baseado no código
  String get tipo {
    if (codigo.startsWith('Sucesso')) return 'Sucesso';
    if (codigo.startsWith('Erro')) return 'Erro';
    if (codigo.startsWith('EntradaIncorreta')) return 'Entrada Incorreta';
    if (codigo.startsWith('Aviso')) return 'Aviso';
    if (codigo.startsWith('AcessoNegado')) return 'Acesso Negado';
    return 'Informação';
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  @override
  String toString() => '$codigo: $texto';
}
