import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplos de uso do Serviço CAIXA POSTAL
///
/// Este arquivo demonstra o uso dos 3 serviços oficiais da API SERPRO:
/// 1. MSGCONTRIBUINTE61 - Obter Lista de Mensagens por Contribuintes
/// 2. MSGDETALHAMENTO62 - Obter Detalhes de uma Mensagem Específica
/// 3. INNOVAMSG63 - Obter Indicador de Novas Mensagens
Future<void> CaixaPostal(ApiClient apiClient) async {
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║       EXEMPLOS SERVIÇO CAIXA POSTAL - API SERPRO              ║');
  print('╚═══════════════════════════════════════════════════════════════╝\n');

  final caixaPostalService = CaixaPostalService(apiClient);
  bool servicoOk = true;

  // Dados de teste conforme documentação SERPRO
  const cpfTeste = '99999999999';
  const cnpjTeste = '99999999999999';
  const contratante = '00000000000000';
  const autorPedido = '00000000000000';

  // ========================================================================
  // SERVIÇO 1: INNOVAMSG63 - Obter Indicador de Novas Mensagens
  // ========================================================================
  print('┌────────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 1: INNOVAMSG63 - Indicador de Novas Mensagens          │');
  print('│ Endpoint: /Monitorar                                           │');
  print('└────────────────────────────────────────────────────────────────┘\n');

  try {
    print('📍 Requisição: obterIndicadorNovasMensagens()');
    print('   - Contribuinte: $cpfTeste');
    print('   - Contratante: $contratante');
    print('   - Autor do pedido: $autorPedido\n');

    final indicadorResponse = await caixaPostalService.obterIndicadorNovasMensagens(
      cpfTeste,
      contratanteNumero: contratante,
      autorPedidoDadosNumero: autorPedido,
    );

    print('📤 RESPOSTA HTTP:');
    print('   Status: ${indicadorResponse.status}\n');

    if (indicadorResponse.dadosParsed != null) {
      print('📊 DADOS PARSEADOS:');
      print('   Código: ${indicadorResponse.dadosParsed!.codigo}');

      if (indicadorResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = indicadorResponse.dadosParsed!.conteudo.first;

        print('\n📋 CONTEÚDO:');
        print('   ┌─────────────────────────────────────────────────────────┐');
        print('   │ Mensagens Novas: ${conteudo.indicadorMensagensNovas.padRight(20)}│');
        print('   │   • 0 = Sem mensagens novas                             │');
        print('   │   • 1 = Uma mensagem nova                               │');
        print('   │   • 2 = Múltiplas mensagens novas                       │');
        print('   ├─────────────────────────────────────────────────────────┤');
        print('   │ Status: ${conteudo.statusMensagensNovas.toString().padRight(45)}│');
        print('   │ Descrição: ${conteudo.descricaoStatus.padRight(42)}│');
        print('   │ Tem Mensagens Novas: ${conteudo.temMensagensNovas.toString().padRight(33)}│');
        print('   └─────────────────────────────────────────────────────────┘');
      }

      print('\n✅ Serviço INNOVAMSG63 executado com sucesso!\n');
    } else {
      print('⚠️  Não foi possível parsear os dados da resposta\n');
    }
  } catch (e) {
    print('❌ ERRO no serviço INNOVAMSG63: $e\n');
    servicoOk = false;
  }

  await Future.delayed(Duration(seconds: 3));

  // ========================================================================
  // SERVIÇO 2: MSGCONTRIBUINTE61 - Obter Lista de Mensagens por Contribuintes
  // ========================================================================
  print('\n┌─────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 2: MSGCONTRIBUINTE61 - Lista de Mensagens             │');
  print('│ Endpoint: /Consultar                                          │');
  print('└───────────────────────────────────────────────────────────────┘\n');

  dynamic listaMensagensResponse; // Guardar para usar no serviço 3

  try {
    print('📍 Requisição: obterListaMensagensPorContribuinte()');
    print('   - Contribuinte: $cnpjTeste');
    print('   - Status Leitura: 0 (todas as mensagens)');
    print('   - Indicador Favorito: null (sem filtro)');
    print('   - Indicador Página: 0 (página inicial)');
    print('   - Contratante: $cnpjTeste');
    print('   - Autor do pedido: $cnpjTeste\n');

    listaMensagensResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
      cnpjTeste,
      contratanteNumero: cnpjTeste,
      autorPedidoDadosNumero: cnpjTeste,
      statusLeitura: 0, // Todas as mensagens
      indicadorFavorito: null, // Sem filtro
      indicadorPagina: 0, // Página inicial
    );

    print('📤 RESPOSTA HTTP:');
    print('   Status: ${listaMensagensResponse.status}\n');

    if (listaMensagensResponse.dadosParsed != null && listaMensagensResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = listaMensagensResponse.dadosParsed!.conteudo.first;

      print('📊 DADOS PARSEADOS:');
      print('   Código: ${listaMensagensResponse.dadosParsed!.codigo}');

      print('\n📋 INFORMAÇÕES DA PÁGINA:');
      print('   ┌───────────────────────────────────────────────────────┐');
      print('   │ Quantidade de Mensagens: ${conteudo.quantidadeMensagensInt.toString().padRight(29)}│');
      print('   │ É Última Página: ${conteudo.isUltimaPagina.toString().padRight(37)}│');
      print('   │ Ponteiro Página Retornada: ${conteudo.ponteiroPaginaRetornada.padRight(27)}│');
      print('   │ Ponteiro Próxima Página: ${conteudo.ponteiroProximaPagina.padRight(29)}│');
      print('   │ CNPJ Matriz: ${(conteudo.cnpjMatriz ?? 'N/A').padRight(41)}│');
      print('   └───────────────────────────────────────────────────────┘');

      // Mostrar as primeiras 3 mensagens
      if (conteudo.listaMensagens.isNotEmpty) {
        print('\n📬 MENSAGENS (exibindo até 3 primeiras):');
        final mensagensParaExibir = conteudo.listaMensagens.take(3);

        for (var i = 0; i < mensagensParaExibir.length; i++) {
          final msg = mensagensParaExibir.elementAt(i);
          print('\n   ╔═════════════════════════════════════════════════════════╗');
          print('   ║ MENSAGEM ${(i + 1).toString().padRight(48)}║');
          print('   ╠═════════════════════════════════════════════════════════╣');
          print('   ║ ISN: ${msg.isn.padRight(51)}║');
          print('   ╟─────────────────────────────────────────────────────────╢');
          print('   ║ 📝 Assunto Original (assuntoModelo):                    ║');
          print('   ║    ${_truncate(msg.assuntoModelo, 51).padRight(51)}║');
          print('   ║ 🔄 Valor Parâmetro: ${msg.valorParametroAssunto.padRight(34)}║');
          print('   ║ ✨ Assunto Processado:                                  ║');
          print('   ║    ${_truncate(msg.assuntoProcessado, 51).padRight(51)}║');
          print('   ╟─────────────────────────────────────────────────────────╢');
          print('   ║ 📅 Data Envio: ${msg.dataEnvio.padRight(42)}║');
          print('   ║ ⏰ Hora Envio: ${msg.horaEnvio.padRight(42)}║');
          print('   ║ 👁️  Foi Lida: ${msg.foiLida.toString().padRight(44)}║');
          print('   ║ ⭐ É Favorita: ${msg.isFavorita.toString().padRight(41)}║');
          print('   ║ 📊 Relevância: ${msg.relevancia.padRight(42)}║');
          print('   ║ 📍 Origem: ${msg.descricaoOrigem.padRight(45)}║');
          print('   ║ 📆 Data Validade: ${msg.dataValidade.padRight(38)}║');
          print('   ╚═════════════════════════════════════════════════════════╝');
        }

        print('\n   Total de mensagens na resposta: ${conteudo.listaMensagens.length}');
      }

      print('\n✅ Serviço MSGCONTRIBUINTE61 executado com sucesso!\n');
    } else {
      print('⚠️  Não há mensagens para exibir\n');
    }
  } catch (e) {
    print('❌ ERRO no serviço MSGCONTRIBUINTE61: $e\n');
    servicoOk = false;
  }

  await Future.delayed(Duration(seconds: 3));

  // ========================================================================
  // SERVIÇO 2.1: Demonstração de Filtros - Apenas mensagens NÃO LIDAS
  // ========================================================================
  print('\n┌─────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 2.1: Exemplo com Filtro - Mensagens NÃO LIDAS         │');
  print('└───────────────────────────────────────────────────────────────┘\n');

  try {
    print('📍 Usando filtro statusLeitura=2 (não lidas)\n');

    final naoLidasResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
      cnpjTeste,
      contratanteNumero: cnpjTeste,
      autorPedidoDadosNumero: cnpjTeste,
      statusLeitura: 2, // Apenas não lidas
    );

    if (naoLidasResponse.dadosParsed != null && naoLidasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = naoLidasResponse.dadosParsed!.conteudo.first;
      print('   Mensagens não lidas encontradas: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print('❌ ERRO ao filtrar mensagens não lidas: $e');
  }

  await Future.delayed(Duration(seconds: 3));

  // ========================================================================
  // SERVIÇO 2.2: Demonstração de Filtros - Apenas mensagens FAVORITAS
  // ========================================================================
  print('\n┌─────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 2.2: Exemplo com Filtro - Mensagens FAVORITAS         │');
  print('└───────────────────────────────────────────────────────────────┘\n');

  try {
    print('📍 Usando filtro indicadorFavorito=1 (favoritas)\n');

    final favoritasResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
      cnpjTeste,
      contratanteNumero: cnpjTeste,
      autorPedidoDadosNumero: cnpjTeste,
      indicadorFavorito: 1, // Apenas favoritas
    );

    if (favoritasResponse.dadosParsed != null && favoritasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = favoritasResponse.dadosParsed!.conteudo.first;
      print('   Mensagens favoritas encontradas: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print('❌ ERRO ao filtrar mensagens favoritas: $e');
  }

  await Future.delayed(Duration(seconds: 3));

  // ========================================================================
  // SERVIÇO 2.3: Demonstração de Paginação
  // ========================================================================
  print('\n┌────────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 2.3: Exemplo de Paginação                             │');
  print('└────────────────────────────────────────────────────────────────┘\n');

  try {
    if (listaMensagensResponse?.dadosParsed != null &&
        listaMensagensResponse.dadosParsed!.conteudo.isNotEmpty &&
        !listaMensagensResponse.dadosParsed!.conteudo.first.isUltimaPagina) {
      print('📍 Carregando próxima página...');
      final proximaPagina = listaMensagensResponse.dadosParsed!.conteudo.first.ponteiroProximaPagina;
      print('   Ponteiro da próxima página: $proximaPagina\n');

      final paginaResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
        cnpjTeste,
        contratanteNumero: cnpjTeste,
        autorPedidoDadosNumero: cnpjTeste,
        indicadorPagina: 1, // Página não-inicial
        ponteiroPagina: proximaPagina,
      );

      if (paginaResponse.dadosParsed != null && paginaResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = paginaResponse.dadosParsed!.conteudo.first;
        print('   Mensagens da próxima página: ${conteudo.quantidadeMensagensInt}');
      }
    } else {
      print('⚠️  Não há próxima página disponível ou é a última página');
    }
  } catch (e) {
    print('❌ ERRO ao paginar: $e');
  }

  await Future.delayed(Duration(seconds: 3));

  // ========================================================================
  // SERVIÇO 3: MSGDETALHAMENTO62 - Obter Detalhes de uma Mensagem Específica
  // ========================================================================
  print('\n┌────────────────────────────────────────────────────────────────┐');
  print('│ SERVIÇO 3: MSGDETALHAMENTO62 - Detalhes de Mensagem           │');
  print('│ Endpoint: /Consultar                                           │');
  print('└────────────────────────────────────────────────────────────────┘\n');

  try {
    // Usar ISN da primeira mensagem da lista, se disponível
    if (listaMensagensResponse?.dadosParsed != null &&
        listaMensagensResponse.dadosParsed!.conteudo.isNotEmpty &&
        listaMensagensResponse.dadosParsed!.conteudo.first.listaMensagens.isNotEmpty) {
      final primeiraMsg = listaMensagensResponse.dadosParsed!.conteudo.first.listaMensagens.first;
      final isnExemplo = primeiraMsg.isn;

      print('📍 Requisição: obterDetalhesMensagemEspecifica()');
      print('   - Contribuinte: $contratante');
      print('   - ISN: $isnExemplo');
      print('   - Contratante: $contratante');
      print('   - Autor do pedido: $contratante\n');

      final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica(
        contratante,
        isnExemplo,
        contratanteNumero: contratante,
        autorPedidoDadosNumero: contratante,
      );

      print('📤 RESPOSTA HTTP:');
      print('   Status: ${detalhesResponse.status}\n');

      if (detalhesResponse.dadosParsed != null && detalhesResponse.dadosParsed!.conteudo.isNotEmpty) {
        final detalhe = detalhesResponse.dadosParsed!.conteudo.first;

        print('📊 DADOS PARSEADOS:');
        print('   Código: ${detalhesResponse.dadosParsed!.codigo}');

        print('\n📋 DETALHES COMPLETOS DA MENSAGEM:');
        print('   ╔═════════════════════════════════════════════════════════╗');
        print('   ║ IDENTIFICAÇÃO                                           ║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ Sistema Remetente: ${detalhe.codigoSistemaRemetente.padRight(35)}║');
        print('   ║ Código Modelo: ${detalhe.codigoModelo.padRight(41)}║');
        print('   ║ Origem Modelo: ${detalhe.origemModelo.padRight(41)}║');
        print('   ║ Tipo Origem: ${detalhe.tipoOrigem.padRight(43)}║');
        print('   ║ Descrição Origem: ${detalhe.descricaoOrigem.padRight(38)}║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ ASSUNTO                                                 ║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ 📝 Assunto Original (assuntoModelo):                    ║');
        print('   ║    ${_truncate(detalhe.assuntoModelo, 51).padRight(51)}║');
        print('   ║ 🔄 Valor Parâmetro: ${detalhe.valorParametroAssunto.padRight(34)}║');
        print('   ║ ✨ Assunto Processado:                                  ║');
        print('   ║    ${_truncate(detalhe.assuntoProcessado, 51).padRight(51)}║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ CORPO DA MENSAGEM                                       ║');
        print('   ╠═════════════════════════════════════════════════════════╣');

        // Mostrar variáveis se existirem
        if (detalhe.variaveis.isNotEmpty) {
          print('   ║ 🔧 Variáveis do Corpo:                                  ║');
          for (var i = 0; i < detalhe.variaveis.length; i++) {
            final varLabel = '++${i + 1}++';
            final varValue = detalhe.variaveis[i];
            print('   ║    $varLabel = ${_truncate(varValue, 45).padRight(45)}║');
          }
          print('   ╟─────────────────────────────────────────────────────────╢');
        }

        // Mostrar corpo processado (primeiros 200 caracteres)
        final corpoLimpo = _limparHtml(detalhe.corpoProcessado);
        print('   ║ 📄 Corpo Processado (primeiros 200 caracteres):         ║');
        final corpoLinhas = _quebrarEmLinhas(corpoLimpo, 51, 200);
        for (final linha in corpoLinhas) {
          print('   ║    ${linha.padRight(51)}║');
        }

        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ DATAS E STATUS                                          ║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ Data Envio: ${detalhe.dataEnvio.padRight(44)}║');
        print('   ║ Data Leitura: ${detalhe.dataLeitura.padRight(42)}║');
        print('   ║ Hora Leitura: ${detalhe.horaLeitura.padRight(42)}║');
        print('   ║ Data Expiração: ${detalhe.dataExpiracao.padRight(40)}║');
        print('   ║ Data Ciência: ${detalhe.dataCiencia.padRight(42)}║');
        print('   ║ É Favorita: ${detalhe.isFavorita.toString().padRight(44)}║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ OUTROS CAMPOS                                           ║');
        print('   ╠═════════════════════════════════════════════════════════╣');
        print('   ║ Número Controle: ${detalhe.numeroControle.padRight(39)}║');
        print('   ║ Enquadramento: ${detalhe.enquadramento.padRight(41)}║');
        print('   ║ Tipo Autenticação: ${detalhe.tipoAutenticacaoUsuario.padRight(35)}║');
        print('   ║ Código Acesso: ${detalhe.codigoAcesso.padRight(41)}║');
        print('   ║ Tipo Usuário: ${detalhe.tipoUsuario.padRight(42)}║');
        print('   ║ NI Usuário: ${detalhe.niUsuario.padRight(44)}║');
        print('   ║ Papel Usuário: ${detalhe.papelUsuario.padRight(41)}║');
        print('   ║ Código Aplicação: ${detalhe.codigoAplicacao.padRight(38)}║');
        print('   ╚═════════════════════════════════════════════════════════╝');

        print('\n✅ Serviço MSGDETALHAMENTO62 executado com sucesso!\n');
      } else {
        print('⚠️  Não foi possível obter os detalhes da mensagem\n');
      }
    } else {
      print('⚠️  Não há mensagens disponíveis para obter detalhes\n');
    }
  } catch (e) {
    print('❌ ERRO no serviço MSGDETALHAMENTO62: $e\n');
    servicoOk = false;
  }

  // ========================================================================
  // RESUMO FINAL
  // ========================================================================
  print('\n╔═══════════════════════════════════════════════════════════════╗');
  print('║                    RESUMO DA EXECUÇÃO                         ║');
  print('╠═══════════════════════════════════════════════════════════════╣');
  if (servicoOk) {
    print('║  ✅ TODOS OS SERVIÇOS EXECUTADOS COM SUCESSO                  ║');
  } else {
    print('║  ❌ HOUVE ERROS NA EXECUÇÃO DE UM OU MAIS SERVIÇOS            ║');
  }
  print('╠═══════════════════════════════════════════════════════════════╣');
  print('║  Serviços testados:                                           ║');
  print('║  1. INNOVAMSG63 - Indicador de Novas Mensagens                ║');
  print('║  2. MSGCONTRIBUINTE61 - Lista de Mensagens                    ║');
  print('║     2.1. Filtro por status de leitura                         ║');
  print('║     2.2. Filtro por mensagens favoritas                       ║');
  print('║     2.3. Paginação                                            ║');
  print('║  3. MSGDETALHAMENTO62 - Detalhes de Mensagem                  ║');
  print('╚═══════════════════════════════════════════════════════════════╝\n');
}

