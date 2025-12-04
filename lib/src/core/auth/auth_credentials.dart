import '../../util/validacoes_utils.dart';
import 'auth_exceptions.dart';

/// Encapsula e valida as credenciais de autenticação da API SERPRO
class AuthCredentials {
  /// Consumer Key OAuth2 fornecido pelo SERPRO
  final String consumerKey;

  /// Consumer Secret OAuth2 fornecido pelo SERPRO
  final String consumerSecret;

  /// Caminho para o arquivo de certificado digital (P12/PFX)
  /// Obrigatório em ambiente de produção
  final String? certPath;

  /// Senha do certificado digital
  /// Obrigatória em ambiente de produção
  final String? certPassword;

  /// CNPJ da empresa que contratou o serviço na Loja Serpro
  final String contratanteNumero;

  /// CPF/CNPJ do autor da requisição (pode ser procurador/contador)
  final String autorPedidoDadosNumero;

  /// Ambiente de execução: 'trial' para testes ou 'producao' para produção
  final String ambiente;

  AuthCredentials({
    required this.consumerKey,
    required this.consumerSecret,
    this.certPath,
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
      throw InvalidCredentialsException('Consumer Key não pode ser vazio', field: 'consumerKey');
    }

    if (consumerSecret.isEmpty) {
      throw InvalidCredentialsException('Consumer Secret não pode ser vazio', field: 'consumerSecret');
    }

    // Validar números de documentos
    if (!ValidacoesUtils.isValidDocument(contratanteNumero)) {
      throw ArgumentError('Número do contratante inválido: $contratanteNumero');
    }

    if (!ValidacoesUtils.isValidDocument(autorPedidoDadosNumero)) {
      throw ArgumentError('Número do autor do pedido inválido: $autorPedidoDadosNumero');
    }

    // Validar ambiente
    if (ambiente != 'trial' && ambiente != 'producao') {
      throw ArgumentError('Ambiente deve ser "trial" ou "producao"');
    }

    // Produção requer certificados
    if (isProduction && !requiresMtls) {
      throw CertificateException(
        'Certificado e senha são obrigatórios em ambiente de produção',
        reason: CertificateErrorReason.requiredForProduction,
      );
    }
  }

  /// Verifica se mTLS está configurado (certificado e senha fornecidos)
  bool get requiresMtls => certPath != null && certPassword != null;

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
        'hasCertificate: $requiresMtls'
        ')';
  }
}
