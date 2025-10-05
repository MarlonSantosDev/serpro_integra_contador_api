import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> CaixaPostal(ApiClient apiClient) async {
  print('=== Exemplos Caixa Postal ===');

  final caixaPostalService = CaixaPostalService(apiClient);
  bool servicoOk = true;

  // Declarar listaResponse no escopo principal para ser usado em outras seções
  dynamic listaResponse;

  // 1. Verificar se há mensagens novas
  try {
    print('\n--- Verificando mensagens novas ---');
    final temNovas = await caixaPostalService.temMensagensNovas(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );
    print('✅ Tem mensagens novas: $temNovas');
  } catch (e) {
    print('❌ Erro ao verificar mensagens novas: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
        print('  📅 Data envio: ${FormatadorUtils.formatDateFromString(msg.dataEnvio)}');
        print('  👁️ Foi lida: ${msg.foiLida}');
        print('  ⭐ É favorita: ${msg.isFavorita}');
        print('  📈 Relevância: ${msg.relevancia}');
        print('  📍 Origem: ${msg.descricaoOrigem}');
      }
    }
  } catch (e) {
    print("❌ Erro ao listar todas as mensagens: $e");
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
      print('✅ Mensagens não lidas: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print('❌ Erro ao listar mensagens não lidas: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
      print('✅ Mensagens lidas: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print("❌ Erro ao listar mensagens lidas: $e");
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
      print('✅ Mensagens favoritas: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print("❌ Erro ao listar mensagens favoritas: $e");
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
        print('✅ Detalhes da mensagem obtidos:');
        print('📝 Assunto processado: ${detalhe.assuntoProcessado}');
        print('📅 Data de envio: ${detalhe.dataEnvio}');
        print('⏰ Data de expiração: ${detalhe.dataExpiracao}');
        print('⭐ É favorita: ${detalhe.isFavorita}');

        // Corpo da mensagem processado
        final corpoProcessado = detalhe.corpoProcessado;
        final corpoLimpo = corpoProcessado
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&amp;', '&')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .replaceAll('&aacute;', 'á')
            .replaceAll('&eacute;', 'é')
            .replaceAll('&iacute;', 'í')
            .replaceAll('&oacute;', 'ó')
            .replaceAll('&uacute;', 'ú')
            .replaceAll('&atilde;', 'ã')
            .replaceAll('&otilde;', 'õ')
            .replaceAll('&ccedil;', 'ç')
            .replaceAll('&Aacute;', 'Á')
            .replaceAll('&Eacute;', 'É')
            .replaceAll('&Iacute;', 'Í')
            .replaceAll('&Oacute;', 'Ó')
            .replaceAll('&Uacute;', 'Ú')
            .replaceAll('&Atilde;', 'Ã')
            .replaceAll('&Otilde;', 'Õ')
            .replaceAll('&Ccedil;', 'Ç')
            .replaceAll('&ordm;', 'º')
            .trim();
        ;
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
    } else {
      print('⚠️ Nenhuma mensagem disponível para obter detalhes');
    }
  } catch (e) {
    print("❌ Erro ao obter detalhes da mensagem específica: $e");
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
        print('✅ Mensagens da próxima página: ${conteudo.quantidadeMensagensInt}');
      }
    } else {
      print('⚠️ Não há próxima página disponível');
    }
  } catch (e) {
    print("❌ Erro ao listar paginação: $e");
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

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
      print('✅ Mensagens com filtros específicos: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print("❌ Erro ao listar mensagens com filtros específicos: $e");
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO CAIXA POSTAL ===');
  if (servicoOk) {
    print('✅ Serviço CAIXA POSTAL: OK');
  } else {
    print('❌ Serviço CAIXA POSTAL: ERRO');
  }

  print('\n=== Exemplos Caixa Postal Concluídos ===');
}
