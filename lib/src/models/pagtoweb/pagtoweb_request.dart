import '../base/base_request.dart';
import 'dart:convert';

/// Classe base para requests do PAGTOWEB
abstract class PagtoWebRequest extends BaseRequest {
  PagtoWebRequest({required String contribuinteNumero, required PedidoDados pedidoDados})
    : super(contribuinteNumero: contribuinteNumero, pedidoDados: pedidoDados);
}

/// Request para consultar pagamentos (PAGAMENTOS71)
class ConsultarPagamentosRequest extends PagtoWebRequest {
  final String? dataInicial;
  final String? dataFinal;
  final List<String>? codigoReceitaLista;
  final double? valorInicial;
  final double? valorFinal;
  final List<String>? numeroDocumentoLista;
  final List<String>? codigoTipoDocumentoLista;
  final int primeiroDaPagina;
  final int tamanhoDaPagina;

  ConsultarPagamentosRequest({
    required String contribuinteNumero,
    this.dataInicial,
    this.dataFinal,
    this.codigoReceitaLista,
    this.valorInicial,
    this.valorFinal,
    this.numeroDocumentoLista,
    this.codigoTipoDocumentoLista,
    this.primeiroDaPagina = 0,
    this.tamanhoDaPagina = 100,
  }) : super(
         contribuinteNumero: contribuinteNumero,
         pedidoDados: PedidoDados(
           idSistema: 'PAGTOWEB',
           idServico: 'PAGAMENTOS71',
           dados: _buildDadosJson(
             dataInicial: dataInicial,
             dataFinal: dataFinal,
             codigoReceitaLista: codigoReceitaLista,
             valorInicial: valorInicial,
             valorFinal: valorFinal,
             numeroDocumentoLista: numeroDocumentoLista,
             codigoTipoDocumentoLista: codigoTipoDocumentoLista,
             primeiroDaPagina: primeiroDaPagina,
             tamanhoDaPagina: tamanhoDaPagina,
           ),
         ),
       );

  static String _buildDadosJson({
    String? dataInicial,
    String? dataFinal,
    List<String>? codigoReceitaLista,
    double? valorInicial,
    double? valorFinal,
    List<String>? numeroDocumentoLista,
    List<String>? codigoTipoDocumentoLista,
    int primeiroDaPagina = 0,
    int tamanhoDaPagina = 100,
  }) {
    final Map<String, dynamic> dados = {};

    // Intervalo de data de arrecadação
    if (dataInicial != null || dataFinal != null) {
      dados['intervaloDataArrecadacao'] = {};
      if (dataInicial != null) {
        dados['intervaloDataArrecadacao']['dataInicial'] = dataInicial;
      }
      if (dataFinal != null) {
        dados['intervaloDataArrecadacao']['dataFinal'] = dataFinal;
      }
    }

    // Lista de códigos de receita
    if (codigoReceitaLista != null && codigoReceitaLista.isNotEmpty) {
      dados['codigoReceitaLista'] = codigoReceitaLista;
    }

    // Intervalo de valor total do documento
    if (valorInicial != null || valorFinal != null) {
      dados['intervaloValorTotalDocumento'] = {};
      if (valorInicial != null) {
        dados['intervaloValorTotalDocumento']['valorInicial'] = valorInicial;
      }
      if (valorFinal != null) {
        dados['intervaloValorTotalDocumento']['valorFinal'] = valorFinal;
      }
    }

    // Lista de números de documento
    if (numeroDocumentoLista != null && numeroDocumentoLista.isNotEmpty) {
      dados['numeroDocumentoLista'] = numeroDocumentoLista;
    }

    // Lista de tipos de documento
    if (codigoTipoDocumentoLista != null && codigoTipoDocumentoLista.isNotEmpty) {
      dados['codigoTipoDocumentoLista'] = codigoTipoDocumentoLista;
    }

    // Paginação
    dados['primeiroDaPagina'] = primeiroDaPagina;
    dados['tamanhoDaPagina'] = tamanhoDaPagina;

    return jsonEncode(dados);
  }
}

/// Request para contar pagamentos (CONTACONSDOCARRPG73)
class ContarPagamentosRequest extends PagtoWebRequest {
  final String? dataInicial;
  final String? dataFinal;
  final List<String>? codigoReceitaLista;
  final double? valorInicial;
  final double? valorFinal;
  final List<String>? numeroDocumentoLista;
  final List<String>? codigoTipoDocumentoLista;

  ContarPagamentosRequest({
    required String contribuinteNumero,
    this.dataInicial,
    this.dataFinal,
    this.codigoReceitaLista,
    this.valorInicial,
    this.valorFinal,
    this.numeroDocumentoLista,
    this.codigoTipoDocumentoLista,
  }) : super(
         contribuinteNumero: contribuinteNumero,
         pedidoDados: PedidoDados(
           idSistema: 'PAGTOWEB',
           idServico: 'CONTACONSDOCARRPG73',
           versaoSistema: '1.0',
           dados: _buildDadosJson(
             dataInicial: dataInicial,
             dataFinal: dataFinal,
             codigoReceitaLista: codigoReceitaLista,
             valorInicial: valorInicial,
             valorFinal: valorFinal,
             numeroDocumentoLista: numeroDocumentoLista,
             codigoTipoDocumentoLista: codigoTipoDocumentoLista,
           ),
         ),
       );

  static String _buildDadosJson({
    String? dataInicial,
    String? dataFinal,
    List<String>? codigoReceitaLista,
    double? valorInicial,
    double? valorFinal,
    List<String>? numeroDocumentoLista,
    List<String>? codigoTipoDocumentoLista,
  }) {
    final Map<String, dynamic> dados = {};

    // Intervalo de data de arrecadação
    if (dataInicial != null || dataFinal != null) {
      dados['intervaloDataArrecadacao'] = {};
      if (dataInicial != null) {
        dados['intervaloDataArrecadacao']['dataInicial'] = dataInicial;
      }
      if (dataFinal != null) {
        dados['intervaloDataArrecadacao']['dataFinal'] = dataFinal;
      }
    }

    // Lista de códigos de receita
    if (codigoReceitaLista != null && codigoReceitaLista.isNotEmpty) {
      dados['codigoReceitaLista'] = codigoReceitaLista;
    }

    // Intervalo de valor total do documento
    if (valorInicial != null || valorFinal != null) {
      dados['intervaloValorTotalDocumento'] = {};
      if (valorInicial != null) {
        dados['intervaloValorTotalDocumento']['valorInicial'] = valorInicial;
      }
      if (valorFinal != null) {
        dados['intervaloValorTotalDocumento']['valorFinal'] = valorFinal;
      }
    }

    // Lista de números de documento
    if (numeroDocumentoLista != null && numeroDocumentoLista.isNotEmpty) {
      dados['numeroDocumentoLista'] = numeroDocumentoLista;
    }

    // Lista de tipos de documento
    if (codigoTipoDocumentoLista != null && codigoTipoDocumentoLista.isNotEmpty) {
      dados['codigoTipoDocumentoLista'] = codigoTipoDocumentoLista;
    }

    return jsonEncode(dados);
  }
}

/// Request para emitir comprovante de pagamento (EMITECOMPROVANTEPAGAMENTO72)
class EmitirComprovanteRequest extends PagtoWebRequest {
  final String numeroDocumento;

  EmitirComprovanteRequest({required String contribuinteNumero, required this.numeroDocumento})
    : super(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'PAGTOWEB',
          idServico: 'COMPARRECADACAO72',
          versaoSistema: '1.0',
          dados: jsonEncode({'numeroDocumento': numeroDocumento}),
        ),
      );
}
