/// Mensagens específicas do serviço SITFIS
class SitfisMensagem {
  final String codigo;
  final String texto;

  SitfisMensagem({required this.codigo, required this.texto});

  factory SitfisMensagem.fromJson(Map<String, dynamic> json) {
    return SitfisMensagem(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  @override
  String toString() {
    return '$codigo: $texto';
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSuccess => codigo.contains('Sucesso-Sitfis');

  /// Verifica se é uma mensagem de aviso
  bool get isWarning => codigo.contains('Aviso-Sitfis');

  /// Verifica se é uma mensagem de erro
  bool get isError => codigo.contains('Erro-Sitfis');

  /// Verifica se é uma mensagem de entrada incorreta
  bool get isInputError => codigo.contains('EntradaIncorreta-Sitfis');
}

/// Códigos de mensagem específicos do SITFIS
class SitfisMensagemCodigos {
  // Sucessos
  static const String sucessoSC01 = '[Sucesso-Sitfis-SC01]';
  static const String sucessoSC02 = '[Sucesso-Sitfis-SC02]';

  // Avisos
  static const String avisoAV01 = '[Aviso-Sitfis-AV01]';
  static const String avisoAV02 = '[Aviso-Sitfis-AV02]';
  static const String avisoAV03 = '[Aviso-Sitfis-AV03]';

  // Erros de entrada incorreta
  static const String entradaIncorretaEI01 = '[EntradaIncorreta-Sitfis-EI01]';
  static const String entradaIncorretaEI02 = '[EntradaIncorreta-Sitfis-EI02]';
  static const String entradaIncorretaEI03 = '[EntradaIncorreta-Sitfis-EI03]';

  // Erros gerais
  static const String erroER01 = '[Erro-Sitfis-ER01]';
  static const String erroER02 = '[Erro-Sitfis-ER02]';
  static const String erroER03 = '[Erro-Sitfis-ER03]';
  static const String erroER04 = '[Erro-Sitfis-ER04]';
  static const String erroER05 = '[Erro-Sitfis-ER05]';

  /// Descrições das mensagens
  static const Map<String, String> descricoes = {sucessoSC01: 'A requisição foi efetuada com sucesso.', sucessoSC02: 'A emissão relatório de situação fiscal está em processamento.', avisoAV01: 'Obtenha o relatório no serviço /emitir.', avisoAV02: 'O limite de solicitações em processamento foi atingido. Aguarde o tempo informado no campo tempoEspera para fazer uma nova solicitação.', avisoAV03: 'Não foi possível concluir a ação para o contribuinte informado. Aguarde o tempo informado no campo tempoEspera para fazer uma nova solicitação.', entradaIncorretaEI01: 'Requisição inválida.', entradaIncorretaEI02: 'Requisição inválida. Versão Inexistente.', entradaIncorretaEI03: 'Requisição inválida. Versão Descontinuada.', erroER01: 'URL não encontrada.', erroER02: 'Erro ao solicitar o protocolo do relatório. Tente novamente mais tarde.', erroER03: 'Erro ao obter o relatório. Tente novamente mais tarde.', erroER04: 'Erro ao processar a requisição. Tente novamente mais tarde.', erroER05: 'Erro ao processar a requisição. Inicie uma nova solicitação /apoiar.'};

  /// Obtém a descrição de uma mensagem pelo código
  static String? obterDescricao(String codigo) {
    return descricoes[codigo];
  }
}
