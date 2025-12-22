/// Constantes e enums específicos para o módulo Procurações SERPRO
class ProcuracoesConstants {
  // Identificadores do sistema conforme documentação SERPRO
  static const String idSistema = 'PROCURACOES';
  static const String idServico = 'OBTERPROCURACAO41';
  static const String versaoSistema = '1';

  // Códigos de tipos de pessoa conforme documentação
  static const String tipoCpf = '1';
  static const String tipoCnpj = '2';

  // Códigos de mensagens específicos de Procurações
  static const String codigoSucesso = '[Sucesso-PROCURACOES]';
  static const String codigoAviso20001 = '[Aviso-PROCURACOES-20001]';
  static const String codigoAviso40400 = '[Aviso-PROCURACOES-40400]';
  static const String codigoAcessoNegado40300 =
      '[AcessoNegado-PROCURACOES-40300]';
  static const String codigoAcessoNegado40301 =
      '[AcessoNegado-PROCURACOES-40301]';
  static const String codigoEntrataIncorreta40002 =
      '[EntrataIncorreta-PROCURACOES-40002]';
  static const String codigoEntrataIncorreta40003 =
      '[EntrataIncorreta-PROCURACOES-40003]';
  static const String codigoEntrataIncorreta40004 =
      '[EntrataIncorreta-PROCURACOES-40004]';
  static const String codigoEntrataIncorreta40005 =
      '[EntrataIncorreta-PROCURACOES-40005]';
  static const String codigoEntrataIncorreta40006 =
      '[EntrataIncorreta-PROCURACOES-40006]';
  static const String codigoEntrataIncorreta40007 =
      '[EntrataIncorreta-PROCURACOES-40007]';
  static const String codigoErro500XX = '[Erro-PROCURACOES-500XX]';

  // Mensagens de texto conforme documentação
  static const String mensagemSucesso = 'Requisição efetuada com sucesso.';
  static const String mensagemAviso20001 =
      'Uma ou mais procurações foram retornadas com sucesso.';
  static const String mensagemAviso40400 = 'Não possui procuração ativa.';

  // Domínio de tipos aceitos
  static const List<String> tiposPessoaValidos = [tipoCpf, tipoCnpj];

  /// Valida se o tipo de pessoa é válido
  static bool isTipoPessoaValido(String tipo) {
    return tiposPessoaValidos.contains(tipo);
  }

  /// Obtém o nome do tipo de pessoa
  static String getNomeTipoPessoa(String tipo) {
    switch (tipo) {
      case tipoCpf:
        return 'CPF';
      case tipoCnpj:
        return 'CNPJ';
      default:
        return 'Desconhecido';
    }
  }
}

/// Enums para tipos de procuração
enum TipoProcuracao {
  /// Procuração geral
  geral('geral'),

  /// Procuração específica
  especifica('especifica'),

  /// Procuração de representação
  representacao('representacao');

  const TipoProcuracao(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Enum para status de procuração baseado na data de expiração
enum StatusProcuracao {
  /// Procuração ativa e válida
  ativa('ativa'),

  /// Procuração que expira em breve (próximos 30 dias)
  expiraEmBreve('expira_em_breve'),

  /// Procuração expirada
  expirada('expirada'),

  /// Status desconhecido ou inválido
  desconhecido('desconhecido');

  const StatusProcuracao(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Enum para tipos de documento (mapeamento DIRETO da API SERPRO)
enum TipoDocumentoSERPRO {
  /// CPF (Pessoa Física)
  cpf(ProcuracoesConstants.tipoCpf, 'CPF'),

  /// CNPJ (Pessoa Jurídica)
  cnpj(ProcuracoesConstants.tipoCnpj, 'CNPJ');

  const TipoDocumentoSERPRO(this.codigo, this.nome);

  final String codigo;
  final String nome;

  @override
  String toString() => nome;

  /// Cria a partir do código SERPRO
  static TipoDocumentoSERPRO? fromCodigo(String codigo) {
    switch (codigo) {
      case ProcuracoesConstants.tipoCpf:
        return TipoDocumentoSERPRO.cpf;
      case ProcuracoesConstants.tipoCnpj:
        return TipoDocumentoSERPRO.cnpj;
      default:
        return null;
    }
  }

  /// Cria automaticamente a partir do número do documento
  static TipoDocumentoSERPRO? fromNumeroDocumento(String numero) {
    final cleanNumber = numero.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length == 11) {
      return TipoDocumentoSERPRO.cpf;
    } else if (cleanNumber.length == 14) {
      return TipoDocumentoSERPRO.cnpj;
    }
    return null;
  }
}
