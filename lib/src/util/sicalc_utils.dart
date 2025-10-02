import 'dart:convert';
import '../models/sicalc/sicalc_enums.dart';

/// Utilitários específicos para SICALC
class SicalcUtils {
  SicalcUtils._();

  /// Valida se o período de apuração está no formato correto (MM/AAAA)
  static bool validarPeriodoApuracao(String periodo) {
    if (periodo.isEmpty) return false;

    // Verificar formato MM/AAAA
    final regex = RegExp(r'^\d{2}/\d{4}$');
    if (!regex.hasMatch(periodo)) return false;

    final partes = periodo.split('/');
    final mes = int.tryParse(partes[0]);
    final ano = int.tryParse(partes[1]);

    if (mes == null || ano == null) return false;
    if (mes < 1 || mes > 12) return false;
    if (ano < 2000 || ano > 2100) return false;

    return true;
  }

  /// Valida se a data está no formato ISO 8601 (AAAA-MM-DDTHH:MM:SS)
  static bool validarDataISO8601(String data) {
    if (data.isEmpty) return false;

    try {
      DateTime.parse(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida se o código de receita tem formato válido
  static bool validarCodigoReceita(String codigo) {
    if (codigo.isEmpty) return false;

    // Código deve conter apenas números e ter tamanho adequado
    final regex = RegExp(r'^\d{3,4}$');
    return regex.hasMatch(codigo);
  }

  /// Valida se o código de extensão da receita tem formato válido
  static bool validarCodigoReceitaExtensao(String codigo) {
    if (codigo.isEmpty) return false;

    // Código deve conter apenas números e ter tamanho adequado
    final regex = RegExp(r'^\d{2}$');
    return regex.hasMatch(codigo);
  }

  /// Valida se o valor monetário é válido
  static bool validarValorMonetario(double valor) {
    return valor > 0 && valor <= 999999999.99;
  }

  /// Valida se o código do município é válido
  static bool validarCodigoMunicipio(int codigo) {
    return codigo > 0 && codigo <= 999999;
  }

  /// Valida se a UF é válida
  static bool validarUF(String uf) {
    if (uf.isEmpty || uf.length != 2) return false;

    return UnidadeFederativa.fromSigla(uf) != null;
  }

  /// Valida se o tipo de período de apuração é válido
  static bool validarTipoPeriodoApuracao(String tipo) {
    return TipoPeriodoApuracao.fromCodigo(tipo) != null;
  }

  /// Valida se o número da cota é válido
  static bool validarCota(int? cota) {
    if (cota == null) return true; // Opcional
    return cota > 0 && cota <= 999;
  }

  /// Valida se o CNO é válido
  static bool validarCNO(int? cno) {
    if (cno == null) return true; // Opcional
    return cno > 0;
  }

  /// Valida se o CNPJ do prestador é válido
  static bool validarCNPJPrestador(String? cnpj) {
    if (cnpj == null) return true; // Opcional
    if (cnpj.isEmpty) return false;

    // Verificar se tem 14 dígitos
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    return cleanCnpj.length == 14;
  }

  /// Formata período de apuração para exibição
  static String formatarPeriodoApuracao(String periodo) {
    if (!validarPeriodoApuracao(periodo)) return periodo;

    final partes = periodo.split('/');
    final mes = partes[0];
    final ano = partes[1];

    final meses = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

    final mesInt = int.parse(mes);
    final nomeMes = meses[mesInt];

    return '$nomeMes de $ano';
  }

  /// Formata data ISO 8601 para exibição brasileira
  static String formatarDataBrasileira(String dataISO) {
    if (!validarDataISO8601(dataISO)) return dataISO;

    try {
      final dateTime = DateTime.parse(dataISO);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    } catch (e) {
      return dataISO;
    }
  }

  /// Formata data ISO 8601 para exibição com hora
  static String formatarDataHoraBrasileira(String dataISO) {
    if (!validarDataISO8601(dataISO)) return dataISO;

    try {
      final dateTime = DateTime.parse(dataISO);
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}:'
          '${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataISO;
    }
  }

  /// Obtém o endpoint correto baseado no tipo de serviço
  static String obterEndpoint(String idServico) {
    switch (idServico) {
      case 'CONSOLIDARGERARDARF51':
      case 'GERARDARFCODBARRA53':
        return EndpointSicalc.emitir.endpoint;
      case 'CONSULTAAPOIORECEITAS52':
        return EndpointSicalc.apoiar.endpoint;
      default:
        return EndpointSicalc.emitir.endpoint;
    }
  }

  /// Valida se o PDF Base64 é válido
  static bool validarPdfBase64(String pdfBase64) {
    if (pdfBase64.isEmpty) return false;

    try {
      // Verificar se é Base64 válido
      final decoded = base64.decode(pdfBase64);

      // Verificar se contém cabeçalho PDF
      final header = String.fromCharCodes(decoded.take(4));
      return header == '%PDF';
    } catch (e) {
      return false;
    }
  }

  /// Extrai informações básicas do PDF Base64
  static Map<String, String?> extrairInfoPdf(String pdfBase64) {
    try {
      final decoded = base64.decode(pdfBase64);
      final pdfString = String.fromCharCodes(decoded);

      final info = <String, String?>{};

      // Extrair informações básicas usando regex simples
      final titleMatch = RegExp(r'/Title\s*\(([^)]+)\)').firstMatch(pdfString);
      if (titleMatch != null) {
        info['titulo'] = titleMatch.group(1);
      }

      final creatorMatch = RegExp(r'/Creator\s*\(([^)]+)\)').firstMatch(pdfString);
      if (creatorMatch != null) {
        info['criador'] = creatorMatch.group(1);
      }

      final producerMatch = RegExp(r'/Producer\s*\(([^)]+)\)').firstMatch(pdfString);
      if (producerMatch != null) {
        info['produtor'] = producerMatch.group(1);
      }

      info['tamanho_bytes'] = decoded.length.toString();
      info['tamanho_kb'] = (decoded.length / 1024).toStringAsFixed(2);

      return info;
    } catch (e) {
      return {};
    }
  }

  /// Valida estrutura completa de uma requisição SICALC
  static List<String> validarRequisicaoCompleta(Map<String, dynamic> dados) {
    final erros = <String>[];

    // Validar campos obrigatórios
    final camposObrigatorios = [
      'uf',
      'municipio',
      'codigoReceita',
      'codigoReceitaExtensao',
      'tipoPA',
      'dataPA',
      'vencimento',
      'valorImposto',
      'dataConsolidacao',
    ];

    for (final campo in camposObrigatorios) {
      if (!dados.containsKey(campo) || dados[campo] == null) {
        erros.add('Campo obrigatório ausente: $campo');
      }
    }

    // Validar UF
    if (dados['uf'] != null && !validarUF(dados['uf'])) {
      erros.add('UF inválida: ${dados['uf']}');
    }

    // Validar município
    if (dados['municipio'] != null) {
      final municipio = int.tryParse(dados['municipio'].toString());
      if (municipio == null || !validarCodigoMunicipio(municipio)) {
        erros.add('Código do município inválido: ${dados['municipio']}');
      }
    }

    // Validar código da receita
    if (dados['codigoReceita'] != null && !validarCodigoReceita(dados['codigoReceita'])) {
      erros.add('Código da receita inválido: ${dados['codigoReceita']}');
    }

    // Validar código da extensão da receita
    if (dados['codigoReceitaExtensao'] != null && !validarCodigoReceitaExtensao(dados['codigoReceitaExtensao'])) {
      erros.add('Código da extensão da receita inválido: ${dados['codigoReceitaExtensao']}');
    }

    // Validar tipo PA
    if (dados['tipoPA'] != null && !validarTipoPeriodoApuracao(dados['tipoPA'])) {
      erros.add('Tipo de período de apuração inválido: ${dados['tipoPA']}');
    }

    // Validar data PA
    if (dados['dataPA'] != null && !validarPeriodoApuracao(dados['dataPA'])) {
      erros.add('Data do período de apuração inválida: ${dados['dataPA']}');
    }

    // Validar vencimento
    if (dados['vencimento'] != null && !validarDataISO8601(dados['vencimento'])) {
      erros.add('Data de vencimento inválida: ${dados['vencimento']}');
    }

    // Validar valor do imposto
    if (dados['valorImposto'] != null) {
      final valor = double.tryParse(dados['valorImposto'].toString());
      if (valor == null || !validarValorMonetario(valor)) {
        erros.add('Valor do imposto inválido: ${dados['valorImposto']}');
      }
    }

    // Validar data de consolidação
    if (dados['dataConsolidacao'] != null && !validarDataISO8601(dados['dataConsolidacao'])) {
      erros.add('Data de consolidação inválida: ${dados['dataConsolidacao']}');
    }

    // Validar campos opcionais
    if (dados['cota'] != null) {
      final cota = int.tryParse(dados['cota'].toString());
      if (cota == null || !validarCota(cota)) {
        erros.add('Número da cota inválido: ${dados['cota']}');
      }
    }

    if (dados['valorMulta'] != null) {
      final valor = double.tryParse(dados['valorMulta'].toString());
      if (valor == null || valor < 0) {
        erros.add('Valor da multa inválido: ${dados['valorMulta']}');
      }
    }

    if (dados['valorJuros'] != null) {
      final valor = double.tryParse(dados['valorJuros'].toString());
      if (valor == null || valor < 0) {
        erros.add('Valor dos juros inválido: ${dados['valorJuros']}');
      }
    }

    if (dados['dataAlienacao'] != null && !validarDataISO8601(dados['dataAlienacao'])) {
      erros.add('Data da alienação inválida: ${dados['dataAlienacao']}');
    }

    if (dados['cno'] != null) {
      final cno = int.tryParse(dados['cno'].toString());
      if (cno == null || !validarCNO(cno)) {
        erros.add('CNO inválido: ${dados['cno']}');
      }
    }

    if (dados['cnpjPrestador'] != null && !validarCNPJPrestador(dados['cnpjPrestador'])) {
      erros.add('CNPJ do prestador inválido: ${dados['cnpjPrestador']}');
    }

    return erros;
  }

  /// Gera relatório de validação
  static Map<String, dynamic> gerarRelatorioValidacao(Map<String, dynamic> dados) {
    final erros = validarRequisicaoCompleta(dados);

    return {
      'dados_validos': erros.isEmpty,
      'total_erros': erros.length,
      'erros': erros,
      'campos_validados': dados.keys.length,
      'campos_obrigatorios_presentes': [
        'uf',
        'municipio',
        'codigoReceita',
        'codigoReceitaExtensao',
        'tipoPA',
        'dataPA',
        'vencimento',
        'valorImposto',
        'dataConsolidacao',
      ].every((campo) => dados.containsKey(campo)),
      'campos_opcionais_presentes': [
        'numeroReferencia',
        'cota',
        'valorMulta',
        'valorJuros',
        'ganhoCapital',
        'dataAlienacao',
        'observacao',
        'cno',
        'cnpjPrestador',
      ].where((campo) => dados.containsKey(campo)).length,
    };
  }
}
