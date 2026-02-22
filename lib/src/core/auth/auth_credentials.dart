import '../../util/validacoes_utils.dart';
import 'auth_exceptions.dart';

/// Encapsula e valida as credenciais de autenticação da API SERPRO
///
/// Suporta certificados via:
/// - **certBase64**: Certificado em Base64 (recomendado - mais portátil)
/// - **certPath**: Caminho do arquivo P12/PFX (alternativa)
class AuthCredentials {
  /// Consumer Key OAuth2 fornecido pelo SERPRO
  final String consumerKey;

  /// Consumer Secret OAuth2 fornecido pelo SERPRO
  final String consumerSecret;

  /// Caminho para o arquivo de certificado digital (P12/PFX)
  /// Obrigatório em ambiente de produção se certBase64 não for fornecido
  final String? certPath;

  /// Certificado digital em Base64 (P12/PFX)
  /// Obrigatório em ambiente de produção se certPath não for fornecido
  /// Recomendado por ser mais portátil e não depender do sistema de arquivos
  final String? certBase64;

  /// Senha do certificado digital
  /// Obrigatória em ambiente de produção
  final String? certPassword;

  /// CNPJ da empresa que contratou o serviço na Loja Serpro
  final String contratanteNumero;

  /// CPF/CNPJ do autor da requisição (pode ser procurador/contador)
  final String autorPedidoDadosNumero;

  /// Ambiente de execução: 'trial' para testes ou 'producao' para produção
  final String ambiente;

  /// Constrói [AuthCredentials] com os parâmetros fornecidos.
  AuthCredentials({
    required this.consumerKey,
    required this.consumerSecret,
    this.certPath,
    this.certBase64,
    this.certPassword,
    required this.contratanteNumero,
    required this.autorPedidoDadosNumero,
    required this.ambiente,
  });

  /// Valida todas as credenciais
  ///
  /// Lança [InvalidCredentialsException] se houver problemas com as credenciais
  /// Lança [ArgumentError] se documentos forem inválidos
  /// Lança [CertificateException] se certificado for obrigatório mas não fornecido
  void validate() {
    // Validar consumer credentials
    if (consumerKey.isEmpty) {
      throw InvalidCredentialsException(
        'Consumer Key não pode ser vazio',
        field: 'consumerKey',
      );
    }

    if (consumerSecret.isEmpty) {
      throw InvalidCredentialsException(
        'Consumer Secret não pode ser vazio',
        field: 'consumerSecret',
      );
    }

    // Validar números de documentos
    if (!ValidacoesUtils.isValidDocument(contratanteNumero)) {
      throw ArgumentError('Número do contratante inválido: $contratanteNumero');
    }

    if (!ValidacoesUtils.isValidDocument(autorPedidoDadosNumero)) {
      throw ArgumentError(
        'Número do autor do pedido inválido: $autorPedidoDadosNumero',
      );
    }

    // Validar ambiente
    if (ambiente != 'trial' && ambiente != 'producao') {
      throw ArgumentError('Ambiente deve ser "trial" ou "producao"');
    }

    // Produção requer certificados (via Base64 ou arquivo)
    if (isProduction && !hasCertificate) {
      throw CertificateException(
        'Certificado é obrigatório em ambiente de produção. '
        'Forneça certBase64 (recomendado) ou certPath.',
        reason: CertificateErrorReason.requiredForProduction,
      );
    }

    // Se tem certificado, senha é obrigatória
    if (isProduction &&
        hasCertificate &&
        (certPassword == null || certPassword!.isEmpty)) {
      throw CertificateException(
        'Senha do certificado é obrigatória em ambiente de produção',
        reason: CertificateErrorReason.invalidPassword,
      );
    }
  }

  /// Verifica se tem certificado disponível (Base64 ou arquivo)
  bool get hasCertificate {
    final hasBase64 = certBase64 != null && certBase64!.trim().isNotEmpty;
    final hasPath = certPath != null && certPath!.trim().isNotEmpty;
    return hasBase64 || hasPath;
  }

  /// Verifica se mTLS está configurado (certificado e senha fornecidos)
  bool get requiresMtls => hasCertificate && certPassword != null;

  /// Verifica se está em ambiente de produção
  bool get isProduction => ambiente == 'producao';

  /// Verifica se está em ambiente de trial
  bool get isTrial => ambiente == 'trial';

  @override
  String toString() {
    return 'AuthCredentials('
        'ambiente: $ambiente, '
        'contratante: $contratanteNumero, '
        'autor: $autorPedidoDadosNumero, '
        'hasCertificate: $hasCertificate, '
        'certSource: ${certBase64 != null
            ? "base64"
            : certPath != null
            ? "file"
            : "none"}'
        ')';
  }
}
