/// Classe base para mensagens utilizada nos módulos de parcelamento
///
/// Esta classe unifica todas as implementações de Mensagem que estavam
/// espalhadas pelos diferentes módulos de parcelamento (PARCSN, PERTSN, PARCMEI, etc.),
/// mantendo compatibilidade com todas as funcionalidades específicas.
class Mensagem {
  /// Código da mensagem (ex.: identificador ou prefixo do módulo).
  final String codigo;

  /// Texto da mensagem.
  final String texto;

  /// Construtor para [Mensagem].
  Mensagem({required this.codigo, required this.texto});

  /// Factory constructor para criar a partir de JSON
  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se é uma mensagem de sucesso (genérico)
  bool get isSucesso => codigo.toLowerCase().contains('sucesso');

  /// Verifica se é uma mensagem de erro (genérico)
  bool get isErro => codigo.toLowerCase().contains('erro');

  /// Verifica se é uma mensagem de aviso (genérico)
  bool get isAviso => codigo.toLowerCase().contains('aviso');

  /// Retorna o tipo da mensagem baseado no código
  String get tipo {
    if (isSucesso) return 'Sucesso';
    if (isErro) return 'Erro';
    if (isAviso) return 'Aviso';
    return 'Informação';
  }

  @override
  String toString() {
    return 'Mensagem(codigo: $codigo, texto: $texto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mensagem && other.codigo == codigo && other.texto == texto;
  }

  @override
  int get hashCode => codigo.hashCode ^ texto.hashCode;
}

/// Extensões específicas para diferentes módulos de parcelamento

/// Extensões para módulo PARCSN
extension MensagemParcsn on Mensagem {
  /// Indica se a mensagem é de sucesso no contexto PARCSN.
  bool get isSucessoParcsn =>
      codigo.contains('Sucesso') || codigo.contains('SUCESSO');

  /// Indica se a mensagem é de erro no contexto PARCSN.
  bool get isErroParcsn => codigo.contains('Erro') || codigo.contains('ERRO');

  /// Indica se a mensagem é de aviso no contexto PARCSN.
  bool get isAvisoParcsn =>
      codigo.contains('Aviso') || codigo.contains('AVISO');
}

/// Extensões para módulo PARCSN-ESPECIAL
extension MensagemParcsnEspecial on Mensagem {
  /// Indica se a mensagem é de sucesso no contexto PARCSN-ESPECIAL.
  bool get isSucessoParcsnEspecial => codigo.contains('[Sucesso-PARCSN-ESP]');

  /// Indica se a mensagem é de aviso no contexto PARCSN-ESPECIAL.
  bool get isAvisoParcsnEspecial => codigo.contains('[Aviso-PARCSN-ESP]');

  /// Indica se a mensagem é de erro no contexto PARCSN-ESPECIAL.
  bool get isErroParcsnEspecial => codigo.contains('[Erro-PARCSN-ESP]');

  /// Indica se a mensagem é de entrada incorreta no contexto PARCSN-ESPECIAL.
  bool get isEntradaIncorretaParcsnEspecial =>
      codigo.contains('[EntradaIncorreta-PARCSN-ESP]');
}

/// Extensões para módulo PERTSN
extension MensagemPertsn on Mensagem {
  /// Indica se a mensagem é de sucesso no contexto PERTSN.
  bool get isSucessoPertsn => codigo.contains('[Sucesso-PERTSN]');

  /// Indica se a mensagem é de aviso no contexto PERTSN.
  bool get isAvisoPertsn => codigo.contains('[Aviso-PERTSN]');

  /// Indica se a mensagem é de erro no contexto PERTSN.
  bool get isErroPertsn => codigo.contains('[Erro-PERTSN]');

  /// Indica se a mensagem é de entrada incorreta no contexto PERTSN.
  bool get isEntradaIncorretaPertsn =>
      codigo.contains('[EntradaIncorreta-PERTSN]');

  /// Retorna o tipo da mensagem no contexto PERTSN.
  String get tipoPertsn {
    if (isSucessoPertsn) return 'Sucesso';
    if (isAvisoPertsn) return 'Aviso';
    if (isErroPertsn) return 'Erro';
    if (isEntradaIncorretaPertsn) return 'Entrada Incorreta';
    return 'Desconhecido';
  }
}

/// Extensões para módulo PARCMEI
extension MensagemParcmei on Mensagem {
  /// Indica se a mensagem é de sucesso no contexto PARCMEI.
  bool get isSucessoParcmei =>
      codigo.contains('Sucesso') || codigo.contains('SUCESSO');

  /// Indica se a mensagem é de erro no contexto PARCMEI.
  bool get isErroParcmei => codigo.contains('ERRO') || codigo.contains('Erro');

  /// Indica se a mensagem é de aviso no contexto PARCMEI.
  bool get isAvisoParcmei =>
      codigo.contains('AVISO') || codigo.contains('Aviso');

  /// Indica se a mensagem é do módulo PARCMEI.
  bool get isParcmei => codigo.contains('PARCMEI');
}

/// Extensões para módulo PARCMEI-ESPECIAL
extension MensagemParcmeiEspecial on Mensagem {
  /// Indica se a mensagem é de sucesso no contexto PARCMEI-ESPECIAL.
  bool get isSucessoParcmeiEspecial => codigo.contains('[Sucesso-PARCMEI-ESP]');

  /// Indica se a mensagem é de aviso no contexto PARCMEI-ESPECIAL.
  bool get isAvisoParcmeiEspecial => codigo.contains('[Aviso-PARCMEI-ESP]');

  /// Indica se a mensagem é de erro no contexto PARCMEI-ESPECIAL.
  bool get isErroParcmeiEspecial => codigo.contains('[Erro-PARCMEI-ESP]');

  /// Indica se a mensagem é de entrada incorreta no contexto PARCMEI-ESPECIAL.
  bool get isEntradaIncorretaParcmeiEspecial =>
      codigo.contains('[EntradaIncorreta-PARCMEI-ESP]');
}
