import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Parcmei(ApiClient apiClient) async {
  print('\n=== Exemplos PARCMEI ===');

  final parcmeiService = ParcmeiService(apiClient);
  bool servicoOk = true;

  // 1. Consultar Pedidos de Parcelamento
  try {
    print('\n--- 1. Consultar Pedidos de Parcelamento ---');
    final pedidosResponse = await parcmeiService.consultarPedidos();
    print('✅ Status: ${pedidosResponse.status}');
    print('Mensagens: ${pedidosResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${pedidosResponse.sucesso}');
    print('Mensagem principal: ${pedidosResponse.mensagemPrincipal}');
    print('Tem parcelamentos: ${pedidosResponse.temParcelamentos}');
    print('Quantidade de parcelamentos: ${pedidosResponse.quantidadeParcelamentos}');

    if (pedidosResponse.sucesso && pedidosResponse.temParcelamentos) {
      final parcelamentos = pedidosResponse.dadosParsed?.parcelamentos ?? [];
      print('Parcelamentos encontrados:');
      for (var parcelamento in parcelamentos.take(3)) {
        print('  - Número: ${parcelamento.numero}');
        print('    Situação: ${parcelamento.situacao}');
        print('    Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('    Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('    Ativo: ${parcelamento.isAtivo}');
        print('    Encerrado: ${parcelamento.isEncerrado}');
        print('');
      }

      print('Parcelamentos ativos: ${pedidosResponse.parcelamentosAtivos.length}');
      print('Parcelamentos encerrados: ${pedidosResponse.parcelamentosEncerrados.length}');
    }
  } catch (e) {
    print('❌ Erro ao consultar pedidos de parcelamento: $e');
    servicoOk = false;
  }

  // 2. Consultar Parcelamento Específico
  try {
    print('\n--- 2. Consultar Parcelamento Específico ---');
    final parcelamentoResponse = await parcmeiService.consultarParcelamento(1);
    print('✅ Status: ${parcelamentoResponse.status}');
    print('Mensagens: ${parcelamentoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${parcelamentoResponse.sucesso}');
    print('Mensagem principal: ${parcelamentoResponse.mensagemPrincipal}');

    if (parcelamentoResponse.sucesso) {
      final parcelamento = parcelamentoResponse.dadosParsed;
      if (parcelamento != null) {
        print('Parcelamento detalhado:');
        print('  Número: ${parcelamento.numero}');
        print('  Situação: ${parcelamento.situacao}');
        print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
        print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
        print('  Ativo: ${parcelamento.isAtivo}');
        print('  Tem alterações de dívida: ${parcelamento.temAlteracoesDivida}');
        print('  Tem pagamentos: ${parcelamento.temPagamentos}');

        if (parcelamento.consolidacaoOriginal != null) {
          final consolidacao = parcelamento.consolidacaoOriginal!;
          print('  Consolidação original:');
          print('    Valor total: ${parcelamentoResponse.valorTotalConsolidadoFormatado}');
          print('    Quantidade de parcelas: ${parcelamentoResponse.quantidadeParcelas}');
          print('    Parcela básica: ${parcelamentoResponse.parcelaBasicaFormatada}');
          print('    Data de consolidação: ${consolidacao.dataConsolidacaoFormatada}');
          print('    Detalhes de consolidação: ${consolidacao.detalhesConsolidacao.length}');
        }

        print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
        print('  Demonstrativo de pagamentos: ${parcelamento.demonstrativoPagamentos.length}');
        print('  Quantidade de pagamentos: ${parcelamentoResponse.quantidadePagamentos}');
        print('  Valor total pago: ${parcelamentoResponse.valorTotalPagoFormatado}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelamento específico: $e');
    servicoOk = false;
  }

  // 3. Consultar Parcelas Disponíveis
  try {
    print('\n--- 3. Consultar Parcelas Disponíveis ---');
    final parcelasResponse = await parcmeiService.consultarParcelas();
    print('✅ Status: ${parcelasResponse.status}');
    print('Mensagens: ${parcelasResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${parcelasResponse.sucesso}');
    print('Mensagem principal: ${parcelasResponse.mensagemPrincipal}');
    print('Tem parcelas: ${parcelasResponse.temParcelas}');
    print('Quantidade de parcelas: ${parcelasResponse.quantidadeParcelas}');

    if (parcelasResponse.sucesso && parcelasResponse.temParcelas) {
      final parcelas = parcelasResponse.dadosParsed?.listaParcelas ?? [];
      print('Parcelas disponíveis:');
      for (var parcela in parcelas.take(5)) {
        print('  - Parcela: ${parcela.parcelaFormatada}');
        print('    Valor: ${parcela.valorFormatado}');
        print('    Ano: ${parcela.ano}');
        print('    Mês: ${parcela.nomeMes}');
        print('    Descrição: ${parcela.descricaoCompleta}');
        print('    Ano atual: ${parcela.isAnoAtual}');
        print('');
      }

      print('Valor total das parcelas: ${parcelasResponse.valorTotalParcelasFormatado}');
      print('Todas parcelas mesmo valor: ${parcelasResponse.todasParcelasMesmoValor}');

      final menorValor = parcelasResponse.parcelaMenorValor;
      final maiorValor = parcelasResponse.parcelaMaiorValor;
      if (menorValor != null) {
        print('Menor valor: ${menorValor.valorFormatado} (${menorValor.parcelaFormatada})');
      }
      if (maiorValor != null) {
        print('Maior valor: ${maiorValor.valorFormatado} (${maiorValor.parcelaFormatada})');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar parcelas disponíveis: $e');
    servicoOk = false;
  }

  // 4. Consultar Detalhes de Pagamento
  try {
    print('\n--- 4. Consultar Detalhes de Pagamento ---');
    final detalhesResponse = await parcmeiService.consultarDetalhesPagamento(1, 202107);
    print('✅ Status: ${detalhesResponse.status}');
    print('Mensagens: ${detalhesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${detalhesResponse.sucesso}');
    print('Mensagem principal: ${detalhesResponse.mensagemPrincipal}');

    if (detalhesResponse.sucesso) {
      final detalhes = detalhesResponse.dadosParsed;
      if (detalhes != null) {
        print('Detalhes de pagamento:');
        print('  Número do DAS: ${detalhes.numeroDas}');
        print('  Data de vencimento: ${detalhesResponse.dataVencimentoFormatada}');
        print('  Período DAS gerado: ${detalhesResponse.paDasGeradoFormatado}');
        print('  Gerado em: ${detalhes.geradoEmFormatado}');
        print('  Número do parcelamento: ${detalhes.numeroParcelamento}');
        print('  Número da parcela: ${detalhes.numeroParcela}');
        print('  Data limite acolhimento: ${detalhesResponse.dataLimiteAcolhimentoFormatada}');
        print('  Data de pagamento: ${detalhesResponse.dataPagamentoFormatada}');
        print('  Banco/Agência: ${detalhes.bancoAgencia}');
        print('  Valor pago: ${detalhesResponse.valorPagoArrecadacaoFormatado}');
        print('  Pagamento realizado: ${detalhesResponse.pagamentoRealizado}');
        print('  Pagamento em atraso: ${detalhesResponse.pagamentoEmAtraso}');
        print('  Quantidade de débitos: ${detalhesResponse.quantidadeDebitos}');

        print('  Débitos pagos:');
        for (var debito in detalhes.pagamentoDebitos.take(3)) {
          print('    Período: ${debito.paDebitoFormatado}');
          print('    Processo: ${debito.processo}');
          print('    Valor total: ${debito.valorTotalDebitoFormatado}');
          print('    Discriminações:');
          for (var disc in debito.discriminacoesDebito) {
            print('      - Tributo: ${disc.tributo}');
            print('        Principal: ${disc.principalFormatado}');
            print('        Multa: ${disc.multaFormatada}');
            print('        Juros: ${disc.jurosFormatados}');
            print('        Total: ${disc.totalFormatado}');
            print('        Ente federado: ${disc.enteFederadoDestino}');
            print('        Tem multa: ${disc.temMulta}');
            print('        Tem juros: ${disc.temJuros}');
            print('        % Multa: ${disc.percentualMulta.toStringAsFixed(2)}%');
            print('        % Juros: ${disc.percentualJuros.toStringAsFixed(2)}%');
          }
          print('');
        }

        print('Valor total dos débitos: ${detalhes.valorTotalDebitosFormatado}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar detalhes de pagamento: $e');
    servicoOk = false;
  }

  // 5. Emitir DAS
  try {
    print('\n--- 5. Emitir DAS ---');
    final emitirResponse = await parcmeiService.emitirDas(202107);
    print('✅ Status: ${emitirResponse.status}');
    print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Sucesso: ${emitirResponse.sucesso}');
    print('Mensagem principal: ${emitirResponse.mensagemPrincipal}');
    print('PDF gerado com sucesso: ${emitirResponse.pdfGeradoComSucesso}');

    if (emitirResponse.sucesso && emitirResponse.pdfGeradoComSucesso) {
      final dados = emitirResponse.dadosParsed;
      if (dados != null) {
        print('Dados do DAS:');
        print('  Tem PDF: ${dados.temPdf}');
        print('  Tamanho Base64: ${dados.tamanhoBase64} caracteres');
        print('  Tamanho estimado PDF: ${dados.tamanhoEstimadoPdf} bytes');
        print('  Base64 válido: ${dados.base64Valido}');
        print('  Parece PDF válido: ${dados.parecePdfValido}');
        print('  Preview Base64: ${dados.base64Preview}');
      }

      final pdfBytes = emitirResponse.pdfBytes;
      print('PDF bytes: ${pdfBytes != null ? 'Disponível' : 'Não disponível'}');
      print('Tamanho PDF: ${emitirResponse.tamanhoPdfFormatado}');
      print('PDF válido: ${emitirResponse.pdfValido}');
      print('Hash do PDF: ${emitirResponse.pdfHash}');

      final pdfInfo = emitirResponse.pdfInfo;
      if (pdfInfo != null) {
        print('Informações do PDF:');
        pdfInfo.forEach((key, value) {
          print('  $key: $value');
        });
      }
    }
  } catch (e) {
    print('❌ Erro ao emitir DAS: $e');
    servicoOk = false;
  }

  // 6. Validações
  try {
    print('\n--- 6. Validações ---');
    print('✅ Validação número parcelamento (1): ${parcmeiService.validarNumeroParcelamento(1)}');
    print('✅ Validação número parcelamento (null): ${parcmeiService.validarNumeroParcelamento(null)}');
    print('✅ Validação ano/mês parcela (202306): ${parcmeiService.validarAnoMesParcela(202306)}');
    print('✅ Validação ano/mês parcela (202313): ${parcmeiService.validarAnoMesParcela(202313)}');
    print('✅ Validação parcela para emitir (202306): ${parcmeiService.validarParcelaParaEmitir(202306)}');
    print('✅ Validação prazo emissão (202306): ${parcmeiService.validarPrazoEmissaoParcela(202306)}');
    print('✅ Validação CNPJ (00000000000000): ${parcmeiService.validarCnpjContribuinte('00000000000000')}');
    print('✅ Validação tipo contribuinte (2): ${parcmeiService.validarTipoContribuinte(2)}');
    print('✅ Validação tipo contribuinte (1): ${parcmeiService.validarTipoContribuinte(1)}');
    print('✅ Validação parcela disponível (202306): ${parcmeiService.validarParcelaDisponivelParaEmissao(202306)}');
    print('✅ Validação período apuração (202306): ${parcmeiService.validarPeriodoApuracao(202306)}');
    print('✅ Validação data formato (20230615): ${parcmeiService.validarDataFormato(20230615)}');
    print('✅ Validação valor monetário (100.50): ${parcmeiService.validarValorMonetario(100.50)}');
    print('✅ Validação sistema (PARCMEI): ${parcmeiService.validarSistema('PARCMEI')}');
    print('✅ Validação serviço (PEDIDOSPARC203): ${parcmeiService.validarServico('PEDIDOSPARC203')}');
    print('✅ Validação versão sistema (1.0): ${parcmeiService.validarVersaoSistema('1.0')}');
  } catch (e) {
    print('❌ Erro nas validações: $e');
    servicoOk = false;
  }

  // 7. Análise de Erros
  try {
    print('\n--- 7. Análise de Erros ---');
    final avisos = parcmeiService.getAvisos();
    print('✅ Avisos disponíveis: ${avisos.length}');
    for (var aviso in avisos.take(3)) {
      print('  - ${aviso.codigo}: ${aviso.descricao}');
    }

    final entradasIncorretas = parcmeiService.getEntradasIncorretas();
    print('✅ Entradas incorretas disponíveis: ${entradasIncorretas.length}');
    for (var entrada in entradasIncorretas.take(3)) {
      print('  - ${entrada.codigo}: ${entrada.descricao}');
    }

    final erros = parcmeiService.getErros();
    print('✅ Erros disponíveis: ${erros.length}');
    for (var erro in erros.take(3)) {
      print('  - ${erro.codigo}: ${erro.descricao}');
    }

    final sucessos = parcmeiService.getSucessos();
    print('✅ Sucessos disponíveis: ${sucessos.length}');
    for (var sucesso in sucessos.take(3)) {
      print('  - ${sucesso.codigo}: ${sucesso.descricao}');
    }

    // Exemplo de análise de erro
    final analiseErro = parcmeiService.analyzeError('[Sucesso-PARCMEI]', 'Requisição efetuada com sucesso.');
    print('✅ Análise de erro:');
    print('  Código: ${analiseErro.codigo}');
    print('  Mensagem: ${analiseErro.mensagem}');
    print('  Categoria: ${analiseErro.categoria}');
    print('  Conhecido: ${analiseErro.isKnownError}');
    print('  Sucesso: ${analiseErro.isSucesso}');
    print('  Erro: ${analiseErro.isErro}');
    print('  Aviso: ${analiseErro.isAviso}');
    print('  Solução: ${analiseErro.solucao ?? 'N/A'}');
  } catch (e) {
    print('❌ Erro na análise de erros: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PARCMEI ===');
  if (servicoOk) {
    print('✅ Serviço PARCMEI: OK');
  } else {
    print('❌ Serviço PARCMEI: ERRO');
  }

  print('\n=== Exemplos PARCMEI Concluídos ===');
}
