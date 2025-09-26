/// Utilitários para trabalhar com documentos (CPF/CNPJ)
class DocumentUtils {
  /// Detecta automaticamente o tipo do documento baseado no número
  /// Retorna 1 para CPF (11 dígitos) e 2 para CNPJ (14 dígitos)
  static int detectDocumentType(String numero) {
    // Remove qualquer formatação (pontos, traços, barras)
    final cleanNumber = numero.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length == 11) {
      return 1; // CPF
    } else if (cleanNumber.length == 14) {
      return 2; // CNPJ
    } else {
      throw ArgumentError(
        'Número de documento inválido. Deve conter 11 dígitos (CPF) ou 14 dígitos (CNPJ). Recebido: $cleanNumber',
      );
    }
  }

  /// Limpa a formatação do número do documento
  static String cleanDocumentNumber(String numero) {
    return numero.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Valida se o número tem o formato correto para CPF ou CNPJ
  static bool isValidDocumentLength(String numero) {
    final cleanNumber = cleanDocumentNumber(numero);
    return cleanNumber.length == 11 || cleanNumber.length == 14;
  }
}
