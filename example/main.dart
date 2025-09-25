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
  //await exemplosPgmei(apiClient);
  //await exemplosPgdasd(apiClient);
  //await exemplosDctfWeb(apiClient);
  //await exemplosProcuracoes(apiClient);
  await exemplosCaixaPostal(apiClient);
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
    // 1. Verificar se há mensagens novas
    print('\n--- Verificando mensagens novas ---');
    final temNovas = await caixaPostalService.temMensagensNovas('99999999999999');
    print('Tem mensagens novas: $temNovas');

    // 2. Obter indicador detalhado de mensagens novas
    print('\n--- Indicador de mensagens novas ---');
    final indicadorResponse = await caixaPostalService.obterIndicadorNovasMensagens('99999999999999');
    print('Status HTTP: ${indicadorResponse.status}');
    if (indicadorResponse.dadosParsed != null) {
      final conteudo = indicadorResponse.dadosParsed!.conteudo.first;
      print('Indicador: ${conteudo.indicadorMensagensNovas}');
      print('Status: ${conteudo.statusMensagensNovas}');
      print('Descrição: ${conteudo.descricaoStatus}');
      print('Tem mensagens novas: ${conteudo.temMensagensNovas}');
    }

    // 3. Listar todas as mensagens
    print('\n--- Listando todas as mensagens ---');
    final listaResponse = await caixaPostalService.listarTodasMensagens('99999999999999');
    print('Status HTTP: ${listaResponse.status}');
    if (listaResponse.dadosParsed != null && listaResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = listaResponse.dadosParsed!.conteudo.first;
      print('Quantidade de mensagens: ${conteudo.quantidadeMensagensInt}');
      print('É última página: ${conteudo.isUltimaPagina}');
      print('Ponteiro próxima página: ${conteudo.ponteiroProximaPagina}');

      // Exibir primeiras 3 mensagens
      final mensagens = conteudo.listaMensagens.take(3);
      for (var i = 0; i < mensagens.length; i++) {
        final msg = mensagens.elementAt(i);
        print('\nMensagem ${i + 1}:');
        print('  ISN: ${msg.isn}');
        print('  Assunto: ${msg.assuntoProcessado}');
        print('  Data envio: ${MessageUtils.formatarData(msg.dataEnvio)}');
        print('  Foi lida: ${msg.foiLida}');
        print('  É favorita: ${msg.isFavorita}');
        print('  Relevância: ${MessageUtils.obterDescricaoRelevancia(msg.relevancia)}');
        print('  Origem: ${msg.descricaoOrigem}');
      }
    }

    // 4. Listar apenas mensagens não lidas
    print('\n--- Listando mensagens não lidas ---');
    final naoLidasResponse = await caixaPostalService.listarMensagensNaoLidas('99999999999999');
    if (naoLidasResponse.dadosParsed != null && naoLidasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = naoLidasResponse.dadosParsed!.conteudo.first;
      print('Mensagens não lidas: ${conteudo.quantidadeMensagensInt}');
    }

    // 5. Listar apenas mensagens lidas
    print('\n--- Listando mensagens lidas ---');
    final lidasResponse = await caixaPostalService.listarMensagensLidas('99999999999999');
    if (lidasResponse.dadosParsed != null && lidasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = lidasResponse.dadosParsed!.conteudo.first;
      print('Mensagens lidas: ${conteudo.quantidadeMensagensInt}');
    }

    // 6. Listar mensagens favoritas
    print('\n--- Listando mensagens favoritas ---');
    final favoritasResponse = await caixaPostalService.listarMensagensFavoritas('99999999999999');
    if (favoritasResponse.dadosParsed != null && favoritasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = favoritasResponse.dadosParsed!.conteudo.first;
      print('Mensagens favoritas: ${conteudo.quantidadeMensagensInt}');
    }

    // 7. Obter detalhes de uma mensagem específica (usando ISN da primeira mensagem)
    if (listaResponse.dadosParsed != null &&
        listaResponse.dadosParsed!.conteudo.isNotEmpty &&
        listaResponse.dadosParsed!.conteudo.first.listaMensagens.isNotEmpty) {
      final primeiraMsg = listaResponse.dadosParsed!.conteudo.first.listaMensagens.first;
      print('\n--- Detalhes da mensagem ISN: ${primeiraMsg.isn} ---');

      final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica('99999999999999', primeiraMsg.isn);

      if (detalhesResponse.dadosParsed != null && detalhesResponse.dadosParsed!.conteudo.isNotEmpty) {
        final detalhe = detalhesResponse.dadosParsed!.conteudo.first;
        print('Assunto processado: ${detalhe.assuntoProcessado}');
        print('Data de envio: ${MessageUtils.formatarData(detalhe.dataEnvio)}');
        print('Data de expiração: ${MessageUtils.formatarData(detalhe.dataExpiracao)}');
        print('É favorita: ${detalhe.isFavorita}');

        // Corpo da mensagem processado
        final corpoProcessado = detalhe.corpoProcessado;
        final corpoLimpo = MessageUtils.removerTagsHtml(corpoProcessado);
        print('Corpo (primeiros 200 caracteres):');
        print('${corpoLimpo.length > 200 ? corpoLimpo.substring(0, 200) + '...' : corpoLimpo}');

        // Mostrar variáveis se existirem
        if (detalhe.variaveis.isNotEmpty) {
          print('\nVariáveis da mensagem:');
          for (var i = 0; i < detalhe.variaveis.length; i++) {
            print('  ++${i + 1}++: ${detalhe.variaveis[i]}');
          }
        }
      }
    }

    // 8. Exemplo de paginação (se houver mais páginas)
    if (listaResponse.dadosParsed != null &&
        listaResponse.dadosParsed!.conteudo.isNotEmpty &&
        !listaResponse.dadosParsed!.conteudo.first.isUltimaPagina) {
      print('\n--- Exemplo de paginação ---');
      final proximaPagina = listaResponse.dadosParsed!.conteudo.first.ponteiroProximaPagina;

      final paginaResponse = await caixaPostalService.listarMensagensComPaginacao('99999999999999', ponteiroPagina: proximaPagina);

      if (paginaResponse.dadosParsed != null && paginaResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = paginaResponse.dadosParsed!.conteudo.first;
        print('Mensagens da próxima página: ${conteudo.quantidadeMensagensInt}');
      }
    }

    // 9. Exemplo usando filtros específicos
    print('\n--- Exemplo com filtros específicos ---');
    final filtradaResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
      '99999999999999',
      statusLeitura: 0, // Todas as mensagens
      indicadorFavorito: null, // Sem filtro de favorita
      indicadorPagina: 0, // Página inicial
    );

    if (filtradaResponse.dadosParsed != null && filtradaResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = filtradaResponse.dadosParsed!.conteudo.first;
      print('Mensagens com filtros específicos: ${conteudo.quantidadeMensagensInt}');
    }
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
