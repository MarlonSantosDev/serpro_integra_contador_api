import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Relpmei(ApiClient apiClient) async {
  print('\n=== Exemplos RELPMEI ===');

  final relpmeiService = RelpmeiService(apiClient);
  bool servicoOk = true;

  // Exemplo 1: Consultar Pedidos de Parcelamento
  try {
    print('\n--- Consultando Pedidos de Parcelamento ---');
    final consultarPedidosRequest = ConsultarPedidosRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta de pedidos RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelamento de débitos',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarPedidosResponse = await relpmeiService.consultarPedidos(consultarPedidosRequest);
    print('✅ Consulta de pedidos: ${consultarPedidosResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarPedidosResponse.sucesso) {
      print('Pedidos encontrados: ${consultarPedidosResponse.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${consultarPedidosResponse.mensagem}');
      print('Código: ${consultarPedidosResponse.codigoErro}');
      print('Detalhes: ${consultarPedidosResponse.detalhesErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos: $e');
    servicoOk = false;
  }

  // Exemplo 2: Consultar Parcelamentos Existentes
  try {
    print('\n--- Consultando Parcelamentos Existentes ---');
    final consultarParcelamentoRequest = ConsultarParcelamentoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PARCELAMENTOS', dados: 'Consulta de parcelamentos RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelamento de débitos',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarParcelamentoResponse = await relpmeiService.consultarParcelamento(consultarParcelamentoRequest);
    print('✅ Consulta de parcelamentos: ${consultarParcelamentoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarParcelamentoResponse.sucesso) {
      print('Parcelamentos encontrados: ${consultarParcelamentoResponse.parcelamentos?.length ?? 0}');
    } else {
      print('Erro: ${consultarParcelamentoResponse.mensagem}');
      print('Código: ${consultarParcelamentoResponse.codigoErro}');
      print('Detalhes: ${consultarParcelamentoResponse.detalhesErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamentos: $e');
    servicoOk = false;
  }

  // Exemplo 3: Consultar Parcelas para Impressão
  try {
    print('\n--- Consultando Parcelas para Impressão ---');
    final consultarParcelasImpressaoRequest = ConsultarParcelasImpressaoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PARCELAS_IMPRESSAO', dados: 'Consulta de parcelas para impressão RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Parcelas para impressão',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarParcelasImpressaoResponse = await relpmeiService.consultarParcelasImpressao(consultarParcelasImpressaoRequest);
    print('✅ Consulta de parcelas para impressão: ${consultarParcelasImpressaoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarParcelasImpressaoResponse.sucesso) {
      print('Parcelas para impressão encontradas: ${consultarParcelasImpressaoResponse.parcelas?.length ?? 0}');
    } else {
      print('Erro: ${consultarParcelasImpressaoResponse.mensagem}');
      print('Código: ${consultarParcelasImpressaoResponse.codigoErro}');
      print('Detalhes: ${consultarParcelasImpressaoResponse.detalhesErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas para impressão: $e');
    servicoOk = false;
  }

  // Exemplo 4: Consultar Detalhes de Pagamento
  try {
    print('\n--- Consultando Detalhes de Pagamento ---');
    final consultarDetalhesPagamentoRequest = ConsultarDetalhesPagamentoRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_DETALHES_PAGAMENTO', dados: 'Consulta de detalhes de pagamento RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Detalhes de pagamento',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final consultarDetalhesPagamentoResponse = await relpmeiService.consultarDetalhesPagamento(consultarDetalhesPagamentoRequest);
    print('✅ Consulta de detalhes de pagamento: ${consultarDetalhesPagamentoResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (consultarDetalhesPagamentoResponse.sucesso) {
      print('Detalhes de pagamento encontrados: ${consultarDetalhesPagamentoResponse.detalhes?.length ?? 0}');
    } else {
      print('Erro: ${consultarDetalhesPagamentoResponse.mensagem}');
      print('Código: ${consultarDetalhesPagamentoResponse.codigoErro}');
      print('Detalhes: ${consultarDetalhesPagamentoResponse.detalhesErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes de pagamento: $e');
    servicoOk = false;
  }

  // Exemplo 5: Emitir DAS
  try {
    print('\n--- Emitindo DAS ---');
    final emitirDasRequest = EmitirDasRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'EMITIR_DAS', dados: 'Emissão de DAS RELPMEI'),
      cpfCnpj: '12345678901', // CPF de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
      vencimento: '2024-01-31',
      valor: '1000.00',
      observacoes: 'Emissão de DAS',
      tipoParcelamento: 'NORMAL',
      numeroParcelas: '12',
      valorParcela: '83.33',
      dataVencimento: '2024-01-31',
      codigoBarras: '12345678901234567890123456789012345678901234',
      linhaDigitavel: '12345678901234567890123456789012345678901234',
      dataPagamento: '2024-01-15',
      valorPago: '1000.00',
      formaPagamento: 'BOLETO',
      banco: '001',
      agencia: '1234',
      conta: '12345678',
      numeroDocumento: '123456789',
      dataEmissao: '2024-01-15',
    );

    final emitirDasResponse = await relpmeiService.emitirDas(emitirDasRequest);
    print('✅ Emissão de DAS: ${emitirDasResponse.sucesso ? 'Sucesso' : 'Erro'}');
    if (emitirDasResponse.sucesso) {
      print('DAS emitido: ${emitirDasResponse.das?.numeroDas ?? 'N/A'}');
      print('Valor: ${emitirDasResponse.das?.valor ?? 'N/A'}');
      print('Vencimento: ${emitirDasResponse.das?.dataVencimento ?? 'N/A'}');
    } else {
      print('Erro: ${emitirDasResponse.mensagem}');
      print('Código: ${emitirDasResponse.codigoErro}');
      print('Detalhes: ${emitirDasResponse.detalhesErro}');
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // Exemplo 6: Teste de validação com CPF/CNPJ inválido
  try {
    print('\n--- Teste de Validação com CPF/CNPJ Inválido ---');
    final requestInvalido = ConsultarPedidosRequest(
      contribuinteNumero: '',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Teste de validação'),
      cpfCnpj: '', // CPF vazio para testar validação
    );

    final responseInvalido = await relpmeiService.consultarPedidos(requestInvalido);
    print('✅ Validação de CPF vazio: ${responseInvalido.sucesso ? 'Sucesso' : 'Erro'}');
    if (!responseInvalido.sucesso) {
      print('Erro esperado: ${responseInvalido.mensagem}');
      print('Código: ${responseInvalido.codigoErro}');
    }
  } catch (e) {
    print('❌ Erro no teste de validação: $e');
    servicoOk = false;
  }

  // Exemplo 7: Teste com CNPJ
  try {
    print('\n--- Teste com CNPJ ---');
    final requestCnpj = ConsultarPedidosRequest(
      contribuinteNumero: '12345678000195',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta com CNPJ'),
      cpfCnpj: '12345678000195', // CNPJ de exemplo
      inscricaoEstadual: '123456789',
      codigoReceita: '1001',
      referencia: '202401',
    );

    final responseCnpj = await relpmeiService.consultarPedidos(requestCnpj);
    print('✅ Consulta com CNPJ: ${responseCnpj.sucesso ? 'Sucesso' : 'Erro'}');
    if (responseCnpj.sucesso) {
      print('Pedidos encontrados: ${responseCnpj.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${responseCnpj.mensagem}');
    }
  } catch (e) {
    print('❌ Erro no teste com CNPJ: $e');
    servicoOk = false;
  }

  // Exemplo 8: Teste com dados mínimos
  try {
    print('\n--- Teste com Dados Mínimos ---');
    final requestMinimo = ConsultarPedidosRequest(
      contribuinteNumero: '12345678901',
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'CONSULTAR_PEDIDOS', dados: 'Consulta com dados mínimos'),
      cpfCnpj: '12345678901', // Apenas CPF obrigatório
    );

    final responseMinimo = await relpmeiService.consultarPedidos(requestMinimo);
    print('✅ Consulta com dados mínimos: ${responseMinimo.sucesso ? 'Sucesso' : 'Erro'}');
    if (responseMinimo.sucesso) {
      print('Pedidos encontrados: ${responseMinimo.pedidos?.length ?? 0}');
    } else {
      print('Erro: ${responseMinimo.mensagem}');
    }
  } catch (e) {
    print('❌ Erro no teste com dados mínimos: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO RELPMEI ===');
  if (servicoOk) {
    print('✅ Serviço RELPMEI: OK');
  } else {
    print('❌ Serviço RELPMEI: ERRO');
  }

  print('\n=== Exemplos RELPMEI Concluídos ===');
}
