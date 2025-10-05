import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> ParcmeiEspecial(ApiClient apiClient) async {
  print('=== Exemplos PARCMEI-ESP ===');

  final parcmeiEspecialService = ParcmeiEspecialService(apiClient);
  bool servicoOk = true;

  // 1. Consultar pedidos de parcelamento
  try {
    print('\n1. Consultando pedidos de parcelamento PARCMEI-ESP...');
    final responsePedidos = await parcmeiEspecialService.consultarPedidos();

    if (responsePedidos.sucesso) {
      print('✅ Status: ${responsePedidos.status}');
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
      print('❌ Erro: ${responsePedidos.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos de parcelamento: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 2. Consultar parcelamento específico
  try {
    print('\n2. Consultando parcelamento específico...');
    final responseParcelamento = await parcmeiEspecialService.consultarParcelamento(9001);

    if (responseParcelamento.sucesso) {
      print('✅ Status: ${responseParcelamento.status}');
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
      print('❌ Erro: ${responseParcelamento.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro na consulta do parcelamento: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 3. Consultar parcelas disponíveis para impressão
  try {
    print('\n3. Consultando parcelas disponíveis para impressão...');
    final responseParcelas = await parcmeiEspecialService.consultarParcelas();

    if (responseParcelas.sucesso) {
      print('✅ Status: ${responseParcelas.status}');
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
      print('❌ Erro: ${responseParcelas.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas disponíveis: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 4. Consultar detalhes de pagamento
  try {
    print('\n4. Consultando detalhes de pagamento...');
    final responseDetalhes = await parcmeiEspecialService.consultarDetalhesPagamento(9001, 202111);

    if (responseDetalhes.sucesso) {
      print('✅ Status: ${responseDetalhes.status}');
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
      print('❌ Erro: ${responseDetalhes.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro na consulta dos detalhes: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 5. Emitir DAS
  try {
    print('\n5. Emitindo DAS...');
    final responseDas = await parcmeiEspecialService.emitirDas(202107);

    if (responseDas.sucesso) {
      print('✅ Status: ${responseDas.status}');
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

          // Salvar PDF em arquivo
          final sucessoSalvamento = await PdfFileUtils.salvarArquivo(dadosDas.docArrecadacaoPdfB64, dadosDas.nomeArquivoSugerido);
          print('  PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
        }
      }
    } else {
      print('❌ Erro: ${responseDas.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro na emissão do DAS: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PARCMEI-ESP ===');
  if (servicoOk) {
    print('✅ Serviço PARCMEI-ESP: OK');
  } else {
    print('❌ Serviço PARCMEI-ESP: ERRO');
  }

  print('\n=== Exemplos PARCMEI-ESP Concluídos ===');
}
