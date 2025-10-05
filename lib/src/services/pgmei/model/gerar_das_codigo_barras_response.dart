import 'dart:convert';
import 'base_response.dart';
import 'gerar_das_response.dart';

/// Modelo de resposta para GERARDASCODBARRA22 - Gerar DAS apenas com código de barras
///
/// Representa a resposta do serviço GERARDASCODBARRA22 que gera DAS
/// para MEI contendo apenas código de barras, sem PDF
class GerarDasCodigoBarrasResponse extends PgmeiBaseResponse {
  GerarDasCodigoBarrasResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como lista de DAS gerados (apenas com código de barras)
  List<DasCodigoBarras>? get dasGerados {
    try {
      if (dados.isEmpty) return [];

      final dadosList = jsonDecode(dados) as List;
      return dadosList.map((d) => DasCodigoBarras.fromJson(d)).toList();
    } catch (e) {
      print('Erro ao parsear DAS código barras gerados: $e');
      return null;
    }
  }

  factory GerarDasCodigoBarrasResponse.fromJson(Map<String, dynamic> json) {
    return GerarDasCodigoBarrasResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m)).toList(),
      dados: json['dados'].toString(),
    );
  }
}

/// DAS gerado apenas com código de barras (sem PDF)
class DasCodigoBarras {
  /// Número do CNPJ sem formatação
  final String cnpjCompleto;

  /// Razão social do contribuinte (quando disponível)
  final String? razaoSocial;

  /// Detalhamento do DAS (lista de detalhamentos)
  final List<DetalhamentoDasCodigoBarras> detalhamento;

  DasCodigoBarras({required this.cnpjCompleto, this.razaoSocial, required this.detalhamento});

  /// Retorna o primeiro detalhamento (mais comum em DAS únicos)
  DetalhamentoDasCodigoBarras? get primeiroDetalhamento => detalhamento.isNotEmpty ? detalhamento.first : null;

  Map<String, dynamic> toJson() {
    return {
      'cnpjCompleto': cnpjCompleto,
      if (razaoSocial != null) 'razaoSocial': razaoSocial,
      'detalhamento': detalhamento.map((d) => d.toJson()).toList(),
    };
  }

  factory DasCodigoBarras.fromJson(Map<String, dynamic> json) {
    return DasCodigoBarras(
      cnpjCompleto: json['cnpjCompleto'].toString(),
      razaoSocial: json['razaoSocial']?.toString(),
      detalhamento: (json['detalhamento'] as List).map((d) => DetalhamentoDasCodigoBarras.fromJson(d)).toList(),
    );
  }
}

/// Detalhamento de um DAS gerado apenas com código de barras
class DetalhamentoDasCodigoBarras {
  /// Período de Apuração no formato AAAAMM ou "Diversos"
  final String periodoApuracao;

  /// Número do documento gerado
  final String numeroDocumento;

  /// Data de vencimento no formato AAAAMMDD
  final String dataVencimento;

  /// Data limite para acolhimento no formato AAAAMMDD
  final String dataLimiteAcolhimento;

  /// Discriminação dos valores
  final ValoresDas valores;

  /// Lista de códigos de barras gerados
  final List<String> codigoDeBarras;

  /// Observação 1
  final String? observacao1;

  /// Observação 2
  final String? observacao2;

  /// Observação 3
  final String? observacao3;

  /// Composição do DAS gerado
  final List<ComposicaoDas>? composicao;

  DetalhamentoDasCodigoBarras({
    required this.periodoApuracao,
    required this.numeroDocumento,
    required this.dataVencimento,
    required this.dataLimiteAcolhimento,
    required this.valores,
    required this.codigoDeBarras,
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
      'codigoDeBarras': codigoDeBarras,
      if (observacao1 != null) 'observacao1': observacao1,
      if (observacao2 != null) 'observacao2': observacao2,
      if (observacao3 != null) 'observacao3': observacao3,
      if (composicao != null) 'composicao': composicao!.map((c) => c.toJson()).toList(),
    };
  }

  factory DetalhamentoDasCodigoBarras.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDasCodigoBarras(
      periodoApuracao: json['periodoApuracao'].toString(),
      numeroDocumento: json['numeroDocumento'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valores: ValoresDas.fromJson(json['valores']),
      codigoDeBarras: (json['codigoDeBarras'] as List).map((e) => e.toString()).toList(),
      observacao1: json['observacao1']?.toString(),
      observacao2: json['observacao2']?.toString(),
      observacao3: json['observacao3']?.toString(),
      composicao: json['composicao'] != null ? (json['composicao'] as List).map((c) => ComposicaoDas.fromJson(c)).toList() : null,
    );
  }
}
