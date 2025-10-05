import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> PagtoWeb(ApiClient apiClient) async {
  print('=== Exemplos PAGTOWEB ===');

  final pagtoWebService = PagtoWebService(apiClient);
  bool servicoOk = true;
  // 1. Consulta Pagamento: quando pesquisado por intervaloDataArrecadacao
  try {
    print('\n--- 1. Consulta Pagamento por intervaloDataArrecadacao ---');
    final consultarDataResponse = await pagtoWebService.consultarPagamentosPorIntervaloDataArrecadacao(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      dataInicial: '2019-09-01',
      dataFinal: '2019-11-30',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 100,
    );

    print('✅ Status: ${consultarDataResponse.status}');
    print('Sucesso: ${consultarDataResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDataResponse.dados.length}');

    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Primeiro pagamento:');
      print('  Número: ${pagamento.numeroDocumento}');
      print('  Tipo: ${pagamento.tipo.descricao}');
      print('  Período: ${pagamento.periodoApuracao}');
      print('  Data Arrecadação: ${pagamento.dataArrecadacao}');
      print('  Valor Total: R\$ ${pagamento.valorTotal}');
      print('  Receita: ${pagamento.receitaPrincipal.descricao}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pagamentos por data: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Consulta Pagamento: quando pesquisado por codigoReceitaLista
  try {
    print('\n--- 2. Consulta Pagamento por codigoReceitaLista ---');
    final consultarReceitaResponse = await pagtoWebService.consultarPagamentosPorCodigoReceitaLista(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      codigoReceitaLista: ['9999', '9999'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 100,
    );

    print('✅ Status: ${consultarReceitaResponse.status}');
    print('Sucesso: ${consultarReceitaResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarReceitaResponse.dados.length}');
    if (consultarReceitaResponse.dados.isNotEmpty) {
      final pagamento = consultarReceitaResponse.dados.first;
      print('Primeiro pagamento:');
      print('  Número: ${pagamento.numeroDocumento}');
      print('  Tipo: ${pagamento.tipo.descricao}');
      print('  Período: ${pagamento.periodoApuracao}');
      print('  Data Arrecadação: ${pagamento.dataArrecadacao}');
      print('  Valor Total: R\$ ${pagamento.valorTotal}');
      print('  Receita: ${pagamento.receitaPrincipal.descricao}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pagamentos por receita: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 3. Consulta Pagamento: quando pesquisado por intervaloValorTotalDocumento
  try {
    print('\n--- 3. Consulta Pagamento por intervaloValorTotalDocumento ---');
    final consultarValorResponse = await pagtoWebService.consultarPagamentosPorIntervaloValorTotalDocumento(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      valorInicial: 6000.0,
      valorFinal: 13000.0,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 100,
    );

    print('✅ Status: ${consultarValorResponse.status}');
    print('Sucesso: ${consultarValorResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarValorResponse.dados.length}');
    if (consultarValorResponse.dados.isNotEmpty) {
      final pagamento = consultarValorResponse.dados.first;
      print('Primeiro pagamento:');
      print('  Número: ${pagamento.numeroDocumento}');
      print('  Tipo: ${pagamento.tipo.descricao}');
      print('  Período: ${pagamento.periodoApuracao}');
      print('  Data Arrecadação: ${pagamento.dataArrecadacao}');
      print('  Valor Total: R\$ ${pagamento.valorTotal}');
      print('  Receita: ${pagamento.receitaPrincipal.descricao}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pagamentos por valor: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 4. Conta Consulta Pagamento: quando pesquisado por intervaloDataArrecadacao
  try {
    print('\n--- 4. Conta Consulta Pagamento por intervaloDataArrecadacao ---');
    final contarDataResponse = await pagtoWebService.contarPagamentosPorIntervaloDataArrecadacao(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      dataInicial: '2019-09-01',
      dataFinal: '2019-11-30',
    );

    print('✅ Status: ${contarDataResponse.status}');
    print('Sucesso: ${contarDataResponse.sucesso}');
    print('Quantidade total: ${contarDataResponse.quantidade}');
  } catch (e) {
    print('❌ Erro ao contar pagamentos por data: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 5. Conta Consulta Pagamento: quando pesquisado por codigoReceitaLista
  try {
    print('\n--- 5. Conta Consulta Pagamento por codigoReceitaLista ---');
    final contarReceitaResponse = await pagtoWebService.contarPagamentosPorCodigoReceitaLista(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      codigoReceitaLista: ['9999', '9999'],
    );

    print('✅ Status: ${contarReceitaResponse.status}');
    print('Sucesso: ${contarReceitaResponse.sucesso}');
    print('Quantidade total: ${contarReceitaResponse.quantidade}');
  } catch (e) {
    print('❌ Erro ao contar pagamentos por receita: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 6. Conta Consulta Pagamento: quando pesquisado por intervaloValorTotalDocumento
  try {
    print('\n--- 6. Conta Consulta Pagamento por intervaloValorTotalDocumento ---');
    final contarValorResponse = await pagtoWebService.contarPagamentosPorIntervaloValorTotalDocumento(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      valorInicial: 6000.0,
      valorFinal: 13000.0,
    );

    print('✅ Status: ${contarValorResponse.status}');
    print('Sucesso: ${contarValorResponse.sucesso}');
    print('Quantidade total: ${contarValorResponse.quantidade}');
  } catch (e) {
    print('❌ Erro ao contar pagamentos por valor: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 7. Emitir Comprovante de Pagamento
  try {
    print('\n--- 7. Emitir Comprovante de Pagamento ---');
    final emitirComprovanteResponse = await pagtoWebService.emitirComprovantePagamento(
      contratanteNumero: '99999999999999',
      contribuinteNumero: '99999999999',
      autorPedidoDadosNumero: '99999999999',
      numeroDocumento: '99999999999999999',
    );

    print('✅ Status: ${emitirComprovanteResponse.status}');
    print('Sucesso: ${emitirComprovanteResponse.sucesso}');
    print('PDF disponível: ${emitirComprovanteResponse.pdfBase64 != null}');

    if (emitirComprovanteResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${emitirComprovanteResponse.pdfBase64!.length} caracteres');

      // Salvar PDF em arquivo
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        emitirComprovanteResponse.pdfBase64!,
        'comprovante_pagto_web_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } catch (e) {
    print('❌ Erro ao emitir comprovante de pagamento: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PAGTOWEB ===');
  if (servicoOk) {
    print('✅ Serviço PAGTOWEB: OK');
  } else {
    print('❌ Serviço PAGTOWEB: ERRO');
  }
  print('\n=== Exemplos PAGTOWEB Concluídos ===');
}
