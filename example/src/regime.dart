import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplos de uso do serviço de Regime de Apuração
Future<void> Regime(ApiClient apiClient) async {
  print('\n=== SERVIÇO DE REGIME DE APURAÇÃO ===');

  // Inicializar o serviço
  final regimeService = RegimeApuracaoService(apiClient);
  final contribuinteNumero = '00000000000100'; // CNPJ de exemplo
  bool servicoOk = true;

  // 1. Consultar anos calendários com opções efetivadas
  try {
    print('\n1. Consultando anos calendários com opções efetivadas...');
    final anosResponse = await regimeService.consultarAnosCalendarios(contribuinteNumero: contribuinteNumero);

    if (anosResponse.isSuccess) {
      print('✅ Consulta de anos realizada com sucesso!');
      if (anosResponse.hasData) {
        print('Anos com opções efetivadas:');
        for (final ano in anosResponse.dados!) {
          print('  - ${ano.anoCalendario}: ${ano.regimeApurado}');
        }
      } else {
        print('Nenhuma opção de regime encontrada.');
      }
    } else {
      print('❌ Erro na consulta de anos:');
      for (final mensagem in anosResponse.mensagens) {
        print('  ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar anos calendários: $e');
    servicoOk = false;
  }

  // 2. Consultar opção específica para um ano
  try {
    print('\n2. Consultando opção específica para o ano 2023...');
    final opcaoResponse = await regimeService.consultarOpcaoPorAno(contribuinteNumero: contribuinteNumero, anoCalendario: 2023);

    if (opcaoResponse.isSuccess) {
      print('✅ Consulta de opção realizada com sucesso!');
      if (opcaoResponse.hasData) {
        final dados = opcaoResponse.dados!;
        print('Dados da opção:');
        print('  - CNPJ Matriz: ${dados.cnpjMatriz}');
        print('  - Ano Calendário: ${dados.anoCalendario}');
        print('  - Regime Escolhido: ${dados.regimeEscolhido}');
        print('  - Data/Hora Opção: ${dados.dataOpcao}');
        print('  - Tem Demonstrativo PDF: ${dados.hasDemonstrativoPdf}');
        print('  - Tem Texto Resolução: ${dados.hasTextoResolucao}');
      } else {
        print('Nenhuma opção encontrada para o ano 2023.');
      }
    } else {
      print('❌ Erro na consulta de opção:');
      for (final mensagem in opcaoResponse.mensagens) {
        print('  ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar opção por ano: $e');
    servicoOk = false;
  }

  // 3. Consultar resolução para regime de caixa
  try {
    print('\n3. Consultando resolução para regime de caixa (ano 2021)...');
    final resolucaoResponse = await regimeService.consultarResolucaoPorAno(contribuinteNumero: contribuinteNumero, anoCalendario: 2021);

    if (resolucaoResponse.isSuccess) {
      print('✅ Consulta de resolução realizada com sucesso!');
      if (resolucaoResponse.hasData) {
        final dados = resolucaoResponse.dados!;
        print('Resolução disponível: ${dados.hasTextoResolucao}');
        if (dados.hasTextoResolucao) {
          print('Texto da resolução (primeiros 100 caracteres):');
          print('  ${dados.textoResolucao.substring(0, dados.textoResolucao.length > 100 ? 100 : dados.textoResolucao.length)}...');
        }
      } else {
        print('Nenhuma resolução encontrada para o ano 2021.');
      }
    } else {
      print('❌ Erro na consulta de resolução:');
      for (final mensagem in resolucaoResponse.mensagens) {
        print('  ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar resolução por ano: $e');
    servicoOk = false;
  }

  // 4. Exemplo usando consultarOpcaoRegime (método principal)
  try {
    print('\n4. Exemplo usando consultarOpcaoRegime (método principal)...');
    final requestOpcao = ConsultarOpcaoRegimeRequest(anoCalendario: 2023);
    final opcaoResponsePrincipal = await regimeService.consultarOpcaoRegime(contribuinteNumero: contribuinteNumero, request: requestOpcao);

    if (opcaoResponsePrincipal.isSuccess) {
      print('✅ Consulta usando método principal realizada com sucesso!');
      if (opcaoResponsePrincipal.hasData) {
        final dados = opcaoResponsePrincipal.dados!;
        print('Dados da opção (método principal):');
        print('  - CNPJ Matriz: ${dados.cnpjMatriz}');
        print('  - Ano Calendário: ${dados.anoCalendario}');
        print('  - Regime Escolhido: ${dados.regimeEscolhido}');
        print('  - Tipo Regime: ${dados.tipoRegime?.descricao ?? 'N/A'}');
      } else {
        print('Nenhuma opção encontrada para o ano 2023 (método principal).');
      }
    } else {
      print('❌ Erro na consulta usando método principal:');
      for (final mensagem in opcaoResponsePrincipal.mensagens) {
        print('  ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar opção regime (método principal): $e');
    servicoOk = false;
  }

  // 5. Exemplo usando consultarResolucao (método principal)
  try {
    print('\n5. Exemplo usando consultarResolucao (método principal)...');
    final requestResolucao = ConsultarResolucaoRequest(anoCalendario: 2021);
    final resolucaoResponsePrincipal = await regimeService.consultarResolucao(contribuinteNumero: contribuinteNumero, request: requestResolucao);

    if (resolucaoResponsePrincipal.isSuccess) {
      print('✅ Consulta de resolução usando método principal realizada com sucesso!');
      if (resolucaoResponsePrincipal.hasData) {
        final dados = resolucaoResponsePrincipal.dados!;
        print('Resolução disponível (método principal): ${dados.hasTextoResolucao}');
        if (dados.hasTextoResolucao) {
          print('Texto da resolução (primeiros 100 caracteres):');
          print('  ${dados.textoResolucao.substring(0, dados.textoResolucao.length > 100 ? 100 : dados.textoResolucao.length)}...');
        }
      } else {
        print('Nenhuma resolução encontrada para o ano 2021 (método principal).');
      }
    } else {
      print('❌ Erro na consulta de resolução usando método principal:');
      for (final mensagem in resolucaoResponsePrincipal.mensagens) {
        print('  ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar resolução (método principal): $e');
    servicoOk = false;
  }

  // 6. Exemplo de efetuar opção pelo regime de competência (comentado para evitar execução real)
  try {
    print('\n6. Exemplo de efetuar opção pelo regime de competência (comentado)...');
    print('// Código comentado para evitar execução real:');
    print('// final opcaoCompetenciaResponse = await regimeService.efetuarOpcaoCompetencia(');
    print('//   contribuinteNumero: contribuinteNumero,');
    print('//   anoOpcao: 2024,');
    print('// );');
    print('// if (opcaoCompetenciaResponse.isSuccess) {');
    print('//   print("✅ Opção pelo regime de competência efetivada com sucesso!");');
    print('//   if (opcaoCompetenciaResponse.dados != null) {');
    print('//     final dados = opcaoCompetenciaResponse.dados!;');
    print('//     print("Regime escolhido: \${dados.regimeEscolhido}");');
    print('//     print("Data da opção: \${dados.dataOpcao}");');
    print('//   }');
    print('// }');
    print('✅ Exemplo documentado (não executado)');
  } catch (e) {
    print('❌ Erro no exemplo comentado: $e');
    servicoOk = false;
  }

  // 7. Exemplo de efetuar opção pelo regime de caixa (comentado para evitar execução real)
  try {
    print('\n7. Exemplo de efetuar opção pelo regime de caixa (comentado)...');
    print('// Código comentado para evitar execução real:');
    print('// final opcaoCaixaResponse = await regimeService.efetuarOpcaoCaixa(');
    print('//   contribuinteNumero: contribuinteNumero,');
    print('//   anoOpcao: 2024,');
    print('// );');
    print('// if (opcaoCaixaResponse.isSuccess) {');
    print('//   print("✅ Opção pelo regime de caixa efetivada com sucesso!");');
    print('//   if (opcaoCaixaResponse.dados != null) {');
    print('//     final dados = opcaoCaixaResponse.dados!;');
    print('//     print("Regime escolhido: \${dados.regimeEscolhido}");');
    print('//     print("Data da opção: \${dados.dataOpcao}");');
    print('//     print("Tem demonstrativo PDF: \${dados.hasDemonstrativoPdf}");');
    print('//     print("Tem texto resolução: \${dados.hasTextoResolucao}");');
    print('//   }');
    print('// }');
    print('✅ Exemplo documentado (não executado)');
  } catch (e) {
    print('❌ Erro no exemplo comentado: $e');
    servicoOk = false;
  }

  // 8. Exemplo usando efetuarOpcaoRegime (método principal) - comentado
  try {
    print('\n8. Exemplo usando efetuarOpcaoRegime (método principal) - comentado...');
    print('// Código comentado para evitar execução real:');
    print('// final requestCustomizado = EfetuarOpcaoRegimeRequest(');
    print('//   anoOpcao: 2024,');
    print('//   tipoRegime: TipoRegime.competencia.codigo,');
    print('//   descritivoRegime: TipoRegime.competencia.descricao,');
    print('//   deAcordoResolucao: true,');
    print('// );');
    print('// final responseCustomizado = await regimeService.efetuarOpcaoRegime(');
    print('//   contribuinteNumero: contribuinteNumero,');
    print('//   request: requestCustomizado,');
    print('// );');
    print('// if (responseCustomizado.isSuccess) {');
    print('//   print("✅ Opção efetivada usando método principal!");');
    print('//   if (responseCustomizado.dados != null) {');
    print('//     final dados = responseCustomizado.dados!;');
    print('//     print("Regime escolhido: \${dados.regimeEscolhido}");');
    print('//     print("Data da opção: \${dados.dataOpcao}");');
    print('//   }');
    print('// }');
    print('✅ Exemplo documentado (não executado)');
  } catch (e) {
    print('❌ Erro no exemplo comentado: $e');
    servicoOk = false;
  }

  // Resumo dos métodos utilizados
  print('\n=== RESUMO DOS MÉTODOS UTILIZADOS ===');
  print('✅ Métodos executados (consultas):');
  print('  1. consultarAnosCalendarios() - Consulta todos os anos com opções');
  print('  2. consultarOpcaoPorAno() - Consulta opção específica por ano (conveniência)');
  print('  3. consultarResolucaoPorAno() - Consulta resolução por ano (conveniência)');
  print('  4. consultarOpcaoRegime() - Consulta opção usando request (método principal)');
  print('  5. consultarResolucao() - Consulta resolução usando request (método principal)');
  print('');
  print('📝 Métodos documentados (comentados para evitar execução real):');
  print('  6. efetuarOpcaoCompetencia() - Efetua opção pelo regime de competência');
  print('  7. efetuarOpcaoCaixa() - Efetua opção pelo regime de caixa');
  print('  8. efetuarOpcaoRegime() - Efetua opção usando request (método principal)');
  print('');
  print('📋 Todos os 8 métodos do RegimeApuracaoService foram demonstrados!');

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO REGIME DE APURAÇÃO ===');
  if (servicoOk) {
    print('✅ Serviço REGIME DE APURAÇÃO: OK');
  } else {
    print('❌ Serviço REGIME DE APURAÇÃO: ERRO');
  }

  print('\n=== FIM DOS EXEMPLOS DE REGIME DE APURAÇÃO ===');
}
