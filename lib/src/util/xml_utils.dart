import 'dart:convert';

/// Utilitários para manipulação de XML
class XmlUtils {
  /// Escapa caracteres especiais em XML
  static String escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Remove escape de caracteres XML
  static String unescapeXml(String text) {
    return text
        .replaceAll('&apos;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&');
  }

  /// Valida se o texto é um XML válido
  static bool isValidXml(String xml) {
    try {
      // Verificação básica de estrutura XML
      if (!xml.trim().startsWith('<?xml')) return false;
      if (!xml.contains('<') || !xml.contains('>')) return false;

      // Verificar se tags estão balanceadas (verificação simples)
      final openTags = RegExp(r'<[^/][^>]*>').allMatches(xml).length;
      final closeTags = RegExp(r'</[^>]*>').allMatches(xml).length;
      final selfClosingTags = RegExp(r'<[^>]*/>').allMatches(xml).length;

      return openTags == closeTags + selfClosingTags;
    } catch (e) {
      return false;
    }
  }

  /// Extrai valor de um atributo XML
  static String? extractAttributeValue(
    String xml,
    String tagName,
    String attributeName,
  ) {
    try {
      final regex = RegExp('<$tagName[^>]*$attributeName="([^"]*)"');
      final match = regex.firstMatch(xml);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  /// Extrai conteúdo de uma tag XML
  static String? extractTagContent(String xml, String tagName) {
    try {
      final regex = RegExp('<$tagName[^>]*>(.*?)</$tagName>', dotAll: true);
      final match = regex.firstMatch(xml);
      return match?.group(1)?.trim();
    } catch (e) {
      return null;
    }
  }

  /// Extrai todas as ocorrências de uma tag
  static List<String> extractAllTagContent(String xml, String tagName) {
    try {
      final regex = RegExp('<$tagName[^>]*>(.*?)</$tagName>', dotAll: true);
      return regex
          .allMatches(xml)
          .map((match) => match.group(1)?.trim() ?? '')
          .where((content) => content.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Formata XML com indentação
  static String formatXml(String xml) {
    try {
      // Implementação simples de formatação
      String formatted = xml;

      // Adicionar quebras de linha após tags de fechamento
      formatted = formatted.replaceAll('>', '>\n');

      // Adicionar indentação
      final lines = formatted.split('\n');
      final formattedLines = <String>[];
      int indentLevel = 0;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // Diminuir indentação para tags de fechamento
        if (trimmed.startsWith('</')) {
          indentLevel--;
        }

        // Adicionar linha com indentação
        formattedLines.add('  ' * indentLevel + trimmed);

        // Aumentar indentação para tags de abertura (não auto-fechamento)
        if (trimmed.startsWith('<') &&
            !trimmed.startsWith('</') &&
            !trimmed.endsWith('/>')) {
          indentLevel++;
        }
      }

      return formattedLines.join('\n');
    } catch (e) {
      return xml; // Retornar original se houver erro
    }
  }

  /// Valida estrutura do Termo de Autorização
  static List<String> validarEstruturaTermoAutorizacao(String xml) {
    final erros = <String>[];

    try {
      // Verificar se é XML válido
      if (!isValidXml(xml)) {
        erros.add('XML inválido');
        return erros;
      }

      // Verificar tags obrigatórias
      final tagsObrigatorias = [
        'termoDeAutorizacao',
        'dados',
        'sistema',
        'termo',
        'avisoLegal',
        'finalidade',
        'dataAssinatura',
        'vigencia',
        'destinatario',
        'assinadoPor',
        'Signature',
      ];

      for (final tag in tagsObrigatorias) {
        if (!xml.contains('<$tag') && !xml.contains('<$tag ')) {
          erros.add('Tag obrigatória ausente: $tag');
        }
      }

      // Verificar atributos obrigatórios
      final atributosObrigatorios = {
        'sistema': ['id'],
        'termo': ['texto'],
        'avisoLegal': ['texto'],
        'finalidade': ['texto'],
        'dataAssinatura': ['data'],
        'vigencia': ['data'],
        'destinatario': ['numero', 'nome', 'tipo', 'papel'],
        'assinadoPor': ['numero', 'nome', 'tipo', 'papel'],
      };

      for (final entry in atributosObrigatorios.entries) {
        final tag = entry.key;
        final atributos = entry.value;

        for (final atributo in atributos) {
          final valor = extractAttributeValue(xml, tag, atributo);
          if (valor == null || valor.isEmpty) {
            erros.add('Atributo obrigatório ausente: $tag.$atributo');
          }
        }
      }

      // Verificar textos obrigatórios
      final textosObrigatorios = {
        'termo': 'Autorizo a empresa CONTRATANTE',
        'avisoLegal': 'O acesso a estas informações foi autorizado',
        'finalidade': 'A finalidade única e exclusiva',
      };

      for (final entry in textosObrigatorios.entries) {
        final tag = entry.key;
        final textoEsperado = entry.value;
        final textoAtual = extractAttributeValue(xml, tag, 'texto');

        if (textoAtual == null || !textoAtual.contains(textoEsperado)) {
          erros.add('Texto obrigatório incorreto ou ausente em $tag');
        }
      }

      // Verificar formato de datas
      final dataAssinatura = extractAttributeValue(
        xml,
        'dataAssinatura',
        'data',
      );
      if (dataAssinatura != null && !_isValidDateFormat(dataAssinatura)) {
        erros.add('Formato de data de assinatura inválido: $dataAssinatura');
      }

      final dataVigencia = extractAttributeValue(xml, 'vigencia', 'data');
      if (dataVigencia != null && !_isValidDateFormat(dataVigencia)) {
        erros.add('Formato de data de vigência inválido: $dataVigencia');
      }

      // Verificar tipos de documento
      final tipoDestinatario = extractAttributeValue(
        xml,
        'destinatario',
        'tipo',
      );
      if (tipoDestinatario != null &&
          !['PF', 'PJ'].contains(tipoDestinatario)) {
        erros.add('Tipo do destinatário deve ser PF ou PJ: $tipoDestinatario');
      }

      final tipoAssinadoPor = extractAttributeValue(xml, 'assinadoPor', 'tipo');
      if (tipoAssinadoPor != null && !['PF', 'PJ'].contains(tipoAssinadoPor)) {
        erros.add('Tipo do assinado por deve ser PF ou PJ: $tipoAssinadoPor');
      }
    } catch (e) {
      erros.add('Erro ao validar XML: $e');
    }

    return erros;
  }

  /// Valida formato de data AAAAMMDD
  static bool _isValidDateFormat(String date) {
    if (date.length != 8) return false;

    try {
      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));
      final day = int.parse(date.substring(6, 8));

      if (year < 2000 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Validação básica de dias por mês
      final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (month == 2 && _isLeapYear(year)) {
        return day <= 29;
      }
      return day <= daysInMonth[month - 1];
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o ano é bissexto
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Converte XML para Base64
  static String xmlToBase64(String xml) {
    return base64.encode(utf8.encode(xml));
  }

  /// Converte Base64 para XML
  static String base64ToXml(String base64String) {
    return utf8.decode(base64.decode(base64String));
  }

  /// Extrai informações do certificado do XML assinado
  static Map<String, String> extrairInfoCertificado(String xmlAssinado) {
    final info = <String, String>{};

    try {
      // Extrair certificado X509
      final certificado = extractTagContent(xmlAssinado, 'X509Certificate');
      if (certificado != null) {
        info['certificado'] = certificado;
      }

      // Extrair algoritmo de assinatura
      final algoritmo = extractAttributeValue(
        xmlAssinado,
        'SignatureMethod',
        'Algorithm',
      );
      if (algoritmo != null) {
        info['algoritmo_assinatura'] = algoritmo;
      }

      // Extrair algoritmo de hash
      final hash = extractAttributeValue(
        xmlAssinado,
        'DigestMethod',
        'Algorithm',
      );
      if (hash != null) {
        info['algoritmo_hash'] = hash;
      }

      // Extrair valor da assinatura
      final valorAssinatura = extractTagContent(xmlAssinado, 'SignatureValue');
      if (valorAssinatura != null) {
        info['valor_assinatura'] = valorAssinatura;
      }
    } catch (e) {
      // Ignorar erros
    }

    return info;
  }

  /// Verifica se o XML está assinado digitalmente
  static bool isXmlAssinado(String xml) {
    return xml.contains('<Signature') &&
        xml.contains('SignatureValue') &&
        xml.contains('X509Certificate');
  }

  /// Remove assinatura digital do XML
  static String removerAssinatura(String xml) {
    try {
      // Encontrar início e fim da tag Signature
      final startIndex = xml.indexOf('<Signature');
      if (startIndex == -1) return xml;

      final endIndex = xml.indexOf('</Signature>', startIndex);
      if (endIndex == -1) return xml;

      // Remover a assinatura
      return xml.substring(0, startIndex) +
          xml.substring(endIndex + 12); // 12 = length of '</Signature>'
    } catch (e) {
      return xml;
    }
  }
}
