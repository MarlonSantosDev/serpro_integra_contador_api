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

  /// Valida se é um CPF válido
  static bool isValidCpf(String cpf) {
    final cleanCpf = cleanDocumentNumber(cpf);
    if (cleanCpf.length != 11) return false;

    // Verificar se todos os dígitos são iguais
    if (cleanCpf.split('').every((digit) => digit == cleanCpf[0])) return false;

    // Validar dígitos verificadores
    return _validateCpfDigits(cleanCpf);
  }

  /// Valida se é um CNPJ válido
  static bool isValidCnpj(String cnpj) {
    final cleanCnpj = cleanDocumentNumber(cnpj);
    if (cleanCnpj.length != 14) return false;

    // Verificar se todos os dígitos são iguais
    if (cleanCnpj.split('').every((digit) => digit == cleanCnpj[0]))
      return false;

    // Validar dígitos verificadores
    return _validateCnpjDigits(cleanCnpj);
  }

  /// Valida dígitos verificadores do CPF
  static bool _validateCpfDigits(String cpf) {
    // Primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    if (int.parse(cpf[9]) != firstDigit) return false;

    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    return int.parse(cpf[10]) == secondDigit;
  }

  /// Valida dígitos verificadores do CNPJ
  static bool _validateCnpjDigits(String cnpj) {
    // Primeiro dígito verificador
    int sum = 0;
    int weight = 2;
    for (int i = 11; i >= 0; i--) {
      sum += int.parse(cnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    if (int.parse(cnpj[12]) != firstDigit) return false;

    // Segundo dígito verificador
    sum = 0;
    weight = 2;
    for (int i = 12; i >= 0; i--) {
      sum += int.parse(cnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    return int.parse(cnpj[13]) == secondDigit;
  }
}
