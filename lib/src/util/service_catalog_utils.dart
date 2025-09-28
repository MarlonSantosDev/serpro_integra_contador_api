/// Utilitário para mapeamento de códigos de funcionalidade baseado no catálogo de serviços
///
/// Este utilitário converte os códigos de serviço (idServico) em códigos sequenciais
/// conforme especificado no catálogo de serviços do Integra Contador.
class ServiceCatalogUtils {
  /// Mapeamento de códigos de serviço para códigos sequenciais
  /// Baseado no catálogo de serviços (.cursor/rules/catalogodeservicos.mdc)
  static const Map<String, String> _serviceCodeMapping = {
    // Integra-SN
    'TRANSDECLARACAO11': '01',
    'GERARDAS12': '02',
    'CONSDECLARACAO13': '03',
    'CONSULTIMADECREC14': '04',
    'CONSDECREC15': '05',
    'CONSEXTRATO16': '06',
    'GERARDASCOBRANCA17': '07',
    'GERARDASPROCESSO18': '08',
    'GERARDASAVULSO19': '09',
    'EFETUAROPCAOREGIME101': '10',
    'CONSULTARANOSCALENDARIOS102': '11',
    'CONSULTAROPCAOREGIME103': '12',
    'CONSULTARRESOLUCAO104': '13',
    'TRANSDECLARACAO141': '14',
    'CONSDECLARACAO142': '15',
    'CONSULTIMADECREC143': '16',
    'CONSDECREC144': '17',

    // Integra-MEI
    'GERARDASPDF21': '18',
    'GERARDASCODBARRA22': '19',
    'ATUBENEFICIO23': '20',
    'DIVIDAATIVA24': '21',
    'EMITIRCCMEI121': '22',
    'DADOSCCMEI122': '23',
    'CCMEISITCADASTRAL123': '24',
    'TRANSDECLARACAO151': '25',
    'CONSULTIMADECREC152': '26',
    'ATUALIZADASEXCESSO153': '27',

    // Integra-DCTFWeb
    'GERARGUIA31': '28',
    'CONSRECIBO32': '29',
    'CONSDECCOMPLETA33': '30',
    'CONSRELCREDITO34': '31',
    'CONSRELDEBITO35': '32',
    'GERARGUIAMAED36': '33',
    'CONSNOTIFMAED37': '34',
    'CONSXMLDECLARACAO38': '35',
    'APLVINCULACAO39': '36',
    'TRANSDECLARACAO310': '37',
    'GERARGUIACOMABATIMENTO311': '38',
    'EDITARVALORSUSPENSO312': '39',
    'GERARGUIAANDAMENTO313': '40',
    'ENCAPURACAO314': '41',
    'SITUACAOENC315': '42',
    'CONSAPURACAO316': '43',
    'LISTAAPURACOES317': '44',

    // Integra-Procurações
    'OBTERPROCURACAO41': '45',

    // Integra-Sicalc
    'CONSOLIDARGERARDARF51': '46',
    'CONSULTAAPOIORECEITAS52': '47',
    'GERARDARFCODBARRA53': '48',

    // Integra-CaixaPostal
    'MSGCONTRIBUINTE61': '49',
    'MSGDETALHAMENTO62': '50',
    'INNOVAMSG63': '51',
    'CONSULTASITUACAODTE111': '52',

    // Integra-Pagamento
    'CONSULTAR71': '53',
    'CONSULTARLOTE72': '54',

    // Integra-Contador-Gerenciador
    'CONSULTAR81': '55',
    'CONSULTARLOTE82': '56',
    'CONSULTARRESPOSTA83': '57',
    'CONSULTARRESPOSTALOTE84': '58',

    // Integra-SITFIS
    'CONSULTARINTIMACAO91': '59',
    'CONSULTARAUTOINFRACAO92': '60',
    'CONSULTARCIENCIAINTIMACAO93': '61',
    'CONSULTARCIENCIAAUTOINFRACAO94': '62',
    'CONSULTARPROCESSOSFISCAIS95': '63',
    'CONSULTARPROCESSOSFISCAISDETALHES96': '64',
    'CONSULTARPROCESSOSFISCAISCIENCIA97': '65',

    // Integra-Parcelamentos
    'EMITIRPARCELA131': '66',
    'CONSULTARPARCELAMENTOS132': '67',
    'CONSULTARPEDIDOS133': '68',
    'REGISTRARDEBITOAUTOMATICO134': '69',
    'DESISTIRPARCELAMENTO135': '70',
    'EMITIRPARCELA161': '71',
    'CONSULTARPARCELAMENTOS162': '72',
    'CONSULTARPEDIDOS163': '73',
    'REGISTRARDEBITOAUTOMATICO164': '74',
    'DESISTIRPARCELAMENTO165': '75',
    'EMITIRPARCELA171': '76',
    'CONSULTARPARCELAMENTOS172': '77',
    'EMITIRPARCELA181': '78',
    'CONSULTARPARCELAMENTOS182': '79',

    // Integra-Redesim
    'CONSULTAROPCAO191': '80',
    'EFETUAROPCAO192': '81',
    'CONSULTARVIABILIDADE201': '82',
    'CONSULTARCOLETORDADOS202': '83',
    'CONSULTARINSCRICAOTRIBUTARIA211': '84',
    'CONSULTARALVARA221': '85',
    'CONSULTARLICENCAS231': '86',
    'CONSULTARDBE241': '87',
    'ACOMPANHARPROTOCOLO251': '88',
    'CONSULTARPJ261': '89',

    // Integra-e-Processo
    'CONSULTARPROCESSOSINTERESSADO271': '90',
    'OBTERLISTADOCSPROC272': '91',
    'OBTERDOCUMENTOPROCESSO273': '92',
    'CONSULTARCOMUNICADOSINTIMACOES274': '93',

    // Autenticação de Procurador (código especial)
    'AUTENTICARPROCURADOR': '94',
  };

  /// Obtém o código sequencial da funcionalidade baseado no idServico
  ///
  /// [idServico] - Código do serviço (ex: 'TRANSDECLARACAO11')
  ///
  /// Retorna o código sequencial de 2 dígitos (ex: '01') ou '00' se não encontrado
  static String getFunctionCode(String idServico) {
    return _serviceCodeMapping[idServico] ?? '00';
  }

  /// Verifica se um serviço existe no catálogo
  ///
  /// [idServico] - Código do serviço
  ///
  /// Retorna true se o serviço existe no catálogo
  static bool isServiceInCatalog(String idServico) {
    return _serviceCodeMapping.containsKey(idServico);
  }

  /// Obtém todos os serviços disponíveis no catálogo
  ///
  /// Retorna uma lista com todos os códigos de serviço disponíveis
  static List<String> getAllServices() {
    return _serviceCodeMapping.keys.toList();
  }
}
