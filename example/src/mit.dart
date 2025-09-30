import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Mit(ApiClient apiClient) async {
  print('\n=== Exemplos MIT (Módulo de Inclusão de Tributos) ===');

  final mitService = MitService(apiClient);
  const cnpjContribuinte = '00000000000000'; // CNPJ de exemplo

  try {
    // 1. Criar Apuração Sem Movimento
    print('\n1. Criando apuração sem movimento...');
    final responsavelApuracao = ResponsavelApuracao(cpfResponsavel: '12345678901', emailResponsavel: 'responsavel@exemplo.com');

    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    final apuracaoSemMovimento = await mitService.criarApuracaoSemMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
    );

    print('Status: ${apuracaoSemMovimento.status}');
    print('Sucesso: ${apuracaoSemMovimento.sucesso}');
    if (apuracaoSemMovimento.sucesso) {
      print('Protocolo: ${apuracaoSemMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoSemMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoSemMovimento.mensagemErro}');
    }

    // 2. Criar Apuração Com Movimento
    print('\n2. Criando apuração com movimento...');
    final debitoIrpj = Debito(idDebito: 1, codigoDebito: '236208', valorDebito: 100.00);

    final debitoCsll = Debito(idDebito: 2, codigoDebito: '248408', valorDebito: 220.00);

    final debitos = Debitos(
      irpj: ListaDebitosIrpj(listaDebitos: [debitoIrpj]),
      csll: ListaDebitosCsll(listaDebitos: [debitoCsll]),
    );

    final apuracaoComMovimento = await mitService.criarApuracaoComMovimento(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      responsavelApuracao: responsavelApuracao,
      debitos: debitos,
    );

    print('Status: ${apuracaoComMovimento.status}');
    print('Sucesso: ${apuracaoComMovimento.sucesso}');
    if (apuracaoComMovimento.sucesso) {
      print('Protocolo: ${apuracaoComMovimento.protocoloEncerramento}');
      print('ID Apuração: ${apuracaoComMovimento.idApuracao}');
    } else {
      print('Erro: ${apuracaoComMovimento.mensagemErro}');
    }

    // 3. Consultar Situação de Encerramento
    if (apuracaoSemMovimento.protocoloEncerramento != null) {
      print('\n3. Consultando situação de encerramento...');
      final situacaoResponse = await mitService.consultarSituacaoEncerramento(
        contribuinteNumero: cnpjContribuinte,
        protocoloEncerramento: apuracaoSemMovimento.protocoloEncerramento!,
      );

      print('Status: ${situacaoResponse.status}');
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
    }

    // 4. Consultar Apuração
    if (apuracaoSemMovimento.idApuracao != null) {
      print('\n4. Consultando dados da apuração...');
      final consultaResponse = await mitService.consultarApuracao(contribuinteNumero: cnpjContribuinte, idApuracao: apuracaoSemMovimento.idApuracao!);

      print('Status: ${consultaResponse.status}');
      print('Sucesso: ${consultaResponse.sucesso}');
      if (consultaResponse.sucesso) {
        print('Situação: ${consultaResponse.textoSituacao}');
        if (consultaResponse.dadosApuracaoMit != null) {
          print('Dados da apuração encontrados: ${consultaResponse.dadosApuracaoMit!.length} registros');
        }
      } else {
        print('Erro: ${consultaResponse.mensagemErro}');
      }
    }

    // 5. Listar Apurações por Ano
    print('\n5. Listando apurações por ano...');
    final listagemResponse = await mitService.listarApuracaoes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('Status: ${listagemResponse.status}');
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

    // 6. Consultar Apurações por Mês
    print('\n6. Consultando apurações por mês...');
    final listagemMesResponse = await mitService.consultarApuracaoesPorMes(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025, mesApuracao: 1);

    print('Status: ${listagemMesResponse.status}');
    print('Sucesso: ${listagemMesResponse.sucesso}');
    if (listagemMesResponse.sucesso) {
      print('Apurações do mês: ${listagemMesResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemMesResponse.mensagemErro}');
    }

    // 7. Consultar Apurações Encerradas
    print('\n7. Consultando apurações encerradas...');
    final listagemEncerradasResponse = await mitService.consultarApuracaoesEncerradas(contribuinteNumero: cnpjContribuinte, anoApuracao: 2025);

    print('Status: ${listagemEncerradasResponse.status}');
    print('Sucesso: ${listagemEncerradasResponse.sucesso}');
    if (listagemEncerradasResponse.sucesso) {
      print('Apurações encerradas: ${listagemEncerradasResponse.apuracoes?.length ?? 0}');
    } else {
      print('Erro: ${listagemEncerradasResponse.mensagemErro}');
    }

    // 8. Aguardar Encerramento (exemplo com timeout curto)
    if (apuracaoSemMovimento.protocoloEncerramento != null) {
      print('\n8. Aguardando encerramento (timeout de 60 segundos)...');
      try {
        final aguardarResponse = await mitService.aguardarEncerramento(
          contribuinteNumero: cnpjContribuinte,
          protocoloEncerramento: apuracaoSemMovimento.protocoloEncerramento!,
          timeoutSegundos: 60,
          intervaloConsulta: 10,
        );

        print('Status final: ${aguardarResponse.status}');
        print('Situação final: ${aguardarResponse.textoSituacao}');
      } catch (e) {
        print('Timeout ou erro ao aguardar encerramento: $e');
      }
    }

    // 9. Exemplo com Eventos Especiais
    print('\n9. Criando apuração com evento especial...');
    final eventoEspecial = EventoEspecial(idEvento: 1, diaEvento: 15, tipoEvento: TipoEventoEspecial.fusao);

    final dadosIniciaisComEvento = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: QualificacaoPj.pjEmGeral,
      tributacaoLucro: TributacaoLucro.realAnual,
      variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
      regimePisCofins: RegimePisCofins.naoCumulativa,
      responsavelApuracao: responsavelApuracao,
    );

    final apuracaoComEvento = await mitService.encerrarApuracao(
      contribuinteNumero: cnpjContribuinte,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciaisComEvento,
      debitos: debitos,
      listaEventosEspeciais: [eventoEspecial],
    );

    print('Status: ${apuracaoComEvento.status}');
    print('Sucesso: ${apuracaoComEvento.sucesso}');
    if (apuracaoComEvento.sucesso) {
      print('Protocolo: ${apuracaoComEvento.protocoloEncerramento}');
    } else {
      print('Erro: ${apuracaoComEvento.mensagemErro}');
    }

    // 10. Exemplo de Validação com Dados Inválidos
    print('\n10. Testando validação com dados inválidos...');
    try {
      PeriodoApuracao(
        mesApuracao: 13, // Mês inválido
        anoApuracao: 2025,
      );
    } catch (e) {
      print('Validação de mês inválido: $e');
    }

    try {
      Debito(
        idDebito: 0, // ID inválido
        codigoDebito: '236208',
        valorDebito: -100.00, // Valor negativo
      );
    } catch (e) {
      print('Validação de débito inválido: $e');
    }

    print('\n=== Exemplos MIT Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço MIT: $e');
  }
}
