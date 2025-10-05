import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Ccmei(ApiClient apiClient) async {
  print('=== Exemplos CCMEI ===');

  final ccmeiService = CcmeiService(apiClient);
  bool servicoOk = true;

  // 1. Emitir CCMEI (PDF)
  try {
    print('\n--- 1. Emitir CCMEI (PDF) ---');
    final emitirResponse = await ccmeiService.emitirCcmei(
      '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );
    print('✅ Status: ${emitirResponse.status}');
    print('📋 Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('🏢 CNPJ: ${emitirResponse.dados.cnpj}');
    print('📄 PDF gerado: ${emitirResponse.dados.pdf.isNotEmpty ? 'Sim' : 'Não'}');
    print('📏 Tamanho do PDF: ${emitirResponse.dados.pdf.length} caracteres');
    final sucessoSalvamento = await PdfFileUtils.salvarArquivo(
      emitirResponse.dados.pdf,
      'relatorio_ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
  } catch (e) {
    print('❌ Erro ao emitir CCMEI: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Consultar Dados CCMEI
  try {
    print('\n--- 2. Consultar Dados CCMEI ---');
    final consultarResponse = await ccmeiService.consultarDadosCcmei(
      '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );
    print('✅ Status: ${consultarResponse.status}');
    print('📋 Mensagens: ${consultarResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('🏢 CNPJ: ${consultarResponse.dados.cnpj}');
    print('📝 Nome Empresarial: ${consultarResponse.dados.nomeEmpresarial}');
    print('👤 Empresário: ${consultarResponse.dados.empresario.nomeCivil}');
    print('🆔 CPF Empresário: ${consultarResponse.dados.empresario.cpf}');
    print('📅 Data Início Atividades: ${consultarResponse.dados.dataInicioAtividades}');
    print('📊 Situação Cadastral: ${consultarResponse.dados.situacaoCadastralVigente}');
    print('💰 Capital Social: R\$ ${consultarResponse.dados.capitalSocial}');
    print('📍 Endereço: ${consultarResponse.dados.enderecoComercial.logradouro}, ${consultarResponse.dados.enderecoComercial.numero}');
    print('🏘️ Bairro: ${consultarResponse.dados.enderecoComercial.bairro}');
    print('🏙️ Município: ${consultarResponse.dados.enderecoComercial.municipio}/${consultarResponse.dados.enderecoComercial.uf}');
    print('📮 CEP: ${consultarResponse.dados.enderecoComercial.cep}');
    print('🏪 Enquadramento MEI: ${consultarResponse.dados.enquadramento.optanteMei ? 'Sim' : 'Não'}');
    print('📈 Situação Enquadramento: ${consultarResponse.dados.enquadramento.situacao}');
    print('📅 Períodos MEI: ${consultarResponse.dados.enquadramento.periodosMei.length} período(s)');
    for (var periodo in consultarResponse.dados.enquadramento.periodosMei) {
      print('  - Período ${periodo.indice}: ${periodo.dataInicio} até ${periodo.dataFim ?? 'atual'}');
    }
    print('💼 Formas de Atuação: ${consultarResponse.dados.atividade.formasAtuacao.join(', ')}');
    print('🎯 Ocupação Principal: ${consultarResponse.dados.atividade.ocupacaoPrincipal.descricaoOcupacao}');
    if (consultarResponse.dados.atividade.ocupacaoPrincipal.codigoCNAE != null) {
      print(
        '🏷️ CNAE Principal: ${consultarResponse.dados.atividade.ocupacaoPrincipal.codigoCNAE} - ${consultarResponse.dados.atividade.ocupacaoPrincipal.descricaoCNAE}',
      );
    }
    print('📋 Ocupações Secundárias: ${consultarResponse.dados.atividade.ocupacoesSecundarias.length}');
    for (var ocupacao in consultarResponse.dados.atividade.ocupacoesSecundarias) {
      print('  - ${ocupacao.descricaoOcupacao}');
      if (ocupacao.codigoCNAE != null) {
        print('    CNAE: ${ocupacao.codigoCNAE} - ${ocupacao.descricaoCNAE}');
      }
    }
    print('📄 Termo Ciência Dispensa: ${consultarResponse.dados.termoCienciaDispensa.titulo}');
    print('📱 QR Code disponível: ${consultarResponse.dados.qrcode != null ? 'Sim' : 'Não'}');
    if (consultarResponse.dados.qrcode != null) {
      final sucessoSalvamento = await PdfFileUtils.salvarArquivo(
        consultarResponse.dados.qrcode!,
        'qrcode_ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } catch (e) {
    print('❌ Erro ao consultar dados CCMEI: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 3. Consultar Situação Cadastral por CPF
  try {
    print('\n--- 3. Consultar Situação Cadastral por CPF ---');
    final situacaoResponse = await ccmeiService.consultarSituacaoCadastral(
      '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );
    print('✅ Status: ${situacaoResponse.status}');
    print('📋 Mensagens: ${situacaoResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('🔍 CNPJs encontrados: ${situacaoResponse.dados.length}');
    for (var situacao in situacaoResponse.dados) {
      print('  - CNPJ: ${situacao.cnpj}');
      print('    Situação: ${situacao.situacao}');
      print('    Enquadrado MEI: ${situacao.enquadradoMei ? 'Sim' : 'Não'}');
    }
  } catch (e) {
    print('❌ Erro ao consultar situação cadastral: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO CCMEI ===');
  if (servicoOk) {
    print('✅ Serviço CCMEI: OK');
  } else {
    print('❌ Serviço CCMEI: ERRO');
  }

  print('\n=== Exemplos CCMEI Concluídos ===');
}
