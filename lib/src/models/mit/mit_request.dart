import 'dart:convert';
import 'mit_enums.dart';

/// Request base para serviços MIT
abstract class MitRequest {
  Map<String, dynamic> toDados();
  String toDadosJson() => jsonEncode(toDados());
}

/// Request para encerrar apuração MIT (ENCAPURACAO314)
class EncerrarApuracaoRequest extends MitRequest {
  final PeriodoApuracao periodoApuracao;
  final DadosIniciais dadosIniciais;
  final Debitos? debitos;
  final List<EventoEspecial>? listaEventosEspeciais;
  final bool? transmissaoImediata;

  EncerrarApuracaoRequest({
    required this.periodoApuracao,
    required this.dadosIniciais,
    this.debitos,
    this.listaEventosEspeciais,
    this.transmissaoImediata,
  }) {
    _validarCampos();
  }

  void _validarCampos() {
    // Validar se para apuração sem movimento não deve ter débitos
    if (dadosIniciais.semMovimento && debitos != null) {
      throw ArgumentError(
        'Para apuração sem movimento não é permitido informar débitos',
      );
    }

    // Validar se para apuração com movimento deve ter débitos
    if (!dadosIniciais.semMovimento && debitos == null) {
      throw ArgumentError(
        'Para apuração com movimento é obrigatório informar débitos',
      );
    }

    // Validar transmissaoImediata apenas para apuração sem movimento
    if (transmissaoImediata != null && !dadosIniciais.semMovimento) {
      throw ArgumentError(
        'Campo transmissaoImediata só deve ser enviado para apuração sem movimento',
      );
    }

    // Validar eventos especiais (máximo 5)
    if (listaEventosEspeciais != null && listaEventosEspeciais!.length > 5) {
      throw ArgumentError(
        'São permitidos o total de 5 eventos especiais por apuração',
      );
    }
  }

  @override
  Map<String, dynamic> toDados() {
    final dados = <String, dynamic>{
      'PeriodoApuracao': periodoApuracao.toJson(),
      'DadosIniciais': dadosIniciais.toJson(),
    };

    if (debitos != null) {
      dados['Debitos'] = debitos!.toJson();
    }

    if (listaEventosEspeciais != null && listaEventosEspeciais!.isNotEmpty) {
      dados['ListaEventosEspeciais'] = listaEventosEspeciais!
          .map((e) => e.toJson())
          .toList();
    }

    if (transmissaoImediata != null) {
      dados['TransmissaoImediata'] = transmissaoImediata;
    }

    return dados;
  }
}

/// Request para consultar situação de encerramento (SITUACAOENC315)
class ConsultarSituacaoEncerramentoRequest extends MitRequest {
  final String protocoloEncerramento;

  ConsultarSituacaoEncerramentoRequest({required this.protocoloEncerramento}) {
    if (protocoloEncerramento.isEmpty) {
      throw ArgumentError('Protocolo de encerramento é obrigatório');
    }
  }

  @override
  Map<String, dynamic> toDados() {
    return {'protocoloEncerramento': protocoloEncerramento};
  }
}

/// Request para consultar apuração (CONSAPURACAO316)
class ConsultarApuracaoRequest extends MitRequest {
  final int idApuracao;

  ConsultarApuracaoRequest({required this.idApuracao}) {
    if (idApuracao < 0) {
      throw ArgumentError('ID da apuração deve ser um número positivo');
    }
  }

  @override
  Map<String, dynamic> toDados() {
    return {'idApuracao': idApuracao};
  }
}

/// Request para listar apurações (LISTAAPURACOES317)
class ListarApuracaoesRequest extends MitRequest {
  final int anoApuracao;
  final int? mesApuracao;
  final int? situacaoApuracao;

  ListarApuracaoesRequest({
    required this.anoApuracao,
    this.mesApuracao,
    this.situacaoApuracao,
  }) {
    _validarCampos();
  }

  void _validarCampos() {
    if (anoApuracao < 2000 || anoApuracao > 3000) {
      throw ArgumentError('Ano da apuração deve estar entre 2000 e 3000');
    }

    if (mesApuracao != null && (mesApuracao! < 1 || mesApuracao! > 12)) {
      throw ArgumentError('Mês da apuração deve estar entre 1 e 12');
    }

    if (situacaoApuracao != null &&
        (situacaoApuracao! < 1 || situacaoApuracao! > 4)) {
      throw ArgumentError('Situação da apuração deve estar entre 1 e 4');
    }
  }

