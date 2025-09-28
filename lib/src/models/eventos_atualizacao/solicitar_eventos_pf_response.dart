import 'mensagem_eventos_atualizacao.dart';

/// Modelo de resposta para solicitar eventos de atualização de Pessoa Física
class SolicitarEventosPFResponse {
  final int status;
  final List<MensagemEventosAtualizacao> mensagens;
  final SolicitarEventosPFDados dados;

  SolicitarEventosPFResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory SolicitarEventosPFResponse.fromJson(Map<String, dynamic> json) {
    return SolicitarEventosPFResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map(
            (e) =>
                MensagemEventosAtualizacao.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      dados: SolicitarEventosPFDados.fromJson(
        json['dados'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.toJson(),
    };
  }
}

/// Dados retornados na solicitação de eventos PF
class SolicitarEventosPFDados {
  final String protocolo;
  final int tempoEsperaMedioEmMs;
  final int tempoLimiteEmMin;

  SolicitarEventosPFDados({
    required this.protocolo,
    required this.tempoEsperaMedioEmMs,
    required this.tempoLimiteEmMin,
  });

  factory SolicitarEventosPFDados.fromJson(Map<String, dynamic> json) {
    return SolicitarEventosPFDados(
      protocolo: json['protocolo'].toString(),
      tempoEsperaMedioEmMs: int.parse(json['TempoEsperaMedioEmMs'].toString()),
      tempoLimiteEmMin: int.parse(json['TempoLimiteEmMin'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocolo': protocolo,
      'TempoEsperaMedioEmMs': tempoEsperaMedioEmMs,
      'TempoLimiteEmMin': tempoLimiteEmMin,
    };
  }
}
