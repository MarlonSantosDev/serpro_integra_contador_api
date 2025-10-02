import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Sicalc(ApiClient apiClient) async {
  print("=== TESTE DOS SERVIÇOS SICALC ===\n");

  final sicalcService = SicalcService(apiClient);

  try {
    // Teste 1: Consultar receitas do SICALC
    await testarConsultarReceitas(sicalcService);

    // Teste 2: Consolidar e emitir DARF de pessoa física
    await testarConsolidarEmitirDarfPessoaFisica(sicalcService);

    // Teste 3: Consolidar e emitir DARF de pessoa jurídica
    await testarConsolidarEmitirDarfPessoaJuridica(sicalcService);

    // Teste 4: Gerar código de barras do DARF
    await testarGerarCodigoBarras(sicalcService);

    // Teste 5: Verificar se receita permite código de barras
    await testarReceitaPermiteCodigoBarras(sicalcService);

    // Teste 6: Obter informações da receita
    await testarObterInfoReceita(sicalcService);
  } catch (e) {
    print("❌ Erro geral nos testes SICALC: $e");
  }

  print("\n=== FIM DOS TESTES SICALC ===");
}

/// Teste 1: Consultar receitas do SICALC
Future<void> testarConsultarReceitas(SicalcService sicalcService) async {
  print("🔍 Teste 1: Consultar receitas do SICALC");

  try {
    final request = SicalcService.criarConsultaReceitas(contribuinteNumero: '00000000000', codigoReceita: '6106');

    final response = await sicalcService.consultarReceitas(request);

    print("✅ Status: ${response.status}");

    if (response.mensagens != null) {
      print("📝 Mensagens:");
      for (final mensagem in response.mensagens!) {
        print("   - ${mensagem.codigo}: ${mensagem.texto}");
      }
    }

    if (response.receita != null) {
      print("📋 Receita encontrada:");
      print("   - Código: ${response.receita!.codigoReceita}");
      print("   - Descrição: ${response.receita!.descricaoReceita}");
      print("   - Extensões: ${response.receita!.extensoes.length}");

      for (int i = 0; i < response.receita!.extensoes.length; i++) {
        final extensao = response.receita!.extensoes[i];
        print("   - Extensão ${i + 1}:");
        print("     * Código: ${extensao.informacoes.codigoReceitaExtensao}");
        print("     * Descrição: ${extensao.informacoes.descricaoReceitaExtensao}");
        print("     * Permite código de barras: ${extensao.informacoes.codigoBarras}");
        print("     * Calculado: ${extensao.informacoes.calculado}");
        print("     * Manual: ${extensao.informacoes.manual}");
        print("     * PF: ${extensao.informacoes.pf}");
        print("     * PJ: ${extensao.informacoes.pj}");
      }
    }
  } catch (e) {
    print("❌ Erro ao consultar receitas: $e");
  }

  print("");
}

/// Teste 2: Consolidar e emitir DARF de pessoa física
Future<void> testarConsolidarEmitirDarfPessoaFisica(SicalcService sicalcService) async {
  print("👤 Teste 2: Consolidar e emitir DARF de pessoa física");

  try {
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

    final response = await sicalcService.consolidarEmitirDarf(request);

    print("✅ Status: ${response.status}");

    if (response.mensagens != null) {
      print("📝 Mensagens:");
      for (final mensagem in response.mensagens!) {
        print("   - ${mensagem.codigo}: ${mensagem.texto}");
      }
    }

    if (response.consolidado != null) {
      print("💰 Dados consolidados:");
      print("   - Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}");
      print("   - Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}");
      print("   - Valor multa: R\$ ${response.consolidado!.valorMultaMora.toStringAsFixed(2)}");
      print("   - Percentual multa: ${response.consolidado!.percentualMultaMora.toStringAsFixed(2)}%");
      print("   - Valor juros: R\$ ${response.consolidado!.valorJuros.toStringAsFixed(2)}");
      print("   - Percentual juros: ${response.consolidado!.percentualJuros.toStringAsFixed(2)}%");
      print("   - Termo inicial juros: ${response.consolidado!.termoInicialJuros}");
      print("   - Data arrecadação: ${response.consolidado!.dataArrecadacaoConsolidacao}");
      print("   - Data validade: ${response.consolidado!.dataValidadeCalculo}");
    }

    if (response.darf != null) {
      print("📄 PDF do DARF gerado: ${response.darf!.length} caracteres");
    }

    if (response.numeroDocumento != null) {
      print("🔢 Número do documento: ${response.numeroDocumento}");
    }
  } catch (e) {
    print("❌ Erro ao consolidar e emitir DARF PF: $e");
  }

  print("");
}

