import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Parcsn(ApiClient apiClient) async {
  print('=== Exemplos PARCSN ===');

  final parcsnService = ParcsnService(apiClient);

  try {
    // 1. Consultar pedidos de parcelamento
    print('\n1. Consultando pedidos de parcelamento...');
    final pedidosResponse = await parcsnService.consultarPedidos();

    if (pedidosResponse.sucesso) {
      print('Status: ${pedidosResponse.status}');
      print('Mensagem: ${pedidosResponse.mensagemPrincipal}');

      if (pedidosResponse.temParcelamentos) {
        final parcelamentos = pedidosResponse.dadosParsed!.parcelamentos;
        print('Quantidade de parcelamentos: ${parcelamentos.length}');

        for (final parcelamento in parcelamentos) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
          print('  Ativo: ${parcelamento.isAtivo}');
        }
      } else {
        print('Nenhum parcelamento encontrado');
      }
    } else {
      print('Erro ao consultar pedidos: ${pedidosResponse.mensagemPrincipal}');
    }

    // 2. Consultar parcelamento específico
    print('\n2. Consultando parcelamento específico...');
    try {
      final parcelamentoResponse = await parcsnService.consultarParcelamento(1);

      if (parcelamentoResponse.sucesso) {
        print('Status: ${parcelamentoResponse.status}');
        print('Mensagem: ${parcelamentoResponse.mensagemPrincipal}');

        final parcelamento = parcelamentoResponse.dadosParsed;
        if (parcelamento != null) {
          print('Parcelamento ${parcelamento.numero}:');
          print('  Situação: ${parcelamento.situacao}');
          print('  Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
          print('  Data da situação: ${parcelamento.dataDaSituacaoFormatada}');
          print('  Consolidações originais: ${parcelamento.consolidacoesOriginais.length}');
          print('  Alterações de dívida: ${parcelamento.alteracoesDivida.length}');
          print('  Demonstrativos de pagamento: ${parcelamento.demonstrativosPagamento.length}');
        }
      } else {
        print('Erro ao consultar parcelamento: ${parcelamentoResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta de parcelamento: $e');
    }

    // 3. Consultar parcelas disponíveis para impressão
    print('\n3. Consultando parcelas disponíveis para impressão...');
    final parcelasResponse = await parcsnService.consultarParcelas();

    if (parcelasResponse.sucesso) {
      print('Status: ${parcelasResponse.status}');
      print('Mensagem: ${parcelasResponse.mensagemPrincipal}');

      if (parcelasResponse.temParcelas) {
        final parcelas = parcelasResponse.dadosParsed!.listaParcelas;
        print('Quantidade de parcelas: ${parcelas.length}');
        print('Valor total: ${parcelasResponse.valorTotalParcelasFormatado}');

        for (final parcela in parcelas) {
          print('Parcela ${parcela.parcelaFormatada}:');
          print('  Valor: ${parcela.valorFormatado}');
          print('  Vencimento: ${parcela.dataVencimentoFormatada}');
          print('  Situação: ${parcela.situacao}');
          print('  Vencida: ${parcela.isVencida}');
          print('  Dias de atraso: ${parcela.diasAtraso}');
        }
      } else {
        print('Nenhuma parcela disponível para impressão');
      }
    } else {
      print('Erro ao consultar parcelas: ${parcelasResponse.mensagemPrincipal}');
    }

    // 4. Consultar detalhes de pagamento
    print('\n4. Consultando detalhes de pagamento...');
    try {
      final detalhesResponse = await parcsnService.consultarDetalhesPagamento(1, 201612);

      if (detalhesResponse.sucesso) {
        print('Status: ${detalhesResponse.status}');
        print('Mensagem: ${detalhesResponse.mensagemPrincipal}');

        final detalhes = detalhesResponse.dadosParsed;
        if (detalhes != null) {
          print('DAS: ${detalhes.numeroDas}');
          print('Código de barras: ${detalhes.codigoBarras}');
          print('Valor pago: ${detalhes.valorPagoArrecadacaoFormatado}');
          print('Data de pagamento: ${detalhes.dataPagamentoFormatada}');
          print('Débitos pagos: ${detalhes.quantidadeDebitosPagos}');

          for (final debito in detalhes.pagamentosDebitos) {
            print('Débito ${debito.competencia}:');
            print('  Tipo: ${debito.tipoDebito}');
            print('  Valor total: ${debito.valorTotalFormatado}');
            print('  Valor principal: ${debito.valorPrincipalFormatado}');
            print('  Multa: ${debito.valorMultaFormatado}');
            print('  Juros: ${debito.valorJurosFormatado}');
            print('  Discriminações: ${debito.discriminacoes.length}');
          }
        }
      } else {
        print('Erro ao consultar detalhes: ${detalhesResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na consulta de detalhes: $e');
    }

    // 5. Emitir DAS
    print('\n5. Emitindo DAS...');
    try {
      final dasResponse = await parcsnService.emitirDas(202306);

      if (dasResponse.sucesso) {
        print('Status: ${dasResponse.status}');
        print('Mensagem: ${dasResponse.mensagemPrincipal}');

        if (dasResponse.pdfGeradoComSucesso) {
          final dasData = dasResponse.dadosParsed;
          if (dasData != null) {
            print('DAS emitido com sucesso!');
            print('Número do DAS: ${dasData.numeroDas}');
            print('Código de barras: ${dasData.codigoBarras}');
            print('Valor: ${dasData.valorFormatado}');
            print('Vencimento: ${dasData.dataVencimentoFormatada}');
            print('Tamanho do PDF: ${dasData.tamanhoPdfFormatado}');
            print('PDF disponível: ${dasData.temPdf}');
          }
        } else {
          print('PDF não foi gerado');
        }
      } else {
        print('Erro ao emitir DAS: ${dasResponse.mensagemPrincipal}');
      }
    } catch (e) {
      print('Erro na emissão do DAS: $e');
    }

    // 6. Exemplos de validações
    print('\n6. Testando validações...');

    // Validar número de parcelamento
    final validacaoParcelamento = parcsnService.validarNumeroParcelamento(0);
    if (validacaoParcelamento != null) {
      print('Validação parcelamento (0): $validacaoParcelamento');
    }

    // Validar ano/mês
    final validacaoAnoMes = parcsnService.validarAnoMesParcela(202313);
    if (validacaoAnoMes != null) {
      print('Validação ano/mês (202313): $validacaoAnoMes');
    }

    // Validar CNPJ
    final validacaoCnpj = parcsnService.validarCnpjContribuinte('12345678901234');
    if (validacaoCnpj != null) {
      print('Validação CNPJ (12345678901234): $validacaoCnpj');
    }

    // Validar tipo de contribuinte
    final validacaoTipo = parcsnService.validarTipoContribuinte(1);
    if (validacaoTipo != null) {
      print('Validação tipo (1): $validacaoTipo');
    }

    // 7. Exemplos de tratamento de erros
    print('\n7. Testando tratamento de erros...');

    // Verificar se erro é conhecido
    final erroConhecido = parcsnService.isKnownError('[Sucesso-PARCSN]');
    print('Erro conhecido ([Sucesso-PARCSN]): $erroConhecido');

    // Obter informações sobre erro
    final errorInfo = parcsnService.getErrorInfo('[Sucesso-PARCSN]');
    if (errorInfo != null) {
      print('Informações do erro:');
      print('  Código: ${errorInfo.codigo}');
      print('  Tipo: ${errorInfo.tipo}');
      print('  Categoria: ${errorInfo.categoria}');
      print('  Descrição: ${errorInfo.descricao}');
      print('  Solução: ${errorInfo.solucao}');
    }

    // Analisar erro
    final analysis = parcsnService.analyzeError('[Sucesso-PARCSN]', 'Requisição efetuada com sucesso.');
    print('Análise do erro:');
    print('  Código: ${analysis.codigo}');
    print('  Tipo: ${analysis.tipo}');
    print('  Categoria: ${analysis.categoria}');
    print('  Conhecido: ${analysis.isConhecido}');
    print('  É sucesso: ${analysis.isSucesso}');

    // Obter listas de erros
    final avisos = parcsnService.getAvisos();
    print('Avisos disponíveis: ${avisos.length}');

    final errosEntrada = parcsnService.getEntradasIncorretas();
    print('Erros de entrada incorreta: ${errosEntrada.length}');

    final erros = parcsnService.getErros();
    print('Erros gerais: ${erros.length}');

    final sucessos = parcsnService.getSucessos();
    print('Sucessos: ${sucessos.length}');

    print('\n=== Exemplos PARCSN Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos PARCSN: $e');
  }
}
