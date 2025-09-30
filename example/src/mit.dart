import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Mit(ApiClient apiClient) async {
  print('\n=== Exemplos MIT (Módulo de Inclusão de Tributos) ===');

  final mitService = MitService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo
  bool servicoOk = true;

  // 1. Criar Apuração Sem Movimento
  try {
    print('\n1. Criando apuração sem movimento...');
    final responsavelApuracao = ResponsavelApuracao(cpfResponsavel: '12345678901', emailResponsavel: 'responsavel@exemplo.com');

    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    final apuracaoSemMovimento = await mitService.criarApuracaoSemMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
    );

    print('✅ Status: ${apuracaoSemMovimento.status}');
    print('Sucesso: ${apuracaoSemMovimento.sucesso}');
    if (apuracaoSemMovimento.sucesso) {
      print('Protocolo: ${apuracaoSemMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoSemMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoSemMovimento.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao criar apuração sem movimento: $e');
    servicoOk = false;
  }

  // 2. Criar Apuração Com Movimento
  try {
    print('\n2. Criando apuração com movimento...');
    final debitoIrpj = Debito(idDebito: 1, codigoDebito: '236208', valorDebito: 100.00);

    final debitoCsll = Debito(idDebito: 2, codigoDebito: '248408', valorDebito: 220.00);

    final debitos = Debitos(
      irpj: ListaDebitosIrpj(listaDebitos: [debitoIrpj]),
      csll: ListaDebitosCsll(listaDebitos: [debitoCsll]),
    );

    final responsavelApuracao = ResponsavelApuracao(cpfResponsavel: '12345678901', emailResponsavel: 'responsavel@exemplo.com');
    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    final apuracaoComMovimento = await mitService.criarApuracaoComMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
      debitos: debitos,
    );

    print('✅ Status: ${apuracaoComMovimento.status}');
    print('Sucesso: ${apuracaoComMovimento.sucesso}');
    if (apuracaoComMovimento.sucesso) {
      print('Protocolo: ${apuracaoComMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoComMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoComMovimento.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao criar apuração com movimento: $e');
    servicoOk = false;
  }

  // 3. Consultar Situação de Encerramento
  try {
    print('\n3. Consultando situação de encerramento...');
    final situacaoResponse = await mitService.consultarSituacaoEncerramento(
      contribuinteNumero: cnpjContribuinte,
      protocoloEncerramento: 'protocolo_exemplo',
    );

    print('✅ Status: ${situacaoResponse.status}');
    print('Sucesso: ${situacaoResponse.sucesso}');
    if (situacaoResponse.sucesso) {
      print('ID Apuração: ${situacaoResponse.idApuracao}');
      print('Situação: ${situacaoResponse.textoSituacao}');
      print('Data Encerramento: ${situacaoResponse.dataEncerramento}');
      if (situacaoResponse.avisosDctf != null) {
        print('Avisos DCTF: ${situacaoResponse.avisosDctf!.join(', ')}');
      }
    } else {
      print('Erro: ${situacaoResponse.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar situação de encerramento: $e');
    servicoOk = false;
  }

  // 4. Consultar Apuração
  try {
    print('\n4. Consultando dados da apuração...');
    final consultaResponse = await mitService.consultarApuracao(contribuinteNumero: cnpjContribuinte, idApuracao: 12345);

    print('✅ Status: ${consultaResponse.status}');
    print('Sucesso: ${consultaResponse.sucesso}');
    if (consultaResponse.sucesso) {
      print('Situação: ${consultaResponse.textoSituacao}');
      if (consultaResponse.dadosApuracaoMit != null) {
        print('Dados da apuração encontrados: ${consultaResponse.dadosApuracaoMit!.length} registros');
      }
    } else {
      print('Erro: ${consultaResponse.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar apuração: $e');
    servicoOk = false;
  }

  // 5. Listar Apurações por Ano
  try {
    print('\n5. Listando apurações por ano...');
    final listagemResponse = await mitService.listarApuracaoes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('✅ Status: ${listagemResponse.status}');
    print('Sucesso: ${listagemResponse.sucesso}');
    if (listagemResponse.sucesso) {
      print('Apurações encontradas: ${listagemResponse.apuracoes?.length ?? 0}');
      if (listagemResponse.apuracoes != null) {
        for (final apuracao in listagemResponse.apuracoes!) {
          print('  - Período: ${apuracao.periodoApuracao}, ID: ${apuracao.idApuracao}, Situação: ${apuracao.situacaoEnum?.descricao}');
        }
      }
    } else {
      print('Erro: ${listagemResponse.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao listar apurações por ano: $e');
    servicoOk = false;
  }

  // 6. Consultar Apurações por Mês
  try {
    print('\n6. Consultando apurações por mês...');
    final listagemMesResponse = await mitService.consultarApuracaoesPorMes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025, mesApuracao: 1);

    print('✅ Status: ${listagemMesResponse.status}');
    print('Sucesso: ${listagemMesResponse.sucesso}');
    if (listagemMesResponse.sucesso) {
      print('Apurações do mês: ${listagemMesResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemMesResponse.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar apurações por mês: $e');
    servicoOk = false;
  }

  // 7. Consultar Apurações Encerradas
  try {
    print('\n7. Consultando apurações encerradas...');
    final listagemEncerradasResponse = await mitService.consultarApuracaoesEncerradas(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('✅ Status: ${listagemEncerradasResponse.status}');
    print('Sucesso: ${listagemEncerradasResponse.sucesso}');
    if (listagemEncerradasResponse.sucesso) {
      print('Apurações encerradas: ${listagemEncerradasResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemEncerradasResponse.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar apurações encerradas: $e');
    servicoOk = false;
  }

  // 8. Aguardar Encerramento (exemplo com timeout curto)
  try {
    print('\n8. Aguardando encerramento (timeout de 60 segundos)...');
    final aguardarResponse = await mitService.aguardarEncerramento(
      contribuinteNumero: cnpjContribuinte,
      protocoloEncerramento: 'protocolo_exemplo',
      timeoutSegundos: 60,
      intervaloConsulta: 10,
    );

    print('✅ Status final: ${aguardarResponse.status}');
    print('Situação final: ${aguardarResponse.textoSituacao}');
  } catch (e) {
    print('❌ Timeout ou erro ao aguardar encerramento: $e');
    servicoOk = false;
  }

  // 9. Exemplo com Eventos Especiais
  try {
    print('\n9. Criando apuração com evento especial...');
    final eventoEspecial = EventoEspecial(idEvento: 1, diaEvento: 15, tipoEvento: TipoEventoEspecial.fusao);

    final responsavelApuracao = ResponsavelApuracao(cpfResponsavel: '12345678901', emailResponsavel: 'responsavel@exemplo.com');
    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    final dadosIniciaisComEvento = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: QualificacaoPj.pjEmGeral,
      tributacaoLucro: TributacaoLucro.realAnual,
      variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
      regimePisCofins: RegimePisCofins.naoCumulativa,
      responsavelApuracao: responsavelApuracao,
    );

    final debitoIrpj = Debito(idDebito: 1, codigoDebito: '236208', valorDebito: 100.00);
    final debitoCsll = Debito(idDebito: 2, codigoDebito: '248408', valorDebito: 220.00);
    final debitos = Debitos(
      irpj: ListaDebitosIrpj(listaDebitos: [debitoIrpj]),
      csll: ListaDebitosCsll(listaDebitos: [debitoCsll]),
    );

    final apuracaoComEvento = await mitService.encerrarApuracao(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciaisComEvento,
      debitos: debitos,
      listaEventosEspeciais: [eventoEspecial],
    );

    print('✅ Status: ${apuracaoComEvento.status}');
    print('Sucesso: ${apuracaoComEvento.sucesso}');
    if (apuracaoComEvento.sucesso) {
      print('Protocolo: ${apuracaoComEvento.protocoloEncerramento}');
    } else {
      print('Erro: ${apuracaoComEvento.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao criar apuração com evento especial: $e');
    servicoOk = false;
  }

  // 10. Exemplo de Validação com Dados Inválidos
  try {
    print('\n10. Testando validação com dados inválidos...');
    try {
      PeriodoApuracao(
        mesApuracao: 13, // Mês inválido
        anoApuracao: 2025,
      );
    } catch (e) {
      print('✅ Validação de mês inválido: $e');
    }

    try {
      Debito(
        idDebito: 0, // ID inválido
        codigoDebito: '236208',
        valorDebito: -100.00, // Valor negativo
      );
    } catch (e) {
      print('✅ Validação de débito inválido: $e');
    }
  } catch (e) {
    print('❌ Erro na validação de dados: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO MIT ===');
  if (servicoOk) {
    print('✅ Serviço MIT: OK');
  } else {
    print('❌ Serviço MIT: ERRO');
  }

  print('\n=== Exemplos MIT Concluídos ===');
}
