import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_request.dart' as defis;
import 'package:serpro_integra_contador_api/src/models/defis/defis_enums.dart' as defis;
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as pgdasd_models;

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
  await exemplosCaixaPostal(apiClient);
  await exemplosCcmei(apiClient);
  // await exemplosPgmei(apiClient);
  // await exemplosCcmei(apiClient);
  // await exemplosPgdasd(apiClient);
  // await exemplosDctfWeb(apiClient);
  // await exemplosProcuracoes(apiClient);
  // await exemplosDte(apiClient);
  // await exemplosSitfis(apiClient);
  // await exemplosDefis(apiClient);
  // await exemplosPagtoWeb(apiClient);
  // await exemplosAutenticaProcurador(apiClient);
  // await exemplosRelpsn(apiClient);
  // await exemplosPertsn(apiClient);
  // await exemplosParcmeiEspecial(apiClient);
  // await exemplosParcmei(apiClient);
  // await exemplosSicalc(apiClient);
  // await exemplosRelpmei(apiClient);
  // await exemplosPertmei(apiClient);
  // await exemplosParcsnEspecial(apiClient);
  // await exemplosMit(apiClient);
  // await exemplosEventosAtualizacao(apiClient);
}

Future<void> exemplosCaixaPostal(ApiClient apiClient) async {
  print('=== Exemplos Caixa Postal ===');

  final caixaPostalService = CaixaPostalService(apiClient);

  // Declarar listaResponse no escopo principal para ser usado em outras seções
  dynamic listaResponse;

  try {
    // 1. Verificar se há mensagens novas
    try {
      print('\n--- Verificando mensagens novas ---');
      final temNovas = await caixaPostalService.temMensagensNovas(
        '99999999999',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );
      print('📬 Tem mensagens novas: $temNovas');
    } catch (e) {
      print('❌ Erro ao verificar mensagens novas: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 2. Obter indicador detalhado de mensagens novas
    try {
      print('\n--- Indicador de mensagens novas ---');
      final indicadorResponse = await caixaPostalService.obterIndicadorNovasMensagens(
        '99999999999',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );
      print('✅ Status HTTP: ${indicadorResponse.status}');
      if (indicadorResponse.dadosParsed != null) {
        final conteudo = indicadorResponse.dadosParsed!.conteudo.first;
        print('📊 Indicador: ${conteudo.indicadorMensagensNovas}');
        print('📈 Status: ${conteudo.statusMensagensNovas}');
        print('📝 Descrição: ${conteudo.descricaoStatus}');
        print('📬 Tem mensagens novas: ${conteudo.temMensagensNovas}');
      }
    } catch (e) {
      print('❌ Erro ao obter indicador de mensagens novas: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 3. Listar todas as mensagens
    try {
      print('\n--- Listando todas as mensagens ---');
      listaResponse = await caixaPostalService.listarTodasMensagens(
        '99999999999999',
        contratanteNumero: '99999999999999',
        autorPedidoDadosNumero: '99999999999999',
      );
      print('✅ Status HTTP: ${listaResponse.status}');
      if (listaResponse.dadosParsed != null && listaResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = listaResponse.dadosParsed!.conteudo.first;
        print('📊 Quantidade de mensagens: ${conteudo.quantidadeMensagensInt}');
        print('📄 É última página: ${conteudo.isUltimaPagina}');
        print('➡️ Ponteiro próxima página: ${conteudo.ponteiroProximaPagina}');

        // Exibir primeiras 3 mensagens
        final mensagens = conteudo.listaMensagens.take(3);
        for (var i = 0; i < mensagens.length; i++) {
          final msg = mensagens.elementAt(i);
          print('\n📧 Mensagem ${i + 1}:');
          print('  🆔 ISN: ${msg.isn}');
          print('  📝 Assunto: ${msg.assuntoProcessado}');
          print('  📅 Data envio: ${MessageUtils.formatarData(msg.dataEnvio)}');
          print('  👁️ Foi lida: ${msg.foiLida}');
          print('  ⭐ É favorita: ${msg.isFavorita}');
          print('  📈 Relevância: ${MessageUtils.obterDescricaoRelevancia(msg.relevancia)}');
          print('  📍 Origem: ${msg.descricaoOrigem}');
        }
      }
    } catch (e) {
      print("❌ Erro ao listar todas as mensagens: $e");
    }
    await Future.delayed(Duration(seconds: 10));

    // 4. Listar apenas mensagens não lidas
    try {
      print('\n--- Listando mensagens não lidas ---');
      final naoLidasResponse = await caixaPostalService.listarMensagensNaoLidas(
        '99999999999999',
        contratanteNumero: '99999999999999',
        autorPedidoDadosNumero: '99999999999999',
      );
      if (naoLidasResponse.dadosParsed != null && naoLidasResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = naoLidasResponse.dadosParsed!.conteudo.first;
        print('📬 Mensagens não lidas: ${conteudo.quantidadeMensagensInt}');
      }
    } catch (e) {
      print('❌ Erro ao listar todas as mensagens: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 5. Listar apenas mensagens lidas
    try {
      print('\n--- Listando mensagens lidas ---');
      final lidasResponse = await caixaPostalService.listarMensagensLidas(
        '99999999999999',
        contratanteNumero: '99999999999999',
        autorPedidoDadosNumero: '99999999999999',
      );
      if (lidasResponse.dadosParsed != null && lidasResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = lidasResponse.dadosParsed!.conteudo.first;
        print('👁️ Mensagens lidas: ${conteudo.quantidadeMensagensInt}');
      }
    } catch (e) {
      print("❌ Erro ao listar mensagens lidas: $e");
    }
    await Future.delayed(Duration(seconds: 10));

    // 6. Listar mensagens favoritas
    try {
      print('\n--- Listando mensagens favoritas ---');
      final favoritasResponse = await caixaPostalService.listarMensagensFavoritas(
        '99999999999999',
        contratanteNumero: '99999999999999',
        autorPedidoDadosNumero: '99999999999999',
      );
      if (favoritasResponse.dadosParsed != null && favoritasResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = favoritasResponse.dadosParsed!.conteudo.first;
        print('⭐ Mensagens favoritas: ${conteudo.quantidadeMensagensInt}');
      }
    } catch (e) {
      print("❌ Erro ao listar mensagens favoritas: $e");
    }
    await Future.delayed(Duration(seconds: 10));

    // 7. Obter detalhes de uma mensagem específica (usando ISN da primeira mensagem)
    try {
      if (listaResponse.dadosParsed != null &&
          listaResponse.dadosParsed!.conteudo.isNotEmpty &&
          listaResponse.dadosParsed!.conteudo.first.listaMensagens.isNotEmpty) {
        final primeiraMsg = listaResponse.dadosParsed!.conteudo.first.listaMensagens.first;
        print('\n--- Detalhes da mensagem ISN: ${primeiraMsg.isn} ---');

        final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica(
          '00000000000000',
          contratanteNumero: '00000000000000',
          autorPedidoDadosNumero: '00000000000000',
          primeiraMsg.isn,
        );

        if (detalhesResponse.dadosParsed != null && detalhesResponse.dadosParsed!.conteudo.isNotEmpty) {
          final detalhe = detalhesResponse.dadosParsed!.conteudo.first;
          print('📝 Assunto processado: ${detalhe.assuntoProcessado}');
          print('📅 Data de envio: ${MessageUtils.formatarData(detalhe.dataEnvio)}');
          print('⏰ Data de expiração: ${MessageUtils.formatarData(detalhe.dataExpiracao)}');
          print('⭐ É favorita: ${detalhe.isFavorita}');

          // Corpo da mensagem processado
          final corpoProcessado = detalhe.corpoProcessado;
          final corpoLimpo = MessageUtils.removerTagsHtml(corpoProcessado);
          print('📄 Corpo (primeiros 200 caracteres):');
          print('${corpoLimpo.length > 200 ? corpoLimpo.substring(0, 200) + '...' : corpoLimpo}');

          // Mostrar variáveis se existirem
          if (detalhe.variaveis.isNotEmpty) {
            print('\n🔧 Variáveis da mensagem:');
            for (var i = 0; i < detalhe.variaveis.length; i++) {
              print('  ++${i + 1}++: ${detalhe.variaveis[i]}');
            }
          }
        }
      }
    } catch (e) {
      print("❌ Erro ao obter detalhes da mensagem específica: $e");
    }
    await Future.delayed(Duration(seconds: 10));

    // 8. Exemplo de paginação (se houver mais páginas)
    try {
      if (listaResponse.dadosParsed != null &&
          listaResponse.dadosParsed!.conteudo.isNotEmpty &&
          !listaResponse.dadosParsed!.conteudo.first.isUltimaPagina) {
        print('\n--- Exemplo de paginação ---');
        final proximaPagina = listaResponse.dadosParsed!.conteudo.first.ponteiroProximaPagina;

        final paginaResponse = await caixaPostalService.listarMensagensComPaginacao(
          '99999999999999',
          contratanteNumero: '99999999999999',
          autorPedidoDadosNumero: '99999999999999',
          ponteiroPagina: proximaPagina,
        );

        if (paginaResponse.dadosParsed != null && paginaResponse.dadosParsed!.conteudo.isNotEmpty) {
          final conteudo = paginaResponse.dadosParsed!.conteudo.first;
          print('📄 Mensagens da próxima página: ${conteudo.quantidadeMensagensInt}');
        }
      }
    } catch (e) {
      print("❌ Erro ao listar paginação: $e");
    }
    await Future.delayed(Duration(seconds: 10));

    // 9. Exemplo usando filtros específicos
    try {
      print('\n--- Exemplo com filtros específicos ---');
      final filtradaResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
        '99999999999999',
        contratanteNumero: '99999999999999',
        autorPedidoDadosNumero: '99999999999999',
        statusLeitura: 0, // Todas as mensagens
        indicadorFavorito: null, // Sem filtro de favorita
        indicadorPagina: 0, // Página inicial
      );

      if (filtradaResponse.dadosParsed != null && filtradaResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = filtradaResponse.dadosParsed!.conteudo.first;
        print('🔍 Mensagens com filtros específicos: ${conteudo.quantidadeMensagensInt}');
      }
    } catch (e) {
      print("❌ Erro ao listar mensagens com filtros específicos: $e");
    }
    await Future.delayed(Duration(seconds: 10));
  } catch (e) {
    print('💥 Erro no serviço da Caixa Postal: $e');
  }
}

Future<void> exemplosCcmei(ApiClient apiClient) async {
  print('=== Exemplos CCMEI ===');

  final ccmeiService = CcmeiService(apiClient);

  try {
    // 1. Emitir CCMEI (PDF)
    try {
      print('\n--- 1. Emitir CCMEI (PDF) ---');
      final emitirResponse = await ccmeiService.emitirCcmei(
        '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );
      print('✅ Status: ${emitirResponse.status}');
      print('📋 Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('🏢 CNPJ: ${emitirResponse.dados.cnpj}');
      print('📄 PDF gerado: ${emitirResponse.dados.pdf.isNotEmpty ? 'Sim' : 'Não'}');
      print('📏 Tamanho do PDF: ${emitirResponse.dados.pdf.length} caracteres');
    } catch (e) {
      print('❌ Erro ao emitir CCMEI: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 2. Consultar Dados CCMEI
    try {
      print('\n--- 2. Consultar Dados CCMEI ---');
      final consultarResponse = await ccmeiService.consultarDadosCcmei(
        '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );
      print('✅ Status: ${consultarResponse.status}');
      print('📋 Mensagens: ${consultarResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('🏢 CNPJ: ${consultarResponse.dados.cnpj}');
      print('📝 Nome Empresarial: ${consultarResponse.dados.nomeEmpresarial}');
      print('👤 Empresário: ${consultarResponse.dados.empresario.nomeCivil}');
      print('🆔 CPF Empresário: ${consultarResponse.dados.empresario.cpf}');
      print('📅 Data Início Atividades: ${consultarResponse.dados.dataInicioAtividades}');
      print('📊 Situação Cadastral: ${consultarResponse.dados.situacaoCadastralVigente}');
      print('💰 Capital Social: R\$ ${consultarResponse.dados.capitalSocial}');
      print('📍 Endereço: ${consultarResponse.dados.enderecoComercial.logradouro}, ${consultarResponse.dados.enderecoComercial.numero}');
      print('🏘️ Bairro: ${consultarResponse.dados.enderecoComercial.bairro}');
      print('🏙️ Município: ${consultarResponse.dados.enderecoComercial.municipio}/${consultarResponse.dados.enderecoComercial.uf}');
      print('📮 CEP: ${consultarResponse.dados.enderecoComercial.cep}');
      print('🏪 Enquadramento MEI: ${consultarResponse.dados.enquadramento.optanteMei ? 'Sim' : 'Não'}');
      print('📈 Situação Enquadramento: ${consultarResponse.dados.enquadramento.situacao}');
      print('📅 Períodos MEI: ${consultarResponse.dados.enquadramento.periodosMei.length} período(s)');
      for (var periodo in consultarResponse.dados.enquadramento.periodosMei) {
        print('  - Período ${periodo.indice}: ${periodo.dataInicio} até ${periodo.dataFim ?? 'atual'}');
      }
      print('💼 Formas de Atuação: ${consultarResponse.dados.atividade.formasAtuacao.join(', ')}');
      print('🎯 Ocupação Principal: ${consultarResponse.dados.atividade.ocupacaoPrincipal.descricaoOcupacao}');
      if (consultarResponse.dados.atividade.ocupacaoPrincipal.codigoCNAE != null) {
        print(
          '🏷️ CNAE Principal: ${consultarResponse.dados.atividade.ocupacaoPrincipal.codigoCNAE} - ${consultarResponse.dados.atividade.ocupacaoPrincipal.descricaoCNAE}',
        );
      }
      print('📋 Ocupações Secundárias: ${consultarResponse.dados.atividade.ocupacoesSecundarias.length}');
      for (var ocupacao in consultarResponse.dados.atividade.ocupacoesSecundarias) {
        print('  - ${ocupacao.descricaoOcupacao}');
        if (ocupacao.codigoCNAE != null) {
          print('    CNAE: ${ocupacao.codigoCNAE} - ${ocupacao.descricaoCNAE}');
        }
      }
      print('📄 Termo Ciência Dispensa: ${consultarResponse.dados.termoCienciaDispensa.titulo}');
      print('📱 QR Code disponível: ${consultarResponse.dados.qrcode != null ? 'Sim' : 'Não'}');
    } catch (e) {
      print('❌ Erro ao consultar dados CCMEI: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 3. Consultar Situação Cadastral por CPF
    try {
      print('\n--- 3. Consultar Situação Cadastral por CPF ---');
      final situacaoResponse = await ccmeiService.consultarSituacaoCadastral(
        '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );
      print('✅ Status: ${situacaoResponse.status}');
      print('📋 Mensagens: ${situacaoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('🔍 CNPJs encontrados: ${situacaoResponse.dados.length}');
      for (var situacao in situacaoResponse.dados) {
        print('  - CNPJ: ${situacao.cnpj}');
        print('    Situação: ${situacao.situacao}');
        print('    Enquadrado MEI: ${situacao.enquadradoMei ? 'Sim' : 'Não'}');
      }
    } catch (e) {
      print('❌ Erro ao consultar situação cadastral: $e');
    }

    print('\n🎉 Todos os serviços CCMEI executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral nos serviços CCMEI: $e');
    if (e.toString().contains('status')) {
      print('Verifique se o CNPJ/CPF informado é válido e se a empresa está cadastrada como MEI.');
    }
  }
}

Future<void> exemplosPgmei(ApiClient apiClient) async {
  print('=== Exemplos PGMEI ===');

  final pgmeiService = PgmeiService(apiClient);

  try {
    // 1. Gerar DAS Padrão
    try {
      print('\n--- 1. Gerar DAS Padrão ---');
      final response = await pgmeiService.gerarDas('00000000000100', '202310');
      print('✅ DAS gerado com sucesso Padrão');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS padrão: $e');
    }

    // 2. Gerar DAS com Código de Barras
    try {
      print('\n--- 2. Gerar DAS com Código de Barras ---');
      final response = await pgmeiService.gerarDasCodigoDeBarras('00000000000100', '202310');
      print('✅ DAS gerado com sucesso Código de Barras');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS com código de barras: $e');
    }

    // 3. Atualizar Benefício
    try {
      print('\n--- 3. Atualizar Benefício ---');
      final response = await pgmeiService.atualizarBeneficio('00000000000100', '202310');
      print('✅ Benefício atualizado com sucesso');

      if (response.dados.isNotEmpty) {
        print("📋 Response: ${response.dados.first.toJson()}");
      }
    } catch (e) {
      print('❌ Erro ao atualizar benefício: $e');
    }

    // 4. Consultar Dívida Ativa
    try {
      print('\n--- 4. Consultar Dívida Ativa ---');
      final response = await pgmeiService.consultarDividaAtiva('00000000000100', '2020');
      print('✅ Consulta de dívida ativa realizada com sucesso');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao consultar dívida ativa: $e');
    }

    print('\n🎉 Todos os serviços PGMEI executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral nos serviços PGMEI: $e');
  }
}

Future<void> exemplosPgdasd(ApiClient apiClient) async {
  print('=== Exemplos PGDASD ===');

  final pgdasdService = PgdasdService(apiClient);

  try {
    // 1. Entregar Declaração Mensal (TRANSDECLARACAO11)
    try {
      print('\n--- 1. Entregando Declaração Mensal ---');

      // Criar declaração de exemplo com dados reais conforme documentação
      final declaracao = pgdasd_models.Declaracao(
        tipoDeclaracao: 1, // Original
        receitaPaCompetenciaInterno: 50000.00,
        receitaPaCompetenciaExterno: 10000.00,
        estabelecimentos: [
          pgdasd_models.Estabelecimento(
            cnpjCompleto: '00000000000100',
            atividades: [
              pgdasd_models.Atividade(
                idAtividade: 1,
                valorAtividade: 60000.00,
                receitasAtividade: [
                  pgdasd_models.ReceitaAtividade(
                    valor: 60000.00,
                    isencoes: [pgdasd_models.Isencao(codTributo: 1, valor: 1000.00, identificador: 1)],
                    reducoes: [pgdasd_models.Reducao(codTributo: 1, valor: 500.00, percentualReducao: 5.0, identificador: 1)],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final entregarResponse = await pgdasdService.entregarDeclaracaoSimples(
        cnpj: '00000000000100',
        periodoApuracao: 202101,
        declaracao: declaracao,
        transmitir: true,
        compararValores: true,
        valoresParaComparacao: [
          pgdasd_models.ValorDevido(codigoTributo: 1, valor: 1000.00),
          pgdasd_models.ValorDevido(codigoTributo: 2, valor: 500.00),
        ],
      );

      print('✅ Status: ${entregarResponse.status}');
      print('✅ Sucesso: ${entregarResponse.sucesso}');

      if (entregarResponse.dadosParsed != null) {
        final declaracaoTransmitida = entregarResponse.dadosParsed!.first;
        print('🆔 ID Declaração: ${declaracaoTransmitida.idDeclaracao}');
        print('📅 Data Transmissão: ${declaracaoTransmitida.dataHoraTransmissao}');
        print('💰 Valor Total Devido: R\$ ${declaracaoTransmitida.valorTotalDevido}');
        print('📋 Tem MAED: ${declaracaoTransmitida.temMaed}');
      }
    } catch (e) {
      print('❌ Erro ao entregar declaração mensal: $e');
    }

    // 2. Gerar DAS (GERARDAS12)
    try {
      print('\n--- 2. Gerando DAS ---');

      final gerarDasResponse = await pgdasdService.gerarDasSimples(
        cnpj: '00000000000100',
        periodoApuracao: '202101',
        dataConsolidacao: '20220831', // Data futura para consolidação
      );

      print('✅ Status: ${gerarDasResponse.status}');
      print('✅ Sucesso: ${gerarDasResponse.sucesso}');

      if (gerarDasResponse.dadosParsed != null) {
        final das = gerarDasResponse.dadosParsed!.first;
        print('🏢 CNPJ: ${das.cnpjCompleto}');
        print('📅 Período: ${das.detalhamento.periodoApuracao}');
        print('📄 Número Documento: ${das.detalhamento.numeroDocumento}');
        print('📅 Data Vencimento: ${das.detalhamento.dataVencimento}');
        print('💰 Valor Total: R\$ ${das.detalhamento.valores.total}');
        print('📄 PDF disponível: ${das.pdf.isNotEmpty}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS: $e');
    }

    // 3. Consultar Declarações por Ano-Calendário (CONSDECLARACAO13)
    try {
      print('\n--- 3. Consultando Declarações por Ano ---');

      final consultarAnoResponse = await pgdasdService.consultarDeclaracoesPorAno(cnpj: '00000000000000', anoCalendario: '2018');

      print('✅ Status: ${consultarAnoResponse.status}');
      print('✅ Sucesso: ${consultarAnoResponse.sucesso}');

      if (consultarAnoResponse.dadosParsed != null) {
        final declaracoes = consultarAnoResponse.dadosParsed!;
        print('📅 Ano Calendário: ${declaracoes.anoCalendario}');
        print('🔍 Períodos encontrados: ${declaracoes.listaPeriodos.length}');

        for (final periodo in declaracoes.listaPeriodos.take(3)) {
          print('\n📅 Período ${periodo.periodoApuracao}:');
          print('  🔧 Operações: ${periodo.operacoes.length}');

          for (final operacao in periodo.operacoes.take(2)) {
            print('    ${operacao.tipoOperacao}');
            if (operacao.isDeclaracao) {
              print('      📄 Número: ${operacao.indiceDeclaracao!.numeroDeclaracao}');
              print('      🔍 Malha: ${operacao.indiceDeclaracao!.malha ?? 'Não está em malha'}');
            }
            if (operacao.isDas) {
              print('      💰 DAS: ${operacao.indiceDas!.numeroDas}');
              print('      ✅ Pago: ${operacao.indiceDas!.foiPago}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao consultar declarações por ano: $e');
    }

    // 4. Consultar Declarações por Período (CONSDECLARACAO13)
    try {
      print('\n--- 4. Consultando Declarações por Período ---');

      final consultarPeriodoResponse = await pgdasdService.consultarDeclaracoesPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

      print('✅ Status: ${consultarPeriodoResponse.status}');
      print('✅ Sucesso: ${consultarPeriodoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro ao consultar declarações por período: $e');
    }

    // 5. Consultar Última Declaração (CONSULTIMADECREC14)
    try {
      print('\n--- 5. Consultando Última Declaração ---');

      final ultimaDeclaracaoResponse = await pgdasdService.consultarUltimaDeclaracaoPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

      print('✅ Status: ${ultimaDeclaracaoResponse.status}');
      print('✅ Sucesso: ${ultimaDeclaracaoResponse.sucesso}');

      if (ultimaDeclaracaoResponse.dadosParsed != null) {
        final declaracao = ultimaDeclaracaoResponse.dadosParsed!;
        print('📄 Número Declaração: ${declaracao.numeroDeclaracao}');
        print('📄 Recibo disponível: ${declaracao.recibo.pdf.isNotEmpty}');
        print('📄 Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}');
        print('📋 Tem MAED: ${declaracao.temMaed}');

        if (declaracao.temMaed) {
          print('  📋 Notificação MAED: ${declaracao.maed!.pdfNotificacao.isNotEmpty}');
          print('  💰 DARF MAED: ${declaracao.maed!.pdfDarf.isNotEmpty}');
        }
      }
    } catch (e) {
      print('❌ Erro ao consultar última declaração: $e');
    }

    // 6. Consultar Declaração por Número (CONSDECREC15)
    try {
      print('\n--- 6. Consultando Declaração por Número ---');

      final declaracaoNumeroResponse = await pgdasdService.consultarDeclaracaoPorNumeroSimples(
        cnpj: '00000000000000',
        numeroDeclaracao: '00000000201801001',
      );

      print('✅ Status: ${declaracaoNumeroResponse.status}');
      print('✅ Sucesso: ${declaracaoNumeroResponse.sucesso}');
    } catch (e) {
      print('❌ Erro ao consultar declaração por número: $e');
    }

    // 7. Consultar Extrato do DAS (CONSEXTRATO16)
    try {
      print('\n--- 7. Consultando Extrato do DAS ---');

      final extratoDasResponse = await pgdasdService.consultarExtratoDasSimples(cnpj: '00000000000000', numeroDas: '07202136999997159');

      print('✅ Status: ${extratoDasResponse.status}');
      print('✅ Sucesso: ${extratoDasResponse.sucesso}');

      if (extratoDasResponse.dadosParsed != null) {
        final extrato = extratoDasResponse.dadosParsed!;
        print('💰 Número DAS: ${extrato.numeroDas}');
        print('🏢 CNPJ: ${extrato.cnpjCompleto}');
        print('📅 Período: ${extrato.periodoApuracao}');
        print('📅 Data Vencimento: ${extrato.dataVencimento}');
        print('💰 Valor Total: R\$ ${extrato.valorTotal}');
        print('📊 Status Pagamento: ${extrato.statusPagamento}');
        print('✅ Foi Pago: ${extrato.foiPago}');
        print('⏰ Está Vencido: ${extrato.estaVencido}');
        print('📋 Composição: ${extrato.composicao.length} tributos');

        for (final composicao in extrato.composicao.take(3)) {
          print('  ${composicao.nomeTributo}: R\$ ${composicao.valorTributo} (${composicao.percentual}%)');
        }
      }
    } catch (e) {
      print('❌ Erro ao consultar extrato do DAS: $e');
    }

    // 8. Exemplo com declaração complexa (receitas brutas anteriores, folha de salário, etc.)
    try {
      print('\n--- 8. Exemplo com Declaração Complexa ---');

      final declaracaoComplexa = pgdasd_models.Declaracao(
        tipoDeclaracao: 1, // Original
        receitaPaCompetenciaInterno: 100000.00,
        receitaPaCompetenciaExterno: 20000.00,
        receitasBrutasAnteriores: [
          pgdasd_models.ReceitaBrutaAnterior(pa: 202012, valorInterno: 80000.00, valorExterno: 15000.00),
          pgdasd_models.ReceitaBrutaAnterior(pa: 202011, valorInterno: 75000.00, valorExterno: 12000.00),
        ],
        folhasSalario: [pgdasd_models.FolhaSalario(pa: 202012, valor: 5000.00), pgdasd_models.FolhaSalario(pa: 202011, valor: 4800.00)],
        estabelecimentos: [
          pgdasd_models.Estabelecimento(
            cnpjCompleto: '00000000000100',
            atividades: [
              pgdasd_models.Atividade(
                idAtividade: 1,
                valorAtividade: 120000.00,
                receitasAtividade: [
                  pgdasd_models.ReceitaAtividade(
                    valor: 120000.00,
                    qualificacoesTributarias: [
                      pgdasd_models.QualificacaoTributaria(codigoTributo: 1, id: 1),
                      pgdasd_models.QualificacaoTributaria(codigoTributo: 2, id: 2),
                    ],
                    exigibilidadesSuspensas: [
                      pgdasd_models.ExigibilidadeSuspensa(
                        codTributo: 1,
                        numeroProcesso: 123456789,
                        uf: 'SP',
                        vara: '1ª Vara Federal',
                        existeDeposito: true,
                        motivo: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      print('✅ Declaração complexa criada com:');
      print('📅 - Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos');
      print('💰 - Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos');
      print('🏢 - Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}');
      print('💼 - Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}');
      print(
        '🏷️ - Qualificações tributárias: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.qualificacoesTributarias!.length}',
      );
      print(
        '⚖️ - Exigibilidades suspensas: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.exigibilidadesSuspensas!.length}',
      );
    } catch (e) {
      print('❌ Erro ao criar declaração complexa: $e');
    }

    // 9. Exemplo de validação de dados
    try {
      print('\n--- 9. Exemplo de Validação de Dados ---');

      // CNPJ inválido
      try {
        final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
          cnpjCompleto: '123', // CNPJ inválido
          pa: 202101,
          indicadorTransmissao: true,
          indicadorComparacao: false,
          declaracao: pgdasd_models.Declaracao(
            tipoDeclaracao: 1,
            receitaPaCompetenciaInterno: 50000.00,
            receitaPaCompetenciaExterno: 10000.00,
            estabelecimentos: [],
          ),
        );
        print('❌ CNPJ inválido detectado: ${!requestInvalido.isCnpjValido}');
      } catch (e) {
        print('⚠️ Erro esperado na validação: $e');
      }

      // Período inválido
      try {
        final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
          cnpjCompleto: '00000000000100',
          pa: 201701, // Período anterior a 2018
          indicadorTransmissao: true,
          indicadorComparacao: false,
          declaracao: pgdasd_models.Declaracao(
            tipoDeclaracao: 1,
            receitaPaCompetenciaInterno: 50000.00,
            receitaPaCompetenciaExterno: 10000.00,
            estabelecimentos: [],
          ),
        );
        print('❌ Período inválido detectado: ${!requestInvalido.isPaValido}');
      } catch (e) {
        print('⚠️ Erro esperado na validação: $e');
      }
    } catch (e) {
      print('❌ Erro na validação de dados: $e');
    }

    print('\n🎉 Todos os serviços PGDASD executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral no serviço PGDASD: $e');
  }
}

Future<void> exemplosDctfWeb(ApiClient apiClient) async {
  print('=== Exemplos DCTFWeb ===');

  final dctfWebService = DctfWebService(apiClient);

  try {
    // 1. Métodos de conveniência
    try {
      print('\n--- 1. Métodos de conveniência ---');

      // DARF Geral Mensal
      final darfGeralResponse = await dctfWebService.gerarDarfGeralMensal(
        contribuinteNumero: '00000000000000',
        anoPA: '2027',
        mesPA: '11',
        idsSistemaOrigem: [SistemaOrigem.esocial, SistemaOrigem.mit],
      );
      print('✅ DARF Geral Mensal: ${darfGeralResponse.sucesso}');

      // DARF Pessoa Física Mensal
      final darfPfResponse = await dctfWebService.gerarDarfPfMensal(contribuinteNumero: '00000000000', anoPA: '2022', mesPA: '06');
      print('✅ DARF PF Mensal: ${darfPfResponse.sucesso}');

      // DARF 13º Salário
      final darf13Response = await dctfWebService.gerarDarf13Salario(contribuinteNumero: '00000000000000', anoPA: '2022', isPessoaFisica: false);
      print('✅ DARF 13º Salário: ${darf13Response.sucesso}');
    } catch (e) {
      print('❌ Erro nos métodos de conveniência: $e');
    }

    // 2. Exemplo com categoria específica - Espetáculo Desportivo
    try {
      print('\n--- 2. Exemplo Espetáculo Desportivo ---');
      final espetaculoResponse = await dctfWebService.consultarXmlDeclaracao(
        contribuinteNumero: '00000000000000',
        categoria: CategoriaDctf.espetaculoDesportivo,
        anoPA: '2022',
        mesPA: '05',
        diaPA: '14', // Dia obrigatório para espetáculo desportivo
      );
      print('✅ XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo espetáculo desportivo: $e');
    }

    // 3. Exemplo com categoria Aferição
    try {
      print('\n--- 3. Exemplo Aferição ---');
      final afericaoResponse = await dctfWebService.consultarXmlDeclaracao(
        contribuinteNumero: '00000000000000',
        categoria: CategoriaDctf.afericao,
        anoPA: '2022',
        mesPA: '03',
        cnoAfericao: 28151, // CNO obrigatório para aferição
      );
      print('✅ XML Aferição: ${afericaoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo aferição: $e');
    }

    // 4. Exemplo com categoria Reclamatória Trabalhista
    try {
      print('\n--- 4. Exemplo Reclamatória Trabalhista ---');
      final reclamatoriaResponse = await dctfWebService.consultarReciboTransmissao(
        contribuinteNumero: '00000000000000',
        categoria: CategoriaDctf.reclamatoriaTrabalhista,
        anoPA: '2022',
        mesPA: '12',
        numProcReclamatoria: '00365354520004013400', // Processo obrigatório
      );
      print('✅ Recibo Reclamatória: ${reclamatoriaResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo reclamatória trabalhista: $e');
    }

    // 5. Exemplo de transmissão completa (simulada)
    try {
      print('\n--- 5. Exemplo de fluxo completo (simulado) ---');
      print('⚠️ ATENÇÃO: Este exemplo simula a assinatura digital.');
      print('⚠️ Em produção, você deve implementar a assinatura real com certificado digital.');

      final transmissaoResponse = await dctfWebService.consultarXmlETransmitir(
        contribuinteNumero: '00000000000',
        categoria: CategoriaDctf.pfMensal,
        anoPA: '2022',
        mesPA: '06',
        assinadorXml: (xmlBase64) async {
          // SIMULAÇÃO: Em produção, aqui você faria a assinatura digital real
          print('🔐 Simulando assinatura digital do XML...');

          // Esta é apenas uma simulação - NÃO USE EM PRODUÇÃO
          // Você deve implementar a assinatura digital real com seu certificado
          return xmlBase64 + '_ASSINADO_SIMULADO';
        },
      );

      print('✅ Transmissão simulada: ${transmissaoResponse.status}');
      print('📋 Tem MAED: ${transmissaoResponse.temMaed}');

      if (transmissaoResponse.infoTransmissao != null) {
        final info = transmissaoResponse.infoTransmissao!;
        print('📄 Número do recibo: ${info.numeroRecibo}');
        print('📅 Data transmissão: ${info.dataTransmissao}');
      }
    } catch (e) {
      print('⚠️ Erro na transmissão simulada (esperado): $e');
    }

    print('\n🎉 Todos os serviços DCTFWeb executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral no serviço DCTFWeb: $e');
  }
}

Future<void> exemplosProcuracoes(ApiClient apiClient) async {
  print('\n=== Exemplos PROCURAÇÕES (Procurações Eletrônicas) ===');

  final procuracoesService = ProcuracoesService(apiClient);

  try {
    // 1. Exemplo básico - Obter procuração entre duas pessoas físicas
    print('\n--- 1. Obter Procuração PF para PF ---');
    try {
      final responsePf = await procuracoesService.obterProcuracaoPf(
        '99999999999', // CPF do outorgante
        '88888888888', // CPF do procurador
      );

      print('Status: ${responsePf.status}');
      print('Sucesso: ${responsePf.sucesso}');
      print('Mensagem: ${responsePf.mensagemPrincipal}');
      print('Código: ${responsePf.codigoMensagem}');

      if (responsePf.sucesso && responsePf.dadosParsed != null) {
        final procuracoes = responsePf.dadosParsed!;
        print('Total de procurações encontradas: ${procuracoes.length}');

        for (int i = 0; i < procuracoes.length; i++) {
          final proc = procuracoes[i];
          print('\nProcuração ${i + 1}:');
          print('  Data de expiração: ${proc.dataExpiracaoFormatada}');
          print('  Quantidade de sistemas: ${proc.nrsistemas}');
          print('  Sistemas: ${proc.sistemasFormatados}');
          print('  Está expirada: ${proc.isExpirada ? 'Sim' : 'Não'}');
          print('  Expira em breve: ${proc.expiraEmBreve ? 'Sim' : 'Não'}');
        }
      }
    } catch (e) {
      print('Erro ao obter procuração PF: $e');
    }

    // 2. Exemplo - Obter procuração entre duas pessoas jurídicas
    print('\n--- 2. Obter Procuração PJ para PJ ---');
    try {
      final responsePj = await procuracoesService.obterProcuracaoPj(
        '99999999999999', // CNPJ do outorgante
        '88888888888888', // CNPJ do procurador
      );

      print('Status: ${responsePj.status}');
      print('Sucesso: ${responsePj.sucesso}');
      print('Mensagem: ${responsePj.mensagemPrincipal}');

      if (responsePj.sucesso && responsePj.dadosParsed != null) {
        final procuracoes = responsePj.dadosParsed!;
        print('Total de procurações encontradas: ${procuracoes.length}');

        for (final proc in procuracoes) {
          print('  Data de expiração: ${proc.dataExpiracaoFormatada}');
          print('  Sistemas: ${proc.sistemas.join(', ')}');
        }
      }
    } catch (e) {
      print('Erro ao obter procuração PJ: $e');
    }

    // 3. Exemplo - Obter procuração mista (PF para PJ)
    print('\n--- 3. Obter Procuração Mista (PF para PJ) ---');
    try {
      final responseMista = await procuracoesService.obterProcuracaoMista(
        '99999999999', // CPF do outorgante
        '88888888888888', // CNPJ do procurador
        false, // outorgante é PF
        true, // procurador é PJ
      );

      print('Status: ${responseMista.status}');
      print('Sucesso: ${responseMista.sucesso}');
      print('Mensagem: ${responseMista.mensagemPrincipal}');
    } catch (e) {
      print('Erro ao obter procuração mista: $e');
    }

    // 4. Exemplo - Obter procuração com tipos específicos
    print('\n--- 4. Obter Procuração com Tipos Específicos ---');
    try {
      final responseTipos = await procuracoesService.obterProcuracaoComTipos(
        '99999999999', // CPF do outorgante
        '1', // Tipo 1 = CPF
        '88888888888888', // CNPJ do procurador
        '2', // Tipo 2 = CNPJ
      );

      print('Status: ${responseTipos.status}');
      print('Sucesso: ${responseTipos.sucesso}');
      print('Mensagem: ${responseTipos.mensagemPrincipal}');
    } catch (e) {
      print('Erro ao obter procuração com tipos: $e');
    }

    // 5. Exemplo - Obter procuração automática (detecta tipos)
    print('\n--- 5. Obter Procuração Automática (Detecta Tipos) ---');
    try {
      final responseAuto = await procuracoesService.obterProcuracao(
        '99999999999', // CPF do outorgante (detecta automaticamente)
        '88888888888888', // CNPJ do procurador (detecta automaticamente)
      );

      print('Status: ${responseAuto.status}');
      print('Sucesso: ${responseAuto.sucesso}');
      print('Mensagem: ${responseAuto.mensagemPrincipal}');
    } catch (e) {
      print('Erro ao obter procuração automática: $e');
    }

    // 6. Exemplo - Validação de documentos
    print('\n--- 6. Validação de Documentos ---');

    // Validar CPF
    final cpfValido = '12345678901';
    final cpfInvalido = '123';
    print('CPF $cpfValido é válido: ${procuracoesService.isCpfValido(cpfValido)}');
    print('CPF $cpfInvalido é válido: ${procuracoesService.isCpfValido(cpfInvalido)}');

    // Validar CNPJ
    final cnpjValido = '12345678000195';
    final cnpjInvalido = '123';
    print('CNPJ $cnpjValido é válido: ${procuracoesService.isCnpjValido(cnpjValido)}');
    print('CNPJ $cnpjInvalido é válido: ${procuracoesService.isCnpjValido(cnpjInvalido)}');

    // Detectar tipo de documento
    print('Tipo do documento $cpfValido: ${procuracoesService.detectarTipoDocumento(cpfValido)} (1=CPF, 2=CNPJ)');
    print('Tipo do documento $cnpjValido: ${procuracoesService.detectarTipoDocumento(cnpjValido)} (1=CPF, 2=CNPJ)');

    // 7. Exemplo - Formatação de documentos
    print('\n--- 7. Formatação de Documentos ---');

    final cpfSemFormatacao = '12345678901';
    final cnpjSemFormatacao = '12345678000195';

    print('CPF sem formatação: $cpfSemFormatacao');
    print('CPF formatado: ${procuracoesService.formatarCpf(cpfSemFormatacao)}');

    print('CNPJ sem formatação: $cnpjSemFormatacao');
    print('CNPJ formatado: ${procuracoesService.formatarCnpj(cnpjSemFormatacao)}');

    // 8. Exemplo - Limpeza de documentos
    print('\n--- 8. Limpeza de Documentos ---');

    final cpfComPontuacao = '123.456.789-01';
    final cnpjComPontuacao = '12.345.678/0001-95';

    print('CPF com pontuação: $cpfComPontuacao');
    print('CPF limpo: ${procuracoesService.limparDocumento(cpfComPontuacao)}');

    print('CNPJ com pontuação: $cnpjComPontuacao');
    print('CNPJ limpo: ${procuracoesService.limparDocumento(cnpjComPontuacao)}');

    // 9. Exemplo - Tratamento de erros
    print('\n--- 9. Tratamento de Erros ---');

    try {
      // Tentar com dados inválidos
      await procuracoesService.obterProcuracaoPf('123', '456'); // CPFs inválidos
    } catch (e) {
      print('Erro capturado (esperado): $e');
    }

    // 10. Exemplo - Análise de procurações
    print('\n--- 10. Análise de Procurações ---');
    try {
      final responseAnalise = await procuracoesService.obterProcuracaoPf('99999999999', '88888888888');

      if (responseAnalise.sucesso && responseAnalise.dadosParsed != null) {
        final procuracoes = responseAnalise.dadosParsed!;

        print('Análise das procurações:');
        print('  Total encontradas: ${procuracoes.length}');

        int expiradas = 0;
        int expiramEmBreve = 0;
        int ativas = 0;

        for (final proc in procuracoes) {
          if (proc.isExpirada) {
            expiradas++;
          } else if (proc.expiraEmBreve) {
            expiramEmBreve++;
          } else {
            ativas++;
          }
        }

        print('  Procurações ativas: $ativas');
        print('  Procurações que expiram em breve: $expiramEmBreve');
        print('  Procurações expiradas: $expiradas');

        // Mostrar sistemas únicos
        final sistemasUnicos = <String>{};
        for (final proc in procuracoes) {
          sistemasUnicos.addAll(proc.sistemas);
        }
        print('  Sistemas únicos encontrados: ${sistemasUnicos.length}');
        for (final sistema in sistemasUnicos) {
          print('    - $sistema');
        }
      }
    } catch (e) {
      print('Erro na análise: $e');
    }

    // 12. Exemplo - Diferentes cenários de uso
    print('\n--- 12. Cenários de Uso ---');

    // Cenário 1: Contador consultando procurações de seu cliente
    print('Cenário 1: Contador consultando procurações de cliente');
    try {
      final responseContador = await procuracoesService.obterProcuracaoPf(
        '99999999999', // CPF do cliente
        '88888888888', // CPF do contador
        contratanteNumero: '77777777777777', // CNPJ da empresa contratante
        autorPedidoDadosNumero: '88888888888', // CPF do contador como autor
      );
      print('  Status: ${responseContador.status}');
      print('  Sucesso: ${responseContador.sucesso}');
    } catch (e) {
      print('  Erro: $e');
    }

    // Cenário 2: Empresa consultando procurações de seus procuradores
    print('Cenário 2: Empresa consultando procurações de procuradores');
    try {
      final responseEmpresa = await procuracoesService.obterProcuracaoPj(
        '99999999999999', // CNPJ da empresa
        '88888888888888', // CNPJ do procurador
      );
      print('  Status: ${responseEmpresa.status}');
      print('  Sucesso: ${responseEmpresa.sucesso}');
    } catch (e) {
      print('  Erro: $e');
    }

    // Cenário 3: Pessoa física consultando suas procurações
    print('Cenário 3: Pessoa física consultando suas procurações');
    try {
      final responsePfConsulta = await procuracoesService.obterProcuracaoPf(
        '99999999999', // CPF da pessoa
        '99999999999', // Mesmo CPF (consulta própria)
      );
      print('  Status: ${responsePfConsulta.status}');
      print('  Sucesso: ${responsePfConsulta.sucesso}');
    } catch (e) {
      print('  Erro: $e');
    }

    print('\n=== Exemplos PROCURAÇÕES Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço de Procurações: $e');
  }
}

Future<void> exemplosDte(ApiClient apiClient) async {
  print('\n=== Exemplos DTE (Domicílio Tributário Eletrônico) ===');

  final dteService = DteService(apiClient);

  try {
    // 1. Exemplo básico - Consultar indicador DTE com CNPJ válido
    print('\n--- 1. Consultar Indicador DTE (CNPJ Válido) ---');
    try {
      final response = await dteService.obterIndicadorDte('11111111111111');

      print('Status HTTP: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');
      print('Código: ${response.codigoMensagem}');

      if (response.sucesso && response.dadosParsed != null) {
        final dados = response.dadosParsed!;
        print('Indicador de enquadramento: ${dados.indicadorEnquadramento}');
        print('Status de enquadramento: ${dados.statusEnquadramento}');
        print('Descrição do indicador: ${dados.indicadorDescricao}');
        print('É válido: ${dados.isIndicadorValido}');

        // Análise do enquadramento
        print('\nAnálise do enquadramento:');
        print('  - É optante DTE: ${response.isOptanteDte}');
        print('  - É optante Simples: ${response.isOptanteSimples}');
        print('  - É optante DTE e Simples: ${response.isOptanteDteESimples}');
        print('  - Não é optante: ${response.isNaoOptante}');
        print('  - NI inválido: ${response.isNiInvalido}');
      }
    } catch (e) {
      print('Erro ao consultar DTE: $e');
    }

    // 2. Exemplo com CNPJ da documentação (99999999999999)
    print('\n--- 2. Consultar Indicador DTE (CNPJ da Documentação) ---');
    try {
      final response = await dteService.obterIndicadorDte('99999999999999');

      print('Status HTTP: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');

      if (response.sucesso && response.dadosParsed != null) {
        final dados = response.dadosParsed!;
        print('Indicador: ${dados.indicadorEnquadramento}');
        print('Status: ${dados.statusEnquadramento}');
        print('Descrição: ${dados.indicadorDescricao}');
      }
    } catch (e) {
      print('Erro ao consultar DTE: $e');
    }

    // 3. Exemplo com CNPJ formatado
    print('\n--- 3. Consultar Indicador DTE (CNPJ Formatado) ---');
    try {
      final cnpjFormatado = '12.345.678/0001-95';
      print('CNPJ formatado: $cnpjFormatado');
      print('CNPJ limpo: ${dteService.limparCnpj(cnpjFormatado)}');

      final response = await dteService.obterIndicadorDte(cnpjFormatado);

      print('Status HTTP: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');
    } catch (e) {
      print('Erro ao consultar DTE: $e');
    }

    // 4. Validação de CNPJ
    print('\n--- 4. Validação de CNPJ ---');

    final cnpjsParaTestar = [
      '11111111111111', // Válido
      '12.345.678/0001-95', // Válido formatado
      '12345678000195', // Válido sem formatação
      '123', // Inválido - muito curto
      '123456789012345', // Inválido - muito longo
      '11111111111112', // Inválido - dígito verificador
      '', // Inválido - vazio
    ];

    for (final cnpj in cnpjsParaTestar) {
      final isValid = dteService.validarCnpjDte(cnpj);
      print('CNPJ "$cnpj" é válido: $isValid');

      if (isValid) {
        print('  Formatado: ${dteService.formatarCnpj(cnpj)}');
      }
    }

    // 5. Tratamento de erros específicos
    print('\n--- 5. Tratamento de Erros Específicos ---');

    final codigosErro = ['Erro-DTE-04', 'Erro-DTE-05', 'Erro-DTE-991', 'Erro-DTE-992', 'Erro-DTE-993', 'Erro-DTE-994', 'Erro-DTE-995'];

    for (final codigo in codigosErro) {
      final isKnown = dteService.isErroConhecido(codigo);
      print('Erro conhecido ($codigo): $isKnown');

      if (isKnown) {
        final info = dteService.obterInfoErro(codigo);
        if (info != null) {
          print('  Tipo: ${info['tipo']}');
          print('  Descrição: ${info['descricao']}');
          print('  Ação: ${info['acao']}');
        }
      }
    }

    // 6. Análise de resposta completa
    print('\n--- 6. Análise de Resposta Completa ---');
    try {
      final response = await dteService.obterIndicadorDte('00000000000000');

      final analise = dteService.analisarResposta(response);
      print('Análise da resposta:');
      for (final entry in analise.entries) {
        print('  ${entry.key}: ${entry.value}');
      }
    } catch (e) {
      print('Erro na análise: $e');
    }

    // 7. Exemplo com diferentes cenários de enquadramento
    print('\n--- 7. Cenários de Enquadramento ---');

    final cenarios = [
      {'cnpj': '11111111111111', 'descricao': 'CNPJ de teste 1'},
      {'cnpj': '22222222222222', 'descricao': 'CNPJ de teste 2'},
      {'cnpj': '33333333333333', 'descricao': 'CNPJ de teste 3'},
    ];

    for (final cenario in cenarios) {
      try {
        print('\nTestando ${cenario['descricao']}:');
        final response = await dteService.obterIndicadorDte(cenario['cnpj']!);

        if (response.sucesso && response.dadosParsed != null) {
          final dados = response.dadosParsed!;
          print('  Indicador: ${dados.indicadorEnquadramento}');
          print('  Status: ${dados.statusEnquadramento}');
          print('  Descrição: ${dados.indicadorDescricao}');

          // Interpretação do resultado
          if (dados.indicadorEnquadramento == 0) {
            print('  → Este contribuinte é OPTANTE DTE');
          } else if (dados.indicadorEnquadramento == 1) {
            print('  → Este contribuinte é OPTANTE SIMPLES NACIONAL');
          } else if (dados.indicadorEnquadramento == 2) {
            print('  → Este contribuinte é OPTANTE DTE E SIMPLES NACIONAL');
          } else if (dados.indicadorEnquadramento == -1) {
            print('  → Este contribuinte NÃO É OPTANTE');
          } else if (dados.indicadorEnquadramento == -2) {
            print('  → Este NI (Número de Identificação) é INVÁLIDO');
          }
        } else {
          print('  Erro: ${response.mensagemPrincipal}');
        }
      } catch (e) {
        print('  Erro: $e');
      }
    }

    // 8. Exemplo de uso prático - Verificação de elegibilidade
    print('\n--- 8. Verificação de Elegibilidade para DTE ---');
    try {
      final cnpjEmpresa = '11111111111111';
      print('Verificando elegibilidade da empresa $cnpjEmpresa para DTE...');

      final response = await dteService.obterIndicadorDte(cnpjEmpresa);

      if (response.sucesso && response.dadosParsed != null) {
        final dados = response.dadosParsed!;

        print('\nResultado da verificação:');
        print('Status: ${dados.statusEnquadramento}');

        if (dados.indicadorEnquadramento == 0 || dados.indicadorEnquadramento == 2) {
          print('✓ Esta empresa PODE utilizar o DTE');
          print('✓ Sua Caixa Postal no e-CAC será considerada Domicílio Tributário');
        } else if (dados.indicadorEnquadramento == 1) {
          print('⚠ Esta empresa é optante do Simples Nacional');
          print('⚠ Verifique se pode utilizar o DTE conforme legislação');
        } else if (dados.indicadorEnquadramento == -1) {
          print('✗ Esta empresa NÃO é optante');
          print('✗ Não pode utilizar o DTE');
        } else if (dados.indicadorEnquadramento == -2) {
          print('✗ CNPJ inválido');
          print('✗ Verifique o número do CNPJ');
        }
      } else {
        print('✗ Erro na verificação: ${response.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na verificação de elegibilidade: $e');
    }

    // 9. Exemplo com dados da documentação oficial
    print('\n--- 9. Exemplo com Dados da Documentação Oficial ---');

    // Dados do exemplo da documentação
    final exemploDocumentacao = {'contratante': '11111111111111', 'autorPedidoDados': '11111111111111', 'contribuinte': '99999999999999'};

    print('Dados do exemplo da documentação:');
    print('Contratante: ${exemploDocumentacao['contratante']}');
    print('Autor do Pedido: ${exemploDocumentacao['autorPedidoDados']}');
    print('Contribuinte: ${exemploDocumentacao['contribuinte']}');

    try {
      final response = await dteService.obterIndicadorDte(exemploDocumentacao['contribuinte']!);

      print('\nResposta do exemplo da documentação:');
      print('Status HTTP: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');

      if (response.sucesso && response.dadosParsed != null) {
        final dados = response.dadosParsed!;
        print('Indicador: ${dados.indicadorEnquadramento}');
        print('Status: ${dados.statusEnquadramento}');

        // Simular o JSON de retorno da documentação
        print('\nJSON de retorno (formato da documentação):');
        print('{');
        print('  "contratante": {');
        print('    "numero": "${exemploDocumentacao['contratante']}",');
        print('    "tipo": 2');
        print('  },');
        print('  "autorPedidoDados": {');
        print('    "numero": "${exemploDocumentacao['autorPedidoDados']}",');
        print('    "tipo": 2');
        print('  },');
        print('  "contribuinte": {');
        print('    "numero": "${exemploDocumentacao['contribuinte']}",');
        print('    "tipo": 2');
        print('  },');
        print('  "pedidoDados": {');
        print('    "idSistema": "DTE",');
        print('    "idServico": "CONSULTASITUACAODTE111",');
        print('    "versaoSistema": "1.0",');
        print('    "dados": ""');
        print('  },');
        print('  "status": ${response.status},');
        print('  "dados": "${response.dados}",');
        print('  "mensagens": [');
        for (final mensagem in response.mensagens) {
          print('    {');
          print('      "codigo": "${mensagem.codigo}",');
          print('      "texto": "${mensagem.texto}"');
          print('    }');
        }
        print('  ]');
        print('}');
      }
    } catch (e) {
      print('Erro no exemplo da documentação: $e');
    }

    // 10. Resumo dos indicadores de enquadramento
    print('\n--- 10. Resumo dos Indicadores de Enquadramento ---');
    print('Conforme documentação DTE:');
    print('  -2: NI inválido');
    print('  -1: NI Não optante');
    print('   0: NI Optante DTE');
    print('   1: NI Optante Simples');
    print('   2: NI Optante DTE e Simples');

    // Testar todos os indicadores possíveis
    for (int indicador = -2; indicador <= 2; indicador++) {
      final descricao = dteService.obterDescricaoIndicador(indicador);
      final isValid = dteService.isIndicadorValido(indicador);
      print('Indicador $indicador: $descricao (válido: $isValid)');
    }

    print('\n=== Exemplos DTE Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço DTE: $e');
  }
}

Future<void> exemplosSitfis(ApiClient apiClient) async {
  print('=== Exemplos SITFIS ===');

  final sitfisService = SitfisService(apiClient);

  try {
    print('\n--- 1. Solicitar Protocolo do Relatório ---');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio('99999999999');
    print('Status: ${protocoloResponse.status}');
    print('Mensagens: ${protocoloResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (protocoloResponse.isSuccess) {
      print('Sucesso: ${protocoloResponse.isSuccess}');
      print('Tem protocolo: ${protocoloResponse.hasProtocolo}');
      print('Tem tempo de espera: ${protocoloResponse.hasTempoEspera}');

      if (protocoloResponse.hasProtocolo) {
        print('Protocolo: ${protocoloResponse.dados!.protocoloRelatorio!.substring(0, 20)}...');
      }

      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Tempo de espera: ${tempoEspera}ms (${protocoloResponse.dados!.tempoEsperaEmSegundos}s)');
      }
    }

    print('\n--- 2. Emitir Relatório (se protocolo disponível) ---');
    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;

      // Se há tempo de espera, aguarda antes de emitir
      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Aguardando ${tempoEspera}ms antes de emitir...');
        await Future.delayed(Duration(milliseconds: tempoEspera));
      }

      final emitirResponse = await sitfisService.emitirRelatorioSituacaoFiscal('99999999999', protocolo);
      print('Status: ${emitirResponse.status}');
      print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('Sucesso: ${emitirResponse.isSuccess}');
      print('Em processamento: ${emitirResponse.isProcessing}');
      print('Tem PDF: ${emitirResponse.hasPdf}');
      print('Tem tempo de espera: ${emitirResponse.hasTempoEspera}');

      if (emitirResponse.hasPdf) {
        final infoPdf = sitfisService.obterInformacoesPdf(emitirResponse);
        print('Informações do PDF:');
        print('  - Disponível: ${infoPdf['disponivel']}');
        print('  - Tamanho: ${infoPdf['tamanhoKB']} KB (${infoPdf['tamanhoMB']} MB)');
        print('  - Tamanho Base64: ${infoPdf['tamanhoBase64']} caracteres');

        // Salvar PDF em arquivo (opcional)
        final sucessoSalvamento = await sitfisService.salvarPdfEmArquivo(
          emitirResponse,
          'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      if (emitirResponse.hasTempoEspera) {
        final tempoEspera = emitirResponse.dados!.tempoEspera!;
        print('Novo tempo de espera: ${tempoEspera}ms (${emitirResponse.dados!.tempoEsperaEmSegundos}s)');
      }
    }

    print('\n--- 3. Fluxo Completo com Retry Automático ---');
    try {
      final relatorioCompleto = await sitfisService.obterRelatorioCompleto(
        '99999999999',
        maxTentativas: 3,
        callbackProgresso: (etapa, tempoEspera) {
          print('Progresso: $etapa');
          if (tempoEspera != null) {
            print('  Tempo de espera: ${tempoEspera}ms');
          }
        },
      );

      print('Relatório completo obtido!');
      print('Status final: ${relatorioCompleto.status}');
      print('PDF disponível: ${relatorioCompleto.hasPdf}');

      if (relatorioCompleto.hasPdf) {
        final infoPdf = sitfisService.obterInformacoesPdf(relatorioCompleto);
        print('Tamanho do PDF: ${infoPdf['tamanhoKB']} KB');
      }
    } catch (e) {
      print('Erro no fluxo completo: $e');
    }

    print('\n--- 4. Exemplo com Cache (simulado) ---');
    // Simular cache válido
    final cacheSimulado = SitfisCache(
      protocoloRelatorio: 'protocolo_cache_exemplo',
      dataExpiracao: DateTime.now().add(Duration(hours: 1)),
      etag: '"protocoloRelatorio:protocolo_cache_exemplo"',
      cacheControl: 'integra_sitfis_solicitar_relatorio',
    );

    print('Cache válido: ${cacheSimulado.isValid}');
    print('Tempo restante: ${cacheSimulado.tempoRestanteEmSegundos}s');

    final protocoloComCache = await sitfisService.solicitarProtocoloComCache('99999999999', cache: cacheSimulado);

    if (protocoloComCache == null) {
      print('Usando cache existente - não fez nova solicitação');
    } else {
      print('Nova solicitação feita - cache inválido');
    }

    print('\n--- 5. Exemplo com Emissão com Retry ---');
    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;

      final relatorioComRetry = await sitfisService.emitirRelatorioComRetry(
        '99999999999',
        protocolo,
        maxTentativas: 2,
        callbackProgresso: (tentativa, tempoEspera) {
          print('Tentativa $tentativa - Aguardando ${tempoEspera}ms...');
        },
      );

      print('Relatório com retry obtido!');
      print('Status: ${relatorioComRetry.status}');
      print('PDF disponível: ${relatorioComRetry.hasPdf}');
    }
  } catch (e) {
    print('Erro no serviço SITFIS: $e');
  }
}

Future<void> exemplosDefis(ApiClient apiClient) async {
  print('=== Exemplos DEFIS ===');

  final defisService = DefisService(apiClient);

  try {
    print('\n--- 1. Transmitir Declaração Sócio Econômica ---');

    // Criar uma declaração de exemplo usando os enums
    final declaracao = defis.TransmitirDeclaracaoRequest(
      ano: 2023,
      situacaoEspecial: defis.SituacaoEspecial(tipoEvento: defis.TipoEventoSituacaoEspecial.cisaoParcial, dataEvento: 20230101),
      inatividade: defis.RegraInatividade.atividadesMaiorZero,
      empresa: defis.Empresa(
        ganhoCapital: 0,
        qtdEmpregadoInicial: 1,
        qtdEmpregadoFinal: 1,
        receitaExportacaoDireta: 0,
        socios: [
          defis.Socio(cpf: '00000000000', rendimentosIsentos: 10000, rendimentosTributaveis: 5000, participacaoCapitalSocial: 100, irRetidoFonte: 0),
        ],
        ganhoRendaVariavel: 0,
        doacoesCampanhaEleitoral: [
          defis.Doacao(
            cnpjBeneficiario: '00000000000000',
            tipoBeneficiario: defis.TipoBeneficiarioDoacao.candidatoCargoPolitico,
            formaDoacao: defis.FormaDoacao.dinheiro,
            valor: 1000.00,
          ),
        ],
        estabelecimentos: [
          defis.Estabelecimento(
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
            operacoesInterestaduais: [defis.OperacaoInterestadual(uf: 'SP', valor: 5000.00, tipoOperacao: defis.TipoOperacao.entrada)],
          ),
        ],
        naoOptante: defis.NaoOptante(
          administracaoTributaria: defis.AdministracaoTributaria.federal,
          uf: 'SP',
          codigoMunicipio: '3550308',
          numeroProcesso: '12345678901234567890',
        ),
      ),
    );

    final transmitirResponse = await defisService.transmitirDeclaracao(contribuinteNumero: '00000000000000', declaracaoData: declaracao);

    print('Status: ${transmitirResponse.status}');
    print('Mensagens: ${transmitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('ID DEFIS: ${transmitirResponse.dados.idDefis}');
    print('Declaração PDF: ${transmitirResponse.dados.declaracaoPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
    print('Recibo PDF: ${transmitirResponse.dados.reciboPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');

    print('\n--- 2. Consultar Declarações Transmitidas ---');
    final consultarDeclaracoesResponse = await defisService.consultarDeclaracoesTransmitidas(contribuinteNumero: '00000000000000');

    print('Status: ${consultarDeclaracoesResponse.status}');
    print('Mensagens: ${consultarDeclaracoesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Quantidade de declarações: ${consultarDeclaracoesResponse.dados.length}');

    for (var declaracao in consultarDeclaracoesResponse.dados) {
      print('  - ID: ${declaracao.idDefis}, Ano: ${declaracao.ano}, Data: ${declaracao.dataTransmissao}, Situação: ${declaracao.situacao}');
    }

    print('\n--- 3. Consultar Última Declaração Transmitida ---');
    final consultarUltimaResponse = await defisService.consultarUltimaDeclaracao(contribuinteNumero: '00000000000000', ano: 2023);

    print('Status: ${consultarUltimaResponse.status}');
    print('Mensagens: ${consultarUltimaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('ID DEFIS: ${consultarUltimaResponse.dados.idDefis}');
    print('Ano: ${consultarUltimaResponse.dados.ano}');
    print('Data Transmissão: ${consultarUltimaResponse.dados.dataTransmissao}');
    print('Situação: ${consultarUltimaResponse.dados.situacao}');
    print('Declaração PDF: ${consultarUltimaResponse.dados.declaracaoPdf != null ? 'Disponível' : 'Não disponível'}');
    print('Recibo PDF: ${consultarUltimaResponse.dados.reciboPdf != null ? 'Disponível' : 'Não disponível'}');

    print('\n--- 4. Consultar Declaração Específica ---');
    final consultarEspecificaResponse = await defisService.consultarDeclaracaoEspecifica(
      contribuinteNumero: '00000000000000',
      idDefis: 12345, // Usar um ID real se disponível
    );

    print('Status: ${consultarEspecificaResponse.status}');
    print('Mensagens: ${consultarEspecificaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('ID DEFIS: ${consultarEspecificaResponse.dados.idDefis}');
    print('Ano: ${consultarEspecificaResponse.dados.ano}');
    print('Data Transmissão: ${consultarEspecificaResponse.dados.dataTransmissao}');
    print('Situação: ${consultarEspecificaResponse.dados.situacao}');

    print('\n--- 5. Exemplo com Procurador ---');
    // Exemplo usando token de procurador (se disponível)
    if (apiClient.hasProcuradorToken) {
      final procuradorResponse = await defisService.consultarDeclaracoesTransmitidas(
        contribuinteNumero: '00000000000000',
        procuradorToken: apiClient.procuradorToken,
      );

      print('Status com procurador: ${procuradorResponse.status}');
      print('Quantidade de declarações: ${procuradorResponse.dados.length}');
    } else {
      print('Token de procurador não disponível');
    }

    print('\n--- 6. Exemplo de Validação de Enums ---');
    print('Tipos de evento disponíveis:');
    for (var tipo in defis.TipoEventoSituacaoEspecial.values) {
      print('  ${tipo.codigo}: ${tipo.descricao}');
    }

    print('Regras de inatividade disponíveis:');
    for (var regra in defis.RegraInatividade.values) {
      print('  ${regra.codigo}: ${regra.descricao}');
    }

    print('Tipos de beneficiário de doação:');
    for (var tipo in defis.TipoBeneficiarioDoacao.values) {
      print('  ${tipo.codigo}: ${tipo.descricao}');
    }

    print('Formas de doação:');
    for (var forma in defis.FormaDoacao.values) {
      print('  ${forma.codigo}: ${forma.descricao}');
    }

    print('Administrações tributárias:');
    for (var admin in defis.AdministracaoTributaria.values) {
      print('  ${admin.codigo}: ${admin.descricao}');
    }
  } catch (e) {
    print('Erro no serviço DEFIS: $e');
  }
}

Future<void> exemplosPagtoWeb(ApiClient apiClient) async {
  print('=== Exemplos PAGTOWEB ===');

  final pagtoWebService = PagtoWebService(apiClient);

  try {
    // 1. Consultar pagamentos por intervalo de data
    print('\n--- Consultando pagamentos por data ---');
    final consultarDataResponse = await pagtoWebService.consultarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDataResponse.status}');
    print('Sucesso: ${consultarDataResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDataResponse.dados.length}');

    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Primeiro pagamento:');
      print('  Número: ${pagamento.numeroDocumento}');
      print('  Tipo: ${pagamento.tipo.descricao}');
      print('  Período: ${pagamento.periodoApuracao}');
      print('  Data Arrecadação: ${pagamento.dataArrecadacao}');
      print('  Valor Total: R\$ ${pagamento.valorTotal}');
      print('  Receita: ${pagamento.receitaPrincipal.descricao}');
    }

    // 2. Consultar pagamentos por códigos de receita
    print('\n--- Consultando pagamentos por receita ---');
    final consultarReceitaResponse = await pagtoWebService.consultarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarReceitaResponse.status}');
    print('Sucesso: ${consultarReceitaResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarReceitaResponse.dados.length}');

    // 3. Consultar pagamentos por intervalo de valor
    print('\n--- Consultando pagamentos por valor ---');
    final consultarValorResponse = await pagtoWebService.consultarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarValorResponse.status}');
    print('Sucesso: ${consultarValorResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarValorResponse.dados.length}');

    // 4. Consultar pagamentos por números de documento
    print('\n--- Consultando pagamentos por documento ---');
    final consultarDocumentoResponse = await pagtoWebService.consultarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDocumentoResponse.status}');
    print('Sucesso: ${consultarDocumentoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDocumentoResponse.dados.length}');

    // 5. Contar pagamentos por data
    print('\n--- Contando pagamentos por data ---');
    final contarDataResponse = await pagtoWebService.contarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
    );

    print('Status: ${contarDataResponse.status}');
    print('Sucesso: ${contarDataResponse.sucesso}');
    print('Quantidade total: ${contarDataResponse.quantidade}');

    // 6. Contar pagamentos por receita
    print('\n--- Contando pagamentos por receita ---');
    final contarReceitaResponse = await pagtoWebService.contarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
    );

    print('Status: ${contarReceitaResponse.status}');
    print('Sucesso: ${contarReceitaResponse.sucesso}');
    print('Quantidade total: ${contarReceitaResponse.quantidade}');

    // 7. Contar pagamentos por valor
    print('\n--- Contando pagamentos por valor ---');
    final contarValorResponse = await pagtoWebService.contarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
    );

    print('Status: ${contarValorResponse.status}');
    print('Sucesso: ${contarValorResponse.sucesso}');
    print('Quantidade total: ${contarValorResponse.quantidade}');

    // 8. Contar pagamentos por documento
    print('\n--- Contando pagamentos por documento ---');
    final contarDocumentoResponse = await pagtoWebService.contarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
    );

    print('Status: ${contarDocumentoResponse.status}');
    print('Sucesso: ${contarDocumentoResponse.sucesso}');
    print('Quantidade total: ${contarDocumentoResponse.quantidade}');

    // 9. Emitir comprovante de pagamento
    print('\n--- Emitindo comprovante de pagamento ---');
    final emitirComprovanteResponse = await pagtoWebService.emitirComprovante(
      contribuinteNumero: '00000000000100',
      numeroDocumento: '12345678901234567890',
    );

    print('Status: ${emitirComprovanteResponse.status}');
    print('Sucesso: ${emitirComprovanteResponse.sucesso}');
    print('PDF disponível: ${emitirComprovanteResponse.pdfBase64 != null}');

    if (emitirComprovanteResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${emitirComprovanteResponse.pdfBase64!.length} caracteres');
    }

    // 10. Exemplo com filtros combinados
    print('\n--- Exemplo com filtros combinados ---');
    final consultarCombinadoResponse = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-06-01',
      dataFinal: '2023-06-30',
      codigoReceitaLista: ['0001'],
      valorInicial: 500.00,
      valorFinal: 2000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 20,
    );

    print('Status: ${consultarCombinadoResponse.status}');
    print('Sucesso: ${consultarCombinadoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarCombinadoResponse.dados.length}');

    // 11. Exemplo de paginação
    print('\n--- Exemplo de paginação ---');
    final pagina1Response = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Página 1 - Status: ${pagina1Response.status}');
    print('Página 1 - Quantidade: ${pagina1Response.dados.length}');

    if (pagina1Response.dados.length == 5) {
      // Simular próxima página
      final pagina2Response = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000100',
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
        primeiroDaPagina: 5,
        tamanhoDaPagina: 5,
      );

      print('Página 2 - Status: ${pagina2Response.status}');
      print('Página 2 - Quantidade: ${pagina2Response.dados.length}');
    }

    // 12. Exemplo de tratamento de erros
    print('\n--- Exemplo de tratamento de erros ---');
    try {
      final erroResponse = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000000', // CNPJ inválido
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
      );

      print('Status: ${erroResponse.status}');
      print('Sucesso: ${erroResponse.sucesso}');

      if (!erroResponse.sucesso) {
        print('Mensagens de erro:');
        for (final mensagem in erroResponse.mensagens) {
          print('  ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
    } catch (e) {
      print('Erro capturado: $e');
    }

    // 13. Exemplo de análise de desmembramentos
    print('\n--- Exemplo de análise de desmembramentos ---');
    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Análise do pagamento ${pagamento.numeroDocumento}:');
      print('  Desmembramentos: ${pagamento.desmembramentos.length}');

      for (int i = 0; i < pagamento.desmembramentos.length; i++) {
        final desmembramento = pagamento.desmembramentos[i];
        print('  Desmembramento ${i + 1}:');
        print('    Sequencial: ${desmembramento.sequencial}');
        print('    Receita: ${desmembramento.receitaPrincipal.descricao}');
        print('    Período: ${desmembramento.periodoApuracao}');
        print('    Valor Total: R\$ ${desmembramento.valorTotal ?? 0.0}');
        print('    Valor Principal: R\$ ${desmembramento.valorPrincipal ?? 0.0}');
        print('    Valor Multa: R\$ ${desmembramento.valorMulta ?? 0.0}');
        print('    Valor Juros: R\$ ${desmembramento.valorJuros ?? 0.0}');
      }
    }

    print('\n=== Exemplos PAGTOWEB Concluídos ===');
  } catch (e) {
    print('Erro no serviço PAGTOWEB: $e');
  }
}

Future<void> exemplosAutenticaProcurador(ApiClient apiClient) async {
  print('=== Exemplos Autenticação de Procurador ===');

  final autenticaProcuradorService = AutenticaProcuradorService(apiClient);

  try {
    // Dados de exemplo para demonstração
    const contratanteNumero = '00000000000100'; // CNPJ da empresa contratante
    const contratanteNome = 'EMPRESA EXEMPLO LTDA';
    const autorPedidoDadosNumero = '00000000000'; // CPF do procurador/contador
    const autorPedidoDadosNome = 'JOÃO DA SILVA CONTADOR';

    // 1. Criar termo de autorização
    print('\n--- 1. Criando Termo de Autorização ---');
    final termo = await autenticaProcuradorService.criarTermoComDataAtual(
      contratanteNumero: contratanteNumero,
      contratanteNome: contratanteNome,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      autorPedidoDadosNome: autorPedidoDadosNome,
    );

    print('Termo criado com sucesso');
    print('Data de assinatura: ${termo.dataAssinatura}');
    print('Data de vigência: ${termo.dataVigencia}');

    // 2. Validar dados do termo
    print('\n--- 2. Validando Dados do Termo ---');
    final erros = termo.validarDados();
    if (erros.isEmpty) {
      print('✓ Dados do termo são válidos');
    } else {
      print('✗ Erros encontrados:');
      for (final erro in erros) {
        print('  - $erro');
      }
    }

    // 3. Criar XML do termo
    print('\n--- 3. Criando XML do Termo ---');
    final xml = termo.criarXmlTermo();
    print('XML criado com ${xml.length} caracteres');

    // 4. Validar estrutura do XML
    print('\n--- 4. Validando Estrutura do XML ---');
    final errosXml = await autenticaProcuradorService.validarTermoAutorizacao(xml);
    if (errosXml.isEmpty) {
      print('✓ Estrutura do XML é válida');
    } else {
      print('✗ Erros na estrutura do XML:');
      for (final erro in errosXml) {
        print('  - $erro');
      }
    }

    // 5. Assinar termo digitalmente (simulado)
    print('\n--- 5. Assinando Termo Digitalmente (Simulado) ---');
    final xmlAssinado = await autenticaProcuradorService.assinarTermoDigital(termo);
    print('Termo assinado com sucesso');
    print('XML assinado tem ${xmlAssinado.length} caracteres');

    // 6. Validar assinatura digital
    print('\n--- 6. Validando Assinatura Digital ---');
    final relatorioAssinatura = await autenticaProcuradorService.validarAssinaturaDigital(xmlAssinado);
    print('Relatório de validação:');
    print('  - Tem assinatura: ${relatorioAssinatura['tem_assinatura']}');
    print('  - Tem signed info: ${relatorioAssinatura['tem_signed_info']}');
    print('  - Tem signature value: ${relatorioAssinatura['tem_signature_value']}');
    print('  - Tem X509 certificate: ${relatorioAssinatura['tem_x509_certificate']}');
    print('  - Algoritmo assinatura correto: ${relatorioAssinatura['algoritmo_assinatura_correto']}');
    print('  - Algoritmo hash correto: ${relatorioAssinatura['algoritmo_hash_correto']}');
    print('  - Assinatura válida: ${relatorioAssinatura['assinatura_valida']}');

    // 7. Autenticar procurador
    print('\n--- 7. Autenticando Procurador ---');
    try {
      final response = await autenticaProcuradorService.autenticarProcurador(
        xmlAssinado: xmlAssinado,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      print('Status da autenticação: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');
      print('Código: ${response.codigoMensagem}');

      if (response.sucesso && response.autenticarProcuradorToken != null) {
        print('✓ Token obtido: ${response.autenticarProcuradorToken!.substring(0, 8)}...');
        print('✓ Data de expiração: ${response.dataExpiracao}');
        print('✓ Token em cache: ${response.isCacheValido}');
      }
    } catch (e) {
      print('Erro na autenticação (esperado em ambiente de teste): $e');
    }

    // 8. Verificar cache de token
    print('\n--- 8. Verificando Cache de Token ---');
    final cache = await autenticaProcuradorService.verificarCacheToken(
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    if (cache != null) {
      print('✓ Token encontrado em cache');
      print('  - Válido: ${cache.isTokenValido}');
      print('  - Expira em breve: ${cache.expiraEmBreve}');
      print('  - Tempo restante: ${cache.tempoRestante.inHours} horas');
    } else {
      print('✗ Nenhum token válido em cache');
    }

    // 9. Obter token válido (do cache ou renovar)
    print('\n--- 9. Obtendo Token Válido ---');
    try {
      final token = await autenticaProcuradorService.obterTokenValido(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
      );

      print('✓ Token obtido: ${token.substring(0, 8)}...');
    } catch (e) {
      print('Erro ao obter token (esperado em ambiente de teste): $e');
    }

    // 10. Exemplo com certificado digital (simulado)
    print('\n--- 10. Exemplo com Certificado Digital (Simulado) ---');
    try {
      final termoComCertificado = await autenticaProcuradorService.criarTermoComDataAtual(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
        certificadoPath: '/caminho/para/certificado.p12',
        certificadoPassword: 'senha123',
      );

      print('Termo com certificado criado');
      print('Caminho do certificado: ${termoComCertificado.certificadoPath}');

      // Simular obtenção de informações do certificado
      final infoCertificado = await autenticaProcuradorService.obterInfoCertificado(
        certificadoPath: '/caminho/para/certificado.p12',
        senha: 'senha123',
      );

      print('Informações do certificado:');
      print('  - Serial: ${infoCertificado['serial']}');
      print('  - Subject: ${infoCertificado['subject']}');
      print('  - Tipo: ${infoCertificado['tipo']}');
      print('  - Formato: ${infoCertificado['formato']}');
      print('  - Tamanho: ${infoCertificado['tamanho_bytes']} bytes');
    } catch (e) {
      print('Erro com certificado (esperado em ambiente de teste): $e');
    }

    // 11. Exemplo de renovação de token
    print('\n--- 11. Exemplo de Renovação de Token ---');
    try {
      final responseRenovacao = await autenticaProcuradorService.renovarToken(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
      );

      print('Status da renovação: ${responseRenovacao.status}');
      print('Sucesso: ${responseRenovacao.sucesso}');
    } catch (e) {
      print('Erro na renovação (esperado em ambiente de teste): $e');
    }

    // 12. Gerenciamento de cache
    print('\n--- 12. Gerenciamento de Cache ---');
    final estatisticas = await autenticaProcuradorService.obterEstatisticasCache();
    print('Estatísticas do cache:');
    print('  - Total de caches: ${estatisticas['total_caches']}');
    print('  - Caches válidos: ${estatisticas['caches_validos']}');
    print('  - Caches expirados: ${estatisticas['caches_expirados']}');
    print('  - Taxa de válidos: ${estatisticas['taxa_validos']}%');
    print('  - Tamanho total: ${estatisticas['tamanho_total_kb']} KB');

    // 13. Limpeza de cache
    print('\n--- 13. Limpeza de Cache ---');
    final removidos = await autenticaProcuradorService.removerCachesExpirados();
    print('Caches expirados removidos: $removidos');

    // 14. Exemplo de uso com ApiClient
    print('\n--- 14. Exemplo de Uso com ApiClient ---');
    print('Verificando se ApiClient tem token de procurador:');
    print('  - Tem token: ${apiClient.hasProcuradorToken}');
    print('  - Token: ${apiClient.procuradorToken?.substring(0, 8) ?? 'N/A'}...');

    // Simular definição de token manual
    apiClient.setProcuradorToken('token_exemplo_123456789', contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    print('Após definir token manualmente:');
    print('  - Tem token: ${apiClient.hasProcuradorToken}');
    print('  - Token: ${apiClient.procuradorToken?.substring(0, 8) ?? 'N/A'}...');

    final infoCache = apiClient.procuradorCacheInfo;
    if (infoCache != null) {
      print('Informações do cache:');
      print('  - Token: ${infoCache['token']}');
      print('  - Válido: ${infoCache['is_valido']}');
      print('  - Expira em breve: ${infoCache['expira_em_breve']}');
      print('  - Tempo restante: ${infoCache['tempo_restante_horas']} horas');
    }

    // 15. Exemplo de fluxo completo
    print('\n--- 15. Exemplo de Fluxo Completo ---');
    print('Este exemplo demonstra o fluxo completo de autenticação de procurador:');
    print('1. ✓ Criar termo de autorização');
    print('2. ✓ Validar dados do termo');
    print('3. ✓ Criar XML do termo');
    print('4. ✓ Validar estrutura do XML');
    print('5. ✓ Assinar termo digitalmente');
    print('6. ✓ Validar assinatura digital');
    print('7. ✓ Autenticar procurador');
    print('8. ✓ Verificar cache de token');
    print('9. ✓ Obter token válido');
    print('10. ✓ Gerenciar cache');
    print('11. ✓ Usar com ApiClient');

    print('\n=== Exemplos Autenticação de Procurador Concluídos ===');
  } catch (e) {
    print('Erro no serviço de Autenticação de Procurador: $e');
  }
}

Future<void> exemplosRelpsn(ApiClient apiClient) async {
  print('\n=== Exemplos RELPSN (Parcelamento do Simples Nacional) ===');

  final relpsnService = RelpsnService(apiClient);

  try {
    // 1. Consultar Pedidos de Parcelamento
    print('\n--- 1. Consultar Pedidos de Parcelamento ---');
    final pedidosResponse = await relpsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('✓ Pedidos consultados com sucesso');
      print('Status: ${pedidosResponse.status}');
      print('Mensagem: ${pedidosResponse.mensagemPrincipal}');

      final parcelamentos = pedidosResponse.dadosParsed?.parcelamentos ?? [];
      print('Total de parcelamentos: ${parcelamentos.length}');

      for (final parcelamento in parcelamentos) {
        print('  - Parcelamento ${parcelamento.numero}:');
        print('    Situação: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
      }
    } else {
      print('✗ Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }

    // 2. Consultar Parcelamento Específico
    print('\n--- 2. Consultar Parcelamento Específico ---');
    const numeroParcelamento = 123456; // Número de exemplo

    try {
      final parcelamentoResponse = await relpsnService.consultarParcelamento(numeroParcelamento);

      if (parcelamentoResponse.sucesso) {
        print('✓ Parcelamento consultado com sucesso');
        final parcelamento = parcelamentoResponse.dadosParsed;

        if (parcelamento != null) {
          print('Número: ${parcelamento.numero}');
          print('Situação: ${parcelamento.situacao}');
          print('Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('Data da situação: ${parcelamento.dataDaSituacaoFormatada}');

          // Consolidação original
          final consolidacao = parcelamento.consolidacaoOriginal;
          if (consolidacao != null) {
            print('Consolidação original:');
            print('  Valor total: R\$ ${consolidacao.valorTotalConsolidadoDaEntrada.toStringAsFixed(2)}');
            print('  Data: ${consolidacao.dataConsolidacaoFormatada}');
            print('  Parcela de entrada: R\$ ${consolidacao.parcelaDeEntrada.toStringAsFixed(2)}');
            print('  Quantidade de parcelas: ${consolidacao.quantidadeParcelasDeEntrada}');
            print('  Valor consolidado da dívida: R\$ ${consolidacao.valorConsolidadoDivida.toStringAsFixed(2)}');

            print('  Detalhes da consolidação:');
            for (final detalhe in consolidacao.detalhesConsolidacao) {
              print('    - Período: ${detalhe.periodoApuracaoFormatado}');
              print('      Vencimento: ${detalhe.vencimentoFormatado}');
              print('      Processo: ${detalhe.numeroProcesso}');
              print('      Saldo original: R\$ ${detalhe.saldoDevedorOriginal.toStringAsFixed(2)}');
              print('      Valor atualizado: R\$ ${detalhe.valorAtualizado.toStringAsFixed(2)}');
            }
          }

          // Alterações de dívida
          print('Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
          for (final alteracao in parcelamento.alteracoesDivida) {
            print('  - Data: ${alteracao.dataAlteracaoDividaFormatada}');
            print('    Identificador: ${alteracao.identificadorConsolidacaoDescricao}');
            print('    Saldo sem reduções: R\$ ${alteracao.saldoDevedorOriginalSemReducoes.toStringAsFixed(2)}');
            print('    Valor com reduções: R\$ ${alteracao.valorRemanescenteComReducoes.toStringAsFixed(2)}');
            print('    Parte previdenciária: R\$ ${alteracao.partePrevidenciaria.toStringAsFixed(2)}');
            print('    Demais débitos: R\$ ${alteracao.demaisDebitos.toStringAsFixed(2)}');

            print('    Parcelas da alteração:');
            for (final parcela in alteracao.parcelasAlteracao) {
              print('      - Faixa: ${parcela.faixaParcelas}');
              print('        Parcela inicial: ${parcela.parcelaInicialFormatada}');
              print('        Vencimento inicial: ${parcela.vencimentoInicialFormatado}');
              print('        Parcela básica: R\$ ${parcela.parcelaBasica.toStringAsFixed(2)}');
            }
          }

          // Demonstrativo de pagamentos
          print('Demonstrativo de pagamentos: ${parcelamento.demonstrativoPagamentos.length}');
          for (final pagamento in parcelamento.demonstrativoPagamentos) {
            print('  - Mês: ${pagamento.mesDaParcelaFormatado}');
            print('    Vencimento DAS: ${pagamento.vencimentoDoDasFormatado}');
            print('    Data de arrecadação: ${pagamento.dataDeArrecadacaoFormatada}');
            print('    Valor pago: R\$ ${pagamento.valorPago.toStringAsFixed(2)}');
          }
        }
      } else {
        print('✗ Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('✗ Erro ao consultar parcelamento: $e');
    }

    // 3. Consultar Parcelas Disponíveis
    print('\n--- 3. Consultar Parcelas Disponíveis ---');

    try {
      final parcelasResponse = await relpsnService.consultarParcelas(numeroParcelamento);

      if (parcelasResponse.sucesso) {
        print('✓ Parcelas consultadas com sucesso');
        final parcelas = parcelasResponse.dadosParsed?.listaParcelas ?? [];

        print('Total de parcelas: ${parcelas.length}');
        print('Valor total: R\$ ${relpsnService.consultarParcelas(numeroParcelamento).then((r) => r.dadosParsed?.valorTotalParcelas ?? 0.0)}');

        // Parcelas ordenadas
        final parcelasOrdenadas = parcelasResponse.dadosParsed?.parcelasOrdenadas ?? [];
        print('Parcelas ordenadas:');
        for (final parcela in parcelasOrdenadas) {
          print('  - ${parcela.descricaoCompleta}');
          print('    Vencida: ${parcela.isVencida ? 'Sim' : 'Não'}');
          print('    Dias até vencimento: ${parcela.diasAteVencimento}');
        }

        // Próxima parcela a vencer
        final proximaParcela = parcelasResponse.dadosParsed?.proximaParcela;
        if (proximaParcela != null) {
          print('Próxima parcela a vencer: ${proximaParcela.descricaoCompleta}');
        }
      } else {
        print('✗ Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('✗ Erro ao consultar parcelas: $e');
    }

    // 4. Consultar Detalhes de Pagamento
    print('\n--- 4. Consultar Detalhes de Pagamento ---');
    const anoMesParcela = 202401; // Janeiro de 2024

    try {
      final detalhesResponse = await relpsnService.consultarDetalhesPagamento(numeroParcelamento, anoMesParcela);

      if (detalhesResponse.sucesso) {
        print('✓ Detalhes de pagamento consultados com sucesso');
        final detalhes = detalhesResponse.dadosParsed;

        if (detalhes != null) {
          print('DAS: ${detalhes.numeroDas}');
          print('Data de vencimento: ${detalhes.dataVencimentoFormatada}');
          print('PA DAS gerado: ${detalhes.paDasGeradoFormatado}');
          print('Gerado em: ${detalhes.geradoEmFormatado}');
          print('Número do parcelamento: ${detalhes.numeroParcelamento}');
          print('Número da parcela: ${detalhes.numeroParcela}');
          print('Data limite para acolhimento: ${detalhes.dataLimiteAcolhimentoFormatada}');
          print('Data do pagamento: ${detalhes.dataPagamentoFormatada}');
          print('Banco/Agência: ${detalhes.bancoAgencia}');
          print('Valor pago: ${detalhes.valorPagoArrecadacaoFormatado}');

          print('Total de débitos pagos: R\$ ${detalhes.totalDebitosPagos.toStringAsFixed(2)}');
          print('Total de tributos pagos: R\$ ${detalhes.totalTributosPagos.toStringAsFixed(2)}');

          print('Pagamentos de débitos:');
          for (final pagamento in detalhes.pagamentoDebitos) {
            print('  - PA Débito: ${pagamento.paDebitoFormatado}');
            print('    Processo: ${pagamento.processo}');
            print('    Total de débitos: R\$ ${pagamento.totalDebitos.toStringAsFixed(2)}');
            print('    Total principal: R\$ ${pagamento.totalPrincipal.toStringAsFixed(2)}');
            print('    Total multa: R\$ ${pagamento.totalMulta.toStringAsFixed(2)}');
            print('    Total juros: R\$ ${pagamento.totalJuros.toStringAsFixed(2)}');

            print('    Discriminações:');
            for (final discriminacao in pagamento.discriminacoesDebito) {
              print('      - ${discriminacao.descricaoCompleta}');
              print('        Percentual multa: ${discriminacao.percentualMulta.toStringAsFixed(2)}%');
              print('        Percentual juros: ${discriminacao.percentualJuros.toStringAsFixed(2)}%');
            }
          }
        }
      } else {
        print('✗ Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('✗ Erro ao consultar detalhes: $e');
    }

    // 5. Emitir DAS
    print('\n--- 5. Emitir DAS ---');
    const parcelaParaEmitir = 202401; // Janeiro de 2024

    try {
      final dasResponse = await relpsnService.emitirDas(numeroParcelamento, parcelaParaEmitir);

      if (dasResponse.sucesso && dasResponse.pdfGeradoComSucesso) {
        print('✓ DAS emitido com sucesso');
        print('Tamanho do PDF: ${dasResponse.tamanhoPdfFormatado}');
        print('PDF disponível: ${dasResponse.dadosParsed?.pdfDisponivel == true ? 'Sim' : 'Não'}');

        final pdfInfo = dasResponse.dadosParsed?.pdfInfo;
        if (pdfInfo != null) {
          print('Informações do PDF:');
          print('  - Disponível: ${pdfInfo['disponivel']}');
          print('  - Tamanho em caracteres: ${pdfInfo['tamanho_caracteres']}');
          print('  - Tamanho em bytes: ${pdfInfo['tamanho_bytes_aproximado']}');
          print('  - Preview: ${pdfInfo['preview']}');
        }
      } else {
        print('✗ Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('✗ Erro ao emitir DAS: $e');
    }

    // 6. Validações
    print('\n--- 6. Validações ---');

    // Validar número do parcelamento
    final validacaoParcelamento = relpsnService.validarNumeroParcelamento(numeroParcelamento);
    print('Validação parcelamento: ${validacaoParcelamento ?? 'Válido'}');

    // Validar ano/mês da parcela
    final validacaoAnoMes = relpsnService.validarAnoMesParcela(anoMesParcela);
    print('Validação ano/mês: ${validacaoAnoMes ?? 'Válido'}');

    // Validar parcela para emitir
    final validacaoParcela = relpsnService.validarParcelaParaEmitir(parcelaParaEmitir);
    print('Validação parcela para emitir: ${validacaoParcela ?? 'Válido'}');

    // Validar prazo de emissão
    final validacaoPrazo = relpsnService.validarPrazoEmissaoParcela(parcelaParaEmitir);
    print('Validação prazo de emissão: ${validacaoPrazo ?? 'Válido'}');

    // 7. Tratamento de Erros
    print('\n--- 7. Tratamento de Erros ---');

    // Verificar se um erro é conhecido
    const codigoErroExemplo = '[Aviso-RELPSN-ER_E001]';
    final isKnown = relpsnService.isKnownError(codigoErroExemplo);
    print('Erro conhecido ($codigoErroExemplo): ${isKnown ? 'Sim' : 'Não'}');

    // Obter informações sobre um erro
    final errorInfo = relpsnService.getErrorInfo(codigoErroExemplo);
    if (errorInfo != null) {
      print('Informações do erro:');
      print('  - Código: ${errorInfo.codigo}');
      print('  - Mensagem: ${errorInfo.mensagem}');
      print('  - Ação: ${errorInfo.acao}');
      print('  - Tipo: ${errorInfo.tipo}');
    }

    // Analisar um erro
    final analysis = relpsnService.analyzeError(codigoErroExemplo, 'Não há parcelamento ativo para o contribuinte.');
    print('Análise do erro:');
    print('  - Resumo: ${analysis.summary}');
    print('  - Ação recomendada: ${analysis.recommendedAction}');
    print('  - Severidade: ${analysis.severity}');
    print('  - Pode tentar novamente: ${analysis.canRetry ? 'Sim' : 'Não'}');
    print('  - Requer ação do usuário: ${analysis.requiresUserAction ? 'Sim' : 'Não'}');
    print('  - É crítico: ${analysis.isCritical ? 'Sim' : 'Não'}');
    print('  - É ignorável: ${analysis.isIgnorable ? 'Sim' : 'Não'}');
    print('  - É erro de validação: ${analysis.isValidationError ? 'Sim' : 'Não'}');
    print('  - É erro de sistema: ${analysis.isSystemError ? 'Sim' : 'Não'}');
    print('  - É aviso: ${analysis.isWarning ? 'Sim' : 'Não'}');

    // 8. Listar Erros por Tipo
    print('\n--- 8. Listar Erros por Tipo ---');

    final avisos = relpsnService.getAvisos();
    print('Total de avisos: ${avisos.length}');
    for (final aviso in avisos.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${aviso.codigo}: ${aviso.mensagem}');
    }

    final errosEntrada = relpsnService.getEntradasIncorretas();
    print('Total de erros de entrada: ${errosEntrada.length}');
    for (final erro in errosEntrada.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${erro.codigo}: ${erro.mensagem}');
    }

    final erros = relpsnService.getErros();
    print('Total de erros gerais: ${erros.length}');
    for (final erro in erros.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${erro.codigo}: ${erro.mensagem}');
    }

    print('\n=== Exemplos RELPSN Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço RELPSN: $e');
  }
}

Future<void> exemplosSicalc(ApiClient apiClient) async {
  print('\n=== Exemplos SICALC (Sistema de Cálculo de Acréscimos Legais) ===');

  final sicalcService = SicalcService(apiClient);

  try {
    // 1. Consultar Código de Receita
    print('\n--- 1. Consultando Código de Receita ---');
    final consultarReceitaResponse = await sicalcService.consultarCodigoReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 190, // IRPF
    );

    if (consultarReceitaResponse.sucesso) {
      print('✓ Receita consultada com sucesso');
      print('Status: ${consultarReceitaResponse.status}');
      print('Mensagem: ${consultarReceitaResponse.mensagemPrincipal}');

      final dados = consultarReceitaResponse.dados;
      if (dados != null) {
        print('Código da receita: ${dados.codigoReceita}');
        print('Descrição: ${dados.descricaoReceita}');
        print('Tipo de pessoa: ${dados.tipoPessoaFormatado}');
        print('Período de apuração: ${dados.tipoPeriodoFormatado}');
        print('Ativa: ${dados.ativa}');
        print('Vigente: ${dados.isVigente}');
        if (dados.observacoes != null) {
          print('Observações: ${dados.observacoes}');
        }
      }
    } else {
      print('✗ Erro ao consultar receita: ${consultarReceitaResponse.mensagemPrincipal}');
    }

    // 2. Gerar DARF para Pessoa Física (IRPF)
    print('\n--- 2. Gerando DARF para Pessoa Física (IRPF) ---');
    final darfPfResponse = await sicalcService.gerarDarfPessoaFisica(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      dataPA: '12/2023',
      vencimento: '2024-01-31T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2024-02-15T00:00:00',
      observacao: 'DARF calculado via SICALC',
    );

    if (darfPfResponse.sucesso) {
      print('✓ DARF gerado com sucesso');
      print('Status: ${darfPfResponse.status}');
      print('Mensagem: ${darfPfResponse.mensagemPrincipal}');
      print('Tem PDF: ${darfPfResponse.temPdf}');
      print('Tamanho do PDF: ${darfPfResponse.tamanhoPdfFormatado}');

      final dados = darfPfResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor principal: ${dados.valorPrincipalFormatado}');
        print('Valor total consolidado: ${dados.valorTotalFormatado}');
        print('Valor multa: ${dados.valorMultaFormatado}');
        print('Percentual multa: ${dados.percentualMultaMora}%');
        print('Valor juros: ${dados.valorJurosFormatado}');
        print('Percentual juros: ${dados.percentualJuros}%');
        print('Data de consolidação: ${dados.dataArrecadacaoConsolidacao}');
        print('Data de validade: ${dados.dataValidadeCalculo}');
      }
    } else {
      print('✗ Erro ao gerar DARF PF: ${darfPfResponse.mensagemPrincipal}');
    }

    // 3. Gerar DARF para Pessoa Jurídica (IRPJ)
    print('\n--- 3. Gerando DARF para Pessoa Jurídica (IRPJ) ---');
    final darfPjResponse = await sicalcService.gerarDarfPessoaJuridica(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '04/2023',
      vencimento: '2023-05-31T00:00:00',
      valorImposto: 5000.00,
      dataConsolidacao: '2023-06-15T00:00:00',
      observacao: 'DARF trimestral PJ',
    );

    if (darfPjResponse.sucesso) {
      print('✓ DARF PJ gerado com sucesso');
      print('Status: ${darfPjResponse.status}');
      print('Tem PDF: ${darfPjResponse.temPdf}');

      final dados = darfPjResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF PJ: ${darfPjResponse.mensagemPrincipal}');
    }

    // 4. Gerar DARF para PIS/PASEP
    print('\n--- 4. Gerando DARF para PIS/PASEP ---');
    final darfPisResponse = await sicalcService.gerarDarfPisPasep(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 500.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      observacao: 'DARF PIS/PASEP mensal',
    );

    if (darfPisResponse.sucesso) {
      print('✓ DARF PIS/PASEP gerado com sucesso');
      print('Status: ${darfPisResponse.status}');
      print('Tem PDF: ${darfPisResponse.temPdf}');

      final dados = darfPisResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF PIS/PASEP: ${darfPisResponse.mensagemPrincipal}');
    }

    // 5. Gerar DARF para COFINS
    print('\n--- 5. Gerando DARF para COFINS ---');
    final darfCofinsResponse = await sicalcService.gerarDarfCofins(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      observacao: 'DARF COFINS mensal',
    );

    if (darfCofinsResponse.sucesso) {
      print('✓ DARF COFINS gerado com sucesso');
      print('Status: ${darfCofinsResponse.status}');
      print('Tem PDF: ${darfCofinsResponse.temPdf}');

      final dados = darfCofinsResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF COFINS: ${darfCofinsResponse.mensagemPrincipal}');
    }

    // 6. Gerar código de barras para DARF já calculado
    print('\n--- 6. Gerando Código de Barras para DARF ---');
    if (darfPfResponse.sucesso && darfPfResponse.dados != null) {
      final codigoBarrasResponse = await sicalcService.gerarCodigoBarrasDarf(
        contribuinteNumero: '00000000000',
        numeroDocumento: darfPfResponse.dados!.numeroDocumento,
      );

      if (codigoBarrasResponse.sucesso) {
        print('✓ Código de barras gerado com sucesso');
        print('Status: ${codigoBarrasResponse.status}');
        print('Tem código de barras: ${codigoBarrasResponse.temCodigoBarras}');
        print('Tamanho: ${codigoBarrasResponse.tamanhoCodigoBarrasFormatado}');

        final dados = codigoBarrasResponse.dados;
        if (dados != null) {
          print('Número do documento: ${dados.numeroDocumento}');
          print('Tem linha digitável: ${dados.temLinhaDigitavel}');
          print('Tem QR Code: ${dados.temQrCode}');
          print('Data de geração: ${dados.dataGeracaoFormatada}');
          print('Data de validade: ${dados.dataValidadeFormatada}');
          print('Válido: ${dados.isValido}');

          final info = dados.infoCodigoBarras;
          print('Informações do código de barras:');
          print('  - Disponível: ${info['disponivel']}');
          print('  - Tamanho: ${info['tamanho_bytes_aproximado']} bytes');
          print('  - Tem linha digitável: ${info['tem_linha_digitavel']}');
          print('  - Tem QR Code: ${info['tem_qr_code']}');
          print('  - Preview: ${info['preview']}');
        }
      } else {
        print('✗ Erro ao gerar código de barras: ${codigoBarrasResponse.mensagemPrincipal}');
      }
    }

    // 7. Fluxo completo: Gerar DARF e código de barras
    print('\n--- 7. Fluxo Completo: DARF + Código de Barras ---');
    final fluxoCompletoResponse = await sicalcService.gerarDarfECodigoBarras(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '02/2024',
      vencimento: '2024-03-31T00:00:00',
      valorImposto: 1500.00,
      dataConsolidacao: '2024-04-05T00:00:00',
      observacao: 'Fluxo completo SICALC',
    );

    if (fluxoCompletoResponse.sucesso) {
      print('✓ Fluxo completo executado com sucesso');
      print('Status: ${fluxoCompletoResponse.status}');
      print('Tem código de barras: ${fluxoCompletoResponse.temCodigoBarras}');

      final dados = fluxoCompletoResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Tem linha digitável: ${dados.temLinhaDigitavel}');
        print('Tem QR Code: ${dados.temQrCode}');
      }
    } else {
      print('✗ Erro no fluxo completo: ${fluxoCompletoResponse.mensagemPrincipal}');
    }

    // 8. Consultar informações detalhadas de receita
    print('\n--- 8. Consultando Informações Detalhadas de Receita ---');
    final infoReceita = await sicalcService.obterInfoReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 1162, // PIS/PASEP
    );

    if (infoReceita != null) {
      print('✓ Informações da receita obtidas');
      print('Código: ${infoReceita['codigoReceita']}');
      print('Descrição: ${infoReceita['descricaoReceita']}');
      print('Tipo de pessoa: ${infoReceita['tipoPessoa']}');
      print('Período de apuração: ${infoReceita['tipoPeriodoApuracao']}');
      print('Ativa: ${infoReceita['ativa']}');
      print('Vigente: ${infoReceita['vigente']}');
      print('Compatível com contribuinte: ${infoReceita['compativelComContribuinte']}');
      if (infoReceita['observacoes'] != null) {
        print('Observações: ${infoReceita['observacoes']}');
      }
    } else {
      print('✗ Não foi possível obter informações da receita');
    }

    // 9. Validar compatibilidade de receita
    print('\n--- 9. Validando Compatibilidade de Receita ---');
    final isCompatible = await sicalcService.validarCompatibilidadeReceita(
      contribuinteNumero: '00000000000',
      codigoReceita: 190, // IRPF
    );

    print('Receita 190 (IRPF) é compatível com CPF: $isCompatible');

    final isCompatiblePJ = await sicalcService.validarCompatibilidadeReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 220, // IRPJ
    );

    print('Receita 220 (IRPJ) é compatível com CNPJ: $isCompatiblePJ');

    // 10. Exemplo com DARF manual (com multa e juros pré-calculados)
    print('\n--- 10. Exemplo com DARF Manual (Multa e Juros Pré-calculados) ---');
    final darfManualResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '03/2024',
      vencimento: '2024-04-30T00:00:00',
      valorImposto: 2000.00,
      dataConsolidacao: '2024-05-10T00:00:00',
      valorMulta: 100.00, // Multa pré-calculada
      valorJuros: 50.00, // Juros pré-calculados
      observacao: 'DARF manual com multa e juros',
    );

    if (darfManualResponse.sucesso) {
      print('✓ DARF manual gerado com sucesso');
      print('Status: ${darfManualResponse.status}');
      print('Tem PDF: ${darfManualResponse.temPdf}');

      final dados = darfManualResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor principal: ${dados.valorPrincipalFormatado}');
        print('Valor total: ${dados.valorTotalFormatado}');
        print('Valor multa: ${dados.valorMultaFormatado}');
        print('Valor juros: ${dados.valorJurosFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF manual: ${darfManualResponse.mensagemPrincipal}');
    }

    // 11. Exemplo com DARF de ganho de capital
    print('\n--- 11. Exemplo com DARF de Ganho de Capital ---');
    final darfGanhoCapitalResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '04/2024',
      vencimento: '2024-05-31T00:00:00',
      valorImposto: 5000.00,
      dataConsolidacao: '2024-06-15T00:00:00',
      ganhoCapital: true,
      dataAlienacao: '2024-04-15T00:00:00',
      observacao: 'DARF ganho de capital',
    );

    if (darfGanhoCapitalResponse.sucesso) {
      print('✓ DARF ganho de capital gerado com sucesso');
      print('Status: ${darfGanhoCapitalResponse.status}');
      print('Tem PDF: ${darfGanhoCapitalResponse.temPdf}');

      final dados = darfGanhoCapitalResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF ganho de capital: ${darfGanhoCapitalResponse.mensagemPrincipal}');
    }

    // 12. Exemplo com DARF com cota
    print('\n--- 12. Exemplo com DARF com Cota ---');
    final darfCotaResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 220,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-29T00:00:00',
      valorImposto: 3000.00,
      dataConsolidacao: '2024-03-10T00:00:00',
      cota: 1,
      observacao: 'DARF com cota',
    );

    if (darfCotaResponse.sucesso) {
      print('✓ DARF com cota gerado com sucesso');
      print('Status: ${darfCotaResponse.status}');
      print('Tem PDF: ${darfCotaResponse.temPdf}');

      final dados = darfCotaResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com cota: ${darfCotaResponse.mensagemPrincipal}');
    }

    // 13. Exemplo com DARF com CNO (Cadastro Nacional de Obras)
    print('\n--- 13. Exemplo com DARF com CNO ---');
    final darfCnoResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1162,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 800.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      cno: 12345,
      observacao: 'DARF com CNO',
    );

    if (darfCnoResponse.sucesso) {
      print('✓ DARF com CNO gerado com sucesso');
      print('Status: ${darfCnoResponse.status}');
      print('Tem PDF: ${darfCnoResponse.temPdf}');

      final dados = darfCnoResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com CNO: ${darfCnoResponse.mensagemPrincipal}');
    }

    // 14. Exemplo com DARF com CNPJ do prestador
    print('\n--- 14. Exemplo com DARF com CNPJ do Prestador ---');
    final darfCnpjPrestadorResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1165,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 1200.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      cnpjPrestador: 12345678000199,
      observacao: 'DARF com CNPJ do prestador',
    );

    if (darfCnpjPrestadorResponse.sucesso) {
      print('✓ DARF com CNPJ do prestador gerado com sucesso');
      print('Status: ${darfCnpjPrestadorResponse.status}');
      print('Tem PDF: ${darfCnpjPrestadorResponse.temPdf}');

      final dados = darfCnpjPrestadorResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com CNPJ do prestador: ${darfCnpjPrestadorResponse.mensagemPrincipal}');
    }

    // 15. Exemplo com diferentes tipos de período de apuração
    print('\n--- 15. Exemplo com Diferentes Tipos de Período de Apuração ---');

    // Mensal
    print('Testando período mensal...');
    final darfMensal = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1162,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 500.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      tipoPA: 'ME',
      observacao: 'DARF mensal',
    );
    print('DARF mensal: ${darfMensal.sucesso ? 'Sucesso' : 'Erro'}');

    // Trimestral
    print('Testando período trimestral...');
    final darfTrimestral = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1164,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-04-30T00:00:00',
      valorImposto: 2000.00,
      dataConsolidacao: '2024-05-10T00:00:00',
      tipoPA: 'TR',
      observacao: 'DARF trimestral',
    );
    print('DARF trimestral: ${darfTrimestral.sucesso ? 'Sucesso' : 'Erro'}');

    // Anual
    print('Testando período anual...');
    final darfAnual = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '2023',
      vencimento: '2024-03-31T00:00:00',
      valorImposto: 10000.00,
      dataConsolidacao: '2024-04-15T00:00:00',
      tipoPA: 'AN',
      observacao: 'DARF anual',
    );
    print('DARF anual: ${darfAnual.sucesso ? 'Sucesso' : 'Erro'}');

    print('\n=== Exemplos SICALC Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço SICALC: $e');
  }
}

Future<void> exemplosRelpmei(ApiClient apiClient) async {
  print('\n=== Exemplos RELPMEI ===');

  final relpmeiService = RelpmeiService(apiClient);

  try {
    // Exemplo 1: Consultar Pedidos de Parcelamento
    print('\n--- Consultando Pedidos de Parcelamento ---');
    final consultarPedidosRequest = ConsultarPedidosRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta de pedidos RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelamento de débitos',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarPedidosResponse = await relpmeiService.consultarPedidos(consultarPedidosRequest);
    print('Consulta de pedidos: ${consultarPedidosResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarPedidosResponse.sucesso) {
      print('Pedidos encontrados: ${consultarPedidosResponse.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${consultarPedidosResponse.mensagem}');
      print('Código: ${consultarPedidosResponse.codigoErro}');
      print('Detalhes: ${consultarPedidosResponse.detalhesErro}');
    }

    // Exemplo 2: Consultar Parcelamentos Existentes
    print('\n--- Consultando Parcelamentos Existentes ---');
    final consultarParcelamentoRequest = ConsultarParcelamentoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PARCELAMENTOS', dados: 'Consulta de parcelamentos RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelamento de débitos',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarParcelamentoResponse = await relpmeiService.consultarParcelamento(consultarParcelamentoRequest);
    print('Consulta de parcelamentos: ${consultarParcelamentoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarParcelamentoResponse.sucesso) {
      print('Parcelamentos encontrados: ${consultarParcelamentoResponse.parcelamentos?.length ?? 0}');
    } else {
      print('Erro: ${consultarParcelamentoResponse.mensagem}');
      print('Código: ${consultarParcelamentoResponse.codigoErro}');
      print('Detalhes: ${consultarParcelamentoResponse.detalhesErro}');
    }

    // Exemplo 3: Consultar Parcelas para Impressão
    print('\n--- Consultando Parcelas para Impressão ---');
    final consultarParcelasImpressaoRequest = ConsultarParcelasImpressaoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PARCELAS_IMPRESSAO', dados: 'Consulta de parcelas para impressão RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelas para impressão',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarParcelasImpressaoResponse = await relpmeiService.consultarParcelasImpressao(consultarParcelasImpressaoRequest);
    print('Consulta de parcelas para impressão: ${consultarParcelasImpressaoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarParcelasImpressaoResponse.sucesso) {
      print('Parcelas para impressão encontradas: ${consultarParcelasImpressaoResponse.parcelas?.length ?? 0}');
    } else {
      print('Erro: ${consultarParcelasImpressaoResponse.mensagem}');
      print('Código: ${consultarParcelasImpressaoResponse.codigoErro}');
      print('Detalhes: ${consultarParcelasImpressaoResponse.detalhesErro}');
    }

    // Exemplo 4: Consultar Detalhes de Pagamento
    print('\n--- Consultando Detalhes de Pagamento ---');
    final consultarDetalhesPagamentoRequest = ConsultarDetalhesPagamentoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_DETALHES_PAGAMENTO', dados: 'Consulta de detalhes de pagamento RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Detalhes de pagamento',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarDetalhesPagamentoResponse = await relpmeiService.consultarDetalhesPagamento(consultarDetalhesPagamentoRequest);
    print('Consulta de detalhes de pagamento: ${consultarDetalhesPagamentoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarDetalhesPagamentoResponse.sucesso) {
      print('Detalhes de pagamento encontrados: ${consultarDetalhesPagamentoResponse.detalhes?.length ?? 0}');
    } else {
      print('Erro: ${consultarDetalhesPagamentoResponse.mensagem}');
      print('Código: ${consultarDetalhesPagamentoResponse.codigoErro}');
      print('Detalhes: ${consultarDetalhesPagamentoResponse.detalhesErro}');
    }

    // Exemplo 5: Emitir DAS
    print('\n--- Emitindo DAS ---');
    final emitirDasRequest = EmitirDasRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'EMITIR_DAS', dados: 'Emissão de DAS RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Emissão de DAS',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final emitirDasResponse = await relpmeiService.emitirDas(emitirDasRequest);
    print('Emissão de DAS: ${emitirDasResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (emitirDasResponse.sucesso) {
      print('DAS emitido: ${emitirDasResponse.das?.numeroDas ?? 'N/A'}');
      print('Valor: ${emitirDasResponse.das?.valor ?? 'N/A'}');
      print('Vencimento: ${emitirDasResponse.das?.dataVencimento ?? 'N/A'}');
    } else {
      print('Erro: ${emitirDasResponse.mensagem}');
      print('Código: ${emitirDasResponse.codigoErro}');
      print('Detalhes: ${emitirDasResponse.detalhesErro}');
    }

    // Exemplo 6: Teste de validação com CPF/CNPJ inválido
    print('\n--- Teste de Validação com CPF/CNPJ Inválido ---');
    final requestInvalido = ConsultarPedidosRequest(
      contribuinteNumero: '',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Teste de validação'),
      cpfCnpj: '', // CPF vazio para testar validação
    );

    final responseInvalido = await relpmeiService.consultarPedidos(requestInvalido);
    print('Validação de CPF vazio: ${responseInvalido.sucesso ? 'Sucesso' : 'Erro'}');
    if (!responseInvalido.sucesso) {
      print('Erro esperado: ${responseInvalido.mensagem}');
      print('Código: ${responseInvalido.codigoErro}');
    }

    // Exemplo 7: Teste com CNPJ
    print('\n--- Teste com CNPJ ---');
    final requestCnpj = ConsultarPedidosRequest(
      contribuinteNumero: '12345678000195',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta com CNPJ'),
      cpfCnpj: '12345678000195', // CNPJ de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
    );

    final responseCnpj = await relpmeiService.consultarPedidos(requestCnpj);
    print('Consulta com CNPJ: ${responseCnpj.sucesso ? 'Sucesso' : 'Erro'}');
    if (responseCnpj.sucesso) {
      print('Pedidos encontrados: ${responseCnpj.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${responseCnpj.mensagem}');
    }

    // Exemplo 8: Teste com dados mínimos
    print('\n--- Teste com Dados Mínimos ---');
    final requestMinimo = ConsultarPedidosRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta com dados mínimos'),
      cpfCnpj: '12345678901', // Apenas CPF obrigatório
    );

    final responseMinimo = await relpmeiService.consultarPedidos(requestMinimo);
    print('Consulta com dados mínimos: ${responseMinimo.sucesso ? 'Sucesso' : 'Erro'}');
    if (responseMinimo.sucesso) {
      print('Pedidos encontrados: ${responseMinimo.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${responseMinimo.mensagem}');
    }

    print('\n=== Exemplos RELPMEI Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço RELPMEI: $e');
  }
}

Future<void> exemplosPertmei(ApiClient apiClient) async {
  print('\n=== Exemplos PERTMEI ===');

  final pertmeiService = PertmeiService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo

  try {
    // 1. Consultar Pedidos de Parcelamento
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await pertmeiService.consultarPedidos(cnpjContribuinte);
    print('Status: ${pedidosResponse.status}');
    print('Mensagens: ${pedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (pedidosResponse.status == '200') {
      final parcelamentos = pedidosResponse.parcelamentos;
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      for (final parcelamento in parcelamentos) {
        print('  - Número: ${parcelamento.numero}, Situação: ${parcelamento.situacao}');
      }
    }

    // 2. Consultar Parcelamento Específico
    print('\n2. Consultando parcelamento específico...');
    const numeroParcelamento = 9001; // Número de exemplo da documentação
    final parcelamentoResponse = await pertmeiService.consultarParcelamento(cnpjContribuinte, numeroParcelamento);
    print('Status: ${parcelamentoResponse.status}');
    print('Mensagens: ${parcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelamentoResponse.status == '200') {
      final parcelamentoDetalhado = parcelamentoResponse.parcelamentoDetalhado;
      if (parcelamentoDetalhado != null) {
        print('Parcelamento encontrado: ${parcelamentoDetalhado.numero}');
        print('Situação: ${parcelamentoDetalhado.situacao}');
        print('Consolidação original: ${parcelamentoDetalhado.consolidacaoOriginal?.valorTotalConsolidadoDaDivida ?? 0.0}');
      }
    }

    // 3. Consultar Parcelas para Impressão
    print('\n3. Consultando parcelas para impressão...');
    final parcelasResponse = await pertmeiService.consultarParcelasParaImpressao(cnpjContribuinte);
    print('Status: ${parcelasResponse.status}');
    print('Mensagens: ${parcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelasResponse.status == '200') {
      final parcelas = parcelasResponse.parcelas;
      print('Parcelas disponíveis: ${parcelas.length}');
      for (final parcela in parcelas) {
        print('  - Parcela: ${parcela.parcela}, Valor: R\$ ${parcela.valor.toStringAsFixed(2)}');
      }
    }

    // 4. Consultar Detalhes de Pagamento
    print('\n4. Consultando detalhes de pagamento...');
    const anoMesParcela = 201907; // Exemplo da documentação
    final detalhesResponse = await pertmeiService.consultarDetalhesPagamento(cnpjContribuinte, numeroParcelamento, anoMesParcela);
    print('Status: ${detalhesResponse.status}');
    print('Mensagens: ${detalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (detalhesResponse.status == '200') {
      final detalhesPagamento = detalhesResponse.detalhesPagamento;
      if (detalhesPagamento != null) {
        print('DAS encontrado: ${detalhesPagamento.numeroDas}');
        print('Valor pago: R\$ ${detalhesPagamento.valorPagoArrecadacao.toStringAsFixed(2)}');
        print('Data pagamento: ${detalhesPagamento.dataPagamento}');
      }
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    const parcelaParaEmitir = 202306; // Exemplo da documentação
    final emitirResponse = await pertmeiService.emitirDas(cnpjContribuinte, parcelaParaEmitir);
    print('Status: ${emitirResponse.status}');
    print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (emitirResponse.status == '200') {
      final dasGerado = emitirResponse.dasGerado;
      if (dasGerado != null) {
        print('DAS gerado com sucesso!');
        print('Tamanho do PDF (base64): ${dasGerado.docArrecadacaoPdfB64.length} caracteres');
        // Em uma aplicação real, você converteria o base64 para PDF e salvaria/abriria o arquivo
      }
    }

    // Exemplos de validação de erro
    print('\n6. Testando validações...');

    // Teste com CNPJ vazio
    final erroResponse = await pertmeiService.consultarPedidos('');
    print('Validação CNPJ vazio: ${erroResponse.status} - ${erroResponse.mensagens.first.texto}');

    // Teste com número de parcelamento inválido
    final erroParcelamento = await pertmeiService.consultarParcelamento(cnpjContribuinte, 0);
    print('Validação parcelamento inválido: ${erroParcelamento.status} - ${erroParcelamento.mensagens.first.texto}');

    // Teste com formato de data inválido
    final erroData = await pertmeiService.emitirDas(cnpjContribuinte, 20230); // Formato inválido
    print('Validação formato data inválido: ${erroData.status} - ${erroData.mensagens.first.texto}');

    print('\n=== Exemplos PERTMEI Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço PERTMEI: $e');
  }
}

Future<void> exemplosMit(ApiClient apiClient) async {
  print('\n=== Exemplos MIT (Módulo de Inclusão de Tributos) ===');

  final mitService = MitService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo

  try {
    // 1. Criar Apuração Sem Movimento
    print('\n1. Criando apuração sem movimento...');
    final responsavelApuracao = ResponsavelApuracao(cpfResponsavel: '12345678901', emailResponsavel: 'responsavel@exemplo.com');

    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    final apuracaoSemMovimento = await mitService.criarApuracaoSemMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
    );

    print('Status: ${apuracaoSemMovimento.status}');
    print('Sucesso: ${apuracaoSemMovimento.sucesso}');
    if (apuracaoSemMovimento.sucesso) {
      print('Protocolo: ${apuracaoSemMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoSemMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoSemMovimento.mensagemErro}');
    }

    // 2. Criar Apuração Com Movimento
    print('\n2. Criando apuração com movimento...');
    final debitoIrpj = Debito(idDebito: 1, codigoDebito: '236208', valorDebito: 100.00);

    final debitoCsll = Debito(idDebito: 2, codigoDebito: '248408', valorDebito: 220.00);

    final debitos = Debitos(
      irpj: ListaDebitosIrpj(listaDebitos: [debitoIrpj]),
      csll: ListaDebitosCsll(listaDebitos: [debitoCsll]),
    );

    final apuracaoComMovimento = await mitService.criarApuracaoComMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
      debitos: debitos,
    );

    print('Status: ${apuracaoComMovimento.status}');
    print('Sucesso: ${apuracaoComMovimento.sucesso}');
    if (apuracaoComMovimento.sucesso) {
      print('Protocolo: ${apuracaoComMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoComMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoComMovimento.mensagemErro}');
    }

    // 3. Consultar Situação de Encerramento
    if (apuracaoSemMovimento.protocoloEncerramento != null) {
      print('\n3. Consultando situação de encerramento...');
      final situacaoResponse = await mitService.consultarSituacaoEncerramento(
        contribuinteNumero: cnpjContribuinte,
        protocoloEncerramento: apuracaoSemMovimento.protocoloEncerramento!,
      );

      print('Status: ${situacaoResponse.status}');
      print('Sucesso: ${situacaoResponse.sucesso}');
      if (situacaoResponse.sucesso) {
        print('ID Apuração: ${situacaoResponse.idApuracao}');
        print('Situação: ${situacaoResponse.textoSituacao}');
        print('Data Encerramento: ${situacaoResponse.dataEncerramento}');
        if (situacaoResponse.avisosDctf != null) {
          print('Avisos DCTF: ${situacaoResponse.avisosDctf!.join(', ')}');
        }
      } else {
        print('Erro: ${situacaoResponse.mensagemErro}');
      }
    }

    // 4. Consultar Apuração
    if (apuracaoSemMovimento.idApuracao != null) {
      print('\n4. Consultando dados da apuração...');
      final consultaResponse = await mitService.consultarApuracao(contribuinteNumero: cnpjContribuinte, idApuracao: apuracaoSemMovimento.idApuracao!);

      print('Status: ${consultaResponse.status}');
      print('Sucesso: ${consultaResponse.sucesso}');
      if (consultaResponse.sucesso) {
        print('Situação: ${consultaResponse.textoSituacao}');
        if (consultaResponse.dadosApuracaoMit != null) {
          print('Dados da apuração encontrados: ${consultaResponse.dadosApuracaoMit!.length} registros');
        }
      } else {
        print('Erro: ${consultaResponse.mensagemErro}');
      }
    }

    // 5. Listar Apurações por Ano
    print('\n5. Listando apurações por ano...');
    final listagemResponse = await mitService.listarApuracaoes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('Status: ${listagemResponse.status}');
    print('Sucesso: ${listagemResponse.sucesso}');
    if (listagemResponse.sucesso) {
      print('Apurações encontradas: ${listagemResponse.apuracoes?.length ?? 0}');
      if (listagemResponse.apuracoes != null) {
        for (final apuracao in listagemResponse.apuracoes!) {
          print('  - Período: ${apuracao.periodoApuracao}, ID: ${apuracao.idApuracao}, Situação: ${apuracao.situacaoEnum?.descricao}');
        }
      }
    } else {
      print('Erro: ${listagemResponse.mensagemErro}');
    }

    // 6. Consultar Apurações por Mês
    print('\n6. Consultando apurações por mês...');
    final listagemMesResponse = await mitService.consultarApuracaoesPorMes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025, mesApuracao: 1);

    print('Status: ${listagemMesResponse.status}');
    print('Sucesso: ${listagemMesResponse.sucesso}');
    if (listagemMesResponse.sucesso) {
      print('Apurações do mês: ${listagemMesResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemMesResponse.mensagemErro}');
    }

    // 7. Consultar Apurações Encerradas
    print('\n7. Consultando apurações encerradas...');
    final listagemEncerradasResponse = await mitService.consultarApuracaoesEncerradas(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('Status: ${listagemEncerradasResponse.status}');
    print('Sucesso: ${listagemEncerradasResponse.sucesso}');
    if (listagemEncerradasResponse.sucesso) {
      print('Apurações encerradas: ${listagemEncerradasResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemEncerradasResponse.mensagemErro}');
    }

    // 8. Aguardar Encerramento (exemplo com timeout curto)
    if (apuracaoSemMovimento.protocoloEncerramento != null) {
      print('\n8. Aguardando encerramento (timeout de 60 segundos)...');
      try {
        final aguardarResponse = await mitService.aguardarEncerramento(
          contribuinteNumero: cnpjContribuinte,
          protocoloEncerramento: apuracaoSemMovimento.protocoloEncerramento!,
          timeoutSegundos: 60,
          intervaloConsulta: 10,
        );

        print('Status final: ${aguardarResponse.status}');
        print('Situação final: ${aguardarResponse.textoSituacao}');
      } catch (e) {
        print('Timeout ou erro ao aguardar encerramento: $e');
      }
    }

    // 9. Exemplo com Eventos Especiais
    print('\n9. Criando apuração com evento especial...');
    final eventoEspecial = EventoEspecial(idEvento: 1, diaEvento: 15, tipoEvento: TipoEventoEspecial.fusao);

    final dadosIniciaisComEvento = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: QualificacaoPj.pjEmGeral,
      tributacaoLucro: TributacaoLucro.realAnual,
      variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
      regimePisCofins: RegimePisCofins.naoCumulativa,
      responsavelApuracao: responsavelApuracao,
    );

    final apuracaoComEvento = await mitService.encerrarApuracao(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciaisComEvento,
      debitos: debitos,
      listaEventosEspeciais: [eventoEspecial],
    );

    print('Status: ${apuracaoComEvento.status}');
    print('Sucesso: ${apuracaoComEvento.sucesso}');
    if (apuracaoComEvento.sucesso) {
      print('Protocolo: ${apuracaoComEvento.protocoloEncerramento}');
    } else {
      print('Erro: ${apuracaoComEvento.mensagemErro}');
    }

    // 10. Exemplo de Validação com Dados Inválidos
    print('\n10. Testando validação com dados inválidos...');
    try {
      PeriodoApuracao(
        mesApuracao: 13, // Mês inválido
        anoApuracao: 2025,
      );
    } catch (e) {
      print('Validação de mês inválido: $e');
    }

    try {
      Debito(
        idDebito: 0, // ID inválido
        codigoDebito: '236208',
        valorDebito: -100.00, // Valor negativo
      );
    } catch (e) {
      print('Validação de débito inválido: $e');
    }

    print('\n=== Exemplos MIT Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço MIT: $e');
  }
}

Future<void> exemplosPertsn(ApiClient apiClient) async {
  print('=== Exemplos PERTSN ===');

  final pertsnService = PertsnService(apiClient);

  try {
    // 1. Consultar pedidos de parcelamento
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await pertsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('Status: ${pedidosResponse.status}');
      print('Mensagem: ${pedidosResponse.mensagemPrincipal}');

      if (pedidosResponse.temParcelamentos) {
        final parcelamentos = pedidosResponse.dadosParsed!.parcelamentos;
        print('Quantidade de parcelamentos: ${parcelamentos.length}');

        for (final parcelamento in parcelamentos) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
          print('  Ativo: ${parcelamento.isAtivo}');
        }
      } else {
        print('Nenhum parcelamento encontrado');
      }
    } else {
      print('Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }

    // 2. Consultar parcelamento específico (usando exemplo da documentação)
    print('\n2. Consultando parcelamento específico...');
    try {
      final parcelamentoResponse = await pertsnService.consultarParcelamento(9102);

      if (parcelamentoResponse.sucesso) {
        print('Status: ${parcelamentoResponse.status}');
        print('Mensagem: ${parcelamentoResponse.mensagemPrincipal}');

        final parcelamento = parcelamentoResponse.dadosParsed;
        if (parcelamento != null) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Valor total consolidado: R\$ ${parcelamento.valorTotalConsolidado.toStringAsFixed(2)}');
          print('  Valor total entrada: R\$ ${parcelamento.valorTotalEntrada.toStringAsFixed(2)}');
          print('  Quantidade parcelas entrada: ${parcelamento.quantidadeParcelasEntrada}');
          print('  Valor parcela entrada: R\$ ${parcelamento.valorParcelaEntrada.toStringAsFixed(2)}');

          if (parcelamento.consolidacaoOriginal != null) {
            print('  Consolidação original:');
            print('    Data: ${parcelamento.consolidacaoOriginal!.dataConsolidacaoFormatada}');
            print('    Valor consolidado: R\$ ${parcelamento.consolidacaoOriginal!.valorConsolidadoDaDivida.toStringAsFixed(2)}');
            print('    Detalhes: ${parcelamento.consolidacaoOriginal!.detalhesConsolidacao.length} itens');
          }

          if (parcelamento.alteracoesDivida.isNotEmpty) {
            print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
            for (final alteracao in parcelamento.alteracoesDivida) {
              print('    Total consolidado: R\$ ${alteracao.totalConsolidado.toStringAsFixed(2)}');
              print('    Parcelas remanescentes: ${alteracao.parcelasRemanescentes}');
              print('    Parcela básica: R\$ ${alteracao.parcelaBasica.toStringAsFixed(2)}');
              print('    Data alteração: ${alteracao.dataAlteracaoDividaFormatada}');
            }
          }

          if (parcelamento.demonstrativoPagamentos.isNotEmpty) {
            print('  Demonstrativo de pagamentos: ${parcelamento.demonstrativoPagamentos.length}');
            for (final pagamento in parcelamento.demonstrativoPagamentos) {
              print('    Mês: ${pagamento.mesDaParcelaFormatado}');
              print('    Vencimento: ${pagamento.vencimentoDoDasFormatado}');
              print('    Data arrecadação: ${pagamento.dataDeArrecadacaoFormatada}');
              print('    Valor pago: ${pagamento.valorPagoFormatado}');
            }
          }
        }
      } else {
        print('Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro ao consultar parcelamento: $e');
    }

    // 3. Consultar parcelas para impressão
    print('\n3. Consultando parcelas para impressão...');
    try {
      final parcelasResponse = await pertsnService.consultarParcelas();

      if (parcelasResponse.sucesso) {
        print('Status: ${parcelasResponse.status}');
        print('Mensagem: ${parcelasResponse.mensagemPrincipal}');

        if (parcelasResponse.temParcelas) {
          final parcelas = parcelasResponse.dadosParsed!.listaParcelas;
          print('Quantidade de parcelas: ${parcelas.length}');
          print('Valor total: ${parcelasResponse.valorTotalParcelasFormatado}');

          // Mostrar algumas parcelas
          final parcelasParaMostrar = parcelas.take(5).toList();
          print('Primeiras 5 parcelas:');
          for (final parcela in parcelasParaMostrar) {
            print('  ${parcela.descricaoCompleta}: ${parcela.valorFormatado}');
          }

          // Mostrar estatísticas
          print('Parcelas pendentes: ${parcelasResponse.parcelasPendentes.length}');
          print('Parcelas vencidas: ${parcelasResponse.parcelasVencidas.length}');
          print('Parcelas do mês atual: ${parcelasResponse.parcelasMesAtual.length}');

          // Mostrar parcelas por ano
          final parcelasPorAno = parcelasResponse.parcelasPorAno;
          print('Parcelas por ano:');
          for (final entry in parcelasPorAno.entries) {
            print('  ${entry.key}: ${entry.value.length} parcelas');
          }
        } else {
          print('Nenhuma parcela encontrada');
        }
      } else {
        print('Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro ao consultar parcelas: $e');
    }

    // 4. Consultar detalhes de pagamento
    print('\n4. Consultando detalhes de pagamento...');
    try {
      final detalhesResponse = await pertsnService.consultarDetalhesPagamento(9102, 201806);

      if (detalhesResponse.sucesso) {
        print('Status: ${detalhesResponse.status}');
        print('Mensagem: ${detalhesResponse.mensagemPrincipal}');

        final detalhes = detalhesResponse.dadosParsed;
        if (detalhes != null) {
          print('Detalhes do pagamento:');
          print('  Número DAS: ${detalhes.numeroDas}');
          print('  Código de barras: ${detalhes.codigoBarras}');
          print('  Valor pago: ${detalhes.valorPagoArrecadacaoFormatado}');
          print('  Data arrecadação: ${detalhes.dataArrecadacaoFormatada}');
          print('  Banco/Agência: ${detalhes.bancoAgencia}');

          if (detalhes.temPagamentosDebitos) {
            print('  Débitos pagos: ${detalhes.quantidadeDebitosPagos}');
            print('  Valor total débitos: ${detalhes.valorTotalDebitosPagosFormatado}');

            for (final debito in detalhes.pagamentosDebitos) {
              print('    Período: ${debito.periodoApuracaoFormatado}');
              print('    Vencimento: ${debito.vencimentoFormatado}');
              print('    Tributo: ${debito.tributo}');
              print('    Ente federado: ${debito.enteFederado}');
              print('    Valor pago: ${debito.valorPagoFormatado}');

              if (debito.temDiscriminacaoDebitos) {
                print('      Discriminações: ${debito.quantidadeDiscriminacoes}');
                for (final discriminacao in debito.discriminacaoDebitos) {
                  print('        ${discriminacao.descricaoResumida}');
                  print('        Valor principal: ${discriminacao.valorPrincipalFormatado}');
                  print('        Valor multa: ${discriminacao.valorMultaFormatado}');
                  print('        Valor juros: ${discriminacao.valorJurosFormatado}');
                  print('        Valor total: ${discriminacao.valorTotalFormatado}');
                }
              }
            }
          }
        }
      } else {
        print('Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro ao consultar detalhes: $e');
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    try {
      final dasResponse = await pertsnService.emitirDas(202301);

      if (dasResponse.sucesso) {
        print('Status: ${dasResponse.status}');
        print('Mensagem: ${dasResponse.mensagemPrincipal}');

        if (dasResponse.pdfGeradoComSucesso) {
          print('PDF gerado com sucesso!');
          print('Tamanho: ${dasResponse.tamanhoPdfFormatado}');
          print('Info: ${dasResponse.infoPdf}');

          final pdfBase64 = dasResponse.pdfBase64;
          if (pdfBase64 != null) {
            print('PDF Base64 disponível: ${pdfBase64.length} caracteres');

            final dadosParsed = dasResponse.dadosParsed;
            if (dadosParsed != null) {
              print('Nome sugerido: ${dadosParsed.nomeArquivoSugerido}');
              print('Tipo MIME: ${dadosParsed.tipoMime}');
              print('PDF válido: ${dadosParsed.isPdfValido}');
            }
          }
        } else {
          print('PDF não foi gerado');
        }
      } else {
        print('Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro ao emitir DAS: $e');
    }

    // 6. Exemplos de validações
    print('\n6. Testando validações...');

    // Validar número de parcelamento
    final validacaoParcelamento = pertsnService.validarNumeroParcelamento(0);
    if (validacaoParcelamento != null) {
      print('Validação parcelamento inválido: $validacaoParcelamento');
    }

    // Validar ano/mês da parcela
    final validacaoAnoMes = pertsnService.validarAnoMesParcela(202513); // Mês inválido
    if (validacaoAnoMes != null) {
      print('Validação ano/mês inválido: $validacaoAnoMes');
    }

    // Validar parcela para emitir
    final validacaoParcela = pertsnService.validarParcelaParaEmitir(202501);
    if (validacaoParcela != null) {
      print('Validação parcela futura: $validacaoParcela');
    }

    // Validar CNPJ
    final validacaoCnpj = pertsnService.validarCnpjContribuinte('123');
    if (validacaoCnpj != null) {
      print('Validação CNPJ inválido: $validacaoCnpj');
    }

    // Validar tipo de contribuinte
    final validacaoTipo = pertsnService.validarTipoContribuinte(1); // Tipo inválido para PERTSN
    if (validacaoTipo != null) {
      print('Validação tipo contribuinte: $validacaoTipo');
    }

    // 7. Exemplos de análise de erros
    print('\n7. Testando análise de erros...');

    // Verificar se erro é conhecido
    final erroConhecido = pertsnService.isKnownError('[Aviso-PERTSN-ER_E001]');
    print('Erro conhecido: $erroConhecido');

    // Obter informações sobre erro
    final errorInfo = pertsnService.getErrorInfo('[Aviso-PERTSN-ER_E001]');
    if (errorInfo != null) {
      print('Informações do erro:');
      print('  Código: ${errorInfo.codigo}');
      print('  Tipo: ${errorInfo.tipo}');
      print('  Mensagem: ${errorInfo.mensagem}');
      print('  Ação: ${errorInfo.acao}');
    }

    // Analisar erro
    final analysis = pertsnService.analyzeError('[Aviso-PERTSN-ER_E001]', 'Não há parcelamento ativo para o contribuinte.');
    print('Análise do erro:');
    print('  Resumo: ${analysis.resumo}');
    print('  Ação recomendada: ${analysis.recommendedAction}');
    print('  Conhecido: ${analysis.isKnown}');

    // Obter listas de erros
    final avisos = pertsnService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');

    final errosEntrada = pertsnService.getEntradasIncorretas();
    print('Erros de entrada incorreta: ${errosEntrada.length}');

    final erros = pertsnService.getErros();
    print('Erros gerais: ${erros.length}');

    final sucessos = pertsnService.getSucessos();
    print('Sucessos: ${sucessos.length}');

    print('\n=== Exemplos PERTSN Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos PERTSN: $e');
  }
}

Future<void> exemplosParcmeiEspecial(ApiClient apiClient) async {
  print('=== Exemplos PARCMEI-ESP ===');

  final parcmeiEspecialService = ParcmeiEspecialService(apiClient);

  try {
    // 1. Consultar pedidos de parcelamento
    print('\n1. Consultando pedidos de parcelamento PARCMEI-ESP...');
    final responsePedidos = await parcmeiEspecialService.consultarPedidos();

    if (responsePedidos.sucesso) {
      print('Status: ${responsePedidos.status}');
      print('Mensagem: ${responsePedidos.mensagemPrincipal}');
      print('Tem parcelamentos: ${responsePedidos.temParcelamentos}');
      print('Quantidade de parcelamentos: ${responsePedidos.quantidadeParcelamentos}');

      final parcelamentos = responsePedidos.dadosParsed?.parcelamentos ?? [];
      for (final parcelamento in parcelamentos) {
        print('  Parcelamento ${parcelamento.numero}:');
        print('    Situação: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('    Ativo: ${parcelamento.isAtivo}');
      }
    } else {
      print('Erro: ${responsePedidos.mensagemPrincipal}');
    }

    // 2. Consultar parcelamento específico
    print('\n2. Consultando parcelamento específico...');
    try {
      final responseParcelamento = await parcmeiEspecialService.consultarParcelamento(9001);

      if (responseParcelamento.sucesso) {
        print('Status: ${responseParcelamento.status}');
        print('Mensagem: ${responseParcelamento.mensagemPrincipal}');

        final parcelamento = responseParcelamento.dadosParsed;
        if (parcelamento != null) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Valor total consolidado: ${parcelamento.valorTotalConsolidadoFormatado}');
          print('  Quantidade de parcelas: ${parcelamento.quantidadeParcelas}');
          print('  Parcela básica: ${parcelamento.parcelaBasicaFormatada}');

          // Consolidação original
          if (parcelamento.consolidacaoOriginal != null) {
            final consolidacao = parcelamento.consolidacaoOriginal!;
            print('  Consolidação original:');
            print('    Data: ${consolidacao.dataConsolidacaoFormatada}');
            print('    Primeira parcela: ${consolidacao.primeiraParcelaFormatada}');
            print('    Detalhes: ${consolidacao.detalhesConsolidacao.length} itens');
          }

          // Alterações de dívida
          if (parcelamento.alteracoesDivida.isNotEmpty) {
            print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
            for (final alteracao in parcelamento.alteracoesDivida) {
              print('    Data: ${alteracao.dataAlteracaoDividaFormatada}');
              print('    Parcelas remanescentes: ${alteracao.parcelasRemanescentes}');
              print('    Valor: ${alteracao.valorTotalConsolidadoFormatado}');
            }
          }

          // Demonstrativo de pagamentos
          if (parcelamento.demonstrativoPagamentos.isNotEmpty) {
            print('  Pagamentos realizados: ${parcelamento.demonstrativoPagamentos.length}');
            for (final pagamento in parcelamento.demonstrativoPagamentos.take(3)) {
              print('    ${pagamento.mesDaParcelaFormatado}: ${pagamento.valorPagoFormatado}');
            }
            if (parcelamento.demonstrativoPagamentos.length > 3) {
              print('    ... e mais ${parcelamento.demonstrativoPagamentos.length - 3} pagamentos');
            }
          }
        }
      } else {
        print('Erro: ${responseParcelamento.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta do parcelamento: $e');
    }

    // 3. Consultar parcelas disponíveis para impressão
    print('\n3. Consultando parcelas disponíveis para impressão...');
    final responseParcelas = await parcmeiEspecialService.consultarParcelas();

    if (responseParcelas.sucesso) {
      print('Status: ${responseParcelas.status}');
      print('Mensagem: ${responseParcelas.mensagemPrincipal}');
      print('Tem parcelas: ${responseParcelas.temParcelas}');
      print('Quantidade de parcelas: ${responseParcelas.quantidadeParcelas}');
      print('Valor total: ${responseParcelas.valorTotalParcelasFormatado}');

      final parcelas = responseParcelas.dadosParsed?.listaParcelas ?? [];
      for (final parcela in parcelas.take(5)) {
        print('  Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
        print('    Descrição: ${parcela.descricao}');
        print('    Mês atual: ${parcela.isMesAtual}');
        print('    Mês futuro: ${parcela.isMesFuturo}');
      }
      if (parcelas.length > 5) {
        print('  ... e mais ${parcelas.length - 5} parcelas');
      }
    } else {
      print('Erro: ${responseParcelas.mensagemPrincipal}');
    }

    // 4. Consultar detalhes de pagamento
    print('\n4. Consultando detalhes de pagamento...');
    try {
      final responseDetalhes = await parcmeiEspecialService.consultarDetalhesPagamento(9001, 202111);

      if (responseDetalhes.sucesso) {
        print('Status: ${responseDetalhes.status}');
        print('Mensagem: ${responseDetalhes.mensagemPrincipal}');

        final detalhes = responseDetalhes.dadosParsed;
        if (detalhes != null) {
          print('Detalhes do pagamento:');
          print('  DAS: ${detalhes.numeroDas}');
          print('  Data de vencimento: ${detalhes.dataVencimentoFormatada}');
          print('  Período de apuração: ${detalhes.paDasGeradoFormatado}');
          print('  Gerado em: ${detalhes.geradoEm}');
          print('  Número do parcelamento: ${detalhes.numeroParcelamento}');
          print('  Número da parcela: ${detalhes.numeroParcela}');
          print('  Data limite para acolhimento: ${detalhes.dataLimiteAcolhimentoFormatada}');
          print('  Data de pagamento: ${detalhes.dataPagamentoFormatada}');
          print('  Banco/Agência: ${detalhes.bancoAgencia}');
          print('  Valor pago: ${detalhes.valorPagoArrecadacaoFormatado}');
          print('  Pago: ${detalhes.isPago}');
          print('  Dentro do prazo: ${detalhes.isDentroPrazoAcolhimento}');

          // Detalhes dos débitos pagos
          if (detalhes.pagamentoDebitos.isNotEmpty) {
            print('  Débitos pagos: ${detalhes.pagamentoDebitos.length}');
            for (final debito in detalhes.pagamentoDebitos) {
              print('    Período: ${debito.paDebitoFormatado}');
              print('    Processo: ${debito.processo}');
              print('    Valor total: ${debito.valorTotalFormatado}');

              for (final discriminacao in debito.discriminacoesDebito) {
                print('      ${discriminacao.tributo}:');
                print('        Principal: ${discriminacao.principalFormatado}');
                print('        Multa: ${discriminacao.multaFormatada}');
                print('        Juros: ${discriminacao.jurosFormatado}');
                print('        Total: ${discriminacao.totalFormatado}');
                print('        Ente federado: ${discriminacao.enteFederadoDestino}');
                print('        Tem multa: ${discriminacao.temMulta}');
                print('        Tem juros: ${discriminacao.temJuros}');
              }
            }
          }
        }
      } else {
        print('Erro: ${responseDetalhes.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta dos detalhes: $e');
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    try {
      final responseDas = await parcmeiEspecialService.emitirDas(202107);

      if (responseDas.sucesso) {
        print('Status: ${responseDas.status}');
        print('Mensagem: ${responseDas.mensagemPrincipal}');
        print('PDF gerado com sucesso: ${responseDas.pdfGeradoComSucesso}');
        print('Tem PDF disponível: ${responseDas.temPdfDisponivel}');
        print('PDF válido: ${responseDas.pdfValido}');
        print('Tamanho do PDF: ${responseDas.tamanhoPdfFormatado}');

        final dadosDas = responseDas.dadosParsed;
        if (dadosDas != null) {
          print('Dados do DAS:');
          print('  Tem PDF: ${dadosDas.temPdf}');
          print('  Tamanho: ${dadosDas.tamanhoFormatado}');
          print('  Base64 válido: ${dadosDas.isBase64Valido}');
          print('  Nome sugerido: ${dadosDas.nomeArquivoSugerido}');
          print('  MIME type: ${dadosDas.mimeType}');
          print('  Extensão: ${dadosDas.extensao}');

          // Simular conversão para bytes
          final pdfBytes = dadosDas.pdfBytes;
          if (pdfBytes != null) {
            print('  PDF convertido para bytes: ${pdfBytes.length} bytes');
          }
        }
      } else {
        print('Erro: ${responseDas.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na emissão do DAS: $e');
    }

    // 6. Testando validações
    print('\n6. Testando validações...');

    // Validar número de parcelamento
    final validacaoParcelamento = parcmeiEspecialService.validarNumeroParcelamento(9001);
    print('Validação parcelamento 9001: $validacaoParcelamento');

    final validacaoParcelamentoInvalido = parcmeiEspecialService.validarNumeroParcelamento(-1);
    print('Validação parcelamento -1: $validacaoParcelamentoInvalido');

    // Validar ano/mês da parcela
    final validacaoAnoMes = parcmeiEspecialService.validarAnoMesParcela(202111);
    print('Validação ano/mês 202111: $validacaoAnoMes');

    final validacaoAnoMesInvalido = parcmeiEspecialService.validarAnoMesParcela(123);
    print('Validação ano/mês 123: $validacaoAnoMesInvalido');

    // Validar parcela para emissão
    final validacaoParcela = parcmeiEspecialService.validarParcelaParaEmitir(202107);
    print('Validação parcela 202107: $validacaoParcela');

    // Validar CNPJ
    final validacaoCnpj = parcmeiEspecialService.validarCnpjContribuinte('12345678000195');
    print('Validação CNPJ válido: $validacaoCnpj');

    final validacaoCnpjInvalido = parcmeiEspecialService.validarCnpjContribuinte('123');
    print('Validação CNPJ inválido: $validacaoCnpjInvalido');

    // Validar tipo de contribuinte
    final validacaoTipo = parcmeiEspecialService.validarTipoContribuinte(2);
    print('Validação tipo 2: $validacaoTipo');

    final validacaoTipoInvalido = parcmeiEspecialService.validarTipoContribuinte(1);
    print('Validação tipo 1: $validacaoTipoInvalido');

    // 7. Testando análise de erros
    print('\n7. Testando análise de erros...');

    // Verificar se erro é conhecido
    final erroConhecido = parcmeiEspecialService.isKnownError('[Sucesso-PARCMEI-ESP]');
    print('Erro conhecido: $erroConhecido');

    // Obter informações sobre erro
    final errorInfo = parcmeiEspecialService.getErrorInfo('[Sucesso-PARCMEI-ESP]');
    if (errorInfo != null) {
      print('Informações do erro:');
      print('  Código: ${errorInfo.codigo}');
      print('  Tipo: ${errorInfo.tipo}');
      print('  Categoria: ${errorInfo.categoria}');
      print('  Detalhes: ${errorInfo.detalhes}');
      print('  Solução: ${errorInfo.solucao}');
      print('  Crítico: ${errorInfo.isCritico}');
      print('  Validação: ${errorInfo.isValidacao}');
      print('  Aviso: ${errorInfo.isAviso}');
      print('  Sucesso: ${errorInfo.isSucesso}');
      print('  Requer ação: ${errorInfo.requerAcaoUsuario}');
      print('  Temporário: ${errorInfo.isTemporario}');
    }

    // Analisar erro
    final analysis = parcmeiEspecialService.analyzeError('[Sucesso-PARCMEI-ESP]', 'Requisição efetuada com sucesso.');
    print('Análise do erro:');
    print('  Código: ${analysis.codigo}');
    print('  Mensagem: ${analysis.mensagem}');
    print('  Tipo: ${analysis.tipo}');
    print('  Categoria: ${analysis.categoria}');
    print('  Solução: ${analysis.solucao}');
    print('  Detalhes: ${analysis.detalhes}');
    print('  Crítico: ${analysis.isCritico}');
    print('  Validação: ${analysis.isValidacao}');
    print('  Aviso: ${analysis.isAviso}');
    print('  Sucesso: ${analysis.isSucesso}');
    print('  Requer ação: ${analysis.requerAcaoUsuario}');
    print('  Temporário: ${analysis.isTemporario}');
    print('  Pode ser ignorado: ${analysis.podeSerIgnorado}');
    print('  Deve ser reportado: ${analysis.deveSerReportado}');
    print('  Prioridade: ${analysis.prioridade}');
    print('  Cor: ${analysis.cor}');
    print('  Ícone: ${analysis.icone}');

    // Obter listas de erros
    final avisos = parcmeiEspecialService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');

    final errosEntrada = parcmeiEspecialService.getEntradasIncorretas();
    print('Erros de entrada incorreta: ${errosEntrada.length}');

    final erros = parcmeiEspecialService.getErros();
    print('Erros gerais: ${erros.length}');

    final sucessos = parcmeiEspecialService.getSucessos();
    print('Sucessos: ${sucessos.length}');

    print('\n=== Exemplos PARCMEI-ESP Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos PARCMEI-ESP: $e');
  }
}

Future<void> exemplosParcsn(ApiClient apiClient) async {
  print('=== Exemplos PARCSN ===');

  final parcsnService = ParcsnService(apiClient);

  try {
    // 1. Consultar pedidos de parcelamento
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await parcsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('Status: ${pedidosResponse.status}');
      print('Mensagem: ${pedidosResponse.mensagemPrincipal}');

      if (pedidosResponse.temParcelamentos) {
        final parcelamentos = pedidosResponse.dadosParsed!.parcelamentos;
        print('Quantidade de parcelamentos: ${parcelamentos.length}');

        for (final parcelamento in parcelamentos) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
          print('  Ativo: ${parcelamento.isAtivo}');
        }
      } else {
        print('Nenhum parcelamento encontrado');
      }
    } else {
      print('Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }

    // 2. Consultar parcelamento específico
    print('\n2. Consultando parcelamento específico...');
    try {
      final parcelamentoResponse = await parcsnService.consultarParcelamento(1);

      if (parcelamentoResponse.sucesso) {
        print('Status: ${parcelamentoResponse.status}');
        print('Mensagem: ${parcelamentoResponse.mensagemPrincipal}');

        final parcelamento = parcelamentoResponse.dadosParsed;
        if (parcelamento != null) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
          print('  Consolidações originais: ${parcelamento.consolidacoesOriginais.length}');
          print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
          print('  Demonstrativos de pagamento: ${parcelamento.demonstrativosPagamento.length}');
        }
      } else {
        print('Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta de parcelamento: $e');
    }

    // 3. Consultar parcelas disponíveis para impressão
    print('\n3. Consultando parcelas disponíveis para impressão...');
    final parcelasResponse = await parcsnService.consultarParcelas();

    if (parcelasResponse.sucesso) {
      print('Status: ${parcelasResponse.status}');
      print('Mensagem: ${parcelasResponse.mensagemPrincipal}');

      if (parcelasResponse.temParcelas) {
        final parcelas = parcelasResponse.dadosParsed!.listaParcelas;
        print('Quantidade de parcelas: ${parcelas.length}');
        print('Valor total: ${parcelasResponse.valorTotalParcelasFormatado}');

        for (final parcela in parcelas) {
          print('Parcela ${parcela.parcelaFormatada}:');
          print('  Valor: ${parcela.valorFormatado}');
          print('  Vencimento: ${parcela.dataVencimentoFormatada}');
          print('  Situação: ${parcela.situacao}');
          print('  Vencida: ${parcela.isVencida}');
          print('  Dias de atraso: ${parcela.diasAtraso}');
        }
      } else {
        print('Nenhuma parcela disponível para impressão');
      }
    } else {
      print('Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
    }

    // 4. Consultar detalhes de pagamento
    print('\n4. Consultando detalhes de pagamento...');
    try {
      final detalhesResponse = await parcsnService.consultarDetalhesPagamento(1, 201612);

      if (detalhesResponse.sucesso) {
        print('Status: ${detalhesResponse.status}');
        print('Mensagem: ${detalhesResponse.mensagemPrincipal}');

        final detalhes = detalhesResponse.dadosParsed;
        if (detalhes != null) {
          print('DAS: ${detalhes.numeroDas}');
          print('Código de barras: ${detalhes.codigoBarras}');
          print('Valor pago: ${detalhes.valorPagoArrecadacaoFormatado}');
          print('Data de pagamento: ${detalhes.dataPagamentoFormatada}');
          print('Débitos pagos: ${detalhes.quantidadeDebitosPagos}');

          for (final debito in detalhes.pagamentosDebitos) {
            print('Débito ${debito.competencia}:');
            print('  Tipo: ${debito.tipoDebito}');
            print('  Valor total: ${debito.valorTotalFormatado}');
            print('  Valor principal: ${debito.valorPrincipalFormatado}');
            print('  Multa: ${debito.valorMultaFormatado}');
            print('  Juros: ${debito.valorJurosFormatado}');
            print('  Discriminações: ${debito.discriminacoes.length}');
          }
        }
      } else {
        print('Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta de detalhes: $e');
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    try {
      final dasResponse = await parcsnService.emitirDas(202306);

      if (dasResponse.sucesso) {
        print('Status: ${dasResponse.status}');
        print('Mensagem: ${dasResponse.mensagemPrincipal}');

        if (dasResponse.pdfGeradoComSucesso) {
          final dasData = dasResponse.dadosParsed;
          if (dasData != null) {
            print('DAS emitido com sucesso!');
            print('Número do DAS: ${dasData.numeroDas}');
            print('Código de barras: ${dasData.codigoBarras}');
            print('Valor: ${dasData.valorFormatado}');
            print('Vencimento: ${dasData.dataVencimentoFormatada}');
            print('Tamanho do PDF: ${dasData.tamanhoPdfFormatado}');
            print('PDF disponível: ${dasData.temPdf}');
          }
        } else {
          print('PDF não foi gerado');
        }
      } else {
        print('Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na emissão do DAS: $e');
    }

    // 6. Exemplos de validações
    print('\n6. Testando validações...');

    // Validar número de parcelamento
    final validacaoParcelamento = parcsnService.validarNumeroParcelamento(0);
    if (validacaoParcelamento != null) {
      print('Validação parcelamento (0): $validacaoParcelamento');
    }

    // Validar ano/mês
    final validacaoAnoMes = parcsnService.validarAnoMesParcela(202313);
    if (validacaoAnoMes != null) {
      print('Validação ano/mês (202313): $validacaoAnoMes');
    }

    // Validar CNPJ
    final validacaoCnpj = parcsnService.validarCnpjContribuinte('12345678901234');
    if (validacaoCnpj != null) {
      print('Validação CNPJ (12345678901234): $validacaoCnpj');
    }

    // Validar tipo de contribuinte
    final validacaoTipo = parcsnService.validarTipoContribuinte(1);
    if (validacaoTipo != null) {
      print('Validação tipo (1): $validacaoTipo');
    }

    // 7. Exemplos de tratamento de erros
    print('\n7. Testando tratamento de erros...');

    // Verificar se erro é conhecido
    final erroConhecido = parcsnService.isKnownError('[Sucesso-PARCSN]');
    print('Erro conhecido ([Sucesso-PARCSN]): $erroConhecido');

    // Obter informações sobre erro
    final errorInfo = parcsnService.getErrorInfo('[Sucesso-PARCSN]');
    if (errorInfo != null) {
      print('Informações do erro:');
      print('  Código: ${errorInfo.codigo}');
      print('  Tipo: ${errorInfo.tipo}');
      print('  Categoria: ${errorInfo.categoria}');
      print('  Descrição: ${errorInfo.descricao}');
      print('  Solução: ${errorInfo.solucao}');
    }

    // Analisar erro
    final analysis = parcsnService.analyzeError('[Sucesso-PARCSN]', 'Requisição efetuada com sucesso.');
    print('Análise do erro:');
    print('  Código: ${analysis.codigo}');
    print('  Tipo: ${analysis.tipo}');
    print('  Categoria: ${analysis.categoria}');
    print('  Conhecido: ${analysis.isConhecido}');
    print('  É sucesso: ${analysis.isSucesso}');

    // Obter listas de erros
    final avisos = parcsnService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');

    final errosEntrada = parcsnService.getEntradasIncorretas();
    print('Erros de entrada incorreta: ${errosEntrada.length}');

    final erros = parcsnService.getErros();
    print('Erros gerais: ${erros.length}');

    final sucessos = parcsnService.getSucessos();
    print('Sucessos: ${sucessos.length}');

    print('\n=== Exemplos PARCSN Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos PARCSN: $e');
  }
}

Future<void> exemplosEventosAtualizacao(ApiClient apiClient) async {
  print('\n=== Exemplos Eventos de Atualização ===');

  try {
    final eventosService = EventosAtualizacaoService(apiClient);

    // Exemplo 1: Solicitar eventos de Pessoa Física (DCTFWeb)
    print('\n--- Exemplo 1: Solicitar Eventos PF (DCTFWeb) ---');
    final cpfsExemplo = ['00000000000', '11111111111', '22222222222'];

    final solicitacaoPF = await eventosService.solicitarEventosPF(cpfs: cpfsExemplo, evento: TipoEvento.dctfWeb);

    print('Status: ${solicitacaoPF.status}');
    print('Protocolo: ${solicitacaoPF.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPF.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPF.dados.tempoLimiteEmMin}min');

    for (final mensagem in solicitacaoPF.mensagens) {
      print('Mensagem: ${mensagem.codigo} - ${mensagem.texto}');
    }

    // Exemplo 2: Obter eventos de Pessoa Física usando protocolo
    print('\n--- Exemplo 2: Obter Eventos PF ---');
    await Future.delayed(Duration(milliseconds: solicitacaoPF.dados.tempoEsperaMedioEmMs));

    final eventosPF = await eventosService.obterEventosPF(protocolo: solicitacaoPF.dados.protocolo, evento: TipoEvento.dctfWeb);

    print('Status: ${eventosPF.status}');
    print('Total de eventos: ${eventosPF.dados.length}');

    for (final evento in eventosPF.dados) {
      if (evento.temAtualizacao) {
        print('CPF ${evento.cpf}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CPF ${evento.cpf}: Sem atualizações');
      } else {
        print('CPF ${evento.cpf}: Sem dados');
      }
    }

    // Exemplo 3: Solicitar eventos de Pessoa Jurídica (CaixaPostal)
    print('\n--- Exemplo 3: Solicitar Eventos PJ (CaixaPostal) ---');
    final cnpjsExemplo = ['00000000000000', '11111111111111', '22222222222222'];

    final solicitacaoPJ = await eventosService.solicitarEventosPJ(cnpjs: cnpjsExemplo, evento: TipoEvento.caixaPostal);

    print('Status: ${solicitacaoPJ.status}');
    print('Protocolo: ${solicitacaoPJ.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPJ.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPJ.dados.tempoLimiteEmMin}min');

    // Exemplo 4: Método de conveniência - Solicitar e obter eventos PF automaticamente
    print('\n--- Exemplo 4: Método de Conveniência PF ---');
    final eventosPFConveniencia = await eventosService.solicitarEObterEventosPF(
      cpfs: ['33333333333', '44444444444'],
      evento: TipoEvento.pagamentoWeb,
    );

    print('Status: ${eventosPFConveniencia.status}');
    print('Total de eventos: ${eventosPFConveniencia.dados.length}');

    for (final evento in eventosPFConveniencia.dados) {
      if (evento.temAtualizacao) {
        print('CPF ${evento.cpf}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CPF ${evento.cpf}: Sem atualizações');
      } else {
        print('CPF ${evento.cpf}: Sem dados');
      }
    }

    // Exemplo 5: Método de conveniência - Solicitar e obter eventos PJ automaticamente
    print('\n--- Exemplo 5: Método de Conveniência PJ ---');
    final eventosPJConveniencia = await eventosService.solicitarEObterEventosPJ(
      cnpjs: ['33333333333333', '44444444444444'],
      evento: TipoEvento.dctfWeb,
    );

    print('Status: ${eventosPJConveniencia.status}');
    print('Total de eventos: ${eventosPJConveniencia.dados.length}');

    for (final evento in eventosPJConveniencia.dados) {
      if (evento.temAtualizacao) {
        print('CNPJ ${evento.cnpj}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CNPJ ${evento.cnpj}: Sem atualizações');
      } else {
        print('CNPJ ${evento.cnpj}: Sem dados');
      }
    }

    // Exemplo 6: Demonstração dos tipos de eventos disponíveis
    print('\n--- Exemplo 6: Tipos de Eventos Disponíveis ---');
    for (final tipo in TipoEvento.values) {
      print('Evento ${tipo.codigo}: ${tipo.sistema}');
    }

    // Exemplo 7: Demonstração dos tipos de contribuinte
    print('\n--- Exemplo 7: Tipos de Contribuinte ---');
    for (final tipo in TipoContribuinte.values) {
      print('Tipo ${tipo.codigo}: ${tipo.descricao}');
    }

    // Exemplo 8: Validação de limites
    print('\n--- Exemplo 8: Informações sobre Limites ---');
    print('Máximo de contribuintes por lote: ${EventosAtualizacaoCommon.maxContribuintesPorLote}');
    print('Máximo de requisições por dia: ${EventosAtualizacaoCommon.maxRequisicoesPorDia}');
    print(
      'Eventos disponíveis: ${EventosAtualizacaoCommon.eventoDCTFWeb}, ${EventosAtualizacaoCommon.eventoCaixaPostal}, ${EventosAtualizacaoCommon.eventoPagamentoWeb}',
    );

    print('\n=== Exemplos Eventos de Atualização Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos de Eventos de Atualização: $e');
  }
}

Future<void> exemplosParcsnEspecial(ApiClient apiClient) async {
  print('=== Exemplos PARCSN-ESP (Parcelamento Especial do Simples Nacional) ===');

  final parcsnEspecialService = ParcsnEspecialService(apiClient);

  try {
    print('\n--- 1. Consultar Pedidos de Parcelamento Especial ---');
    final consultarPedidosResponse = await parcsnEspecialService.consultarPedidos();
    print('Status: ${consultarPedidosResponse.status}');
    print('Mensagens: ${consultarPedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${consultarPedidosResponse.sucesso}');
    print('Quantidade de parcelamentos: ${consultarPedidosResponse.quantidadeParcelamentos}');

    if (consultarPedidosResponse.temParcelamentos) {
      final parcelamentos = consultarPedidosResponse.dadosParsed?.parcelamentos ?? [];
      for (var parcelamento in parcelamentos) {
        print('  - Parcelamento ${parcelamento.numero}: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('    Ativo: ${parcelamento.isAtivo}');
      }
    }

    print('\n--- 2. Consultar Parcelamento Específico ---');
    final consultarParcelamentoResponse = await parcsnEspecialService.consultarParcelamento(9001);
    print('Status: ${consultarParcelamentoResponse.status}');
    print('Mensagens: ${consultarParcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${consultarParcelamentoResponse.sucesso}');

    if (consultarParcelamentoResponse.temDadosParcelamento) {
      final parcelamento = consultarParcelamentoResponse.dadosParsed;
      print('Número: ${parcelamento?.numero}');
      print('Situação: ${parcelamento?.situacao}');
      print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
      print('Data da situação: ${parcelamento?.dataDaSituacaoFormatada}');

      if (parcelamento?.consolidacaoOriginal != null) {
        final consolidacao = parcelamento!.consolidacaoOriginal!;
        print('Consolidação Original:');
        print('  Valor total: ${consolidacao.valorTotalConsolidadoFormatado}');
        print('  Quantidade de parcelas: ${consolidacao.quantidadeParcelas}');
        print('  Primeira parcela: ${consolidacao.primeiraParcelaFormatada}');
        print('  Parcela básica: ${consolidacao.parcelaBasicaFormatada}');
        print('  Data da consolidação: ${consolidacao.dataConsolidacaoFormatada}');
        print('  Detalhes: ${consolidacao.detalhesConsolidacao.length} item(s)');
      }

      print('Alterações de dívida: ${parcelamento?.alteracoesDivida.length ?? 0}');
      print('Demonstrativo de pagamentos: ${parcelamento?.demonstrativoPagamentos.length ?? 0}');
    }

    print('\n--- 3. Consultar Detalhes de Pagamento ---');
    final consultarDetalhesResponse = await parcsnEspecialService.consultarDetalhesPagamento(9001, 201612);
    print('Status: ${consultarDetalhesResponse.status}');
    print('Mensagens: ${consultarDetalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${consultarDetalhesResponse.sucesso}');

    if (consultarDetalhesResponse.temDadosPagamento) {
      final detalhes = consultarDetalhesResponse.dadosParsed;
      print('Número do DAS: ${detalhes?.numeroDas}');
      print('Data de vencimento: ${detalhes?.dataVencimentoFormatada}');
      print('Período de apuração: ${detalhes?.paDasGeradoFormatado}');
      print('Gerado em: ${detalhes?.geradoEm}');
      print('Número do parcelamento: ${detalhes?.numeroParcelamento}');
      print('Número da parcela: ${detalhes?.numeroParcela}');
      print('Data limite para acolhimento: ${detalhes?.dataLimiteAcolhimentoFormatada}');
      print('Data do pagamento: ${detalhes?.dataPagamentoFormatada}');
      print('Banco/Agência: ${detalhes?.bancoAgencia}');
      print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
      print('Pago: ${detalhes?.isPago}');

      print('Pagamento de débitos: ${detalhes?.pagamentoDebitos.length ?? 0}');
      for (var pagamento in detalhes?.pagamentoDebitos ?? []) {
        print('  - Período: ${pagamento.paDebitoFormatado}');
        print('    Processo: ${pagamento.processo}');
        print('    Valor total: ${pagamento.valorTotalDebitosFormatado}');
        print('    Discriminações: ${pagamento.discriminacoesDebito.length}');

        for (var discriminacao in pagamento.discriminacoesDebito) {
          print('      * ${discriminacao.tributo}: ${discriminacao.totalFormatado}');
          print('        Principal: ${discriminacao.principalFormatado}');
          print('        Multa: ${discriminacao.multaFormatada}');
          print('        Juros: ${discriminacao.jurosFormatados}');
          print('        Destino: ${discriminacao.enteFederadoDestino}');
        }
      }
    }

    print('\n--- 4. Consultar Parcelas para Impressão ---');
    final consultarParcelasResponse = await parcsnEspecialService.consultarParcelas();
    print('Status: ${consultarParcelasResponse.status}');
    print('Mensagens: ${consultarParcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${consultarParcelasResponse.sucesso}');
    print('Quantidade de parcelas: ${consultarParcelasResponse.quantidadeParcelas}');
    print('Valor total das parcelas: ${consultarParcelasResponse.valorTotalParcelasFormatado}');

    if (consultarParcelasResponse.temParcelas) {
      final parcelas = consultarParcelasResponse.dadosParsed?.listaParcelas ?? [];
      for (var parcela in parcelas) {
        print('  - Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
        print('    Ano: ${parcela.ano}, Mês: ${parcela.mes}');
        print('    Mês atual: ${parcela.isMesAtual}');
        print('    Mês futuro: ${parcela.isMesFuturo}');
        print('    Mês passado: ${parcela.isMesPassado}');
      }
    }

    print('\n--- 5. Emitir DAS ---');
    final emitirDasResponse = await parcsnEspecialService.emitirDas(202306);
    print('Status: ${emitirDasResponse.status}');
    print('Mensagens: ${emitirDasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${emitirDasResponse.sucesso}');
    print('PDF gerado com sucesso: ${emitirDasResponse.pdfGeradoComSucesso}');
    print('Tamanho do PDF: ${emitirDasResponse.tamanhoPdfFormatado}');

    if (emitirDasResponse.pdfGeradoComSucesso) {
      final pdfBytes = emitirDasResponse.pdfBytes;
      print('PDF em bytes: ${pdfBytes?.length ?? 0} bytes');
      print('PDF válido: ${pdfBytes != null}');
    }

    print('\n--- 6. Validações ---');
    print('Validação número parcelamento (9001): ${parcsnEspecialService.validarNumeroParcelamento(9001)}');
    print('Validação número parcelamento (null): ${parcsnEspecialService.validarNumeroParcelamento(null)}');
    print('Validação ano/mês parcela (202306): ${parcsnEspecialService.validarAnoMesParcela(202306)}');
    print('Validação ano/mês parcela (202313): ${parcsnEspecialService.validarAnoMesParcela(202313)}');
    print('Validação parcela para emitir (202306): ${parcsnEspecialService.validarParcelaParaEmitir(202306)}');
    print('Validação CNPJ (00000000000000): ${parcsnEspecialService.validarCnpjContribuinte('00000000000000')}');
    print('Validação tipo contribuinte (2): ${parcsnEspecialService.validarTipoContribuinte(2)}');
    print('Validação tipo contribuinte (1): ${parcsnEspecialService.validarTipoContribuinte(1)}');

    print('\n--- 7. Análise de Erros ---');
    final avisos = parcsnEspecialService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');
    for (var aviso in avisos.take(3)) {
      print('  - ${aviso.codigo}: ${aviso.descricao}');
    }

    final entradasIncorretas = parcsnEspecialService.getEntradasIncorretas();
    print('Entradas incorretas disponíveis: ${entradasIncorretas.length}');
    for (var entrada in entradasIncorretas.take(3)) {
      print('  - ${entrada.codigo}: ${entrada.descricao}');
    }

    final erros = parcsnEspecialService.getErros();
    print('Erros disponíveis: ${erros.length}');
    for (var erro in erros.take(3)) {
      print('  - ${erro.codigo}: ${erro.descricao}');
    }

    final sucessos = parcsnEspecialService.getSucessos();
    print('Sucessos disponíveis: ${sucessos.length}');
    for (var sucesso in sucessos.take(3)) {
      print('  - ${sucesso.codigo}: ${sucesso.descricao}');
    }

    // Exemplo de análise de erro
    final analiseErro = parcsnEspecialService.analyzeError('[Aviso-PARCSN-ESP-ER_E001]', 'Não há parcelamento ativo para o contribuinte.');
    print('Análise de erro:');
    print('  Código: ${analiseErro.codigo}');
    print('  Tipo: ${analiseErro.tipo}');
    print('  Categoria: ${analiseErro.categoria}');
    print('  Conhecido: ${analiseErro.isConhecido}');
    print('  Crítico: ${analiseErro.isCritico}');
    print('  Permite retry: ${analiseErro.permiteRetry}');
    print('  Ação recomendada: ${analiseErro.acaoRecomendada}');

    print('\n=== Exemplos PARCSN-ESP Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos do PARCSN-ESP: $e');
  }
}

Future<void> exemplosParcmei(ApiClient apiClient) async {
  print('\n=== Exemplos PARCMEI ===');

  final parcmeiService = ParcmeiService(apiClient);

  try {
    print('\n--- 1. Consultar Pedidos de Parcelamento ---');
    final pedidosResponse = await parcmeiService.consultarPedidos();
    print('Status: ${pedidosResponse.status}');
    print('Mensagens: ${pedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${pedidosResponse.sucesso}');
    print('Mensagem principal: ${pedidosResponse.mensagemPrincipal}');
    print('Tem parcelamentos: ${pedidosResponse.temParcelamentos}');
    print('Quantidade de parcelamentos: ${pedidosResponse.quantidadeParcelamentos}');

    if (pedidosResponse.sucesso && pedidosResponse.temParcelamentos) {
      final parcelamentos = pedidosResponse.dadosParsed?.parcelamentos ?? [];
      print('Parcelamentos encontrados:');
      for (var parcelamento in parcelamentos.take(3)) {
        print('  - Número: ${parcelamento.numero}');
        print('    Situação: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('    Ativo: ${parcelamento.isAtivo}');
        print('    Encerrado: ${parcelamento.isEncerrado}');
        print('');
      }

      print('Parcelamentos ativos: ${pedidosResponse.parcelamentosAtivos.length}');
      print('Parcelamentos encerrados: ${pedidosResponse.parcelamentosEncerrados.length}');
    }

    print('\n--- 2. Consultar Parcelamento Específico ---');
    final parcelamentoResponse = await parcmeiService.consultarParcelamento(1);
    print('Status: ${parcelamentoResponse.status}');
    print('Mensagens: ${parcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${parcelamentoResponse.sucesso}');
    print('Mensagem principal: ${parcelamentoResponse.mensagemPrincipal}');

    if (parcelamentoResponse.sucesso) {
      final parcelamento = parcelamentoResponse.dadosParsed;
      if (parcelamento != null) {
        print('Parcelamento detalhado:');
        print('  Número: ${parcelamento.numero}');
        print('  Situação: ${parcelamento.situacao}');
        print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('  Ativo: ${parcelamento.isAtivo}');
        print('  Tem alterações de dívida: ${parcelamento.temAlteracoesDivida}');
        print('  Tem pagamentos: ${parcelamento.temPagamentos}');

        if (parcelamento.consolidacaoOriginal != null) {
          final consolidacao = parcelamento.consolidacaoOriginal!;
          print('  Consolidação original:');
          print('    Valor total: ${parcelamentoResponse.valorTotalConsolidadoFormatado}');
          print('    Quantidade de parcelas: ${parcelamentoResponse.quantidadeParcelas}');
          print('    Parcela básica: ${parcelamentoResponse.parcelaBasicaFormatada}');
          print('    Data de consolidação: ${consolidacao.dataConsolidacaoFormatada}');
          print('    Detalhes de consolidação: ${consolidacao.detalhesConsolidacao.length}');
        }

        print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
        print('  Demonstrativo de pagamentos: ${parcelamento.demonstrativoPagamentos.length}');
        print('  Quantidade de pagamentos: ${parcelamentoResponse.quantidadePagamentos}');
        print('  Valor total pago: ${parcelamentoResponse.valorTotalPagoFormatado}');
      }
    }

    print('\n--- 3. Consultar Parcelas Disponíveis ---');
    final parcelasResponse = await parcmeiService.consultarParcelas();
    print('Status: ${parcelasResponse.status}');
    print('Mensagens: ${parcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${parcelasResponse.sucesso}');
    print('Mensagem principal: ${parcelasResponse.mensagemPrincipal}');
    print('Tem parcelas: ${parcelasResponse.temParcelas}');
    print('Quantidade de parcelas: ${parcelasResponse.quantidadeParcelas}');

    if (parcelasResponse.sucesso && parcelasResponse.temParcelas) {
      final parcelas = parcelasResponse.dadosParsed?.listaParcelas ?? [];
      print('Parcelas disponíveis:');
      for (var parcela in parcelas.take(5)) {
        print('  - Parcela: ${parcela.parcelaFormatada}');
        print('    Valor: ${parcela.valorFormatado}');
        print('    Ano: ${parcela.ano}');
        print('    Mês: ${parcela.nomeMes}');
        print('    Descrição: ${parcela.descricaoCompleta}');
        print('    Ano atual: ${parcela.isAnoAtual}');
        print('');
      }

      print('Valor total das parcelas: ${parcelasResponse.valorTotalParcelasFormatado}');
      print('Todas parcelas mesmo valor: ${parcelasResponse.todasParcelasMesmoValor}');

      final menorValor = parcelasResponse.parcelaMenorValor;
      final maiorValor = parcelasResponse.parcelaMaiorValor;
      if (menorValor != null) {
        print('Menor valor: ${menorValor.valorFormatado} (${menorValor.parcelaFormatada})');
      }
      if (maiorValor != null) {
        print('Maior valor: ${maiorValor.valorFormatado} (${maiorValor.parcelaFormatada})');
      }
    }

    print('\n--- 4. Consultar Detalhes de Pagamento ---');
    final detalhesResponse = await parcmeiService.consultarDetalhesPagamento(1, 202107);
    print('Status: ${detalhesResponse.status}');
    print('Mensagens: ${detalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${detalhesResponse.sucesso}');
    print('Mensagem principal: ${detalhesResponse.mensagemPrincipal}');

    if (detalhesResponse.sucesso) {
      final detalhes = detalhesResponse.dadosParsed;
      if (detalhes != null) {
        print('Detalhes de pagamento:');
        print('  Número do DAS: ${detalhes.numeroDas}');
        print('  Data de vencimento: ${detalhesResponse.dataVencimentoFormatada}');
        print('  Período DAS gerado: ${detalhesResponse.paDasGeradoFormatado}');
        print('  Gerado em: ${detalhes.geradoEmFormatado}');
        print('  Número do parcelamento: ${detalhes.numeroParcelamento}');
        print('  Número da parcela: ${detalhes.numeroParcela}');
        print('  Data limite acolhimento: ${detalhesResponse.dataLimiteAcolhimentoFormatada}');
        print('  Data de pagamento: ${detalhesResponse.dataPagamentoFormatada}');
        print('  Banco/Agência: ${detalhes.bancoAgencia}');
        print('  Valor pago: ${detalhesResponse.valorPagoArrecadacaoFormatado}');
        print('  Pagamento realizado: ${detalhesResponse.pagamentoRealizado}');
        print('  Pagamento em atraso: ${detalhesResponse.pagamentoEmAtraso}');
        print('  Quantidade de débitos: ${detalhesResponse.quantidadeDebitos}');

        print('  Débitos pagos:');
        for (var debito in detalhes.pagamentoDebitos.take(3)) {
          print('    Período: ${debito.paDebitoFormatado}');
          print('    Processo: ${debito.processo}');
          print('    Valor total: ${debito.valorTotalDebitoFormatado}');
          print('    Discriminações:');
          for (var disc in debito.discriminacoesDebito) {
            print('      - Tributo: ${disc.tributo}');
            print('        Principal: ${disc.principalFormatado}');
            print('        Multa: ${disc.multaFormatada}');
            print('        Juros: ${disc.jurosFormatados}');
            print('        Total: ${disc.totalFormatado}');
            print('        Ente federado: ${disc.enteFederadoDestino}');
            print('        Tem multa: ${disc.temMulta}');
            print('        Tem juros: ${disc.temJuros}');
            print('        % Multa: ${disc.percentualMulta.toStringAsFixed(2)}%');
            print('        % Juros: ${disc.percentualJuros.toStringAsFixed(2)}%');
          }
          print('');
        }

        print('Valor total dos débitos: ${detalhes.valorTotalDebitosFormatado}');
      }
    }

    print('\n--- 5. Emitir DAS ---');
    final emitirResponse = await parcmeiService.emitirDas(202107);
    print('Status: ${emitirResponse.status}');
    print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${emitirResponse.sucesso}');
    print('Mensagem principal: ${emitirResponse.mensagemPrincipal}');
    print('PDF gerado com sucesso: ${emitirResponse.pdfGeradoComSucesso}');

    if (emitirResponse.sucesso && emitirResponse.pdfGeradoComSucesso) {
      final dados = emitirResponse.dadosParsed;
      if (dados != null) {
        print('Dados do DAS:');
        print('  Tem PDF: ${dados.temPdf}');
        print('  Tamanho Base64: ${dados.tamanhoBase64} caracteres');
        print('  Tamanho estimado PDF: ${dados.tamanhoEstimadoPdf} bytes');
        print('  Base64 válido: ${dados.base64Valido}');
        print('  Parece PDF válido: ${dados.parecePdfValido}');
        print('  Preview Base64: ${dados.base64Preview}');
      }

      final pdfBytes = emitirResponse.pdfBytes;
      print('PDF bytes: ${pdfBytes != null ? 'Disponível' : 'Não disponível'}');
      print('Tamanho PDF: ${emitirResponse.tamanhoPdfFormatado}');
      print('PDF válido: ${emitirResponse.pdfValido}');
      print('Hash do PDF: ${emitirResponse.pdfHash}');

      final pdfInfo = emitirResponse.pdfInfo;
      if (pdfInfo != null) {
        print('Informações do PDF:');
        pdfInfo.forEach((key, value) {
          print('  $key: $value');
        });
      }
    }

    print('\n--- 6. Validações ---');
    print('Validação número parcelamento (1): ${parcmeiService.validarNumeroParcelamento(1)}');
    print('Validação número parcelamento (null): ${parcmeiService.validarNumeroParcelamento(null)}');
    print('Validação ano/mês parcela (202306): ${parcmeiService.validarAnoMesParcela(202306)}');
    print('Validação ano/mês parcela (202313): ${parcmeiService.validarAnoMesParcela(202313)}');
    print('Validação parcela para emitir (202306): ${parcmeiService.validarParcelaParaEmitir(202306)}');
    print('Validação prazo emissão (202306): ${parcmeiService.validarPrazoEmissaoParcela(202306)}');
    print('Validação CNPJ (00000000000000): ${parcmeiService.validarCnpjContribuinte('00000000000000')}');
    print('Validação tipo contribuinte (2): ${parcmeiService.validarTipoContribuinte(2)}');
    print('Validação tipo contribuinte (1): ${parcmeiService.validarTipoContribuinte(1)}');
    print('Validação parcela disponível (202306): ${parcmeiService.validarParcelaDisponivelParaEmissao(202306)}');
    print('Validação período apuração (202306): ${parcmeiService.validarPeriodoApuracao(202306)}');
    print('Validação data formato (20230615): ${parcmeiService.validarDataFormato(20230615)}');
    print('Validação valor monetário (100.50): ${parcmeiService.validarValorMonetario(100.50)}');
    print('Validação sistema (PARCMEI): ${parcmeiService.validarSistema('PARCMEI')}');
    print('Validação serviço (PEDIDOSPARC203): ${parcmeiService.validarServico('PEDIDOSPARC203')}');
    print('Validação versão sistema (1.0): ${parcmeiService.validarVersaoSistema('1.0')}');

    print('\n--- 7. Análise de Erros ---');
    final avisos = parcmeiService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');
    for (var aviso in avisos.take(3)) {
      print('  - ${aviso.codigo}: ${aviso.descricao}');
    }

    final entradasIncorretas = parcmeiService.getEntradasIncorretas();
    print('Entradas incorretas disponíveis: ${entradasIncorretas.length}');
    for (var entrada in entradasIncorretas.take(3)) {
      print('  - ${entrada.codigo}: ${entrada.descricao}');
    }

    final erros = parcmeiService.getErros();
    print('Erros disponíveis: ${erros.length}');
    for (var erro in erros.take(3)) {
      print('  - ${erro.codigo}: ${erro.descricao}');
    }

    final sucessos = parcmeiService.getSucessos();
    print('Sucessos disponíveis: ${sucessos.length}');
    for (var sucesso in sucessos.take(3)) {
      print('  - ${sucesso.codigo}: ${sucesso.descricao}');
    }

    // Exemplo de análise de erro
    final analiseErro = parcmeiService.analyzeError('[Sucesso-PARCMEI]', 'Requisição efetuada com sucesso.');
    print('Análise de erro:');
    print('  Código: ${analiseErro.codigo}');
    print('  Mensagem: ${analiseErro.mensagem}');
    print('  Categoria: ${analiseErro.categoria}');
    print('  Conhecido: ${analiseErro.isKnownError}');
    print('  Sucesso: ${analiseErro.isSucesso}');
    print('  Erro: ${analiseErro.isErro}');
    print('  Aviso: ${analiseErro.isAviso}');
    print('  Solução: ${analiseErro.solucao ?? 'N/A'}');

    print('\n=== Exemplos PARCMEI Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos do PARCMEI: $e');
  }
}
