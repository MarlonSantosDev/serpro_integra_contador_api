/// Utilitários para o SICALC
class SicalcUtils {
  /// Endpoints dos serviços SICALC
  static const Map<String, String> _endpoints = {
    'CONSOLIDARGERARDARF51': '/sicalc/consolidar-gerar-darf',
    'CONSULTAAPOIORECEITAS52': '/sicalc/consultar-apoioreceitas',
    'GERARDARFCODBARRA53': '/sicalc/gerar-darf-codbarra',
  };

  /// Obtém o endpoint para um serviço específico
  static String obterEndpoint(String idServico) {
    return _endpoints[idServico] ?? '/sicalc/unknown';
  }

  /// Valida UF (Unidade Federativa)
  static bool isValidUF(String uf) {
    if (uf.length != 2) return false;

    const ufsValidas = [
      'AC',
      'AL',
      'AP',
      'AM',
      'BA',
      'CE',
      'DF',
      'ES',
      'GO',
      'MA',
      'MT',
      'MS',
      'MG',
      'PA',
      'PB',
      'PR',
      'PE',
      'PI',
      'RJ',
      'RN',
      'RS',
      'RO',
      'RR',
      'SC',
      'SP',
      'SE',
      'TO',
    ];

    return ufsValidas.contains(uf.toUpperCase());
  }

  /// Valida código do município
  static bool isValidMunicipio(int municipio) {
    return municipio > 0 && municipio <= 999999;
  }

  /// Valida código da receita
  static bool isValidCodigoReceita(int codigoReceita) {
    return codigoReceita > 0 && codigoReceita <= 9999;
  }

  /// Valida código da extensão da receita
  static bool isValidCodigoReceitaExtensao(int codigoReceitaExtensao) {
    return codigoReceitaExtensao > 0 && codigoReceitaExtensao <= 99;
  }

  /// Valida tipo do período de apuração
  static bool isValidTipoPA(String? tipoPA) {
    if (tipoPA == null) return true; // Opcional

    const tiposValidos = ['AN', 'TR', 'ME', 'QZ', 'DC', 'SM', 'DI'];
    return tiposValidos.contains(tipoPA.toUpperCase());
  }

  /// Valida formato da data do período de apuração
  static bool isValidDataPA(String dataPA, String? tipoPA) {
    if (dataPA.isEmpty) return false;

    switch (tipoPA?.toUpperCase()) {
      case 'AN': // anual - aaaa
        return RegExp(r'^\d{4}$').hasMatch(dataPA);
      case 'TR': // trimestral - trimestre/ano (01 a 04)
        return RegExp(r'^(0[1-4])/\d{4}$').hasMatch(dataPA);
      case 'ME': // mensal - mm/aaaa
        return RegExp(r'^(0[1-9]|1[0-2])/\d{4}$').hasMatch(dataPA);
      case 'QZ': // quinzenal - quinzena/mm/ano (01 ou 02)
        return RegExp(r'^(0[1-2])/(0[1-9]|1[0-2])/\d{4}$').hasMatch(dataPA);
      case 'DC': // decendial - decêndio/mm/ano (01 a 03)
        return RegExp(r'^(0[1-3])/(0[1-9]|1[0-2])/\d{4}$').hasMatch(dataPA);
      case 'SM': // semanal - semana/mm/aaaa (01 a 05)
        return RegExp(r'^(0[1-5])/(0[1-9]|1[0-2])/\d{4}$').hasMatch(dataPA);
      case 'DI': // diário - dd/mm/aaaa
        return RegExp(
          r'^(0[1-9]|[12]\d|3[01])/(0[1-9]|1[0-2])/\d{4}$',
        ).hasMatch(dataPA);
      default:
        // Se não especificado, aceita qualquer formato válido
        return RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(dataPA) ||
            RegExp(r'^\d{4}$').hasMatch(dataPA);
    }
  }

  /// Valida formato de data ISO 8601
  static bool isValidIsoDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida valor monetário
  static bool isValidValorMonetario(double valor) {
    return valor > 0 && valor <= 999999999.99;
  }

  /// Valida número do documento
  static bool isValidNumeroDocumento(int numeroDocumento) {
    return numeroDocumento > 0;
  }

  /// Valida número da cota
  static bool isValidCota(int? cota) {
    return cota == null || (cota > 0 && cota <= 999);
  }

  /// Valida número de referência
  static bool isValidNumeroReferencia(int? numeroReferencia) {
    return numeroReferencia == null || numeroReferencia > 0;
  }

  /// Valida CNPJ do prestador
  static bool isValidCnpjPrestador(int? cnpjPrestador) {
    return cnpjPrestador == null || cnpjPrestador > 0;
  }

