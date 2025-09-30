import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> EventosAtualizacao(ApiClient apiClient) async {
  print('\n=== Exemplos Eventos de Atualização ===');

  try {
    final eventosService = EventosAtualizacaoService(apiClient);
    // Exemplo 1: Solicitar eventos de Pessoa Física (DCTFWeb)
    print('\n--- Exemplo 1: Solicitar Eventos PF (DCTFWeb) ---');
    final cpfsExemplo = ['00000000000', '11111111111', '22222222222', '33333333333'];

    final solicitacaoPF = await eventosService.solicitarEventosPF(
      contratanteNumero: '99999999999999',
      autorPedidoDadosNumero: '99999999999999',
      cpfs: cpfsExemplo,
      evento: TipoEvento.dctfWeb,
    );

    print('Status: ${solicitacaoPF.status}');
    print('Protocolo: ${solicitacaoPF.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPF.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPF.dados.tempoLimiteEmMin}min');

    for (final mensagem in solicitacaoPF.mensagens) {
      print('Mensagem: ${mensagem.codigo} - ${mensagem.texto}');
    }

    // Exemplo 2: Obter eventos de Pessoa Física usando protocolo
    print('\n--- Exemplo 2: Obter Eventos PF ---');
    await Future.delayed(Duration(milliseconds: solicitacaoPF.dados.tempoEsperaMedioEmMs));

    final eventosPF = await eventosService.obterEventosPF(protocolo: solicitacaoPF.dados.protocolo, evento: TipoEvento.dctfWeb);

    print('Status: ${eventosPF.status}');
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

    // Exemplo 3: Solicitar eventos de Pessoa Jurídica (CaixaPostal)
    print('\n--- Exemplo 3: Solicitar Eventos PJ (CaixaPostal) ---');
    final cnpjsExemplo = ['00000000000000', '11111111111111', '22222222222222'];

    final solicitacaoPJ = await eventosService.solicitarEventosPJ(cnpjs: cnpjsExemplo, evento: TipoEvento.caixaPostal);

    print('Status: ${solicitacaoPJ.status}');
    print('Protocolo: ${solicitacaoPJ.dados.protocolo}');
    print('Tempo espera médio: ${solicitacaoPJ.dados.tempoEsperaMedioEmMs}ms');
    print('Tempo limite: ${solicitacaoPJ.dados.tempoLimiteEmMin}min');

    // Exemplo 4: Método de conveniência - Solicitar e obter eventos PF automaticamente
    print('\n--- Exemplo 4: Método de Conveniência PF ---');
    final eventosPFConveniencia = await eventosService.solicitarEObterEventosPF(
      cpfs: ['33333333333', '44444444444'],
      evento: TipoEvento.pagamentoWeb,
    );

    print('Status: ${eventosPFConveniencia.status}');
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

    // Exemplo 5: Método de conveniência - Solicitar e obter eventos PJ automaticamente
    print('\n--- Exemplo 5: Método de Conveniência PJ ---');
    final eventosPJConveniencia = await eventosService.solicitarEObterEventosPJ(
      cnpjs: ['33333333333333', '44444444444444'],
      evento: TipoEvento.dctfWeb,
    );

    print('Status: ${eventosPJConveniencia.status}');
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

    // Exemplo 6: Demonstração dos tipos de eventos disponíveis
    print('\n--- Exemplo 6: Tipos de Eventos Disponíveis ---');
    for (final tipo in TipoEvento.values) {
      print('Evento ${tipo.codigo}: ${tipo.sistema}');
    }

    // Exemplo 7: Demonstração dos tipos de contribuinte
    print('\n--- Exemplo 7: Tipos de Contribuinte ---');
    for (final tipo in TipoContribuinte.values) {
      print('Tipo ${tipo.codigo}: ${tipo.descricao}');
    }

    // Exemplo 8: Validação de limites
    print('\n--- Exemplo 8: Informações sobre Limites ---');
    print('Máximo de contribuintes por lote: ${EventosAtualizacaoCommon.maxContribuintesPorLote}');
    print('Máximo de requisições por dia: ${EventosAtualizacaoCommon.maxRequisicoesPorDia}');
    print(
      'Eventos disponíveis: ${EventosAtualizacaoCommon.eventoDCTFWeb}, ${EventosAtualizacaoCommon.eventoCaixaPostal}, ${EventosAtualizacaoCommon.eventoPagamentoWeb}',
    );

    print('\n=== Exemplos Eventos de Atualização Concluídos ===');
  } catch (e) {
    print('Erro nos exemplos de Eventos de Atualização: $e');
  }
}
