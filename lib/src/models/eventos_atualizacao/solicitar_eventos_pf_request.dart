import 'eventos_atualizacao_common.dart';
import '../../util/validations_utils.dart';

/// Modelo de requisição para solicitar eventos de atualização de Pessoa Física
class SolicitarEventosPFRequest {
  final List<String> cpfs;
  final TipoEvento evento;

  SolicitarEventosPFRequest({required this.cpfs, required this.evento}) {
    if (cpfs.isEmpty) {
      throw ArgumentError('Lista de CPFs não pode estar vazia');
    }
    if (cpfs.length > EventosAtualizacaoCommon.maxContribuintesPorLote) {
      throw ArgumentError('Máximo de ${EventosAtualizacaoCommon.maxContribuintesPorLote} CPFs por lote');
    }

    // Validar formato dos CPFs
    for (final cpf in cpfs) {
      if (!DocumentUtils.isValidCpf(cpf)) {
        throw ArgumentError('CPF inválido: $cpf');
      }
    }
  }

  /// Cria os dados JSON para o campo 'dados' da requisição
  String get dadosJson {
    return '{"evento": "${evento.codigo}"}';
  }

  /// Cria a string de CPFs separados por vírgula
  String get cpfsString {
    return cpfs.join(',');
  }

  factory SolicitarEventosPFRequest.fromJson(Map<String, dynamic> json) {
    final cpfsString = json['cpfs'].toString();
    final cpfs = cpfsString.split(',').map((e) => e.trim()).toList();
    final eventoCodigo = json['evento'].toString();
    final evento = TipoEvento.fromCodigo(eventoCodigo) ?? TipoEvento.dctfWeb;

    return SolicitarEventosPFRequest(cpfs: cpfs, evento: evento);
  }

  Map<String, dynamic> toJson() {
    return {'cpfs': cpfsString, 'evento': evento.codigo};
  }
}