/// Teste 3: Consolidar e emitir DARF de pessoa jurídica
Future<void> testarConsolidarEmitirDarfPessoaJuridica(SicalcService sicalcService) async {
  print("🏢 Teste 3: Consolidar e emitir DARF de pessoa jurídica");

  try {
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

    final response = await sicalcService.consolidarEmitirDarf(request);

    print("✅ Status: ${response.status}");

    if (response.mensagens != null) {
      print("📝 Mensagens:");
      for (final mensagem in response.mensagens!) {
        print("   - ${mensagem.codigo}: ${mensagem.texto}");
      }
    }

    if (response.consolidado != null) {
      print("💰 Dados consolidados:");
      print("   - Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}");
      print("   - Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}");
      print("   - Valor multa: R\$ ${response.consolidado!.valorMultaMora.toStringAsFixed(2)}");
      print("   - Percentual multa: ${response.consolidado!.percentualMultaMora.toStringAsFixed(2)}%");
      print("   - Valor juros: R\$ ${response.consolidado!.valorJuros.toStringAsFixed(2)}");
      print("   - Percentual juros: ${response.consolidado!.percentualJuros.toStringAsFixed(2)}%");
    }

    if (response.darf != null) {
      print("📄 PDF do DARF gerado: ${response.darf!.length} caracteres");
    }

    if (response.numeroDocumento != null) {
      print("🔢 Número do documento: ${response.numeroDocumento}");
    }
  } catch (e) {
    print("❌ Erro ao consolidar e emitir DARF PJ: $e");
  }

  print("");
}

/// Teste 4: Gerar código de barras do DARF
Future<void> testarGerarCodigoBarras(SicalcService sicalcService) async {
  print("📊 Teste 4: Gerar código de barras do DARF");

  try {
    final request = SicalcService.criarCodigoBarras(
      contribuinteNumero: '99999999999',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: '1394',
      codigoReceitaExtensao: '01',
      tipoPA: 'ME',
      dataPA: '12/2017',
      vencimento: '2018-01-31T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2022-08-08T00:00:00',
      observacao: 'Código de barras calculado',
    );

    final response = await sicalcService.gerarCodigoBarras(request);

    print("✅ Status: ${response.status}");

    if (response.mensagens != null) {
      print("📝 Mensagens:");
      for (final mensagem in response.mensagens!) {
        print("   - ${mensagem.codigo}: ${mensagem.texto}");
      }
    }

    if (response.consolidado != null) {
      print("💰 Dados consolidados:");
      print("   - Valor principal: R\$ ${response.consolidado!.valorPrincipalMoedaCorrente.toStringAsFixed(2)}");
      print("   - Valor total consolidado: R\$ ${response.consolidado!.valorTotalConsolidado.toStringAsFixed(2)}");
    }

    if (response.codigoDeBarras != null) {
      print("📊 Código de barras gerado:");
      print("   - Campo 1 com DV: ${response.codigoDeBarras!.campo1ComDV}");
      print("   - Campo 2 com DV: ${response.codigoDeBarras!.campo2ComDV}");
      print("   - Campo 3 com DV: ${response.codigoDeBarras!.campo3ComDV}");
      print("   - Campo 4 com DV: ${response.codigoDeBarras!.campo4ComDV}");
      print("   - Código 44: ${response.codigoDeBarras!.codigo44}");
    }

    if (response.numeroDocumento != null) {
      print("🔢 Número do documento: ${response.numeroDocumento}");
    }
  } catch (e) {
    print("❌ Erro ao gerar código de barras: $e");
  }

  print("");
}

/// Teste 5: Verificar se receita permite código de barras
Future<void> testarReceitaPermiteCodigoBarras(SicalcService sicalcService) async {
  print("🔍 Teste 5: Verificar se receita permite código de barras");

  try {
    final codigosReceita = ['0190', '0220', '1162', '1394', '6106'];

    for (final codigo in codigosReceita) {
      final permite = await sicalcService.receitaPermiteCodigoBarras(codigo);
      print("   - Receita $codigo: ${permite ? '✅ Permite' : '❌ Não permite'} código de barras");
    }
  } catch (e) {
    print("❌ Erro ao verificar receitas: $e");
  }

  print("");
}

/// Teste 6: Obter informações da receita
Future<void> testarObterInfoReceita(SicalcService sicalcService) async {
  print("📋 Teste 6: Obter informações da receita");

  try {
    final info = await sicalcService.obterInfoReceita('6106');

    if (info != null) {
      print("✅ Informações da receita ${info['codigoReceita']}:");
      print("   - Descrição: ${info['descricaoReceita']}");
      print("   - Extensões: ${info['extensoes'].length}");

      for (int i = 0; i < info['extensoes'].length; i++) {
        final extensao = info['extensoes'][i];
        print("   - Extensão ${i + 1}:");
        print("     * Código: ${extensao['informacoes']['codigoReceitaExtensao']}");
        print("     * Descrição: ${extensao['informacoes']['descricaoReceitaExtensao']}");
        print("     * Permite código de barras: ${extensao['informacoes']['codigoBarras']}");
        print("     * Calculado: ${extensao['informacoes']['calculado']}");
        print("     * Manual: ${extensao['informacoes']['manual']}");
        print("     * PF: ${extensao['informacoes']['pf']}");
        print("     * PJ: ${extensao['informacoes']['pj']}");
        print("     * Exige matriz: ${extensao['informacoes']['exigeMatriz']}");
        print("     * Veda valor: ${extensao['informacoes']['vedaValor']}");
      }
    } else {
      print("❌ Não foi possível obter informações da receita");
    }
  } catch (e) {
    print("❌ Erro ao obter informações da receita: $e");
  }

  print("");
}