// ========================================================================
// FUNÇÕES AUXILIARES PARA FORMATAÇÃO
// ========================================================================

/// Trunca uma string para o tamanho máximo especificado
String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

/// Limpa HTML de uma string
String _limparHtml(String html) {
  return html
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
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Quebra texto em linhas respeitando o limite de caracteres
List<String> _quebrarEmLinhas(String text, int maxLength, int totalMaxLength) {
  final List<String> linhas = [];
  String textoRestante = text.substring(0, text.length < totalMaxLength ? text.length : totalMaxLength);

  while (textoRestante.isNotEmpty) {
    if (textoRestante.length <= maxLength) {
      linhas.add(textoRestante);
      break;
    }

    // Procurar último espaço antes do limite
    int breakIndex = maxLength;
    for (int i = maxLength - 1; i > 0; i--) {
      if (textoRestante[i] == ' ') {
        breakIndex = i;
        break;
      }
    }

    linhas.add(textoRestante.substring(0, breakIndex).trim());
    textoRestante = textoRestante.substring(breakIndex).trim();
  }

  // Adicionar "..." se o texto foi truncado
  if (text.length > totalMaxLength && linhas.isNotEmpty) {
    final ultimaLinha = linhas.last;
    linhas[linhas.length - 1] = ultimaLinha.length > 3 ? '${ultimaLinha.substring(0, ultimaLinha.length - 3)}...' : '$ultimaLinha...';
  }

  return linhas;
}
