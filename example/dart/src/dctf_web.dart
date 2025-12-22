import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> DctfWeb(ApiClient apiClient) async {
  print('=== Exemplos DCTFWeb ===');

  final dctfWebService = DctfWebService(apiClient);
  bool servicoOk = true;

  // 1. Métodos de conveniência
  try {
    print('\n--- 1. Métodos de conveniência ---');
    // DARF Geral Mensal
    final darfGeralResponse = await dctfWebService.gerarDarfGeralMensal(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      anoPA: '2027',
      mesPA: '11',
      idsSistemaOrigem: [SistemaOrigem.esocial, SistemaOrigem.mit],
    );
    if (darfGeralResponse.sucesso) {
      print('✅ DARF Geral Mensal: ${darfGeralResponse.sucesso}');
      print(
        'Mensagens: ${darfGeralResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        darfGeralResponse.pdfBase64!,
        'darf_geral_mensal_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ DARF Geral Mensal: ${darfGeralResponse.sucesso}');
    }
    await Future.delayed(Duration(seconds: 5));

    // DARF Pessoa Física Mensal
    final darfPfResponse = await dctfWebService.gerarDarfPfMensal(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      anoPA: '2022',
      mesPA: '06',
    );
    if (darfPfResponse.sucesso) {
      print('✅ DARF PF Mensal: ${darfPfResponse.sucesso}');
      print(
        'Mensagens: ${darfPfResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        darfPfResponse.pdfBase64!,
        'darf_pf_mensal_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ DARF PF Mensal: ${darfPfResponse.sucesso}');
    }
    await Future.delayed(Duration(seconds: 5));

    // DARF 13º Salário
    final darf13Response = await dctfWebService.gerarDarf13Salario(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      anoPA: '2022',
      isPessoaFisica: false,
    );
    if (darf13Response.sucesso) {
      print('✅ DARF 13º Salário: ${darf13Response.sucesso}');
      print(
        'Mensagens: ${darf13Response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        darf13Response.pdfBase64!,
        'darf_13_salario_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ DARF 13º Salário: ${darf13Response.sucesso}');
    }
    print('✅ DARF 13º Salário: ${darf13Response.sucesso}');
  } catch (e) {
    print('❌ Erro nos métodos de conveniência: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Exemplo com categoria específica - Espetáculo Desportivo
  try {
    print('\n--- 2. Exemplo Espetáculo Desportivo ---');
    final espetaculoResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000',
      contratanteNumero: '00000000000',
      autorPedidoDadosNumero: '00000000000',
      categoria: CategoriaDctf.espetaculoDesportivo,
      anoPA: '2022',
      mesPA: '05',
      diaPA: '14', // Dia obrigatório para espetáculo desportivo
    );
    if (espetaculoResponse.sucesso) {
      print('✅ XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');
      print(
        'Mensagens: ${espetaculoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        espetaculoResponse.xmlBase64!,
        'espetaculo_desportivo_${DateTime.now().millisecondsSinceEpoch}.xml',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');
    }
    print('✅ XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');
  } catch (e) {
    print('❌ Erro no exemplo espetáculo desportivo: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 3. Exemplo com categoria Aferição
  try {
    print('\n--- 3. Exemplo Aferição ---');
    final afericaoResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000',
      contratanteNumero: '00000000000',
      autorPedidoDadosNumero: '00000000000',
      categoria: CategoriaDctf.pfMensal,
      anoPA: '2022',
      mesPA: '06',
      //cnoAfericao: 28151, // CNO obrigatório para aferição
    );
    if (afericaoResponse.sucesso) {
      print('✅ XML Aferição: ${afericaoResponse.sucesso}');
      print(
        'Mensagens: ${afericaoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        afericaoResponse.xmlBase64!,
        'afericao_${DateTime.now().millisecondsSinceEpoch}.xml',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ XML Aferição: ${afericaoResponse.sucesso}');
    }
  } catch (e) {
    print('❌ Erro no exemplo aferição: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 4. Exemplo com categoria Reclamatória Trabalhista
  try {
    print('\n--- 4. Exemplo Reclamatória Trabalhista ---');
    final reclamatoriaResponse = await dctfWebService
        .consultarReciboTransmissao(
          contribuinteNumero: '00000000000000',
          contratanteNumero: '00000000000000',
          autorPedidoDadosNumero: '00000000000000',
          categoria: CategoriaDctf.reclamatoriaTrabalhista,
          anoPA: '2022',
          mesPA: '12',
          numProcReclamatoria: '00365354520004013400', // Processo obrigatório
        );
    if (reclamatoriaResponse.sucesso) {
      print('✅ Recibo Reclamatória: ${reclamatoriaResponse.sucesso}');
      print(
        'Mensagens: ${reclamatoriaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
      );
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        reclamatoriaResponse.pdfBase64!,
        'recibo_reclamatoria_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    } else {
      print('❌ Recibo Reclamatória: ${reclamatoriaResponse.sucesso}');
    }
  } catch (e) {
    print('❌ Erro no exemplo reclamatória trabalhista: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 5. Exemplo de transmissão completa (simulada)
  try {
    print('\n--- 5. Exemplo de fluxo completo (simulado) ---');
    print('⚠️ ATENÇÃO: Este exemplo simula a assinatura digital.');
    print(
      '⚠️ Em produção, você deve implementar a assinatura real com certificado digital.',
    );

    final transmissaoResponse = await dctfWebService.consultarXmlETransmitir(
      contribuinteNumero: '00000000000',
      contratanteNumero: '00000000000', // CPF/CNPJ do contratante do serviço
      autorPedidoDadosNumero:
          '00000000000', // CPF/CNPJ do autor do pedido de dados
      categoria: CategoriaDctf.pfMensal,
      anoPA: '2022',
      mesPA: '06',
      assinadorXml: (xmlBase64) async {
        // SIMULAÇÃO: Em produção, aqui você faria a assinatura digital real
        print('🔐 Simulando assinatura digital do XML...');

        // Esta é apenas uma simulação - NÃO USE EM PRODUÇÃO
        // Você deve implementar a assinatura digital real com seu certificado
        return xmlBase64 + '_ASSINADO_SIMULADO';
      },
    );

    print('✅ Transmissão simulada: ${transmissaoResponse.status}');
    print('📋 Tem MAED: ${transmissaoResponse.temMaed}');

    if (transmissaoResponse.infoTransmissao != null) {
      final info = transmissaoResponse.infoTransmissao!;
      print('📄 Número do recibo: ${info.numeroRecibo}');
      print('📅 Data transmissão: ${info.dataTransmissao}');
    }
  } catch (e) {
    print('⚠️ Erro na transmissão simulada (esperado): $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO DCTFWEB ===');
  if (servicoOk) {
    print('✅ Serviço DCTFWEB: OK');
  } else {
    print('❌ Serviço DCTFWEB: ERRO');
  }

  print('\n=== Exemplos DCTFWeb Concluídos ===');
}
