import 'dart:convert';

/// Modelo de resposta para consultar última declaração PGDASD
///
/// Representa a resposta do serviço CONSULTIMADECREC14
class ConsultarUltimaDeclaracaoResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo o objeto DeclaracaoCompleta parseado
  final DeclaracaoCompleta? dados;

  ConsultarUltimaDeclaracaoResponse({required this.status, required this.mensagens, this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
  }

  factory ConsultarUltimaDeclaracaoResponse.fromJson(Map<String, dynamic> json) {
    DeclaracaoCompleta? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final dadosMap = jsonDecode(dadosStr) as Map<String, dynamic>;
        dadosParsed = DeclaracaoCompleta.fromJson(dadosMap);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarUltimaDeclaracaoResponse(
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

/// Declaração completa
class DeclaracaoCompleta {
  /// Identificador único da declaração transmitida
  final String numeroDeclaracao;

  /// Estrutura de dados do Recibo de entrega da declaração. A saída é um PDF
  final ArquivoRecibo recibo;

  /// Estrutura de dados completa da declaração entregue. A saída é um PDF
  final ArquivoDeclaracao declaracao;

  /// Nos casos de declaração original entregue fora do prazo, o PGDAS-D gera uma MAED
  /// Essa estrutura representa os documentos de Notificação e DARF da MAED
  final ArquivoMaed? maed;

  DeclaracaoCompleta({required this.numeroDeclaracao, required this.recibo, required this.declaracao, this.maed});

  /// Indica se há MAED (Multa por Atraso na Entrega da Declaração)
  bool get temMaed => maed != null;

  Map<String, dynamic> toJson() {
    return {
      'numeroDeclaracao': numeroDeclaracao,
      'recibo': recibo.toJson(),
      'declaracao': declaracao.toJson(),
      if (maed != null) 'maed': maed!.toJson(),
    };
  }

  factory DeclaracaoCompleta.fromJson(Map<String, dynamic> json) {
    return DeclaracaoCompleta(
      numeroDeclaracao: json['numeroDeclaracao'].toString(),
      recibo: ArquivoRecibo.fromJson(json['recibo']),
      declaracao: ArquivoDeclaracao.fromJson(json['declaracao']),
      maed: json['maed'] != null ? ArquivoMaed.fromJson(json['maed']) : null,
    );
  }
}

/// Arquivo do recibo
class ArquivoRecibo {
  /// Nome do arquivo do recibo para ser utilizado no processo de decodificação do base64
  /// Ex. "recibo-pgdasd-{numeroDeclaracao}.pdf"
  final String nomeArquivo;

  /// Obtém o arquivo em base 64 para conversão em PDF
  final String pdf;

  ArquivoRecibo({required this.nomeArquivo, required this.pdf});

  Map<String, dynamic> toJson() {
    return {'nomeArquivo': nomeArquivo, 'pdf': pdf};
  }

  factory ArquivoRecibo.fromJson(Map<String, dynamic> json) {
    return ArquivoRecibo(nomeArquivo: json['nomeArquivo'].toString(), pdf: json['pdf'].toString());
  }
}

/// Arquivo da declaração
class ArquivoDeclaracao {
  /// Nome do arquivo da declaracao para ser utilizado no processo de decodificação do base64
  /// Ex. "dec-pgdasd-{numeroDeclaracao}.pdf"
  final String nomeArquivo;

  /// Obtém o arquivo em base 64 para conversão em PDF
  final String pdf;

  ArquivoDeclaracao({required this.nomeArquivo, required this.pdf});

  Map<String, dynamic> toJson() {
    return {'nomeArquivo': nomeArquivo, 'pdf': pdf};
  }

  factory ArquivoDeclaracao.fromJson(Map<String, dynamic> json) {
    return ArquivoDeclaracao(nomeArquivo: json['nomeArquivo'].toString(), pdf: json['pdf'].toString());
  }
}

/// Arquivo MAED
class ArquivoMaed {
  /// Nome do arquivo da notificação da multa da declaracao entregue em atraso
  /// para ser utilizado no processo de decodificação do base64
  /// Ex. "notificacao-maed-pgdasd-{numeroDeclaracao}.pdf"
  final String nomeArquivoNotificacao;

  /// Obtém o arquivo em base 64 para conversão em PDF da notificação da MAED
  final String pdfNotificacao;

  /// Nome do arquivo do DARF da multa da declaracao entregue em atraso
  /// para ser utilizado no processo de decodificação do base64
  /// Ex. "darf-maed-pgdasd-{numeroDeclaracao}.pdf"
  final String nomeArquivoDarf;

  /// Obtém o arquivo em base 64 para conversão em PDF da DARF da MAED
  final String pdfDarf;

  ArquivoMaed({required this.nomeArquivoNotificacao, required this.pdfNotificacao, required this.nomeArquivoDarf, required this.pdfDarf});

  Map<String, dynamic> toJson() {
    return {
      'nomeArquivoNotificacao': nomeArquivoNotificacao,
      'pdfNotificacao': pdfNotificacao,
      'nomeArquivoDarf': nomeArquivoDarf,
      'pdfDarf': pdfDarf,
    };
  }

  factory ArquivoMaed.fromJson(Map<String, dynamic> json) {
    return ArquivoMaed(
      nomeArquivoNotificacao: json['nomeArquivoNotificacao'].toString(),
      pdfNotificacao: json['pdfNotificacao'].toString(),
      nomeArquivoDarf: json['nomeArquivoDarf'].toString(),
      pdfDarf: json['pdfDarf'].toString(),
    );
  }
}
