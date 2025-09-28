/// Modelo para mensagens de negócio do sistema PROCURACOES
class MensagemNegocio {
  final String codigo;
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  /// Indica se é uma mensagem de sucesso
  bool get isSucesso => codigo.contains('[Sucesso-PROCURACOES]');

  /// Indica se é um aviso
  bool get isAviso => codigo.contains('[Aviso-PROCURACOES]');

  /// Indica se é um erro de acesso negado
  bool get isAcessoNegado => codigo.contains('[AcessoNegado-PROCURACOES]');

  /// Indica se é um erro de entrada incorreta
  bool get isEntradaIncorreta => codigo.contains('[EntrataIncorreta-PROCURACOES]');

  /// Indica se é um erro geral
  bool get isErro => codigo.contains('[Erro-PROCURACOES]');

  /// Retorna o tipo da mensagem
  String get tipo {
    if (isSucesso) return 'Sucesso';
    if (isAviso) return 'Aviso';
    if (isAcessoNegado) return 'Acesso Negado';
    if (isEntradaIncorreta) return 'Entrada Incorreta';
    if (isErro) return 'Erro';
    return 'Desconhecido';
  }

  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  @override
  String toString() {
    return 'MensagemNegocio(codigo: $codigo, texto: $texto)';
  }
}
