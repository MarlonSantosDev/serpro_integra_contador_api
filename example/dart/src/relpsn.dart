import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Relpsn(ApiClient apiClient) async {
  print('\n=== Exemplos RELPSN (Parcelamento do Simples Nacional) ===');

  final relpsnService = RelpsnService(apiClient);
  bool servicoOk = true;

  // 1. Consultar Pedidos de Parcelamento
  try {
    print('\n--- 1. Consultar Pedidos de Parcelamento ---');
    final pedidosResponse = await relpsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('✅ Pedidos consultados com sucesso');
      print('Status: ${pedidosResponse.status}');
      print('Mensagem: ${pedidosResponse.mensagemPrincipal}');

      final parcelamentos = pedidosResponse.dados?.parcelamentos ?? [];
      print('Total de parcelamentos: ${parcelamentos.length}');

      for (final parcelamento in parcelamentos) {
        print('  - Parcelamento ${parcelamento.numero}:');
        print('    Situação: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
      }
    } else {
      print('❌ Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 3));

  // 2. Consultar Parcelamento Específico
  try {
    print('\n--- 2. Consultar Parcelamento Específico ---');
    const numeroParcelamento = 9131; // Número de exemplo

    final parcelamentoResponse = await relpsnService.consultarParcelamento(numeroParcelamento);

    if (parcelamentoResponse.sucesso) {
      print('✅ Parcelamento consultado com sucesso');
      final parcelamento = parcelamentoResponse.dados;

      if (parcelamento != null) {
        print('Número: ${parcelamento.numero}');
        print('Situação: ${parcelamento.situacao}');
        print('Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('Data da situação: ${parcelamento.dataDaSituacaoFormatada}');

        // Consolidação original
        final consolidacao = parcelamento.consolidacaoOriginal;
        if (consolidacao != null) {
          print('Consolidação original:');
          print('  Valor total: R\$ ${consolidacao.valorTotalConsolidadoDeEntrada.toStringAsFixed(2)}');
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
          print('    Identificador: ${alteracao.identificadorConsolidacao}');
          print('      (Valor descritivo retornado diretamente)');
          print('      Possíveis valores:');
          print('        - "Consolidação do restante da dívida"');
          print('        - "Reconsolidação por alteração de débitos no sistema de cobrança"');
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
      print('❌ Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamento: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 3));

  // 3. Consultar Parcelas Disponíveis
  try {
    print('\n--- 3. Consultar Parcelas Disponíveis ---');

    final parcelasResponse = await relpsnService.consultarParcelasParaImpressao();

    if (parcelasResponse.sucesso) {
      print('✅ Parcelas consultadas com sucesso');
      final parcelas = parcelasResponse.dados?.listaParcelas ?? [];
      print('Total de parcelas: ${parcelas.length}');

      print('Parcelas ordenadas:');
      for (final parcela in parcelas) {
        print('  - ${parcela.descricaoCompleta}');
        print('    Vencida: ${parcela.isVencida ? 'Sim' : 'Não'}');
        print('    Dias até vencimento: ${parcela.diasAteVencimento}');
      }

      // Próxima parcela a vencer
      final proximaParcela = parcelasResponse.dados?.proximaParcela;
      if (proximaParcela != null) {
        print('Próxima parcela a vencer: ${proximaParcela.descricaoCompleta}');
      }
    } else {
      print('❌ Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 3));

  // 4. Consultar Detalhes de Pagamento
  try {
    print('\n--- 4. Consultar Detalhes de Pagamento ---');
    const numeroParcelamento = 9131; // Número de exemplo
    const anoMesParcela = 201806; // Janeiro de 2024

    final detalhesResponse = await relpsnService.consultarDetalhesPagamento(numeroParcelamento, anoMesParcela);

    if (detalhesResponse.sucesso) {
      print('✅ Detalhes de pagamento consultados com sucesso');
      final detalhes = detalhesResponse.dados;

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
      print('❌ Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 3));

  // 5. Emitir DAS
  try {
    print('\n--- 5. Emitir DAS ---');

    final dasResponse = await relpsnService.emitirDas(202308);

    if (dasResponse.sucesso && dasResponse.pdfGeradoComSucesso) {
      print('✅ DAS emitido com sucesso');
      print('Tamanho do PDF: ${dasResponse.tamanhoPdfFormatado}');
      print('PDF disponível: ${dasResponse.dados?.pdfDisponivel == true ? 'Sim' : 'Não'}');

      // Salvar PDF em arquivo
      if (dasResponse.dados?.pdfDisponivel == true && dasResponse.dados?.docArrecadacaoPdfB64 != null) {
        final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
          dasResponse.dados!.docArrecadacaoPdfB64,
          'das_relpsn_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      final pdfInfo = dasResponse.dados?.pdfInfo;
      if (pdfInfo != null) {
        print('Informações do PDF:');
        print('  - Disponível: ${pdfInfo['disponivel']}');
        print('  - Tamanho em caracteres: ${pdfInfo['tamanho_caracteres']}');
        print('  - Tamanho em bytes: ${pdfInfo['tamanho_bytes_aproximado']}');
        print('  - Preview: ${pdfInfo['preview']}');
      }
    } else {
      print('❌ Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== Resumo Final ===');
  if (servicoOk) {
    print('✅ RELPSN: OK');
  } else {
    print('❌ RELPSN: ERRO');
  }
}
