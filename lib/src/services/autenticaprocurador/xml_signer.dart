import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:asn1lib/asn1lib.dart' as asn1;
import 'package:xml/xml.dart';
import 'model/certificate_info.dart';
import 'exceptions/autenticaprocurador_exceptions.dart';
import 'io/file_io.dart';

/// Representa um elemento ASN.1 parseado (usado na conversão BER→DER)
class _Asn1Element {
  /// Tag ASN.1 (ex: 0x30 para SEQUENCE, 0x31 para SET)
  final int tag;

  /// Conteúdo raw do elemento
  final Uint8List content;

  /// Se true, este elemento é do tipo construído (pode ter children)
  final bool isConstructed;

  /// Elementos filhos (apenas para tipos construídos)
  final List<_Asn1Element>? children;

  _Asn1Element({required this.tag, required this.content, required this.isConstructed, this.children});
}

/// Assinador digital XML conforme padrão XMLDSig ICP-Brasil
///
/// **100% Pure Dart** - Funciona em todas as plataformas (Android, iOS, Windows, Web)
///
/// Implementa assinatura digital de documentos XML seguindo:
/// - W3C XMLDSig (http://www.w3.org/2000/09/xmldsig#)
/// - Padrões ICP-Brasil para certificados e-CPF e e-CNPJ
/// - RSA-SHA256 para assinatura
/// - C14N para canonicalização
///
/// ## Formatos de certificado suportados:
/// - **PFX/P12**: Formato binário, suportado em todas as plataformas via Pure Dart
/// - **PEM**: Formato texto, suportado em todas as plataformas
///
/// ## Uso por plataforma:
/// - **Web**: Use `certificadoBase64` (conteúdo do .pfx em Base64)
/// - **Mobile/Desktop**: Use `caminhoCertificado` (path do arquivo) ou `certificadoBase64`
///
/// ## Exemplo de uso:
/// ```dart
/// final assinador = AssinadorDigitalXml(
///   certificadoBase64: 'MIIJqQIBAzCCCW8GCSqGSIb3...',
///   senhaCertificado: 'minhasenha',
/// );
/// await assinador.carregarCertificado();
/// final xmlAssinado = await assinador.assinarXml(xmlOriginal);
/// ```
class AssinadorDigitalXml {
  final String? caminhoCertificado;
  final String? certificadoBase64;
  final String senhaCertificado;

  // Dados do certificado carregados
  pc.RSAPrivateKey? _chavePrivada;
  String? _certificadoX509Base64;
  InformacoesCertificado? _infoCertificado;

  AssinadorDigitalXml({this.caminhoCertificado, this.certificadoBase64, required this.senhaCertificado}) {
    // Validar que pelo menos um dos dois foi fornecido
    if ((caminhoCertificado == null || caminhoCertificado!.isEmpty) && (certificadoBase64 == null || certificadoBase64!.isEmpty)) {
      throw ExcecaoAssinaturaCertificado('É necessário fornecer caminhoCertificado ou certificadoBase64');
    }

    // Validar que não foram fornecidos ambos
    if (caminhoCertificado != null && caminhoCertificado!.isNotEmpty && certificadoBase64 != null && certificadoBase64!.isNotEmpty) {
      throw ExcecaoAssinaturaCertificado('Forneça apenas caminhoCertificado OU certificadoBase64, não ambos');
    }
  }

  /// Assina o XML digitalmente seguindo EXATAMENTE o padrão PHP do SERPRO
  ///
  /// Processo baseado na implementação PHP de referência:
  /// 1. Carrega certificado P12/PFX
  /// 2. Canoniza o documento (C14N, sem comentários) - sobre o documentElement SEM Signature
  /// 3. Calcula digest SHA-256 do documento canonizado
  /// 4. Constrói estrutura Signature com SignedInfo contendo o DigestValue
  /// 5. Canoniza APENAS o SignedInfo
  /// 6. Assina o SignedInfo canonizado com RSA-SHA256
  /// 7. Insere SignatureValue e retorna XML completo
  Future<String> assinarXml(String conteudoXml) async {
    try {
      // 1. Carregar certificado se ainda não carregado
      if (_chavePrivada == null || _certificadoX509Base64 == null) {
        await carregarCertificado();
      }

      // 2. Parsear XML (documento SEM Signature ainda)
      final documento = XmlDocument.parse(conteudoXml);

      // 3. Canonizar o documentElement (C14N sem comentários)
      // PHP: $canonicalData = $xml->documentElement->C14N(true, false);
      final dadosCanonicalizados = _canonizarElemento(documento.rootElement);

      // 4. Calcular digest SHA-256 do documento canonizado
      // PHP: $digestValue = openssl_digest($canonicalData, "sha256", true);
      // PHP: $digestValue = base64_encode($digestValue);
      final valorDigest = _calcularDigest(dadosCanonicalizados);

      // 5. Construir estrutura Signature com SignedInfo
      final signatureXml = _construirSignatureXmlString(valorDigest);

      // 6. Adicionar Signature ao documento para poder canonizar o SignedInfo
      final docComSignature = XmlDocument.parse(conteudoXml.replaceAll('</termoDeAutorizacao>', '$signatureXml</termoDeAutorizacao>'));

      // 7. Extrair e canonizar APENAS o SignedInfo
      // PHP: $c14nSignedInfo = $signedInfoElement->C14N(true, false);
      final signedInfoElement = docComSignature.findAllElements('SignedInfo').first;
      final signedInfoCanonico = _canonizarElemento(signedInfoElement, namespacePai: 'http://www.w3.org/2000/09/xmldsig#');

      // 8. Assinar o SignedInfo canonizado com RSA-SHA256
      // PHP: openssl_sign($c14nSignedInfo, $signatureValue, $privateKey, OPENSSL_ALGO_SHA256);
      final valorAssinatura = _assinarComRsaSha256(signedInfoCanonico);

      // 9. Substituir o SignatureValue vazio pelo valor da assinatura
      final xmlFinal = docComSignature
          .toXmlString(pretty: false, indent: '')
          .replaceFirst('<SignatureValue></SignatureValue>', '<SignatureValue>$valorAssinatura</SignatureValue>');

      return xmlFinal;
    } catch (e) {
      if (e is ExcecaoAutenticaProcurador) rethrow;
      throw ExcecaoAssinaturaXml('Erro ao assinar XML: $e');
    }
  }

  /// Constrói a string XML da Signature (como no PHP com createElement)
  String _construirSignatureXmlString(String digestValue) {
    return '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
        '<SignedInfo>'
        '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
        '<SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>'
        '<Reference URI="">'
        '<Transforms>'
        '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
        '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
        '</Transforms>'
        '<DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>'
        '<DigestValue>$digestValue</DigestValue>'
        '</Reference>'
        '</SignedInfo>'
        '<SignatureValue></SignatureValue>'
        '<KeyInfo>'
        '<X509Data>'
        '<X509Certificate>$_certificadoX509Base64</X509Certificate>'
        '</X509Data>'
        '</KeyInfo>'
        '</Signature>';
  }

  /// Canoniza um elemento XML seguindo C14N (Canonical XML 1.0)
  ///
  /// Implementação que segue as regras principais de C14N:
  /// - Remove declaração XML
  /// - Expande tags self-closing para abertura/fechamento
  /// - Ordena atributos em ordem alfabética (namespace primeiro)
  /// - Usa aspas duplas para atributos
  /// - Propaga namespace para SignedInfo (para exclusive C14N)
  String _canonizarElemento(XmlElement elemento, {String? namespacePai}) {
    return _c14nElement(elemento, namespacePai: namespacePai);
  }

  /// Implementação recursiva de C14N para um elemento
  String _c14nElement(XmlElement element, {String? namespacePai}) {
    final buffer = StringBuffer();

    // Abrir tag
    buffer.write('<${element.name.qualified}');

    // Coletar atributos (incluindo namespace se houver)
    final atributos = <String, String>{};
    String? namespaceAtual;

    // Se este elemento tem um namespace xmlns herdado do pai que precisa ser declarado
    // (para exclusive C14N do SignedInfo)
    if (element.name.qualified == 'SignedInfo' && namespacePai != null) {
      atributos['xmlns'] = namespacePai;
    }

    // Adicionar atributos do elemento
    for (final attr in element.attributes) {
      atributos[attr.name.qualified] = attr.value;
      if (attr.name.qualified == 'xmlns') {
        namespaceAtual = attr.value;
      }
    }

    // Ordenar atributos: xmlns primeiro, depois alfabeticamente
    final atributosOrdenados = atributos.keys.toList()
      ..sort((a, b) {
        // xmlns sempre primeiro
        if (a == 'xmlns') return -1;
        if (b == 'xmlns') return 1;
        // outros atributos xmlns: depois
        if (a.startsWith('xmlns:') && !b.startsWith('xmlns:')) return -1;
        if (b.startsWith('xmlns:') && !a.startsWith('xmlns:')) return 1;
        // alfabético para o resto
        return a.compareTo(b);
      });

    for (final attrName in atributosOrdenados) {
      buffer.write(' $attrName="${_escapeAttrValue(atributos[attrName]!)}"');
    }

    buffer.write('>');

    // Processar filhos
    for (final child in element.children) {
      if (child is XmlElement) {
        buffer.write(_c14nElement(child, namespacePai: namespaceAtual ?? namespacePai));
      } else if (child is XmlText) {
        buffer.write(_escapeText(child.value));
      }
    }

    // Sempre fechar tag (C14N não usa self-closing tags)
    buffer.write('</${element.name.qualified}>');

    return buffer.toString();
  }

