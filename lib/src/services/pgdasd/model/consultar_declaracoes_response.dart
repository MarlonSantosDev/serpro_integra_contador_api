import 'dart:convert';

/// Modelo de resposta para consultar declarações PGDASD
///
/// Representa a resposta do serviço CONSDECLARACAO13
class ConsultarDeclaracoesResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo o objeto DeclaracoesEntregues parseado
  final DeclaracoesEntregues? dados;

  ConsultarDeclaracoesResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
  }

  factory ConsultarDeclaracoesResponse.fromJson(Map<String, dynamic> json) {
    DeclaracoesEntregues? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final dadosMap = jsonDecode(dadosStr);
        dadosParsed = DeclaracoesEntregues.fromJson(dadosMap);
      }
    } catch (e) {
      print('❌ Erro ao fazer parse dos dados: $e');
    }

    return ConsultarDeclaracoesResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((m) => Mensagem.fromJson(m as Map<String, dynamic>))
          .toList(),
      dados: dadosParsed,
    );
  }
}

/// Mensagem de retorno
class Mensagem {
  /// Código da mensagem
  final String codigo;

  /// Texto da mensagem
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo'].toString(),
      texto: json['texto'].toString(),
    );
  }
}

/// Declarações entregues
class DeclaracoesEntregues {
  /// Ano-calendário
  final int anoCalendario;

  /// Contém uma lista de declarações em um determinado período de apuração (PA)
  /// Quando for utilizado o ano-calendário no parâmetro da realização da consulta
  final List<Periodo>? periodos;

  /// Contém apenas um período de apuração (PA)
  /// Quando for utilizado o periodo da apuração no parâmetro da realização da consulta
  final Periodo? periodo;

  DeclaracoesEntregues({
    required this.anoCalendario,
    this.periodos,
    this.periodo,
  });

  /// Retorna a lista de períodos (seja de periodos ou periodo único)
  List<Periodo> get listaPeriodos {
    if (periodos != null) return periodos!;
    if (periodo != null) return [periodo!];
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'anoCalendario': anoCalendario,
      if (periodos != null)
        'periodos': periodos!.map((p) => p.toJson()).toList(),
      if (periodo != null) 'periodo': periodo!.toJson(),
    };
  }

  factory DeclaracoesEntregues.fromJson(Map<String, dynamic> json) {
    final ano = json['anocalendario'] ?? json['anoCalendario'];

    return DeclaracoesEntregues(
      anoCalendario: int.parse(ano.toString()),
      periodos: json['periodos'] != null
          ? (json['periodos'] as List).map((p) => Periodo.fromJson(p)).toList()
          : null,
      periodo: json['periodo'] != null
          ? Periodo.fromJson(json['periodo'])
          : null,
    );
  }
}

/// Período de apuração
class Periodo {
  /// Período da apuração, formato AAAAMM
  final int periodoApuracao;

  /// Lista todas as operações realizadas no período de apuração
  final List<Operacao> operacoes;

  Periodo({required this.periodoApuracao, required this.operacoes});

  /// Retorna apenas as declarações originais
  List<Operacao> get declaracoesOriginais {
    return operacoes
        .where((op) => op.tipoOperacao == 'Declaração Original')
        .toList();
  }

  /// Retorna apenas as declarações retificadoras
  List<Operacao> get declaracoesRetificadoras {
    return operacoes
        .where((op) => op.tipoOperacao == 'Declaração Retificadora')
        .toList();
  }

  /// Retorna apenas as gerações de DAS
  List<Operacao> get geracoesDas {
    return operacoes
        .where((op) => op.tipoOperacao == 'Geração de DAS')
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'operacoes': operacoes.map((o) => o.toJson()).toList(),
    };
  }

  factory Periodo.fromJson(Map<String, dynamic> json) {
    return Periodo(
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      operacoes: (json['operacoes'] as List)
          .map((o) => Operacao.fromJson(o))
          .toList(),
    );
  }
}

