import 'relpmei_base_request.dart';
import '../base/base_request.dart';

/// Modelo base para requisições RELPMEI
class RelpmeiRequest extends RelpmeiBaseRequest {
  RelpmeiRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory RelpmeiRequest.fromJson(Map<String, dynamic> json) {
    return RelpmeiRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj']?.toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }
}

/// Modelo para requisição de consulta de pedidos
class ConsultarPedidosRequest extends RelpmeiBaseRequest {
  ConsultarPedidosRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    required super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory ConsultarPedidosRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarPedidosRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj'].toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuinteNumero': contribuinteNumero,
      'pedidoDados': pedidoDados.toJson(),
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
    };
  }
}

/// Modelo para requisição de consulta de parcelamento
class ConsultarParcelamentoRequest extends RelpmeiBaseRequest {
  ConsultarParcelamentoRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    required super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory ConsultarParcelamentoRequest.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj'].toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuinteNumero': contribuinteNumero,
      'pedidoDados': pedidoDados.toJson(),
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
    };
  }
}

/// Modelo para requisição de consulta de parcelas para impressão
class ConsultarParcelasImpressaoRequest extends RelpmeiBaseRequest {
  ConsultarParcelasImpressaoRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    required super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory ConsultarParcelasImpressaoRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarParcelasImpressaoRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj'].toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuinteNumero': contribuinteNumero,
      'pedidoDados': pedidoDados.toJson(),
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
    };
  }
}

/// Modelo para requisição de consulta de detalhes de pagamento
class ConsultarDetalhesPagamentoRequest extends RelpmeiBaseRequest {
  ConsultarDetalhesPagamentoRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    required super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory ConsultarDetalhesPagamentoRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarDetalhesPagamentoRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj'].toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuinteNumero': contribuinteNumero,
      'pedidoDados': pedidoDados.toJson(),
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
    };
  }
}

/// Modelo para requisição de emissão de DAS
class EmitirDasRequest extends RelpmeiBaseRequest {
  EmitirDasRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
    required super.cpfCnpj,
    super.inscricaoEstadual,
    super.codigoReceita,
    super.referencia,
    super.vencimento,
    super.valor,
    super.observacoes,
    super.tipoParcelamento,
    super.numeroParcelas,
    super.valorParcela,
    super.dataVencimento,
    super.codigoBarras,
    super.linhaDigitavel,
    super.dataPagamento,
    super.valorPago,
    super.formaPagamento,
    super.banco,
    super.agencia,
    super.conta,
    super.numeroDocumento,
    super.dataEmissao,
  });

  factory EmitirDasRequest.fromJson(Map<String, dynamic> json) {
    return EmitirDasRequest(
      contribuinteNumero: json['contribuinteNumero'].toString(),
      pedidoDados: PedidoDados.fromJson(
        json['pedidoDados'] as Map<String, dynamic>,
      ),
      cpfCnpj: json['cpfCnpj'].toString(),
      inscricaoEstadual: json['inscricaoEstadual']?.toString(),
      codigoReceita: json['codigoReceita']?.toString(),
      referencia: json['referencia']?.toString(),
      vencimento: json['vencimento']?.toString(),
      valor: json['valor']?.toString(),
      observacoes: json['observacoes']?.toString(),
      tipoParcelamento: json['tipoParcelamento']?.toString(),
      numeroParcelas: json['numeroParcelas']?.toString(),
      valorParcela: json['valorParcela']?.toString(),
      dataVencimento: json['dataVencimento']?.toString(),
      codigoBarras: json['codigoBarras']?.toString(),
      linhaDigitavel: json['linhaDigitavel']?.toString(),
      dataPagamento: json['dataPagamento']?.toString(),
      valorPago: json['valorPago']?.toString(),
      formaPagamento: json['formaPagamento']?.toString(),
      banco: json['banco']?.toString(),
      agencia: json['agencia']?.toString(),
      conta: json['conta']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString(),
      dataEmissao: json['dataEmissao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribuinteNumero': contribuinteNumero,
      'pedidoDados': pedidoDados.toJson(),
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
    };
  }
}
