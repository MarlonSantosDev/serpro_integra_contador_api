import 'eventos_atualizacao_common.dart';
import '../../../util/validacoes_utils.dart';

/// Modelo de requisição para solicitar eventos de atualização de Pessoa Jurídica
class SolicitarEventosPJRequest {
  final List<String> cnpjs;
  final TipoEvento evento;

  SolicitarEventosPJRequest({required this.cnpjs, required this.evento}) {
    if (cnpjs.isEmpty) {
      throw ArgumentError('Lista de CNPJs não pode estar vazia');
    }
    if (cnpjs.length > EventosAtualizacaoCommon.maxContribuintesPorLote) {
      throw ArgumentError(
        'Máximo de ${EventosAtualizacaoCommon.maxContribuintesPorLote} CNPJs por lote',
      );
    }

    // Validar lista de CNPJs (consistência e formato)
    ValidacoesUtils.validateCNPJList(cnpjs);
  }

  /// Cria os dados JSON para o campo 'dados' da requisição
  String get dadosJson {
    return '{"evento": "${evento.codigo}"}';
  }

  /// Cria a string de CNPJs separados por vírgula
  String get cnpjsString {
    return cnpjs.join(',');
  }

  factory SolicitarEventosPJRequest.fromJson(Map<String, dynamic> json) {
    final cnpjsString = json['cnpjs'].toString();
    final cnpjs = cnpjsString.split(',').map((e) => e.trim()).toList();
    final eventoCodigo = json['evento'].toString();
    final evento = TipoEvento.fromCodigo(eventoCodigo) ?? TipoEvento.dctfWeb;

    return SolicitarEventosPJRequest(cnpjs: cnpjs, evento: evento);
  }

  Map<String, dynamic> toJson() {
    return {'cnpjs': cnpjsString, 'evento': evento.codigo};
  }
}
