import '../base/common.dart';
import 'dart:convert';

/// Modelo para resposta de consolidação e emissão de DARF
class ConsolidarEmitirDarfResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio>? mensagens;

  /// Dados consolidados do cálculo
  final ConsolidadoDarf? consolidado;

  /// Conteúdo binário Base64 contendo o PDF do DARF
  final String? darf;

  /// Número do documento
  final String? numeroDocumento;

  ConsolidarEmitirDarfResponse({required this.status, this.mensagens, this.consolidado, this.darf, this.numeroDocumento});

  factory ConsolidarEmitirDarfResponse.fromJson(Map<String, dynamic> json) {
    ConsolidadoDarf? consolidado;
    String? darf;
    String? numeroDocumento;

    // Processar dados se existirem
    if (json['dados'] != null) {
      final dadosStr = json['dados'] as String;
      try {
        final dados = jsonDecode(dadosStr);

        if (dados['consolidado'] != null) {
          consolidado = ConsolidadoDarf.fromJson(dados['consolidado']);
        }

        darf = dados['darf'] as String?;
        numeroDocumento = dados['numeroDocumento'] as String?;
      } catch (e) {
        // Ignorar erro de parsing, manter campos como null
      }
    }

    return ConsolidarEmitirDarfResponse(
      status: json['status'] as int,
      mensagens: json['mensagens'] != null ? (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList() : null,
      consolidado: consolidado,
      darf: darf,
      numeroDocumento: numeroDocumento,
    );
  }
}

/// Modelo para dados consolidados do DARF
class ConsolidadoDarf {
  /// Valor principal calculado
  final double valorPrincipalMoedaCorrente;

  /// Valor total do débito calculado
  final double valorTotalConsolidado;

  /// Valor de multa de mora calculada
  final double valorMultaMora;

  /// Percentual de multa de mora calculada
  final double percentualMultaMora;

  /// Valor de juros calculada
  final double valorJuros;

  /// Percentual de juros calculado
  final double percentualJuros;

  /// Data no qual começa a incidência de juros no débito
  final String termoInicialJuros;

  /// Data de Arrecadação/Consolidação considerada no resultado de cálculo
  final String dataArrecadacaoConsolidacao;

  /// Data em que o resultado de calculo é válido
  final String dataValidadeCalculo;

  ConsolidadoDarf({
    required this.valorPrincipalMoedaCorrente,
    required this.valorTotalConsolidado,
    required this.valorMultaMora,
    required this.percentualMultaMora,
    required this.valorJuros,
    required this.percentualJuros,
    required this.termoInicialJuros,
    required this.dataArrecadacaoConsolidacao,
    required this.dataValidadeCalculo,
  });

  factory ConsolidadoDarf.fromJson(Map<String, dynamic> json) {
    return ConsolidadoDarf(
      valorPrincipalMoedaCorrente: (json['valorPrincipalMoedaCorrente'] as num).toDouble(),
      valorTotalConsolidado: (json['valorTotalConsolidado'] as num).toDouble(),
      valorMultaMora: (json['valorMultaMora'] as num).toDouble(),
      percentualMultaMora: (json['percentualMultaMora'] as num).toDouble(),
      valorJuros: (json['valorJuros'] as num).toDouble(),
      percentualJuros: (json['percentualJuros'] as num).toDouble(),
      termoInicialJuros: json['termoInicialJuros'] as String,
      dataArrecadacaoConsolidacao: json['dataArrecadacaoConsolidacao'] as String,
      dataValidadeCalculo: json['dataValidadeCalculo'] as String,
    );
  }
}

/// Modelo para resposta de consulta de receitas
class ConsultarReceitasResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio>? mensagens;

  /// Dados da receita consultada
  final ReceitaInfo? receita;

  ConsultarReceitasResponse({required this.status, this.mensagens, this.receita});

  factory ConsultarReceitasResponse.fromJson(Map<String, dynamic> json) {
    ReceitaInfo? receita;

    // Processar dados se existirem
    if (json['dados'] != null) {
      final dadosStr = json['dados'] as String;
      try {
        final dados = jsonDecode(dadosStr);

        if (dados['receita'] != null) {
          receita = ReceitaInfo.fromJson(dados['receita']);
        }
      } catch (e) {
        // Ignorar erro de parsing, manter campos como null
      }
    }

    return ConsultarReceitasResponse(
      status: json['status'] as int,
      mensagens: json['mensagens'] != null ? (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList() : null,
      receita: receita,
    );
  }
}

