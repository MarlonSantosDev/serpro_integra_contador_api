import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplos de uso do serviço RELPMEI
Future<void> Relpmei(ApiClient apiClient) async {
  print('=== TESTANDO TODOS OS SERVIÇOS RELPMEI ===\rest');

  final relpmeiService = RelpmeiService(apiClient);
  int erros = 0;

  // CNPJ de teste conforme documentação SERPRO
  const cnpjContribuinte = '00000000000000';

  // ==============================================
  // 1. PEDIDOSPARC233 - Consultar Pedidos
  // ==============================================
  try {
    print('📋 1. PEDIDOSPARC233 - Consultar Pedidos de Parcelamento');
    print('   CNPJ: $cnpjContribuinte');

    final response = await relpmeiService.consultarPedidos(contribuinteNumero: cnpjContribuinte);

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final parcelamentos = response.parcelamentos;
      if (parcelamentos != null && parcelamentos.isNotEmpty) {
        print('   📋 Parcelamentos encontrados: ${parcelamentos.length}');
        for (final parcelamento in parcelamentos) {
          print('     - Número: ${parcelamento.numero}');
          print('       Situação: ${parcelamento.situacao}');
          print('       Data Pedido: ${FormatterUtils.formatDateFromString(parcelamento.dataDoPedido.toString())}');
        }
      } else {
        print('   ℹ️ Nenhum parcelamento encontrado');
      }
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ==============================================
  // 2. OBTERPARC234 - Consultar Parcelamento
  // ==============================================
  try {
    print('\n📋 2. OBTERPARC234 - Consultar Parcelamento Específico');
    print('   CNPJ: $cnpjContribuinte');
    print('   Parcelamento: 9131');

    final response = await relpmeiService.consultarParcelamento(contribuinteNumero: cnpjContribuinte, numeroParcelamento: 9131);

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final parcelamento = response.parcelamento;
      if (parcelamento != null) {
        print('   📋 Parcelamento:');
        print('     - Número: ${parcelamento.numero}');
        print('     - Situação: ${parcelamento.situacao}');
        print('     - Data Pedido: ${FormatterUtils.formatDateFromString(parcelamento.dataDoPedido.toString())}');
        print('     - Data Situação: ${FormatterUtils.formatDateFromString(parcelamento.dataDaSituacao.toString())}');

        if (parcelamento.consolidacaoOriginal != null) {
          final consolidacao = parcelamento.consolidacaoOriginal!;
          print('     - Valor Total: R\$ ${consolidacao.valorTotalConsolidadoDeEntrada.toStringAsFixed(2)}');
          print('     - Qtd Parcelas: ${consolidacao.quantidadeParcelasDeEntrada}');
          print('     - Valor Parcela: R\$ ${consolidacao.parcelaDeEntrada.toStringAsFixed(2)}');
        }
      }
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ==============================================
  // 3. PARCELASPARGERAR232 - Consultar Parcelas para Impressão
  // ==============================================
  try {
    print('\n📋 3. PARCELASPARGERAR232 - Consultar Parcelas para Impressão');
    print('   CNPJ: $cnpjContribuinte');

    final response = await relpmeiService.consultarParcelasImpressao(contribuinteNumero: cnpjContribuinte);

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final parcelas = response.parcelasDisponiveis;
      if (parcelas != null && parcelas.isNotEmpty) {
        print('   📋 Parcelas Disponíveis: ${parcelas.length}');
        for (final parcela in parcelas) {
          print('     - Parcela ${parcela.parcela}: R\$ ${parcela.valor.toStringAsFixed(2)}');
        }
      } else {
        print('   ℹ️ Nenhuma parcela disponível para impressão');
      }
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ==============================================
  // 4. DETPAGTOPARC235 - Consultar Detalhes de Pagamento
  // ==============================================
  try {
    print('\n📋 4. DETPAGTOPARC235 - Consultar Detalhes de Pagamento');
    print('   CNPJ: $cnpjContribuinte');
    print('   Parcelação: 9131');
    print('   Parcela: 202303');

    final response = await relpmeiService.consultarDetalhesPagamento(
      contribuinteNumero: cnpjContribuinte,
      numeroParcelamento: 9131,
      anoMesParcela: 202303,
    );

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final detalhes = response.detalhesPagamento;
      if (detalhes != null) {
        print('   📋 Detalhes do Pagamento:');
        print('     - Número DAS: ${detalhes.numeroDas}');
        print('     - Vencimento: ${FormatterUtils.formatDateFromString(detalhes.dataVencimento.toString())}');
        print('     - Pagamento: ${FormatterUtils.formatDateFromString(detalhes.dataPagamento.toString())}');
        print('     - Banco/Agência: ${detalhes.bancoAgencia}');
        print('     - Valor Pago: R\$ ${detalhes.valorPagoArrecadacao.toStringAsFixed(2)}');
      }
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ==============================================
  // 5. GERARDAS231 - Emitir DAS
  // ==============================================
  try {
    print('\n📋 5. GERARDAS231 - Emitir DAS');
    print('   CNPJ: $cnpjContribuinte');
    print('   Parcela: 202304');

    final response = await relpmeiService.emitirDas(contribuinteNumero: cnpjContribuinte, parcelaParaEmitir: 202304);

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final das = response.dasEmitido;
      if (das != null) {
        print('   📄 DAS Emitido:');
        print('     - PDF em Base64: ${das.docArrecadacaoPdfB64.length} caracteres');

        // Salvar PDF em arquivo
        final sucessoSalvamento = await PdfFileUtils.salvarArquivo(
          das.docArrecadacaoPdfB64,
          'das_relpmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('     PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  // ==============================================
  // RESUMO FINAL DOS TESTES
  // ==============================================
  print('\n=== RESUMO DO SERVIÇO RELPMEI ===');

  if (erros == 0) {
    print('\n✅🎉 RELPMEI: TODOS OS SERVIÇOS FUNCIONANDO PERFEITAMENTE!');
  } else {
    print('\❌ RELPMEI: Alguns problemas encontrados, verifique os erros acima.');
  }

  print('\n=== Exemplos RELPMEI Concluídos ===');
}
