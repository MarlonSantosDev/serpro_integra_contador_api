/// Classe base para mensagens de negócio utilizada em todos os módulos da API SERPRO
///
/// Esta classe unifica todas as implementações de MensagemNegocio que estavam
/// espalhadas pelos diferentes módulos, mantendo compatibilidade com todas
/// as funcionalidades específicas através de métodos de extensão.
class MensagemNegocio {
  final String codigo;
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  /// Factory constructor para criar a partir de JSON
  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo']?.toString() ?? '', texto: json['texto']?.toString() ?? '');
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
    return 'MensagemNegocio(codigo: $codigo, texto: $texto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MensagemNegocio && other.codigo == codigo && other.texto == texto;
  }

  @override
  int get hashCode => codigo.hashCode ^ texto.hashCode;
}

/// Extensões específicas para diferentes módulos
///
/// Cada módulo pode ter suas próprias extensões para funcionalidades específicas
/// sem precisar duplicar a classe base.

/// Extensões para módulo de Procurações
extension MensagemNegocioProcuracoes on MensagemNegocio {
  bool get isSucessoProcuracoes => codigo.contains('[Sucesso-PROCURACOES]');
  bool get isAvisoProcuracoes => codigo.contains('[Aviso-PROCURACOES]');
  bool get isAcessoNegadoProcuracoes => codigo.contains('[AcessoNegado-PROCURACOES]');
  bool get isEntradaIncorretaProcuracoes => codigo.contains('[EntrataIncorreta-PROCURACOES]');
  bool get isErroProcuracoes => codigo.contains('[Erro-PROCURACOES]');

  String get tipoProcuracoes {
    if (isSucessoProcuracoes) return 'Sucesso';
    if (isAvisoProcuracoes) return 'Aviso';
    if (isAcessoNegadoProcuracoes) return 'Acesso Negado';
    if (isEntradaIncorretaProcuracoes) return 'Entrada Incorreta';
    if (isErroProcuracoes) return 'Erro';
    return 'Desconhecido';
  }
}

/// Extensões para módulo DTE
extension MensagemNegocioDte on MensagemNegocio {
  bool get isSucessoDte => codigo.startsWith('Sucesso-DTE');
  bool get isErroDte => codigo.startsWith('Erro-DTE');

  String get tipoDte {
    if (isSucessoDte) return 'Sucesso';
    if (isErroDte) return 'Erro';
    return 'Informação';
  }
}
