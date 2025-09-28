import '../base/base_request.dart';

/// Classe base para requests do PAGTOWEB
abstract class PagtoWebRequest extends BaseRequest {
  PagtoWebRequest({
    required String contribuinteNumero,
    required PedidoDados pedidoDados,
  }) : super(contribuinteNumero: contribuinteNumero, pedidoDados: pedidoDados);
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
           versaoSistema: '1.0',
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
    if (codigoTipoDocumentoLista != null &&
        codigoTipoDocumentoLista.isNotEmpty) {
      dados['codigoTipoDocumentoLista'] = codigoTipoDocumentoLista;
    }

    // Paginação
    dados['primeiroDaPagina'] = primeiroDaPagina;
    dados['tamanhoDaPagina'] = tamanhoDaPagina;

    return _mapToJsonString(dados);
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
    if (codigoTipoDocumentoLista != null &&
        codigoTipoDocumentoLista.isNotEmpty) {
      dados['codigoTipoDocumentoLista'] = codigoTipoDocumentoLista;
    }

    return _mapToJsonString(dados);
  }
}

/// Request para emitir comprovante de pagamento (EMITECOMPROVANTEPAGAMENTO72)
class EmitirComprovanteRequest extends PagtoWebRequest {
  final String numeroDocumento;

  EmitirComprovanteRequest({
    required String contribuinteNumero,
    required this.numeroDocumento,
  }) : super(
         contribuinteNumero: contribuinteNumero,
         pedidoDados: PedidoDados(
           idSistema: 'PAGTOWEB',
           idServico: 'EMITECOMPROVANTEPAGAMENTO72',
           versaoSistema: '1.0',
           dados: _mapToJsonString({'numeroDocumento': numeroDocumento}),
         ),
       );
}

/// Utilitário para converter Map para JSON String
String _mapToJsonString(Map<String, dynamic> map) {
  final buffer = StringBuffer();
  buffer.write('{');

  final entries = map.entries.toList();
  for (int i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.write('"${entry.key}":');

    if (entry.value is String) {
      buffer.write('"${entry.value}"');
    } else if (entry.value is List) {
      buffer.write('[');
      final list = entry.value as List;
      for (int j = 0; j < list.length; j++) {
        buffer.write('"${list[j]}"');
        if (j < list.length - 1) buffer.write(',');
      }
      buffer.write(']');
    } else if (entry.value is Map) {
      buffer.write('{');
      final subMap = entry.value as Map<String, dynamic>;
      final subEntries = subMap.entries.toList();
      for (int k = 0; k < subEntries.length; k++) {
        final subEntry = subEntries[k];
        buffer.write('"${subEntry.key}":"${subEntry.value}"');
        if (k < subEntries.length - 1) buffer.write(',');
      }
      buffer.write('}');
    } else {
      buffer.write(entry.value.toString());
    }

    if (i < entries.length - 1) buffer.write(',');
  }

  buffer.write('}');
  return buffer.toString();
}
