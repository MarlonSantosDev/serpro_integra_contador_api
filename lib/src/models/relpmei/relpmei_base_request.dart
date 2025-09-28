import '../base/base_request.dart';

/// Classe base para requisições RELPMEI
class RelpmeiBaseRequest extends BaseRequest {
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

  RelpmeiBaseRequest({
    required super.contribuinteNumero,
    required super.pedidoDados,
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
  });

  @override
  Map<String, dynamic> toJson() {
    return {
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
