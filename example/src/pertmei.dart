import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Pertmei(ApiClient apiClient) async {
  print('\n=== Exemplos PERTMEI ===');

  final pertmeiService = PertmeiService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo

  try {
    // 1. Consultar Pedidos de Parcelamento
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await pertmeiService.consultarPedidos(cnpjContribuinte);
    print('Status: ${pedidosResponse.status}');
    print('Mensagens: ${pedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (pedidosResponse.status == '200') {
      final parcelamentos = pedidosResponse.parcelamentos;
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      for (final parcelamento in parcelamentos) {
        print('  - Número: ${parcelamento.numero}, Situação: ${parcelamento.situacao}');
      }
    }

    // 2. Consultar Parcelamento Específico
    print('\n2. Consultando parcelamento específico...');
    const numeroParcelamento = 9001; // Número de exemplo da documentação
    final parcelamentoResponse = await pertmeiService.consultarParcelamento(cnpjContribuinte, numeroParcelamento);
    print('Status: ${parcelamentoResponse.status}');
    print('Mensagens: ${parcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelamentoResponse.status == '200') {
      final parcelamentoDetalhado = parcelamentoResponse.parcelamentoDetalhado;
      if (parcelamentoDetalhado != null) {
        print('Parcelamento encontrado: ${parcelamentoDetalhado.numero}');
        print('Situação: ${parcelamentoDetalhado.situacao}');
        print('Consolidação original: ${parcelamentoDetalhado.consolidacaoOriginal?.valorTotalConsolidadoDaDivida ?? 0.0}');
      }
    }

    // 3. Consultar Parcelas para Impressão
    print('\n3. Consultando parcelas para impressão...');
    final parcelasResponse = await pertmeiService.consultarParcelasParaImpressao(cnpjContribuinte);
    print('Status: ${parcelasResponse.status}');
    print('Mensagens: ${parcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (parcelasResponse.status == '200') {
      final parcelas = parcelasResponse.parcelas;
      print('Parcelas disponíveis: ${parcelas.length}');
      for (final parcela in parcelas) {
        print('  - Parcela: ${parcela.parcela}, Valor: R\$ ${parcela.valor.toStringAsFixed(2)}');
      }
    }

    // 4. Consultar Detalhes de Pagamento
    print('\n4. Consultando detalhes de pagamento...');
    const anoMesParcela = 201907; // Exemplo da documentação
    final detalhesResponse = await pertmeiService.consultarDetalhesPagamento(cnpjContribuinte, numeroParcelamento, anoMesParcela);
    print('Status: ${detalhesResponse.status}');
    print('Mensagens: ${detalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (detalhesResponse.status == '200') {
      final detalhesPagamento = detalhesResponse.detalhesPagamento;
      if (detalhesPagamento != null) {
        print('DAS encontrado: ${detalhesPagamento.numeroDas}');
        print('Valor pago: R\$ ${detalhesPagamento.valorPagoArrecadacao.toStringAsFixed(2)}');
        print('Data pagamento: ${detalhesPagamento.dataPagamento}');
      }
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    const parcelaParaEmitir = 202306; // Exemplo da documentação
    final emitirResponse = await pertmeiService.emitirDas(cnpjContribuinte, parcelaParaEmitir);
    print('Status: ${emitirResponse.status}');
    print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (emitirResponse.status == '200') {
      final dasGerado = emitirResponse.dasGerado;
      if (dasGerado != null) {
        print('DAS gerado com sucesso!');
        print('Tamanho do PDF (base64): ${dasGerado.docArrecadacaoPdfB64.length} caracteres');
        // Em uma aplicação real, você converteria o base64 para PDF e salvaria/abriria o arquivo
      }
    }

    // Exemplos de validação de erro
    print('\n6. Testando validações...');

    // Teste com CNPJ vazio
    final erroResponse = await pertmeiService.consultarPedidos('');
    print('Validação CNPJ vazio: ${erroResponse.status} - ${erroResponse.mensagens.first.texto}');

    // Teste com número de parcelamento inválido
    final erroParcelamento = await pertmeiService.consultarParcelamento(cnpjContribuinte, 0);
    print('Validação parcelamento inválido: ${erroParcelamento.status} - ${erroParcelamento.mensagens.first.texto}');

    // Teste com formato de data inválido
    final erroData = await pertmeiService.emitirDas(cnpjContribuinte, 20230); // Formato inválido
    print('Validação formato data inválido: ${erroData.status} - ${erroData.mensagens.first.texto}');

    print('\n=== Exemplos PERTMEI Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço PERTMEI: $e');
  }
}
