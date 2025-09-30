import 'regime_apuracao_enums.dart';

/// Modelo de dados para consultar resolução do regime de caixa
///
/// Representa os dados necessários para consultar a resolução para o regime de caixa
/// através do serviço CONSULTARRESOLUCAO104
class ConsultarResolucaoRequest {
  /// Ano calendário para consulta da resolução (formato: YYYY)
  final int anoCalendario;

  ConsultarResolucaoRequest({required this.anoCalendario});

  /// Valida se o ano calendário está dentro dos limites permitidos
  bool get isAnoCalendarioValido => RegimeApuracaoValidations.isAnoValido(anoCalendario);

  /// Valida se todos os campos obrigatórios estão preenchidos e válidos
  bool get isValid {
    if (!isAnoCalendarioValido) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {'anoCalendario': anoCalendario};
  }

  factory ConsultarResolucaoRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarResolucaoRequest(anoCalendario: int.parse(json['anoCalendario'].toString()));
  }
}
