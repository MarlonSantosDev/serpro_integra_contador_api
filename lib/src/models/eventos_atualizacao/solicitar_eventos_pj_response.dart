import 'mensagem_eventos_atualizacao.dart';

/// Modelo de resposta para solicitar eventos de atualização de Pessoa Jurídica
class SolicitarEventosPJResponse {
  final int status;
  final List<MensagemEventosAtualizacao> mensagens;
  final SolicitarEventosPJDados dados;

  SolicitarEventosPJResponse({required this.status, required this.mensagens, required this.dados});

  factory SolicitarEventosPJResponse.fromJson(Map<String, dynamic> json) {
    return SolicitarEventosPJResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemEventosAtualizacao.fromJson(e as Map<String, dynamic>)).toList(),
      dados: SolicitarEventosPJDados.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}

/// Dados retornados na solicitação de eventos PJ
class SolicitarEventosPJDados {
  final String protocolo;
  final int tempoEsperaMedioEmMs;
  final int tempoLimiteEmMin;

  SolicitarEventosPJDados({required this.protocolo, required this.tempoEsperaMedioEmMs, required this.tempoLimiteEmMin});

  factory SolicitarEventosPJDados.fromJson(Map<String, dynamic> json) {
    return SolicitarEventosPJDados(
      protocolo: json['protocolo'].toString(),
      tempoEsperaMedioEmMs: int.parse(json['TempoEsperaMedioEmMs'].toString()),
      tempoLimiteEmMin: int.parse(json['TempoLimiteEmMin'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'protocolo': protocolo, 'TempoEsperaMedioEmMs': tempoEsperaMedioEmMs, 'TempoLimiteEmMin': tempoLimiteEmMin};
  }
}