  /// Escapa caracteres especiais em valores de atributo (C14N)
  String _escapeAttrValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\t', '&#x9;')
        .replaceAll('\n', '&#xA;')
        .replaceAll('\r', '&#xD;');
  }

  /// Escapa caracteres especiais em texto (C14N)
  String _escapeText(String value) {
    return value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('\r', '&#xD;');
  }

  /// Carrega e analisa o certificado digital
  ///
  /// ## Formatos suportados:
  /// - **PFX/P12**: Parse Pure Dart em todas as plataformas
  /// - **PEM**: Parse texto em todas as plataformas
  ///
  /// ## Desktop com OpenSSL:
  /// Se OpenSSL estiver disponível, tenta conversão automática PFX->PEM
  /// para melhor compatibilidade com certificados ICP-Brasil.
  Future<void> carregarCertificado() async {
    try {
      Uint8List certificadoBytes;

      // Obter bytes do certificado
      if (certificadoBase64 != null && certificadoBase64!.isNotEmpty) {
        // Certificado em Base64 (funciona em todas as plataformas!)
        certificadoBytes = base64.decode(certificadoBase64!);
      } else if (caminhoCertificado != null && caminhoCertificado!.isNotEmpty) {
        // Certificado em arquivo (Desktop/Mobile apenas)
        if (!FileIO.isSupported) {
          throw ExcecaoAssinaturaCertificado(
            '📱 Leitura de arquivo não suportada em Web.\n'
            'Use certificadoBase64 em vez de certificadoPath.',
          );
        }

        if (!await FileIO.fileExists(caminhoCertificado!)) {
          throw ExcecaoAssinaturaCertificado('Certificado não encontrado: $caminhoCertificado');
        }
        certificadoBytes = await FileIO.readFileAsBytes(caminhoCertificado!);
      } else {
        throw ExcecaoAssinaturaCertificado('Nenhum certificado fornecido. Use certificadoBase64 ou caminhoCertificado.');
      }

      // Detectar formato: PEM (texto) ou PKCS#12 (binário)
      final certificadoTexto = utf8.decode(certificadoBytes, allowMalformed: true);
      final isPem = certificadoTexto.contains('-----BEGIN') && certificadoTexto.contains('-----END');

      _DadosPkcs12 dadosCertificado;

      if (isPem) {
        //print('✅ Detectado formato PEM');
        dadosCertificado = _extrairDePem(certificadoTexto);
      } else {
        // PKCS#12/PFX
        //print('✅ Detectado formato PKCS#12/PFX');

        // Tentar conversão via OpenSSL em Desktop (melhor compatibilidade)
        if (FileIO.isDesktop && caminhoCertificado != null) {
          final pemConvertido = await FileIO.runOpenSSLConversion(caminhoCertificado!, senhaCertificado);

          if (pemConvertido != null) {
            //print('✅ Convertido para PEM usando OpenSSL');
            dadosCertificado = _extrairDePem(pemConvertido);
          } else {
            // Fallback para parse Pure Dart
            //print('⚠️  OpenSSL não disponível, usando parser Pure Dart');
            dadosCertificado = _extrairPkcs12PureDart(certificadoBytes, senhaCertificado);
          }
        } else {
          // Web/Mobile: usar parser Pure Dart diretamente
          dadosCertificado = _extrairPkcs12PureDart(certificadoBytes, senhaCertificado);
        }
      }

      _chavePrivada = dadosCertificado.chavePrivada;
      _certificadoX509Base64 = dadosCertificado.certificado;
      _infoCertificado = dadosCertificado.info;

      if (!_infoCertificado!.isValido) {
        throw ExcecaoAssinaturaCertificado(
          'Certificado fora da validade. Válido de ${_infoCertificado!.validoDe} até ${_infoCertificado!.validoAte}',
        );
      }

      // print('✅ Certificado carregado: ${_infoCertificado!.nomeExibicao}');
      // print('   Válido até: ${_infoCertificado!.validoAte}');
      // print('   Dias restantes: ${_infoCertificado!.diasRestantes}');
    } catch (e) {
      if (e is ExcecaoAutenticaProcurador) rethrow;

      final certSource = certificadoBase64 != null ? 'Base64 (${certificadoBase64!.length} chars)' : caminhoCertificado ?? 'desconhecido';

      throw ExcecaoAssinaturaCertificado(
        'Erro ao carregar certificado.\n'
        'Fonte: $certSource\n'
        'Erro: $e',
      );
    }
  }

  /// Retorna informações do certificado
  Future<InformacoesCertificado> obterInformacoesCertificado() async {
    if (_infoCertificado == null) {
      await carregarCertificado();
    }
    return _infoCertificado!;
  }

  /// Calcula o digest SHA-256 e retorna em base64
  String _calcularDigest(String dados) {
    final bytes = utf8.encode(dados);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  /// Assina dados com RSA-SHA256
  String _assinarComRsaSha256(String dados) {
    try {
      // Criar assinador RSA-SHA256
      final assinador = pc.Signer('SHA-256/RSA');
      assinador.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(_chavePrivada!));

      // Converter dados para bytes
      final dadosBytes = utf8.encode(dados);

      // Gerar assinatura
      final assinatura = assinador.generateSignature(Uint8List.fromList(dadosBytes)) as pc.RSASignature;

      // Retornar em base64
      return base64.encode(assinatura.bytes);
    } catch (e) {
      throw ExcecaoAssinaturaXml('Erro ao gerar assinatura RSA-SHA256: $e');
    }
  }

  /// Extrai chave privada e certificado de formato PEM
  _DadosPkcs12 _extrairDePem(String pemText) {
    try {
      pc.RSAPrivateKey? chavePrivada;
      String? certificadoBase64;

      // Procurar pela chave privada (vários formatos possíveis)
      final privateKeyRegex = RegExp(
        r'-----BEGIN (?:RSA )?PRIVATE KEY-----\s*([A-Za-z0-9+/=\s]+)\s*-----END (?:RSA )?PRIVATE KEY-----',
        multiLine: true,
      );

      final privateKeyMatch = privateKeyRegex.firstMatch(pemText);
      if (privateKeyMatch != null) {
        final privateKeyB64 = privateKeyMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
        final privateKeyBytes = base64.decode(privateKeyB64);
        chavePrivada = _parsePrivateKeyFromDer(privateKeyBytes);
      }

      // Procurar pelo certificado
      final certRegex = RegExp(r'-----BEGIN CERTIFICATE-----\s*([A-Za-z0-9+/=\s]+)\s*-----END CERTIFICATE-----', multiLine: true);

      final certMatch = certRegex.firstMatch(pemText);
      if (certMatch != null) {
        certificadoBase64 = certMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
      }

      if (chavePrivada == null) {
        throw ExcecaoAssinaturaCertificado('Chave privada não encontrada no PEM');
      }

      if (certificadoBase64 == null) {
        throw ExcecaoAssinaturaCertificado('Certificado não encontrado no PEM');
      }

      // Extrair informações do certificado
      final infoCert = _extrairInformacoesCertificadoDeBytes(base64.decode(certificadoBase64));

      return _DadosPkcs12(chavePrivada: chavePrivada, certificado: certificadoBase64, info: infoCert);
    } catch (e) {
      if (e is ExcecaoAutenticaProcurador) rethrow;
      throw ExcecaoAssinaturaCertificado('Erro ao processar PEM: $e');
    }
  }

  /// Parse chave privada DER (PKCS#8 ou PKCS#1)
  pc.RSAPrivateKey _parsePrivateKeyFromDer(Uint8List derBytes) {
    try {
      final parser = asn1.ASN1Parser(derBytes);
      final sequence = parser.nextObject() as asn1.ASN1Sequence;

      // Verificar se é PKCS#8 (tem version + algorithm + privateKey)
      // ou PKCS#1 (tem version + modulus + exponents diretamente)
      if (sequence.elements.length >= 3 && sequence.elements[1] is asn1.ASN1Sequence) {
        // PKCS#8 format
        final privateKeyOctet = sequence.elements[2] as asn1.ASN1OctetString;
        final privateKeyBytes = privateKeyOctet.valueBytes();
        final rsaParser = asn1.ASN1Parser(privateKeyBytes);
        final rsaSequence = rsaParser.nextObject() as asn1.ASN1Sequence;
        return _parseRsaPrivateKey(rsaSequence);
      } else {
        // PKCS#1 format (RSAPrivateKey direto)
        return _parseRsaPrivateKey(sequence);
      }
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro ao parsear chave privada: $e');
    }
  }

  /// Parse RSAPrivateKey ASN.1 sequence
  pc.RSAPrivateKey _parseRsaPrivateKey(asn1.ASN1Sequence rsaSequence) {
    final modulus = (rsaSequence.elements[1] as asn1.ASN1Integer).valueAsBigInteger;
    final privateExponent = (rsaSequence.elements[3] as asn1.ASN1Integer).valueAsBigInteger;
    final p = (rsaSequence.elements[4] as asn1.ASN1Integer).valueAsBigInteger;
    final q = (rsaSequence.elements[5] as asn1.ASN1Integer).valueAsBigInteger;

    return pc.RSAPrivateKey(modulus, privateExponent, p, q);
  }

  /// Converte BER com comprimento indefinido para DER com comprimento definido
  ///
  /// BER permite comprimento indefinito (0x80) terminado por 0x00 0x00
  /// DER requer comprimento definido
  /// asn1lib não suporta BER indefinido, então precisamos converter
  ///
  /// Esta implementação completa:
  /// 1. Detecta se há comprimento indefinido no buffer
  /// 2. Faz parsing recursivo da estrutura ASN.1
  /// 3. Re-codifica em DER com comprimentos definidos
  /// 4. Retorna bytes originais se já estiver em DER ou se conversão falhar
  ///
  /// Performance:
  /// - DER puro (sem conversão): O(n) scan, <1ms para certs típicos
  /// - Conversão completa: O(n) parse + encode, <10ms para certs típicos
  Uint8List _converterBerParaDer(Uint8List berBytes) {
    // Validação básica
    if (berBytes.isEmpty) {
      return berBytes;
    }

    // Otimização: bailout rápido se não há indefinite length
    if (!_containsIndefiniteLength(berBytes)) {
      return berBytes;
    }

    try {
      // Parse estrutura completa
      final element = _parseAsn1Element(berBytes, 0);

      // Re-encode em DER
      final derBytes = _encodeAsn1Element(element);

      // Validação de sanidade: output não deve ser muito maior que input
      // (um pouco maior é OK devido a length encoding, mas não 2x+)
      if (derBytes.length > berBytes.length * 2) {
        throw ExcecaoAssinaturaCertificado(
          'Conversão BER→DER resultou em output inesperadamente grande.\n'
          'Tamanho original: ${berBytes.length} bytes\n'
          'Tamanho convertido: ${derBytes.length} bytes\n'
          'Possível corrupção de dados.',
        );
      }

      // Debug: log conversão
      // ignore: avoid_print
      print('[BER→DER] Convertido: ${berBytes.length} → ${derBytes.length} bytes');
      // ignore: avoid_print
      print('[BER→DER] Original: ${berBytes.sublist(0, 20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      // ignore: avoid_print
      print('[BER→DER] Converted: ${derBytes.sublist(0, 20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      return derBytes;
    } catch (e) {
      // Debug: log erro
      // ignore: avoid_print
      print('[BER→DER] Erro na conversão: $e');

      // Degradação graceful: retorna bytes originais
      // Isso pode acontecer quando tentamos converter dados encriptados
      // que NÃO são estruturas ASN.1 válidas.
      // Retornar os bytes originais é seguro - se realmente forem ASN.1 inválidos,
      // o erro será detectado depois no fluxo normal.

      // SEMPRE retornar bytes originais em caso de erro, não re-lançar
      // Isso permite que dados encriptados passem sem problemas
      return berBytes;
    }
  }

  /// Extrai chave e certificado de PKCS12 usando Pure Dart
  ///
  /// Compatível com Web, Desktop e Mobile
  _DadosPkcs12 _extrairPkcs12PureDart(Uint8List pkcs12Bytes, String senha) {
    try {
      // Converter BER indefinite length para DER definite length se necessário
      // Alguns certificados PKCS#12 usam BER com comprimento indefinito (0x80)
      // que a biblioteca asn1lib não suporta
      final derBytes = _converterBerParaDer(pkcs12Bytes);

      // Parse PKCS#12 usando asn1lib
      // ignore: avoid_print
      print('[Debug] Fazendo parse com asn1lib, ${derBytes.length} bytes');
      // ignore: avoid_print
      print('[Debug] Primeiros bytes: ${derBytes.sublist(0, 10).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');

      final parser = asn1.ASN1Parser(derBytes);
      var pfxObject = parser.nextObject();

      // ignore: avoid_print
      print('[Debug] Parse OK! Tipo: ${pfxObject.runtimeType}');

      // Alguns PKCS#12 vêm encapsulados em ASN1Application
      if (pfxObject is asn1.ASN1Application) {
        // ASN1Application em asn1lib já fornece valueBytes() que extrai o conteúdo
        // Tentar usar método built-in primeiro
        try {
          final contentBytes = (pfxObject as dynamic).valueBytes();
          if (contentBytes != null && contentBytes is Uint8List && contentBytes.isNotEmpty) {
            final innerParser = asn1.ASN1Parser(contentBytes);
            pfxObject = innerParser.nextObject();
          } else {
            // Fallback para extração manual
            final appBytes = pfxObject.encodedBytes;
            if (appBytes.length < 2) {
              throw ExcecaoAssinaturaCertificado('ASN1Application muito pequeno: ${appBytes.length} bytes');
            }

            final offset = _decodificarComprimentoAsn1Seguro(appBytes, 'ASN1Application (PFX wrapper)');

            if (offset >= appBytes.length) {
              throw ExcecaoAssinaturaCertificado('ASN1Application: offset $offset >= tamanho ${appBytes.length}');
            }

            final innerParser = asn1.ASN1Parser(Uint8List.sublistView(appBytes, offset));
            pfxObject = innerParser.nextObject();
          }
        } catch (e) {
          // Se valueBytes() não existir, fazer extração manual
          final appBytes = pfxObject.encodedBytes;
          if (appBytes.length < 2) {
            throw ExcecaoAssinaturaCertificado('ASN1Application muito pequeno: ${appBytes.length} bytes');
          }

          final offset = _decodificarComprimentoAsn1Seguro(appBytes, 'ASN1Application (PFX wrapper)');

          if (offset >= appBytes.length) {
            throw ExcecaoAssinaturaCertificado('ASN1Application: offset $offset >= tamanho ${appBytes.length}');
          }

          final innerParser = asn1.ASN1Parser(Uint8List.sublistView(appBytes, offset));
          pfxObject = innerParser.nextObject();
        }
      }

      if (pfxObject is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado('PKCS#12 inválido: objeto raiz não é Sequence');
      }

      final pfxSequence = pfxObject;

      // ignore: avoid_print
      print('[Debug] pfxSequence.elements.length = ${pfxSequence.elements.length}');

      // Validar que a sequência tem elementos suficientes
      if (pfxSequence.elements.isEmpty) {
        // Verificar se é um certificado com BER indefinite length
        if (pkcs12Bytes.length >= 2 && pkcs12Bytes[0] == 0x30 && pkcs12Bytes[1] == 0x80) {
          throw ExcecaoAssinaturaCertificado(
            'Certificado PKCS#12 usa codificação BER com comprimento indefinido.\n'
            'Esta codificação não é suportada pelo parser Pure Dart.\n'
            '\n'
            'SOLUÇÃO:\n'
            '  Opção 1: Use certificadoDigitalPath em vez de certificadoDigitalBase64\n'
            '           (OpenSSL será usado automaticamente no desktop)\n'
            '\n'
            '  Opção 2: Converta o certificado para DER:\n'
            '           openssl pkcs12 -in cert.pfx -out cert_der.pfx -export\n'
            '\n'
            '  Opção 3: Extraia para PEM e use PEM:\n'
            '           openssl pkcs12 -in cert.pfx -out cert.pem -nodes',
          );
        }

        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: PFX Sequence vazia.\n'
          'Tipo do objeto: ${pfxObject.runtimeType}\n'
          'Encoded bytes length: ${pfxObject.encodedBytes.length}\n'
          'Possíveis causas:\n'
          '  • Senha incorreta\n'
          '  • Certificado corrompido\n'
          '  • Estrutura PKCS#12 não padrão',
        );
      }

      if (pfxSequence.elements.length < 2) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: PFX Sequence incompleta.\n'
          'Esperado: mínimo 2 elementos (version + authSafe)\n'
          'Recebido: ${pfxSequence.elements.length} elemento(s)',
        );
      }

      // Verificar versão (deve ser 3)
      // ignore: avoid_print
      print('[Debug] Verificando versão (element[0] tipo: ${pfxSequence.elements[0].runtimeType})');

      if (pfxSequence.elements[0] is! asn1.ASN1Integer) {
        throw ExcecaoAssinaturaCertificado('PKCS#12 version não é Integer');
      }

      final version = (pfxSequence.elements[0] as asn1.ASN1Integer).intValue;
      // ignore: avoid_print
      print('[Debug] Versão: $version');
      if (version != 3) {
        throw ExcecaoAssinaturaCertificado('Versão PKCS#12 não suportada: $version');
      }

      // AuthSafe ContentInfo
      // ignore: avoid_print
      print('[Debug] authSafeContentInfo tipo: ${pfxSequence.elements[1].runtimeType}');

      if (pfxSequence.elements[1] is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado('AuthSafe ContentInfo não é Sequence');
      }

      final authSafeContentInfo = pfxSequence.elements[1] as asn1.ASN1Sequence;
      // ignore: avoid_print
      print('[Debug] authSafeContentInfo.elements.length = ${authSafeContentInfo.elements.length}');

      // ignore: avoid_print
      print('[Debug] authSafe[0] tipo: ${authSafeContentInfo.elements[0].runtimeType}');

      if (authSafeContentInfo.elements[0] is! asn1.ASN1ObjectIdentifier) {
        throw ExcecaoAssinaturaCertificado('AuthSafe OID não é ObjectIdentifier');
      }

      final authSafeOid = (authSafeContentInfo.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

      // ignore: avoid_print
      print('[Debug] authSafeOid: $authSafeOid');

      if (authSafeOid != '1.2.840.113549.1.7.1') {
        throw ExcecaoAssinaturaCertificado('PKCS#12 authSafe OID não suportado: $authSafeOid');
      }

      // Extrair conteúdo do AuthSafe
      final authSafeContext = authSafeContentInfo.elements[1];
      // ignore: avoid_print
      print('[Debug] authSafeContext tipo: ${authSafeContext.runtimeType}');

      Uint8List authSafeOctetBytes;

      if (authSafeContext is asn1.ASN1OctetString) {
        // ignore: avoid_print
        print('[Debug] authSafeContext é ASN1OctetString');
        authSafeOctetBytes = authSafeContext.valueBytes();
      } else {
        // ignore: avoid_print
        print('[Debug] authSafeContext NÃO é ASN1OctetString, usando parser manual');
        final authSafeBytes = authSafeContext.encodedBytes;
        final offset = _decodificarComprimentoAsn1Seguro(authSafeBytes, 'AuthSafe CONTEXT_SPECIFIC');
        // ignore: avoid_print
        print('[Debug] Offset calculado: $offset, total bytes: ${authSafeBytes.length}');

        // IMPORTANTE: innerBytes pode ter estruturas BER aninhadas!
        // A conversão inicial (raiz) pode não ter convertido estruturas muito aninhadas
        var innerBytes = Uint8List.sublistView(authSafeBytes, offset);
        // ignore: avoid_print
        print('[Debug] innerBytes[0-1]: 0x${innerBytes[0].toRadixString(16)} 0x${innerBytes[1].toRadixString(16)}');

        // Se tag 0x24 (APPLICATION/CONTEXT constructed), converter conteúdo
        if (innerBytes[0] == 0x24 && innerBytes.length > 2) {
          // ignore: avoid_print
          print('[Debug] Tag 0x24 detectada, convertendo BER→DER...');
          innerBytes = _converterBerParaDer(innerBytes);
          // ignore: avoid_print
          print(
            '[Debug] innerBytes convertido: ${innerBytes.length} bytes, [0-1]: 0x${innerBytes[0].toRadixString(16)} 0x${innerBytes[1].toRadixString(16)}',
          );
        }

        // Tag 0x24 é CONTEXT_SPECIFIC não padrão que asn1lib pode não reconhecer
        // Extrair conteúdo manualmente sem fazer parse
        try {
          // Tentar fazer parse normalmente primeiro
          final innerParser = asn1.ASN1Parser(innerBytes);
          final parsedObject = innerParser.nextObject();
          // ignore: avoid_print
          print('[Debug] Parsed object tipo: ${parsedObject.runtimeType}');

          // Pode ser ASN1OctetString ou outro tipo (CONTEXT_SPECIFIC, APPLICATION)
          if (parsedObject is asn1.ASN1OctetString) {
            authSafeOctetBytes = parsedObject.valueBytes();
          } else {
            // Se não for OctetString, tentar extrair manualmente
            final bytes = parsedObject.encodedBytes;
            final contentOffset = _decodificarComprimentoAsn1Seguro(bytes, 'CONTEXT[0]');
            authSafeOctetBytes = Uint8List.sublistView(bytes, contentOffset);
          }

          // ignore: avoid_print
          print('[Debug] Parse inner OK! authSafeOctetBytes: ${authSafeOctetBytes.length}');
        } catch (e) {
          // ignore: avoid_print
          print('[Debug] ERRO no parse inner, extraindo manualmente: $e');

          // Fallback: extrair conteúdo manualmente sem usar asn1lib
          // Tag (1 byte) + Length (variável) + Content
          final contentOffset = _decodificarComprimentoAsn1Seguro(innerBytes, 'Inner CONTEXT_SPECIFIC manual');
          authSafeOctetBytes = Uint8List.sublistView(innerBytes, contentOffset);

          // ignore: avoid_print
          print('[Debug] Extração manual OK! authSafeOctetBytes: ${authSafeOctetBytes.length}');
        }
      }

      // ignore: avoid_print
      print('[Debug] authSafeOctetBytes length: ${authSafeOctetBytes.length}');

      // authSafeOctetBytes pode conter MAIS estruturas BER aninhadas!
      // A conversão recursiva deve ter convertido, mas vamos garantir
      // aplicando conversão novamente (idempotente para DER)
      // ignore: avoid_print
      print(
        '[Debug] authSafeOctetBytes primeiros 20 bytes: ${authSafeOctetBytes.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      // Verificar se há múltiplos objetos em authSafeOctetBytes
      if (authSafeOctetBytes.length > 1100 && authSafeOctetBytes[0] == 0x04) {
        // ignore: avoid_print
        print('[Debug] Verificando estrutura em offset 1004...');
        // ignore: avoid_print
        print('[Debug] Bytes 1004-1024: ${authSafeOctetBytes.sublist(1004, 1024).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }

      var authSafeDer = _converterBerParaDer(authSafeOctetBytes);

      // ignore: avoid_print
      print('[Debug] authSafeDer length: ${authSafeDer.length}');
      // ignore: avoid_print
      print('[Debug] authSafeDer primeiros 20 bytes: ${authSafeDer.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      // IMPORTANTE: authSafeDer pode começar com OCTET STRING, mas o conteúdo
      // dessa OCTET STRING pode ser BER! Precisamos converter O CONTEÚDO também
      // Vamos verificar se começa com OCTET STRING (tag 0x04)
      if (authSafeDer[0] == 0x04) {
        // É OCTET STRING - extrair conteúdo e converter
        // ignore: avoid_print
        print('[Debug] authSafeDer começa com OCTET STRING, extraindo e convertendo conteúdo...');

        final tempParser = asn1.ASN1Parser(authSafeDer);
        final tempOctetString = tempParser.nextObject() as asn1.ASN1OctetString;
        final octetContent = tempOctetString.valueBytes();

        // ignore: avoid_print
        print('[Debug] Conteúdo do OCTET STRING: ${octetContent.length} bytes');
        // ignore: avoid_print
        print('[Debug] Primeiros 20 bytes do conteúdo: ${octetContent.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

        // Converter o CONTEÚDO da OCTET STRING (que pode ter BER)
        final contentDer = _converterBerParaDer(octetContent);

        // ignore: avoid_print
        print('[Debug] Conteúdo convertido: ${contentDer.length} bytes');

        // Re-empacotar em OCTET STRING DER
        final newOctetString = asn1.ASN1OctetString(contentDer);
        authSafeDer = newOctetString.encodedBytes;

        // ignore: avoid_print
        print('[Debug] OCTET STRING re-empacotada: ${authSafeDer.length} bytes');
      }

      final authSafeParser = asn1.ASN1Parser(authSafeDer);
      // ignore: avoid_print
      print('[Debug] Fazendo parse do authSafeObject...');
      var authSafeObject = authSafeParser.nextObject();
      // ignore: avoid_print
      print('[Debug] authSafeObject tipo: ${authSafeObject.runtimeType}');

      if (authSafeObject is asn1.ASN1OctetString) {
        // ignore: avoid_print
        print('[Debug] authSafeObject é OCTET STRING com encoded length: ${authSafeObject.encodedBytes.length}');
      }

      // Se for OCTET STRING, extrair o conteúdo interno
      if (authSafeObject is asn1.ASN1OctetString) {
        // ignore: avoid_print
        print('[Debug] authSafeObject é OCTET STRING, extraindo conteúdo...');
        final innerBytes = authSafeObject.valueBytes();
        // ignore: avoid_print
        print('[Debug] innerBytes length: ${innerBytes.length}');
        // ignore: avoid_print
        print('[Debug] innerBytes primeiros 20 bytes: ${innerBytes.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

        // IMPORTANTE: innerBytes pode conter estruturas ASN.1 aninhadas com BER!
        // Precisamos converter BER→DER aqui também
        final innerDer = _converterBerParaDer(innerBytes);
        final innerParser = asn1.ASN1Parser(innerDer);
        authSafeObject = innerParser.nextObject();
        // ignore: avoid_print
        print('[Debug] Conteúdo interno tipo: ${authSafeObject.runtimeType}');

        if (authSafeObject is asn1.ASN1Sequence) {
          // ignore: avoid_print
          print('[Debug] AuthSafe SEQUENCE tem ${authSafeObject.elements.length} elementos');
        }
      }

      if (authSafeObject is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado('AuthSafe não é uma Sequence');
      }

      final authSafeSequence = authSafeObject;

      pc.RSAPrivateKey? chavePrivada;
      String? certificadoBase64;

      // ignore: avoid_print
      print('[Debug] Processando ${authSafeSequence.elements.length} elementos no AuthSafe...');

      for (var element in authSafeSequence.elements) {
        if (element is! asn1.ASN1Sequence) {
          // ignore: avoid_print
          print('[Debug] Elemento ignorado: não é ASN1Sequence (${element.runtimeType})');
          continue;
        }

        final contentInfo = element;
        if (contentInfo.elements.isEmpty) {
          // ignore: avoid_print
          print('[Debug] ContentInfo vazio, ignorando');
          continue;
        }
        if (contentInfo.elements[0] is! asn1.ASN1ObjectIdentifier) {
          // ignore: avoid_print
          print('[Debug] Primeiro elemento não é OID: ${contentInfo.elements[0].runtimeType}');
          continue;
        }

        final contentType = (contentInfo.elements[0] as asn1.ASN1ObjectIdentifier).identifier;
        // ignore: avoid_print
        print('[Debug] Processando contentType: $contentType');

        if (contentType == '1.2.840.113549.1.7.1') {
          // Data - contém bags não encriptados
          // ignore: avoid_print
          print('[Debug] → Processando Data (não encriptado)...');
          final result = _processarDataContent(contentInfo, senha);
          chavePrivada ??= result.chavePrivada;
          certificadoBase64 ??= result.certificado;
          // ignore: avoid_print
          print('[Debug] → Resultado: chave=${result.chavePrivada != null}, cert=${result.certificado != null}');
        } else if (contentType == '1.2.840.113549.1.7.6') {
          // EncryptedData - contém dados encriptados
          // ignore: avoid_print
          print('[Debug] → Processando EncryptedData...');
          final result = _processarEncryptedData(contentInfo, senha);
          chavePrivada ??= result.chavePrivada;
          certificadoBase64 ??= result.certificado;
          // ignore: avoid_print
          print('[Debug] → Resultado: chave=${result.chavePrivada != null}, cert=${result.certificado != null}');
        } else {
          // ignore: avoid_print
          print('[Debug] → ContentType desconhecido, ignorando');
        }
      }

      // ignore: avoid_print
      print(
        '[Debug] Finalizado processamento. ChavePrivada encontrada: ${chavePrivada != null}, Certificado encontrado: ${certificadoBase64 != null}',
      );

      if (chavePrivada == null) {
        throw ExcecaoAssinaturaCertificado(
          'Chave privada não encontrada no PKCS#12. '
          'Verifique se a senha está correta.',
        );
      }

      if (certificadoBase64 == null) {
        throw ExcecaoAssinaturaCertificado('Certificado não encontrado no PKCS#12');
      }

      final infoCert = _extrairInformacoesCertificadoDeBytes(base64.decode(certificadoBase64));

      return _DadosPkcs12(chavePrivada: chavePrivada, certificado: certificadoBase64, info: infoCert);
    } catch (e) {
      if (e is ExcecaoAutenticaProcurador) rethrow;
      if (e is ExcecaoAssinaturaCertificado) rethrow;

      // Adicionar informação de stack trace para debug
      throw ExcecaoAssinaturaCertificado(
        'Erro ao processar certificado PKCS#12.\n'
        '\n'
        'Erro original: $e\n'
        '\n'
        'Diagnóstico:\n'
        '  1. Verifique se a senha está correta\n'
        '  2. Confirme que é um certificado PKCS#12 válido (.pfx/.p12)\n'
        '  3. Teste abrindo com: openssl pkcs12 -info -in cert.pfx',
      );
    }
  }

  /// Processa conteúdo Data (não encriptado) do PKCS#12
  _DadosParciais _processarDataContent(asn1.ASN1Sequence contentInfo, String senha) {
    pc.RSAPrivateKey? chavePrivada;
    String? certificadoBase64;

    if (contentInfo.elements.length < 2) {
      return _DadosParciais();
    }

    Uint8List bagsBytes;
    final content = contentInfo.elements[1];

    if (content is asn1.ASN1OctetString) {
      bagsBytes = content.valueBytes();
    } else {
      final contentBytes = content.encodedBytes;
      final offset = _decodificarComprimentoAsn1Seguro(contentBytes, 'Data ContentInfo');
      final innerParser = asn1.ASN1Parser(Uint8List.sublistView(contentBytes, offset));
      final contentOctet = innerParser.nextObject() as asn1.ASN1OctetString;
      bagsBytes = contentOctet.valueBytes();
    }

    final bagsParser = asn1.ASN1Parser(bagsBytes);
    final bagsSequence = bagsParser.nextObject() as asn1.ASN1Sequence;

    for (var bag in bagsSequence.elements) {
      if (bag is! asn1.ASN1Sequence) continue;

      final safeBag = bag;
      if (safeBag.elements.isEmpty) continue;
      if (safeBag.elements[0] is! asn1.ASN1ObjectIdentifier) continue;

      final bagId = (safeBag.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

      if (bagId == '1.2.840.113549.1.12.10.1.1') {
        // KeyBag - chave privada NÃO encriptada
        chavePrivada = _extrairChavePrivadaDeBag(safeBag);
      } else if (bagId == '1.2.840.113549.1.12.10.1.2') {
        // PKCS8ShroudedKeyBag - chave privada ENCRIPTADA
        chavePrivada = _descriptografarChavePrivada(safeBag, senha);
      } else if (bagId == '1.2.840.113549.1.12.10.1.3') {
        // CertBag - certificado
        certificadoBase64 = _extrairCertificadoDeBag(safeBag);
      }
    }

    return _DadosParciais(chavePrivada: chavePrivada, certificado: certificadoBase64);
  }

  /// Processa conteúdo EncryptedData do PKCS#12
  _DadosParciais _processarEncryptedData(asn1.ASN1Sequence contentInfo, String senha) {
    pc.RSAPrivateKey? chavePrivada;
    String? certificadoBase64;

    try {
      if (contentInfo.elements.length < 2) {
        return _DadosParciais();
      }

      final encryptedDataContext = contentInfo.elements[1];
      final encryptedDataBytes = _extrairBytesDeContextSpecific(encryptedDataContext);

      final encryptedDataParser = asn1.ASN1Parser(encryptedDataBytes);
      final encryptedData = encryptedDataParser.nextObject() as asn1.ASN1Sequence;

      final encryptedContentInfo = encryptedData.elements[1] as asn1.ASN1Sequence;
      final algorithmSeq = encryptedContentInfo.elements[1] as asn1.ASN1Sequence;
      final encryptedContentContext = encryptedContentInfo.elements[2];

      final algorithmOid = (algorithmSeq.elements[0] as asn1.ASN1ObjectIdentifier).identifier!;
      final algorithmParams = algorithmSeq.elements[1] as asn1.ASN1Sequence;

      final encryptedContentBytes = _extrairBytesDeContextSpecific(encryptedContentContext, isOctetString: true);

      final decryptedBytes = _pbeDecrypt(algorithmOid, algorithmParams, encryptedContentBytes, senha);

      final bagsParser = asn1.ASN1Parser(decryptedBytes);
      final bagsSequence = bagsParser.nextObject() as asn1.ASN1Sequence;

      for (var bag in bagsSequence.elements) {
        if (bag is! asn1.ASN1Sequence) continue;

        final safeBag = bag;
        if (safeBag.elements.isEmpty) continue;
        if (safeBag.elements[0] is! asn1.ASN1ObjectIdentifier) continue;

        final bagId = (safeBag.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

        if (bagId == '1.2.840.113549.1.12.10.1.1') {
          chavePrivada = _extrairChavePrivadaDeBag(safeBag);
        } else if (bagId == '1.2.840.113549.1.12.10.1.2') {
          chavePrivada = _descriptografarChavePrivada(safeBag, senha);
        } else if (bagId == '1.2.840.113549.1.12.10.1.3') {
          certificadoBase64 = _extrairCertificadoDeBag(safeBag);
        }
      }
    } catch (e) {
      // Ignorar erros e continuar
    }

    return _DadosParciais(chavePrivada: chavePrivada, certificado: certificadoBase64);
  }

  /// Descriptografa chave privada de PKCS8ShroudedKeyBag
  pc.RSAPrivateKey _descriptografarChavePrivada(asn1.ASN1Sequence safeBag, String senha) {
    try {
      if (safeBag.elements.length < 2) {
        throw ExcecaoAssinaturaCertificado('SafeBag incompleto');
      }

      final encryptedKeyContext = safeBag.elements[1];
      final encryptedKeyBytes = _extrairBytesDeContextSpecific(encryptedKeyContext);

      final encryptedKeyParser = asn1.ASN1Parser(encryptedKeyBytes);
      final encryptedPrivateKeyInfo = encryptedKeyParser.nextObject() as asn1.ASN1Sequence;

      if (encryptedPrivateKeyInfo.elements.length < 2) {
        throw ExcecaoAssinaturaCertificado('EncryptedPrivateKeyInfo incompleto');
      }

      final algorithmSeq = encryptedPrivateKeyInfo.elements[0] as asn1.ASN1Sequence;
      final encryptedDataOctet = encryptedPrivateKeyInfo.elements[1] as asn1.ASN1OctetString;

      final algorithmOid = (algorithmSeq.elements[0] as asn1.ASN1ObjectIdentifier).identifier!;
      final algorithmParams = algorithmSeq.elements[1] as asn1.ASN1Sequence;

      final decryptedBytes = _pbeDecrypt(algorithmOid, algorithmParams, encryptedDataOctet.valueBytes(), senha);

      final keyParser = asn1.ASN1Parser(decryptedBytes);
      final privateKeyInfo = keyParser.nextObject() as asn1.ASN1Sequence;

      final privateKeyOctet = privateKeyInfo.elements[2] as asn1.ASN1OctetString;
      final rsaParser = asn1.ASN1Parser(privateKeyOctet.valueBytes());
      final rsaSequence = rsaParser.nextObject() as asn1.ASN1Sequence;

      return _parseRsaPrivateKey(rsaSequence);
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro ao descriptografar chave privada: $e');
    }
  }

  /// Extrai bytes de CONTEXT_SPECIFIC tag
  Uint8List _extrairBytesDeContextSpecific(asn1.ASN1Object context, {bool isOctetString = false}) {
    final bytes = context.encodedBytes;
    final contexto = isOctetString ? 'CONTEXT_SPECIFIC OctetString' : 'CONTEXT_SPECIFIC';

    final offset = _decodificarComprimentoAsn1Seguro(bytes, contexto);

    // Validação adicional: verificar se há conteúdo após o offset
    if (offset >= bytes.length) {
      throw ExcecaoAssinaturaCertificado(
        'PKCS#12 inválido: Sem conteúdo em $contexto.\n'
        'Offset: $offset\n'
        'Tamanho buffer: ${bytes.length}',
      );
    }

    return Uint8List.sublistView(bytes, offset);
  }

  /// Decodifica o comprimento DER de um objeto ASN.1 de forma segura
  /// com validação completa de bounds.
  ///
  /// Retorna o offset após tag + length encoding.
  /// Lança ExcecaoAssinaturaCertificado com diagnóstico detalhado em caso de erro.
  int _decodificarComprimentoAsn1Seguro(Uint8List bytes, String contexto) {
    // Validação 1: Buffer mínimo (tag + length)
    if (bytes.length < 2) {
      throw ExcecaoAssinaturaCertificado(
        'PKCS#12 inválido: Buffer muito pequeno ao processar $contexto.\n'
        'Esperado: mínimo 2 bytes (tag + length)\n'
        'Recebido: ${bytes.length} byte(s)\n'
        'Possíveis causas:\n'
        '  • Certificado corrompido\n'
        '  • Senha incorreta (descriptografia falhou)\n'
        '  • Formato ASN.1 malformado',
      );
    }

    int offset = 2;

    // Long form: bit 7 = 1
    if ((bytes[1] & 0x80) != 0) {
      final lengthOfLength = bytes[1] & 0x7F;

      // Caso especial: 0x80 = indefinite length (BER encoding)
      // Não podemos calcular offset neste caso, apenas retornar 2
      if (lengthOfLength == 0) {
        // Comprimento indefinido - retorna offset mínimo
        // O parser ASN.1 deve lidar com isto
        return 2;
      }

      // Validação 2: lengthOfLength razoável (máx 4 para DER)
      if (lengthOfLength > 4) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: Length encoding incorreto em $contexto.\n'
          'Length-of-length: $lengthOfLength (deve ser 1-4)\n'
          'Byte: 0x${bytes[1].toRadixString(16).padLeft(2, '0')}\n'
          'Possíveis causas:\n'
          '  • Senha incorreta\n'
          '  • Certificado corrompido',
        );
      }

      offset = 1 + 1 + lengthOfLength;

      // Validação 3: Buffer suficiente para header
      if (bytes.length < offset) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: Buffer insuficiente para header ASN.1 em $contexto.\n'
          'Length-of-length: $lengthOfLength bytes\n'
          'Tamanho buffer: ${bytes.length} bytes\n'
          'Offset calculado: $offset bytes\n'
          'Faltam: ${offset - bytes.length} byte(s)',
        );
      }

      // Validação 4: Decodificar e validar comprimento total
      int comprimento = 0;
      for (int i = 0; i < lengthOfLength; i++) {
        comprimento = (comprimento << 8) | bytes[2 + i];
      }

      final tamanhoTotal = offset + comprimento;
      if (bytes.length < tamanhoTotal) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: Conteúdo truncado em $contexto.\n'
          'Comprimento declarado: $comprimento bytes\n'
          'Tamanho buffer: ${bytes.length} bytes\n'
          'Offset header: $offset bytes\n'
          'Total esperado: $tamanhoTotal bytes\n'
          'Faltam: ${tamanhoTotal - bytes.length} byte(s)',
        );
      }
    } else {
      // Short form: validar conteúdo
      final comprimento = bytes[1];
      final tamanhoTotal = 2 + comprimento;

      if (bytes.length < tamanhoTotal) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: Conteúdo truncado em $contexto.\n'
          'Comprimento: $comprimento bytes\n'
          'Buffer: ${bytes.length} bytes\n'
          'Esperado: $tamanhoTotal bytes',
        );
      }
    }

    return offset;
  }

  /// Descriptografia PBE (Password Based Encryption)
  Uint8List _pbeDecrypt(String algorithmOid, asn1.ASN1Sequence params, Uint8List encryptedData, String senha) {
    if (params.elements.isEmpty) {
      throw ExcecaoAssinaturaCertificado('Parâmetros PBE vazios');
    }

    final salt = (params.elements[0] as asn1.ASN1OctetString).valueBytes();
    final iterations = (params.elements[1] as asn1.ASN1Integer).intValue;

    if (encryptedData.isEmpty) {
      throw ExcecaoAssinaturaCertificado('Dados encriptados vazios');
    }

    final senhaBytes = Uint8List.fromList(utf8.encode(senha));

    switch (algorithmOid) {
      case '1.2.840.113549.1.12.1.3': // pbeWithSHAAnd3-KeyTripleDES-CBC
        return _pbeWithSHAAnd3KeyTripleDESCBC(senhaBytes, salt, iterations, encryptedData);

      case '1.2.840.113549.1.12.1.6': // pbeWithSHAAnd40BitRC2-CBC
        return _pbeWithSHAAnd40BitRC2CBC(senhaBytes, salt, iterations, encryptedData);

      case '1.2.840.113549.1.5.13': // PBES2
        return _pbes2Decrypt(params, encryptedData, senhaBytes);

      default:
        throw ExcecaoAssinaturaCertificado('Algoritmo PBE não suportado: $algorithmOid');
    }
  }

  /// PBE com SHA1 e 3-Key Triple DES CBC
  Uint8List _pbeWithSHAAnd3KeyTripleDESCBC(Uint8List senha, Uint8List salt, int iterations, Uint8List data) {
    final keyAndIv = _pkcs12Kdf(senha, salt, iterations, 1, 24);
    final iv = _pkcs12Kdf(senha, salt, iterations, 2, 8);

    final desEngine = pc.DESedeEngine();
    final cbcCipher = pc.CBCBlockCipher(desEngine);
    cbcCipher.init(false, pc.ParametersWithIV(pc.KeyParameter(keyAndIv), iv));

    final decrypted = Uint8List(data.length);
    var offset = 0;
    while (offset < data.length) {
      offset += cbcCipher.processBlock(data, offset, decrypted, offset);
    }

    return _removePkcs7Padding(decrypted);
  }

  /// PBE com SHA1 e 40-bit RC2 CBC
  Uint8List _pbeWithSHAAnd40BitRC2CBC(Uint8List senha, Uint8List salt, int iterations, Uint8List data) {
    final key = _pkcs12Kdf(senha, salt, iterations, 1, 5);
    final iv = _pkcs12Kdf(senha, salt, iterations, 2, 8);

    final rc2Engine = pc.RC2Engine();
    final cbcCipher = pc.CBCBlockCipher(rc2Engine);
    cbcCipher.init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));

    final decrypted = Uint8List(data.length);
    var offset = 0;
    while (offset < data.length) {
      offset += cbcCipher.processBlock(data, offset, decrypted, offset);
    }

    return _removePkcs7Padding(decrypted);
  }

  /// PBES2 (mais moderno)
  Uint8List _pbes2Decrypt(asn1.ASN1Sequence params, Uint8List data, Uint8List senha) {
    final kdfSeq = params.elements[0] as asn1.ASN1Sequence;
    final encSchemeSeq = params.elements[1] as asn1.ASN1Sequence;

    final kdfParams = kdfSeq.elements[1] as asn1.ASN1Sequence;
    final salt = (kdfParams.elements[0] as asn1.ASN1OctetString).valueBytes();
    final iterations = (kdfParams.elements[1] as asn1.ASN1Integer).intValue;

    int keyLength = 32;
    if (kdfParams.elements.length > 2 && kdfParams.elements[2] is asn1.ASN1Integer) {
      keyLength = (kdfParams.elements[2] as asn1.ASN1Integer).intValue;
    }

    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64));
    pbkdf2.init(pc.Pbkdf2Parameters(salt, iterations, keyLength));
    final key = pbkdf2.process(senha);

    final iv = (encSchemeSeq.elements[1] as asn1.ASN1OctetString).valueBytes();

    final aesEngine = pc.AESEngine();
    final cbcCipher = pc.CBCBlockCipher(aesEngine);
    cbcCipher.init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));

    final decrypted = Uint8List(data.length);
    var offset = 0;
    while (offset < data.length) {
      offset += cbcCipher.processBlock(data, offset, decrypted, offset);
    }

    return _removePkcs7Padding(decrypted);
  }

  /// PKCS#12 Key Derivation Function
  Uint8List _pkcs12Kdf(Uint8List senha, Uint8List salt, int iterations, int id, int keyLength) {
    // Converter senha para formato PKCS#12 (UTF-16BE com null terminator)
    final senhaUtf16 = Uint8List(senha.length * 2 + 2);
    for (var i = 0; i < senha.length; i++) {
      senhaUtf16[i * 2] = 0;
      senhaUtf16[i * 2 + 1] = senha[i];
    }
    senhaUtf16[senha.length * 2] = 0;
    senhaUtf16[senha.length * 2 + 1] = 0;

    const v = 64; // SHA-1 block size
    const u = 20; // SHA-1 output size

    // Construct D
    final d = Uint8List(v);
    for (var i = 0; i < v; i++) {
      d[i] = id;
    }

    // Construct I = S || P
    final sLen = salt.isEmpty ? 0 : v * ((salt.length + v - 1) ~/ v);
    final pLen = senhaUtf16.isEmpty ? 0 : v * ((senhaUtf16.length + v - 1) ~/ v);
    final iArray = Uint8List(sLen + pLen);

    for (var j = 0; j < sLen; j++) {
      iArray[j] = salt[j % salt.length];
    }
    for (var j = 0; j < pLen; j++) {
      iArray[sLen + j] = senhaUtf16[j % senhaUtf16.length];
    }

    final result = Uint8List(keyLength);
    var resultOffset = 0;

    while (resultOffset < keyLength) {
      var a = Uint8List.fromList([...d, ...iArray]);
      for (var iter = 0; iter < iterations; iter++) {
        final digest = pc.SHA1Digest();
        a = digest.process(a);
      }

      final copyLen = (keyLength - resultOffset) < u ? (keyLength - resultOffset) : u;
      for (var j = 0; j < copyLen; j++) {
        result[resultOffset + j] = a[j];
      }
      resultOffset += copyLen;

      if (resultOffset >= keyLength) break;

      final b = Uint8List(v);
      for (var j = 0; j < v; j++) {
        b[j] = a[j % u];
      }

      for (var j = 0; j < iArray.length ~/ v; j++) {
        _addWithCarry(iArray, j * v, b);
      }
    }

    return result;
  }

  /// Adiciona com carry para PKCS#12 KDF
  void _addWithCarry(Uint8List data, int offset, Uint8List b) {
    var carry = 1;
    for (var i = b.length - 1; i >= 0; i--) {
      final sum = data[offset + i] + b[i] + carry;
      data[offset + i] = sum & 0xFF;
      carry = sum >> 8;
    }
  }

  /// Remove padding PKCS#7
  Uint8List _removePkcs7Padding(Uint8List data) {
    if (data.isEmpty) return data;
    final paddingLength = data[data.length - 1];
    if (paddingLength > data.length || paddingLength > 16) {
      return data;
    }
    return Uint8List.sublistView(data, 0, data.length - paddingLength);
  }

  // ============================================================================
  // BER to DER Conversion - Full Implementation
  // ============================================================================

  /// Verifica se há algum comprimento indefinido no buffer
  ///
  /// IMPORTANTE: Só verifica a TAG RAIZ (primeiros 2 bytes)
  /// Não faz scan do buffer inteiro porque pode detectar falsos positivos
  /// dentro de dados encriptados (OCTET STRINGs com bytes aleatórios)
  bool _containsIndefiniteLength(Uint8List bytes) {
    if (bytes.length < 2) return false;

    // Verificar apenas se a estrutura RAIZ usa BER indefinite length
    // Byte 0 = tag, Byte 1 = length
    return bytes[1] == 0x80;
  }

  /// Verifica se uma tag representa tipo construído (constructed)
  ///
  /// Bit 6 (0x20) indica constructed encoding
  bool _isConstructedTag(int tag) {
    return (tag & 0x20) != 0;
  }

  /// Verifica se deve fazer parse dos children para uma tag
  ///
  /// SEQUENCE (0x30), SET (0x31), CONTEXT_SPECIFIC construídos (0xA0-0xAF)
  /// e tags APPLICATION/CONTEXT construídas (0x20-0x3F com bit 6 setado = constructed)
  bool _shouldParseChildren(int tag) {
    // SEQUENCE e SET sempre devem ter children
    if (tag == 0x30 || tag == 0x31) return true;

    // CONTEXT_SPECIFIC constructed
    if (tag >= 0xA0 && tag <= 0xAF && _isConstructedTag(tag)) return true;

    // APPLICATION/CONTEXT tags constructed (0x20-0x3F)
    // Tag 0x24 = 00100100 → bit 6 está setado = constructed
    if (tag >= 0x20 && tag <= 0x3F && _isConstructedTag(tag)) return true;

    return false;
  }

  /// Encontra o offset dos octetos end-of-contents (0x00 0x00)
  ///
  /// Rastreia profundidade de aninhamento para lidar com
  /// indefinite length aninhados corretamente.
  ///
  /// Throws [ExcecaoAssinaturaCertificado] se end-of-contents não encontrado
  int _findEndOfContents(Uint8List bytes, int startOffset) {
    int offset = startOffset;
    int depth = 1; // Rastreia profundidade de aninhamento
    const int maxDepth = 100; // Limite de segurança

    while (offset < bytes.length - 1 && depth > 0) {
      // Verificar limite de profundidade
      if (depth > maxDepth) {
        throw ExcecaoAssinaturaCertificado('BER parsing: profundidade de aninhamento excede limite ($maxDepth)');
      }

      // Verificar end-of-contents octets
      if (bytes[offset] == 0x00 && bytes[offset + 1] == 0x00) {
        depth--;
        if (depth == 0) {
          return offset; // Encontrou terminador correspondente
        }
        offset += 2;
        continue;
      }

      // Parse tag
      if (offset >= bytes.length) {
        break;
      }
      offset++;

      // Parse length
      if (offset >= bytes.length) {
        break;
      }
      final lengthByte = bytes[offset];
      offset++;

      if (lengthByte == 0x80) {
        // Nested indefinite length - aumenta profundidade
        depth++;
      } else if ((lengthByte & 0x80) != 0) {
        // Long form definite length
        final lengthOfLength = lengthByte & 0x7F;

        if (lengthOfLength > 4 || offset + lengthOfLength > bytes.length) {
          throw ExcecaoAssinaturaCertificado('BER parsing: length encoding inválido em offset $offset');
        }

        int actualLength = 0;
        for (int i = 0; i < lengthOfLength; i++) {
          actualLength = (actualLength << 8) | bytes[offset++];
        }

        // Validar bounds
        if (offset + actualLength > bytes.length) {
          throw ExcecaoAssinaturaCertificado(
            'BER parsing: conteúdo truncado em offset $offset '
            '(esperado $actualLength bytes, disponível ${bytes.length - offset})',
          );
        }

        offset += actualLength; // Skip content
      } else {
        // Short form definite length
        if (offset + lengthByte > bytes.length) {
          throw ExcecaoAssinaturaCertificado(
            'BER parsing: conteúdo truncado em offset $offset '
            '(esperado $lengthByte bytes, disponível ${bytes.length - offset})',
          );
        }
        offset += lengthByte; // Skip content
      }
    }

    throw ExcecaoAssinaturaCertificado(
      'BER parsing: end-of-contents (0x00 0x00) não encontrado.\n'
      'Offset inicial: $startOffset\n'
      'Último offset: $offset\n'
      'Profundidade final: $depth\n'
      'Possíveis causas:\n'
      '  • Certificado corrompido\n'
      '  • Senha incorreta\n'
      '  • Formato BER inválido',
    );
  }

  /// Codifica um comprimento em formato DER
  ///
  /// Short form (0-127): [length]
  /// Long form (128+): [0x80 | num_bytes, byte1, byte2, ...]
  List<int> _encodeDerLength(int length) {
    if (length < 128) {
      // Short form: 0-127 bytes
      return [length];
    } else {
      // Long form: 128+ bytes
      final lengthBytes = <int>[];
      int temp = length;
      while (temp > 0) {
        lengthBytes.insert(0, temp & 0xFF);
        temp >>= 8;
      }
      // Primeiro byte: 0x80 | número de bytes do comprimento
      return [0x80 | lengthBytes.length, ...lengthBytes];
    }
  }

  /// Parse um elemento ASN.1 (pode ser BER ou DER)
  ///
  /// Retorna estrutura [_Asn1Element] com conteúdo parseado
  _Asn1Element _parseAsn1Element(Uint8List bytes, int offset, [int depth = 0]) {
    const int maxDepth = 100;
    if (depth > maxDepth) {
      throw ExcecaoAssinaturaCertificado('ASN.1 parsing: profundidade máxima excedida ($maxDepth)');
    }

    if (offset >= bytes.length) {
      throw ExcecaoAssinaturaCertificado('ASN.1 parsing: offset $offset >= tamanho buffer ${bytes.length}');
    }

    // Parse tag
    final tag = bytes[offset];
    offset++;

    if (offset >= bytes.length) {
      throw ExcecaoAssinaturaCertificado('ASN.1 parsing: buffer truncado após tag em offset ${offset - 1}');
    }

    // Parse length
    final lengthByte = bytes[offset];
    offset++;

    late final Uint8List content;
    late final bool isConstructed;

    if (lengthByte == 0x80) {
      // ========== BER indefinite length ==========
      final contentStart = offset;
      final endOffset = _findEndOfContents(bytes, contentStart);
      content = Uint8List.sublistView(bytes, contentStart, endOffset);
      isConstructed = _isConstructedTag(tag);
    } else if ((lengthByte & 0x80) != 0) {
      // ========== DER long form definite length ==========
      final lengthOfLength = lengthByte & 0x7F;

      if (lengthOfLength == 0) {
        // 0x80 já foi tratado acima, isso não deveria acontecer
        throw ExcecaoAssinaturaCertificado('ASN.1 parsing: length-of-length = 0 inesperado');
      }

      if (lengthOfLength > 4 || offset + lengthOfLength > bytes.length) {
        throw ExcecaoAssinaturaCertificado('ASN.1 parsing: length-of-length inválido: $lengthOfLength');
      }

      int actualLength = 0;
      for (int i = 0; i < lengthOfLength; i++) {
        actualLength = (actualLength << 8) | bytes[offset++];
      }

      if (offset + actualLength > bytes.length) {
        throw ExcecaoAssinaturaCertificado('ASN.1 parsing: conteúdo truncado (esperado $actualLength bytes)');
      }

      content = Uint8List.sublistView(bytes, offset, offset + actualLength);
      isConstructed = _isConstructedTag(tag);
    } else {
      // ========== DER short form definite length ==========
      final contentLength = lengthByte;

      if (offset + contentLength > bytes.length) {
        throw ExcecaoAssinaturaCertificado('ASN.1 parsing: conteúdo truncado (esperado $contentLength bytes)');
      }

      content = Uint8List.sublistView(bytes, offset, offset + contentLength);
      isConstructed = _isConstructedTag(tag);
    }

    // Parse children se for tipo construído
    List<_Asn1Element>? children;
    if (isConstructed && _shouldParseChildren(tag)) {
      children = _parseChildren(content, depth + 1);

      // Debug: log parsing
      if (depth == 0) {
        // ignore: avoid_print
        print('[BER Parse] Root tag=0x${tag.toRadixString(16)} content=${content.length}b children=${children.length}');
      }
    }

    return _Asn1Element(tag: tag, content: content, isConstructed: isConstructed, children: children);
  }

  /// Parse todos os children de um elemento construído
  List<_Asn1Element> _parseChildren(Uint8List content, int depth) {
    final children = <_Asn1Element>[];
    int offset = 0;

    while (offset < content.length) {
      // Skip possíveis end-of-contents octets
      if (offset + 1 < content.length && content[offset] == 0x00 && content[offset + 1] == 0x00) {
        break;
      }

      final childStart = offset;
      final child = _parseAsn1Element(content, offset, depth);
      children.add(child);

      // Calcular quanto avançar
      // Tag (1 byte) + length encoding + content length
      final lengthByte = content[childStart + 1];

      int headerSize = 2; // tag + length byte
      int contentLength = child.content.length;

      if (lengthByte == 0x80) {
        // Indefinite length: tag + 0x80 + content + 0x00 0x00
        final endOfContents = _findEndOfContents(content, childStart + 2);
        offset = endOfContents + 2; // +2 para pular 0x00 0x00
      } else if ((lengthByte & 0x80) != 0) {
        // Long form
        final lengthOfLength = lengthByte & 0x7F;
        headerSize += lengthOfLength;
        offset = childStart + headerSize + contentLength;
      } else {
        // Short form
        offset = childStart + headerSize + contentLength;
      }
    }

    return children;
  }

  /// Codifica um elemento ASN.1 em formato DER
  ///
  /// Sempre usa comprimento definido (nunca indefinido)
  Uint8List _encodeAsn1Element(_Asn1Element element) {
    // Tag
    final tag = element.tag;

    // Content
    Uint8List contentBytes;
    if (element.isConstructed && element.children != null && element.children!.isNotEmpty) {
      // Re-encode children recursivamente
      final childBuffer = BytesBuilder(copy: false);
      for (final child in element.children!) {
        final childBytes = _encodeAsn1Element(child);
        childBuffer.add(childBytes);
      }
      contentBytes = childBuffer.toBytes();
    } else {
      // Content primitivo - usar como está
      contentBytes = element.content;
    }

    // Montar resultado final: Tag + Length + Content
    final buffer = BytesBuilder(copy: false);
    buffer.addByte(tag);
    final lengthBytes = _encodeDerLength(contentBytes.length);
    buffer.add(lengthBytes);
    buffer.add(contentBytes);

    return buffer.toBytes();
  }

  /// Extrai chave privada não encriptada de um KeyBag
  pc.RSAPrivateKey _extrairChavePrivadaDeBag(asn1.ASN1Sequence safeBag) {
    try {
      final keyBagContext = safeBag.elements[1];
      final keyBagBytes = keyBagContext.encodedBytes;

      final offset = _decodificarComprimentoAsn1Seguro(keyBagBytes, 'KeyBag CONTEXT_SPECIFIC');

      final keyParser = asn1.ASN1Parser(Uint8List.sublistView(keyBagBytes, offset));
      final privateKeyInfo = keyParser.nextObject() as asn1.ASN1Sequence;

      final privateKeyOctet = privateKeyInfo.elements[2] as asn1.ASN1OctetString;
      final privateKeyBytes = privateKeyOctet.valueBytes();

      final rsaParser = asn1.ASN1Parser(privateKeyBytes);
      final rsaSequence = rsaParser.nextObject() as asn1.ASN1Sequence;

      return _parseRsaPrivateKey(rsaSequence);
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro ao extrair chave privada: $e');
    }
  }

  /// Extrai certificado de um CertBag
  String _extrairCertificadoDeBag(asn1.ASN1Sequence safeBag) {
    try {
      final certBagContext = safeBag.elements[1];
      final certBagBytes = certBagContext.encodedBytes;

      final offset = _decodificarComprimentoAsn1Seguro(certBagBytes, 'CertBag CONTEXT_SPECIFIC');

      final certBagParser = asn1.ASN1Parser(Uint8List.sublistView(certBagBytes, offset));
      final certBagSequence = certBagParser.nextObject() as asn1.ASN1Sequence;
      final certType = (certBagSequence.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

      if (certType != '1.2.840.113549.1.9.22.1') {
        throw ExcecaoAssinaturaCertificado('Tipo de certificado não suportado: $certType');
      }

      final certContext = certBagSequence.elements[1];
      final certContextBytes = certContext.encodedBytes;

      final certOffset = _decodificarComprimentoAsn1Seguro(certContextBytes, 'Certificate CONTEXT_SPECIFIC');

      final certParser = asn1.ASN1Parser(Uint8List.sublistView(certContextBytes, certOffset));
      final certOctet = certParser.nextObject() as asn1.ASN1OctetString;
      final certBytes = certOctet.valueBytes();

      return base64.encode(certBytes);
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro ao extrair certificado: $e');
    }
  }

  /// Extrai informações do certificado X.509 dos bytes
  InformacoesCertificado _extrairInformacoesCertificadoDeBytes(Uint8List certBytes) {
    try {
      final parser = asn1.ASN1Parser(certBytes);
      final certSequence = parser.nextObject() as asn1.ASN1Sequence;
      final tbsCertificate = certSequence.elements[0] as asn1.ASN1Sequence;

      final serialNumber = (tbsCertificate.elements[1] as asn1.ASN1Integer).valueAsBigInteger.toString();

      final validity = tbsCertificate.elements[4] as asn1.ASN1Sequence;
      final validoDe = _parseAsn1Time(validity.elements[0]);
      final validoAte = _parseAsn1Time(validity.elements[1]);

      // Extrair subject para obter nome e CPF/CNPJ
      String assunto = 'Certificado ICP-Brasil';
      String? cpfCnpj;

      try {
        final subject = tbsCertificate.elements[5] as asn1.ASN1Sequence;
        final subjectInfo = _extrairSubjectInfo(subject);
        assunto = subjectInfo['cn'] ?? assunto;
        cpfCnpj = subjectInfo['cpfCnpj'];
      } catch (_) {
        // Ignorar erros na extração do subject
      }

      return InformacoesCertificado(
        numeroSerie: serialNumber,
        assunto: assunto,
        emissor: 'ICP-Brasil',
        validoDe: validoDe,
        validoAte: validoAte,
        isICPBrasil: true,
        tipo: cpfCnpj != null && cpfCnpj.length == 11 ? TipoCertificado.eCPF : TipoCertificado.eCNPJ,
        cpfCnpj: cpfCnpj ?? '',
      );
    } catch (e) {
      return InformacoesCertificado(
        numeroSerie: 'Não disponível',
        assunto: 'Certificado Digital',
        emissor: 'ICP-Brasil',
        validoDe: DateTime.now().subtract(const Duration(days: 365)),
        validoAte: DateTime.now().add(const Duration(days: 365)),
        isICPBrasil: true,
        tipo: TipoCertificado.eCNPJ,
        cpfCnpj: '',
      );
    }
  }

  /// Extrai informações do Subject do certificado
  Map<String, String?> _extrairSubjectInfo(asn1.ASN1Sequence subject) {
    String? cn;
    String? cpfCnpj;

    for (var rdn in subject.elements) {
      if (rdn is! asn1.ASN1Set) continue;

      for (var atv in rdn.elements) {
        if (atv is! asn1.ASN1Sequence) continue;
        if (atv.elements.length < 2) continue;

        final oid = (atv.elements[0] as asn1.ASN1ObjectIdentifier).identifier;
        final value = atv.elements[1];

        String? stringValue;
        if (value is asn1.ASN1UTF8String) {
          stringValue = value.utf8StringValue;
        } else if (value is asn1.ASN1PrintableString) {
          stringValue = value.stringValue;
        } else if (value is asn1.ASN1IA5String) {
          stringValue = value.stringValue;
        }

        if (stringValue == null) continue;

        // CN (Common Name)
        if (oid == '2.5.4.3') {
          cn = stringValue;
        }

        // Tentar extrair CPF/CNPJ do CN ou de OIDs específicos
        if (oid == '2.5.4.3' || oid == '2.16.76.1.3.1') {
          // Procurar padrão de CPF (11 dígitos)
          final cpfMatch = RegExp(r'(\d{11})').firstMatch(stringValue);
          if (cpfMatch != null) {
            cpfCnpj = cpfMatch.group(1);
          }

          // Procurar padrão de CNPJ (14 dígitos)
          final cnpjMatch = RegExp(r'(\d{14})').firstMatch(stringValue);
          if (cnpjMatch != null) {
            cpfCnpj = cnpjMatch.group(1);
          }
        }
      }
    }

    return {'cn': cn, 'cpfCnpj': cpfCnpj};
  }

  /// Parse de tempo ASN.1 (UTCTime ou GeneralizedTime)
  DateTime _parseAsn1Time(dynamic timeObject) {
    try {
      if (timeObject is asn1.ASN1UtcTime) {
        return timeObject.dateTimeValue;
      } else if (timeObject is asn1.ASN1GeneralizedTime) {
        return timeObject.dateTimeValue;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Limpa recursos
  void dispose() {
    // Limpar dados sensíveis
    _chavePrivada = null;
    _certificadoX509Base64 = null;
    _infoCertificado = null;
  }
}

/// Dados extraídos do PKCS12
class _DadosPkcs12 {
  final pc.RSAPrivateKey chavePrivada;
  final String certificado;
  final InformacoesCertificado info;

  _DadosPkcs12({required this.chavePrivada, required this.certificado, required this.info});
}

/// Dados parciais extraídos durante o processamento
class _DadosParciais {
  final pc.RSAPrivateKey? chavePrivada;
  final String? certificado;

  _DadosParciais({this.chavePrivada, this.certificado});
}
