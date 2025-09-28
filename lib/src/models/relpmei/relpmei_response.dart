/// Modelo base para respostas RELPMEI
class RelpmeiResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final Map<String, dynamic>? dados;

  RelpmeiResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.dados});

  factory RelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return RelpmeiResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      dados: json['dados'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sucesso': sucesso, 'mensagem': mensagem, 'codigoErro': codigoErro, 'detalhesErro': detalhesErro, 'dados': dados};
  }
}

/// Modelo para resposta de consulta de pedidos
class ConsultarPedidosResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final List<Pedido>? pedidos;

  ConsultarPedidosResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.pedidos});

  factory ConsultarPedidosResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarPedidosResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      pedidos: json['pedidos'] != null ? (json['pedidos'] as List).map((e) => Pedido.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'mensagem': mensagem,
      'codigoErro': codigoErro,
      'detalhesErro': detalhesErro,
      'pedidos': pedidos?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para resposta de consulta de parcelamento
class ConsultarParcelamentoResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final List<Parcelamento>? parcelamentos;

  ConsultarParcelamentoResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.parcelamentos});

  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      parcelamentos: json['parcelamentos'] != null
          ? (json['parcelamentos'] as List).map((e) => Parcelamento.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'mensagem': mensagem,
      'codigoErro': codigoErro,
      'detalhesErro': detalhesErro,
      'parcelamentos': parcelamentos?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para resposta de consulta de parcelas para impressão
class ConsultarParcelasImpressaoResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final List<ParcelaImpressao>? parcelas;

  ConsultarParcelasImpressaoResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.parcelas});

  factory ConsultarParcelasImpressaoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelasImpressaoResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      parcelas: json['parcelas'] != null
          ? (json['parcelas'] as List).map((e) => ParcelaImpressao.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'mensagem': mensagem,
      'codigoErro': codigoErro,
      'detalhesErro': detalhesErro,
      'parcelas': parcelas?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para resposta de consulta de detalhes de pagamento
class ConsultarDetalhesPagamentoResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final List<DetalhePagamento>? detalhes;

  ConsultarDetalhesPagamentoResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.detalhes});

  factory ConsultarDetalhesPagamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDetalhesPagamentoResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      detalhes: json['detalhes'] != null
          ? (json['detalhes'] as List).map((e) => DetalhePagamento.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'mensagem': mensagem,
      'codigoErro': codigoErro,
      'detalhesErro': detalhesErro,
      'detalhes': detalhes?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para resposta de emissão de DAS
class EmitirDasResponse {
  final bool sucesso;
  final String? mensagem;
  final String? codigoErro;
  final String? detalhesErro;
  final Das? das;

  EmitirDasResponse({required this.sucesso, this.mensagem, this.codigoErro, this.detalhesErro, this.das});

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    return EmitirDasResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String?,
      codigoErro: json['codigoErro'] as String?,
      detalhesErro: json['detalhesErro'] as String?,
      das: json['das'] != null ? Das.fromJson(json['das'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sucesso': sucesso, 'mensagem': mensagem, 'codigoErro': codigoErro, 'detalhesErro': detalhesErro, 'das': das?.toJson()};
  }
}

/// Modelo para pedido
class Pedido {
  final String? numeroPedido;
  final String? cpfCnpj;
  final String? inscricaoEstadual;
  final String? codigoReceita;
  final String? referencia;
  final String? vencimento;
  final String? valor;
  final String? observacoes;
  final String? tipoParcelamento;
  final String? numeroParcelas;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;

  Pedido({
    this.numeroPedido,
    this.cpfCnpj,
    this.inscricaoEstadual,
    this.codigoReceita,
    this.referencia,
    this.vencimento,
    this.valor,
    this.observacoes,
    this.tipoParcelamento,
    this.numeroParcelas,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      numeroPedido: json['numeroPedido'] as String?,
      cpfCnpj: json['cpfCnpj'] as String?,
      inscricaoEstadual: json['inscricaoEstadual'] as String?,
      codigoReceita: json['codigoReceita'] as String?,
      referencia: json['referencia'] as String?,
      vencimento: json['vencimento'] as String?,
      valor: json['valor'] as String?,
      observacoes: json['observacoes'] as String?,
      tipoParcelamento: json['tipoParcelamento'] as String?,
      numeroParcelas: json['numeroParcelas'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroPedido': numeroPedido,
      'cpfCnpj': cpfCnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'codigoReceita': codigoReceita,
      'referencia': referencia,
      'vencimento': vencimento,
      'valor': valor,
      'observacoes': observacoes,
      'tipoParcelamento': tipoParcelamento,
      'numeroParcelas': numeroParcelas,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
    };
  }
}

/// Modelo para parcelamento
class Parcelamento {
  final String? numeroParcelamento;
  final String? cpfCnpj;
  final String? inscricaoEstadual;
  final String? codigoReceita;
  final String? referencia;
  final String? vencimento;
  final String? valor;
  final String? observacoes;
  final String? tipoParcelamento;
  final String? numeroParcelas;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;
  final List<Parcela>? parcelas;

  Parcelamento({
    this.numeroParcelamento,
    this.cpfCnpj,
    this.inscricaoEstadual,
    this.codigoReceita,
    this.referencia,
    this.vencimento,
    this.valor,
    this.observacoes,
    this.tipoParcelamento,
    this.numeroParcelas,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
    this.parcelas,
  });

  factory Parcelamento.fromJson(Map<String, dynamic> json) {
    return Parcelamento(
      numeroParcelamento: json['numeroParcelamento'] as String?,
      cpfCnpj: json['cpfCnpj'] as String?,
      inscricaoEstadual: json['inscricaoEstadual'] as String?,
      codigoReceita: json['codigoReceita'] as String?,
      referencia: json['referencia'] as String?,
      vencimento: json['vencimento'] as String?,
      valor: json['valor'] as String?,
      observacoes: json['observacoes'] as String?,
      tipoParcelamento: json['tipoParcelamento'] as String?,
      numeroParcelas: json['numeroParcelas'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
      parcelas: json['parcelas'] != null ? (json['parcelas'] as List).map((e) => Parcela.fromJson(e as Map<String, dynamic>)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroParcelamento': numeroParcelamento,
      'cpfCnpj': cpfCnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'codigoReceita': codigoReceita,
      'referencia': referencia,
      'vencimento': vencimento,
      'valor': valor,
      'observacoes': observacoes,
      'tipoParcelamento': tipoParcelamento,
      'numeroParcelas': numeroParcelas,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
      'parcelas': parcelas?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para parcela
class Parcela {
  final String? numeroParcela;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;

  Parcela({
    this.numeroParcela,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
  });

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      numeroParcela: json['numeroParcela'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroParcela': numeroParcela,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
    };
  }
}

/// Modelo para parcela de impressão
class ParcelaImpressao {
  final String? numeroParcela;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;
  final String? codigoImpressao;
  final String? dataImpressao;
  final String? usuarioImpressao;

  ParcelaImpressao({
    this.numeroParcela,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
    this.codigoImpressao,
    this.dataImpressao,
    this.usuarioImpressao,
  });

  factory ParcelaImpressao.fromJson(Map<String, dynamic> json) {
    return ParcelaImpressao(
      numeroParcela: json['numeroParcela'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
      codigoImpressao: json['codigoImpressao'] as String?,
      dataImpressao: json['dataImpressao'] as String?,
      usuarioImpressao: json['usuarioImpressao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroParcela': numeroParcela,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
      'codigoImpressao': codigoImpressao,
      'dataImpressao': dataImpressao,
      'usuarioImpressao': usuarioImpressao,
    };
  }
}

/// Modelo para detalhe de pagamento
class DetalhePagamento {
  final String? numeroPagamento;
  final String? cpfCnpj;
  final String? inscricaoEstadual;
  final String? codigoReceita;
  final String? referencia;
  final String? vencimento;
  final String? valor;
  final String? observacoes;
  final String? tipoParcelamento;
  final String? numeroParcelas;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;
  final String? codigoAutorizacao;
  final String? numeroTransacao;
  final String? dataTransacao;
  final String? horaTransacao;
  final String? valorTransacao;
  final String? formaPagamentoTransacao;
  final String? bancoTransacao;
  final String? agenciaTransacao;
  final String? contaTransacao;
  final String? numeroDocumentoTransacao;
  final String? dataEmissaoTransacao;

  DetalhePagamento({
    this.numeroPagamento,
    this.cpfCnpj,
    this.inscricaoEstadual,
    this.codigoReceita,
    this.referencia,
    this.vencimento,
    this.valor,
    this.observacoes,
    this.tipoParcelamento,
    this.numeroParcelas,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
    this.codigoAutorizacao,
    this.numeroTransacao,
    this.dataTransacao,
    this.horaTransacao,
    this.valorTransacao,
    this.formaPagamentoTransacao,
    this.bancoTransacao,
    this.agenciaTransacao,
    this.contaTransacao,
    this.numeroDocumentoTransacao,
    this.dataEmissaoTransacao,
  });

  factory DetalhePagamento.fromJson(Map<String, dynamic> json) {
    return DetalhePagamento(
      numeroPagamento: json['numeroPagamento'] as String?,
      cpfCnpj: json['cpfCnpj'] as String?,
      inscricaoEstadual: json['inscricaoEstadual'] as String?,
      codigoReceita: json['codigoReceita'] as String?,
      referencia: json['referencia'] as String?,
      vencimento: json['vencimento'] as String?,
      valor: json['valor'] as String?,
      observacoes: json['observacoes'] as String?,
      tipoParcelamento: json['tipoParcelamento'] as String?,
      numeroParcelas: json['numeroParcelas'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
      codigoAutorizacao: json['codigoAutorizacao'] as String?,
      numeroTransacao: json['numeroTransacao'] as String?,
      dataTransacao: json['dataTransacao'] as String?,
      horaTransacao: json['horaTransacao'] as String?,
      valorTransacao: json['valorTransacao'] as String?,
      formaPagamentoTransacao: json['formaPagamentoTransacao'] as String?,
      bancoTransacao: json['bancoTransacao'] as String?,
      agenciaTransacao: json['agenciaTransacao'] as String?,
      contaTransacao: json['contaTransacao'] as String?,
      numeroDocumentoTransacao: json['numeroDocumentoTransacao'] as String?,
      dataEmissaoTransacao: json['dataEmissaoTransacao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroPagamento': numeroPagamento,
      'cpfCnpj': cpfCnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'codigoReceita': codigoReceita,
      'referencia': referencia,
      'vencimento': vencimento,
      'valor': valor,
      'observacoes': observacoes,
      'tipoParcelamento': tipoParcelamento,
      'numeroParcelas': numeroParcelas,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
      'codigoAutorizacao': codigoAutorizacao,
      'numeroTransacao': numeroTransacao,
      'dataTransacao': dataTransacao,
      'horaTransacao': horaTransacao,
      'valorTransacao': valorTransacao,
      'formaPagamentoTransacao': formaPagamentoTransacao,
      'bancoTransacao': bancoTransacao,
      'agenciaTransacao': agenciaTransacao,
      'contaTransacao': contaTransacao,
      'numeroDocumentoTransacao': numeroDocumentoTransacao,
      'dataEmissaoTransacao': dataEmissaoTransacao,
    };
  }
}

/// Modelo para DAS
class Das {
  final String? numeroDas;
  final String? cpfCnpj;
  final String? inscricaoEstadual;
  final String? codigoReceita;
  final String? referencia;
  final String? vencimento;
  final String? valor;
  final String? observacoes;
  final String? tipoParcelamento;
  final String? numeroParcelas;
  final String? valorParcela;
  final String? dataVencimento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? dataPagamento;
  final String? valorPago;
  final String? formaPagamento;
  final String? banco;
  final String? agencia;
  final String? conta;
  final String? numeroDocumento;
  final String? dataEmissao;
  final String? status;
  final String? dataStatus;
  final String? usuarioStatus;
  final String? observacoesStatus;
  final String? codigoImpressao;
  final String? dataImpressao;
  final String? usuarioImpressao;
  final String? arquivoDas;
  final String? tamanhoArquivo;
  final String? tipoArquivo;

  Das({
    this.numeroDas,
    this.cpfCnpj,
    this.inscricaoEstadual,
    this.codigoReceita,
    this.referencia,
    this.vencimento,
    this.valor,
    this.observacoes,
    this.tipoParcelamento,
    this.numeroParcelas,
    this.valorParcela,
    this.dataVencimento,
    this.codigoBarras,
    this.linhaDigitavel,
    this.dataPagamento,
    this.valorPago,
    this.formaPagamento,
    this.banco,
    this.agencia,
    this.conta,
    this.numeroDocumento,
    this.dataEmissao,
    this.status,
    this.dataStatus,
    this.usuarioStatus,
    this.observacoesStatus,
    this.codigoImpressao,
    this.dataImpressao,
    this.usuarioImpressao,
    this.arquivoDas,
    this.tamanhoArquivo,
    this.tipoArquivo,
  });

  factory Das.fromJson(Map<String, dynamic> json) {
    return Das(
      numeroDas: json['numeroDas'] as String?,
      cpfCnpj: json['cpfCnpj'] as String?,
      inscricaoEstadual: json['inscricaoEstadual'] as String?,
      codigoReceita: json['codigoReceita'] as String?,
      referencia: json['referencia'] as String?,
      vencimento: json['vencimento'] as String?,
      valor: json['valor'] as String?,
      observacoes: json['observacoes'] as String?,
      tipoParcelamento: json['tipoParcelamento'] as String?,
      numeroParcelas: json['numeroParcelas'] as String?,
      valorParcela: json['valorParcela'] as String?,
      dataVencimento: json['dataVencimento'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      dataPagamento: json['dataPagamento'] as String?,
      valorPago: json['valorPago'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      banco: json['banco'] as String?,
      agencia: json['agencia'] as String?,
      conta: json['conta'] as String?,
      numeroDocumento: json['numeroDocumento'] as String?,
      dataEmissao: json['dataEmissao'] as String?,
      status: json['status'] as String?,
      dataStatus: json['dataStatus'] as String?,
      usuarioStatus: json['usuarioStatus'] as String?,
      observacoesStatus: json['observacoesStatus'] as String?,
      codigoImpressao: json['codigoImpressao'] as String?,
      dataImpressao: json['dataImpressao'] as String?,
      usuarioImpressao: json['usuarioImpressao'] as String?,
      arquivoDas: json['arquivoDas'] as String?,
      tamanhoArquivo: json['tamanhoArquivo'] as String?,
      tipoArquivo: json['tipoArquivo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'cpfCnpj': cpfCnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'codigoReceita': codigoReceita,
      'referencia': referencia,
      'vencimento': vencimento,
      'valor': valor,
      'observacoes': observacoes,
      'tipoParcelamento': tipoParcelamento,
      'numeroParcelas': numeroParcelas,
      'valorParcela': valorParcela,
      'dataVencimento': dataVencimento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'formaPagamento': formaPagamento,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'numeroDocumento': numeroDocumento,
      'dataEmissao': dataEmissao,
      'status': status,
      'dataStatus': dataStatus,
      'usuarioStatus': usuarioStatus,
      'observacoesStatus': observacoesStatus,
      'codigoImpressao': codigoImpressao,
      'dataImpressao': dataImpressao,
      'usuarioImpressao': usuarioImpressao,
      'arquivoDas': arquivoDas,
      'tamanhoArquivo': tamanhoArquivo,
      'tipoArquivo': tipoArquivo,
    };
  }
}