  @override
  Map<String, dynamic> toDados() {
    final dados = <String, dynamic>{'anoApuracao': anoApuracao};

    if (mesApuracao != null) {
      dados['mesApuracao'] = mesApuracao;
    }

    if (situacaoApuracao != null) {
      dados['situacaoApuracao'] = situacaoApuracao;
    }

    return dados;
  }
}

/// Período da apuração
class PeriodoApuracao {
  final int mesApuracao;
  final int anoApuracao;

  PeriodoApuracao({required this.mesApuracao, required this.anoApuracao}) {
    if (mesApuracao < 1 || mesApuracao > 12) {
      throw ArgumentError('Mês da apuração deve estar entre 1 e 12');
    }
    if (anoApuracao < 2000 || anoApuracao > 3000) {
      throw ArgumentError('Ano da apuração deve estar entre 2000 e 3000');
    }
  }

  Map<String, dynamic> toJson() {
    return {'MesApuracao': mesApuracao, 'AnoApuracao': anoApuracao};
  }
}

/// Dados iniciais da apuração
class DadosIniciais {
  final bool semMovimento;
  final QualificacaoPj qualificacaoPj;
  final TributacaoLucro? tributacaoLucro;
  final VariacoesMonetarias? variacoesMonetarias;
  final RegimePisCofins? regimePisCofins;
  final ResponsavelApuracao responsavelApuracao;

  DadosIniciais({
    required this.semMovimento,
    required this.qualificacaoPj,
    this.tributacaoLucro,
    this.variacoesMonetarias,
    this.regimePisCofins,
    required this.responsavelApuracao,
  }) {
    _validarCampos();
  }

  void _validarCampos() {
    // Se não é sem movimento e qualificação não é estado/município, tributação do lucro é obrigatória
    if (!semMovimento &&
        qualificacaoPj != QualificacaoPj.estadoMunicipio &&
        tributacaoLucro == null) {
      throw ArgumentError(
        'Tributação do lucro é obrigatória quando não é sem movimento e qualificação não é estado/município',
      );
    }

    // Se não é sem movimento, variações monetárias é obrigatória
    if (!semMovimento && variacoesMonetarias == null) {
      throw ArgumentError(
        'Variações monetárias é obrigatória quando não é sem movimento',
      );
    }

    // Regime PIS/COFINS tem regras específicas baseadas na qualificação e tributação
    if (!semMovimento && regimePisCofins == null) {
      final precisaRegime = _precisaRegimePisCofins();
      if (precisaRegime) {
        throw ArgumentError(
          'Regime PIS/COFINS é obrigatório para esta configuração',
        );
      }
    }
  }

  bool _precisaRegimePisCofins() {
    // Regras específicas do MIT para quando regime PIS/COFINS é obrigatório
    if (qualificacaoPj == QualificacaoPj.autarquiaFundacaoPublica) return true;
    if (qualificacaoPj == QualificacaoPj.pjEmGeral &&
        [
          TributacaoLucro.realAnual,
          TributacaoLucro.realTrimestral,
          TributacaoLucro.imuneIrpj,
          TributacaoLucro.isentaIrpj,
        ].contains(tributacaoLucro))
      return true;
    if ([
          QualificacaoPj.sociedadeCorretoraSeguros,
          QualificacaoPj.sociedadeCooperativaAgropecuaria,
          QualificacaoPj.empresaPublica,
        ].contains(qualificacaoPj) &&
        ![
          TributacaoLucro.presumido,
          TributacaoLucro.arbitrado,
          TributacaoLucro.imuneIrpj,
          TributacaoLucro.optanteSimplesNacional,
        ].contains(tributacaoLucro))
      return true;
    if (qualificacaoPj == QualificacaoPj.maisDeUmaQualificacao &&
        tributacaoLucro != TributacaoLucro.optanteSimplesNacional)
      return true;

    return false;
  }

  Map<String, dynamic> toJson() {
    final dados = <String, dynamic>{
      'SemMovimento': semMovimento,
      'QualificacaoPj': qualificacaoPj.codigo,
      'ResponsavelApuracao': responsavelApuracao.toJson(),
    };

    if (tributacaoLucro != null) {
      dados['TributacaoLucro'] = tributacaoLucro!.codigo;
    }

    if (variacoesMonetarias != null) {
      dados['VariacoesMonetarias'] = variacoesMonetarias!.codigo;
    }

    if (regimePisCofins != null) {
      dados['RegimePisCofins'] = regimePisCofins!.codigo;
    }

    return dados;
  }
}

