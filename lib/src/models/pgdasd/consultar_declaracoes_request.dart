/// Modelo de dados para consultar declarações PGDASD
///
/// Representa os dados necessários para consultar declarações transmitidas
/// através do serviço CONSDECLARACAO13
class ConsultarDeclaracoesRequest {
  /// Ano-calendário da declaração (formato: AAAA)
  final String? anoCalendario;

  /// Período da apuração mensal (formato: AAAAMM)
  final String? periodoApuracao;

  ConsultarDeclaracoesRequest({this.anoCalendario, this.periodoApuracao});

  /// Construtor para consulta por ano-calendário
  factory ConsultarDeclaracoesRequest.porAnoCalendario(String anoCalendario) {
    return ConsultarDeclaracoesRequest(anoCalendario: anoCalendario);
  }

  /// Construtor para consulta por período de apuração
  factory ConsultarDeclaracoesRequest.porPeriodoApuracao(String periodoApuracao) {
    return ConsultarDeclaracoesRequest(periodoApuracao: periodoApuracao);
  }

  /// Valida se o ano-calendário está no formato correto (AAAA)
  bool get isAnoCalendarioValido {
    if (anoCalendario == null) return true;
    if (anoCalendario!.length != 4) return false;
    if (!RegExp(r'^\d{4}$').hasMatch(anoCalendario!)) return false;

    final ano = int.parse(anoCalendario!);
    return ano >= 2018 && ano <= 9999;
  }

  /// Valida se o período de apuração está no formato correto (AAAAMM)
  bool get isPeriodoApuracaoValido {
    if (periodoApuracao == null) return true;
    if (periodoApuracao!.length != 6) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao!)) return false;

    final ano = int.parse(periodoApuracao!.substring(0, 4));
    final mes = int.parse(periodoApuracao!.substring(4, 6));

    return ano >= 2018 && ano <= 9999 && mes >= 1 && mes <= 12;
  }

  /// Valida se exatamente um parâmetro foi informado
  bool get isParametroUnico {
    final temAno = anoCalendario != null && anoCalendario!.isNotEmpty;
    final temPeriodo = periodoApuracao != null && periodoApuracao!.isNotEmpty;

    return (temAno && !temPeriodo) || (!temAno && temPeriodo);
  }

  /// Valida se pelo menos um parâmetro foi informado
  bool get temParametro {
    return (anoCalendario != null && anoCalendario!.isNotEmpty) || (periodoApuracao != null && periodoApuracao!.isNotEmpty);
  }

  /// Valida se todos os campos estão corretos
  bool get isValid {
    if (!temParametro) return false;
    if (!isParametroUnico) return false;
    if (!isAnoCalendarioValido) return false;
    if (!isPeriodoApuracaoValido) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (anoCalendario != null && anoCalendario!.isNotEmpty) {
      json['anoCalendario'] = anoCalendario;
    }

    if (periodoApuracao != null && periodoApuracao!.isNotEmpty) {
      json['periodoApuracao'] = periodoApuracao;
    }

    return json;
  }

  factory ConsultarDeclaracoesRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarDeclaracoesRequest(anoCalendario: json['anoCalendario'] as String?, periodoApuracao: json['periodoApuracao'] as String?);
  }
}
