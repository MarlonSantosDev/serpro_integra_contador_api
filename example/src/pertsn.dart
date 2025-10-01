import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Pertsn(ApiClient apiClient) async {
  print('=== Exemplos PERTSN ===');

  final pertsnService = PertsnService(apiClient);
  bool servicoOk = true;

  // 1. Consultar pedidos de parcelamento
  try {
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await pertsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('✅ Status: ${pedidosResponse.status}');
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
      print('❌ Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos de parcelamento: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 2. Consultar parcelamento específico (usando exemplo da documentação)
  try {
    print('\n2. Consultando parcelamento específico...');
    final parcelamentoResponse = await pertsnService.consultarParcelamento(9102);

    if (parcelamentoResponse.sucesso) {
      print('✅ Status: ${parcelamentoResponse.status}');
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
      print('❌ Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamento: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 3. Consultar parcelas para impressão
  try {
    print('\n3. Consultando parcelas para impressão...');
    final parcelasResponse = await pertsnService.consultarParcelas();

    if (parcelasResponse.sucesso) {
      print('✅ Status: ${parcelasResponse.status}');
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
      print('❌ Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 4. Consultar detalhes de pagamento
  try {
    print('\n4. Consultando detalhes de pagamento...');
    final detalhesResponse = await pertsnService.consultarDetalhesPagamento(9102, 201806);

    if (detalhesResponse.sucesso) {
      print('✅ Status: ${detalhesResponse.status}');
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
      print('❌ Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 5. Emitir DAS
  try {
    print('\n5. Emitindo DAS...');
    final dasResponse = await pertsnService.emitirDas(202301);

    if (dasResponse.sucesso) {
      print('✅ Status: ${dasResponse.status}');
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
      print('❌ Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // 6. Exemplos de validações
  try {
    print('\n6. Testando validações...');

    // Validar número de parcelamento
    final validacaoParcelamento = pertsnService.validarNumeroParcelamento(0);
    if (validacaoParcelamento != null) {
      print('✅ Validação parcelamento inválido: $validacaoParcelamento');
    }

    // Validar ano/mês da parcela
    final validacaoAnoMes = pertsnService.validarAnoMesParcela(202513); // Mês inválido
    if (validacaoAnoMes != null) {
      print('✅ Validação ano/mês inválido: $validacaoAnoMes');
    }

    // Validar parcela para emitir
    final validacaoParcela = pertsnService.validarParcelaParaEmitir(202501);
    if (validacaoParcela != null) {
      print('✅ Validação parcela futura: $validacaoParcela');
    }

    // Validar CNPJ
    final validacaoCnpj = pertsnService.validarCnpjContribuinte('123');
    if (validacaoCnpj != null) {
      print('✅ Validação CNPJ inválido: $validacaoCnpj');
    }

    // Validar tipo de contribuinte
    final validacaoTipo = pertsnService.validarTipoContribuinte(1); // Tipo inválido para PERTSN
    if (validacaoTipo != null) {
      print('✅ Validação tipo contribuinte: $validacaoTipo');
    }
  } catch (e) {
    print('❌ Erro nas validações: $e');
    servicoOk = false;
  }

  // 7. Exemplos de análise de erros
  try {
    print('\n7. Testando análise de erros...');

    // Verificar se erro é conhecido
    final erroConhecido = pertsnService.isKnownError('[Aviso-PERTSN-ER_E001]');
    print('✅ Erro conhecido: $erroConhecido');

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
  } catch (e) {
    print('❌ Erro na análise de erros: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PERTSN ===');
  if (servicoOk) {
    print('✅ Serviço PERTSN: OK');
  } else {
    print('❌ Serviço PERTSN: ERRO');
  }

  print('\n=== Exemplos PERTSN Concluídos ===');
}
