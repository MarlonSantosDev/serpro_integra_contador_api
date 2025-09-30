import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Pgmei(ApiClient apiClient) async {
  print('=== Exemplos PGMEI ===');

  final pgmeiService = PgmeiService(apiClient);

  try {
    // 1. Gerar DAS Padrão
    try {
      print('\n--- 1. Gerar DAS Padrão ---');
      final response = await pgmeiService.gerarDas('00000000000100', '202310');
      print('✅ DAS gerado com sucesso Padrão');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS padrão: $e');
    }

    // 2. Gerar DAS com Código de Barras
    try {
      print('\n--- 2. Gerar DAS com Código de Barras ---');
      final response = await pgmeiService.gerarDasCodigoDeBarras('00000000000100', '202310');
      print('✅ DAS gerado com sucesso Código de Barras');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS com código de barras: $e');
    }

    // 3. Atualizar Benefício
    try {
      print('\n--- 3. Atualizar Benefício ---');
      final response = await pgmeiService.atualizarBeneficio('00000000000100', '202310');
      print('✅ Benefício atualizado com sucesso');

      if (response.dados.isNotEmpty) {
        print("📋 Response: ${response.dados.first.toJson()}");
      }
    } catch (e) {
      print('❌ Erro ao atualizar benefício: $e');
    }

    // 4. Consultar Dívida Ativa
    try {
      print('\n--- 4. Consultar Dívida Ativa ---');
      final response = await pgmeiService.consultarDividaAtiva('00000000000100', '2020');
      print('✅ Consulta de dívida ativa realizada com sucesso');

      if (response.dados.isNotEmpty) {
        final das = response.dados.first;
        print('💰 Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
      }
    } catch (e) {
      print('❌ Erro ao consultar dívida ativa: $e');
    }

    print('\n🎉 Todos os serviços PGMEI executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral nos serviços PGMEI: $e');
  }
}
