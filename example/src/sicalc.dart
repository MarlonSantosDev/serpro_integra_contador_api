import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Sicalc(ApiClient apiClient) async {
  print('=== TESTANDO TODOS OS SERVIÇOS SICALC ===\n');

  final sicalcService = SicalcService(apiClient);
  int erros = 0;

  // ========================================
  // 1. DARF PESSOA FÍSICA - Consolidar e emitir DARF de pessoa física
  // ========================================
  try {
    print('📋 1. DARF PESSOA FÍSICA - Consolidar e emitir DARF de pessoa física');

    final request = SicalcService.criarDarfPessoaFisica(
      contribuinteNumero: '99999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '0190',
      codigoReceitaExtensao: '01',
      tipoPA: 'ME',
      dataPA: '12/2017',
      vencimento: '2018-01-31T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      observacao: 'DARF calculado - Pessoa Física',
    );
    final response = await sicalcService.consolidarEmitirDarf(request, contratanteNumero: '99999999999999', autorPedidoDadosNumero: '99999999999');

    if (response.status == 200) {
      print('   ✅ Sucesso: DARF consolidado e emitido');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.consolidado != null) {
        print('   💰 Dados consolidados:');
        print('      Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}');
        print('      Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}');
        print('      Valor multa: R\$ ${response.consolidado!.valorMultaMora.toStringAsFixed(2)}');
        print('      Percentual multa: ${response.consolidado!.percentualMultaMora.toStringAsFixed(2)}%');
        print('      Valor juros: R\$ ${response.consolidado!.valorJuros.toStringAsFixed(2)}');
        print('      Percentual juros: ${response.consolidado!.percentualJuros.toStringAsFixed(2)}%');
        print('      Termo inicial juros: ${response.consolidado!.termoInicialJuros}');
        print('      Data arrecadação: ${response.consolidado!.dataArrecadacaoConsolidacao}');
        print('      Data validade: ${response.consolidado!.dataValidadeCalculo}');
      }

      if (response.darf != null) {
        print('   📄 PDF do DARF gerado: ${response.darf!.length} caracteres');

        // Salvar PDF em arquivo
        final sucessoSalvamento = await PdfFileUtils.salvarPdf(response.darf!, 'darf_pessoa_fisica_${DateTime.now().millisecondsSinceEpoch}.pdf');
        print('   PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      if (response.numeroDocumento != null) {
        print('   🔢 Número do documento: ${response.numeroDocumento}');
      }
    } else {
      print('  ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ========================================
  // 2. DARF PESSOA JURÍDICA COM COTAS - Consolidar e emitir DARF de pessoa jurídica com cotas
  // ========================================
  try {
    print('\n📋 2. DARF PESSOA JURÍDICA COM COTAS - Consolidar e emitir DARF de pessoa jurídica com cotas');

    final request = SicalcService.criarDarfPessoaJuridica(
      contribuinteNumero: '99999999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '0220',
      codigoReceitaExtensao: '01',
      tipoPA: 'TR',
      dataPA: '04/2021',
      vencimento: '2022-02-01T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      cota: 1,
      observacao: 'DARF calculado - Pessoa Jurídica com cota',
    );

    final response = await sicalcService.consolidarEmitirDarf(request, contratanteNumero: '00000000000000', autorPedidoDadosNumero: '99999999999999');

    if (response.status == 200) {
      print('   ✅ Sucesso: DARF consolidado e emitido');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.consolidado != null) {
        print('   💰 Dados consolidados:');
        print('      Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}');
        print('      Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}');
        print('      Valor multa: R\$ ${response.consolidado!.valorMultaMora.toStringAsFixed(2)}');
        print('      Percentual multa: ${response.consolidado!.percentualMultaMora.toStringAsFixed(2)}%');
        print('      Valor juros: R\$ ${response.consolidado!.valorJuros.toStringAsFixed(2)}');
        print('      Percentual juros: ${response.consolidado!.percentualJuros.toStringAsFixed(2)}%');
      }

      if (response.darf != null) {
        print('   📄 PDF do DARF gerado: ${response.darf!.length} caracteres');

        // Salvar PDF em arquivo
        final sucessoSalvamento = await PdfFileUtils.salvarPdf(response.darf!, 'darf_sicalc_${DateTime.now().millisecondsSinceEpoch}.pdf');
        print('   PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      if (response.numeroDocumento != null) {
        print('   🔢 Número do documento: ${response.numeroDocumento}');
      }
    } else {
      print('   ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ========================================
  // 3. DARF PJ COM CÓDIGO BARRAS E QRCODE - DARF de Pessoa Jurídica com código de barras e QRCODE
  // ========================================
  try {
    print('\n📋 3. DARF PJ COM CÓDIGO BARRAS E QRCODE - DARF de Pessoa Jurídica com código de barras e QRCODE');

    final request = SicalcService.criarCodigoBarras(
      contribuinteNumero: '99999999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '1394',
      codigoReceitaExtensao: '01',
      tipoPA: 'ME',
      dataPA: '12/2017',
      vencimento: '2018-01-31T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      observacao: 'DARF com código de barras e QRCODE - Pessoa Jurídica',
    );

    final response = await sicalcService.gerarCodigoBarras(request, contratanteNumero: '99999999999999', autorPedidoDadosNumero: '99999999999999');

    if (response.status == 200) {
      print('   ✅ Sucesso: DARF com código de barras e QRCODE gerado');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.consolidado != null) {
        print('   💰 Dados consolidados:');
        print('      Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}');
        print('      Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}');
      }

      if (response.codigoDeBarras != null) {
        print('   📊 Código de barras gerado:');
        print('      Campo 1 com DV: ${response.codigoDeBarras!.campo1ComDV}');
        print('      Campo 2 com DV: ${response.codigoDeBarras!.campo2ComDV}');
        print('      Campo 3 com DV: ${response.codigoDeBarras!.campo3ComDV}');
        print('      Campo 4 com DV: ${response.codigoDeBarras!.campo4ComDV}');
        print('      Código 44: ${response.codigoDeBarras!.codigo44}');
      }

      if (response.numeroDocumento != null) {
        print('   🔢 Número do documento: ${response.numeroDocumento}');
      }
    } else {
      print('   ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));
  // ========================================
  // 4. CONSULTAR RECEITAS - Consultar receitas do SICALC
  // ========================================
  try {
    print('\n📋 4. CONSULTAR RECEITAS - Consultar receitas do SICALC');

    final request = SicalcService.criarConsultaReceitas(contribuinteNumero: '00000000000', codigoReceita: '6106');
    final response = await sicalcService.consultarReceitas(request, contratanteNumero: '00000000000000', autorPedidoDadosNumero: '00000000000000');

    if (response.status == 200) {
      print('   ✅ Sucesso: Consulta realizada com sucesso');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.receita != null) {
        print('   📋 Receita encontrada:');
        print('      Código: ${response.receita!.codigoReceita}');
        print('      Descrição: ${response.receita!.descricaoReceita}');
        print('      Extensões: ${response.receita!.extensoes.length}');

        for (int i = 0; i < response.receita!.extensoes.length; i++) {
          final extensao = response.receita!.extensoes[i];
          print('      Extensão ${i + 1}:');
          print('        Código: ${extensao.informacoes.codigoReceitaExtensao}');
          print('        Descrição: ${extensao.informacoes.descricaoReceitaExtensao}');
          print('        Permite código de barras: ${extensao.informacoes.codigoBarras}');
          print('        Calculado: ${extensao.informacoes.calculado}');
          print('        Manual: ${extensao.informacoes.manual}');
          print('        PF: ${extensao.informacoes.pf}');
          print('        PJ: ${extensao.informacoes.pj}');
        }
      }
    } else {
      print('   ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ========================================
  // 5. DARF PJ COM CÓDIGO BARRAS - DARF de Pessoa Jurídica com código de barras
  // ========================================
  try {
    print('\n📋 5. DARF PJ COM CÓDIGO BARRAS - DARF de Pessoa Jurídica com código de barras');

    final request = SicalcService.criarCodigoBarras(
      contribuinteNumero: '99999999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '1162',
      codigoReceitaExtensao: '01',
      tipoPA: 'TR',
      dataPA: '03/2021',
      vencimento: '2021-04-30T00:00:00',
      valorImposto: 1500.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      observacao: 'DARF com código de barras - Pessoa Jurídica',
    );

    final response = await sicalcService.gerarCodigoBarras(request, contratanteNumero: '99999999999999', autorPedidoDadosNumero: '99999999999999');

    if (response.status == 200) {
      print('   ✅ Sucesso: DARF com código de barras gerado');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.consolidado != null) {
        print('   💰 Dados consolidados:');
        print('      Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}');
        print('      Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}');
      }

      if (response.codigoDeBarras != null) {
        print('   📊 Código de barras gerado:');
        print('      Campo 1 com DV: ${response.codigoDeBarras!.campo1ComDV}');
        print('      Campo 2 com DV: ${response.codigoDeBarras!.campo2ComDV}');
        print('      Campo 3 com DV: ${response.codigoDeBarras!.campo3ComDV}');
        print('      Campo 4 com DV: ${response.codigoDeBarras!.campo4ComDV}');
        print('      Código 44: ${response.codigoDeBarras!.codigo44}');
      }

      if (response.numeroDocumento != null) {
        print('   🔢 Número do documento: ${response.numeroDocumento}');
      }
    } else {
      print('   ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ========================================
  // 6. DARF PJ MANUAL COM CÓDIGO BARRAS - DARF de Pessoa Jurídica manual com código de barras
  // ========================================
  try {
    print('\n📋 6. DARF PJ MANUAL COM CÓDIGO BARRAS - DARF de Pessoa Jurídica manual com código de barras');

    final request = SicalcService.criarDarfPessoaJuridica(
      contribuinteNumero: '99999999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '0190',
      codigoReceitaExtensao: '01',
      tipoPA: 'ME',
      dataPA: '05/2021',
      vencimento: '2021-06-30T00:00:00',
      valorImposto: 2000.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      observacao: 'DARF manual com código de barras - Pessoa Jurídica',
    );

    final response = await sicalcService.consolidarEmitirDarf(request, contratanteNumero: '99999999999999', autorPedidoDadosNumero: '99999999999999');

    if (response.status == 200) {
      print('   ✅ Sucesso: DARF manual consolidado e emitido');

      if (response.mensagens != null) {
        print('   📝 Mensagens:');
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }

      if (response.consolidado != null) {
        print('   💰 Dados consolidados:');
        print('      Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}');
        print('      Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}');
        print('      Valor multa: R\$ ${response.consolidado!.valorMultaMora.toStringAsFixed(2)}');
        print('      Percentual multa: ${response.consolidado!.percentualMultaMora.toStringAsFixed(2)}%');
        print('      Valor juros: R\$ ${response.consolidado!.valorJuros.toStringAsFixed(2)}');
        print('      Percentual juros: ${response.consolidado!.percentualJuros.toStringAsFixed(2)}%');
      }

      if (response.darf != null) {
        print('   📄 PDF do DARF gerado: ${response.darf!.length} caracteres');

        // Salvar PDF em arquivo
        final sucessoSalvamento = await PdfFileUtils.salvarPdf(response.darf!, 'darf_sicalc_${DateTime.now().millisecondsSinceEpoch}.pdf');
        print('   PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      if (response.numeroDocumento != null) {
        print('   🔢 Número do documento: ${response.numeroDocumento}');
      }
    } else {
      print('   ❌ Erro: Status ${response.status}');
      if (response.mensagens != null) {
        for (final mensagem in response.mensagens!) {
          print('      ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  // ============================================
  // RESUMO FINAL DOS TESTES
  // ============================================

  if (erros == 0) {
    print('🎉✅ TODOS OS SERVIÇOS SICALC FUNCIONANDO PERFEITAMENTE!');
  } else {
    print('🚨 Muitos erros detectados, verificar configuração da API');
  }
  print('\n🏁 Testes SICALC concluídos!');
}
