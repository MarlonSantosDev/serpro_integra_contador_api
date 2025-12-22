/// Classe base para mensagens utilizada nos módulos de parcelamento
///
/// Esta classe unifica todas as implementações de Mensagem que estavam
/// espalhadas pelos diferentes módulos de parcelamento (PARCSN, PERTSN, PARCMEI, etc.),
/// mantendo compatibilidade com todas as funcionalidades específicas.
class Mensagem {
  final String codigo;
  final String texto;

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
  bool get isSucessoParcsn =>
      codigo.contains('Sucesso') || codigo.contains('SUCESSO');
  bool get isErroParcsn => codigo.contains('Erro') || codigo.contains('ERRO');
  bool get isAvisoParcsn =>
      codigo.contains('Aviso') || codigo.contains('AVISO');
}

/// Extensões para módulo PARCSN-ESPECIAL
extension MensagemParcsnEspecial on Mensagem {
  bool get isSucessoParcsnEspecial => codigo.contains('[Sucesso-PARCSN-ESP]');
  bool get isAvisoParcsnEspecial => codigo.contains('[Aviso-PARCSN-ESP]');
  bool get isErroParcsnEspecial => codigo.contains('[Erro-PARCSN-ESP]');
  bool get isEntradaIncorretaParcsnEspecial =>
      codigo.contains('[EntradaIncorreta-PARCSN-ESP]');
}

/// Extensões para módulo PERTSN
extension MensagemPertsn on Mensagem {
  bool get isSucessoPertsn => codigo.contains('[Sucesso-PERTSN]');
  bool get isAvisoPertsn => codigo.contains('[Aviso-PERTSN]');
  bool get isErroPertsn => codigo.contains('[Erro-PERTSN]');
  bool get isEntradaIncorretaPertsn =>
      codigo.contains('[EntradaIncorreta-PERTSN]');

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
  bool get isSucessoParcmei =>
      codigo.contains('Sucesso') || codigo.contains('SUCESSO');
  bool get isErroParcmei => codigo.contains('ERRO') || codigo.contains('Erro');
  bool get isAvisoParcmei =>
      codigo.contains('AVISO') || codigo.contains('Aviso');
  bool get isParcmei => codigo.contains('PARCMEI');
}

/// Extensões para módulo PARCMEI-ESPECIAL
extension MensagemParcmeiEspecial on Mensagem {
  bool get isSucessoParcmeiEspecial => codigo.contains('[Sucesso-PARCMEI-ESP]');
  bool get isAvisoParcmeiEspecial => codigo.contains('[Aviso-PARCMEI-ESP]');
  bool get isErroParcmeiEspecial => codigo.contains('[Erro-PARCMEI-ESP]');
  bool get isEntradaIncorretaParcmeiEspecial =>
      codigo.contains('[EntradaIncorreta-PARCMEI-ESP]');
}
