/// Modelo de dados para gerar DAS PGDASD
///
/// Representa os dados necessários para gerar um DAS através do serviço GERARDAS12
class GerarDasRequest {
  /// Período de Apuração no formato AAAAMM
  final String periodoApuracao;

  /// Data de consolidação no formato AAAAMMDD - Data futura
  final String? dataConsolidacao;

  GerarDasRequest({required this.periodoApuracao, this.dataConsolidacao});

  /// Valida se o período de apuração está no formato correto (AAAAMM)
  bool get isPeriodoValido {
    if (periodoApuracao.length != 6) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao)) return false;

    final ano = int.parse(periodoApuracao.substring(0, 4));
    final mes = int.parse(periodoApuracao.substring(4, 6));

    return ano >= 2018 && ano <= 9999 && mes >= 1 && mes <= 12;
  }

  /// Valida se a data de consolidação está no formato correto (AAAAMMDD)
  bool get isDataConsolidacaoValida {
    if (dataConsolidacao == null) return true;
    if (dataConsolidacao!.length != 8) return false;
    if (!RegExp(r'^\d{8}$').hasMatch(dataConsolidacao!)) return false;

    final ano = int.parse(dataConsolidacao!.substring(0, 4));
    final mes = int.parse(dataConsolidacao!.substring(4, 6));
    final dia = int.parse(dataConsolidacao!.substring(6, 8));

    return ano >= 2018 &&
        ano <= 9999 &&
        mes >= 1 &&
        mes <= 12 &&
        dia >= 1 &&
        dia <= 31;
  }

  /// Valida se a data de consolidação é futura
  bool get isDataConsolidacaoFutura {
    if (dataConsolidacao == null) return true;

    final hoje = DateTime.now();
    final dataConsolidacaoDate = DateTime(
      int.parse(dataConsolidacao!.substring(0, 4)),
      int.parse(dataConsolidacao!.substring(4, 6)),
      int.parse(dataConsolidacao!.substring(6, 8)),
    );

    return dataConsolidacaoDate.isAfter(hoje);
  }

  /// Valida se todos os campos estão corretos
  bool get isValid {
    if (!isPeriodoValido) return false;
    if (!isDataConsolidacaoValida) return false;
    if (!isDataConsolidacaoFutura) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      if (dataConsolidacao != null) 'dataConsolidacao': dataConsolidacao,
    };
  }

  factory GerarDasRequest.fromJson(Map<String, dynamic> json) {
    return GerarDasRequest(
      periodoApuracao: json['periodoApuracao'].toString(),
      dataConsolidacao: json['dataConsolidacao']?.toString(),
    );
  }
}
