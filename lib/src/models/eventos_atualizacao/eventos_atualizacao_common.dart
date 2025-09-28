/// Enums e constantes comuns para os serviços de Eventos de Atualização
class EventosAtualizacaoCommon {
  static const String idSistema = 'EVENTOSATUALIZACAO';
  static const String versaoSistema = '1.0';

  // Serviços disponíveis
  static const String solicitarEventosPF = 'SOLICEVENTOSPF131';
  static const String obterEventosPF = 'OBTEREVENTOSPF133';
  static const String solicitarEventosPJ = 'SOLICEVENTOSPJ132';
  static const String obterEventosPJ = 'OBTEREVENTOSPJ134';

  // Tipos de contribuinte
  static const int tipoPF = 3;
  static const int tipoPJ = 4;

  // Eventos disponíveis
  static const String eventoDCTFWeb = 'E0301';
  static const String eventoCaixaPostal = 'E0601';
  static const String eventoPagamentoWeb = 'E0701';

  // Limites
  static const int maxContribuintesPorLote = 1000;
  static const int maxRequisicoesPorDia = 1000;
}

/// Enum para os tipos de eventos disponíveis
enum TipoEvento {
  dctfWeb('E0301', 'DCTFWEB'),
  caixaPostal('E0601', 'CAIXAPOSTAL'),
  pagamentoWeb('E0701', 'PAGTOWEB');

  const TipoEvento(this.codigo, this.sistema);

  final String codigo;
  final String sistema;

  static TipoEvento? fromCodigo(String codigo) {
    for (final tipo in TipoEvento.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}

/// Enum para os tipos de contribuinte
enum TipoContribuinte {
  pessoaFisica(3, 'PF'),
  pessoaJuridica(4, 'PJ');

  const TipoContribuinte(this.codigo, this.descricao);

  final int codigo;
  final String descricao;

  static TipoContribuinte? fromCodigo(int codigo) {
    for (final tipo in TipoContribuinte.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}
