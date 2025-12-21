import 'dart:convert';
import 'regime_apuracao_enums.dart';
import '../../../base/mensagem_negocio.dart';

/// Modelo de dados de resposta para consultar anos calendários
///
/// Representa a resposta do serviço CONSULTARANOSCALENDARIOS102
class ConsultarAnosCalendariosResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio> mensagens;

  /// Lista de anos calendários com opções efetivadas
  final List<AnoCalendarioRegime>? dados;

  ConsultarAnosCalendariosResponse({required this.status, required this.mensagens, this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get isSuccess => status == 200;

  /// Indica se há mensagens de erro
  bool get hasErrors => mensagens.any((m) => m.codigo.contains('Erro'));

  /// Indica se há mensagens de aviso
  bool get hasWarnings => mensagens.any((m) => m.codigo.contains('Aviso'));

  /// Indica se há dados disponíveis
  bool get hasData => dados != null && dados!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      if (dados != null) 'dados': dados!.map((d) => d.toJson()).toList(),
    };
  }

  factory ConsultarAnosCalendariosResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarAnosCalendariosResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList(),
      dados: json['dados'] != null ? (jsonDecode(json['dados']) as List).map((d) => AnoCalendarioRegime.fromJson(d)).toList() : null,
    );
  }
}

/// Modelo de dados para ano calendário com regime efetivado
///
/// Representa um ano calendário com sua opção de regime efetivada
class AnoCalendarioRegime {
  /// Ano calendário
  final int anoCalendario;

  /// Texto com o regime efetivado: "COMPETENCIA" ou "CAIXA"
  final String regimeApurado;

  /// Construtor para criar uma instância de AnoCalendarioRegime
  ///
  /// [anoCalendario] O ano calendário
  /// [regimeApurado] O regime apurado ("COMPETENCIA" ou "CAIXA")
  AnoCalendarioRegime({required this.anoCalendario, required this.regimeApurado});

  /// Converte o regime apurado para enum
  TipoRegime? get tipoRegime => TipoRegime.fromDescricao(regimeApurado);

  /// Indica se o regime é de competência
  bool get isCompetencia => regimeApurado.toUpperCase() == 'COMPETENCIA';

  /// Indica se o regime é de caixa
  bool get isCaixa => regimeApurado.toUpperCase() == 'CAIXA';

  /// Converte a instância para um mapa JSON
  ///
  /// Retorna um [Map] com as chaves 'anoCalendario' e 'regimeApurado'
  Map<String, dynamic> toJson() {
    return {'anoCalendario': anoCalendario, 'regimeApurado': regimeApurado};
  }

  /// Cria uma instância de AnoCalendarioRegime a partir de um mapa JSON
  ///
  /// [json] Mapa contendo os dados do ano calendário e regime apurado
  /// Retorna uma nova instância de [AnoCalendarioRegime]
  factory AnoCalendarioRegime.fromJson(Map<String, dynamic> json) {
    return AnoCalendarioRegime(anoCalendario: int.parse(json['anoCalendario'].toString()), regimeApurado: json['regimeApurado'].toString());
  }
}
