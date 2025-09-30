import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> PagtoWeb(ApiClient apiClient) async {
  print('=== Exemplos PAGTOWEB ===');

  final pagtoWebService = PagtoWebService(apiClient);

  try {
    // 1. Consultar pagamentos por intervalo de data
    print('\n--- Consultando pagamentos por data ---');
    final consultarDataResponse = await pagtoWebService.consultarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDataResponse.status}');
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

    // 2. Consultar pagamentos por códigos de receita
    print('\n--- Consultando pagamentos por receita ---');
    final consultarReceitaResponse = await pagtoWebService.consultarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarReceitaResponse.status}');
    print('Sucesso: ${consultarReceitaResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarReceitaResponse.dados.length}');

    // 3. Consultar pagamentos por intervalo de valor
    print('\n--- Consultando pagamentos por valor ---');
    final consultarValorResponse = await pagtoWebService.consultarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarValorResponse.status}');
    print('Sucesso: ${consultarValorResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarValorResponse.dados.length}');

    // 4. Consultar pagamentos por números de documento
    print('\n--- Consultando pagamentos por documento ---');
    final consultarDocumentoResponse = await pagtoWebService.consultarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDocumentoResponse.status}');
    print('Sucesso: ${consultarDocumentoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDocumentoResponse.dados.length}');

    // 5. Contar pagamentos por data
    print('\n--- Contando pagamentos por data ---');
    final contarDataResponse = await pagtoWebService.contarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
    );

    print('Status: ${contarDataResponse.status}');
    print('Sucesso: ${contarDataResponse.sucesso}');
    print('Quantidade total: ${contarDataResponse.quantidade}');

    // 6. Contar pagamentos por receita
    print('\n--- Contando pagamentos por receita ---');
    final contarReceitaResponse = await pagtoWebService.contarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
    );

    print('Status: ${contarReceitaResponse.status}');
    print('Sucesso: ${contarReceitaResponse.sucesso}');
    print('Quantidade total: ${contarReceitaResponse.quantidade}');

    // 7. Contar pagamentos por valor
    print('\n--- Contando pagamentos por valor ---');
    final contarValorResponse = await pagtoWebService.contarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
    );

    print('Status: ${contarValorResponse.status}');
    print('Sucesso: ${contarValorResponse.sucesso}');
    print('Quantidade total: ${contarValorResponse.quantidade}');

    // 8. Contar pagamentos por documento
    print('\n--- Contando pagamentos por documento ---');
    final contarDocumentoResponse = await pagtoWebService.contarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
    );

    print('Status: ${contarDocumentoResponse.status}');
    print('Sucesso: ${contarDocumentoResponse.sucesso}');
    print('Quantidade total: ${contarDocumentoResponse.quantidade}');

    // 9. Emitir comprovante de pagamento
    print('\n--- Emitindo comprovante de pagamento ---');
    final emitirComprovanteResponse = await pagtoWebService.emitirComprovante(
      contribuinteNumero: '00000000000100',
      numeroDocumento: '12345678901234567890',
    );

    print('Status: ${emitirComprovanteResponse.status}');
    print('Sucesso: ${emitirComprovanteResponse.sucesso}');
    print('PDF disponível: ${emitirComprovanteResponse.pdfBase64 != null}');

    if (emitirComprovanteResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${emitirComprovanteResponse.pdfBase64!.length} caracteres');
    }

    // 10. Exemplo com filtros combinados
    print('\n--- Exemplo com filtros combinados ---');
    final consultarCombinadoResponse = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-06-01',
      dataFinal: '2023-06-30',
      codigoReceitaLista: ['0001'],
      valorInicial: 500.00,
      valorFinal: 2000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 20,
    );

    print('Status: ${consultarCombinadoResponse.status}');
    print('Sucesso: ${consultarCombinadoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarCombinadoResponse.dados.length}');

    // 11. Exemplo de paginação
    print('\n--- Exemplo de paginação ---');
    final pagina1Response = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Página 1 - Status: ${pagina1Response.status}');
    print('Página 1 - Quantidade: ${pagina1Response.dados.length}');

    if (pagina1Response.dados.length == 5) {
      // Simular próxima página
      final pagina2Response = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000100',
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
        primeiroDaPagina: 5,
        tamanhoDaPagina: 5,
      );

      print('Página 2 - Status: ${pagina2Response.status}');
      print('Página 2 - Quantidade: ${pagina2Response.dados.length}');
    }

    // 12. Exemplo de tratamento de erros
    print('\n--- Exemplo de tratamento de erros ---');
    try {
      final erroResponse = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000000', // CNPJ inválido
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
      );

      print('Status: ${erroResponse.status}');
      print('Sucesso: ${erroResponse.sucesso}');

      if (!erroResponse.sucesso) {
        print('Mensagens de erro:');
        for (final mensagem in erroResponse.mensagens) {
          print('  ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
    } catch (e) {
      print('Erro capturado: $e');
    }

    // 13. Exemplo de análise de desmembramentos
    print('\n--- Exemplo de análise de desmembramentos ---');
    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Análise do pagamento ${pagamento.numeroDocumento}:');
      print('  Desmembramentos: ${pagamento.desmembramentos.length}');

      for (int i = 0; i < pagamento.desmembramentos.length; i++) {
        final desmembramento = pagamento.desmembramentos[i];
        print('  Desmembramento ${i + 1}:');
        print('    Sequencial: ${desmembramento.sequencial}');
        print('    Receita: ${desmembramento.receitaPrincipal.descricao}');
        print('    Período: ${desmembramento.periodoApuracao}');
        print('    Valor Total: R\$ ${desmembramento.valorTotal ?? 0.0}');
        print('    Valor Principal: R\$ ${desmembramento.valorPrincipal ?? 0.0}');
        print('    Valor Multa: R\$ ${desmembramento.valorMulta ?? 0.0}');
        print('    Valor Juros: R\$ ${desmembramento.valorJuros ?? 0.0}');
      }
    }

    print('\n=== Exemplos PAGTOWEB Concluídos ===');
  } catch (e) {
    print('Erro no serviço PAGTOWEB: $e');
  }
}
