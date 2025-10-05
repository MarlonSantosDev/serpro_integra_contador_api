import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Pertmei(ApiClient apiClient) async {
  print('\n=== Exemplos PERTMEI ===');

  final pertmeiService = PertmeiService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo
  bool servicoOk = true;

  // 1. Consultar Pedidos de Parcelamento
  try {
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await pertmeiService.consultarPedidos(cnpjContribuinte);
    print('✅ Status: ${pedidosResponse.status}');
    print('Mensagens: ${pedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (pedidosResponse.status == '200') {
      final parcelamentos = pedidosResponse.parcelamentos;
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      for (final parcelamento in parcelamentos) {
        print('  - Número: ${parcelamento.numero}, Situação: ${parcelamento.situacao}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos de parcelamento: $e');
    servicoOk = false;
  }

  // 2. Consultar Parcelamento Específico
  try {
    print('\n2. Consultando parcelamento específico...');
    const numeroParcelamento = 9001; // Número de exemplo da documentação
    final parcelamentoResponse = await pertmeiService.consultarParcelamento(cnpjContribuinte, numeroParcelamento);
    print('✅ Status: ${parcelamentoResponse.status}');
    print('Mensagens: ${parcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelamentoResponse.status == '200') {
      final parcelamentoDetalhado = parcelamentoResponse.parcelamentoDetalhado;
      if (parcelamentoDetalhado != null) {
        print('Parcelamento encontrado: ${parcelamentoDetalhado.numero}');
        print('Situação: ${parcelamentoDetalhado.situacao}');
        print('Consolidação original: ${parcelamentoDetalhado.consolidacaoOriginal?.valorTotalConsolidadoDaDivida ?? 0.0}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamento específico: $e');
    servicoOk = false;
  }

  // 3. Consultar Parcelas para Impressão
  try {
    print('\n3. Consultando parcelas para impressão...');
    final parcelasResponse = await pertmeiService.consultarParcelasParaImpressao(cnpjContribuinte);
    print('✅ Status: ${parcelasResponse.status}');
    print('Mensagens: ${parcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelasResponse.status == '200') {
      final parcelas = parcelasResponse.parcelas;
      print('Parcelas disponíveis: ${parcelas.length}');
      for (final parcela in parcelas) {
        print('  - Parcela: ${parcela.parcela}, Valor: R\$ ${parcela.valor.toStringAsFixed(2)}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas para impressão: $e');
    servicoOk = false;
  }

  // 4. Consultar Detalhes de Pagamento
  try {
    print('\n4. Consultando detalhes de pagamento...');
    const numeroParcelamento = 9001;
    const anoMesParcela = 201907; // Exemplo da documentação
    final detalhesResponse = await pertmeiService.consultarDetalhesPagamento(cnpjContribuinte, numeroParcelamento, anoMesParcela);
    print('✅ Status: ${detalhesResponse.status}');
    print('Mensagens: ${detalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (detalhesResponse.status == '200') {
      final detalhesPagamento = detalhesResponse.detalhesPagamento;
      if (detalhesPagamento != null) {
        print('DAS encontrado: ${detalhesPagamento.numeroDas}');
        print('Valor pago: R\$ ${detalhesPagamento.valorPagoArrecadacao.toStringAsFixed(2)}');
        print('Data pagamento: ${detalhesPagamento.dataPagamento}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes de pagamento: $e');
    servicoOk = false;
  }

  // 5. Emitir DAS
  try {
    print('\n5. Emitindo DAS...');
    const parcelaParaEmitir = 202306; // Exemplo da documentação
    final emitirResponse = await pertmeiService.emitirDas(cnpjContribuinte, parcelaParaEmitir);
    print('✅ Status: ${emitirResponse.status}');
    print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (emitirResponse.status == '200') {
      final dasGerado = emitirResponse.dasGerado;
      if (dasGerado != null) {
        print('DAS gerado com sucesso!');
        print('Tamanho do PDF (base64): ${dasGerado.docArrecadacaoPdfB64.length} caracteres');

        // Salvar PDF em arquivo
        final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
          dasGerado.docArrecadacaoPdfB64,
          'das_pertmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // 6. Testando validações
  try {
    print('\n6. Testando validações...');

    // Teste com CNPJ vazio
    final erroResponse = await pertmeiService.consultarPedidos('');
    print('✅ Validação CNPJ vazio: ${erroResponse.status} - ${erroResponse.mensagens.first.texto}');

    // Teste com número de parcelamento inválido
    final erroParcelamento = await pertmeiService.consultarParcelamento(cnpjContribuinte, 0);
    print('✅ Validação parcelamento inválido: ${erroParcelamento.status} - ${erroParcelamento.mensagens.first.texto}');

    // Teste com formato de data inválido
    final erroData = await pertmeiService.emitirDas(cnpjContribuinte, 20230); // Formato inválido
    print('✅ Validação formato data inválido: ${erroData.status} - ${erroData.mensagens.first.texto}');
  } catch (e) {
    print('❌ Erro nos testes de validação: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PERTMEI ===');
  if (servicoOk) {
    print('✅ Serviço PERTMEI: OK');
  } else {
    print('❌ Serviço PERTMEI: ERRO');
  }

  print('\n=== Exemplos PERTMEI Concluídos ===');
}
