import '../lib/integra_contador_api.dart';

/// Exemplo de uso da API Integra Contador no ambiente de demonstração (trial)
/// para os serviços do DEFIS (Declaração de Informações Socioeconômicas e Fiscais)
void main() async {
  // 1. Configuração do serviço para o ambiente de demonstração
  // Usando o método createTrialService que já configura a URL correta e a chave de teste
  final service = IntegraContadorFactory.createTrialService();

  print('🚀 Iniciando exemplos da API Integra Contador - DEFIS (Ambiente de Demonstração)\n');

  // 2. Teste de conectividade
  await _testarConectividade(service);

  // 3. Consulta de declarações DEFIS
  await _exemploConsultaDeclaracoesDEFIS(service);

  // 4. Consultar última declaração DEFIS
  await _exemploConsultarUltimaDeclaracaoDEFIS(service);

  // 5. Consultar declaração DEFIS específica
  await _exemploConsultarDeclaracaoDEFIS(service);

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

/// Exemplo de consulta de declarações DEFIS
Future<void> _exemploConsultaDeclaracoesDEFIS(IntegraContadorExtendedService service) async {
  print('=== Consulta de Declarações DEFIS ===');

  final result = await service.consultarDeclaracoesDEFIS(documento: '00000000000000', anoCalendario: '2018');

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');

    final dados = result.data?.dados;
    if (dados != null) {
      print('Declarações encontradas: ${dados['declaracoes']?.length ?? 0}');

      final declaracoes = dados['declaracoes'] as List<dynamic>?;
      if (declaracoes != null && declaracoes.isNotEmpty) {
        print('\nPrimeira declaração:');
        print('Número: ${declaracoes[0]['numeroDeclaracao']}');
        print('Ano Calendário: ${declaracoes[0]['anoCalendario']}');
        print('Data: ${declaracoes[0]['dataHoraTransmissao']}');
      }
    } else {
      print('❌ Nenhuma declaração encontrada ${result}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta da última declaração DEFIS
Future<void> _exemploConsultarUltimaDeclaracaoDEFIS(IntegraContadorExtendedService service) async {
  print('=== Consulta da Última Declaração DEFIS ===');

  final result = await service.consultarUltimaDeclaracaoDEFIS(documento: '00000000000000', anoCalendario: '2018');

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');

    final dados = result.data?.dados;
    if (dados != null) {
      print('Número da Declaração: ${dados['numeroDeclaracao']}');
      print('Ano Calendário: ${dados['anoCalendario']}');
      print('Data/Hora Transmissão: ${dados['dataHoraTransmissao']}');
      print('Recibo: ${dados['recibo']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de declaração DEFIS específica
Future<void> _exemploConsultarDeclaracaoDEFIS(IntegraContadorExtendedService service) async {
  print('=== Consulta de Declaração DEFIS Específica ===');

  final result = await service.consultarDeclaracaoReciboDEFIS(documento: '00000000000000', numeroDeclaracao: '00000000201801');

  if (result.isSuccess) {
    print('✅ Consulta realizada com sucesso!');

    final dados = result.data?.dados;
    if (dados != null) {
      print('Número da Declaração: ${dados['numeroDeclaracao']}');
      print('Ano Calendário: ${dados['anoCalendario']}');
      print('Data/Hora Transmissão: ${dados['dataHoraTransmissao']}');
      print('Recibo: ${dados['recibo']}');

      // Informações adicionais específicas do DEFIS
      print('\nInformações Socioeconômicas:');
      print('Receita Bruta Total: R\$ ${dados['receitaBrutaTotal']}');
      print('Quantidade de Empregados: ${dados['quantidadeEmpregados']}');
      print('Capital Social: R\$ ${dados['capitalSocial']}');
    }
  } else {
    print('❌ Erro na consulta: ${result.error?.message}');
  }
  print('');
}
