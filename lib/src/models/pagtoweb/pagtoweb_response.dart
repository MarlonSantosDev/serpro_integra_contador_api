import 'dart:convert';

/// Classe base para responses do PAGTOWEB
abstract class PagtoWebResponse {
  final int status;
  final List<MensagemNegocio> mensagens;

  PagtoWebResponse({required this.status, required this.mensagens});

  // Abstract class - cannot be instantiated directly
  // Use concrete subclasses instead

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((msg) => msg.toJson()).toList()};
  }

  /// Verifica se a resposta foi bem-sucedida
  bool get sucesso => status >= 200 && status < 300;
}

/// Response para consulta de pagamentos
class ConsultarPagamentosResponse extends PagtoWebResponse {
  final List<DocumentoArrecadacao> dados;

  ConsultarPagamentosResponse({required int status, required List<MensagemNegocio> mensagens, required this.dados})
    : super(status: status, mensagens: mensagens);

  factory ConsultarPagamentosResponse.fromJson(Map<String, dynamic> json) {
    final dados = <DocumentoArrecadacao>[];

    if (json['dados'] != null) {
      final dadosString = json['dados'] as String;
      if (dadosString.isNotEmpty) {
        try {
          final dadosList = jsonDecode(dadosString) as List<dynamic>;
          dados.addAll(dadosList.map((item) => DocumentoArrecadacao.fromJson(item as Map<String, dynamic>)));
        } catch (e) {
          // Se não conseguir fazer parse, deixa a lista vazia
        }
      }
    }

    return ConsultarPagamentosResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>).map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>)).toList(),
      dados: dados,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'dados': dados.map((doc) => doc.toJson()).toList()};
  }
}

/// Response para contagem de pagamentos
class ContarPagamentosResponse extends PagtoWebResponse {
  final int quantidade;

  ContarPagamentosResponse({required int status, required List<MensagemNegocio> mensagens, required this.quantidade})
    : super(status: status, mensagens: mensagens);

  factory ContarPagamentosResponse.fromJson(Map<String, dynamic> json) {
    int quantidade = 0;

    if (json['dados'] != null) {
      final dadosString = json['dados'] as String;
      if (dadosString.isNotEmpty) {
        try {
          quantidade = int.parse(dadosString);
        } catch (e) {
          quantidade = 0;
        }
      }
    }

    return ContarPagamentosResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>).map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>)).toList(),
      quantidade: quantidade,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'dados': quantidade.toString()};
  }
}

/// Response para emissão de comprovante
class EmitirComprovanteResponse extends PagtoWebResponse {
  final String? pdfBase64;

  EmitirComprovanteResponse({required int status, required List<MensagemNegocio> mensagens, this.pdfBase64})
    : super(status: status, mensagens: mensagens);

  factory EmitirComprovanteResponse.fromJson(Map<String, dynamic> json) {
    String? pdfBase64;

    if (json['dados'] != null) {
      final dadosString = json['dados'] as String;
      if (dadosString.isNotEmpty) {
        try {
          final dadosMap = jsonDecode(dadosString) as Map<String, dynamic>;
          pdfBase64 = dadosMap['pdf'] as String?;
        } catch (e) {
          // Se não conseguir fazer parse, deixa null
        }
      }
    }

    return EmitirComprovanteResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>).map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>)).toList(),
      pdfBase64: pdfBase64,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'dados': pdfBase64 != null ? '{"pdf":"$pdfBase64"}' : '{}'};
  }
}

/// Documento de arrecadação
class DocumentoArrecadacao {
  final String numeroDocumento;
  final TipoDocumento tipo;
  final String periodoApuracao;
  final String dataArrecadacao;
  final String dataVencimento;
  final ReceitaPrincipal receitaPrincipal;
  final String? referencia;
  final double valorTotal;
  final double valorPrincipal;
  final double? valorMulta;
  final double? valorJuros;
  final double? valorSaldoTotal;
  final double? valorSaldoPrincipal;
  final double? valorSaldoMulta;
  final double? valorSaldoJuros;
  final List<Desmembramento> desmembramentos;

  DocumentoArrecadacao({
    required this.numeroDocumento,
    required this.tipo,
    required this.periodoApuracao,
    required this.dataArrecadacao,
    required this.dataVencimento,
    required this.receitaPrincipal,
    this.referencia,
    required this.valorTotal,
    required this.valorPrincipal,
    this.valorMulta,
    this.valorJuros,
    this.valorSaldoTotal,
    this.valorSaldoPrincipal,
    this.valorSaldoMulta,
    this.valorSaldoJuros,
    required this.desmembramentos,
  });

