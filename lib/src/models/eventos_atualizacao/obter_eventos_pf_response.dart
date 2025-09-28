import 'dart:convert';
import 'mensagem_eventos_atualizacao.dart';

/// Modelo de resposta para obter eventos de atualização de Pessoa Física
class ObterEventosPFResponse {
  final int status;
  final List<MensagemEventosAtualizacao> mensagens;
  final List<EventoAtualizacaoPF> dados;
  final String? responseId;

  ObterEventosPFResponse({required this.status, required this.mensagens, required this.dados, this.responseId});

  factory ObterEventosPFResponse.fromJson(Map<String, dynamic> json) {
    // Parse dos dados que vêm como string JSON escapada
    List<EventoAtualizacaoPF> eventos = [];
    if (json['dados'] != null) {
      final dadosString = json['dados'].toString();
      if (dadosString.isNotEmpty) {
        try {
          final dadosList = jsonDecode(dadosString) as List<dynamic>;
          eventos = dadosList.map((e) => EventoAtualizacaoPF.fromJson(e as List<dynamic>)).toList();
        } catch (e) {
          // Se não conseguir fazer parse, cria lista vazia
          eventos = [];
        }
      }
    }

    return ObterEventosPFResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemEventosAtualizacao.fromJson(e as Map<String, dynamic>)).toList(),
      dados: eventos,
      responseId: json['responseId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.map((e) => e.toJson()).toList(),
      'responseId': responseId,
    };
  }
}

/// Modelo para um evento de atualização de PF
class EventoAtualizacaoPF {
  final String cpf;
  final String? dataAtualizacao;

  EventoAtualizacaoPF({required this.cpf, this.dataAtualizacao});

  factory EventoAtualizacaoPF.fromJson(List<dynamic> json) {
    return EventoAtualizacaoPF(
      cpf: json[0] as String,
      dataAtualizacao: json.length > 1 && json[1] != null && json[1] != '' && json[1] != 'x' ? json[1] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'cpf': cpf, 'dataAtualizacao': dataAtualizacao};
  }

  /// Verifica se há data de atualização disponível
  bool get temAtualizacao => dataAtualizacao != null && dataAtualizacao!.isNotEmpty;

  /// Verifica se o contribuinte não tem atualizações (marcado com 'x')
  bool get semAtualizacao => dataAtualizacao == 'x';

  /// Formata a data de atualização (formato YYMMDD)
  String? get dataFormatada {
    if (!temAtualizacao) return null;

    try {
      final ano = '20${dataAtualizacao!.substring(0, 2)}';
      final mes = dataAtualizacao!.substring(2, 4);
      final dia = dataAtualizacao!.substring(4, 6);
      return '$dia/$mes/$ano';
    } catch (e) {
      return dataAtualizacao;
    }
  }
}
