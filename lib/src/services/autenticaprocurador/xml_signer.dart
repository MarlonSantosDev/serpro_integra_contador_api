import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:asn1lib/asn1lib.dart' as asn1;
import 'package:xml/xml.dart';
import 'model/certificate_info.dart';
import 'exceptions/autenticaprocurador_exceptions.dart';
import 'io/file_io.dart';

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

  AssinadorDigitalXml({
    this.caminhoCertificado,
    this.certificadoBase64,
    required this.senhaCertificado,
  }) {
    // Validar que pelo menos um dos dois foi fornecido
    if ((caminhoCertificado == null || caminhoCertificado!.isEmpty) &&
        (certificadoBase64 == null || certificadoBase64!.isEmpty)) {
      throw ExcecaoAssinaturaCertificado(
        'É necessário fornecer caminhoCertificado ou certificadoBase64',
      );
    }

    // Validar que não foram fornecidos ambos
    if (caminhoCertificado != null &&
        caminhoCertificado!.isNotEmpty &&
        certificadoBase64 != null &&
        certificadoBase64!.isNotEmpty) {
      throw ExcecaoAssinaturaCertificado(
        'Forneça apenas caminhoCertificado OU certificadoBase64, não ambos',
      );
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
      final docComSignature = XmlDocument.parse(
        conteudoXml.replaceAll(
          '</termoDeAutorizacao>',
          '$signatureXml</termoDeAutorizacao>',
        ),
      );

      // 7. Extrair e canonizar APENAS o SignedInfo
      // PHP: $c14nSignedInfo = $signedInfoElement->C14N(true, false);
      final signedInfoElement = docComSignature
          .findAllElements('SignedInfo')
          .first;
      final signedInfoCanonico = _canonizarElemento(
        signedInfoElement,
        namespacePai: 'http://www.w3.org/2000/09/xmldsig#',
      );

      // 8. Assinar o SignedInfo canonizado com RSA-SHA256
      // PHP: openssl_sign($c14nSignedInfo, $signatureValue, $privateKey, OPENSSL_ALGO_SHA256);
      final valorAssinatura = _assinarComRsaSha256(signedInfoCanonico);

      // 9. Substituir o SignatureValue vazio pelo valor da assinatura
      final xmlFinal = docComSignature
          .toXmlString(pretty: false, indent: '')
          .replaceFirst(
            '<SignatureValue></SignatureValue>',
            '<SignatureValue>$valorAssinatura</SignatureValue>',
          );

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
        buffer.write(
          _c14nElement(child, namespacePai: namespaceAtual ?? namespacePai),
        );
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
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\r', '&#xD;');
  }

  /// Carrega e analisa o certificado digital
  ///
  /// ## Formatos suportados:
  /// Valida e decodifica string Base64 de certificado
  ///
  /// Realiza sanitização e validação do Base64 antes de decodificar.
  /// Lança [ExcecaoAssinaturaCertificado] com códigos específicos:
  /// - ERRO_BASE64_FORMATO_INVALIDO: Formato Base64 inválido
  /// - ERRO_BASE64_TRUNCADO: String muito curta (possível truncamento)
  /// - ERRO_BASE64_VAZIO: Decodificação resultou em bytes vazios
  /// - ERRO_BASE64_NAO_PKCS12: Conteúdo não parece ser PKCS#12
  /// - ERRO_BASE64_DECODE: Erro durante decodificação
  Uint8List _decodificarCertificadoBase64(String base64String) {
    try {
      // Remover whitespace, line breaks, e caracteres inválidos
      final sanitized = base64String
          .replaceAll(RegExp(r'\s+'), '') // Remove espaços/quebras de linha
          .replaceAll(
            RegExp(r'[^A-Za-z0-9+/=]'),
            '',
          ); // Remove caracteres inválidos

      // Validar formato Base64 básico
      if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(sanitized)) {
        throw ExcecaoAssinaturaCertificado(
          'Formato Base64 inválido detectado.\n'
          'O certificado deve estar codificado em Base64 válido.',
          codigo: 'ERRO_BASE64_FORMATO_INVALIDO',
        );
      }

      // Validar comprimento mínimo (certificados PKCS#12 típicos têm >1000 bytes)
      if (sanitized.length < 100) {
        throw ExcecaoAssinaturaCertificado(
          'Certificado Base64 muito curto (${sanitized.length} caracteres).\n'
          'Certificados PKCS#12 válidos geralmente têm >1000 bytes.\n'
          'Possível truncamento ou corrupção.',
          codigo: 'ERRO_BASE64_TRUNCADO',
        );
      }

      final bytes = base64.decode(sanitized);

      // Validar que decodificação não resultou em vazio
      if (bytes.isEmpty) {
        throw ExcecaoAssinaturaCertificado(
          'Decodificação Base64 resultou em bytes vazios.',
          codigo: 'ERRO_BASE64_VAZIO',
        );
      }

      // Validar assinatura mágica PKCS#12
      // Certificados PKCS#12 começam com SEQUENCE (0x30) ou APPLICATION (0x60)
      if (bytes[0] != 0x30 && bytes[0] != 0x60) {
        throw ExcecaoAssinaturaCertificado(
          'Conteúdo Base64 não parece ser um certificado PKCS#12 válido.\n'
          'Byte inicial: 0x${bytes[0].toRadixString(16).padLeft(2, '0')} '
          '(esperado: 0x30 para SEQUENCE ou 0x60 para APPLICATION).\n'
          'Verifique se o arquivo Base64 está correto.',
          codigo: 'ERRO_BASE64_NAO_PKCS12',
        );
      }

      return bytes;
    } on FormatException catch (e) {
      throw ExcecaoAssinaturaCertificado(
        'Erro ao decodificar Base64: ${e.message}\n'
        'Certifique-se de que o certificado está em Base64 válido.',
        codigo: 'ERRO_BASE64_DECODE',
      );
    }
  }

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
        certificadoBytes = _decodificarCertificadoBase64(certificadoBase64!);
      } else if (caminhoCertificado != null && caminhoCertificado!.isNotEmpty) {
        // Certificado em arquivo (Desktop/Mobile apenas)
        if (!FileIO.isSupported) {
          throw ExcecaoAssinaturaCertificado(
            '📱 Leitura de arquivo não suportada em Web.\n'
            'Use certificadoBase64 em vez de certificadoPath.',
          );
        }

        if (!await FileIO.fileExists(caminhoCertificado!)) {
          throw ExcecaoAssinaturaCertificado(
            'Certificado não encontrado: $caminhoCertificado',
          );
        }
        certificadoBytes = await FileIO.readFileAsBytes(caminhoCertificado!);
      } else {
        throw ExcecaoAssinaturaCertificado(
          'Nenhum certificado fornecido. Use certificadoBase64 ou caminhoCertificado.',
        );
      }

      // Detectar formato: PEM (texto) ou PKCS#12 (binário)
      final certificadoTexto = utf8.decode(
        certificadoBytes,
        allowMalformed: true,
      );
      final isPem =
          certificadoTexto.contains('-----BEGIN') &&
          certificadoTexto.contains('-----END');

      _DadosPkcs12 dadosCertificado;

      if (isPem) {
        //print('✅ Detectado formato PEM');
        dadosCertificado = _extrairDePem(certificadoTexto);
      } else {
        // PKCS#12/PFX
        //print('✅ Detectado formato PKCS#12/PFX');

        // Tentar conversão via OpenSSL em Desktop (melhor compatibilidade)
        if (FileIO.isDesktop && caminhoCertificado != null) {
          final pemConvertido = await FileIO.runOpenSSLConversion(
            caminhoCertificado!,
            senhaCertificado,
          );

          if (pemConvertido != null) {
            //print('✅ Convertido para PEM usando OpenSSL');
            dadosCertificado = _extrairDePem(pemConvertido);
          } else {
            // Fallback para parse Pure Dart
            //print('⚠️  OpenSSL não disponível, usando parser Pure Dart');
            dadosCertificado = _extrairPkcs12PureDart(
              certificadoBytes,
              senhaCertificado,
            );
          }
        } else {
          // Web/Mobile: usar parser Pure Dart diretamente
          dadosCertificado = _extrairPkcs12PureDart(
            certificadoBytes,
            senhaCertificado,
          );
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
      throw ExcecaoAssinaturaCertificado('Erro ao carregar certificado: $e');
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
      assinador.init(
        true,
        pc.PrivateKeyParameter<pc.RSAPrivateKey>(_chavePrivada!),
      );

      // Converter dados para bytes
      final dadosBytes = utf8.encode(dados);

      // Gerar assinatura
      final assinatura =
          assinador.generateSignature(Uint8List.fromList(dadosBytes))
              as pc.RSASignature;

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
        final privateKeyB64 = privateKeyMatch
            .group(1)!
            .replaceAll(RegExp(r'\s'), '');
        final privateKeyBytes = base64.decode(privateKeyB64);
        chavePrivada = _parsePrivateKeyFromDer(privateKeyBytes);
      }

      // Procurar pelo certificado
      final certRegex = RegExp(
        r'-----BEGIN CERTIFICATE-----\s*([A-Za-z0-9+/=\s]+)\s*-----END CERTIFICATE-----',
        multiLine: true,
      );

      final certMatch = certRegex.firstMatch(pemText);
      if (certMatch != null) {
        certificadoBase64 = certMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
      }

      if (chavePrivada == null) {
        throw ExcecaoAssinaturaCertificado(
          'Chave privada não encontrada no PEM',
        );
      }

      if (certificadoBase64 == null) {
        throw ExcecaoAssinaturaCertificado('Certificado não encontrado no PEM');
      }

      // Extrair informações do certificado
      final infoCert = _extrairInformacoesCertificadoDeBytes(
        base64.decode(certificadoBase64),
      );

      return _DadosPkcs12(
        chavePrivada: chavePrivada,
        certificado: certificadoBase64,
        info: infoCert,
      );
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
      if (sequence.elements.length >= 3 &&
          sequence.elements[1] is asn1.ASN1Sequence) {
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
    final modulus =
        (rsaSequence.elements[1] as asn1.ASN1Integer).valueAsBigInteger;
    final privateExponent =
        (rsaSequence.elements[3] as asn1.ASN1Integer).valueAsBigInteger;
    final p = (rsaSequence.elements[4] as asn1.ASN1Integer).valueAsBigInteger;
    final q = (rsaSequence.elements[5] as asn1.ASN1Integer).valueAsBigInteger;

    return pc.RSAPrivateKey(modulus, privateExponent, p, q);
  }

  /// Extrai chave e certificado de PKCS12 usando Pure Dart
  ///
  /// Compatível com Web, Desktop e Mobile
  _DadosPkcs12 _extrairPkcs12PureDart(Uint8List pkcs12Bytes, String senha) {
    try {
      // Parse PKCS#12 usando asn1lib
      final parser = asn1.ASN1Parser(pkcs12Bytes);
      var pfxObject = parser.nextObject();

      // Alguns PKCS#12 vêm encapsulados em ASN1Application
      if (pfxObject is asn1.ASN1Application) {
        final appBytes = pfxObject.encodedBytes;
        final offset = _calcularOffsetDerSeguro(
          appBytes,
          'ASN1Application wrapper',
        );
        final innerParser = asn1.ASN1Parser(
          _extrairSublistSegura(appBytes, offset, 'ASN1Application'),
        );
        pfxObject = innerParser.nextObject();
      }

      if (pfxObject is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 inválido: objeto raiz não é Sequence',
        );
      }

      final pfxSequence = pfxObject;

      // Verificar versão (deve ser 3)
      if (pfxSequence.elements[0] is! asn1.ASN1Integer) {
        throw ExcecaoAssinaturaCertificado('PKCS#12 version não é Integer');
      }

      final version = (pfxSequence.elements[0] as asn1.ASN1Integer).intValue;
      if (version != 3) {
        throw ExcecaoAssinaturaCertificado(
          'Versão PKCS#12 não suportada: $version',
        );
      }

      // AuthSafe ContentInfo
      if (pfxSequence.elements[1] is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado(
          'AuthSafe ContentInfo não é Sequence',
        );
      }

      final authSafeContentInfo = pfxSequence.elements[1] as asn1.ASN1Sequence;

      if (authSafeContentInfo.elements[0] is! asn1.ASN1ObjectIdentifier) {
        throw ExcecaoAssinaturaCertificado(
          'AuthSafe OID não é ObjectIdentifier',
        );
      }

      final authSafeOid =
          (authSafeContentInfo.elements[0] as asn1.ASN1ObjectIdentifier)
              .identifier;

      if (authSafeOid != '1.2.840.113549.1.7.1') {
        throw ExcecaoAssinaturaCertificado(
          'PKCS#12 authSafe OID não suportado: $authSafeOid',
        );
      }

      // Extrair conteúdo do AuthSafe
      final authSafeContext = authSafeContentInfo.elements[1];
      Uint8List authSafeOctetBytes;

      if (authSafeContext is asn1.ASN1OctetString) {
        authSafeOctetBytes = authSafeContext.valueBytes();
      } else {
        final authSafeBytes = authSafeContext.encodedBytes;
        final offset = _calcularOffsetDerSeguro(
          authSafeBytes,
          'AuthSafe context',
        );
        final innerParser = asn1.ASN1Parser(
          _extrairSublistSegura(authSafeBytes, offset, 'AuthSafe'),
        );
        final authSafeOctet = innerParser.nextObject() as asn1.ASN1OctetString;
        authSafeOctetBytes = authSafeOctet.valueBytes();
      }

      final authSafeParser = asn1.ASN1Parser(authSafeOctetBytes);
      final authSafeObject = authSafeParser.nextObject();

      if (authSafeObject is! asn1.ASN1Sequence) {
        throw ExcecaoAssinaturaCertificado('AuthSafe não é uma Sequence');
      }

      final authSafeSequence = authSafeObject;

      pc.RSAPrivateKey? chavePrivada;
      String? certificadoBase64;

      for (var element in authSafeSequence.elements) {
        if (element is! asn1.ASN1Sequence) continue;

        final contentInfo = element;
        if (contentInfo.elements.isEmpty) continue;
        if (contentInfo.elements[0] is! asn1.ASN1ObjectIdentifier) continue;

        final contentType =
            (contentInfo.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

        if (contentType == '1.2.840.113549.1.7.1') {
          // Data - contém bags não encriptados
          final result = _processarDataContent(contentInfo, senha);
          chavePrivada ??= result.chavePrivada;
          certificadoBase64 ??= result.certificado;
        } else if (contentType == '1.2.840.113549.1.7.6') {
          // EncryptedData - contém dados encriptados
          final result = _processarEncryptedData(contentInfo, senha);
          chavePrivada ??= result.chavePrivada;
          certificadoBase64 ??= result.certificado;
        }
      }

      if (chavePrivada == null) {
        throw ExcecaoAssinaturaCertificado(
          'Chave privada não encontrada no PKCS#12. '
          'Verifique se a senha está correta.',
        );
      }

      if (certificadoBase64 == null) {
        throw ExcecaoAssinaturaCertificado(
          'Certificado não encontrado no PKCS#12',
        );
      }

      final infoCert = _extrairInformacoesCertificadoDeBytes(
        base64.decode(certificadoBase64),
      );

      return _DadosPkcs12(
        chavePrivada: chavePrivada,
        certificado: certificadoBase64,
        info: infoCert,
      );
    } on RangeError catch (e) {
      // RangeError indica estrutura ASN.1 corrompida/truncada
      throw ExcecaoAssinaturaCertificado(
        'Formato não-padrão incompatível com parser Pure Dart',
        diagnostico: {
          'erro_tipo': 'Formato',
          'mensagem': e.message,
          'Formato invalido': e.invalidValue?.toString() ?? 'desconhecido',
        },
      );
    } on StateError catch (e) {
      // StateError geralmente indica estrutura inesperada
      throw ExcecaoAssinaturaCertificado(
        'Estrutura PKCS#12 inesperada: ${e.message}\n'
        'O certificado não segue o formato padrão PKCS#12.\n'
        'Verifique com o provedor do certificado.',
        codigo: 'ERRO_PKCS12_ESTRUTURA_INVALIDA',
        diagnostico: {'erro_tipo': 'StateError', 'mensagem': e.message},
      );
    } on asn1.ASN1Exception catch (e) {
      // Erro específico da biblioteca asn1lib
      throw ExcecaoAssinaturaCertificado(
        'Erro ASN.1 durante parsing: $e\n'
        'Certificado PKCS#12 com estrutura ASN.1 inválida.',
        codigo: 'ERRO_ASN1_PARSING',
        diagnostico: {'erro_tipo': 'ASN1Exception', 'mensagem': e.toString()},
      );
    } on ExcecaoAutenticaProcurador {
      // Re-throw nossas exceções customizadas
      rethrow;
    } catch (e) {
      // Catch-all para erros inesperados
      throw ExcecaoAssinaturaCertificado(
        'Erro ao processar PKCS#12: $e\n\n'
        'Tipo de erro: ${e.runtimeType}\n',
        codigo: 'ERRO_PKCS12_GENERICO',
        diagnostico: {
          'erro_tipo': e.runtimeType.toString(),
          'mensagem': e.toString(),
        },
      );
    }
  }

  /// Processa conteúdo Data (não encriptado) do PKCS#12
  _DadosParciais _processarDataContent(
    asn1.ASN1Sequence contentInfo,
    String senha,
  ) {
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
      final offset = _calcularOffsetDerSeguro(contentBytes, 'Data content');
      final innerParser = asn1.ASN1Parser(
        _extrairSublistSegura(contentBytes, offset, 'Data content'),
      );
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

      final bagId =
          (safeBag.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

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

    return _DadosParciais(
      chavePrivada: chavePrivada,
      certificado: certificadoBase64,
    );
  }

  /// Processa conteúdo EncryptedData do PKCS#12
  _DadosParciais _processarEncryptedData(
    asn1.ASN1Sequence contentInfo,
    String senha,
  ) {
    pc.RSAPrivateKey? chavePrivada;
    String? certificadoBase64;

    try {
      if (contentInfo.elements.length < 2) {
        return _DadosParciais();
      }

      final encryptedDataContext = contentInfo.elements[1];
      final encryptedDataBytes = _extrairBytesDeContextSpecific(
        encryptedDataContext,
      );

      final encryptedDataParser = asn1.ASN1Parser(encryptedDataBytes);
      final encryptedData =
          encryptedDataParser.nextObject() as asn1.ASN1Sequence;

      final encryptedContentInfo =
          encryptedData.elements[1] as asn1.ASN1Sequence;
      final algorithmSeq =
          encryptedContentInfo.elements[1] as asn1.ASN1Sequence;
      final encryptedContentContext = encryptedContentInfo.elements[2];

      final algorithmOid =
          (algorithmSeq.elements[0] as asn1.ASN1ObjectIdentifier).identifier!;
      final algorithmParams = algorithmSeq.elements[1] as asn1.ASN1Sequence;

      final encryptedContentBytes = _extrairBytesDeContextSpecific(
        encryptedContentContext,
        isOctetString: true,
      );

      final decryptedBytes = _pbeDecrypt(
        algorithmOid,
        algorithmParams,
        encryptedContentBytes,
        senha,
      );

      final bagsParser = asn1.ASN1Parser(decryptedBytes);
      final bagsSequence = bagsParser.nextObject() as asn1.ASN1Sequence;

      for (var bag in bagsSequence.elements) {
        if (bag is! asn1.ASN1Sequence) continue;

        final safeBag = bag;
        if (safeBag.elements.isEmpty) continue;
        if (safeBag.elements[0] is! asn1.ASN1ObjectIdentifier) continue;

        final bagId =
            (safeBag.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

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

    return _DadosParciais(
      chavePrivada: chavePrivada,
      certificado: certificadoBase64,
    );
  }

  /// Descriptografa chave privada de PKCS8ShroudedKeyBag
  pc.RSAPrivateKey _descriptografarChavePrivada(
    asn1.ASN1Sequence safeBag,
    String senha,
  ) {
    try {
      if (safeBag.elements.length < 2) {
        throw ExcecaoAssinaturaCertificado('SafeBag incompleto');
      }

      final encryptedKeyContext = safeBag.elements[1];
      final encryptedKeyBytes = _extrairBytesDeContextSpecific(
        encryptedKeyContext,
      );

      final encryptedKeyParser = asn1.ASN1Parser(encryptedKeyBytes);
      final encryptedPrivateKeyInfo =
          encryptedKeyParser.nextObject() as asn1.ASN1Sequence;

      if (encryptedPrivateKeyInfo.elements.length < 2) {
        throw ExcecaoAssinaturaCertificado(
          'EncryptedPrivateKeyInfo incompleto',
        );
      }

      final algorithmSeq =
          encryptedPrivateKeyInfo.elements[0] as asn1.ASN1Sequence;
      final encryptedDataOctet =
          encryptedPrivateKeyInfo.elements[1] as asn1.ASN1OctetString;

      final algorithmOid =
          (algorithmSeq.elements[0] as asn1.ASN1ObjectIdentifier).identifier!;
      final algorithmParams = algorithmSeq.elements[1] as asn1.ASN1Sequence;

      final decryptedBytes = _pbeDecrypt(
        algorithmOid,
        algorithmParams,
        encryptedDataOctet.valueBytes(),
        senha,
      );

      final keyParser = asn1.ASN1Parser(decryptedBytes);
      final privateKeyInfo = keyParser.nextObject() as asn1.ASN1Sequence;

      final privateKeyOctet =
          privateKeyInfo.elements[2] as asn1.ASN1OctetString;
      final rsaParser = asn1.ASN1Parser(privateKeyOctet.valueBytes());
      final rsaSequence = rsaParser.nextObject() as asn1.ASN1Sequence;

      return _parseRsaPrivateKey(rsaSequence);
    } catch (e) {
      throw ExcecaoAssinaturaCertificado(
        'Erro ao descriptografar chave privada: $e',
      );
    }
  }

  /// Calcula offset ASN.1 DER com validação de bounds
  ///
  /// Retorna offset seguro ou lança exceção com contexto detalhado.
  /// Lança [ExcecaoAssinaturaCertificado] com códigos:
  /// - ERRO_ASN1_TRUNCADO: Estrutura truncada
  /// - ERRO_ASN1_LENGTH_INVALIDO: Length encoding inválido
  /// - ERRO_ASN1_HEADER_INCOMPLETO: Header ASN.1 incompleto
  int _calcularOffsetDerSeguro(Uint8List bytes, String contexto) {
    // Validar comprimento mínimo
    if (bytes.length < 2) {
      throw ExcecaoAssinaturaCertificado(
        'Estrutura ASN.1 truncada em "$contexto".\n'
        'Comprimento: ${bytes.length} bytes (mínimo esperado: 2).\n'
        'Possível certificado corrompido ou incompleto.',
        codigo: 'ERRO_ASN1_TRUNCADO',
        diagnostico: {
          'contexto': contexto,
          'bytes_disponiveis': bytes.length,
          'bytes_minimos': 2,
        },
      );
    }

    int offset = 2;

    // Verificar se usa forma longa de comprimento
    if ((bytes[1] & 0x80) != 0) {
      final lengthOfLength = bytes[1] & 0x7F;

      // Validar lengthOfLength razoável (DER permite até 127, mas prática é <8)
      if (lengthOfLength > 8) {
        throw ExcecaoAssinaturaCertificado(
          'Comprimento ASN.1 inválido em "$contexto".\n'
          'Length-of-length: $lengthOfLength (esperado: ≤8).\n'
          'Estrutura DER malformada.',
          codigo: 'ERRO_ASN1_LENGTH_INVALIDO',
          diagnostico: {
            'contexto': contexto,
            'length_of_length': lengthOfLength,
            'maximo_esperado': 8,
          },
        );
      }

      offset = 1 + 1 + lengthOfLength;

      // Validar que há bytes suficientes para o header completo
      if (offset > bytes.length) {
        throw ExcecaoAssinaturaCertificado(
          'Estrutura ASN.1 truncada em "$contexto".\n'
          'Offset calculado: $offset, comprimento disponível: ${bytes.length}.\n'
          'Header ASN.1 incompleto - certificado corrompido.',
          codigo: 'ERRO_ASN1_HEADER_INCOMPLETO',
          diagnostico: {
            'contexto': contexto,
            'offset_calculado': offset,
            'bytes_disponiveis': bytes.length,
          },
        );
      }
    }

    return offset;
  }

  /// Extrai sublist com validação de bounds
  ///
  /// Lança [ExcecaoAssinaturaCertificado] com códigos:
  /// - ERRO_ASN1_OFFSET_INVALIDO: Offset fora dos limites
  /// - ERRO_ASN1_CONTEUDO_VAZIO: Conteúdo vazio
  Uint8List _extrairSublistSegura(
    Uint8List bytes,
    int offset,
    String contexto,
  ) {
    if (offset < 0 || offset > bytes.length) {
      throw ExcecaoAssinaturaCertificado(
        'Offset fora dos limites em "$contexto".\n'
        'Offset: $offset, comprimento total: ${bytes.length}.\n'
        'Estrutura ASN.1 malformada ou corrompida.',
        codigo: 'ERRO_ASN1_OFFSET_INVALIDO',
        diagnostico: {
          'contexto': contexto,
          'offset': offset,
          'comprimento_total': bytes.length,
        },
      );
    }

    if (offset == bytes.length) {
      throw ExcecaoAssinaturaCertificado(
        'Conteúdo ASN.1 vazio em "$contexto".\n'
        'Offset aponta para o fim do buffer.\n'
        'Estrutura incompleta ou certificado corrompido.',
        codigo: 'ERRO_ASN1_CONTEUDO_VAZIO',
        diagnostico: {
          'contexto': contexto,
          'offset': offset,
          'comprimento_total': bytes.length,
        },
      );
    }

    return Uint8List.sublistView(bytes, offset);
  }

  /// Extrai bytes de CONTEXT_SPECIFIC tag
  Uint8List _extrairBytesDeContextSpecific(
    asn1.ASN1Object context, {
    bool isOctetString = false,
  }) {
    final bytes = context.encodedBytes;
    final offset = _calcularOffsetDerSeguro(bytes, 'CONTEXT_SPECIFIC tag');
    return _extrairSublistSegura(bytes, offset, 'CONTEXT_SPECIFIC content');
  }

  /// Descriptografia PBE (Password Based Encryption)
  Uint8List _pbeDecrypt(
    String algorithmOid,
    asn1.ASN1Sequence params,
    Uint8List encryptedData,
    String senha,
  ) {
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
        return _pbeWithSHAAnd3KeyTripleDESCBC(
          senhaBytes,
          salt,
          iterations,
          encryptedData,
        );

      case '1.2.840.113549.1.12.1.6': // pbeWithSHAAnd40BitRC2-CBC
        return _pbeWithSHAAnd40BitRC2CBC(
          senhaBytes,
          salt,
          iterations,
          encryptedData,
        );

      case '1.2.840.113549.1.5.13': // PBES2
        return _pbes2Decrypt(params, encryptedData, senhaBytes);

      default:
        throw ExcecaoAssinaturaCertificado(
          'Algoritmo PBE não suportado: $algorithmOid',
        );
    }
  }

  /// PBE com SHA1 e 3-Key Triple DES CBC
  Uint8List _pbeWithSHAAnd3KeyTripleDESCBC(
    Uint8List senha,
    Uint8List salt,
    int iterations,
    Uint8List data,
  ) {
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
  Uint8List _pbeWithSHAAnd40BitRC2CBC(
    Uint8List senha,
    Uint8List salt,
    int iterations,
    Uint8List data,
  ) {
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
  Uint8List _pbes2Decrypt(
    asn1.ASN1Sequence params,
    Uint8List data,
    Uint8List senha,
  ) {
    final kdfSeq = params.elements[0] as asn1.ASN1Sequence;
    final encSchemeSeq = params.elements[1] as asn1.ASN1Sequence;

    final kdfParams = kdfSeq.elements[1] as asn1.ASN1Sequence;
    final salt = (kdfParams.elements[0] as asn1.ASN1OctetString).valueBytes();
    final iterations = (kdfParams.elements[1] as asn1.ASN1Integer).intValue;

    int keyLength = 32;
    if (kdfParams.elements.length > 2 &&
        kdfParams.elements[2] is asn1.ASN1Integer) {
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
  Uint8List _pkcs12Kdf(
    Uint8List senha,
    Uint8List salt,
    int iterations,
    int id,
    int keyLength,
  ) {
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
    final pLen = senhaUtf16.isEmpty
        ? 0
        : v * ((senhaUtf16.length + v - 1) ~/ v);
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

      final copyLen = (keyLength - resultOffset) < u
          ? (keyLength - resultOffset)
          : u;
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
    if (paddingLength > data.length) {
      throw ExcecaoAssinaturaCertificado(
        'PKCS#7 padding inválido.\n'
        'Padding: $paddingLength bytes, comprimento: ${data.length} bytes.\n'
        'Possível senha incorreta ou dados corrompidos.',
        codigo: 'ERRO_PADDING_INVALIDO',
        diagnostico: {
          'padding_length': paddingLength,
          'data_length': data.length,
        },
      );
    }
    return Uint8List.sublistView(data, 0, data.length - paddingLength);
  }

  /// Extrai chave privada não encriptada de um KeyBag
  pc.RSAPrivateKey _extrairChavePrivadaDeBag(asn1.ASN1Sequence safeBag) {
    try {
      final keyBagContext = safeBag.elements[1];
      final keyBagBytes = keyBagContext.encodedBytes;

      final offset = _calcularOffsetDerSeguro(keyBagBytes, 'KeyBag context');
      final keyParser = asn1.ASN1Parser(
        _extrairSublistSegura(keyBagBytes, offset, 'KeyBag'),
      );
      final privateKeyInfo = keyParser.nextObject() as asn1.ASN1Sequence;

      final privateKeyOctet =
          privateKeyInfo.elements[2] as asn1.ASN1OctetString;
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

      final offset = _calcularOffsetDerSeguro(certBagBytes, 'CertBag context');
      final certBagParser = asn1.ASN1Parser(
        _extrairSublistSegura(certBagBytes, offset, 'CertBag'),
      );
      final certBagSequence = certBagParser.nextObject() as asn1.ASN1Sequence;
      final certType =
          (certBagSequence.elements[0] as asn1.ASN1ObjectIdentifier).identifier;

      if (certType != '1.2.840.113549.1.9.22.1') {
        throw ExcecaoAssinaturaCertificado(
          'Tipo de certificado não suportado: $certType',
        );
      }

      final certContext = certBagSequence.elements[1];
      final certContextBytes = certContext.encodedBytes;

      final certOffset = _calcularOffsetDerSeguro(
        certContextBytes,
        'Certificate context',
      );
      final certParser = asn1.ASN1Parser(
        _extrairSublistSegura(certContextBytes, certOffset, 'Certificate'),
      );
      final certOctet = certParser.nextObject() as asn1.ASN1OctetString;
      final certBytes = certOctet.valueBytes();

      return base64.encode(certBytes);
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro ao extrair certificado: $e');
    }
  }

  /// Extrai informações do certificado X.509 dos bytes
  InformacoesCertificado _extrairInformacoesCertificadoDeBytes(
    Uint8List certBytes,
  ) {
    try {
      final parser = asn1.ASN1Parser(certBytes);
      final certSequence = parser.nextObject() as asn1.ASN1Sequence;
      final tbsCertificate = certSequence.elements[0] as asn1.ASN1Sequence;

      final serialNumber = (tbsCertificate.elements[1] as asn1.ASN1Integer)
          .valueAsBigInteger
          .toString();

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
        tipo: cpfCnpj != null && cpfCnpj.length == 11
            ? TipoCertificado.eCPF
            : TipoCertificado.eCNPJ,
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

  _DadosPkcs12({
    required this.chavePrivada,
    required this.certificado,
    required this.info,
  });
}

/// Dados parciais extraídos durante o processamento
class _DadosParciais {
  final pc.RSAPrivateKey? chavePrivada;
  final String? certificado;

  _DadosParciais({this.chavePrivada, this.certificado});
}
