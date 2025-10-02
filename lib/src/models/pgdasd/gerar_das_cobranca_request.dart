/// Modelo de dados para gerar DAS Cobrança PGDASD
///
/// Representa os dados necessários para gerar um DAS Cobrança através do serviço GERARDASCOBRANCA17
class GerarDasCobrancaRequest {
  /// Período de apuração que se deseja gerar o DAS de Cobrança no formato AAAAMM
  final String periodoApuracao;

  GerarDasCobrancaRequest({required this.periodoApuracao});

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

  factory GerarDasCobrancaRequest.fromJson(Map<String, dynamic> json) {
    return GerarDasCobrancaRequest(periodoApuracao: json['periodoApuracao'].toString());
  }
}

