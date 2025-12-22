import 'dart:convert';

/// Modelo de resposta para gerar DAS Cobrança PGDASD
///
/// Representa a resposta do serviço GERARDASCOBRANCA17
class GerarDasCobrancaResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo o objeto DasCobranca parseado
  final DasCobranca? dados;

  GerarDasCobrancaResponse({
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

  factory GerarDasCobrancaResponse.fromJson(Map<String, dynamic> json) {
    DasCobranca? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final dadosList = jsonDecode(dadosStr);
        dadosParsed = DasCobranca.fromJson(dadosList as Map<String, dynamic>);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return GerarDasCobrancaResponse(
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

/// DAS Cobrança gerado
class DasCobranca {
  /// PDF do DAS no formato Texto Base 64
  final String pdf;

  /// Número do CNPJ sem formatação
  final String cnpjCompleto;

  /// Detalhamento do DAS
  final DetalhamentoDasCobranca detalhamento;

  DasCobranca({
    required this.pdf,
    required this.cnpjCompleto,
    required this.detalhamento,
  });

  Map<String, dynamic> toJson() {
    return {
      'pdf': pdf,
      'cnpjCompleto': cnpjCompleto,
      'detalhamento': detalhamento.toJson(),
    };
  }

  factory DasCobranca.fromJson(Map<String, dynamic> json) {
    return DasCobranca(
      pdf: json['pdf'].toString(),
      cnpjCompleto: json['cnpjCompleto'].toString(),
      detalhamento: DetalhamentoDasCobranca.fromJson(json['detalhamentoDas']),
    );
  }
}

/// Detalhamento do DAS Cobrança
class DetalhamentoDasCobranca {
  /// Período de Apuração no formato AAAAMM
  final String periodoApuracao;

  /// Número do documento gerado
  final String numeroDocumento;

  /// Data de vencimento no formato AAAAMMDD
  final String dataVencimento;

  /// Data limite para acolhimento no formato AAAAMMDD
  final String dataLimiteAcolhimento;

  /// Discriminação dos valores
  final ValoresDasCobranca valores;

  /// Observação 1
  final String? observacao1;

  /// Observação 2
  final String? observacao2;

  /// Observação 3
  final String? observacao3;

  /// Composição do DAS gerado
  final List<ComposicaoDasCobranca>? composicao;

  DetalhamentoDasCobranca({
    required this.periodoApuracao,
    required this.numeroDocumento,
    required this.dataVencimento,
    required this.dataLimiteAcolhimento,
    required this.valores,
    this.observacao1,
    this.observacao2,
    this.observacao3,
    this.composicao,
  });

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'numeroDocumento': numeroDocumento,
      'dataVencimento': dataVencimento,
      'dataLimiteAcolhimento': dataLimiteAcolhimento,
      'valores': valores.toJson(),
      if (observacao1 != null) 'observacao1': observacao1,
      if (observacao2 != null) 'observacao2': observacao2,
      if (observacao3 != null) 'observacao3': observacao3,
      if (composicao != null)
        'composicao': composicao!.map((c) => c.toJson()).toList(),
    };
  }

  factory DetalhamentoDasCobranca.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDasCobranca(
      periodoApuracao: json['periodoApuracao'].toString(),
      numeroDocumento: json['numeroDocumento'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valores: ValoresDasCobranca.fromJson(json['valores']),
      observacao1: json['observacao1']?.toString(),
      observacao2: json['observacao2']?.toString(),
      observacao3: json['observacao3']?.toString(),
      composicao: json['composicao'] != null
          ? (json['composicao'] as List)
                .map((c) => ComposicaoDasCobranca.fromJson(c))
                .toList()
          : null,
    );
  }
}

/// Valores do DAS Cobrança
class ValoresDasCobranca {
  /// Valor do principal
  final double principal;

  /// Valor da multa
  final double multa;

  /// Valor dos juros
  final double juros;

  /// Valor total
  final double total;

  ValoresDasCobranca({
    required this.principal,
    required this.multa,
    required this.juros,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'multa': multa,
      'juros': juros,
      'total': total,
    };
  }

  factory ValoresDasCobranca.fromJson(Map<String, dynamic> json) {
    return ValoresDasCobranca(
      principal: (num.parse(json['principal'].toString())).toDouble(),
      multa: (num.parse(json['multa'].toString())).toDouble(),
      juros: (num.parse(json['juros'].toString())).toDouble(),
      total: (num.parse(json['total'].toString())).toDouble(),
    );
  }
}

/// Composição do DAS Cobrança
class ComposicaoDasCobranca {
  /// Período de apuração do tributo no formato AAAAMM
  final String periodoApuracao;

  /// Código do tributo
  final String codigo;

  /// Descrição do nome/destino do tributo
  final String denominacao;

  /// Discriminação dos valores do tributo
  final ValoresDasCobranca valores;

  ComposicaoDasCobranca({
    required this.periodoApuracao,
    required this.codigo,
    required this.denominacao,
    required this.valores,
  });

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'codigo': codigo,
      'denominacao': denominacao,
      'valores': valores.toJson(),
    };
  }

  factory ComposicaoDasCobranca.fromJson(Map<String, dynamic> json) {
    return ComposicaoDasCobranca(
      periodoApuracao: json['periodoApuracao'].toString(),
      codigo: json['codigo'].toString(),
      denominacao: json['denominacao'].toString(),
      valores: ValoresDasCobranca.fromJson(json['valores']),
    );
  }
}
