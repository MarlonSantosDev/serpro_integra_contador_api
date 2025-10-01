import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> EventosAtualizacao(ApiClient apiClient) async {
  print('\n=== Exemplos Eventos de Atualização ===');

  final eventosService = EventosAtualizacaoService(apiClient);
  bool servicoOk = true;
  // Exemplo 1: Solicitar eventos de Pessoa Física (DCTFWeb)
  try {
    print('\n--- Exemplo 1: Solicitar Eventos PF (DCTFWeb) ---');
    final cpfsExemplo = ['00000000000', '11111111111', '22222222222', '33333333333'];

    final solicitacaoPF = await eventosService.solicitarEventosPF(
      contratanteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      cpfs: cpfsExemplo,
      evento: TipoEvento.dctfWeb,
    );

    print('✅ Status: ${solicitacaoPF.status}');
    print('Protocolo: ${solicitacaoPF.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPF.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPF.dados.tempoLimiteEmMin}min');

    for (final mensagem in solicitacaoPF.mensagens) {
      print('Mensagem: ${mensagem.codigo} - ${mensagem.texto}');
    }
  } catch (e) {
    print('❌ Erro ao solicitar eventos PF: $e');
    servicoOk = false;
  }

  // Exemplo 2: Obter eventos de Pessoa Física usando protocolo
  try {
    print('\n--- Exemplo 2: Obter Eventos PF ---');
    await Future.delayed(Duration(milliseconds: 1000)); // Simulação de espera

    final eventosPF = await eventosService.obterEventosPF(protocolo: 'a65f3455-fa91-419b-b0ad-c4ac50695abf', evento: TipoEvento.dctfWeb);

    print('✅ Status: ${eventosPF.status}');
    print('Total de eventos: ${eventosPF.dados.length}');

    for (final evento in eventosPF.dados) {
      if (evento.temAtualizacao) {
        print('CPF ${evento.cpf}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CPF ${evento.cpf}: Sem atualizações');
      } else {
        print('CPF ${evento.cpf}: Sem dados');
      }
    }
  } catch (e) {
    print('❌ Erro ao obter eventos PF: $e');
    servicoOk = false;
  }

  // Exemplo 3: Solicitar eventos de Pessoa Jurídica (CaixaPostal)
  try {
    print('\n--- Exemplo 3: Solicitar Eventos PJ (CaixaPostal) ---');
    final cnpjsExemplo = ['00000000000000', '11111111111111', '22222222222222', '33333333333333'];

    final solicitacaoPJ = await eventosService.solicitarEventosPJ(cnpjs: cnpjsExemplo, evento: TipoEvento.caixaPostal);

    print('✅ Status: ${solicitacaoPJ.status}');
    print('Protocolo: ${solicitacaoPJ.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPJ.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPJ.dados.tempoLimiteEmMin}min');
  } catch (e) {
    print('❌ Erro ao solicitar eventos PJ: $e');
    servicoOk = false;
  }

  // Exemplo 4: Método de conveniência - Solicitar e obter eventos PF automaticamente
  try {
    print('\n--- Exemplo 4: Método de Conveniência PF ---');
    final eventosPFConveniencia = await eventosService.solicitarEObterEventosPF(
      cpfs: ['33333333333', '44444444444'],
      evento: TipoEvento.pagamentoWeb,
    );

    print('✅ Status: ${eventosPFConveniencia.status}');
    print('Total de eventos: ${eventosPFConveniencia.dados.length}');

    for (final evento in eventosPFConveniencia.dados) {
      if (evento.temAtualizacao) {
        print('CPF ${evento.cpf}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CPF ${evento.cpf}: Sem atualizações');
      } else {
        print('CPF ${evento.cpf}: Sem dados');
      }
    }
  } catch (e) {
    print('❌ Erro no método de conveniência PF: $e');
    servicoOk = false;
  }
  // Exemplo 5: Método de conveniência - Solicitar e obter eventos PJ automaticamente
  try {
    print('\n--- Exemplo 5: Método de Conveniência PJ ---');
    final eventosPJConveniencia = await eventosService.solicitarEObterEventosPJ(
      contratanteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      cnpjs: ['99999999999999', '99999999999999'],
      evento: TipoEvento.caixaPostal,
    );

    print('✅ Status: ${eventosPJConveniencia.status}');
    print('Total de eventos: ${eventosPJConveniencia.dados.length}');

    for (final evento in eventosPJConveniencia.dados) {
      if (evento.temAtualizacao) {
        print('CNPJ ${evento.cnpj}: Última atualização em ${evento.dataFormatada}');
      } else if (evento.semAtualizacao) {
        print('CNPJ ${evento.cnpj}: Sem atualizações');
      } else {
        print('CNPJ ${evento.cnpj}: Sem dados');
      }
    }
  } catch (e) {
    print('❌ Erro no método de conveniência PJ: $e');
    servicoOk = false;
  }

  // Exemplo 6: Demonstração dos tipos de eventos disponíveis
  try {
    print('\n--- Exemplo 6: Tipos de Eventos Disponíveis ---');
    for (final tipo in TipoEvento.values) {
      print('✅ Evento ${tipo.codigo}: ${tipo.sistema}');
    }
  } catch (e) {
    print('❌ Erro ao listar tipos de eventos: $e');
    servicoOk = false;
  }

  // Exemplo 7: Demonstração dos tipos de contribuinte
  try {
    print('\n--- Exemplo 7: Tipos de Contribuinte ---');
    for (final tipo in TipoContribuinte.values) {
      print('✅ Tipo ${tipo.codigo}: ${tipo.descricao}');
    }
  } catch (e) {
    print('❌ Erro ao listar tipos de contribuinte: $e');
    servicoOk = false;
  }

  // Exemplo 8: Validação de limites
  try {
    print('\n--- Exemplo 8: Informações sobre Limites ---');
    print('✅ Máximo de contribuintes por lote: ${EventosAtualizacaoCommon.maxContribuintesPorLote}');
    print('✅ Máximo de requisições por dia: ${EventosAtualizacaoCommon.maxRequisicoesPorDia}');
    print(
      '✅ Eventos disponíveis: ${EventosAtualizacaoCommon.eventoDCTFWeb}, ${EventosAtualizacaoCommon.eventoCaixaPostal}, ${EventosAtualizacaoCommon.eventoPagamentoWeb}',
    );
  } catch (e) {
    print('❌ Erro ao mostrar informações de limites: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO EVENTOS ATUALIZAÇÃO ===');
  if (servicoOk) {
    print('✅ Serviço EVENTOS ATUALIZAÇÃO: OK');
  } else {
    print('❌ Serviço EVENTOS ATUALIZAÇÃO: ERRO');
  }

  print('\n=== Exemplos Eventos de Atualização Concluídos ===');
}
