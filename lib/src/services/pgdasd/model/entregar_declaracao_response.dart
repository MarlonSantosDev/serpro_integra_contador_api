import 'dart:convert';
import 'pgdasd_dominios.dart';

/// Modelo de resposta para entrega de declaração PGDASD
///
/// Representa a resposta do serviço TRANSDECLARACAO11
class EntregarDeclaracaoResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo uma lista com o objeto DeclaracaoTransmitida parseado
  final DeclaracaoTransmitida? dados;

  EntregarDeclaracaoResponse({required this.status, required this.mensagens, this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((m) => m.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
  }

  factory EntregarDeclaracaoResponse.fromJson(Map<String, dynamic> json) {
    DeclaracaoTransmitida? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final dadosMap = jsonDecode(dadosStr);

        // Se for uma lista, retorna a lista
        if (dadosMap is Map && dadosMap.containsKey('dados') && dadosMap['dados'] is List) {
          final lista = dadosMap['dados'];
          dadosParsed = DeclaracaoTransmitida.fromJson(lista as Map<String, dynamic>);
        } else if (dadosMap is Map) {
          // Se for um objeto único, retorna como lista com um item
          dadosParsed = DeclaracaoTransmitida.fromJson(dadosMap as Map<String, dynamic>);
        }
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return EntregarDeclaracaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m as Map<String, dynamic>)).toList(),
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
    return Mensagem(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }
}

/// Declaração transmitida
class DeclaracaoTransmitida {
  /// ID da Declaração que foi transmitida
  final String idDeclaracao;

  /// Data e hora da transmissão no formato AAAAMMDDHHmmSS
  final String dataHoraTransmissao;

  /// Valor devidos calculados pelo sistema
  final List<ValorDevido> valoresDevidos;

  /// PDF da declaração no formato Base64
  final String declaracao;

  /// PDF do recibo no formato Base64
  final String recibo;

  /// PDF da notificação MAED. No caso de não ter MAED este campo é nulo
  final String? notificacaoMaed;

  /// PDF do DARF. No caso de não ter MAED este campo é nulo
  final String? darf;

  /// Detalhamento dos valores do Darf
  final DetalhamentoDarfMaed? detalhamentoDarfMaed;

  DeclaracaoTransmitida({
    required this.idDeclaracao,
    required this.dataHoraTransmissao,
    required this.valoresDevidos,
    required this.declaracao,
    required this.recibo,
    this.notificacaoMaed,
    this.darf,
    this.detalhamentoDarfMaed,
  });

  /// Indica se há MAED (Multa por Atraso na Entrega da Declaração)
  bool get temMaed => notificacaoMaed != null && darf != null;

  /// Valor total devido
  double get valorTotalDevido => valoresDevidos.fold(0.0, (sum, valor) => sum + valor.valor);

  Map<String, dynamic> toJson() {
    return {
      'idDeclaracao': idDeclaracao,
      'dataHoraTransmissao': dataHoraTransmissao,
      'valoresDevidos': valoresDevidos.map((v) => v.toJson()).toList(),
      'declaracao': declaracao,
      'recibo': recibo,
      if (notificacaoMaed != null) 'notificacaoMaed': notificacaoMaed,
      if (darf != null) 'darf': darf,
      if (detalhamentoDarfMaed != null) 'detalhamentoDarfMaed': detalhamentoDarfMaed!.toJson(),
    };
  }

  factory DeclaracaoTransmitida.fromJson(Map<String, dynamic> json) {
    return DeclaracaoTransmitida(
      idDeclaracao: json['idDeclaracao'].toString(),
      dataHoraTransmissao: json['dataHoraTransmissao'].toString(),
      valoresDevidos: (json['valoresDevidos'] as List).map((v) => ValorDevido.fromJson(v)).toList(),
      declaracao: json['declaracao'].toString(),
      recibo: json['recibo'].toString(),
      notificacaoMaed: json['notificacaoMaed']?.toString(),
      darf: json['darf']?.toString(),
      detalhamentoDarfMaed: json['detalhamentoDarfMaed'] != null ? DetalhamentoDarfMaed.fromJson(json['detalhamentoDarfMaed']) : null,
    );
  }
}

/// Valor devido
class ValorDevido {
  /// Código do tributo
  final String codigoTributo;

  /// Valor devido do tributo
  final double valor;

  ValorDevido({required this.codigoTributo, required this.valor});

  Map<String, dynamic> toJson() {
    return {'codigoTributo': codigoTributo, 'valor': valor};
  }

  factory ValorDevido.fromJson(Map<String, dynamic> json) {
    final codigo = json['codigoTributo']?.toString();
    final descricao = PgdasdDominios.descricaoCodigoTributo(codigo);
    return ValorDevido(codigoTributo: descricao, valor: (num.parse(json['valor'].toString())).toDouble());
  }
}

/// Detalhamento do DARF/MAED
class DetalhamentoDarfMaed {
  /// Período de Apuração no formato AAAAMM
  final String periodoApuracao;

  /// Número do documento gerado
  final String numeroDocumento;

  /// Data de vencimento no formato AAAAMMDD
  final String dataVencimento;

  /// Data limite para acolhimento no formato AAAAMMDD
  final String dataLimiteAcolhimento;

  /// Discriminação dos valores contidos no DARF
  final ValoresDarf valores;

  /// Observação 1
  final String? observacao1;

  /// Observação 2
  final String? observacao2;

  /// Observação 3
  final String? observacao3;

  /// Por se tratar de DARF, este campo não possui informação
  final dynamic composicao;

  DetalhamentoDarfMaed({
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
      if (composicao != null) 'composicao': composicao,
    };
  }

  factory DetalhamentoDarfMaed.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDarfMaed(
      periodoApuracao: json['periodoApuracao'].toString(),
      numeroDocumento: json['numeroDocumento'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valores: ValoresDarf.fromJson(json['valores']),
      observacao1: json['observacao1']?.toString(),
      observacao2: json['observacao2']?.toString(),
      observacao3: json['observacao3']?.toString(),
      composicao: json['composicao'],
    );
  }
}

/// Valores do DARF
class ValoresDarf {
  /// Valor do principal
  final double principal;

  /// Valor da multa
  final double multa;

  /// Valor dos juros
  final double juros;

  /// Valor total
  final double total;

  ValoresDarf({required this.principal, required this.multa, required this.juros, required this.total});

  Map<String, dynamic> toJson() {
    return {'principal': principal, 'multa': multa, 'juros': juros, 'total': total};
  }

  factory ValoresDarf.fromJson(Map<String, dynamic> json) {
    return ValoresDarf(
      principal: (num.parse(json['principal'].toString())).toDouble(),
      multa: (num.parse(json['multa'].toString())).toDouble(),
      juros: (num.parse(json['juros'].toString())).toDouble(),
      total: (num.parse(json['total'].toString())).toDouble(),
    );
  }
}
