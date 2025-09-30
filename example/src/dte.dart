import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Dte(ApiClient apiClient) async {
  print('\n=== Exemplos DTE (Domicílio Tributário Eletrônico) ===');

  final dteService = DteService(apiClient);
  bool servicoOk = true;

  // 1. Exemplo básico - Consultar indicador DTE com CNPJ válido
  try {
    print('\n--- 1. Consultar Indicador DTE (CNPJ Válido) ---');
    final response = await dteService.obterIndicadorDte('11111111111111');

    print('✅ Status HTTP: ${response.status}');
    print('Sucesso: ${response.sucesso}');
    print('Mensagem: ${response.mensagemPrincipal}');
    print('Código: ${response.codigoMensagem}');

    if (response.sucesso && response.dadosParsed != null) {
      final dados = response.dadosParsed!;
      print('Indicador de enquadramento: ${dados.indicadorEnquadramento}');
      print('Status de enquadramento: ${dados.statusEnquadramento}');
      print('Descrição do indicador: ${dados.indicadorDescricao}');
      print('É válido: ${dados.isIndicadorValido}');

      // Análise do enquadramento
      print('\nAnálise do enquadramento:');
      print('  - É optante DTE: ${response.isOptanteDte}');
      print('  - É optante Simples: ${response.isOptanteSimples}');
      print('  - É optante DTE e Simples: ${response.isOptanteDteESimples}');
      print('  - Não é optante: ${response.isNaoOptante}');
      print('  - NI inválido: ${response.isNiInvalido}');
    }
  } catch (e) {
    print('❌ Erro ao consultar DTE: $e');
    servicoOk = false;
  }

  // 2. Exemplo com CNPJ da documentação (99999999999999)
  try {
    print('\n--- 2. Consultar Indicador DTE (CNPJ da Documentação) ---');
    final response = await dteService.obterIndicadorDte('11111111111111');

    print('✅ Status HTTP: ${response.status}');
    print('Sucesso: ${response.sucesso}');
    print('Mensagem: ${response.mensagemPrincipal}');

    if (response.sucesso && response.dadosParsed != null) {
      final dados = response.dadosParsed!;
      print('Indicador: ${dados.indicadorEnquadramento}');
      print('Status: ${dados.statusEnquadramento}');
      print('Descrição: ${dados.indicadorDescricao}');
    }
  } catch (e) {
    print('❌ Erro ao consultar DTE: $e');
    servicoOk = false;
  }

  // 3. Exemplo com CNPJ formatado
  try {
    print('\n--- 3. Consultar Indicador DTE (CNPJ Formatado) ---');
    final cnpjFormatado = '12.345.678/0001-95';
    print('CNPJ formatado: $cnpjFormatado');
    print('CNPJ limpo: ${dteService.limparCnpj(cnpjFormatado)}');

    final response = await dteService.obterIndicadorDte(cnpjFormatado);

    print('✅ Status HTTP: ${response.status}');
    print('Sucesso: ${response.sucesso}');
    print('Mensagem: ${response.mensagemPrincipal}');
  } catch (e) {
    print('❌ Erro ao consultar DTE: $e');
    servicoOk = false;
  }

  // 4. Validação de CNPJ
  try {
    print('\n--- 4. Validação de CNPJ ---');

    final cnpjsParaTestar = [
      '11111111111111', // Válido
      '12.345.678/0001-95', // Válido formatado
      '12345678000195', // Válido sem formatação
      '123', // Inválido - muito curto
      '123456789012345', // Inválido - muito longo
      '11111111111112', // Inválido - dígito verificador
      '', // Inválido - vazio
    ];

    for (final cnpj in cnpjsParaTestar) {
      final isValid = dteService.validarCnpjDte(cnpj);
      print('CNPJ "$cnpj" é válido: $isValid');

      if (isValid) {
        print('  Formatado: ${dteService.formatarCnpj(cnpj)}');
      }
    }
    print('✅ Validações de CNPJ concluídas');
  } catch (e) {
    print('❌ Erro na validação de CNPJ: $e');
    servicoOk = false;
  }

  // 5. Tratamento de erros específicos
  try {
    print('\n--- 5. Tratamento de Erros Específicos ---');

    final codigosErro = ['Erro-DTE-04', 'Erro-DTE-05', 'Erro-DTE-991', 'Erro-DTE-992', 'Erro-DTE-993', 'Erro-DTE-994', 'Erro-DTE-995'];

    for (final codigo in codigosErro) {
      final isKnown = dteService.isErroConhecido(codigo);
      print('Erro conhecido ($codigo): $isKnown');

      if (isKnown) {
        final info = dteService.obterInfoErro(codigo);
        if (info != null) {
          print('  Tipo: ${info['tipo']}');
          print('  Descrição: ${info['descricao']}');
          print('  Ação: ${info['acao']}');
        }
      }
    }
    print('✅ Tratamento de erros específicos concluído');
  } catch (e) {
    print('❌ Erro no tratamento de erros específicos: $e');
    servicoOk = false;
  }

  // 6. Análise de resposta completa
  try {
    print('\n--- 6. Análise de Resposta Completa ---');
    final response = await dteService.obterIndicadorDte('00000000000000');

    final analise = dteService.analisarResposta(response);
    print('✅ Análise da resposta:');
    for (final entry in analise.entries) {
      print('  ${entry.key}: ${entry.value}');
    }
  } catch (e) {
    print('❌ Erro na análise: $e');
    servicoOk = false;
  }

  // 7. Exemplo com diferentes cenários de enquadramento
  try {
    print('\n--- 7. Cenários de Enquadramento ---');

    final cenarios = [
      {'cnpj': '11111111111111', 'descricao': 'CNPJ de teste 1'},
      {'cnpj': '22222222222222', 'descricao': 'CNPJ de teste 2'},
      {'cnpj': '33333333333333', 'descricao': 'CNPJ de teste 3'},
    ];

    for (final cenario in cenarios) {
      try {
        print('\nTestando ${cenario['descricao']}:');
        final response = await dteService.obterIndicadorDte(cenario['cnpj']!);

        if (response.sucesso && response.dadosParsed != null) {
          final dados = response.dadosParsed!;
          print('  Indicador: ${dados.indicadorEnquadramento}');
          print('  Status: ${dados.statusEnquadramento}');
          print('  Descrição: ${dados.indicadorDescricao}');

          // Interpretação do resultado
          if (dados.indicadorEnquadramento == 0) {
            print('  → Este contribuinte é OPTANTE DTE');
          } else if (dados.indicadorEnquadramento == 1) {
            print('  → Este contribuinte é OPTANTE SIMPLES NACIONAL');
          } else if (dados.indicadorEnquadramento == 2) {
            print('  → Este contribuinte é OPTANTE DTE E SIMPLES NACIONAL');
          } else if (dados.indicadorEnquadramento == -1) {
            print('  → Este contribuinte NÃO É OPTANTE');
          } else if (dados.indicadorEnquadramento == -2) {
            print('  → Este NI (Número de Identificação) é INVÁLIDO');
          }
        } else {
          print('  Erro: ${response.mensagemPrincipal}');
        }
      } catch (e) {
        print('  Erro: $e');
      }
    }
    print('✅ Cenários de enquadramento concluídos');
  } catch (e) {
    print('❌ Erro nos cenários de enquadramento: $e');
    servicoOk = false;
  }

  // 8. Exemplo de uso prático - Verificação de elegibilidade
  try {
    print('\n--- 8. Verificação de Elegibilidade para DTE ---');
    final cnpjEmpresa = '11111111111111';
    print('Verificando elegibilidade da empresa $cnpjEmpresa para DTE...');

    final response = await dteService.obterIndicadorDte(cnpjEmpresa);

    if (response.sucesso && response.dadosParsed != null) {
      final dados = response.dadosParsed!;

      print('\n✅ Resultado da verificação:');
      print('Status: ${dados.statusEnquadramento}');

      if (dados.indicadorEnquadramento == 0 || dados.indicadorEnquadramento == 2) {
        print('✓ Esta empresa PODE utilizar o DTE');
        print('✓ Sua Caixa Postal no e-CAC será considerada Domicílio Tributário');
      } else if (dados.indicadorEnquadramento == 1) {
        print('⚠ Esta empresa é optante do Simples Nacional');
        print('⚠ Verifique se pode utilizar o DTE conforme legislação');
      } else if (dados.indicadorEnquadramento == -1) {
        print('✗ Esta empresa NÃO é optante');
        print('✗ Não pode utilizar o DTE');
      } else if (dados.indicadorEnquadramento == -2) {
        print('✗ CNPJ inválido');
        print('✗ Verifique o número do CNPJ');
      }
    } else {
      print('✗ Erro na verificação: ${response.mensagemPrincipal}');
    }
  } catch (e) {
    print('❌ Erro na verificação de elegibilidade: $e');
    servicoOk = false;
  }

  // 9. Exemplo com dados da documentação oficial
  try {
    print('\n--- 9. Exemplo com Dados da Documentação Oficial ---');

    // Dados do exemplo da documentação
    final exemploDocumentacao = {'contratante': '11111111111111', 'autorPedidoDados': '11111111111111', 'contribuinte': '99999999999999'};

    print('Dados do exemplo da documentação:');
    print('Contratante: ${exemploDocumentacao['contratante']}');
    print('Autor do Pedido: ${exemploDocumentacao['autorPedidoDados']}');
    print('Contribuinte: ${exemploDocumentacao['contribuinte']}');

    final response = await dteService.obterIndicadorDte(exemploDocumentacao['contribuinte']!);

    print('\n✅ Resposta do exemplo da documentação:');
    print('Status HTTP: ${response.status}');
    print('Sucesso: ${response.sucesso}');
    print('Mensagem: ${response.mensagemPrincipal}');

    if (response.sucesso && response.dadosParsed != null) {
      final dados = response.dadosParsed!;
      print('Indicador: ${dados.indicadorEnquadramento}');
      print('Status: ${dados.statusEnquadramento}');

      // Simular o JSON de retorno da documentação
      print('\nJSON de retorno (formato da documentação):');
      print('{');
      print('  "contratante": {');
      print('    "numero": "${exemploDocumentacao['contratante']}",');
      print('    "tipo": 2');
      print('  },');
      print('  "autorPedidoDados": {');
      print('    "numero": "${exemploDocumentacao['autorPedidoDados']}",');
      print('    "tipo": 2');
      print('  },');
      print('  "contribuinte": {');
      print('    "numero": "${exemploDocumentacao['contribuinte']}",');
      print('    "tipo": 2');
      print('  },');
      print('  "pedidoDados": {');
      print('    "idSistema": "DTE",');
      print('    "idServico": "CONSULTASITUACAODTE111",');
      print('    "versaoSistema": "1.0",');
      print('    "dados": ""');
      print('  },');
      print('  "status": ${response.status},');
      print('  "dados": "${response.dados}",');
      print('  "mensagens": [');
      for (final mensagem in response.mensagens) {
        print('    {');
        print('      "codigo": "${mensagem.codigo}",');
        print('      "texto": "${mensagem.texto}"');
        print('    }');
      }
      print('  ]');
      print('}');
    }
  } catch (e) {
    print('❌ Erro no exemplo da documentação: $e');
    servicoOk = false;
  }

  // 10. Resumo dos indicadores de enquadramento
  try {
    print('\n--- 10. Resumo dos Indicadores de Enquadramento ---');
    print('Conforme documentação DTE:');
    print('  -2: NI inválido');
    print('  -1: NI Não optante');
    print('   0: NI Optante DTE');
    print('   1: NI Optante Simples');
    print('   2: NI Optante DTE e Simples');

    // Testar todos os indicadores possíveis
    for (int indicador = -2; indicador <= 2; indicador++) {
      final descricao = dteService.obterDescricaoIndicador(indicador);
      final isValid = dteService.isIndicadorValido(indicador);
      print('Indicador $indicador: $descricao (válido: $isValid)');
    }
    print('✅ Resumo dos indicadores concluído');
  } catch (e) {
    print('❌ Erro no resumo dos indicadores: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO DTE ===');
  if (servicoOk) {
    print('✅ Serviço DTE: OK');
  } else {
    print('❌ Serviço DTE: ERRO');
  }

  print('\n=== Exemplos DTE Concluídos ===');
}