/// Modelo para informações da receita
class ReceitaInfo {
  /// Código de receita informado na chamada
  final int codigoReceita;

  /// Nome descritivo do código de receita
  final String descricaoReceita;

  /// Extensões da receita
  final List<ExtensaoReceita> extensoes;

  ReceitaInfo({required this.codigoReceita, required this.descricaoReceita, required this.extensoes});

  factory ReceitaInfo.fromJson(Map<String, dynamic> json) {
    return ReceitaInfo(
      codigoReceita: json['codigoReceita'] as int,
      descricaoReceita: json['descricaoReceita'] as String,
      extensoes: (json['extensoes'] as List).map((e) => ExtensaoReceita.fromJson(e)).toList(),
    );
  }
}

/// Modelo para extensão da receita
class ExtensaoReceita {
  /// Campos obrigatórios
  final CamposObrigatorios obrigatorios;

  /// Campos opcionais
  final CamposOpcionais opcionais;

  /// Informações adicionais
  final InformacoesAdicionais informacoes;

  ExtensaoReceita({required this.obrigatorios, required this.opcionais, required this.informacoes});

  factory ExtensaoReceita.fromJson(Map<String, dynamic> json) {
    return ExtensaoReceita(
      obrigatorios: CamposObrigatorios.fromJson(json['obrigatorios']),
      opcionais: CamposOpcionais.fromJson(json['opcionais']),
      informacoes: InformacoesAdicionais.fromJson(json['informacoes']),
    );
  }
}

/// Modelo para campos obrigatórios
class CamposObrigatorios {
  final bool codigoReceita;
  final bool codigoReceitaExtensao;
  final bool cota;
  final bool dataConsolidacao;
  final bool dataPA;
  final bool referencia;
  final bool tipoPA;
  final bool valorImposto;
  final bool vencimento;

  CamposObrigatorios({
    required this.codigoReceita,
    required this.codigoReceitaExtensao,
    required this.cota,
    required this.dataConsolidacao,
    required this.dataPA,
    required this.referencia,
    required this.tipoPA,
    required this.valorImposto,
    required this.vencimento,
  });

  factory CamposObrigatorios.fromJson(Map<String, dynamic> json) {
    return CamposObrigatorios(
      codigoReceita: json['codigoReceita'] as bool,
      codigoReceitaExtensao: json['codigoReceitaExtensao'] as bool,
      cota: json['cota'] as bool,
      dataConsolidacao: json['dataConsolidacao'] as bool,
      dataPA: json['dataPA'] as bool,
      referencia: json['referencia'] as bool,
      tipoPA: json['tipoPA'] as bool,
      valorImposto: json['valorImposto'] as bool,
      vencimento: json['vencimento'] as bool,
    );
  }
}

/// Modelo para campos opcionais
class CamposOpcionais {
  final bool cno;
  final bool cnpjPrestador;
  final bool dataAlienacao;
  final bool ganhoCapital;
  final bool municipio;
  final bool observacao;
  final bool referencia;
  final bool uf;
  final bool valorJuros;
  final bool valorMulta;

  CamposOpcionais({
    required this.cno,
    required this.cnpjPrestador,
    required this.dataAlienacao,
    required this.ganhoCapital,
    required this.municipio,
    required this.observacao,
    required this.referencia,
    required this.uf,
    required this.valorJuros,
    required this.valorMulta,
  });

  factory CamposOpcionais.fromJson(Map<String, dynamic> json) {
    return CamposOpcionais(
      cno: json['cno'] as bool,
      cnpjPrestador: json['cnpjPrestador'] as bool,
      dataAlienacao: json['dataAlienacao'] as bool,
      ganhoCapital: json['ganhoCapital'] as bool,
      municipio: json['municipio'] as bool,
      observacao: json['observacao'] as bool,
      referencia: json['referencia'] as bool,
      uf: json['uf'] as bool,
      valorJuros: json['valorJuros'] as bool,
      valorMulta: json['valorMulta'] as bool,
    );
  }
}

