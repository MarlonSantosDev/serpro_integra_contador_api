/// Utilitário para processamento de mensagens da Caixa Postal
class MessageUtils {
  /// Processa o assunto de uma mensagem substituindo a variável ++VARIAVEL++
  ///
  /// Exemplo:
  /// - assunto: "[IRPF] Declaração do exercício ++VARIAVEL++ processada"
  /// - valorParametro: "2023"
  /// - resultado: "[IRPF] Declaração do exercício 2023 processada"
  static String processarAssunto(
    String assuntoModelo,
    String valorParametroAssunto,
  ) {
    if (valorParametroAssunto.isEmpty) return assuntoModelo;
    return assuntoModelo.replaceAll('++VARIAVEL++', valorParametroAssunto);
  }

  /// Processa o corpo de uma mensagem substituindo as variáveis numeradas
  ///
  /// Exemplo:
  /// - corpo: "A Declaração do exercício ++1++ foi processada em ++2++"
  /// - variaveis: ["2023", "http://receita.fazenda"]
  /// - resultado: "A Declaração do exercício 2023 foi processada em http://receita.fazenda"
  static String processarCorpoMensagem(
    String corpoModelo,
    List<String> variaveis,
  ) {
    if (variaveis.isEmpty) return corpoModelo;

    String corpoProcessado = corpoModelo;
    for (int i = 0; i < variaveis.length; i++) {
      final placeholder = '++${i + 1}++';
      corpoProcessado = corpoProcessado.replaceAll(placeholder, variaveis[i]);
    }
    return corpoProcessado;
  }

  /// Processa uma mensagem completa (assunto + corpo)
  static MensagemProcessada processarMensagemCompleta({
    required String assuntoModelo,
    required String valorParametroAssunto,
    required String corpoModelo,
    required List<String> variaveis,
  }) {
    return MensagemProcessada(
      assuntoProcessado: processarAssunto(assuntoModelo, valorParametroAssunto),
      corpoProcessado: processarCorpoMensagem(corpoModelo, variaveis),
    );
  }

  /// Remove tags HTML básicas do conteúdo da mensagem
  static String removerTagsHtml(String conteudo) {
    return conteudo
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&aacute;', 'á')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&atilde;', 'ã')
        .replaceAll('&otilde;', 'õ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&Atilde;', 'Ã')
        .replaceAll('&Otilde;', 'Õ')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ordm;', 'º')
        .trim();
  }

  /// Formata data do formato AAAAMMDD para DD/MM/AAAA
  static String formatarData(String data) {
    if (data.length != 8) return data;

    final ano = data.substring(0, 4);
    final mes = data.substring(4, 6);
    final dia = data.substring(6, 8);

    return '$dia/$mes/$ano';
  }

  /// Formata hora do formato HHMMSS para HH:MM:SS
  static String formatarHora(String hora) {
    if (hora.length != 6) return hora;

    final hh = hora.substring(0, 2);
    final mm = hora.substring(2, 4);
    final ss = hora.substring(4, 6);

    return '$hh:$mm:$ss';
  }

  /// Formata data e hora juntas
  static String formatarDataHora(String data, String hora) {
    final dataFormatada = formatarData(data);
    final horaFormatada = formatarHora(hora);

    if (dataFormatada == data && horaFormatada == hora) {
      return '$data $hora';
    }

    return '$dataFormatada $horaFormatada';
  }

  /// Converte status de leitura para descrição
  static String obterDescricaoStatusLeitura(String indicadorLeitura) {
    switch (indicadorLeitura) {
      case '0':
        return 'Não lida';
      case '1':
        return 'Lida';
      default:
        return 'Status desconhecido';
    }
  }

  /// Converte indicador de favorito para descrição
  static String obterDescricaoFavorito(String indicadorFavorito) {
    switch (indicadorFavorito) {
      case '0':
        return 'Não favorita';
      case '1':
        return 'Favorita';
      default:
        return 'Status desconhecido';
    }
  }

  /// Converte relevância para descrição
  static String obterDescricaoRelevancia(String relevancia) {
    switch (relevancia) {
      case '1':
        return 'Sem relevância';
      case '2':
        return 'Com relevância';
      default:
        return 'Relevância desconhecida';
    }
  }

  /// Converte tipo de origem para descrição
  static String obterDescricaoTipoOrigem(String tipoOrigem) {
    switch (tipoOrigem) {
      case '0':
      case '1':
        return 'Receita';
      case '2':
        return 'Estado';
      case '3':
        return 'Município';
      default:
        return 'Origem desconhecida';
    }
  }
}

/// Classe para representar uma mensagem processada
class MensagemProcessada {
  final String assuntoProcessado;
  final String corpoProcessado;

  MensagemProcessada({
    required this.assuntoProcessado,
    required this.corpoProcessado,
  });

  /// Obtém o corpo da mensagem sem tags HTML
  String get corpoLimpo => MessageUtils.removerTagsHtml(corpoProcessado);

  /// Obtém um resumo da mensagem (primeiros 200 caracteres do corpo limpo)
  String get resumo {
    final texto = corpoLimpo;
    if (texto.length <= 200) return texto;
    return '${texto.substring(0, 200)}...';
  }
}
