import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Pgmei(ApiClient apiClient) async {
  print('=== TESTANDO TODOS OS SERVIÇOS PGMEI ===\n');

  final pgmeiService = PgmeiService(apiClient);
  int sucessos = 0;
  int erros = 0;

  // CNPJ de teste da documentação
  const cnpjContribuinte = '00000000000100';

  // ========================================
  // 1. GERARDASPDF21 - Gerar DAS com PDF
  // ========================================
  try {
    print('📋 1. GERARDASPDF21 - Gerar DAS com PDF');
    print('   CNPJ: $cnpjContribuinte');
    print('   Período: 201901');

    final response = await pgmeiService.gerarDas(
      cnpj: cnpjContribuinte,
      periodoApuracao: '201901',
    );

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final dasGerados = response.dasGerados;
      if (dasGerados != null && dasGerados.isNotEmpty) {
        final das = dasGerados.first;
        final detalhe = das.primeiroDetalhamento;

        if (detalhe != null) {
          print('   📄 PDF gerado: ${das.pdf.length} caracteres');
          print(
            '   💰 Valor total: R\$ ${detalhe.valores.total.toStringAsFixed(2)}',
          );
          print('   📅 Vencimento: ${formatarData(detalhe.dataVencimento)}');

          // Salvar PDF em arquivo
          final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
            das.pdf,
            'das_pgmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print(
            '   PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}',
          );

          if (detalhe.composicao != null) {
            print('   📊 Tributos:');
            for (final comp in detalhe.composicao!) {
              print('      ${comp.codigo}: ${comp.denominacao}');
              print(
                '        Valor: R\$ ${comp.valores.total.toStringAsFixed(2)}',
              );
            }
          }
        }
      }
      sucessos++;
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ===================================================
  // 2. GERARDASCODBARRA22 - Gerar DAS código barras
  // ===================================================
  try {
    print('\n📋 2. GERARDASCODBARRA22 - Gerar DAS código barras');
    print('   CNPJ: $cnpjContribuinte');
    print('   Período: 201901');

    final response = await pgmeiService.gerarDasCodigoBarras(
      cnpj: cnpjContribuinte,
      periodoApuracao: '201901',
    );

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final dasGerados = response.dasGerados;
      if (dasGerados != null && dasGerados.isNotEmpty) {
        final das = dasGerados.first;
        final detalhe = das.primeiroDetalhamento;

        if (detalhe != null) {
          print(
            '   🔲 Códigos de barras: ${detalhe.codigoDeBarras.length} segmentos',
          );
          print(
            '   💰 Valor total: R\$ ${detalhe.valores.total.toStringAsFixed(2)}',
          );
          print('   📅 Vencimento: ${formatarData(detalhe.dataVencimento)}');

          if (detalhe.codigoDeBarras.isNotEmpty) {
            print(
              '   📊 Código de barras: ${detalhe.codigoDeBarras.join(' ')}',
            );
          }
        }
      }
      sucessos++;
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ========================================
  // 3. ATUBENEFICIO23 - Atualizar Benefício
  // ========================================
  try {
    print('\n📋 3. ATUBENEFICIO23 - Atualizar Benefício');
    print('   CNPJ: $cnpjContribuinte');
    print('   Ano: 2021');
    print('   Períodos: 202101, 202102');

    final beneficios = [
      InfoBeneficio(periodoApuracao: '202101', indicadorBeneficio: true),
      InfoBeneficio(periodoApuracao: '202102', indicadorBeneficio: true),
    ];

    final response = await pgmeiService.atualizarBeneficio(
      cnpj: cnpjContribuinte,
      anoCalendario: 2021,
      beneficios: beneficios,
    );

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final beneficiosAtualizados = response.beneficiosAtualizados;
      if (beneficiosAtualizados != null && beneficiosAtualizados.isNotEmpty) {
        print('   📋 Benefícios atualizados:');
        for (final beneficio in beneficiosAtualizados) {
          print('      PA Original: ${beneficio.paOriginal}');
          print(
            '      Indicador: ${beneficio.indicadorBeneficio ? 'Sim' : 'Não'}',
          );
          print('      PA Agrupado: ${beneficio.paAgrupado}');
          print('      ---');
        }
      }
      sucessos++;
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ============================================
  // 4. DIVIDAATIVA24 - Consultar Dívida Ativa
  // ============================================
  try {
    print('\n📋 4. DIVIDAATIVA24 - Consultar Dívida Ativa');
    print('   CNPJ: $cnpjContribuinte');
    print('   Ano: 2020');

    final response = await pgmeiService.consultarDividaAtiva(
      cnpj: cnpjContribuinte,
      anoCalendario: '2020',
    );

    if (response.sucesso) {
      print('   ✅ Sucesso: ${response.mensagens.first.texto}');

      final debitosDividaAtiva = response.debitosDividaAtiva;
      if (response.temDebitosDividaAtiva) {
        print('   🚨 Situação: CONTRIBUINTE EM DÍVIDA ATIVA');
        print(
          '   💰 Valor total em dívida: R\$ ${response.valorTotalDividaAtiva.toStringAsFixed(2)}',
        );
        print('   📋 Débitos encontrados:');

        for (final debito in debitosDividaAtiva!) {
          print('      Período: ${debito.periodoApuracao}');
          print('      Tributo: ${debito.tributo}');
          print('      Valor: R\$ ${debito.valor.toStringAsFixed(2)}');
          print('      Ente: ${debito.enteFederado}');
          print('      Situação: ${debito.situacaoDebito}');
          print('      ---');
        }
      } else {
        print('   ✅ Situação: Contribuinte SEM dívida ativa');
      }
      sucessos++;
    } else {
      print('   ❌ Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // ============================================
  // TESTES ADICIONAIS COM MÉTODOS DE CONVENIÊNCIA
  // ============================================

  print('\n📋 TESTANDO MÉTODOS DE CONVENIÊNCIA');

  // Teste da interface moderna (sem deprecated)
  try {
    print('\n📋 5. Interface Moderna - Gerar DAS código barras');
    print('   CNPJ: $cnpjContribuinte');
    print('   Período: 202310');

    final response = await pgmeiService.gerarDasCodigoBarras(
      cnpj: cnpjContribuinte,
      periodoApuracao: '202310',
    );

    if (response.sucesso) {
      print(
        '   ✅ Interface moderna funcionando: ${response.mensagens.first.texto}',
      );
      sucessos++;
    } else {
      print(
        '   ❌ Interface moderna falhou: ${response.mensagens.map((m) => m.texto).join(', ')}',
      );
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção na interface moderna: $e');
    erros++;
  }

  await Future.delayed(const Duration(seconds: 3));

  // Teste do método simplificado para benefício único
  try {
    print('\n📋 6. Benefício Período Único');
    print('   CNPJ: $cnpjContribuinte');
    print('   Ano: 2021, Período: 202101');

    final response = await pgmeiService.atualizarBeneficioPeriodoUnico(
      cnpj: cnpjContribuinte,
      anoCalendario: 2021,
      periodoApuracao: '202101',
      indicadorBeneficio: true,
    );

    if (response.sucesso) {
      print(
        '   ✅ Benefício único atualizado: ${response.mensagens.first.texto}',
      );
      sucessos++;
    } else {
      print(
        '   ❌ Benefício único falhou: ${response.mensagens.map((m) => m.texto).join(', ')}',
      );
      erros++;
    }
  } catch (e) {
    print('   ❌ Exceção no benefício único: $e');
    erros++;
  }

  // ============================================
  // RESUMO FINAL DOS TESTES
  // ============================================

  print('\n' + '=' * 50);
  print('📊 RESUMO DOS TESTES PGMEI');
  print('=' * 50);
  print('✅ Sucessos: $sucessos');
  print('❌ Erros: $erros');
  print(
    '📈 Taxa de sucesso: ${((sucessos / (sucessos + erros)) * 100).toStringAsFixed(1)}%',
  );

  if (erros == 0) {
    print('🎉 TODOS OS SERVIÇOS PGMEI FUNCIONANDO PERFEITAMENTE!');
  } else if (sucessos > erros) {
    print('⚠️  Maioria dos serviços funcionando, alguns erros detectados');
  } else {
    print('🚨 Muitos erros detectados, verificar configuração da API');
  }

  print('\nServiços testados:');
  print('   • GERARDASPDF21 - Gerar DAS com PDF');
  print('   • GERARDASCODBARRA22 - Gerar DAS código barras');
  print('   • ATUBENEFICIO23 - Atualizar Benefício');
  print('   • DIVIDAATIVA24 - Consultar Dívida Ativa');
  print('   • Métodos de conveniência');

  print('\n🏁 Testes PGMEI concluídos!');
}

/// Formata data no formato AAAAMMDD para DD/MM/YYYY
String formatarData(String dataAaaammdd) {
  if (dataAaaammdd.length != 8) return dataAaaammdd;

  final ano = dataAaaammdd.substring(0, 4);
  final mes = dataAaaammdd.substring(4, 6);
  final dia = dataAaaammdd.substring(6, 8);

  return '$dia/$mes/$ano';
}
