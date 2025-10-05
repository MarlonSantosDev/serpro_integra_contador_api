import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Sitfis(ApiClient apiClient) async {
  print('=== Exemplos SITFIS ===');
  print('SITFIS - Sistema de Relatório de Situação Fiscal');

  final sitfisService = SitfisService(apiClient);
  bool servicoOk = true;

  // 1. Solicitar Protocolo do Relatório
  try {
    print('--- 1. Solicitar Protocolo do Relatório ---');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('Status: ${protocoloResponse.status}');
    print('Mensagens: ${protocoloResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (protocoloResponse.isSuccess) {
      print('✅ Sucesso ao solicitar protocolo');

      if (protocoloResponse.hasProtocolo) {
        final protocolo = protocoloResponse.dados!.protocoloRelatorio!;
        print('Protocolo obtido: ${protocolo.substring(0, 20)}...');
      }

      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Tempo de espera: ${tempoEspera}ms (${protocoloResponse.dados!.tempoEsperaEmSegundos}s)');
      }
    } else {
      print('❌ Erro ao solicitar protocolo');
      servicoOk = false;
    }
  } catch (e) {
    print('❌ Erro ao solicitar protocolo: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Emitir Relatório (se protocolo disponível)
  try {
    print('\n--- 2. Emitir Relatório de Situação Fiscal ---');

    // Primeiro solicita o protocolo
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;
      print('Usando protocolo: ${protocolo.substring(0, 20)}...');

      // Se há tempo de espera, aguarda antes de emitir
      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Aguardando ${tempoEspera}ms antes de emitir...');
        await Future.delayed(Duration(milliseconds: tempoEspera));
      }

      // Emite o relatório
      final emitirResponse = await sitfisService.emitirRelatorioSituacaoFiscal(
        '99999999999',
        protocolo,
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );

      print('Status: ${emitirResponse.status}');
      print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('Sucesso: ${emitirResponse.isSuccess}');
      print('Em processamento: ${emitirResponse.isProcessing}');
      print('PDF disponível: ${emitirResponse.hasPdf}');

      if (emitirResponse.hasPdf) {
        // Salvar PDF em arquivo (opcional)
        final sucessoSalvamento = await PdfFileUtils.salvarArquivo(
          emitirResponse.dados!.pdf!,
          'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      } else if (emitirResponse.isProcessing) {
        print('⏳ Relatório em processamento...');
        if (emitirResponse.hasTempoEspera) {
          final tempoEspera = emitirResponse.dados!.tempoEspera!;
          print('Tempo de espera: ${tempoEspera}ms (${emitirResponse.dados!.tempoEsperaEmSegundos}s)');
        }
      }
    } else {
      print('❌ Protocolo não disponível para emissão');
      servicoOk = false;
    }
  } catch (e) {
    print('❌ Erro ao emitir relatório: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== Resumo Final ===');
  if (servicoOk) {
    print('✅ SITFIS: Todos os serviços executados com sucesso');
  } else {
    print('❌ SITFIS: Alguns serviços apresentaram erro');
  }
}