  /// Valida CNO (Cadastro Nacional de Obras)
  static bool isValidCNO(int? cno) {
    return cno == null || cno > 0;
  }

  /// Formata valor monetário para string
  static String formatarValorMonetario(double valor) {
    return valor.toStringAsFixed(2);
  }

  /// Formata data para ISO 8601
  static String formatarDataIso(DateTime data) {
    return data.toIso8601String();
  }

  /// Converte data ISO para DateTime
  static DateTime? parseDataIso(String dataIso) {
    try {
      return DateTime.parse(dataIso);
    } catch (e) {
      return null;
    }
  }

  /// Valida observação
  static bool isValidObservacao(String? observacao) {
    return observacao == null || observacao.length <= 500;
  }

  /// Códigos de receita comuns
  static const Map<String, String> codigosReceitaComuns = {
    '0190': 'IRPF - Imposto de Renda Pessoa Física',
    '0220': 'IRPJ - Imposto de Renda Pessoa Jurídica',
    '1162': 'PIS/PASEP',
    '1163': 'COFINS',
    '1164': 'CSLL',
    '1165': 'IRRF',
    '1166': 'INSS',
    '1167': 'FGTS',
  };

  /// Obtém descrição de código de receita comum
  static String? obterDescricaoCodigoReceita(int codigoReceita) {
    final codigoStr = codigoReceita.toString().padLeft(4, '0');
    return codigosReceitaComuns[codigoStr];
  }

  /// Tipos de período de apuração com descrições
  static const Map<String, String> tiposPADescricao = {
    'AN': 'Anual',
    'TR': 'Trimestral',
    'ME': 'Mensal',
    'QZ': 'Quinzenal',
    'DC': 'Decendial',
    'SM': 'Semanal',
    'DI': 'Diário',
  };

  /// Obtém descrição do tipo de período de apuração
  static String obterDescricaoTipoPA(String tipoPA) {
    return tiposPADescricao[tipoPA.toUpperCase()] ?? tipoPA;
  }

  /// Valida se um código de receita é compatível com pessoa física
  static bool isReceitaCompatiblePessoaFisica(int codigoReceita) {
    // Códigos que são específicos para pessoa física
    const codigosPF = [190, 191, 192, 193, 194, 195, 196, 197, 198, 199];
    return codigosPF.contains(codigoReceita);
  }

  /// Valida se um código de receita é compatível com pessoa jurídica
  static bool isReceitaCompatiblePessoaJuridica(int codigoReceita) {
    // Códigos que são específicos para pessoa jurídica
    const codigosPJ = [220, 221, 222, 223, 224, 225, 226, 227, 228, 229];
    return codigosPJ.contains(codigoReceita);
  }

  /// Valida se um código de receita é compatível com ambos os tipos
  static bool isReceitaCompatibleAmbos(int codigoReceita) {
    // Códigos que são compatíveis com ambos os tipos
    const codigosAmbos = [1162, 1163, 1164, 1165, 1166, 1167];
    return codigosAmbos.contains(codigoReceita);
  }

  /// Valida compatibilidade entre código de receita e tipo de pessoa
  static bool validarCompatibilidadeReceitaTipoPessoa(
    int codigoReceita,
    int tipoPessoa,
  ) {
    if (tipoPessoa == 1) {
      // Pessoa Física
      return isReceitaCompatiblePessoaFisica(codigoReceita) ||
          isReceitaCompatibleAmbos(codigoReceita);
    } else if (tipoPessoa == 2) {
      // Pessoa Jurídica
      return isReceitaCompatiblePessoaJuridica(codigoReceita) ||
          isReceitaCompatibleAmbos(codigoReceita);
    }
    return false;
  }

  /// Mensagens de erro comuns do SICALC
  static const Map<String, String> mensagensErroComuns = {
    '[EntradaIncorreta-SICALC]': 'Dados de entrada incorretos',
    '[Erro-SICALC]': 'Erro interno do sistema SICALC',
    'Contribuinte não encontrado':
        'Verificar número de identificação do contribuinte',
    'A receita não permite o uso por pessoa jurídica':
        'Código de receita incompatível com pessoa jurídica',
    'A receita não permite o uso por pessoa física':
        'Código de receita incompatível com pessoa física',
    'Erro no sistema emissor de darf': 'Indisponibilidade do serviço SICALC',
  };

  /// Obtém descrição de mensagem de erro
  static String obterDescricaoErro(String mensagem) {
    for (final entry in mensagensErroComuns.entries) {
      if (mensagem.contains(entry.key)) {
        return entry.value;
      }
    }
    return mensagem;
  }

