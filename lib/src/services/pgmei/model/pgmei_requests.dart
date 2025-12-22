import 'dart:convert';

/// Modelo de entrada para services PGMEI que requerem apenas período de apuração
class GerarDasRequest {
  /// Período de apuração no formato AAAAMM
  final String periodoApuracao;

  /// Data de consolidação no formato AAAAMMDD (opcional)
  final String? dataConsolidacao;

  GerarDasRequest({required this.periodoApuracao, this.dataConsolidacao});

  /// Converte para JSON string para uso nos dados do pedido
  String toJsonString() {
    final map = <String, dynamic>{'periodoApuracao': periodoApuracao};

    if (dataConsolidacao != null) {
      map['dataConsolidacao'] = dataConsolidacao;
    }

    return jsonEncode(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      if (dataConsolidacao != null) 'dataConsolidacao': dataConsolidacao,
    };
  }
}

/// Modelo de entrada para ATUBENEFICIO23
class AtualizarBeneficioRequest {
  /// Ano calendário no formato AAAA
  final int anoCalendario;

  /// Informação sobre os benefícios por período
  final List<InfoBeneficio> infoBeneficio;

  AtualizarBeneficioRequest({
    required this.anoCalendario,
    required this.infoBeneficio,
  });

  /// Converte para JSON string para uso nos dados do pedido
  String toJsonString() {
    return jsonEncode({
      'anoCalendario': anoCalendario,
      'infoBeneficio': infoBeneficio.map((b) => b.toJson()).toList(),
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'anoCalendario': anoCalendario,
      'infoBeneficio': infoBeneficio.map((b) => b.toJson()).toList(),
    };
  }
}

/// Informação sobre benefício de um período
class InfoBeneficio {
  /// Período de apuração no formato AAAAMM
  final String periodoApuracao;

  /// Indica se houve benefício
  final bool indicadorBeneficio;

  InfoBeneficio({
    required this.periodoApuracao,
    required this.indicadorBeneficio,
  });

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'indicadorBeneficio': indicadorBeneficio,
    };
  }
}

/// Modelo de entrada para DIVIDAATIVA24
class ConsultarDividaAtivaRequest {
  /// Ano calendário no formato AAAA
  final String anoCalendario;

  ConsultarDividaAtivaRequest({required this.anoCalendario});

  /// Converte para JSON string para uso nos dados do pedido
  String toJsonString() {
    return jsonEncode({'anoCalendario': anoCalendario});
  }

  Map<String, dynamic> toJson() {
    return {'anoCalendario': anoCalendario};
  }
}
