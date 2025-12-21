import 'dart:convert';
import '../io/file_io.dart';

/// Modelo para gerenciamento de assinatura digital
class AssinaturaDigitalModel {
  final String? certificadoPath;
  final String? certificadoPassword;
  final String? certificadoBase64;
  final String? chavePrivada;
  final String? certificadoSerial;
  final String? certificadoSubject;
  final DateTime? certificadoValidadeInicio;
  final DateTime? certificadoValidadeFim;
  final bool isValido;

  AssinaturaDigitalModel({
    this.certificadoPath,
    this.certificadoPassword,
    this.certificadoBase64,
    this.chavePrivada,
    this.certificadoSerial,
    this.certificadoSubject,
    this.certificadoValidadeInicio,
    this.certificadoValidadeFim,
    this.isValido = false,
  });

  /// Cria modelo a partir de arquivo de certificado
  factory AssinaturaDigitalModel.fromFile({required String certificadoPath, required String certificadoPassword}) {
    return AssinaturaDigitalModel(certificadoPath: certificadoPath, certificadoPassword: certificadoPassword);
  }

  /// Cria modelo a partir de certificado em base64
  factory AssinaturaDigitalModel.fromBase64({required String certificadoBase64, required String chavePrivada}) {
    return AssinaturaDigitalModel(certificadoBase64: certificadoBase64, chavePrivada: chavePrivada);
  }

  /// Valida o certificado digital
  Future<bool> validarCertificado() async {
    try {
      // Verificar se o certificado existe (se for arquivo)
      if (certificadoPath != null) {
        if (!await FileIO.fileExists(certificadoPath!)) {
          return false;
        }
      }

      // Verificar se tem dados do certificado
      if (certificadoBase64 == null && certificadoPath == null) {
        return false;
      }

      // Verificar se tem chave privada
      if (chavePrivada == null && certificadoPassword == null) {
        return false;
      }

      // Aqui seria feita a validação da cadeia de certificação
      // e verificação se é um certificado válido ICP-Brasil

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Assina o XML conforme padrão XMLDSig
  Future<String> assinarXml(String xml) async {
    try {
      // Esta é uma implementação simulada para demonstração

      // Em produção, aqui seria feita a assinatura real usando:
      // - Biblioteca de criptografia (como pointycastle)
      // - Validação do certificado ICP-Brasil
      // - Geração da assinatura XMLDSig conforme W3C

      final assinaturaSimulada = _gerarAssinaturaSimulada(xml);
      return _inserirAssinaturaNoXml(xml, assinaturaSimulada);
    } catch (e) {
      throw Exception('Erro ao assinar XML: $e');
    }
  }

  /// Gera assinatura simulada para demonstração
  String _gerarAssinaturaSimulada(String xml) {
    // Esta é apenas uma simulação - NÃO USE EM PRODUÇÃO
    final hash = xml.hashCode.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    return '''<SignedInfo>
        <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
        <SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsigmore#rsa-sha256"/>
        <Reference URI="">
            <Transforms>
                <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
            </Transforms>
            <DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
            <DigestValue>${base64.encode(utf8.encode(hash))}</DigestValue>
        </Reference>
    </SignedInfo>
    <SignatureValue>${base64.encode(utf8.encode('SIMULADO_$timestamp'))}</SignatureValue>
    <KeyInfo>
        <X509Data>
            <X509Certificate>${base64.encode(utf8.encode('CERTIFICADO_SIMULADO_$timestamp'))}</X509Certificate>
        </X509Data>
    </KeyInfo>''';
  }

  /// Insere a assinatura no XML
  String _inserirAssinaturaNoXml(String xml, String assinatura) {
    // Substitui o placeholder da assinatura pelo conteúdo real
    return xml.replaceAll('<!-- Assinatura digital será inserida aqui -->', assinatura);
  }

  /// Verifica se o certificado está dentro da validade
  bool get isCertificadoValido {
    if (certificadoValidadeInicio == null || certificadoValidadeFim == null) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(certificadoValidadeInicio!) && now.isBefore(certificadoValidadeFim!);
  }

  /// Obtém informações do certificado
  Map<String, dynamic> get informacoesCertificado {
    return {
      'serial': certificadoSerial,
      'subject': certificadoSubject,
      'validade_inicio': certificadoValidadeInicio?.toIso8601String(),
      'validade_fim': certificadoValidadeFim?.toIso8601String(),
      'is_valido': isCertificadoValido,
      'tempo_restante': certificadoValidadeFim != null ? certificadoValidadeFim!.difference(DateTime.now()).inDays : null,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'certificado_path': certificadoPath,
      'certificado_base64': certificadoBase64,
      'certificado_serial': certificadoSerial,
      'certificado_subject': certificadoSubject,
      'validade_inicio': certificadoValidadeInicio?.toIso8601String(),
      'validade_fim': certificadoValidadeFim?.toIso8601String(),
      'is_valido': isValido,
      'is_certificado_valido': isCertificadoValido,
    };
  }

  @override
  String toString() {
    return 'AssinaturaDigitalModel(serial: $certificadoSerial, '
        'valido: $isValido, certificado_valido: $isCertificadoValido)';
  }
}

/// Enum para tipos de certificado
enum TipoCertificado {
  ecpf('eCPF', 'Pessoa Física'),
  ecnpj('eCNPJ', 'Pessoa Jurídica');

  const TipoCertificado(this.codigo, this.descricao);

  final String codigo;
  final String descricao;
}

/// Enum para formato de certificado
enum FormatoCertificado {
  a1('A1', 'Arquivo no computador'),
  a3('A3', 'Token ou Smart Card');

  const FormatoCertificado(this.codigo, this.descricao);

  final String codigo;
  final String descricao;
}

/// Modelo para configuração de assinatura
class ConfiguracaoAssinatura {
  final TipoCertificado tipoCertificado;
  final FormatoCertificado formatoCertificado;
  final String algoritmoHash;
  final String algoritmoAssinatura;
  final bool incluirCadeiaCompleta;

  ConfiguracaoAssinatura({
    required this.tipoCertificado,
    required this.formatoCertificado,
    this.algoritmoHash = 'http://www.w3.org/2001/04/xmlenc#sha256',
    this.algoritmoAssinatura = 'http://www.w3.org/2001/04/xmldsigmore#rsa-sha256',
    this.incluirCadeiaCompleta = false,
  });

  /// Configuração padrão para ICP-Brasil
  factory ConfiguracaoAssinatura.padraoICPBrasil({required TipoCertificado tipoCertificado, required FormatoCertificado formatoCertificado}) {
    return ConfiguracaoAssinatura(
      tipoCertificado: tipoCertificado,
      formatoCertificado: formatoCertificado,
      algoritmoHash: 'http://www.w3.org/2001/04/xmlenc#sha256',
      algoritmoAssinatura: 'http://www.w3.org/2001/04/xmldsigmore#rsa-sha256',
      incluirCadeiaCompleta: false, // EndCertOnly conforme especificação
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_certificado': tipoCertificado.codigo,
      'formato_certificado': formatoCertificado.codigo,
      'algoritmo_hash': algoritmoHash,
      'algoritmo_assinatura': algoritmoAssinatura,
      'incluir_cadeia_completa': incluirCadeiaCompleta,
    };
  }
}
