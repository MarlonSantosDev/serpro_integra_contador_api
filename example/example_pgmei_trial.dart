import '../lib/integra_contador_api.dart';

/// Exemplo de uso da API Integra Contador no ambiente de demonstração (trial)
/// para os serviços do PGMEI (Programa Gerador do Microempreendedor Individual)
void main() async {
  // 1. Configuração do serviço para o ambiente de demonstração
  // Usando o método createTrialService que já configura a URL correta e a chave de teste
  final service = IntegraContadorFactory.createTrialService();

  print('🚀 Iniciando exemplos da API Integra Contador - PGMEI (Ambiente de Demonstração)\n');

  // 2. Teste de conectividade
  await _testarConectividade(service);

  // 3. Consulta de DAS do MEI
  await _exemploConsultarDASMEI(service);

  // 4. Gerar DAS do MEI
  await _exemploGerarDASMEI(service);

  // 5. Consultar extrato do DAS do MEI
  await _exemploConsultarExtratoDASMEI(service);

  // 6. Limpeza de recursos
  service.dispose();

  print('\n✨ Todos os exemplos foram executados!');
}

/// Testa a conectividade com a API
Future<void> _testarConectividade(IntegraContadorExtendedService service) async {
  print('=== Teste de Conectividade ===');

  final result = await service.testarConectividade();

  if (result.isSuccess) {
    print('✅ Conectividade OK');
  } else {
    print('❌ Falha na conectividade: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de DAS do MEI
Future<void> _exemploConsultarDASMEI(IntegraContadorExtendedService service) async {
  print('=== Consulta de DAS do MEI ===');

  final pedido = PedidoDados(
    identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
    servico: 'PGMEI.CONSULTAR_DAS',
    parametros: {
      'periodo_apuracao': '202401',
    },
  );

  final result = await service.consultar(pedido);

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número do DAS: ${dados['numeroDas']}');
      print('Período de Apuração: ${dados['periodoApuracao']}');
      print('Valor Total: R\$ ${dados['valorTotal']}');
      print('Data de Vencimento: ${dados['dataVencimento']}');
      print('Situação: ${dados['situacao']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de geração de DAS do MEI
Future<void> _exemploGerarDASMEI(IntegraContadorExtendedService service) async {
  print('=== Geração de DAS do MEI ===');

  final pedido = PedidoDados(
    identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
    servico: 'PGMEI.GERAR_DAS',
    parametros: {
      'periodo_apuracao': '202401',
    },
  );

  final result = await service.emitir(pedido);

  if (result.isSuccess) {
    print('✅ DAS gerado com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número do DAS: ${dados['numeroDas']}');
      print('Valor Total: R\$ ${dados['valorTotal']}');
      print('Data de Vencimento: ${dados['dataVencimento']}');
      print('Código de Barras: ${dados['codigoBarras']}');
      print('Linha Digitável: ${dados['linhaDigitavel']}');
    }
  } else {
    print('❌ Erro na geração do DAS: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de extrato do DAS do MEI
Future<void> _exemploConsultarExtratoDASMEI(IntegraContadorExtendedService service) async {
  print('=== Consulta de Extrato do DAS do MEI ===');

  final pedido = PedidoDados(
    identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
    servico: 'PGMEI.CONSULTAR_EXTRATO',
    parametros: {
      'periodo_apuracao': '202401',
    },
  );

  final result = await service.consultar(pedido);

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número do DAS: ${dados['numeroDas']}');
      print('Valor Total: R\$ ${dados['valorTotal']}');
      print('Data de Vencimento: ${dados['dataVencimento']}');
      print('Situação: ${dados['situacao']}');
      
      final componentes = dados['componentes'] as List<dynamic>?;
      if (componentes != null && componentes.isNotEmpty) {
        print('\nComponentes do DAS:');
        for (var i = 0; i < componentes.length; i++) {
          final componente = componentes[i];
          print('${i+1}. ${componente['descricao']}: R\$ ${componente['valor']}');
        }
      }
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

