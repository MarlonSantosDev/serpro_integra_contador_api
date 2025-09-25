import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Inicializar o cliente da API
  final apiClient = ApiClient();

  // Autenticar com dados da empresa contratante e autor do pedido
  await apiClient.authenticate(
    consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Key
    consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Secret
    certPath: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Caminho para seu certificado
    certPassword: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Senha do certificado
    contratanteNumero: '00000000000100', // CNPJ da empresa que contratou o serviço na Loja Serpro
    autorPedidoDadosNumero: '00000000000100', // CPF/CNPJ do autor da requisição (pode ser procurador/contador)
  );

  // Exemplo de uso dos serviços
  //await exemplosCcmei(apiClient);
  await exemplosPgmei(apiClient);
  //await exemplosPgdasd(apiClient);
  //await exemplosDctfWeb(apiClient);
  //await exemplosProcuracoes(apiClient);
  //await exemplosCaixaPostal(apiClient);
  //await exemplosDte(apiClient);
  //await exemplosSitfis(apiClient);
  //await exemplosDefis(apiClient);
}

Future<void> exemplosCcmei(ApiClient apiClient) async {
  print('=== Exemplos CCMEI ===');

  final ccmeiService = CcmeiService(apiClient);

  try {
    // Emitir CCMEI
    final emitirResponse = await ccmeiService.emitirCcmei('00000000000000');
    print('CCMEI emitido com sucesso');

    // Consultar Dados CCMEI
    final consultarResponse = await ccmeiService.consultarDadosCcmei('00000000000000');
    print('Dados CCMEI consultados: ${consultarResponse.dados.nomeEmpresarial}');

    // Consultar Situação Cadastral
    final situacaoResponse = await ccmeiService.consultarSituacaoCadastral('00000000000');
    print('Situação cadastral consultada');
  } catch (e) {
    print('Erro nos serviços CCMEI: $e');
  }
}

Future<void> exemplosPgmei(ApiClient apiClient) async {
  print('=== Exemplos PGMEI ===');

  final pgmeiService = PgmeiService(apiClient);
  /*
  try {
    // Gerar DAS
    final response = await pgmeiService.gerarDas('00000000000100', '2023-10');
    print('DAS gerado com sucesso Padrao');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }
  try {
    final response = await pgmeiService.gerarDasCodigoDeBarras('00000000000100', '2023-10');
    print('DAS gerado com sucesso Codigo de Barras');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }
  */
  try {
    final response = await pgmeiService.AtualizarBeneficio('00000000000100', '2023-10');
    print('DAS gerado com sucesso Atualizar Beneficio');

    if (response.dados.isNotEmpty) {
      //final das = response.dados.first;
      print("response: ${response.dados.first.toJson()}");
    }
  } catch (e) {
    print('Erro no serviço PGMEI: Atualizar Beneficio: $e');
  }
  /*
  try {
    final response = await pgmeiService.ConsultarDividaAtiva('00000000000100', '2020');
    print('DAS gerado com sucesso Consultar Divida Ativa');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }*/
}

Future<void> exemplosPgdasd(ApiClient apiClient) async {
  print('=== Exemplos PGDASD ===');

  final pgdasdService = PgdasdService(apiClient);

  try {
    // Declarar
    final response = await pgdasdService.declarar('00000000000000', '{}');
    print('Declaração PGDASD realizada: ${response.status}');
  } catch (e) {
    print('Erro no serviço PGDASD: $e');
  }
}

Future<void> exemplosDctfWeb(ApiClient apiClient) async {
  print('=== Exemplos DCTFWeb ===');

  final dctfWebService = DctfWebService(apiClient);

  try {
    // Gerar DARF
    final response = await dctfWebService.gerarDarf('00000000000000', '2023-10');
    print('DARF gerado: ${response.status}');
  } catch (e) {
    print('Erro no serviço DCTFWeb: $e');
  }
}

Future<void> exemplosProcuracoes(ApiClient apiClient) async {
  print('=== Exemplos Procurações ===');

  final procuracoesService = ProcuracoesService(apiClient);

  try {
    // Obter Procuração
    final response = await procuracoesService.obterProcuracao('00000000000000');
    print('Procurações obtidas: ${response.dadosSaida.procuracoes.length}');
  } catch (e) {
    print('Erro no serviço de Procurações: $e');
  }
}

Future<void> exemplosCaixaPostal(ApiClient apiClient) async {
  print('=== Exemplos Caixa Postal ===');

  final caixaPostalService = CaixaPostalService(apiClient);

  try {
    // Consultar Mensagens
    final response = await caixaPostalService.consultarMensagens('00000000000');
    print('Mensagens na caixa postal: ${response.mensagens.length}');
  } catch (e) {
    print('Erro no serviço da Caixa Postal: $e');
  }
}

Future<void> exemplosDte(ApiClient apiClient) async {
  print('=== Exemplos DTE ===');

  final dteService = DteService(apiClient);

  try {
    // Declarar
    final response = await dteService.declarar('00000000000000', '{}');
    print('Declaração DTE realizada: ${response.status}');
  } catch (e) {
    print('Erro no serviço DTE: $e');
  }
}

Future<void> exemplosSitfis(ApiClient apiClient) async {
  print('=== Exemplos SITFIS ===');

  final sitfisService = SitfisService(apiClient);

  try {
    // Solicitar Protocolo
    final protocoloResponse = await sitfisService.solicitarProtocolo('00000000000');
    print('Protocolo solicitado');

    // Simular protocolo para exemplo
    final protocolo = 'exemplo_protocolo';

    // Emitir Relatório
    final relatorioResponse = await sitfisService.emitirRelatorio('00000000000', protocolo);
    print('Relatório SITFIS emitido');
  } catch (e) {
    print('Erro no serviço SITFIS: $e');
  }
}

Future<void> exemplosDefis(ApiClient apiClient) async {
  print('=== Exemplos DEFIS ===');

  final defisService = DefisService(apiClient);

  try {
    // Criar uma declaração de exemplo
    final declaracao = TransmitirDeclaracaoRequest(
      ano: 2023,
      situacaoEspecial: null,
      inatividade: 2,
      empresa: Empresa(
        ganhoCapital: 0,
        qtdEmpregadoInicial: 1,
        qtdEmpregadoFinal: 1,
        receitaExportacaoDireta: 0,
        socios: [
          Socio(cpf: '00000000000', rendimentosIsentos: 10000, rendimentosTributaveis: 5000, participacaoCapitalSocial: 100, irRetidoFonte: 0),
        ],
        ganhoRendaVariavel: 0,
        estabelecimentos: [
          Estabelecimento(
            cnpjCompleto: '00000000000000',
            estoqueInicial: 1000,
            estoqueFinal: 2000,
            saldoCaixaInicial: 5000,
            saldoCaixaFinal: 15000,
            aquisicoesMercadoInterno: 10000,
            importacoes: 0,
            totalEntradasPorTransferencia: 0,
            totalSaidasPorTransferencia: 0,
            totalDevolucoesVendas: 100,
            totalEntradas: 10100,
            totalDevolucoesCompras: 50,
            totalDespesas: 8000,
          ),
        ],
      ),
    );

    // Transmitir Declaração
    final response = await defisService.transmitirDeclaracao('00000000000000', declaracao);
    print('Declaração DEFIS transmitida: ${response.dados.idDefis}');
  } catch (e) {
    print('Erro no serviço DEFIS: $e');
  }
}
