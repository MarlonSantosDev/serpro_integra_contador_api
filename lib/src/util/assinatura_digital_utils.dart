import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/autenticaprocurador/assinatura_digital_model.dart';

/// Utilitários para assinatura digital
class AssinaturaDigitalUtils {
  /// Valida certificado digital ICP-Brasil
  static Future<bool> validarCertificadoICPBrasil({required String certificadoPath, required String senha}) async {
    try {
      // TODO: Implementar validação real do certificado ICP-Brasil
      // Esta é uma implementação simulada para demonstração

      final file = File(certificadoPath);
      if (!await file.exists()) {
        return false;
      }

      // Verificar extensão do arquivo
      final extension = certificadoPath.toLowerCase().split('.').last;
      if (!['p12', 'pfx', 'pem', 'crt'].contains(extension)) {
        return false;
      }

      // Verificar tamanho do arquivo (deve ser razoável)
      final fileSize = await file.length();
      if (fileSize < 1024 || fileSize > 1024 * 1024) {
        // 1KB a 1MB
        return false;
      }

      // Simular validação de certificado
      // Em produção, aqui seria feita a validação real usando bibliotecas de criptografia
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extrai informações do certificado
  static Future<Map<String, dynamic>> extrairInfoCertificado({required String certificadoPath, required String senha}) async {
    try {
      // TODO: Implementar extração real de informações do certificado
      // Esta é uma implementação simulada

      final file = File(certificadoPath);
      final bytes = await file.readAsBytes();

      return {
        'serial': _gerarSerialSimulado(),
        'subject': _gerarSubjectSimulado(),
        'issuer': 'AC SERPRO v5',
        'validade_inicio': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
        'validade_fim': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'tipo': _detectarTipoCertificado(bytes),
        'formato': _detectarFormatoCertificado(certificadoPath),
        'tamanho_bytes': bytes.length,
      };
    } catch (e) {
      throw Exception('Erro ao extrair informações do certificado: $e');
    }
  }

  /// Assina XML conforme padrão XMLDSig
  static Future<String> assinarXml({
    required String xml,
    required String certificadoPath,
    required String senha,
    ConfiguracaoAssinatura? configuracao,
  }) async {
    try {
      // TODO: Implementar assinatura digital real
      // Esta é uma implementação simulada para demonstração

      final config =
          configuracao ?? ConfiguracaoAssinatura.padraoICPBrasil(tipoCertificado: TipoCertificado.ecnpj, formatoCertificado: FormatoCertificado.a1);

      // Validar certificado
      final isValid = await validarCertificadoICPBrasil(certificadoPath: certificadoPath, senha: senha);

      if (!isValid) {
        throw Exception('Certificado digital inválido');
      }

      // Gerar assinatura simulada
      final assinatura = _gerarAssinaturaSimulada(xml, config);

      // Inserir assinatura no XML
      return _inserirAssinaturaNoXml(xml, assinatura);
    } catch (e) {
      throw Exception('Erro ao assinar XML: $e');
    }
  }

  /// Verifica assinatura digital
  static Future<bool> verificarAssinatura({required String xmlAssinado, required String certificadoPath}) async {
    try {
      // TODO: Implementar verificação real de assinatura
      // Esta é uma implementação simulada

      if (!xmlAssinado.contains('<Signature')) {
        return false;
      }

      if (!xmlAssinado.contains('SignatureValue')) {
        return false;
      }

      if (!xmlAssinado.contains('X509Certificate')) {
        return false;
      }

      // Simular verificação bem-sucedida
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gera assinatura simulada para demonstração
  static String _gerarAssinaturaSimulada(String xml, ConfiguracaoAssinatura config) {
    final hash = xml.hashCode.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final serial = _gerarSerialSimulado();

    return '''<SignedInfo>
        <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
        <SignatureMethod Algorithm="${config.algoritmoAssinatura}"/>
        <Reference URI="">
            <Transforms>
                <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
            </Transforms>
            <DigestMethod Algorithm="${config.algoritmoHash}"/>
            <DigestValue>${base64.encode(utf8.encode(hash))}</DigestValue>
        </Reference>
    </SignedInfo>
    <SignatureValue>${base64.encode(utf8.encode('SIMULADO_$timestamp'))}</SignatureValue>
    <KeyInfo>
        <X509Data>
            <X509Certificate>${base64.encode(utf8.encode('CERTIFICADO_SIMULADO_$serial'))}</X509Certificate>
        </X509Data>
    </KeyInfo>''';
  }

  /// Insere assinatura no XML
  static String _inserirAssinaturaNoXml(String xml, String assinatura) {
    return xml.replaceAll('<!-- Assinatura digital será inserida aqui -->', assinatura);
  }

  /// Gera serial simulado
  static String _gerarSerialSimulado() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SIMULADO_${timestamp.toString().substring(8)}';
  }

  /// Gera subject simulado
  static String _gerarSubjectSimulado() {
    return 'CN=EMPRESA SIMULADA, OU=TI, O=EMPRESA LTDA, L=SAO PAULO, ST=SP, C=BR';
  }

  /// Detecta tipo de certificado
  static String _detectarTipoCertificado(Uint8List bytes) {
    // Simulação baseada no tamanho do arquivo
    if (bytes.length > 5000) {
      return 'eCNPJ';
    } else {
      return 'eCPF';
    }
  }

  /// Detecta formato do certificado
  static String _detectarFormatoCertificado(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'p12':
      case 'pfx':
        return 'A1';
      case 'pem':
      case 'crt':
        return 'A3';
      default:
        return 'A1';
    }
  }

  /// Valida estrutura da assinatura XMLDSig
  static List<String> validarEstruturaAssinatura(String xmlAssinado) {
    final erros = <String>[];

    try {
      // Verificar se contém tag Signature
      if (!xmlAssinado.contains('<Signature')) {
        erros.add('Tag Signature não encontrada');
      }

      // Verificar SignedInfo
      if (!xmlAssinado.contains('<SignedInfo')) {
        erros.add('Tag SignedInfo não encontrada');
      }

      // Verificar SignatureValue
      if (!xmlAssinado.contains('<SignatureValue')) {
        erros.add('Tag SignatureValue não encontrada');
      }

      // Verificar KeyInfo
      if (!xmlAssinado.contains('<KeyInfo')) {
        erros.add('Tag KeyInfo não encontrada');
      }

      // Verificar X509Data
      if (!xmlAssinado.contains('<X509Data')) {
        erros.add('Tag X509Data não encontrada');
      }

      // Verificar X509Certificate
      if (!xmlAssinado.contains('<X509Certificate')) {
        erros.add('Tag X509Certificate não encontrada');
      }

      // Verificar algoritmos obrigatórios
      if (!xmlAssinado.contains('http://www.w3.org/2001/04/xmldsigmore#rsa-sha256')) {
        erros.add('Algoritmo de assinatura RSA-SHA256 não encontrado');
      }

      if (!xmlAssinado.contains('http://www.w3.org/2001/04/xmlenc#sha256')) {
        erros.add('Algoritmo de hash SHA-256 não encontrado');
      }

      if (!xmlAssinado.contains('http://www.w3.org/TR/2001/REC-xml-c14n-20010315')) {
        erros.add('Algoritmo de canonicalização C14N não encontrado');
      }

      if (!xmlAssinado.contains('http://www.w3.org/2000/09/xmldsig#enveloped-signature')) {
        erros.add('Transformação enveloped-signature não encontrada');
      }
    } catch (e) {
      erros.add('Erro ao validar estrutura da assinatura: $e');
    }

    return erros;
  }

  /// Extrai certificado do XML assinado
  static String? extrairCertificado(String xmlAssinado) {
    try {
      final startTag = '<X509Certificate>';
      final endTag = '</X509Certificate>';

      final startIndex = xmlAssinado.indexOf(startTag);
      if (startIndex == -1) return null;

      final endIndex = xmlAssinado.indexOf(endTag, startIndex);
      if (endIndex == -1) return null;

      return xmlAssinado.substring(startIndex + startTag.length, endIndex).trim();
    } catch (e) {
      return null;
    }
  }

  /// Extrai valor da assinatura
  static String? extrairValorAssinatura(String xmlAssinado) {
    try {
      final startTag = '<SignatureValue>';
      final endTag = '</SignatureValue>';

      final startIndex = xmlAssinado.indexOf(startTag);
      if (startIndex == -1) return null;

      final endIndex = xmlAssinado.indexOf(endTag, startIndex);
      if (endIndex == -1) return null;

      return xmlAssinado.substring(startIndex + startTag.length, endIndex).trim();
    } catch (e) {
      return null;
    }
  }

  /// Gera hash SHA-256 de uma string
  static String gerarHashSha256(String input) {
    // TODO: Implementar hash SHA-256 real
    // Esta é uma implementação simulada
    final bytes = utf8.encode(input);
    final hash = bytes.fold(0, (prev, element) => prev + element);
    return base64.encode(utf8.encode(hash.toString()));
  }

  /// Valida se o certificado está dentro da validade
  static bool isCertificadoValido({required DateTime validadeInicio, required DateTime validadeFim}) {
    final now = DateTime.now();
    return now.isAfter(validadeInicio) && now.isBefore(validadeFim);
  }

  /// Calcula dias restantes até expiração do certificado
  static int diasRestantesValidade(DateTime validadeFim) {
    final now = DateTime.now();
    if (now.isAfter(validadeFim)) return 0;
    return validadeFim.difference(now).inDays;
  }

  /// Gera relatório de validação da assinatura
  static Map<String, dynamic> gerarRelatorioValidacao(String xmlAssinado) {
    final relatorio = <String, dynamic>{
      'tem_assinatura': xmlAssinado.contains('<Signature'),
      'tem_signed_info': xmlAssinado.contains('<SignedInfo'),
      'tem_signature_value': xmlAssinado.contains('<SignatureValue'),
      'tem_key_info': xmlAssinado.contains('<KeyInfo'),
      'tem_x509_data': xmlAssinado.contains('<X509Data'),
      'tem_x509_certificate': xmlAssinado.contains('<X509Certificate'),
      'algoritmo_assinatura_correto': xmlAssinado.contains('rsa-sha256'),
      'algoritmo_hash_correto': xmlAssinado.contains('sha256'),
      'canonicalizacao_correta': xmlAssinado.contains('xml-c14n-20010315'),
      'transformacao_correta': xmlAssinado.contains('enveloped-signature'),
      'erros_validacao': validarEstruturaAssinatura(xmlAssinado),
    };

    relatorio['assinatura_valida'] =
        relatorio['erros_validacao'].isEmpty &&
        relatorio['tem_assinatura'] &&
        relatorio['tem_signed_info'] &&
        relatorio['tem_signature_value'] &&
        relatorio['tem_key_info'] &&
        relatorio['tem_x509_data'] &&
        relatorio['tem_x509_certificate'] &&
        relatorio['algoritmo_assinatura_correto'] &&
        relatorio['algoritmo_hash_correto'] &&
        relatorio['canonicalizacao_correta'] &&
        relatorio['transformacao_correta'];

    return relatorio;
  }
}
