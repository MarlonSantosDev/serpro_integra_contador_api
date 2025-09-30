import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> CaixaPostal(ApiClient apiClient) async {
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
