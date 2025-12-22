import 'regime_apuracao_enums.dart';

/// Modelo de dados para consultar opção específica de regime por ano
///
/// Representa os dados necessários para consultar a opção pelo regime de apuração
/// através do serviço CONSULTAROPCAOREGIME103
class ConsultarOpcaoRegimeRequest {
  /// Ano Calendário (SIM - Obligatório)
  final int anoCalendario;

  ConsultarOpcaoRegimeRequest({required this.anoCalendario});

  /// Valida se o ano calendário está dentro dos limites permitidos
  bool get isAnoCalendarioValido =>
      RegimeApuracaoValidations.isAnoValido(anoCalendario);

  /// Valida se todos os campos obrigatórios estão preenchidos e válidos
  bool get isValid {
    if (!isAnoCalendarioValido) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {'anoCalendario': anoCalendario};
  }

  factory ConsultarOpcaoRegimeRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarOpcaoRegimeRequest(
      anoCalendario: int.parse(json['anoCalendario'].toString()),
    );
  }
}
