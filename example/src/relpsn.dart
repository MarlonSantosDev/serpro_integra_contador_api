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

      final parcelamentos = pedidosResponse.dadosParsed?.parcelamentos ?? [];
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

  // 2. Consultar Parcelamento Específico
  try {
    print('\n--- 2. Consultar Parcelamento Específico ---');
    const numeroParcelamento = 123456; // Número de exemplo

    final parcelamentoResponse = await relpsnService.consultarParcelamento(numeroParcelamento);

    if (parcelamentoResponse.sucesso) {
      print('✅ Parcelamento consultado com sucesso');
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
      print('❌ Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamento: $e');
    servicoOk = false;
  }

  // 3. Consultar Parcelas Disponíveis
  try {
    print('\n--- 3. Consultar Parcelas Disponíveis ---');
    const numeroParcelamento = 123456; // Número de exemplo

    final parcelasResponse = await relpsnService.consultarParcelas(numeroParcelamento);

    if (parcelasResponse.sucesso) {
      print('✅ Parcelas consultadas com sucesso');
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
      print('❌ Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas: $e');
    servicoOk = false;
  }

  // 4. Consultar Detalhes de Pagamento
  try {
    print('\n--- 4. Consultar Detalhes de Pagamento ---');
    const numeroParcelamento = 123456; // Número de exemplo
    const anoMesParcela = 202401; // Janeiro de 2024

    final detalhesResponse = await relpsnService.consultarDetalhesPagamento(numeroParcelamento, anoMesParcela);

    if (detalhesResponse.sucesso) {
      print('✅ Detalhes de pagamento consultados com sucesso');
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
      print('❌ Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes: $e');
    servicoOk = false;
  }

  // 5. Emitir DAS
  try {
    print('\n--- 5. Emitir DAS ---');
    const numeroParcelamento = 123456; // Número de exemplo
    const parcelaParaEmitir = 202401; // Janeiro de 2024

    final dasResponse = await relpsnService.emitirDas(numeroParcelamento, parcelaParaEmitir);

    if (dasResponse.sucesso && dasResponse.pdfGeradoComSucesso) {
      print('✅ DAS emitido com sucesso');
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
      print('❌ Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // 6. Validações
  try {
    print('\n--- 6. Validações ---');
    const numeroParcelamento = 123456; // Número de exemplo
    const anoMesParcela = 202401; // Janeiro de 2024
    const parcelaParaEmitir = 202401; // Janeiro de 2024

    // Validar número do parcelamento
    final validacaoParcelamento = relpsnService.validarNumeroParcelamento(numeroParcelamento);
    print('✅ Validação parcelamento: ${validacaoParcelamento ?? 'Válido'}');

    // Validar ano/mês da parcela
    final validacaoAnoMes = relpsnService.validarAnoMesParcela(anoMesParcela);
    print('✅ Validação ano/mês: ${validacaoAnoMes ?? 'Válido'}');

    // Validar parcela para emitir
    final validacaoParcela = relpsnService.validarParcelaParaEmitir(parcelaParaEmitir);
    print('✅ Validação parcela para emitir: ${validacaoParcela ?? 'Válido'}');

    // Validar prazo de emissão
    final validacaoPrazo = relpsnService.validarPrazoEmissaoParcela(parcelaParaEmitir);
    print('✅ Validação prazo de emissão: ${validacaoPrazo ?? 'Válido'}');
  } catch (e) {
    print('❌ Erro nas validações: $e');
    servicoOk = false;
  }

  // 7. Tratamento de Erros
  try {
    print('\n--- 7. Tratamento de Erros ---');

    // Verificar se um erro é conhecido
    const codigoErroExemplo = '[Aviso-RELPSN-ER_E001]';
    final isKnown = relpsnService.isKnownError(codigoErroExemplo);
    print('✅ Erro conhecido ($codigoErroExemplo): ${isKnown ? 'Sim' : 'Não'}');

    // Obter informações sobre um erro
    final errorInfo = relpsnService.getErrorInfo(codigoErroExemplo);
    if (errorInfo != null) {
      print('✅ Informações do erro:');
      print('  - Código: ${errorInfo.codigo}');
      print('  - Mensagem: ${errorInfo.mensagem}');
      print('  - Ação: ${errorInfo.acao}');
      print('  - Tipo: ${errorInfo.tipo}');
    }

    // Analisar um erro
    final analysis = relpsnService.analyzeError(codigoErroExemplo, 'Não há parcelamento ativo para o contribuinte.');
    print('✅ Análise do erro:');
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
  } catch (e) {
    print('❌ Erro no tratamento de erros: $e');
    servicoOk = false;
  }

  // 8. Listar Erros por Tipo
  try {
    print('\n--- 8. Listar Erros por Tipo ---');

    final avisos = relpsnService.getAvisos();
    print('✅ Total de avisos: ${avisos.length}');
    for (final aviso in avisos.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${aviso.codigo}: ${aviso.mensagem}');
    }

    final errosEntrada = relpsnService.getEntradasIncorretas();
    print('✅ Total de erros de entrada: ${errosEntrada.length}');
    for (final erro in errosEntrada.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${erro.codigo}: ${erro.mensagem}');
    }

    final erros = relpsnService.getErros();
    print('✅ Total de erros gerais: ${erros.length}');
    for (final erro in erros.take(3)) {
      // Mostrar apenas os primeiros 3
      print('  - ${erro.codigo}: ${erro.mensagem}');
    }
  } catch (e) {
    print('❌ Erro ao listar erros por tipo: $e');
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