  factory DocumentoArrecadacao.fromJson(Map<String, dynamic> json) {
    return DocumentoArrecadacao(
      numeroDocumento: json['numeroDocumento'] as String,
      tipo: TipoDocumento.fromJson(json['tipo'] as Map<String, dynamic>),
      periodoApuracao: json['periodoApuracao'] as String,
      dataArrecadacao: json['dataArrecadacao'] as String,
      dataVencimento: json['dataVencimento'] as String,
      receitaPrincipal: ReceitaPrincipal.fromJson(json['receitaPrincipal'] as Map<String, dynamic>),
      referencia: json['referencia'] as String?,
      valorTotal: (json['valorTotal'] as num).toDouble(),
      valorPrincipal: (json['valorPrincipal'] as num).toDouble(),
      valorMulta: json['valorMulta'] != null ? (json['valorMulta'] as num).toDouble() : null,
      valorJuros: json['valorJuros'] != null ? (json['valorJuros'] as num).toDouble() : null,
      valorSaldoTotal: json['valorSaldoTotal'] != null ? (json['valorSaldoTotal'] as num).toDouble() : null,
      valorSaldoPrincipal: json['valorSaldoPrincipal'] != null ? (json['valorSaldoPrincipal'] as num).toDouble() : null,
      valorSaldoMulta: json['valorSaldoMulta'] != null ? (json['valorSaldoMulta'] as num).toDouble() : null,
      valorSaldoJuros: json['valorSaldoJuros'] != null ? (json['valorSaldoJuros'] as num).toDouble() : null,
      desmembramentos: (json['desmembramentos'] as List<dynamic>).map((item) => Desmembramento.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDocumento': numeroDocumento,
      'tipo': tipo.toJson(),
      'periodoApuracao': periodoApuracao,
      'dataArrecadacao': dataArrecadacao,
      'dataVencimento': dataVencimento,
      'receitaPrincipal': receitaPrincipal.toJson(),
      'referencia': referencia,
      'valorTotal': valorTotal,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorSaldoTotal': valorSaldoTotal,
      'valorSaldoPrincipal': valorSaldoPrincipal,
      'valorSaldoMulta': valorSaldoMulta,
      'valorSaldoJuros': valorSaldoJuros,
      'desmembramentos': desmembramentos.map((item) => item.toJson()).toList(),
    };
  }
}

/// Tipo de documento
class TipoDocumento {
  final String codigo;
  final String descricao;
  final String descricaoAbreviada;

  TipoDocumento({required this.codigo, required this.descricao, required this.descricaoAbreviada});

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      codigo: json['codigo'] as String,
      descricao: json['descricao'] as String,
      descricaoAbreviada: json['descricaoAbreviada'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'descricao': descricao, 'descricaoAbreviada': descricaoAbreviada};
  }
}

/// Receita principal
class ReceitaPrincipal {
  final String codigo;
  final String descricao;
  final String? extensaoReceita;

  ReceitaPrincipal({required this.codigo, required this.descricao, this.extensaoReceita});

  factory ReceitaPrincipal.fromJson(Map<String, dynamic> json) {
    return ReceitaPrincipal(
      codigo: json['codigo'] as String,
      descricao: json['descricao'] as String,
      extensaoReceita: json['extensaoReceita'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'descricao': descricao, 'extensaoReceita': extensaoReceita};
  }
}

/// Desmembramento
class Desmembramento {
  final String sequencial;
  final ReceitaPrincipal receitaPrincipal;
  final String periodoApuracao;
  final String dataVencimento;
  final double? valorTotal;
  final double? valorPrincipal;
  final double? valorMulta;
  final double? valorJuros;
  final double? valorSaldoTotal;
  final double? valorSaldoPrincipal;
  final double? valorSaldoMulta;
  final double? valorSaldoJuros;

  Desmembramento({
    required this.sequencial,
    required this.receitaPrincipal,
    required this.periodoApuracao,
    required this.dataVencimento,
    this.valorTotal,
    this.valorPrincipal,
    this.valorMulta,
    this.valorJuros,
    this.valorSaldoTotal,
    this.valorSaldoPrincipal,
    this.valorSaldoMulta,
    this.valorSaldoJuros,
  });

  factory Desmembramento.fromJson(Map<String, dynamic> json) {
    return Desmembramento(
      sequencial: json['sequencial'] as String,
      receitaPrincipal: ReceitaPrincipal.fromJson(json['receitaPrincipal'] as Map<String, dynamic>),
      periodoApuracao: json['periodoApuracao'] as String,
      dataVencimento: json['dataVencimento'] as String,
      valorTotal: json['valorTotal'] != null ? (json['valorTotal'] as num).toDouble() : null,
      valorPrincipal: json['valorPrincipal'] != null ? (json['valorPrincipal'] as num).toDouble() : null,
      valorMulta: json['valorMulta'] != null ? (json['valorMulta'] as num).toDouble() : null,
      valorJuros: json['valorJuros'] != null ? (json['valorJuros'] as num).toDouble() : null,
      valorSaldoTotal: json['valorSaldoTotal'] != null ? (json['valorSaldoTotal'] as num).toDouble() : null,
      valorSaldoPrincipal: json['valorSaldoPrincipal'] != null ? (json['valorSaldoPrincipal'] as num).toDouble() : null,
      valorSaldoMulta: json['valorSaldoMulta'] != null ? (json['valorSaldoMulta'] as num).toDouble() : null,
      valorSaldoJuros: json['valorSaldoJuros'] != null ? (json['valorSaldoJuros'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sequencial': sequencial,
      'receitaPrincipal': receitaPrincipal.toJson(),
      'periodoApuracao': periodoApuracao,
      'dataVencimento': dataVencimento,
      'valorTotal': valorTotal,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorSaldoTotal': valorSaldoTotal,
      'valorSaldoPrincipal': valorSaldoPrincipal,
      'valorSaldoMulta': valorSaldoMulta,
      'valorSaldoJuros': valorSaldoJuros,
    };
  }
}

/// Mensagem de negócio
class MensagemNegocio {
  final String codigo;
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo'] as String, texto: json['texto'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
