import 'dart:convert';
import 'mit_enums.dart';

/// Response base para serviços MIT
class MitResponse {
  final String status;
  final String? responseId;
  final String? responseDateTime;
  final List<MensagemMit> mensagens;

  MitResponse({
    required this.status,
    this.responseId,
    this.responseDateTime,
    required this.mensagens,
  });

  factory MitResponse.fromJson(Map<String, dynamic> json) {
    final mensagens = <MensagemMit>[];
    if (json['mensagens'] != null) {
      for (final msg in json['mensagens']) {
        mensagens.add(MensagemMit.fromJson(msg));
      }
    }

    return MitResponse._internal(
      status: json['status']?.toString() ?? '',
      responseId: json['responseId']?.toString(),
      responseDateTime: json['responseDateTime']?.toString(),
      mensagens: mensagens,
    );
  }

  MitResponse._internal({
    required this.status,
    this.responseId,
    this.responseDateTime,
    required this.mensagens,
  });

  bool get sucesso => status == '200';
  String? get mensagemErro =>
      mensagens.isNotEmpty ? mensagens.first.texto : null;
}

/// Response para encerrar apuração MIT
class EncerrarApuracaoResponse extends MitResponse {
  final String? protocoloEncerramento;
  final int? idApuracao;

  EncerrarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.protocoloEncerramento,
    this.idApuracao,
  });

  factory EncerrarApuracaoResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    String? protocoloEncerramento;
    int? idApuracao;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;
        protocoloEncerramento = dados['protocoloEncerramento'] as String?;
        idApuracao = dados['idApuracao'] as int?;
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return EncerrarApuracaoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      protocoloEncerramento: protocoloEncerramento,
      idApuracao: idApuracao,
    );
  }
}

/// Response para consultar situação de encerramento
class ConsultarSituacaoEncerramentoResponse extends MitResponse {
  final int? idApuracao;
  final int? situacaoApuracao;
  final String? textoSituacao;
  final List<String>? avisosDctf;
  final String? dataEncerramento;

  ConsultarSituacaoEncerramentoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.idApuracao,
    this.situacaoApuracao,
    this.textoSituacao,
    this.avisosDctf,
    this.dataEncerramento,
  });

  factory ConsultarSituacaoEncerramentoResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final baseResponse = MitResponse.fromJson(json);

    int? idApuracao;
    int? situacaoApuracao;
    String? textoSituacao;
    List<String>? avisosDctf;
    String? dataEncerramento;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;
        idApuracao = dados['idApuracao'] as int?;
        situacaoApuracao = dados['situacaoApuracao'] as int?;
        textoSituacao = dados['textoSituacao'] as String?;
        dataEncerramento = dados['dataEncerramento'] as String?;

        if (dados['avisosDctf'] != null) {
          avisosDctf = List<String>.from(dados['avisosDctf']);
        }
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ConsultarSituacaoEncerramentoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      idApuracao: idApuracao,
      situacaoApuracao: situacaoApuracao,
      textoSituacao: textoSituacao,
      avisosDctf: avisosDctf,
      dataEncerramento: dataEncerramento,
    );
  }

  SituacaoApuracao? get situacaoEnum => situacaoApuracao != null
      ? SituacaoApuracao.fromCodigo(situacaoApuracao!)
      : null;
}

/// Response para consultar apuração
class ConsultarApuracaoResponse extends MitResponse {
  final int? situacaoApuracao;
  final String? textoSituacao;
  final List<DadosApuracaoMit>? dadosApuracaoMit;

  ConsultarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.situacaoApuracao,
    this.textoSituacao,
    this.dadosApuracaoMit,
  });

  factory ConsultarApuracaoResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    int? situacaoApuracao;
    String? textoSituacao;
    List<DadosApuracaoMit>? dadosApuracaoMit;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;
        situacaoApuracao = dados['situacaoApuracao'] as int?;
        textoSituacao = dados['textoSituacao'] as String?;

        if (dados['dadosApuracaoMit'] != null) {
          dadosApuracaoMit = (dados['dadosApuracaoMit'] as List)
              .map((item) => DadosApuracaoMit.fromJson(item))
              .toList();
        }
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ConsultarApuracaoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      situacaoApuracao: situacaoApuracao,
      textoSituacao: textoSituacao,
      dadosApuracaoMit: dadosApuracaoMit,
    );
  }

  SituacaoApuracao? get situacaoEnum => situacaoApuracao != null
      ? SituacaoApuracao.fromCodigo(situacaoApuracao!)
      : null;
}

/// Response para listar apurações
class ListarApuracaoesResponse extends MitResponse {
  final List<ApuracaoResumo>? apuracoes;

  ListarApuracaoesResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.apuracoes,
  });

  factory ListarApuracaoesResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    List<ApuracaoResumo>? apuracoes;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;

        if (dados['Apuracoes'] != null) {
          apuracoes = (dados['Apuracoes'] as List)
              .map((item) => ApuracaoResumo.fromJson(item))
              .toList();
        }
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ListarApuracaoesResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      apuracoes: apuracoes,
    );
  }
}

