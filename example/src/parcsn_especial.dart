import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> ParcsnEspecial(ApiClient apiClient) async {
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
