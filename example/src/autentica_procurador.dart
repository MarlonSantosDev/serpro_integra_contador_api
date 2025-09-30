import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> AutenticaProcurador(ApiClient apiClient) async {
  print('=== Exemplos Autenticação de Procurador ===');

  final autenticaProcuradorService = AutenticaProcuradorService(apiClient);

  try {
    // Dados de exemplo para demonstração
    const contratanteNumero = '00000000000100'; // CNPJ da empresa contratante
    const contratanteNome = 'EMPRESA EXEMPLO LTDA';
    const autorPedidoDadosNumero = '00000000000'; // CPF do procurador/contador
    const autorPedidoDadosNome = 'JOÃO DA SILVA CONTADOR';

    // 1. Criar termo de autorização
    print('\n--- 1. Criando Termo de Autorização ---');
    final termo = await autenticaProcuradorService.criarTermoComDataAtual(
      contratanteNumero: contratanteNumero,
      contratanteNome: contratanteNome,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      autorPedidoDadosNome: autorPedidoDadosNome,
    );

    print('Termo criado com sucesso');
    print('Data de assinatura: ${termo.dataAssinatura}');
    print('Data de vigência: ${termo.dataVigencia}');

    // 2. Validar dados do termo
    print('\n--- 2. Validando Dados do Termo ---');
    final erros = termo.validarDados();
    if (erros.isEmpty) {
      print('✓ Dados do termo são válidos');
    } else {
      print('✗ Erros encontrados:');
      for (final erro in erros) {
        print('  - $erro');
      }
    }

    // 3. Criar XML do termo
    print('\n--- 3. Criando XML do Termo ---');
    final xml = termo.criarXmlTermo();
    print('XML criado com ${xml.length} caracteres');

    // 4. Validar estrutura do XML
    print('\n--- 4. Validando Estrutura do XML ---');
    final errosXml = await autenticaProcuradorService.validarTermoAutorizacao(xml);
    if (errosXml.isEmpty) {
      print('✓ Estrutura do XML é válida');
    } else {
      print('✗ Erros na estrutura do XML:');
      for (final erro in errosXml) {
        print('  - $erro');
      }
    }

    // 5. Assinar termo digitalmente (simulado)
    print('\n--- 5. Assinando Termo Digitalmente (Simulado) ---');
    final xmlAssinado = await autenticaProcuradorService.assinarTermoDigital(termo);
    print('Termo assinado com sucesso');
    print('XML assinado tem ${xmlAssinado.length} caracteres');

    // 6. Validar assinatura digital
    print('\n--- 6. Validando Assinatura Digital ---');
    final relatorioAssinatura = await autenticaProcuradorService.validarAssinaturaDigital(xmlAssinado);
    print('Relatório de validação:');
    print('  - Tem assinatura: ${relatorioAssinatura['tem_assinatura']}');
    print('  - Tem signed info: ${relatorioAssinatura['tem_signed_info']}');
    print('  - Tem signature value: ${relatorioAssinatura['tem_signature_value']}');
    print('  - Tem X509 certificate: ${relatorioAssinatura['tem_x509_certificate']}');
    print('  - Algoritmo assinatura correto: ${relatorioAssinatura['algoritmo_assinatura_correto']}');
    print('  - Algoritmo hash correto: ${relatorioAssinatura['algoritmo_hash_correto']}');
    print('  - Assinatura válida: ${relatorioAssinatura['assinatura_valida']}');

    // 7. Autenticar procurador
    print('\n--- 7. Autenticando Procurador ---');
    try {
      final response = await autenticaProcuradorService.autenticarProcurador(
        xmlAssinado: xmlAssinado,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      print('Status da autenticação: ${response.status}');
      print('Sucesso: ${response.sucesso}');
      print('Mensagem: ${response.mensagemPrincipal}');
      print('Código: ${response.codigoMensagem}');

      if (response.sucesso && response.autenticarProcuradorToken != null) {
        print('✓ Token obtido: ${response.autenticarProcuradorToken!.substring(0, 8)}...');
        print('✓ Data de expiração: ${response.dataExpiracao}');
        print('✓ Token em cache: ${response.isCacheValido}');
      }
    } catch (e) {
      print('Erro na autenticação (esperado em ambiente de teste): $e');
    }

    // 8. Verificar cache de token
    print('\n--- 8. Verificando Cache de Token ---');
    final cache = await autenticaProcuradorService.verificarCacheToken(
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    if (cache != null) {
      print('✓ Token encontrado em cache');
      print('  - Válido: ${cache.isTokenValido}');
      print('  - Expira em breve: ${cache.expiraEmBreve}');
      print('  - Tempo restante: ${cache.tempoRestante.inHours} horas');
    } else {
      print('✗ Nenhum token válido em cache');
    }

    // 9. Obter token válido (do cache ou renovar)
    print('\n--- 9. Obtendo Token Válido ---');
    try {
      final token = await autenticaProcuradorService.obterTokenValido(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
      );

      print('✓ Token obtido: ${token.substring(0, 8)}...');
    } catch (e) {
      print('Erro ao obter token (esperado em ambiente de teste): $e');
    }

    // 10. Exemplo com certificado digital (simulado)
    print('\n--- 10. Exemplo com Certificado Digital (Simulado) ---');
    try {
      final termoComCertificado = await autenticaProcuradorService.criarTermoComDataAtual(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
        certificadoPath: '/caminho/para/certificado.p12',
        certificadoPassword: 'senha123',
      );

      print('Termo com certificado criado');
      print('Caminho do certificado: ${termoComCertificado.certificadoPath}');

      // Simular obtenção de informações do certificado
      final infoCertificado = await autenticaProcuradorService.obterInfoCertificado(
        certificadoPath: '/caminho/para/certificado.p12',
        senha: 'senha123',
      );

      print('Informações do certificado:');
      print('  - Serial: ${infoCertificado['serial']}');
      print('  - Subject: ${infoCertificado['subject']}');
      print('  - Tipo: ${infoCertificado['tipo']}');
      print('  - Formato: ${infoCertificado['formato']}');
      print('  - Tamanho: ${infoCertificado['tamanho_bytes']} bytes');
    } catch (e) {
      print('Erro com certificado (esperado em ambiente de teste): $e');
    }

    // 11. Exemplo de renovação de token
    print('\n--- 11. Exemplo de Renovação de Token ---');
    try {
      final responseRenovacao = await autenticaProcuradorService.renovarToken(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
      );

      print('Status da renovação: ${responseRenovacao.status}');
      print('Sucesso: ${responseRenovacao.sucesso}');
    } catch (e) {
      print('Erro na renovação (esperado em ambiente de teste): $e');
    }

    // 12. Gerenciamento de cache
    print('\n--- 12. Gerenciamento de Cache ---');
    final estatisticas = await autenticaProcuradorService.obterEstatisticasCache();
    print('Estatísticas do cache:');
    print('  - Total de caches: ${estatisticas['total_caches']}');
    print('  - Caches válidos: ${estatisticas['caches_validos']}');
    print('  - Caches expirados: ${estatisticas['caches_expirados']}');
    print('  - Taxa de válidos: ${estatisticas['taxa_validos']}%');
    print('  - Tamanho total: ${estatisticas['tamanho_total_kb']} KB');

    // 13. Limpeza de cache
    print('\n--- 13. Limpeza de Cache ---');
    final removidos = await autenticaProcuradorService.removerCachesExpirados();
    print('Caches expirados removidos: $removidos');

    // 14. Exemplo de uso com ApiClient
    print('\n--- 14. Exemplo de Uso com ApiClient ---');
    print('Verificando se ApiClient tem token de procurador:');
    print('  - Tem token: ${apiClient.hasProcuradorToken}');
    print('  - Token: ${apiClient.procuradorToken?.substring(0, 8) ?? 'N/A'}...');

    // Simular definição de token manual
    apiClient.setProcuradorToken('token_exemplo_123456789', contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    print('Após definir token manualmente:');
    print('  - Tem token: ${apiClient.hasProcuradorToken}');
    print('  - Token: ${apiClient.procuradorToken?.substring(0, 8) ?? 'N/A'}...');

    final infoCache = apiClient.procuradorCacheInfo;
    if (infoCache != null) {
      print('Informações do cache:');
      print('  - Token: ${infoCache['token']}');
      print('  - Válido: ${infoCache['is_valido']}');
      print('  - Expira em breve: ${infoCache['expira_em_breve']}');
      print('  - Tempo restante: ${infoCache['tempo_restante_horas']} horas');
    }

    // 15. Exemplo de fluxo completo
    print('\n--- 15. Exemplo de Fluxo Completo ---');
    print('Este exemplo demonstra o fluxo completo de autenticação de procurador:');
    print('1. ✓ Criar termo de autorização');
    print('2. ✓ Validar dados do termo');
    print('3. ✓ Criar XML do termo');
    print('4. ✓ Validar estrutura do XML');
    print('5. ✓ Assinar termo digitalmente');
    print('6. ✓ Validar assinatura digital');
    print('7. ✓ Autenticar procurador');
    print('8. ✓ Verificar cache de token');
    print('9. ✓ Obter token válido');
    print('10. ✓ Gerenciar cache');
    print('11. ✓ Usar com ApiClient');

    print('\n=== Exemplos Autenticação de Procurador Concluídos ===');
  } catch (e) {
    print('Erro no serviço de Autenticação de Procurador: $e');
  }
}