/// Responsável pelo preenchimento da apuração
class ResponsavelApuracao {
  final String cpfResponsavel;
  final TelefoneResponsavel? telResponsavel;
  final String? emailResponsavel;
  final RegistroCrc? registroCrc;

  ResponsavelApuracao({
    required this.cpfResponsavel,
    this.telResponsavel,
    this.emailResponsavel,
    this.registroCrc,
  }) {
    if (cpfResponsavel.length != 11) {
      throw ArgumentError('CPF do responsável deve ter 11 dígitos');
    }
    if (emailResponsavel != null && emailResponsavel!.length > 60) {
      throw ArgumentError(
        'E-mail do responsável deve ter no máximo 60 caracteres',
      );
    }
  }

  Map<String, dynamic> toJson() {
    final dados = <String, dynamic>{'CpfResponsavel': cpfResponsavel};

    if (telResponsavel != null) {
      dados['TelResponsavel'] = telResponsavel!.toJson();
    }

    if (emailResponsavel != null) {
      dados['EmailResponsavel'] = emailResponsavel;
    }

    if (registroCrc != null) {
      dados['RegistroCrc'] = registroCrc!.toJson();
    }

    return dados;
  }
}

/// Telefone do responsável
class TelefoneResponsavel {
  final String ddd;
  final String numTelefone;

  TelefoneResponsavel({required this.ddd, required this.numTelefone}) {
    if (ddd.length != 2) {
      throw ArgumentError('DDD deve ter 2 dígitos');
    }
    if (numTelefone.length < 8 || numTelefone.length > 9) {
      throw ArgumentError('Número do telefone deve ter 8 ou 9 dígitos');
    }
  }

  Map<String, dynamic> toJson() {
    return {'Ddd': ddd, 'NumTelefone': numTelefone};
  }
}

/// Registro CRC do responsável
class RegistroCrc {
  final String ufRegistro;
  final String numRegistro;

