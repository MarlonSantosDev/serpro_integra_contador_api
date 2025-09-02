import '../lib/integra_contador_api.dart';

/// Exemplo de uso da API Integra Contador no ambiente de demonstração (trial)
void main() async {
  // 1. Configuração do serviço para o ambiente de demonstração
  // Usando o método createTrialService que já configura a URL correta e a chave de teste
  final service = IntegraContadorFactory.createTrialService();

  print('🚀 Iniciando exemplos da API Integra Contador (Ambiente de Demonstração)\n');

  // 2. Teste de conectividade
  await _testarConectividade(service);

  // 3. Consulta de declarações PGDASD
  await _exemploConsultaDeclaracoesPGDASD(service);

  // 4. Gerar DAS do Simples Nacional
  await _exemploGerarDASSN(service);

  // 5. Consultar última declaração/recibo
  await _exemploConsultarUltimaDeclaracaoRecibo(service);

  // 6. Consultar declaração/recibo específico
  await _exemploConsultarDeclaracaoRecibo(service);

  // 7. Consultar extrato do DAS
  await _exemploConsultarExtratoDAS(service);

  // 8. Limpeza de recursos
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

/// Exemplo de consulta de declarações PGDASD
Future<void> _exemploConsultaDeclaracoesPGDASD(IntegraContadorExtendedService service) async {
  print('=== Consulta de Declarações PGDASD ===');

  final result = await service.consultarDeclaracoesSN(
    documento: '00000000000000',
    anoCalendario: '2018',
  );

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Declarações encontradas: ${dados['declaracoes']?.length ?? 0}');
      
      final declaracoes = dados['declaracoes'] as List<dynamic>?;
      if (declaracoes != null && declaracoes.isNotEmpty) {
        print('\nPrimeira declaração:');
        print('Número: ${declaracoes[0]['numeroDeclaracao']}');
        print('Período: ${declaracoes[0]['periodoApuracao']}');
        print('Data: ${declaracoes[0]['dataHoraTransmissao']}');
      }
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de geração de DAS do Simples Nacional
Future<void> _exemploGerarDASSN(IntegraContadorExtendedService service) async {
  print('=== Geração de DAS do Simples Nacional ===');

  final result = await service.gerarDASSN(
    documento: '00000000000100',
    periodoApuracao: '201801',
  );

  if (result.isSuccess) {
    print('✅ DAS gerado com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número do DAS: ${dados['numeroDas']}');
      print('Valor Total: R\$ ${dados['valorTotal']}');
      print('Data Vencimento: ${dados['dataVencimento']}');
      print('Código de Barras: ${dados['codigoBarras']}');
    }
  } else {
    print('❌ Erro na geração do DAS: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta da última declaração/recibo
Future<void> _exemploConsultarUltimaDeclaracaoRecibo(IntegraContadorExtendedService service) async {
  print('=== Consulta da Última Declaração/Recibo ===');

  final result = await service.consultarUltimaDeclaracaoSN(
    documento: '00000000000000',
    anoCalendario: '2018',
  );

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número da Declaração: ${dados['numeroDeclaracao']}');
      print('Período de Apuração: ${dados['periodoApuracao']}');
      print('Data/Hora Transmissão: ${dados['dataHoraTransmissao']}');
      print('Recibo: ${dados['recibo']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de declaração/recibo específico
Future<void> _exemploConsultarDeclaracaoRecibo(IntegraContadorExtendedService service) async {
  print('=== Consulta de Declaração/Recibo Específico ===');

  final result = await service.consultarDeclaracaoReciboSN(
    documento: '00000000000000',
    numeroDeclaracao: '00000000201801001',
  );

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número da Declaração: ${dados['numeroDeclaracao']}');
      print('Período de Apuração: ${dados['periodoApuracao']}');
      print('Data/Hora Transmissão: ${dados['dataHoraTransmissao']}');
      print('Recibo: ${dados['recibo']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de extrato do DAS
Future<void> _exemploConsultarExtratoDAS(IntegraContadorExtendedService service) async {
  print('=== Consulta de Extrato do DAS ===');

  final result = await service.consultarExtratoDAS(
    documento: '00000000000000',
    periodoApuracao: '201801',
  );

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Número do DAS: ${dados['numeroDas']}');
      print('Valor Total: R\$ ${dados['valorTotal']}');
      print('Data Vencimento: ${dados['dataVencimento']}');
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

