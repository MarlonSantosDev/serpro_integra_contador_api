/// Modelo de dados para consultar última declaração PGDASD
///
/// Representa os dados necessários para consultar a última declaração transmitida
/// através do serviço CONSULTIMADECREC14
class ConsultarUltimaDeclaracaoRequest {
  /// Período de apuração mensal. Formato: AAAAMM
  final String periodoApuracao;

  ConsultarUltimaDeclaracaoRequest({required this.periodoApuracao});

  /// Valida se o período de apuração está no formato correto (AAAAMM)
  bool get isPeriodoValido {
    if (periodoApuracao.length != 6) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao)) return false;

    final ano = int.parse(periodoApuracao.substring(0, 4));
    final mes = int.parse(periodoApuracao.substring(4, 6));

    return ano >= 2018 && ano <= 9999 && mes >= 1 && mes <= 12;
  }

  /// Valida se todos os campos estão corretos
  bool get isValid => isPeriodoValido;

  Map<String, dynamic> toJson() {
    return {'periodoApuracao': periodoApuracao};
  }

  factory ConsultarUltimaDeclaracaoRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarUltimaDeclaracaoRequest(periodoApuracao: json['periodoApuracao'] as String);
  }
}