/// Operação realizada
class Operacao {
  /// Tipo da operação realizada: (Declaração Original; Declaração Retificadora; Geração de DAS; DAS Avulso, DAS Medida Judicial ou DAS Cobrança)
  final String tipoOperacao;

  /// Estrutura de dados da declaração
  final IndiceDeclaracao? indiceDeclaracao;

  /// Estrutura de dados do DAS
  final IndiceDas? indiceDas;

  Operacao({required this.tipoOperacao, this.indiceDeclaracao, this.indiceDas});

  /// Indica se é uma operação de declaração
  bool get isDeclaracao => indiceDeclaracao != null;

  /// Indica se é uma operação de DAS
  bool get isDas => indiceDas != null;

  Map<String, dynamic> toJson() {
    return {
      'tipoOperacao': tipoOperacao,
      if (indiceDeclaracao != null)
        'indiceDeclaracao': indiceDeclaracao!.toJson(),
      if (indiceDas != null) 'indiceDas': indiceDas!.toJson(),
    };
  }

  factory Operacao.fromJson(Map<String, dynamic> json) {
    return Operacao(
      tipoOperacao: json['tipoOperacao'].toString(),
      indiceDeclaracao: json['indiceDeclaracao'] != null
          ? IndiceDeclaracao.fromJson(json['indiceDeclaracao'])
          : null,
      indiceDas: json['indiceDas'] != null
          ? IndiceDas.fromJson(json['indiceDas'])
          : null,
    );
  }
}

/// Índice da declaração
class IndiceDeclaracao {
  /// Identificador único da declaração transmitida
  final String numeroDeclaracao;

  /// Data e hora da entrega à RFB. Formato yyyyMMddHHmmss
  final String dataHoraTransmissao;

  /// Situação da malha quando aplicável: (Retida em Malha; Liberada, Intimada ou Rejeitada)
  /// A situação Liberada contempla 3 situações diferentes, liberada sem análise, liberada por alteração de parâmetros e aceita
  /// Quando não está em Malha o campo retorna null
  final String? malha;

  IndiceDeclaracao({
    required this.numeroDeclaracao,
    required this.dataHoraTransmissao,
    this.malha,
  });

  /// Indica se a declaração está em malha
  bool get estaEmMalha => malha != null;

  /// Indica se a declaração foi liberada
  bool get foiLiberada => malha == 'Liberada';

  /// Indica se a declaração foi rejeitada
  bool get foiRejeitada => malha == 'Rejeitada';

  Map<String, dynamic> toJson() {
    return {
      'numeroDeclaracao': numeroDeclaracao,
      'dataHoraTransmissao': dataHoraTransmissao,
      if (malha != null) 'malha': malha,
    };
  }

  factory IndiceDeclaracao.fromJson(Map<String, dynamic> json) {
    return IndiceDeclaracao(
      numeroDeclaracao: json['numeroDeclaracao'].toString(),
      dataHoraTransmissao: json['dataHoraTransmissao'].toString(),
      malha: json['malha']?.toString(),
    );
  }
}

/// Índice do DAS
class IndiceDas {
  /// Número do DAS (Documento de Arrecadação do Simples Nacional)
  final String numeroDas;

  /// Data e hora da emissão do DAS. Formato yyyyMMddHHmmss
  final String dataHoraEmissaoDas;

  /// Informa se houve ou não pagamento do DAS até o momento da consulta
  /// Pago (true) e não consta pagamento até o momento (false)
  final bool dasPago;

  IndiceDas({
    required this.numeroDas,
    required this.dataHoraEmissaoDas,
    required this.dasPago,
  });

  /// Indica se o DAS foi pago
  bool get foiPago => dasPago;

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'dataHoraEmissaoDas': dataHoraEmissaoDas,
      'dasPago': dasPago,
    };
  }

  factory IndiceDas.fromJson(Map<String, dynamic> json) {
    return IndiceDas(
      numeroDas: json['numeroDas'].toString(),
      dataHoraEmissaoDas: json['dataHoraEmissaoDas'].toString(),
      dasPago: json['dasPago'] as bool,
    );
  }
}
