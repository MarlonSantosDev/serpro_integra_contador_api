import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Mit(ApiClient apiClient) async {
  print('=== Exemplos MIT (Módulo de Inclusão de Tributos) ===');

  final mitService = MitService(apiClient);
  bool servicoOk = true;

  // 1. Encerrar Apuração
  try {
    print('\n--- 1. Encerrar Apuração ---');

    // Criar período da apuração (baseado no JSON fornecido)
    final periodoApuracao = PeriodoApuracao(mesApuracao: 1, anoApuracao: 2025);

    // Criar responsável pela apuração
    final responsavelApuracao = ResponsavelApuracao(
      cpfResponsavel: '00000000000',
    );

    // Criar dados iniciais (baseado no JSON fornecido)
    final dadosIniciais = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: QualificacaoPj.pjEmGeral,
      tributacaoLucro: TributacaoLucro.realAnual,
      variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
      regimePisCofins: RegimePisCofins.cumulativa,
      responsavelApuracao: responsavelApuracao,
    );

    // Criar débitos (baseado no JSON fornecido)
    final debitos = Debitos(
      irpj: ListaDebitosIrpj(
        listaDebitos: [
          Debito(
            idDebito: 1,
            codigoDebito: '236208',
            cnpjScp: '88888888888888',
            valorDebito: 100.00,
          ),
        ],
      ),
      csll: ListaDebitosCsll(
        listaDebitos: [
          Debito(
            idDebito: 2,
            codigoDebito: '248408',
            cnpjScp: '88888888888888',
            valorDebito: 220.00,
          ),
        ],
      ),
      pisPasep: ListaDebitosPisPasep(
        listaDebitos: [
          Debito(
            idDebito: 3,
            codigoDebito: '067904',
            cnpjScp: '88888888888888',
            valorDebito: 300.00,
          ),
        ],
      ),
      cofins: ListaDebitosCofins(
        listaDebitos: [
          Debito(
            idDebito: 4,
            codigoDebito: '092902',
            cnpjScp: '88888888888888',
            valorDebito: 444.00,
          ),
        ],
      ),
    );

    // Encerrar apuração usando método principal
    final response = await mitService.encerrarApuracao(
      contribuinteNumero: '00000000000000',
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      debitos: debitos,
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${response.status}');
    print(
      '📋 Mensagens: ${response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
    );
    if (response.sucesso) {
      print('✅ Apuração encerrada com sucesso!');
      print('📋 Protocolo: ${response.protocoloEncerramento}');
      print('🆔 ID da Apuração: ${response.idApuracao}');
    } else {
      print('❌ Erro ao encerrar apuração: ${response.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao encerrar apuração: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 2. Consultar situação de encerramento - Resposta sem avisos DCTFWeb
  try {
    print('\n--- 2. Consultar Situação Encerramento (Sem Avisos DCTFWeb) ---');
    final response = await mitService.consultarSituacaoEncerramento(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      protocoloEncerramento: 'AuYb4wuDp0GvCij3GDOAsA==',
    );

    print('✅ Status: ${response.status}');
    print(
      '📋 Mensagens: ${response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
    );
    if (response.sucesso) {
      print('✅ Situação consultada com sucesso!');
      print('📊 Situação: ${response.situacaoEnum?.descricao}');
      print('🔄 Em andamento: ${response.encerramentoEmAndamento}');
      print('✅ Concluído: ${response.encerramentoConcluido}');
    } else {
      print('❌ Erro ao consultar situação: ${response.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar situação de encerramento: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 3. Consultar situação de encerramento - Resposta com avisos DCTFWeb
  try {
    print('\n--- 3. Consultar Situação Encerramento (Com Avisos DCTFWeb) ---');
    final response = await mitService.consultarSituacaoEncerramento(
      contribuinteNumero: '11111111111111',
      contratanteNumero: '11111111111111',
      autorPedidoDadosNumero: '11111111111111',
      protocoloEncerramento: 'ZuAb4wuDp0GvCij3GDOAsA==',
    );

    print('✅ Status: ${response.status}');
    print(
      '📋 Mensagens: ${response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
    );
    if (response.sucesso) {
      print('✅ Situação consultada com sucesso!');
      print('📊 Situação: ${response.situacaoEnum?.descricao}');
      print('🔄 Em andamento: ${response.encerramentoEmAndamento}');
      print('✅ Concluído: ${response.encerramentoConcluido}');

      // Mostrar avisos se houver
      if (response.mensagensAviso.isNotEmpty) {
        print('⚠️ Avisos DCTFWeb encontrados:');
        for (final aviso in response.mensagensAviso) {
          print('  - ${aviso.codigo}: ${aviso.texto}');
        }
      }
    } else {
      print('❌ Erro ao consultar situação: ${response.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar situação de encerramento: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 4. Consultar Apuração
  try {
    print('\n--- 4. Consultar Apuração ---');
    final response = await mitService.consultarApuracao(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      idApuracao: 0,
    );

    print('✅ Status: ${response.status}');
    print(
      '📋 Mensagens: ${response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
    );
    if (response.sucesso) {
      print('✅ Apuração consultada com sucesso!');

      if (response.apuracao != null) {
        print('📋 Período: ${response.apuracao!.periodoApuracao}');
        print('🆔 ID: ${response.apuracao!.idApuracao}');
        print('📊 Situação: ${response.apuracao!.situacao}');
        print('  (Valor descritivo retornado diretamente)');
        print('  Possíveis valores:');
        print('    - "Em Processamento"');
        print('    - "Processado com Sucesso"');
        print('    - "Processado com Erro"');
        print(
          '📊 Situação (Enum): ${response.apuracao!.situacaoEnum?.descricao}',
        );
        print('📅 Data Encerramento: ${response.apuracao!.dataEncerramento}');
        print('🎯 Evento Especial: ${response.apuracao!.eventoEspecial}');
        print(
          '💰 Valor Total: R\$ ${response.apuracao!.valorTotalApurado?.toStringAsFixed(2)}',
        );
      }

      if (response.temPendencias) {
        print('⚠️ Pendências encontradas:');
        for (final pendencia in response.pendencias!) {
          print('  - ${pendencia.codigo}: ${pendencia.texto}');
        }
      } else {
        print('✅ Nenhuma pendência encontrada');
      }
    } else {
      print('❌ Erro ao consultar apuração: ${response.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao consultar apuração: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 5. Listar Apuração por mês e ano com situação encerrada
  try {
    print('\n--- 5. Listar Apuração por Mês e Ano (Situação Encerrada) ---');
    // Listar apurações encerradas de dezembro/2024
    final response = await mitService.consultarApuracaoesEncerradas(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      anoApuracao: 2025,
    );

    print('✅ Status: ${response.status}');
    print(
      '📋 Mensagens: ${response.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}',
    );
    if (response.sucesso) {
      print('✅ Apurações encerradas listadas com sucesso!');

      if (response.apuracoes != null && response.apuracoes!.isNotEmpty) {
        print(
          '📊 Total de apurações encerradas: ${response.apuracoes!.length}',
        );

        for (final apuracao in response.apuracoes!) {
          print('  📋 ${apuracao.periodoApuracao} - ${apuracao.situacao}');
          print('     (Valor descritivo: "${apuracao.situacao}")');
          print('     🆔 ID: ${apuracao.idApuracao}');
          print('     📅 Encerramento: ${apuracao.dataEncerramento}');
          print(
            '     💰 Valor: R\$ ${apuracao.valorTotalApurado?.toStringAsFixed(2)}',
          );
          print('');
        }
      } else {
        print('📭 Nenhuma apuração encerrada encontrada');
      }
    } else {
      print('❌ Erro ao listar apurações encerradas: ${response.mensagemErro}');
    }
  } catch (e) {
    print('❌ Erro ao listar apurações encerradas: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO MIT ===');
  if (servicoOk) {
    print('✅ Serviço MIT: OK');
  } else {
    print('❌ Serviço MIT: ERRO');
  }

  print('\n=== Exemplos MIT Concluídos ===');
}
