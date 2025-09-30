import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Procuracoes(ApiClient apiClient) async {
  print('\n=== Exemplos PROCURAÇÕES (Procurações Eletrônicas) ===');

  final procuracoesService = ProcuracoesService(apiClient);
  bool servicoOk = true;

  // 1. Exemplo básico - Obter procuração entre duas pessoas físicas
  try {
    print('\n--- 1. Obter Procuração PF para PF ---');
    final responsePf = await procuracoesService.obterProcuracaoPf(
      '99999999999', // CPF do outorgante
      '88888888888', // CPF do procurador
    );

    print('✅ Status: ${responsePf.status}');
    print('Sucesso: ${responsePf.sucesso}');
    print('Mensagem: ${responsePf.mensagemPrincipal}');
    print('Código: ${responsePf.codigoMensagem}');

    if (responsePf.sucesso && responsePf.dadosParsed != null) {
      final procuracoes = responsePf.dadosParsed!;
      print('Total de procurações encontradas: ${procuracoes.length}');

      for (int i = 0; i < procuracoes.length; i++) {
        final proc = procuracoes[i];
        print('\nProcuração ${i + 1}:');
        print('  Data de expiração: ${proc.dataExpiracaoFormatada}');
        print('  Quantidade de sistemas: ${proc.nrsistemas}');
        print('  Sistemas: ${proc.sistemasFormatados}');
        print('  Está expirada: ${proc.isExpirada ? 'Sim' : 'Não'}');
        print('  Expira em breve: ${proc.expiraEmBreve ? 'Sim' : 'Não'}');
      }
    }
  } catch (e) {
    print('❌ Erro ao obter procuração PF: $e');
    servicoOk = false;
  }

  // 2. Exemplo - Obter procuração entre duas pessoas jurídicas
  try {
    print('\n--- 2. Obter Procuração PJ para PJ ---');
    final responsePj = await procuracoesService.obterProcuracaoPj(
      '99999999999999', // CNPJ do outorgante
      '88888888888888', // CNPJ do procurador
    );

    print('✅ Status: ${responsePj.status}');
    print('Sucesso: ${responsePj.sucesso}');
    print('Mensagem: ${responsePj.mensagemPrincipal}');

    if (responsePj.sucesso && responsePj.dadosParsed != null) {
      final procuracoes = responsePj.dadosParsed!;
      print('Total de procurações encontradas: ${procuracoes.length}');

      for (final proc in procuracoes) {
        print('  Data de expiração: ${proc.dataExpiracaoFormatada}');
        print('  Sistemas: ${proc.sistemas.join(', ')}');
      }
    }
  } catch (e) {
    print('❌ Erro ao obter procuração PJ: $e');
    servicoOk = false;
  }

  // 3. Exemplo - Obter procuração mista (PF para PJ)
  try {
    print('\n--- 3. Obter Procuração Mista (PF para PJ) ---');
    final responseMista = await procuracoesService.obterProcuracaoMista(
      '99999999999', // CPF do outorgante
      '88888888888888', // CNPJ do procurador
      false, // outorgante é PF
      true, // procurador é PJ
    );

    print('✅ Status: ${responseMista.status}');
    print('Sucesso: ${responseMista.sucesso}');
    print('Mensagem: ${responseMista.mensagemPrincipal}');
  } catch (e) {
    print('❌ Erro ao obter procuração mista: $e');
    servicoOk = false;
  }

  // 4. Exemplo - Obter procuração com tipos específicos
  try {
    print('\n--- 4. Obter Procuração com Tipos Específicos ---');
    final responseTipos = await procuracoesService.obterProcuracaoComTipos(
      '99999999999', // CPF do outorgante
      '1', // Tipo 1 = CPF
      '88888888888888', // CNPJ do procurador
      '2', // Tipo 2 = CNPJ
    );

    print('✅ Status: ${responseTipos.status}');
    print('Sucesso: ${responseTipos.sucesso}');
    print('Mensagem: ${responseTipos.mensagemPrincipal}');
  } catch (e) {
    print('❌ Erro ao obter procuração com tipos: $e');
    servicoOk = false;
  }

  // 5. Exemplo - Obter procuração automática (detecta tipos)
  try {
    print('\n--- 5. Obter Procuração Automática (Detecta Tipos) ---');
    final responseAuto = await procuracoesService.obterProcuracao(
      '99999999999', // CPF do outorgante (detecta automaticamente)
      '88888888888888', // CNPJ do procurador (detecta automaticamente)
    );

    print('✅ Status: ${responseAuto.status}');
    print('Sucesso: ${responseAuto.sucesso}');
    print('Mensagem: ${responseAuto.mensagemPrincipal}');
  } catch (e) {
    print('❌ Erro ao obter procuração automática: $e');
    servicoOk = false;
  }

  // 6. Exemplo - Validação de documentos
  try {
    print('\n--- 6. Validação de Documentos ---');

    // Validar CPF
    final cpfValido = '12345678901';
    final cpfInvalido = '123';
    print('✅ CPF $cpfValido é válido: ${procuracoesService.isCpfValido(cpfValido)}');
    print('❌ CPF $cpfInvalido é válido: ${procuracoesService.isCpfValido(cpfInvalido)}');

    // Validar CNPJ
    final cnpjValido = '12345678000195';
    final cnpjInvalido = '123';
    print('✅ CNPJ $cnpjValido é válido: ${procuracoesService.isCnpjValido(cnpjValido)}');
    print('❌ CNPJ $cnpjInvalido é válido: ${procuracoesService.isCnpjValido(cnpjInvalido)}');

    // Detectar tipo de documento
    print('Tipo do documento $cpfValido: ${procuracoesService.detectarTipoDocumento(cpfValido)} (1=CPF, 2=CNPJ)');
    print('Tipo do documento $cnpjValido: ${procuracoesService.detectarTipoDocumento(cnpjValido)} (1=CPF, 2=CNPJ)');
  } catch (e) {
    print('❌ Erro na validação de documentos: $e');
    servicoOk = false;
  }

  // 7. Exemplo - Formatação de documentos
  try {
    print('\n--- 7. Formatação de Documentos ---');

    final cpfSemFormatacao = '12345678901';
    final cnpjSemFormatacao = '12345678000195';

    print('CPF sem formatação: $cpfSemFormatacao');
    print('CPF formatado: ${procuracoesService.formatarCpf(cpfSemFormatacao)}');

    print('CNPJ sem formatação: $cnpjSemFormatacao');
    print('CNPJ formatado: ${procuracoesService.formatarCnpj(cnpjSemFormatacao)}');
  } catch (e) {
    print('❌ Erro na formatação de documentos: $e');
    servicoOk = false;
  }

  // 8. Exemplo - Limpeza de documentos
  try {
    print('\n--- 8. Limpeza de Documentos ---');

    final cpfComPontuacao = '123.456.789-01';
    final cnpjComPontuacao = '12.345.678/0001-95';

    print('CPF com pontuação: $cpfComPontuacao');
    print('CPF limpo: ${procuracoesService.limparDocumento(cpfComPontuacao)}');

    print('CNPJ com pontuação: $cnpjComPontuacao');
    print('CNPJ limpo: ${procuracoesService.limparDocumento(cnpjComPontuacao)}');
  } catch (e) {
    print('❌ Erro na limpeza de documentos: $e');
    servicoOk = false;
  }

  // 9. Exemplo - Tratamento de erros
  try {
    print('\n--- 9. Tratamento de Erros ---');

    // Tentar com dados inválidos
    await procuracoesService.obterProcuracaoPf('123', '456'); // CPFs inválidos
  } catch (e) {
    print('✅ Erro capturado (esperado): $e');
  }

  // 10. Exemplo - Análise de procurações
  try {
    print('\n--- 10. Análise de Procurações ---');
    final responseAnalise = await procuracoesService.obterProcuracaoPf('99999999999', '88888888888');

    if (responseAnalise.sucesso && responseAnalise.dadosParsed != null) {
      final procuracoes = responseAnalise.dadosParsed!;

      print('Análise das procurações:');
      print('  Total encontradas: ${procuracoes.length}');

      int expiradas = 0;
      int expiramEmBreve = 0;
      int ativas = 0;

      for (final proc in procuracoes) {
        if (proc.isExpirada) {
          expiradas++;
        } else if (proc.expiraEmBreve) {
          expiramEmBreve++;
        } else {
          ativas++;
        }
      }

      print('  Procurações ativas: $ativas');
      print('  Procurações que expiram em breve: $expiramEmBreve');
      print('  Procurações expiradas: $expiradas');

      // Mostrar sistemas únicos
      final sistemasUnicos = <String>{};
      for (final proc in procuracoes) {
        sistemasUnicos.addAll(proc.sistemas);
      }
      print('  Sistemas únicos encontrados: ${sistemasUnicos.length}');
      for (final sistema in sistemasUnicos) {
        print('    - $sistema');
      }
    }
  } catch (e) {
    print('❌ Erro na análise: $e');
    servicoOk = false;
  }

  // 11. Exemplo - Diferentes cenários de uso
  try {
    print('\n--- 11. Cenários de Uso ---');

    // Cenário 1: Contador consultando procurações de seu cliente
    print('Cenário 1: Contador consultando procurações de cliente');
    final responseContador = await procuracoesService.obterProcuracaoPf(
      '99999999999', // CPF do cliente
      '88888888888', // CPF do contador
      contratanteNumero: '77777777777777', // CNPJ da empresa contratante
      autorPedidoDadosNumero: '88888888888', // CPF do contador como autor
    );
    print('  ✅ Status: ${responseContador.status}');
    print('  Sucesso: ${responseContador.sucesso}');

    // Cenário 2: Empresa consultando procurações de seus procuradores
    print('Cenário 2: Empresa consultando procurações de procuradores');
    final responseEmpresa = await procuracoesService.obterProcuracaoPj(
      '99999999999999', // CNPJ da empresa
      '88888888888888', // CNPJ do procurador
    );
    print('  ✅ Status: ${responseEmpresa.status}');
    print('  Sucesso: ${responseEmpresa.sucesso}');

    // Cenário 3: Pessoa física consultando suas procurações
    print('Cenário 3: Pessoa física consultando suas procurações');
    final responsePfConsulta = await procuracoesService.obterProcuracaoPf(
      '99999999999', // CPF da pessoa
      '99999999999', // Mesmo CPF (consulta própria)
    );
    print('  ✅ Status: ${responsePfConsulta.status}');
    print('  Sucesso: ${responsePfConsulta.sucesso}');
  } catch (e) {
    print('❌ Erro nos cenários de uso: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PROCURAÇÕES ===');
  if (servicoOk) {
    print('✅ Serviço PROCURAÇÕES: OK');
  } else {
    print('❌ Serviço PROCURAÇÕES: ERRO');
  }

  print('\n=== Exemplos PROCURAÇÕES Concluídos ===');
}