  RegistroCrc({required this.ufRegistro, required this.numRegistro}) {
    if (ufRegistro.length != 2) {
      throw ArgumentError('UF do registro deve ter 2 caracteres');
    }
    if (numRegistro.length < 6 || numRegistro.length > 11) {
      throw ArgumentError(
        'Número do registro deve ter entre 6 e 11 caracteres',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {'UfRegistro': ufRegistro, 'NumRegistro': numRegistro};
  }
}

/// Débitos da apuração
class Debitos {
  final bool? balancoLucroReal;
  final ListaDebitosIrpj? irpj;
  final ListaDebitosCsll? csll;
  final ListaDebitosPisPasep? pisPasep;
  final ListaDebitosCofins? cofins;
  final ListaDebitosIrrf? irrf;
  final ListaDebitosIpi? ipi;
  final ListaDebitosIof? iof;
  final ListaDebitosCideCombustiveis? cideCombustiveis;
  final ListaDebitosCideRemessas? cideRemessas;
  final ListaDebitosCondecine? condecine;
  final ListaDebitosContribuicaoConcursoPrognosticos?
  contribuicaoConcursoPrognosticos;
  final ListaDebitosCpss? cpss;
  final ListaDebitosRetPagamentoUnificado? retPagamentoUnificado;
  final ListaDebitosContribuicoesDiversas? contribuicoesDiversas;

  Debitos({
    this.balancoLucroReal,
    this.irpj,
    this.csll,
    this.pisPasep,
    this.cofins,
    this.irrf,
    this.ipi,
    this.iof,
    this.cideCombustiveis,
    this.cideRemessas,
    this.condecine,
    this.contribuicaoConcursoPrognosticos,
    this.cpss,
    this.retPagamentoUnificado,
    this.contribuicoesDiversas,
  });

  Map<String, dynamic> toJson() {
    final dados = <String, dynamic>{};

    if (balancoLucroReal != null) {
      dados['BalancoLucroReal'] = balancoLucroReal;
    }

    if (irpj != null) {
      dados['Irpj'] = irpj!.toJson();
    }

    if (csll != null) {
      dados['Csll'] = csll!.toJson();
    }

    if (pisPasep != null) {
      dados['PisPasep'] = pisPasep!.toJson();
    }

    if (cofins != null) {
      dados['Cofins'] = cofins!.toJson();
    }

    if (irrf != null) {
      dados['Irrf'] = irrf!.toJson();
    }

    if (ipi != null) {
      dados['Ipi'] = ipi!.toJson();
    }

    if (iof != null) {
      dados['Iof'] = iof!.toJson();
    }

    if (cideCombustiveis != null) {
      dados['CideCombustiveis'] = cideCombustiveis!.toJson();
    }

    if (cideRemessas != null) {
      dados['CideRemessas'] = cideRemessas!.toJson();
    }

    if (condecine != null) {
      dados['Condecine'] = condecine!.toJson();
    }

    if (contribuicaoConcursoPrognosticos != null) {
      dados['ContribuicaoConcursoPrognosticos'] =
          contribuicaoConcursoPrognosticos!.toJson();
    }

    if (cpss != null) {
      dados['Cpss'] = cpss!.toJson();
    }

    if (retPagamentoUnificado != null) {
      dados['RetPagamentoUnificado'] = retPagamentoUnificado!.toJson();
    }

    if (contribuicoesDiversas != null) {
      dados['ContribuicoesDiversas'] = contribuicoesDiversas!.toJson();
    }

    return dados;
  }
}

/// Evento especial da apuração
class EventoEspecial {
  final int idEvento;
  final int diaEvento;
  final TipoEventoEspecial tipoEvento;

  EventoEspecial({
    required this.idEvento,
    required this.diaEvento,
    required this.tipoEvento,
  }) {
    if (idEvento < 1 || idEvento > 5) {
      throw ArgumentError('ID do evento deve estar entre 1 e 5');
    }
    if (diaEvento < 1 || diaEvento > 31) {
      throw ArgumentError('Dia do evento deve estar entre 1 e 31');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'IdEvento': idEvento,
      'DiaEvento': diaEvento,
      'TipoEvento': tipoEvento.codigo,
    };
  }
}

// Classes para listas de débitos específicas por tributo
abstract class ListaDebitosBase {
  List<Debito> get listaDebitos;
  Map<String, dynamic> toJson();
}

class ListaDebitosIrpj implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosIrpj({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCsll implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCsll({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosPisPasep implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosPisPasep({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCofins implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCofins({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosIrrf implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosIrrf({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosIpi implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosIpi({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosIof implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosIof({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCideCombustiveis implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCideCombustiveis({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCideRemessas implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCideRemessas({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCondecine implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCondecine({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosContribuicaoConcursoPrognosticos implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosContribuicaoConcursoPrognosticos({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosCpss implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosCpss({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosRetPagamentoUnificado implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosRetPagamentoUnificado({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

class ListaDebitosContribuicoesDiversas implements ListaDebitosBase {
  @override
  final List<Debito> listaDebitos;

  ListaDebitosContribuicoesDiversas({required this.listaDebitos});

  @override
  Map<String, dynamic> toJson() {
    return {'ListaDebitos': listaDebitos.map((d) => d.toJson()).toList()};
  }
}

/// Débito individual
class Debito {
  final int idDebito;
  final String codigoDebito;
  final String? cnpjScp;
  final double valorDebito;
  final String? estabelecimento;
  final String? municipioEstabelecimento;

  Debito({
    required this.idDebito,
    required this.codigoDebito,
    this.cnpjScp,
    required this.valorDebito,
    this.estabelecimento,
    this.municipioEstabelecimento,
  }) {
    if (idDebito <= 0) {
      throw ArgumentError('ID do débito deve ser um número positivo');
    }
    if (codigoDebito.isEmpty) {
      throw ArgumentError('Código do débito é obrigatório');
    }
    if (valorDebito <= 0) {
      throw ArgumentError('Valor do débito deve ser maior que zero');
    }
    if (cnpjScp != null && cnpjScp!.length != 14) {
      throw ArgumentError('CNPJ SCP deve ter 14 dígitos');
    }
  }

  Map<String, dynamic> toJson() {
    final dados = <String, dynamic>{
      'IdDebito': idDebito,
      'CodigoDebito': codigoDebito,
      'ValorDebito': valorDebito,
    };

    if (cnpjScp != null) {
      dados['CnpjScp'] = cnpjScp;
    }

    if (estabelecimento != null) {
      dados['Estabelecimento'] = estabelecimento;
    }

    if (municipioEstabelecimento != null) {
      dados['MunicipioEstabelecimento'] = municipioEstabelecimento;
    }

    return dados;
  }
}
