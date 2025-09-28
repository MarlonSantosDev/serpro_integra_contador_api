import 'eventos_atualizacao_common.dart';

/// Modelo de requisição para obter eventos de atualização de Pessoa Física
class ObterEventosPFRequest {
  final String protocolo;
  final TipoEvento evento;

  ObterEventosPFRequest({required this.protocolo, required this.evento}) {
    if (protocolo.isEmpty) {
      throw ArgumentError('Protocolo não pode estar vazio');
    }
    if (!_isValidProtocol(protocolo)) {
      throw ArgumentError('Formato de protocolo inválido');
    }
  }

  /// Cria os dados JSON para o campo 'dados' da requisição
  String get dadosJson {
    return '{"protocolo":"$protocolo", "evento":"${evento.codigo}"}';
  }

  /// Valida se o protocolo tem formato válido (UUID)
  bool _isValidProtocol(String protocolo) {
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(protocolo);
  }

  factory ObterEventosPFRequest.fromJson(Map<String, dynamic> json) {
    final protocolo = json['protocolo'] as String;
    final eventoCodigo = json['evento'] as String;
    final evento = TipoEvento.fromCodigo(eventoCodigo) ?? TipoEvento.dctfWeb;

    return ObterEventosPFRequest(protocolo: protocolo, evento: evento);
  }

  Map<String, dynamic> toJson() {
    return {'protocolo': protocolo, 'evento': evento.codigo};
  }
}