  /// Valida se uma mensagem é um erro conhecido
  static bool isErroConhecido(String mensagem) {
    return mensagensErroComuns.keys.any((key) => mensagem.contains(key));
  }

  /// Gera data de vencimento padrão baseada no período de apuração
  static String gerarDataVencimentoPadrao(String dataPA, String? tipoPA) {
    try {
      DateTime dataBase;

      switch (tipoPA?.toUpperCase()) {
        case 'ME': // Mensal - vence no último dia do mês seguinte
          final partes = dataPA.split('/');
          final mes = int.parse(partes[0]);
          final ano = int.parse(partes[1]);
          dataBase = DateTime(ano, mes + 1, 0); // Último dia do mês
          break;
        case 'TR': // Trimestral - vence no último dia do mês seguinte ao trimestre
          final partes = dataPA.split('/');
          final trimestre = int.parse(partes[0]);
          final ano = int.parse(partes[1]);
          final mesTrimestre = trimestre * 3;
          dataBase = DateTime(ano, mesTrimestre + 1, 0);
          break;
        case 'AN': // Anual - vence em 31/03 do ano seguinte
          final ano = int.parse(dataPA);
          dataBase = DateTime(ano + 1, 3, 31);
          break;
        default:
          // Para outros tipos, usar data padrão
          dataBase = DateTime.now().add(const Duration(days: 30));
      }

      return formatarDataIso(dataBase);
    } catch (e) {
      // Se falhar, retornar data padrão
      return formatarDataIso(DateTime.now().add(const Duration(days: 30)));
    }
  }

  /// Valida dados completos de uma requisição de consolidação de DARF
  static List<String> validarDadosConsolidacao({
    required String uf,
    required int municipio,
    required int codigoReceita,
    required int codigoReceitaExtensao,
    required String dataPA,
    required String vencimento,
    required double valorImposto,
    required String dataConsolidacao,
    String? tipoPA,
    int? cota,
    double? valorMulta,
    double? valorJuros,
    String? dataAlienacao,
    String? observacao,
    int? cno,
    int? cnpjPrestador,
    int tipoPessoa = 1,
  }) {
    final List<String> erros = [];

    // Validações básicas
    if (!isValidUF(uf)) {
      erros.add('UF inválida: $uf');
    }

    if (!isValidMunicipio(municipio)) {
      erros.add('Código do município inválido: $municipio');
    }

    if (!isValidCodigoReceita(codigoReceita)) {
      erros.add('Código da receita inválido: $codigoReceita');
    }

    if (!isValidCodigoReceitaExtensao(codigoReceitaExtensao)) {
      erros.add(
        'Código da extensão da receita inválido: $codigoReceitaExtensao',
      );
    }

    if (!isValidTipoPA(tipoPA)) {
      erros.add('Tipo de período de apuração inválido: $tipoPA');
    }

    if (!isValidDataPA(dataPA, tipoPA)) {
      erros.add('Data do período de apuração inválida: $dataPA');
    }

    if (!isValidIsoDate(vencimento)) {
      erros.add('Data de vencimento inválida: $vencimento');
    }

    if (!isValidValorMonetario(valorImposto)) {
      erros.add('Valor do imposto inválido: $valorImposto');
    }

    if (!isValidIsoDate(dataConsolidacao)) {
      erros.add('Data de consolidação inválida: $dataConsolidacao');
    }

    // Validações opcionais
    if (cota != null && !isValidCota(cota)) {
      erros.add('Número da cota inválido: $cota');
    }

    if (valorMulta != null && !isValidValorMonetario(valorMulta)) {
      erros.add('Valor da multa inválido: $valorMulta');
    }

    if (valorJuros != null && !isValidValorMonetario(valorJuros)) {
      erros.add('Valor dos juros inválido: $valorJuros');
    }

    if (dataAlienacao != null && !isValidIsoDate(dataAlienacao)) {
      erros.add('Data de alienação inválida: $dataAlienacao');
    }

    if (!isValidObservacao(observacao)) {
      erros.add('Observação muito longa (máximo 500 caracteres)');
    }

    if (cno != null && !isValidCNO(cno)) {
      erros.add('CNO inválido: $cno');
    }

    if (cnpjPrestador != null && !isValidCnpjPrestador(cnpjPrestador)) {
      erros.add('CNPJ do prestador inválido: $cnpjPrestador');
    }

    // Validação de compatibilidade
    if (!validarCompatibilidadeReceitaTipoPessoa(codigoReceita, tipoPessoa)) {
      erros.add(
        'Código de receita $codigoReceita não é compatível com tipo de pessoa $tipoPessoa',
      );
    }

    return erros;
  }
}
