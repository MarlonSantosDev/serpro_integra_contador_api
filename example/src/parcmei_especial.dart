import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> ParcmeiEspecial(ApiClient apiClient) async {
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
