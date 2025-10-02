import 'dart:convert';

/// Modelo de resposta para consultar extrato do DAS PGDASD
///
/// Representa a resposta do serviço CONSEXTRATO16
class ConsultarExtratoDasResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo uma lista em SCAPED Texto JSON com o objeto ExtratoDas
  final String dados;

  ConsultarExtratoDasResponse({required this.status, required this.mensagens, required this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  /// Parse dos dados JSON retornados
  ExtratoDas? get dadosParsed {
    try {
      // Primeiro converte a string JSON para Map
      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      return ExtratoDas.fromJson(dadosMap);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((m) => m.toJson()).toList(), 'dados': dados};
  }

  factory ConsultarExtratoDasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarExtratoDasResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m)).toList(),
      dados: json['dados'].toString(),
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
    return Mensagem(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }
}

/// Extrato do DAS
class ExtratoDas {
  /// Número do DAS
  final String numeroDas;

  /// CNPJ completo sem formatação
  final String cnpjCompleto;

  /// Período de apuração no formato AAAAMM
  final String periodoApuracao;

  /// Data de vencimento no formato AAAAMMDD
  final String dataVencimento;

  /// Data limite para acolhimento no formato AAAAMMDD
  final String dataLimiteAcolhimento;

  /// Valor total do DAS
  final double valorTotal;

  /// Status do pagamento
  final String statusPagamento;

  /// Data do pagamento (se pago)
  final String? dataPagamento;

  /// Composição do DAS
  final List<ComposicaoExtratoDas> composicao;

  ExtratoDas({
    required this.numeroDas,
    required this.cnpjCompleto,
    required this.periodoApuracao,
    required this.dataVencimento,
    required this.dataLimiteAcolhimento,
    required this.valorTotal,
    required this.statusPagamento,
    this.dataPagamento,
    required this.composicao,
  });

  /// Indica se o DAS foi pago
  bool get foiPago => statusPagamento == 'Pago';

  /// Indica se o DAS está vencido
  bool get estaVencido {
    if (foiPago) return false;

    final hoje = DateTime.now();
    final dataVencimentoDate = DateTime(
      int.parse(dataVencimento.substring(0, 4)),
      int.parse(dataVencimento.substring(4, 6)),
      int.parse(dataVencimento.substring(6, 8)),
    );

    return hoje.isAfter(dataVencimentoDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'cnpjCompleto': cnpjCompleto,
      'periodoApuracao': periodoApuracao,
      'dataVencimento': dataVencimento,
      'dataLimiteAcolhimento': dataLimiteAcolhimento,
      'valorTotal': valorTotal,
      'statusPagamento': statusPagamento,
      if (dataPagamento != null) 'dataPagamento': dataPagamento,
      'composicao': composicao.map((c) => c.toJson()).toList(),
    };
  }

  factory ExtratoDas.fromJson(Map<String, dynamic> json) {
    return ExtratoDas(
      numeroDas: json['numeroDas'].toString(),
      cnpjCompleto: json['cnpjCompleto'].toString(),
      periodoApuracao: json['periodoApuracao'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valorTotal: (num.parse(json['valorTotal'].toString())).toDouble(),
      statusPagamento: json['statusPagamento'].toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      composicao: (json['composicao'] as List).map((c) => ComposicaoExtratoDas.fromJson(c)).toList(),
    );
  }
}

/// Composição do extrato do DAS
class ComposicaoExtratoDas {
  /// Código do tributo
  final String codigoTributo;

  /// Nome do tributo
  final String nomeTributo;

  /// Valor do tributo
  final double valorTributo;

  /// Percentual aplicado
  final double percentual;

  ComposicaoExtratoDas({required this.codigoTributo, required this.nomeTributo, required this.valorTributo, required this.percentual});

  Map<String, dynamic> toJson() {
    return {'codigoTributo': codigoTributo, 'nomeTributo': nomeTributo, 'valorTributo': valorTributo, 'percentual': percentual};
  }

  factory ComposicaoExtratoDas.fromJson(Map<String, dynamic> json) {
    return ComposicaoExtratoDas(
      codigoTributo: json['codigoTributo'].toString(),
      nomeTributo: json['nomeTributo'].toString(),
      valorTributo: (num.parse(json['valorTributo'].toString())).toDouble(),
      percentual: (num.parse(json['percentual'].toString())).toDouble(),
    );
  }
}
