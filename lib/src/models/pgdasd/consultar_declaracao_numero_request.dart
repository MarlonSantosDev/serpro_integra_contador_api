/// Modelo de dados para consultar declaração por número PGDASD
///
/// Representa os dados necessários para consultar uma declaração específica
/// através do serviço CONSDECREC15
class ConsultarDeclaracaoNumeroRequest {
  /// Número identificador único da declaração
  final String numeroDeclaracao;

  ConsultarDeclaracaoNumeroRequest({required this.numeroDeclaracao});

  /// Valida se o número da declaração está no formato correto (17 dígitos)
  bool get isNumeroValido {
    if (numeroDeclaracao.length != 17) return false;
    if (!RegExp(r'^\d{17}$').hasMatch(numeroDeclaracao)) return false;
    return true;
  }

  /// Valida se todos os campos estão corretos
  bool get isValid => isNumeroValido;

  Map<String, dynamic> toJson() {
    return {'numeroDeclaracao': numeroDeclaracao};
  }

  factory ConsultarDeclaracaoNumeroRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarDeclaracaoNumeroRequest(
      numeroDeclaracao: json['numeroDeclaracao'] as String,
    );
  }
}
