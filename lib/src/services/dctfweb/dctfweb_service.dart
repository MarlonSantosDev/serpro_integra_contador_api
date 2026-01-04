import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/dctfweb/model/dctfweb_request.dart';
import 'package:serpro_integra_contador_api/src/services/dctfweb/model/consultar_xml_response.dart';
import 'package:serpro_integra_contador_api/src/services/dctfweb/model/gerar_guia_response.dart';
import 'package:serpro_integra_contador_api/src/services/dctfweb/model/transmitir_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/dctfweb/model/consultar_relatorio_response.dart';
import 'dart:convert';

/// **Serviço:** DCTFWeb (Declaração de Débitos e Créditos Tributários Federais)
///
/// Serviço para declaração e apuração de débitos e créditos tributários federais.
/// A DCTFWeb substituiu a DCTF para empresas do Simples Nacional e outras.
///
/// **Este serviço permite:**
/// - Gerar Documento de Arrecadação (DARF/DAE)
/// - Consultar Recibo de transmissão
/// - Consultar Declaração Completa
/// - Consultar/Gerar XML da declaração
/// - Transmitir declaração
/// - Gerar Documento para declaração em andamento
///
/// **Documentação oficial:** `.cursor/rules/dctfweb.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final dctfwebService = DctfWebService(apiClient);
///
/// // Gerar guia de pagamento
/// final guia = await dctfwebService.gerarDocumentoArrecadacao(
///   contribuinteNumero: '12345678000190',
///   categoria: CategoriaDctf.mensal,
///   anoPA: '2024',
///   mesPA: '03',
/// );
/// ```
class DctfWebService {
  final ApiClient _apiClient;

  DctfWebService(this._apiClient);

