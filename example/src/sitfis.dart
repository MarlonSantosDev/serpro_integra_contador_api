import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Sitfis(ApiClient apiClient) async {
  print('=== Exemplos SITFIS ===');

  final sitfisService = SitfisService(apiClient);
  bool servicoOk = true;

  // 1. Solicitar Protocolo do Relatório
  try {
    print('\n--- 1. Solicitar Protocolo do Relatório ---');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );
    print('✅ Status: ${protocoloResponse.status}');
    print('Mensagens: ${protocoloResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

    if (protocoloResponse.isSuccess) {
      print('✅ Sucesso: ${protocoloResponse.isSuccess}');
      print('Tem protocolo: ${protocoloResponse.hasProtocolo}');
      print('Tem tempo de espera: ${protocoloResponse.hasTempoEspera}');

      if (protocoloResponse.hasProtocolo) {
        print('Protocolo: ${protocoloResponse.dados!.protocoloRelatorio!.substring(0, 20)}...');
      }

      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Tempo de espera: ${tempoEspera}ms (${protocoloResponse.dados!.tempoEsperaEmSegundos}s)');
      }
    } else {
      print('❌ Erro ao solicitar protocolo');
    }
  } catch (e) {
    print('❌ Erro ao solicitar protocolo: $e');
    servicoOk = false;
  }

  // 2. Emitir Relatório (se protocolo disponível)
  try {
    print('\n--- 2. Emitir Relatório (se protocolo disponível) ---');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;

      // Se há tempo de espera, aguarda antes de emitir
      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Aguardando ${tempoEspera}ms antes de emitir...');
        await Future.delayed(Duration(milliseconds: tempoEspera));
      }

      final emitirResponse = await sitfisService.emitirRelatorioSituacaoFiscal('99999999999', protocolo);
      print('✅ Status: ${emitirResponse.status}');
      print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('Sucesso: ${emitirResponse.isSuccess}');
      print('Em processamento: ${emitirResponse.isProcessing}');
      print('Tem PDF: ${emitirResponse.hasPdf}');
      print('Tem tempo de espera: ${emitirResponse.hasTempoEspera}');

      if (emitirResponse.hasPdf) {
        final infoPdf = sitfisService.obterInformacoesPdf(emitirResponse);
        print('✅ Informações do PDF:');
        print('  - Disponível: ${infoPdf['disponivel']}');
        print('  - Tamanho: ${infoPdf['tamanhoKB']} KB (${infoPdf['tamanhoMB']} MB)');
        print('  - Tamanho Base64: ${infoPdf['tamanhoBase64']} caracteres');

        // Salvar PDF em arquivo (opcional)
        final sucessoSalvamento = await sitfisService.salvarPdfEmArquivo(
          emitirResponse,
          'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      if (emitirResponse.hasTempoEspera) {
        final tempoEspera = emitirResponse.dados!.tempoEspera!;
        print('Novo tempo de espera: ${tempoEspera}ms (${emitirResponse.dados!.tempoEsperaEmSegundos}s)');
      }
    } else {
      print('❌ Protocolo não disponível para emissão');
    }
  } catch (e) {
    print('❌ Erro ao emitir relatório: $e');
    servicoOk = false;
  }

  // 3. Fluxo Completo com Retry Automático
  try {
    print('\n--- 3. Fluxo Completo com Retry Automático ---');
    final relatorioCompleto = await sitfisService.obterRelatorioCompleto(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      maxTentativas: 3,
      callbackProgresso: (etapa, tempoEspera) {
        print('Progresso: $etapa');
        if (tempoEspera != null) {
          print('  Tempo de espera: ${tempoEspera}ms');
        }
      },
    );

    print('✅ Relatório completo obtido!');
    print('Status final: ${relatorioCompleto.status}');
    print('PDF disponível: ${relatorioCompleto.hasPdf}');

    if (relatorioCompleto.hasPdf) {
      final infoPdf = sitfisService.obterInformacoesPdf(relatorioCompleto);
      print('Tamanho do PDF: ${infoPdf['tamanhoKB']} KB');
    }
  } catch (e) {
    print('❌ Erro no fluxo completo: $e');
    servicoOk = false;
  }

  // 4. Exemplo com Cache (simulado)
  try {
    print('\n--- 4. Exemplo com Cache (simulado) ---');
    // Simular cache válido
    final cacheSimulado = SitfisCache(
      protocoloRelatorio: 'protocolo_cache_exemplo',
      dataExpiracao: DateTime.now().add(Duration(hours: 1)),
      etag: '"protocoloRelatorio:protocolo_cache_exemplo"',
      cacheControl: 'integra_sitfis_solicitar_relatorio',
    );

    print('✅ Cache válido: ${cacheSimulado.isValid}');
    print('Tempo restante: ${cacheSimulado.tempoRestanteEmSegundos}s');

    final protocoloComCache = await sitfisService.solicitarProtocoloComCache(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      cache: cacheSimulado,
    );

    if (protocoloComCache == null) {
      print('✅ Usando cache existente - não fez nova solicitação');
    } else {
      print('✅ Nova solicitação feita - cache inválido');
    }
  } catch (e) {
    print('❌ Erro no exemplo com cache: $e');
    servicoOk = false;
  }

  // 5. Exemplo com Emissão com Retry
  try {
    print('\n--- 5. Exemplo com Emissão com Retry ---');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
      '99999999999',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;

      final relatorioComRetry = await sitfisService.emitirRelatorioComRetry(
        '99999999999',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
        protocolo,
        maxTentativas: 2,
        callbackProgresso: (tentativa, tempoEspera) {
          print('Tentativa $tentativa - Aguardando ${tempoEspera}ms...');
        },
      );

      print('✅ Relatório com retry obtido!');
      print('Status: ${relatorioComRetry.status}');
      print('PDF disponível: ${relatorioComRetry.hasPdf}');
    } else {
      print('❌ Protocolo não disponível para retry');
    }
  } catch (e) {
    print('❌ Erro no exemplo com retry: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== Resumo Final ===');
  if (servicoOk) {
    print('✅ SITFIS: OK');
  } else {
    print('❌ SITFIS: ERRO');
  }
}
