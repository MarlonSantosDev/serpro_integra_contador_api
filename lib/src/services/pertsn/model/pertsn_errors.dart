/// Tratamento de erros específicos para os serviços PERTSN
class PertsnErrors {
  /// Analisa um erro específico do PERTSN e retorna informações detalhadas
  static PertsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = getErrorInfo(codigo);

    if (errorInfo != null) {
      return PertsnErrorAnalysis(
        codigo: codigo,
        mensagem: mensagem,
        tipo: errorInfo.tipo,
        acao: errorInfo.acao,
        summary: errorInfo.mensagem,
        recommendedAction: errorInfo.acao,
        isKnown: true,
      );
    }

    return PertsnErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      tipo: 'Desconhecido',
      acao: 'Verificar documentação ou contatar suporte',
      summary: mensagem,
      recommendedAction: 'Verificar documentação ou contatar suporte',
      isKnown: false,
    );
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  static bool isKnownError(String codigo) {
    return _errors.containsKey(codigo);
  }

  /// Obtém informações sobre um erro específico do PERTSN
  static PertsnErrorInfo? getErrorInfo(String codigo) {
    return _errors[codigo];
  }

  /// Obtém todos os erros de aviso do PERTSN
  static List<PertsnErrorInfo> getAvisos() {
    return _errors.values.where((error) => error.tipo == 'Aviso').toList();
  }

  /// Obtém todos os erros de entrada incorreta do PERTSN
  static List<PertsnErrorInfo> getEntradasIncorretas() {
    return _errors.values
        .where((error) => error.tipo == 'Entrada Incorreta')
        .toList();
  }

  /// Obtém todos os erros gerais do PERTSN
  static List<PertsnErrorInfo> getErros() {
    return _errors.values.where((error) => error.tipo == 'Erro').toList();
  }

  /// Obtém todos os erros de sucesso do PERTSN
  static List<PertsnErrorInfo> getSucessos() {
    return _errors.values.where((error) => error.tipo == 'Sucesso').toList();
  }

  /// Mapa de erros conhecidos do PERTSN
  static final Map<String, PertsnErrorInfo> _errors = {
    '[Sucesso-PERTSN]': PertsnErrorInfo(
      codigo: '[Sucesso-PERTSN]',
      tipo: 'Sucesso',
      mensagem: 'Requisição efetuada com sucesso.',
      acao: 'Continuar com o processamento.',
    ),
    '[Aviso-PERTSN-ER_E001]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_E001]',
      tipo: 'Aviso',
      mensagem: 'Não há parcelamento ativo para o contribuinte.',
      acao: 'O número do parcelamento informado não está ativo ou não existe.',
    ),
    '[Erro-PERTSN-ER_N001]': PertsnErrorInfo(
      codigo: '[Erro-PERTSN-ER_N001]',
      tipo: 'Erro',
      mensagem:
          'Erro ao utilizar o Integra Contador Parcelamentos. Tente novamente mais tarde.',
      acao: 'Erro interno. Efetuar nova tentativa.',
    ),
    '[EntradaIncorreta-PERTSN-ER_N002]': PertsnErrorInfo(
      codigo: '[EntradaIncorreta-PERTSN-ER_N002]',
      tipo: 'Entrada Incorreta',
      mensagem: 'Parâmetro de entrada inválido: {}.',
      acao:
          'Foi enviado um parâmetro de forma incorreta. Reenviar corrigindo o problema.',
    ),
    '[Aviso-PERTSN-ER_N003]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N003]',
      tipo: 'Aviso',
      mensagem:
          'Não há mais saldo devedor para os débitos incluídos no parcelamento. No próximo processamento mensal, o parcelamento será encerrado.',
      acao: 'Não há parcela disponível.',
    ),
    '[EntradaIncorreta-PERTSN-ER_N004]': PertsnErrorInfo(
      codigo: '[EntradaIncorreta-PERTSN-ER_N004]',
      tipo: 'Entrada Incorreta',
      mensagem:
          'Houve uma reconsolidação do parcelamento. Não é possível utilizar o Integra Contador para esta ação, que deve ser feita diretamente no portal do contribuinte ou eCac.',
      acao: 'Quando há reconsolidação, deve ser utilizada a versão web.',
    ),
    '[Aviso-PERTSN-ER_N005]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N005]',
      tipo: 'Aviso',
      mensagem:
          'O DAS da parcela do mês corrente só pode ser emitido a partir do dia {}.',
      acao: 'Reenviar a partir do dia indicado.',
    ),
    '[Aviso-PERTSN-ER_N006]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N006]',
      tipo: 'Aviso',
      mensagem:
          'A parcela {0} está indisponível para impressão devido a um dos seguintes motivos: 1- A parcela não existe no parcelamento; 2- Já existe pagamento para a parcela ou 3- É uma parcela de um mês futuro ainda não disponível.',
      acao:
          'Foi solicitada uma parcela que não está disponível para o parcelamento solicitado.',
    ),
    '[EntradaIncorreta-PERTSN-ER_N007]': PertsnErrorInfo(
      codigo: '[EntradaIncorreta-PERTSN-ER_N007]',
      tipo: 'Entrada Incorreta',
      mensagem:
          'Esta funcionalidade não requer nenhuma informação no campo dados. Remova e envie novamente a requisição.',
      acao:
          'Foram enviados parâmetros de entrada desnecessários. Reenviar retirando os parâmetros.',
    ),
    '[Aviso-PERTSN-ER_N008]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N008]',
      tipo: 'Aviso',
      mensagem: 'Não foram encontradas parcelas para emissão.',
      acao: 'Não há parcelas para o parcelamento solicitado.',
    ),
    '[Aviso-PERTSN-ER_N009]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N009]',
      tipo: 'Aviso',
      mensagem: 'Não existe parcelamento para o numeroParcelamento informado.',
      acao: 'Verificar o número do parcelamento passado no parâmetro.',
    ),
    '[Aviso-PERTSN-ER_N010]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N010]',
      tipo: 'Aviso',
      mensagem:
          'A parcela {} informada não é uma parcela válida para consulta de pagamento do parcelamento {}.',
      acao: 'Foi passada uma parcela que não existe ou não possui pagamento.',
    ),
    '[Aviso-PERTSN-ER_N011]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N011]',
      tipo: 'Aviso',
      mensagem: 'Não existe parcelamento com o número informado.',
      acao: 'Reenviar corrigindo o parâmetro.',
    ),
    '[Aviso-PERTSN-ER_N012]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N012]',
      tipo: 'Aviso',
      mensagem:
          'Não existe pagamento para o anoMesParcela e numeroParcelamento informados.',
      acao: 'Não existe pagamento para a parcela informada.',
    ),
    '[Aviso-PERTSN-ER_N013]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N013]',
      tipo: 'Aviso',
      mensagem:
          'Há um pedido de parcelamento para o contribuinte aguardando confirmação do pagamento da primeira parcela. Mensalmente, após a confirmação, estarão disponíveis os documentos para pagamento das demais.',
      acao: 'Aguardar o pagamento.',
    ),
    '[EntradaIncorreta-PERTSN-ER_N014]': PertsnErrorInfo(
      codigo: '[EntradaIncorreta-PERTSN-ER_N014]',
      tipo: 'Entrada Incorreta',
      mensagem:
          'Não será possível utilizar o IC para este contribuinte. Utilize o sistema web.',
      acao:
          'A condição do parcelamento do contribuinte não permite a utilização pelo Integra Contador.',
    ),
    '[Aviso-PERTSN-ER_N015]': PertsnErrorInfo(
      codigo: '[Aviso-PERTSN-ER_N015]',
      tipo: 'Aviso',
      mensagem:
          'Informe a parcela {0} na requisição para obter o documento de arrecadação da primeira parcela.',
      acao:
          'Mensagem que pode ser emitida em conjunto com outra. Deve ser corrigido o parâmetro de entrada.',
    ),
    '[EntradaIncorreta-PERTSN-ER_N016]': PertsnErrorInfo(
      codigo: '[EntradaIncorreta-PERTSN-ER_N016]',
      tipo: 'Entrada Incorreta',
      mensagem:
          'O Integra Contador Parcelamento possui o limite de {0} parcelas e este parcelamento possui {1} parcelas. Utilize o sistema na WEB para obter a guia.',
      acao: 'Não será possível emitir guia para este parcelamento.',
    ),
  };
}