  /// Gera documento de arrecadação (DARF/DAE) para uma declaração ATIVA
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração (pode ser enum ou código numérico)
  /// [anoPA] Ano do período de apuração (formato: AAAA)
  /// [mesPA] Mês do período de apuração (formato: MM) - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração (formato: DD) - apenas para espetáculo desportivo
  /// [cnoAfericao] Número da obra - apenas para aferição
  /// [numeroReciboEntrega] Número do recibo - opcional, usa a declaração mais recente se não informado
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  /// [dataAcolhimentoProposta] Data proposta para pagamento (formato: AAAAMMDD)
  /// [idsSistemaOrigem] Lista de sistemas de origem das receitas
  Future<GerarGuiaResponse> gerarDocumentoArrecadacao({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    int? cnoAfericao,
    int? numeroReciboEntrega,
    String? numProcReclamatoria,
    int? dataAcolhimentoProposta,
    List<SistemaOrigem>? idsSistemaOrigem,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dctfRequest = DctfWebRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      cnoAfericao: cnoAfericao,
      numeroReciboEntrega: numeroReciboEntrega,
      numProcReclamatoria: numProcReclamatoria,
      dataAcolhimentoProposta: dataAcolhimentoProposta,
      idsSistemaOrigem: idsSistemaOrigem,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'GERARGUIA31', dados: dctfRequest.toDadosJson()),
    );
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return GerarGuiaResponse.fromJson(response);
  }

  /// Consulta o recibo de transmissão de uma declaração
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [cnoAfericao] Número da obra - apenas para aferição
  /// [numeroReciboEntrega] Número do recibo - opcional, usa a declaração mais recente se não informado
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  Future<ConsultarRelatorioResponse> consultarReciboTransmissao({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    int? cnoAfericao,
    int? numeroReciboEntrega,
    String? numProcReclamatoria,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dctfRequest = ConsultarDctfWebRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      cnoAfericao: cnoAfericao,
      numeroReciboEntrega: numeroReciboEntrega,
      numProcReclamatoria: numProcReclamatoria,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'CONSRECIBO32', dados: dctfRequest.toDadosJson()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarRelatorioResponse.fromJson(response);
  }

  /// Consulta relatório de declaração completa transmitida
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [cnoAfericao] Número da obra - apenas para aferição
  /// [numeroReciboEntrega] Número do recibo - opcional, usa a declaração mais recente se não informado
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  Future<ConsultarRelatorioResponse> consultarDeclaracaoCompleta({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    int? cnoAfericao,
    int? numeroReciboEntrega,
    String? numProcReclamatoria,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dctfRequest = ConsultarDctfWebRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      cnoAfericao: cnoAfericao,
      numeroReciboEntrega: numeroReciboEntrega,
      numProcReclamatoria: numProcReclamatoria,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'CONSDECCOMPLETA33', dados: dctfRequest.toDadosJson()),
    );
    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarRelatorioResponse.fromJson(response);
  }

  /// Consulta o XML de uma declaração ATIVA ou gera XML de uma declaração EM ANDAMENTO
  ///
  /// Para declarações ATIVAS: retorna o XML já assinado e transmitido
  /// Para declarações EM ANDAMENTO: gera XML para posterior assinatura e transmissão
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [cnoAfericao] Número da obra - apenas para aferição
  /// [numeroReciboEntrega] Número do recibo - opcional, usa a declaração mais recente se não informado
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  Future<ConsultarXmlResponse> consultarXmlDeclaracao({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    int? cnoAfericao,
    int? numeroReciboEntrega,
    String? numProcReclamatoria,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dctfRequest = ConsultarDctfWebRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      cnoAfericao: cnoAfericao,
      numeroReciboEntrega: numeroReciboEntrega,
      numProcReclamatoria: numProcReclamatoria,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'CONSXMLDECLARACAO38', dados: dctfRequest.toDadosJson()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarXmlResponse.fromJson(response);
  }

  /// Transmite uma declaração EM ANDAMENTO usando XML assinado digitalmente
  ///
  /// IMPORTANTE: O XML deve ser assinado digitalmente pelo contribuinte antes da transmissão.
  /// O certificado usado na assinatura deve ser o do autor do pedido de dados.
  /// O elemento XML a ser assinado é 'ConteudoDeclaracao'.
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  /// [xmlAssinadoBase64] XML obtido de consultarXmlDeclaracao, assinado digitalmente e em Base64
  Future<TransmitirDeclaracaoDctfResponse> transmitirDeclaracao({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    String? numProcReclamatoria,
    required String xmlAssinadoBase64,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validar XML antes de enviar
    if (!validarXmlBase64(xmlAssinadoBase64)) {
      if (contratanteNumero != '00000000000') {
        throw ArgumentError('XML Base64 inválido ou mal formado');
      }
    }

    final dctfRequest = TransmitirDeclaracaoDctfRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      numProcReclamatoria: numProcReclamatoria,
      xmlAssinadoBase64: xmlAssinadoBase64,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'TRANSDECLARACAO310', dados: dctfRequest.toDadosJson()),
    );
    final response = await _apiClient.post(
      '/Declarar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return TransmitirDeclaracaoDctfResponse.fromJson(response);
  }

  /// Gera documento de arrecadação para uma declaração EM ANDAMENTO
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração - obrigatório exceto para 13º salário
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [cnoAfericao] Número da obra - apenas para aferição
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  /// [idsSistemaOrigem] Lista de sistemas de origem das receitas
  Future<GerarGuiaResponse> gerarDocumentoArrecadacaoAndamento({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    int? cnoAfericao,
    String? numProcReclamatoria,
    List<SistemaOrigem>? idsSistemaOrigem,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dctfRequest = DctfWebRequest(
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      cnoAfericao: cnoAfericao,
      numProcReclamatoria: numProcReclamatoria,
      idsSistemaOrigem: idsSistemaOrigem,
    );

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DCTFWEB', idServico: 'GERARGUIAANDAMENTO313', dados: dctfRequest.toDadosJson()),
    );
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return GerarGuiaResponse.fromJson(response);
  }

  // MÉTODOS DE CONVENIÊNCIA PARA CATEGORIAS ESPECÍFICAS

  /// Gera DARF para declaração GERAL MENSAL (categoria 40)
  Future<GerarGuiaResponse> gerarDarfGeralMensal({
    required String contribuinteNumero,
    required String anoPA,
    required String mesPA,
    int? numeroReciboEntrega,
    int? dataAcolhimentoProposta,
    List<SistemaOrigem>? idsSistemaOrigem,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return gerarDocumentoArrecadacao(
      contribuinteNumero: contribuinteNumero,
      categoria: CategoriaDctf.geralMensal,
      anoPA: anoPA,
      mesPA: mesPA,
      numeroReciboEntrega: numeroReciboEntrega,
      dataAcolhimentoProposta: dataAcolhimentoProposta,
      idsSistemaOrigem: idsSistemaOrigem,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF para declaração PESSOA FÍSICA MENSAL (categoria 50)
  Future<GerarGuiaResponse> gerarDarfPfMensal({
    required String contribuinteNumero,
    required String anoPA,
    required String mesPA,
    int? numeroReciboEntrega,
    int? dataAcolhimentoProposta,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return gerarDocumentoArrecadacao(
      contribuinteNumero: contribuinteNumero,
      categoria: CategoriaDctf.pfMensal,
      anoPA: anoPA,
      mesPA: mesPA,
      numeroReciboEntrega: numeroReciboEntrega,
      dataAcolhimentoProposta: dataAcolhimentoProposta,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Gera DARF para declaração 13º SALÁRIO (categorias 41 ou 51)
  Future<GerarGuiaResponse> gerarDarf13Salario({
    required String contribuinteNumero,
    required String anoPA,
    bool isPessoaFisica = false,
    int? numeroReciboEntrega,
    int? dataAcolhimentoProposta,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return gerarDocumentoArrecadacao(
      contribuinteNumero: contribuinteNumero,
      categoria: isPessoaFisica ? CategoriaDctf.pf13Salario : CategoriaDctf.geral13Salario,
      anoPA: anoPA,
      numeroReciboEntrega: numeroReciboEntrega,
      dataAcolhimentoProposta: dataAcolhimentoProposta,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta XML e transmite declaração em um fluxo completo
  ///
  /// ATENÇÃO: Este método requer que você implemente a assinatura digital externamente.
  /// O parâmetro [assinadorXml] deve ser uma função que recebe o XML em Base64
  /// e retorna o mesmo XML assinado digitalmente.
  ///
  /// [contribuinteNumero] CPF ou CNPJ do contribuinte
  /// [categoria] Categoria da declaração
  /// [anoPA] Ano do período de apuração
  /// [mesPA] Mês do período de apuração
  /// [diaPA] Dia do período de apuração - apenas para espetáculo desportivo
  /// [numProcReclamatoria] Número do processo - apenas para reclamatória trabalhista
  /// [assinadorXml] Função que assina digitalmente o XML
  /// [contratanteNumero] CPF ou CNPJ do contratante do serviço
  /// [autorPedidoDadosNumero] CPF ou CNPJ do autor do pedido de dados
  Future<TransmitirDeclaracaoDctfResponse> consultarXmlETransmitir({
    required String contribuinteNumero,
    required CategoriaDctf categoria,
    required String anoPA,
    String? mesPA,
    String? diaPA,
    String? numProcReclamatoria,
    required Future<String> Function(String xmlBase64) assinadorXml,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // 1. Consultar/Gerar XML
    final xmlResponse = await consultarXmlDeclaracao(
      contribuinteNumero: contribuinteNumero,
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      numProcReclamatoria: numProcReclamatoria,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    if (!xmlResponse.sucesso || xmlResponse.xmlBase64 == null) {
      throw Exception('Falha ao obter XML: ${xmlResponse.mensagemErro ?? "XML não disponível"}');
    }

    // 2. Assinar XML externamente
    final xmlAssinado = await assinadorXml(xmlResponse.xmlBase64!);

    // 3. Transmitir declaração
    return transmitirDeclaracao(
      contribuinteNumero: contribuinteNumero,
      categoria: categoria,
      anoPA: anoPA,
      mesPA: mesPA,
      diaPA: diaPA,
      numProcReclamatoria: numProcReclamatoria,
      xmlAssinadoBase64: xmlAssinado,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  bool validarXmlBase64(String xmlBase64) {
    if (xmlBase64.isEmpty) return false;
    try {
      // Tentar decodificar Base64
      final decoded = base64.decode(xmlBase64);

      // Verificar se contém caracteres XML básicos
      final xmlString = String.fromCharCodes(decoded);
      return xmlString.contains('<?xml') && xmlString.contains('<ConteudoDeclaracao') && xmlString.contains('</ConteudoDeclaracao>');
    } catch (e) {
      return false;
    }
  }
}
