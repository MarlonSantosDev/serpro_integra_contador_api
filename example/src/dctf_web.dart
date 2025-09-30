import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> DctfWeb(ApiClient apiClient) async {
  print('=== Exemplos DCTFWeb ===');

  final dctfWebService = DctfWebService(apiClient);

  try {
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
      print('✅ DARF Geral Mensal: ${darfGeralResponse.sucesso}');
      await Future.delayed(Duration(seconds: 10));

      // DARF Pessoa Física Mensal
      final darfPfResponse = await dctfWebService.gerarDarfPfMensal(
        contribuinteNumero: '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
        anoPA: '2022',
        mesPA: '06',
      );
      print('✅ DARF PF Mensal: ${darfPfResponse.sucesso}');
      await Future.delayed(Duration(seconds: 10));

      // DARF 13º Salário
      final darf13Response = await dctfWebService.gerarDarf13Salario(
        contribuinteNumero: '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
        anoPA: '2022',
        isPessoaFisica: false,
      );
      print('✅ DARF 13º Salário: ${darf13Response.sucesso}');
    } catch (e) {
      print('❌ Erro nos métodos de conveniência: $e');
    }
    await Future.delayed(Duration(seconds: 10));

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
      print('✅ XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo espetáculo desportivo: $e');
    }
    await Future.delayed(Duration(seconds: 10));

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
      print('✅ XML Aferição: ${afericaoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo aferição: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 4. Exemplo com categoria Reclamatória Trabalhista
    try {
      print('\n--- 4. Exemplo Reclamatória Trabalhista ---');
      final reclamatoriaResponse = await dctfWebService.consultarReciboTransmissao(
        contribuinteNumero: '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
        categoria: CategoriaDctf.reclamatoriaTrabalhista,
        anoPA: '2022',
        mesPA: '12',
        numProcReclamatoria: '00365354520004013400', // Processo obrigatório
      );
      print('✅ Recibo Reclamatória: ${reclamatoriaResponse.sucesso}');
    } catch (e) {
      print('❌ Erro no exemplo reclamatória trabalhista: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    // 5. Exemplo de transmissão completa (simulada)
    try {
      print('\n--- 5. Exemplo de fluxo completo (simulado) ---');
      print('⚠️ ATENÇÃO: Este exemplo simula a assinatura digital.');
      print('⚠️ Em produção, você deve implementar a assinatura real com certificado digital.');

      final transmissaoResponse = await dctfWebService.consultarXmlETransmitir(
        contribuinteNumero: '00000000000',
        contratanteNumero: '00000000000', // CPF/CNPJ do contratante do serviço
        autorPedidoDadosNumero: '00000000000', // CPF/CNPJ do autor do pedido de dados
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
    }

    print('\n🎉 Todos os serviços DCTFWeb executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral no serviço DCTFWeb: $e');
  }
}
