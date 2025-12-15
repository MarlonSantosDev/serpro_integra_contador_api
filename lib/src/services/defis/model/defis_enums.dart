/// Enums para os dados de domínio do DEFIS conforme documentação oficial

/// Tipos de evento para situação especial
enum TipoEventoSituacaoEspecial {
  cisaoParcial(1, 'Cisão parcial'),
  cisaoTotal(2, 'Cisão total'),
  extincao(3, 'Extinção'),
  fusao(4, 'Fusão'),
  incorporacaoIncorporada(5, 'Incorporação/Incorporada');

  const TipoEventoSituacaoEspecial(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TipoEventoSituacaoEspecial? fromCodigo(int codigo) {
    try {
      return TipoEventoSituacaoEspecial.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

/// Regra para inatividade
enum RegraInatividade {
  atividadesZeroNao(0, 'As atividades do PGDASD totalizam zero. Responde NÃO à pergunta sobre inatividade'),
  atividadesZeroSim(1, 'As atividades do PGDASD totalizam zero. Responde SIM à pergunta sobre inatividade'),
  atividadesMaiorZero(2, 'O total das atividades do PGDASD (incluindo valor fixo) é maior que zero');

  const RegraInatividade(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static RegraInatividade? fromCodigo(int codigo) {
    try {
      return RegraInatividade.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

/// Tipo de beneficiário da doação à campanha eleitoral
enum TipoBeneficiarioDoacao {
  candidatoCargoPolitico(1, 'Candidato a cargo político eletivo'),
  comiteFinanceiro(2, 'Comitê financeiro'),
  partidoPolitico(3, 'Partido político');

  const TipoBeneficiarioDoacao(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TipoBeneficiarioDoacao? fromCodigo(int codigo) {
    try {
      return TipoBeneficiarioDoacao.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

/// Forma de doação
enum FormaDoacao {
  cheque(1, 'Cheque'),
  outrosTitulosCredito(2, 'Outro títulos de crédito'),
  transferenciaEletronica(3, 'Transferência eletrônica'),
  depositoEspecie(4, 'Depósito em espécie'),
  dinheiro(5, 'Dinheiro'),
  bens(6, 'Bens'),
  servicos(7, 'Serviços');

  const FormaDoacao(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static FormaDoacao? fromCodigo(int codigo) {
    try {
      return FormaDoacao.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

/// Tipo de operação
enum TipoOperacao {
  entrada(1, 'Entrada'),
  saida(2, 'Saída');

  const TipoOperacao(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TipoOperacao? fromCodigo(int codigo) {
    try {
      return TipoOperacao.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

/// Administração tributária
enum AdministracaoTributaria {
  distrital(1, 'Distrital'),
  estadual(2, 'Estadual'),
  federal(3, 'Federal'),
  municipal(4, 'Municipal');

  const AdministracaoTributaria(this.codigo, this.descricao);

  /// Código numérico da administração tributária
  final int codigo;

  /// Descrição textual da administração tributária
  final String descricao;

  /// Retorna a instância de [AdministracaoTributaria] correspondente ao código fornecido.
  ///
  /// Retorna `null` se nenhum valor corresponder ao código.
  static AdministracaoTributaria? fromCodigo(int codigo) {
    try {
      return AdministracaoTributaria.values.firstWhere((e) => e.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}
