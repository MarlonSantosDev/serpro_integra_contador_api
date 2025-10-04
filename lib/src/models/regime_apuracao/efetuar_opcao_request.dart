import 'regime_apuracao_enums.dart';

/// Modelo de dados para efetuar opção pelo regime de apuração
///
/// Representa os dados necessários para efetuar a opção pelo regime de apuração
/// através do serviço EFETUAROPCAOREGIME101
class EfetuarOpcaoRegimeRequest {
  /// Ano Opção (SIM - Obligatório)
  final int anoOpcao;

  /// Tipo da opção (SIM - Obligatório) (0 = Competência, 1 = Caixa)
  final int tipoRegime;

  /// Descritivo do Regime (SIM - Obligatório) ("COMPETENCIA" ou "CAIXA")
  final String descritivoRegime;

  /// Confirmação obrigatória para efetivar a opção (SIM - Obligatório)
  /// Este campo deve ser enviado como true para ser efetivada a opção
  final bool deAcordoResolucao;

  EfetuarOpcaoRegimeRequest({required this.anoOpcao, required this.tipoRegime, required this.descritivoRegime, required this.deAcordoResolucao});

  /// Valida se o ano da opção está dentro dos limites permitidos
  bool get isAnoOpcaoValido => RegimeApuracaoValidations.isAnoValido(anoOpcao);

  /// Valida se o tipo de regime é válido
  bool get isTipoRegimeValido => RegimeApuracaoValidations.isTipoRegimeValido(tipoRegime);

  /// Valida se o descritivo do regime é válido
  bool get isDescritivoRegimeValido => RegimeApuracaoValidations.isDescritivoRegimeValido(descritivoRegime);

  /// Valida se o descritivo está coerente com o tipo de regime
  bool get isDescritivoCoerenteComTipo => RegimeApuracaoValidations.isDescritivoCoerenteComTipo(tipoRegime, descritivoRegime);

  /// Valida se todos os campos obrigatórios estão preenchidos e válidos
  bool get isValid {
    if (!isAnoOpcaoValido) return false;
    if (!isTipoRegimeValido) return false;
    if (!isDescritivoRegimeValido) return false;
    if (!isDescritivoCoerenteComTipo) return false;
    if (!deAcordoResolucao) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {'anoOpcao': anoOpcao, 'tipoRegime': tipoRegime, 'descritivoRegime': descritivoRegime, 'deAcordoResolucao': deAcordoResolucao};
  }

  factory EfetuarOpcaoRegimeRequest.fromJson(Map<String, dynamic> json) {
    return EfetuarOpcaoRegimeRequest(
      anoOpcao: int.parse(json['anoOpcao'].toString()),
      tipoRegime: int.parse(json['tipoRegime'].toString()),
      descritivoRegime: json['descritivoRegime'].toString(),
      deAcordoResolucao: json['deAcordoResolucao'] as bool,
    );
  }

  /// Cria uma instância para regime de competência
  factory EfetuarOpcaoRegimeRequest.competencia({required int anoOpcao, bool deAcordoResolucao = true}) {
    return EfetuarOpcaoRegimeRequest(
      anoOpcao: anoOpcao,
      tipoRegime: TipoRegime.competencia.codigo,
      descritivoRegime: TipoRegime.competencia.descricao,
      deAcordoResolucao: deAcordoResolucao,
    );
  }

  /// Cria uma instância para regime de caixa
  factory EfetuarOpcaoRegimeRequest.caixa({required int anoOpcao, bool deAcordoResolucao = true}) {
    return EfetuarOpcaoRegimeRequest(
      anoOpcao: anoOpcao,
      tipoRegime: TipoRegime.caixa.codigo,
      descritivoRegime: TipoRegime.caixa.descricao,
      deAcordoResolucao: deAcordoResolucao,
    );
  }
}
