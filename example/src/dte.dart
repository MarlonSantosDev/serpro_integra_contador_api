import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Dte(ApiClient apiClient) async {
  print('\n=== Exemplos DTE (Domicílio Tributário Eletrônico) ===');

  final dteService = DteService(apiClient);
  bool servicoOk = true;

  // 1. Exemplo básico - Consultar indicador DTE com CNPJ válido
  try {
    print('\n--- 1. Consultar Indicador DTE (CNPJ Válido) ---');
    final response = await dteService.obterIndicadorDte(
      '99999999999999',
      contratanteNumero: '11111111111111',
      autorPedidoDadosNumero: '11111111111111',
    );

    print('✅ Status HTTP: ${response.status}');
    print('Sucesso: ${response.sucesso}');
    print('Mensagem: ${response.mensagemPrincipal}');
    print('Código: ${response.codigoMensagem}');

    if (response.sucesso && response.dados != null) {
      final dados = response.dados!;
      print('Indicador de enquadramento: ${dados.indicadorEnquadramento}');
      print('  (Valor descritivo retornado diretamente)');
      print('  Possíveis valores:');
      print('    - "NI inválido"');
      print('    - "NI Não optante"');
      print('    - "NI Optante DTE"');
      print('    - "NI Optante Simples"');
      print('    - "NI Optante DTE e Simples"');
      print('Status de enquadramento: ${dados.statusEnquadramento}');
      print('Descrição do indicador: ${dados.indicadorDescricao} (mesmo valor)');
      print('É válido: ${dados.isIndicadorValido}');

      // Análise do enquadramento
      print('\nAnálise do enquadramento:');
      print('  - É optante DTE: ${response.isOptanteDte}');
      print('  - É optante Simples: ${response.isOptanteSimples}');
      print('  - É optante DTE e Simples: ${response.isOptanteDteESimples}');
      print('  - Não é optante: ${response.isNaoOptante}');
      print('  - NI inválido: ${response.isNiInvalido}');
    }
  } catch (e) {
    print('❌ Erro ao consultar DTE: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO DTE ===');
  if (servicoOk) {
    print('✅ Serviço DTE: OK');
  } else {
    print('❌ Serviço DTE: ERRO');
  }

  print('\n=== Exemplos DTE Concluídos ===');
}
