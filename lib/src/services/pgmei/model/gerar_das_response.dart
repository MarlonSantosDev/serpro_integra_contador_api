import 'dart:convert';
import 'base_response.dart';

/// Modelo de resposta para GERARDASPDF21 - Gerar DAS com PDF
///
/// Representa a resposta do serviço GERARDASPDF21 que gera DAS
/// para MEI com PDF completo
class PgmeiGerarDasResponse extends PgmeiBaseResponse {
  PgmeiGerarDasResponse({
    required super.status,
    required super.mensagens,
    required super.dados,
  });

  /// Parse dos dados como lista de DAS gerados
  List<PgmeiDas>? get dasGerados {
    try {
      final dadosMap = dados;
      if (dadosMap == null) return [];
      if (dadosMap.containsKey('das') && dadosMap['das'] is List) {
        return (dadosMap['das'] as List)
            .map((d) => PgmeiDas.fromJson(d as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // printE('Erro ao parsear DAS gerados: $e');
      return [];
    }
  }

  factory PgmeiGerarDasResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final decoded = jsonDecode(dadosStr);
        if (decoded is List) {
          // Se for uma lista, converte para Map com chave 'das'
          dadosParsed = {'das': decoded};
        } else if (decoded is Map) {
          dadosParsed = decoded as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return PgmeiGerarDasResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((m) => Mensagem.fromJson(m))
          .toList(),
      dados: dadosParsed,
    );
  }
}

/// DAS gerado pelo PGMEI
class PgmeiDas {
  /// PDF do DAS no formato Base64
  final String pdf;

  /// Número do CNPJ sem formatação
  final String cnpjCompleto;

  /// Razão social do contribuinte (quando disponível)
  final String? razaoSocial;

  /// Detalhamento do DAS (lista de detalhamentos)
  final List<DetalhamentoDas> detalhamento;

  PgmeiDas({
    required this.pdf,
    required this.cnpjCompleto,
    this.razaoSocial,
    required this.detalhamento,
  });

  /// Retorna o primeiro detalhamento (mais comum em DAS únicos)
  DetalhamentoDas? get primeiroDetalhamento =>
      detalhamento.isNotEmpty ? detalhamento.first : null;

  Map<String, dynamic> toJson() {
    return {
      'pdf': pdf,
      'cnpjCompleto': cnpjCompleto,
      if (razaoSocial != null) 'razaoSocial': razaoSocial,
      'detalhamento': detalhamento.map((d) => d.toJson()).toList(),
    };
  }

  factory PgmeiDas.fromJson(Map<String, dynamic> json) {
    return PgmeiDas(
      pdf: json['pdf'].toString(),
      cnpjCompleto: json['cnpjCompleto'].toString(),
      razaoSocial: json['razaoSocial']?.toString(),
      detalhamento: (json['detalhamento'] as List)
          .map((d) => DetalhamentoDas.fromJson(d))
          .toList(),
    );
  }
}

/// Detalhamento de um DAS gerado
class DetalhamentoDas {
  /// Período de Apuração no formato AAAAMM ou "Diversos"
  final String periodoApuracao;

  /// Número do documento gerado
  final String numeroDocumento;

  /// Data de vencimento no formato AAAAMMDD
  final String dataVencimento;

  /// Data limite para acolhimento no formato AAAAMMDD
  final String dataLimiteAcolhimento;

  /// Discriminação dos valores
  final PgmeiValoresDas valores;

  /// Lista de códigos de barras gerados (quando aplicável)
  final List<String>? codigoDeBarras;

  /// Observação 1
  final String? observacao1;

  /// Observação 2
  final String? observacao2;

  /// Observação 3
  final String? observacao3;

  /// Composição do DAS gerado
  final List<PgmeiComposicaoDas>? composicao;

  DetalhamentoDas({
    required this.periodoApuracao,
    required this.numeroDocumento,
    required this.dataVencimento,
    required this.dataLimiteAcolhimento,
    required this.valores,
    this.codigoDeBarras,
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
      if (codigoDeBarras != null) 'codigoDeBarras': codigoDeBarras,
      if (observacao1 != null) 'observacao1': observacao1,
      if (observacao2 != null) 'observacao2': observacao2,
      if (observacao3 != null) 'observacao3': observacao3,
      if (composicao != null)
        'composicao': composicao!.map((c) => c.toJson()).toList(),
    };
  }

  factory DetalhamentoDas.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDas(
      periodoApuracao: json['periodoApuracao'].toString(),
      numeroDocumento: json['numeroDocumento'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valores: PgmeiValoresDas.fromJson(json['valores']),
      codigoDeBarras: json['codigoDeBarras'] != null
          ? (json['codigoDeBarras'] as List).map((e) => e.toString()).toList()
          : null,
      observacao1: json['observacao1']?.toString(),
      observacao2: json['observacao2']?.toString(),
      observacao3: json['observacao3']?.toString(),
      composicao: json['composicao'] != null
          ? (json['composicao'] as List)
                .map((c) => PgmeiComposicaoDas.fromJson(c))
                .toList()
          : null,
    );
  }
}

/// Valores de um DAS do PGMEI
class PgmeiValoresDas {
  /// Valor do principal
  final double principal;

  /// Valor da multa
  final double multa;

  /// Valor dos juros
  final double juros;

  /// Valor total
  final double total;

  PgmeiValoresDas({
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

  factory PgmeiValoresDas.fromJson(Map<String, dynamic> json) {
    return PgmeiValoresDas(
      principal: double.parse(json['principal'].toString()),
      multa: double.parse(json['multa'].toString()),
      juros: double.parse(json['juros'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}

/// Composição de um DAS por tributo (PGMEI)
class PgmeiComposicaoDas {
  /// Período de apuração do tributo no formato AAAAMM
  final String periodoApuracao;

  /// Código do tributo
  final String codigo;

  /// Descrição do nome/destino do tributo
  final String denominacao;

  /// Valores discriminados do tributo
  final PgmeiValoresDas valores;

  PgmeiComposicaoDas({
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

  factory PgmeiComposicaoDas.fromJson(Map<String, dynamic> json) {
    return PgmeiComposicaoDas(
      periodoApuracao: json['periodoApuracao'].toString(),
      codigo: json['codigo'].toString(),
      denominacao: json['denominacao'].toString(),
      valores: PgmeiValoresDas.fromJson(json['valores']),
    );
  }
}