/// Mensagem MIT
class MensagemMit {
  final String codigo;
  final String texto;

  MensagemMit({required this.codigo, required this.texto});

  factory MensagemMit.fromJson(Map<String, dynamic> json) {
    return MensagemMit(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}

/// Dados completos da apuração MIT
class DadosApuracaoMit {
  final PeriodoApuracaoResponse? periodoApuracao;
  final List<EventoEspecialResponse>? listaEventosEspeciais;
  final DadosIniciaisResponse? dadosIniciais;
  final DebitosResponse? debitos;

  DadosApuracaoMit({
    this.periodoApuracao,
    this.listaEventosEspeciais,
    this.dadosIniciais,
    this.debitos,
  });

  factory DadosApuracaoMit.fromJson(Map<String, dynamic> json) {
    return DadosApuracaoMit(
      periodoApuracao: json['PeriodoApuracao'] != null
          ? PeriodoApuracaoResponse.fromJson(json['PeriodoApuracao'])
          : null,
      listaEventosEspeciais: json['ListaEventosEspeciais'] != null
          ? (json['ListaEventosEspeciais'] as List)
                .map((item) => EventoEspecialResponse.fromJson(item))
                .toList()
          : null,
      dadosIniciais: json['DadosIniciais'] != null
          ? DadosIniciaisResponse.fromJson(json['DadosIniciais'])
          : null,
      debitos: json['Debitos'] != null
          ? DebitosResponse.fromJson(json['Debitos'])
          : null,
    );
  }
}

/// Resumo da apuração para listagem
class ApuracaoResumo {
  final String? periodoApuracao;
  final int? idApuracao;
  final int? situacao;
  final String? dataEncerramento;
  final bool? eventoEspecial;
  final double? valorTotalApurado;

  ApuracaoResumo({
    this.periodoApuracao,
    this.idApuracao,
    this.situacao,
    this.dataEncerramento,
    this.eventoEspecial,
    this.valorTotalApurado,
  });

  factory ApuracaoResumo.fromJson(Map<String, dynamic> json) {
    return ApuracaoResumo(
      periodoApuracao: json['periodoApuracao']?.toString(),
      idApuracao: int.parse(json['idApuracao'].toString()),
      situacao: int.parse(json['situacao'].toString()),
      dataEncerramento: json['dataEncerramento']?.toString(),
      eventoEspecial: json['eventoEspecial'] as bool?,
      valorTotalApurado: (num.parse(
        json['valorTotalApurado'].toString(),
      )).toDouble(),
    );
  }

  SituacaoApuracao? get situacaoEnum =>
      situacao != null ? SituacaoApuracao.fromCodigo(situacao!) : null;
}

/// Período da apuração (response)
class PeriodoApuracaoResponse {
  final int? mesApuracao;
  final int? anoApuracao;

  PeriodoApuracaoResponse({this.mesApuracao, this.anoApuracao});

  factory PeriodoApuracaoResponse.fromJson(Map<String, dynamic> json) {
    return PeriodoApuracaoResponse(
      mesApuracao: int.parse(json['MesApuracao'].toString()),
      anoApuracao: int.parse(json['AnoApuracao'].toString()),
    );
  }
}

/// Evento especial (response)
class EventoEspecialResponse {
  final int? idEvento;
  final int? diaEvento;
  final int? tipoEvento;

  EventoEspecialResponse({this.idEvento, this.diaEvento, this.tipoEvento});

  factory EventoEspecialResponse.fromJson(Map<String, dynamic> json) {
    return EventoEspecialResponse(
      idEvento: int.parse(json['IdEvento'].toString()),
      diaEvento: int.parse(json['DiaEvento'].toString()),
      tipoEvento: int.parse(json['TipoEvento'].toString()),
    );
  }

  TipoEventoEspecial? get tipoEventoEnum =>
      tipoEvento != null ? TipoEventoEspecial.fromCodigo(tipoEvento!) : null;
}

/// Dados iniciais (response)
class DadosIniciaisResponse {
  final bool? semMovimento;
  final int? qualificacaoPj;
  final int? tributacaoLucro;
  final int? variacoesMonetarias;
  final int? regimePisCofins;
  final ResponsavelApuracaoResponse? responsavelApuracao;

  DadosIniciaisResponse({
    this.semMovimento,
    this.qualificacaoPj,
    this.tributacaoLucro,
    this.variacoesMonetarias,
    this.regimePisCofins,
    this.responsavelApuracao,
  });

  factory DadosIniciaisResponse.fromJson(Map<String, dynamic> json) {
    return DadosIniciaisResponse(
      semMovimento: json['SemMovimento'] as bool?,
      qualificacaoPj: int.parse(json['QualificacaoPj'].toString()),
      tributacaoLucro: int.parse(json['TributacaoLucro'].toString()),
      variacoesMonetarias: int.parse(json['VariacoesMonetarias'].toString()),
      regimePisCofins: int.parse(json['RegimePisCofins'].toString()),
      responsavelApuracao: json['ResponsavelApuracao'] != null
          ? ResponsavelApuracaoResponse.fromJson(json['ResponsavelApuracao'])
          : null,
    );
  }

  QualificacaoPj? get qualificacaoPjEnum => qualificacaoPj != null
      ? QualificacaoPj.fromCodigo(qualificacaoPj!)
      : null;

  TributacaoLucro? get tributacaoLucroEnum => tributacaoLucro != null
      ? TributacaoLucro.fromCodigo(tributacaoLucro!)
      : null;

  VariacoesMonetarias? get variacoesMonetariasEnum =>
      variacoesMonetarias != null
      ? VariacoesMonetarias.fromCodigo(variacoesMonetarias!)
      : null;

  RegimePisCofins? get regimePisCofinsEnum => regimePisCofins != null
      ? RegimePisCofins.fromCodigo(regimePisCofins!)
      : null;
}

/// Responsável pela apuração (response)
class ResponsavelApuracaoResponse {
  final String? cpfResponsavel;
  final TelefoneResponsavelResponse? telResponsavel;
  final String? emailResponsavel;
  final RegistroCrcResponse? registroCrc;

  ResponsavelApuracaoResponse({
    this.cpfResponsavel,
    this.telResponsavel,
    this.emailResponsavel,
    this.registroCrc,
  });

  factory ResponsavelApuracaoResponse.fromJson(Map<String, dynamic> json) {
    return ResponsavelApuracaoResponse(
      cpfResponsavel: json['CpfResponsavel']?.toString(),
      telResponsavel: json['TelResponsavel'] != null
          ? TelefoneResponsavelResponse.fromJson(json['TelResponsavel'])
          : null,
      emailResponsavel: json['EmailResponsavel']?.toString(),
      registroCrc: json['RegistroCrc'] != null
          ? RegistroCrcResponse.fromJson(json['RegistroCrc'])
          : null,
    );
  }
}

/// Telefone do responsável (response)
class TelefoneResponsavelResponse {
  final String? ddd;
  final String? numTelefone;

  TelefoneResponsavelResponse({this.ddd, this.numTelefone});

  factory TelefoneResponsavelResponse.fromJson(Map<String, dynamic> json) {
    return TelefoneResponsavelResponse(
      ddd: json['Ddd']?.toString(),
      numTelefone: json['NumTelefone']?.toString(),
    );
  }
}

/// Registro CRC (response)
class RegistroCrcResponse {
  final String? ufRegistro;
  final String? numRegistro;

  RegistroCrcResponse({this.ufRegistro, this.numRegistro});

  factory RegistroCrcResponse.fromJson(Map<String, dynamic> json) {
    return RegistroCrcResponse(
      ufRegistro: json['UfRegistro']?.toString(),
      numRegistro: json['NumRegistro']?.toString(),
    );
  }
}

/// Débitos (response)
class DebitosResponse {
  final bool? balancoLucroReal;
  final Map<String, dynamic>? irpj;
  final Map<String, dynamic>? csll;
  final Map<String, dynamic>? pisPasep;
  final Map<String, dynamic>? cofins;
  final Map<String, dynamic>? irrf;
  final Map<String, dynamic>? ipi;
  final Map<String, dynamic>? iof;
  final Map<String, dynamic>? cideCombustiveis;
  final Map<String, dynamic>? cideRemessas;
  final Map<String, dynamic>? condecine;
  final Map<String, dynamic>? contribuicaoConcursoPrognosticos;
  final Map<String, dynamic>? cpss;
  final Map<String, dynamic>? retPagamentoUnificado;
  final Map<String, dynamic>? contribuicoesDiversas;

  DebitosResponse({
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

  factory DebitosResponse.fromJson(Map<String, dynamic> json) {
    return DebitosResponse(
      balancoLucroReal: json['BalancoLucroReal'] as bool?,
      irpj: json['Irpj'] as Map<String, dynamic>?,
      csll: json['Csll'] as Map<String, dynamic>?,
      pisPasep: json['PisPasep'] as Map<String, dynamic>?,
      cofins: json['Cofins'] as Map<String, dynamic>?,
      irrf: json['Irrf'] as Map<String, dynamic>?,
      ipi: json['Ipi'] as Map<String, dynamic>?,
      iof: json['Iof'] as Map<String, dynamic>?,
      cideCombustiveis: json['CideCombustiveis'] as Map<String, dynamic>?,
      cideRemessas: json['CideRemessas'] as Map<String, dynamic>?,
      condecine: json['Condecine'] as Map<String, dynamic>?,
      contribuicaoConcursoPrognosticos:
          json['ContribuicaoConcursoPrognosticos'] as Map<String, dynamic>?,
      cpss: json['Cpss'] as Map<String, dynamic>?,
      retPagamentoUnificado:
          json['RetPagamentoUnificado'] as Map<String, dynamic>?,
      contribuicoesDiversas:
          json['ContribuicoesDiversas'] as Map<String, dynamic>?,
    );
  }
}
