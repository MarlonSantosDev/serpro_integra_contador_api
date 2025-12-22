import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplos de uso do serviço de Regime de Apuração
Future<void> Regime(ApiClient apiClient) async {
  print('\n=== SERVIÇO DE REGIME DE APURAÇÃO ===');

  // Inicializar o serviço
  final regimeService = RegimeApuracaoService(apiClient);
  bool servicoOk = true;
  // 1. Efetuar opção pelo regime de competência
  try {
    print('\n1. Efetuando opção pelo regime de competência (comentado)...');
    final opcaoCompetenciaResponse = await regimeService.efetuarOpcaoRegime(
      contribuinteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      anoOpcao: 2023,
      tipoRegime: TipoRegime.caixa,
      deAcordoResolucao: true,
    );
    if (opcaoCompetenciaResponse.isSuccess) {
      print("✅ Opção pelo regime de competência efetivada com sucesso!");
      if (opcaoCompetenciaResponse.dados != null) {
        final dados = opcaoCompetenciaResponse.dados!;
        print("CNPJ Matriz: ${dados.cnpjMatriz}");
        print("Regime escolhido: ${dados.regimeEscolhido}");
        print("Data da opção: ${dados.dataOpcao}");
        print("Demonstrativo PDF: ${dados.demonstrativoPdf?.isEmpty}");

        // Salvar PDF em arquivo se disponível
        if (dados.demonstrativoPdf != null &&
            dados.demonstrativoPdf!.isNotEmpty) {
          final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
            dados.demonstrativoPdf!,
            'demonstrativo_regime_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print("PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}");
        }
      }
    }
    print('✅ Exemplo documentado (não executado)');
  } catch (e) {
    print('❌ Erro no exemplo comentado: $e');
    servicoOk = false;
  }
  await Future.delayed(const Duration(seconds: 5));

  // 2. Consultar anos calendários com opções efetivadas
  try {
    print('\n2. Consultando anos calendários com opções efetivadas...');
    final anosResponse = await regimeService.consultarAnosCalendarios(
      contribuinteNumero: '00000000000000',
    );

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
  await Future.delayed(const Duration(seconds: 5));

  // 3. Consultar opção específica para um ano
  try {
    print('\n3. Consultando opção específica para o ano 2023...');
    final requestOpcao = ConsultarOpcaoRegimeRequest(anoCalendario: 2023);
    final opcaoResponse = await regimeService.consultarOpcaoRegime(
      contribuinteNumero: '00000000000000',
      request: requestOpcao,
    );

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

  // 4. Consultar resolução para regime de caixa
  try {
    print('\n4. Consultando resolução para regime de caixa (ano 2021)...');
    final requestResolucao = ConsultarResolucaoRequest(anoCalendario: 2021);
    final resolucaoResponse = await regimeService.consultarResolucao(
      contribuinteNumero: '00000000000000',
      request: requestResolucao,
    );

    if (resolucaoResponse.isSuccess) {
      print('✅ Consulta de resolução realizada com sucesso!');
      if (resolucaoResponse.hasData) {
        final dados = resolucaoResponse.dados!;
        print('Resolução disponível: ${dados.hasTextoResolucao}');
        if (dados.hasTextoResolucao) {
          print('Texto da resolução (primeiros 100 caracteres):');
          print(
            '  ${dados.textoResolucao.substring(0, dados.textoResolucao.length > 100 ? 100 : dados.textoResolucao.length)}...',
          );
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
    print('❌ Erro ao consultar resolução: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO REGIME DE APURAÇÃO ===');
  if (servicoOk) {
    print('✅ Serviço REGIME DE APURAÇÃO: OK');
  } else {
    print('❌ Serviço REGIME DE APURAÇÃO: ERRO');
  }

  print('\n=== FIM DOS EXEMPLOS DE REGIME DE APURAÇÃO ===');
}
