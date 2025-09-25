/// Modelo de dados para consultar extrato do DAS PGDASD
///
/// Representa os dados necessários para consultar o extrato da apuração do DAS
/// através do serviço CONSEXTRATO16
class ConsultarExtratoDasRequest {
  /// Número do DAS
  final String numeroDas;

  ConsultarExtratoDasRequest({required this.numeroDas});

  /// Valida se o número do DAS está no formato correto (17 dígitos)
  bool get isNumeroValido {
    if (numeroDas.length != 17) return false;
    if (!RegExp(r'^\d{17}$').hasMatch(numeroDas)) return false;
    return true;
  }

  /// Valida se todos os campos estão corretos
  bool get isValid => isNumeroValido;

  Map<String, dynamic> toJson() {
    return {'numeroDas': numeroDas};
  }

  factory ConsultarExtratoDasRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarExtratoDasRequest(numeroDas: json['numeroDas'] as String);
  }
}