/// Modelo para informações adicionais
class InformacoesAdicionais {
  final bool calculado;
  final bool codigoBarras;
  final int codigoReceitaExtensao;
  final String criacao;
  final String descricaoReceitaExtensao;
  final String descricaoReferencia;
  final bool exigeMatriz;
  final String? extincao;
  final bool manual;
  final bool pf;
  final bool pj;
  final String tipoPeriodoApuracao;
  final bool vedaValor;

  InformacoesAdicionais({
    required this.calculado,
    required this.codigoBarras,
    required this.codigoReceitaExtensao,
    required this.criacao,
    required this.descricaoReceitaExtensao,
    required this.descricaoReferencia,
    required this.exigeMatriz,
    this.extincao,
    required this.manual,
    required this.pf,
    required this.pj,
    required this.tipoPeriodoApuracao,
    required this.vedaValor,
  });

  factory InformacoesAdicionais.fromJson(Map<String, dynamic> json) {
    return InformacoesAdicionais(
      calculado: json['calculado'] as bool,
      codigoBarras: json['codigoBarras'] as bool,
      codigoReceitaExtensao: json['codigoReceitaExtensao'] as int,
      criacao: json['criacao'] as String,
      descricaoReceitaExtensao: json['descricaoReceitaExtensao'] as String,
      descricaoReferencia: json['descricaoReferencia'] as String,
      exigeMatriz: json['exigeMatriz'] as bool,
      extincao: json['extincao'] as String?,
      manual: json['manual'] as bool,
      pf: json['pf'] as bool,
      pj: json['pj'] as bool,
      tipoPeriodoApuracao: json['tipoPeriodoApuracao'] as String,
      vedaValor: json['vedaValor'] as bool,
    );
  }
}

/// Modelo para resposta de geração de código de barras
class GerarCodigoBarrasResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio>? mensagens;

  /// Dados consolidados do cálculo
  final ConsolidadoDarf? consolidado;

  /// Código de barras gerado
  final CodigoBarras? codigoDeBarras;

  /// Número do documento
  final String? numeroDocumento;

  GerarCodigoBarrasResponse({required this.status, this.mensagens, this.consolidado, this.codigoDeBarras, this.numeroDocumento});

  factory GerarCodigoBarrasResponse.fromJson(Map<String, dynamic> json) {
    ConsolidadoDarf? consolidado;
    CodigoBarras? codigoDeBarras;
    String? numeroDocumento;

    // Processar dados se existirem
    if (json['dados'] != null) {
      final dadosStr = json['dados'] as String;
      try {
        final dados = jsonDecode(dadosStr);

        if (dados['consolidado'] != null) {
          consolidado = ConsolidadoDarf.fromJson(dados['consolidado']);
        }

        if (dados['codigoDeBarras'] != null) {
          codigoDeBarras = CodigoBarras.fromJson(dados['codigoDeBarras']);
        }

        numeroDocumento = dados['numeroDocumento'] as String?;
      } catch (e) {
        // Ignorar erro de parsing, manter campos como null
      }
    }

    return GerarCodigoBarrasResponse(
      status: json['status'] as int,
      mensagens: json['mensagens'] != null ? (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList() : null,
      consolidado: consolidado,
      codigoDeBarras: codigoDeBarras,
      numeroDocumento: numeroDocumento,
    );
  }
}

/// Modelo para código de barras
class CodigoBarras {
  /// Código do campo 01 com dígito verificador
  final String campo1ComDV;

  /// Código do campo 02 com dígito verificador
  final String campo2ComDV;

  /// Código do campo 03 com dígito verificador
  final String campo3ComDV;

  /// Código do campo 04 com dígito verificador
  final String campo4ComDV;

  /// Código de barras com 44 caracteres sem os dígitos verificadores
  final String codigo44;

  CodigoBarras({required this.campo1ComDV, required this.campo2ComDV, required this.campo3ComDV, required this.campo4ComDV, required this.codigo44});

  factory CodigoBarras.fromJson(Map<String, dynamic> json) {
    return CodigoBarras(
      campo1ComDV: json['campo1ComDV'] as String,
      campo2ComDV: json['campo2ComDV'] as String,
      campo3ComDV: json['campo3ComDV'] as String,
      campo4ComDV: json['campo4ComDV'] as String,
      codigo44: json['codigo44'] as String,
    );
  }
}
