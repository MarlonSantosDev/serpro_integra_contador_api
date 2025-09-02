import '../lib/integra_contador_api.dart';

/// Exemplo de uso da API Integra Contador no ambiente de demonstração (trial)
/// para os serviços do REGIMEAPURACAO (Regime de Apuração do Simples Nacional)
void main() async {
  // 1. Configuração do serviço para o ambiente de demonstração
  // Usando o método createTrialService que já configura a URL correta e a chave de teste
  final service = IntegraContadorFactory.createTrialService();

  print('🚀 Iniciando exemplos da API Integra Contador - REGIMEAPURACAO (Ambiente de Demonstração)\n');

  // 2. Teste de conectividade
  await _testarConectividade(service);

  // 3. Consulta do regime de apuração
  await _exemploConsultarRegimeApuracao(service);

  // 4. Consulta do histórico de regimes de apuração
  await _exemploConsultarHistoricoRegimeApuracao(service);

  // 5. Limpeza de recursos
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

/// Exemplo de consulta do regime de apuração atual
Future<void> _exemploConsultarRegimeApuracao(IntegraContadorExtendedService service) async {
  print('=== Consulta do Regime de Apuração Atual ===');

  final pedido = PedidoDados(
    identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
    servico: 'REGIMEAPURACAO.CONSULTAR',
    parametros: {
      'periodo_apuracao': '202401',
    },
  );

  final result = await service.consultar(pedido);

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Regime de Apuração: ${dados['regimeApuracao']}');
      print('Período de Apuração: ${dados['periodoApuracao']}');
      print('Data de Início: ${dados['dataInicio']}');
      print('Situação: ${dados['situacao']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta do histórico de regimes de apuração
Future<void> _exemploConsultarHistoricoRegimeApuracao(IntegraContadorExtendedService service) async {
  print('=== Consulta do Histórico de Regimes de Apuração ===');

  final pedido = PedidoDados(
    identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
    servico: 'REGIMEAPURACAO.CONSULTAR_HISTORICO',
    parametros: {
      'ano_calendario': '2024',
    },
  );

  final result = await service.consultar(pedido);

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      final historico = dados['historico'] as List<dynamic>?;
      
      if (historico != null && historico.isNotEmpty) {
        print('Histórico de Regimes de Apuração:');
        
        for (var i = 0; i < historico.length; i++) {
          final regime = historico[i];
          print('\n${i+1}. Período: ${regime['periodoApuracao']}');
          print('   Regime: ${regime['regimeApuracao']}');
          print('   Data de Início: ${regime['dataInicio']}');
          print('   Situação: ${regime['situacao']}');
        }
      } else {
        print('Nenhum histórico encontrado.');
      }
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