/// Informações sobre um erro específico do PERTSN
class PertsnErrorInfo {
  final String codigo;
  final String tipo;
  final String mensagem;
  final String acao;

  PertsnErrorInfo({
    required this.codigo,
    required this.tipo,
    required this.mensagem,
    required this.acao,
  });

  /// Verifica se é um erro de sucesso
  bool get isSucesso => tipo == 'Sucesso';

  /// Verifica se é um aviso
  bool get isAviso => tipo == 'Aviso';

  /// Verifica se é um erro
  bool get isErro => tipo == 'Erro';

  /// Verifica se é uma entrada incorreta
  bool get isEntradaIncorreta => tipo == 'Entrada Incorreta';

  /// Obtém a descrição completa do erro
  String get descricaoCompleta {
    return '$codigo: $mensagem\nAção: $acao';
  }
}

/// Análise de erro do PERTSN
class PertsnErrorAnalysis {
  final String codigo;
  final String mensagem;
  final String tipo;
  final String acao;
  final String summary;
  final String recommendedAction;
  final bool isKnown;

  PertsnErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.tipo,
    required this.acao,
    required this.summary,
    required this.recommendedAction,
    required this.isKnown,
  });

  /// Verifica se é um erro de sucesso
  bool get isSucesso => tipo == 'Sucesso';

  /// Verifica se é um aviso
  bool get isAviso => tipo == 'Aviso';

  /// Verifica se é um erro
  bool get isErro => tipo == 'Erro';

  /// Verifica se é uma entrada incorreta
  bool get isEntradaIncorreta => tipo == 'Entrada Incorreta';

  /// Obtém a descrição completa da análise
  String get descricaoCompleta {
    return 'Código: $codigo\nTipo: $tipo\nMensagem: $mensagem\nAção Recomendada: $recommendedAction\nConhecido: ${isKnown ? 'Sim' : 'Não'}';
  }

  /// Obtém um resumo da análise
  String get resumo {
    return '$tipo: $summary';
  }
}
