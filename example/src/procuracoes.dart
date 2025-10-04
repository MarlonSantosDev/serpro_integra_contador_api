import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Procuracoes(ApiClient apiClient) async {
  print('\n=== 🏢 TESTES PRINCIPAIS - SERPRO PROCURAÇÕES ELETRÔNICAS ===');
  print('PF→PF, PJ→PJ, PF→PJ com análise detalhada');

  final procuracoesService = ProcuracoesService(apiClient);
  bool servicoOk = true;

  // Dados de teste conforme documentação SERPRO
  const dadosTesteSerpro = <String, dynamic>{
    'contratante': '99999999999999', // CNPJ conforme documentação
    'autorPedidoDados': '99999999999999', // CNPJ conforme documentação
    'cpfTeste': '99999999999',
    'cnpjTeste': '99999999999999',
  };

  try {
    print('\n📋 === 1. TESTE PF → PF ===');

    final responsePfPf = await procuracoesService.obterProcuracaoPf(
      dadosTesteSerpro['cpfTeste'] as String,
      dadosTesteSerpro['cpfTeste'] as String,
      contratanteNumero: dadosTesteSerpro['contratante'] as String,
      autorPedidoDadosNumero: dadosTesteSerpro['autorPedidoDados'] as String,
    );

    print('✅ Status HTTP: ${responsePfPf.status}');
    print('✅ Sucesso: ${responsePfPf.sucesso}');
    print('✅ Mensagem: ${responsePfPf.mensagemPrincipal}');
    print('✅ Código Mensagem: ${responsePfPf.codigoMensagem}');

    if (responsePfPf.sucesso && responsePfPf.dadosParsed != null) {
      print('\n📊 📋 RESULTADOS DETALHADOS PF→PF:');
      final procuracoes = responsePfPf.dadosParsed!;
      print('🏷️  Total de procurações encontradas: ${procuracoes.length}');

      for (int i = 0; i < procuracoes.length; i++) {
        final proc = procuracoes[i];
        print('\n📄 Procuração ${i + 1}:');
        print('   📅 Data de expiração: ${proc.dataExpiracaoFormatada}');
        print('   🔢 Quantidade de sistemas: ${proc.nrsistemas}');
        print('   📂 Status: ${proc.status.value}');
        print('   ⚠️  Está expirada: ${proc.isExpirada ? 'Sim' : 'Não'}');
        print('   ⏰ Expira em breve: ${proc.expiraEmBreve ? 'Sim' : 'Não'}');
        print('   🛠️  Sistemas: ${proc.sistemasFormatados}');
        if (proc.dataExpiracaoDateTime != null) {
          print('   📆 Data como DateTime: ${proc.dataExpiracaoDateTime}');
        }
      }

      // Análise completa das procurações PF→PF
      print('\n📈 ANÁLISE ESTATÍSTICA PF→PF:');
      final analisePf = procuracoesService.analisarProcuracoes(responsePfPf);
      print('   🔢 Total: ${analisePf['total']}');
      print('   ✅ Ativas: ${analisePf['ativas']}');
      print('   ⚠️  Expirando em breve: ${analisePf['expiramEmBreve']}');
      print('   ❌ Expiradas: ${analisePf['expiradas']}');
      print('   🛠️  Sistemas únicos: ${analisePf['totalSistemasUnicos']}');

      // Relatório completo PF→PF
      print('\n📊 RELATÓRIO COMPLETO PF→PF:');
      print(procuracoesService.gerarRelatorio(responsePfPf));
    } else {
      print('ℹ️ Nenhuma procuração encontrada PF→PF');
    }
  } catch (e) {
    print('❌ Erro no teste PF → PF: $e');
    servicoOk = false;
  }

  await Future.delayed(Duration(seconds: 3));

  try {
    print('\n📋 === 2. TESTE PJ → PJ ===');

    final responsePjPj = await procuracoesService.obterProcuracaoPj(
      dadosTesteSerpro['cnpjTeste'] as String,
      dadosTesteSerpro['cnpjTeste'] as String,
      contratanteNumero: dadosTesteSerpro['contratante'] as String,
      autorPedidoDadosNumero: dadosTesteSerpro['autorPedidoDados'] as String,
    );

    print('✅ Status HTTP: ${responsePjPj.status}');
    print('✅ Sucesso: ${responsePjPj.sucesso}');
    print('✅ Mensagem: ${responsePjPj.mensagemPrincipal}');
    print('✅ Código Mensagem: ${responsePjPj.codigoMensagem}');

    if (responsePjPj.sucesso && responsePjPj.dadosParsed != null) {
      print('\n📊 📋 RESULTADOS DETALHADOS PJ→PJ:');
      final procuracoes = responsePjPj.dadosParsed!;
      print('🏷️  Total de procurações encontradas: ${procuracoes.length}');

      for (int i = 0; i < procuracoes.length; i++) {
        final proc = procuracoes[i];
        print('\n📄 Procuração ${i + 1}:');
        print('   📅 Data de expiração: ${proc.dataExpiracaoFormatada}');
        print('   🔢 Quantidade de sistemas: ${proc.nrsistemas}');
        print('   📂 Status: ${proc.status.value}');
        print('   ⚠️  Está expirada: ${proc.isExpirada ? 'Sim' : 'Não'}');
        print('   ⏰ Expira em breve: ${proc.expiraEmBreve ? 'Sim' : 'Não'}');
        print('   🛠️  Sistemas: ${proc.sistemasFormatados}');
        if (proc.dataExpiracaoDateTime != null) {
          print('   📆 Data como DateTime: ${proc.dataExpiracaoDateTime}');
        }
      }

      // Análise completa das procurações PJ→PJ
      print('\n📈 ANÁLISE ESTATÍSTICA PJ→PJ:');
      final analisePj = procuracoesService.analisarProcuracoes(responsePjPj);
      print('   🔢 Total: ${analisePj['total']}');
      print('   ✅ Ativas: ${analisePj['ativas']}');
      print('   ⚠️  Expirando em breve: ${analisePj['expiramEmBreve']}');
      print('   ❌ Expiradas: ${analisePj['expiradas']}');
      print('   🛠️  Sistemas únicos: ${analisePj['totalSistemasUnicos']}');

      // Relatório completo PJ→PJ
      print('\n📊 RELATÓRIO COMPLETO PJ→PJ:');
      print(procuracoesService.gerarRelatorio(responsePjPj));
    } else {
      print('ℹ️ Nenhuma procuração encontrada PJ→PJ');
    }
  } catch (e) {
    print('❌ Erro no teste PJ → PJ: $e');
    servicoOk = false;
  }

  await Future.delayed(Duration(seconds: 3));

  try {
    print('\n📋 === 3. TESTE PF → PJ (MISTA) ===');

    final responseMista = await procuracoesService.obterProcuracaoMista(
      dadosTesteSerpro['cpfTeste'] as String,
      dadosTesteSerpro['cnpjTeste'] as String,
      false, // outorgante é PF
      true, // procurador é PJ
      contratanteNumero: dadosTesteSerpro['contratante'] as String,
      autorPedidoDadosNumero: dadosTesteSerpro['autorPedidoDados'] as String,
    );

    print('✅ Status HTTP: ${responseMista.status}');
    print('✅ Sucesso: ${responseMista.sucesso}');
    print('✅ Mensagem: ${responseMista.mensagemPrincipal}');
    print('✅ Código Mensagem: ${responseMista.codigoMensagem}');

    if (responseMista.sucesso && responseMista.dadosParsed != null) {
      print('\n📊 📋 RESULTADOS DETALHADOS PF→PJ:');
      final procuracoes = responseMista.dadosParsed!;
      print('🏷️  Total de procurações encontradas: ${procuracoes.length}');

      for (int i = 0; i < procuracoes.length; i++) {
        final proc = procuracoes[i];
        print('\n📄 Procuração ${i + 1}:');
        print('   📅 Data de expiração: ${proc.dataExpiracaoFormatada}');
        print('   🔢 Quantidade de sistemas: ${proc.nrsistemas}');
        print('   📂 Status: ${proc.status.value}');
        print('   ⚠️  Está expirada: ${proc.isExpirada ? 'Sim' : 'Não'}');
        print('   ⏰ Expira em breve: ${proc.expiraEmBreve ? 'Sim' : 'Não'}');
        print('   🛠️  Sistemas: ${proc.sistemasFormatados}');
        if (proc.dataExpiracaoDateTime != null) {
          print('   📆 Data como DateTime: ${proc.dataExpiracaoDateTime}');
        }
      }

      // Análise completa das procurações PF→PJ
      print('\n📈 ANÁLISE ESTATÍSTICA PF→PJ:');
      final analiseMista = procuracoesService.analisarProcuracoes(responseMista);
      print('   🔢 Total: ${analiseMista['total']}');
      print('   ✅ Ativas: ${analiseMista['ativas']}');
      print('   ⚠️  Expirando em breve: ${analiseMista['expiramEmBreve']}');
      print('   ❌ Expiradas: ${analiseMista['expiradas']}');
      print('   🛠️  Sistemas únicos: ${analiseMista['totalSistemasUnicos']}');

      // Relatório completo PF→PJ
      print('\n📊 RELATÓRIO COMPLETO PF→PJ:');
      print(procuracoesService.gerarRelatorio(responseMista));
    } else {
      print('ℹ️ Nenhuma procuração encontrada PF→PJ');
    }
  } catch (e) {
    print('❌ Erro no teste PF → PJ: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n🎯 === RESUMO FINAL DO SERVIÇO PROCURAÇÕES ===');
  if (servicoOk) {
    print('   🎉 ✅ SERVIÇO PROCURAÇÕES: FUNCIONAL');
    print('      📊 PF→PF: Analisado');
    print('      📊 PJ→PJ: Analisado');
    print('      📊 PF→PJ: Analisado');
    print('      📊 Todos os testes com análise detalhada');
  } else {
    print('   ⚠️ ❌ SERVIÇO PROCURAÇÕES: REQUER ATENÇÃO');
    print('      🔧 Alguns testes falharam');
    print('      📋 Verifique logs acima para detalhes');
  }

  print('\n🏁 === TESTES PROCURAÇÕES CONCLUÍDOS ===\n');
  print('📚 Análise completa disponível nos relatórios acima');
}
