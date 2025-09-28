import 'dart:convert';

/// Classe base para responses do PAGTOWEB
abstract class PagtoWebResponse {
  final int status;
  final List<MensagemNegocio> mensagens;

  PagtoWebResponse({required this.status, required this.mensagens});

  // Abstract class - cannot be instantiated directly
  // Use concrete subclasses instead

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((msg) => msg.toJson()).toList(),
    };
  }

  /// Verifica se a resposta foi bem-sucedida
  bool get sucesso => status >= 200 && status < 300;
}

/// Response para consulta de pagamentos
class ConsultarPagamentosResponse extends PagtoWebResponse {
  final List<DocumentoArrecadacao> dados;

  ConsultarPagamentosResponse({
    required int status,
    required List<MensagemNegocio> mensagens,
    required this.dados,
  }) : super(status: status, mensagens: mensagens);

  factory ConsultarPagamentosResponse.fromJson(Map<String, dynamic> json) {
    final dados = <DocumentoArrecadacao>[];

    if (json['dados'] != null) {
      final dadosString = json['dados'].toString();
      if (dadosString.isNotEmpty) {
        try {
          final dadosList = jsonDecode(dadosString) as List<dynamic>;
          dados.addAll(
            dadosList.map(
              (item) =>
                  DocumentoArrecadacao.fromJson(item as Map<String, dynamic>),
            ),
          );
        } catch (e) {
          // Se não conseguir fazer parse, deixa a lista vazia
        }
      }
    }

    return ConsultarPagamentosResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>))
          .toList(),
      dados: dados,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dados': dados.map((doc) => doc.toJson()).toList(),
    };
  }
}

/// Response para contagem de pagamentos
class ContarPagamentosResponse extends PagtoWebResponse {
  final int quantidade;

  ContarPagamentosResponse({
    required int status,
    required List<MensagemNegocio> mensagens,
    required this.quantidade,
  }) : super(status: status, mensagens: mensagens);

  factory ContarPagamentosResponse.fromJson(Map<String, dynamic> json) {
    int quantidade = 0;

    if (json['dados'] != null) {
      final dadosString = json['dados'].toString();
      if (dadosString.isNotEmpty) {
        try {
          quantidade = int.parse(dadosString);
        } catch (e) {
          quantidade = 0;
        }
      }
    }

    return ContarPagamentosResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>))
          .toList(),
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

  EmitirComprovanteResponse({
    required int status,
    required List<MensagemNegocio> mensagens,
    this.pdfBase64,
  }) : super(status: status, mensagens: mensagens);

  factory EmitirComprovanteResponse.fromJson(Map<String, dynamic> json) {
    String? pdfBase64;

    if (json['dados'] != null) {
      final dadosString = json['dados'].toString();
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
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((msg) => MensagemNegocio.fromJson(msg as Map<String, dynamic>))
          .toList(),
      pdfBase64: pdfBase64,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'dados': pdfBase64 != null ? '{"pdf":"$pdfBase64"}' : '{}',
    };
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
      numeroDocumento: json['numeroDocumento'].toString(),
      tipo: TipoDocumento.fromJson(json['tipo'] as Map<String, dynamic>),
      periodoApuracao: json['periodoApuracao'].toString(),
      dataArrecadacao: json['dataArrecadacao'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      receitaPrincipal: ReceitaPrincipal.fromJson(
        json['receitaPrincipal'] as Map<String, dynamic>,
      ),
      referencia: json['referencia']?.toString(),
      valorTotal: (num.parse(json['valorTotal'].toString())).toDouble(),
      valorPrincipal: (num.parse(json['valorPrincipal'].toString())).toDouble(),
      valorMulta: json['valorMulta'] != null
          ? (num.parse(json['valorMulta'].toString())).toDouble()
          : null,
      valorJuros: json['valorJuros'] != null
          ? (num.parse(json['valorJuros'].toString())).toDouble()
          : null,
      valorSaldoTotal: json['valorSaldoTotal'] != null
          ? (num.parse(json['valorSaldoTotal'].toString())).toDouble()
          : null,
      valorSaldoPrincipal: json['valorSaldoPrincipal'] != null
          ? (num.parse(json['valorSaldoPrincipal'].toString())).toDouble()
          : null,
      valorSaldoMulta: json['valorSaldoMulta'] != null
          ? (num.parse(json['valorSaldoMulta'].toString())).toDouble()
          : null,
      valorSaldoJuros: json['valorSaldoJuros'] != null
          ? (num.parse(json['valorSaldoJuros'].toString())).toDouble()
          : null,
      desmembramentos: (json['desmembramentos'] as List<dynamic>)
          .map((item) => Desmembramento.fromJson(item as Map<String, dynamic>))
          .toList(),
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

  TipoDocumento({
    required this.codigo,
    required this.descricao,
    required this.descricaoAbreviada,
  });

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      codigo: json['codigo'].toString(),
      descricao: json['descricao'].toString(),
      descricaoAbreviada: json['descricaoAbreviada'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'descricaoAbreviada': descricaoAbreviada,
    };
  }
}

/// Receita principal
class ReceitaPrincipal {
  final String codigo;
  final String descricao;
  final String? extensaoReceita;

  ReceitaPrincipal({
    required this.codigo,
    required this.descricao,
    this.extensaoReceita,
  });

  factory ReceitaPrincipal.fromJson(Map<String, dynamic> json) {
    return ReceitaPrincipal(
      codigo: json['codigo'].toString(),
      descricao: json['descricao'].toString(),
      extensaoReceita: json['extensaoReceita']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'extensaoReceita': extensaoReceita,
    };
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
      sequencial: json['sequencial'].toString(),
      receitaPrincipal: ReceitaPrincipal.fromJson(
        json['receitaPrincipal'] as Map<String, dynamic>,
      ),
      periodoApuracao: json['periodoApuracao'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      valorTotal: json['valorTotal'] != null
          ? (num.parse(json['valorTotal'].toString())).toDouble()
          : null,
      valorPrincipal: json['valorPrincipal'] != null
          ? (num.parse(json['valorPrincipal'].toString())).toDouble()
          : null,
      valorMulta: json['valorMulta'] != null
          ? (num.parse(json['valorMulta'].toString())).toDouble()
          : null,
      valorJuros: json['valorJuros'] != null
          ? (num.parse(json['valorJuros'].toString())).toDouble()
          : null,
      valorSaldoTotal: json['valorSaldoTotal'] != null
          ? (num.parse(json['valorSaldoTotal'].toString())).toDouble()
          : null,
      valorSaldoPrincipal: json['valorSaldoPrincipal'] != null
          ? (num.parse(json['valorSaldoPrincipal'].toString())).toDouble()
          : null,
      valorSaldoMulta: json['valorSaldoMulta'] != null
          ? (num.parse(json['valorSaldoMulta'].toString())).toDouble()
          : null,
      valorSaldoJuros: json['valorSaldoJuros'] != null
          ? (num.parse(json['valorSaldoJuros'].toString())).toDouble()
          : null,
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
    return MensagemNegocio(
      codigo: json['codigo'].toString(),
      texto: json['texto'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}
