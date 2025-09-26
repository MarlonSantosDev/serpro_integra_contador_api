import 'dart:convert';
import '../models/dctfweb/dctfweb_request.dart';

/// Utilitários específicos para DCTFWeb
class DctfWebUtils {
  /// Valida se o período de apuração está no formato correto
  static bool validarPeriodoApuracao(String ano, String? mes, String? dia) {
    // Validar ano
    if (ano.length != 4 || int.tryParse(ano) == null) {
      return false;
    }

    // Validar mês se fornecido
    if (mes != null && mes.isNotEmpty) {
      if (mes.length != 2 || int.tryParse(mes) == null) {
        return false;
      }
      final mesInt = int.parse(mes);
      if (mesInt < 1 || mesInt > 12) {
        return false;
      }
    }

    // Validar dia se fornecido
    if (dia != null && dia.isNotEmpty) {
      if (dia.length != 2 || int.tryParse(dia) == null) {
        return false;
      }
      final diaInt = int.parse(dia);
      if (diaInt < 1 || diaInt > 31) {
        return false;
      }
    }

    return true;
  }

  /// Formata data no formato AAAAMMDD para data legível
  static String formatarDataApuracao(String ano, String? mes, String? dia) {
    if (mes == null || mes.isEmpty) {
      return ano; // Apenas ano para categorias anuais
    }

    if (dia == null || dia.isEmpty) {
      return '$mes/$ano'; // Mês/Ano para categorias mensais
    }

    return '$dia/$mes/$ano'; // Dia/Mês/Ano para categorias diárias
  }

  /// Obtém descrição da categoria
  static String obterDescricaoCategoria(CategoriaDctf categoria) {
    switch (categoria) {
      case CategoriaDctf.geralMensal:
        return 'Geral Mensal';
      case CategoriaDctf.geral13Salario:
        return 'Geral 13º Salário';
      case CategoriaDctf.afericao:
        return 'Aferição';
      case CategoriaDctf.espetaculoDesportivo:
        return 'Espetáculo Desportivo';
      case CategoriaDctf.reclamatoriaTrabalhista:
        return 'Reclamatória Trabalhista';
      case CategoriaDctf.pfMensal:
        return 'Pessoa Física Mensal';
      case CategoriaDctf.pf13Salario:
        return 'Pessoa Física 13º Salário';
    }
  }

  /// Obtém descrição do sistema de origem
  static String obterDescricaoSistemaOrigem(SistemaOrigem sistema) {
    switch (sistema) {
      case SistemaOrigem.esocial:
        return 'eSocial';
      case SistemaOrigem.sero:
        return 'Sero';
      case SistemaOrigem.reinfCp:
        return 'Reinf CP';
      case SistemaOrigem.reinfRet:
        return 'Reinf RET';
      case SistemaOrigem.mit:
        return 'MIT';
    }
  }

  /// Verifica se uma data de acolhimento está no formato correto (AAAAMMDD)
  static bool validarDataAcolhimento(int dataAcolhimento) {
    final dataStr = dataAcolhimento.toString();

    if (dataStr.length != 8) return false;

    final ano = int.tryParse(dataStr.substring(0, 4));
    final mes = int.tryParse(dataStr.substring(4, 6));
    final dia = int.tryParse(dataStr.substring(6, 8));

    if (ano == null || mes == null || dia == null) return false;
    if (mes < 1 || mes > 12) return false;
    if (dia < 1 || dia > 31) return false;

    // Verificar se é uma data válida
    try {
      DateTime(ano, mes, dia);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Converte data DateTime para formato AAAAMMDD
  static int converterDataParaAcolhimento(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return int.parse('$ano$mes$dia');
  }

  /// Converte formato AAAAMMDD para DateTime
  static DateTime? converterAcolhimentoParaData(int dataAcolhimento) {
    if (!validarDataAcolhimento(dataAcolhimento)) return null;

    final dataStr = dataAcolhimento.toString();
    final ano = int.parse(dataStr.substring(0, 4));
    final mes = int.parse(dataStr.substring(4, 6));
    final dia = int.parse(dataStr.substring(6, 8));

    try {
      return DateTime(ano, mes, dia);
    } catch (e) {
      return null;
    }
  }

  /// Obtém o endpoint correto baseado no tipo de serviço
  static String obterEndpoint(String idServico) {
    switch (idServico) {
      case 'GERARGUIA31':
      case 'GERARGUIAANDAMENTO313':
        return '/Emitir';
      case 'CONSRECIBO32':
      case 'CONSDECCOMPLETA33':
      case 'CONSXMLDECLARACAO38':
        return '/Consultar';
      case 'TRANSDECLARACAO310':
        return '/Declarar';
      default:
        return '/Consultar'; // Default para consultas
    }
  }

  /// Verifica se o XML Base64 é válido
  static bool validarXmlBase64(String xmlBase64) {
    if (xmlBase64.isEmpty) return false;

    try {
      // Tentar decodificar Base64
      final decoded = base64.decode(xmlBase64);

      // Verificar se contém caracteres XML básicos
      final xmlString = String.fromCharCodes(decoded);
      return xmlString.contains('<?xml') &&
          xmlString.contains('<ConteudoDeclaracao') &&
          xmlString.contains('</ConteudoDeclaracao>');
    } catch (e) {
      return false;
    }
  }

  /// Extrai informações básicas do XML Base64 sem decodificar completamente
  static Map<String, String?> extrairInfoXml(String xmlBase64) {
    try {
      final decoded = base64.decode(xmlBase64);
      final xmlString = String.fromCharCodes(decoded);

      // Extrair informações básicas usando regex simples
      final info = <String, String?>{};

      // Categoria
      final categoriaMatch = RegExp(
        r'<categoriaDCTF>(\d+)</categoriaDCTF>',
      ).firstMatch(xmlString);
      if (categoriaMatch != null) {
        info['categoria'] = categoriaMatch.group(1);
      }

      // Período de apuração
      final periodoMatch = RegExp(
        r'<perApuracao>(\d+)</perApuracao>',
      ).firstMatch(xmlString);
      if (periodoMatch != null) {
        info['periodoApuracao'] = periodoMatch.group(1);
      }

      // Contribuinte
      final contribuinteMatch = RegExp(
        r'<inscContrib>(\d+)</inscContrib>',
      ).firstMatch(xmlString);
      if (contribuinteMatch != null) {
        info['contribuinte'] = contribuinteMatch.group(1);
      }

      return info;
    } catch (e) {
      return {};
    }
  }
}
