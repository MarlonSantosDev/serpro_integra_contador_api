import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> AutenticaProcurador(ApiClient apiClient) async {
  print('=== Exemplo Autenticação de Procurador ===');
  print('Funcionalidade: Envio de XML assinado com o Termo de Autorização\n');

  final autenticaProcuradorService = AutenticaProcuradorService(apiClient);
  // Exemplo principal: Autenticação de Procurador
  try {
    print('--- Autenticando Procurador ---');

    final response = await autenticaProcuradorService.autenticarProcurador(
      contratanteNumero: '99999999999999',
      contratanteNome: 'EMPRESA EXEMPLO LTDA',
      autorPedidoDadosNumero: '00000000000000',
      autorPedidoDadosNome: 'JOÃO DA SILVA CONTADOR',
      contribuinteNumero: '11111111111111',
    );

    if (response.sucesso && response.autenticarProcuradorToken != null) {
      print('✅ Resultado da autenticação:');
      print('  - Token obtido: ${response.autenticarProcuradorToken}');
      print('  - Data de expiração: ${response.dataExpiracao}');
      print('  - Token em cache: ${response.isCacheValido}');
      print('O token pode ser usado nas próximas requisições da API.');
    } else {
      print('\n⚠️ Autenticação não foi bem-sucedida');
      print('Verifique os dados e tente novamente.');
    }
  } catch (e) {
    print('❌ Erro na autenticação: $e');
    print('(Esperado em ambiente de teste sem certificado digital real)');
  }

  print('\n=== Exemplo Autenticação de Procurador Concluído ===');
}
