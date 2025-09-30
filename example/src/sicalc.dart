import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Sicalc(ApiClient apiClient) async {
  print('\n=== Exemplos SICALC (Sistema de Cálculo de Acréscimos Legais) ===');

  final sicalcService = SicalcService(apiClient);

  try {
    // 1. Consultar Código de Receita
    print('\n--- 1. Consultando Código de Receita ---');
    final consultarReceitaResponse = await sicalcService.consultarCodigoReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 190, // IRPF
    );

    if (consultarReceitaResponse.sucesso) {
      print('✓ Receita consultada com sucesso');
      print('Status: ${consultarReceitaResponse.status}');
      print('Mensagem: ${consultarReceitaResponse.mensagemPrincipal}');

      final dados = consultarReceitaResponse.dados;
      if (dados != null) {
        print('Código da receita: ${dados.codigoReceita}');
        print('Descrição: ${dados.descricaoReceita}');
        print('Tipo de pessoa: ${dados.tipoPessoaFormatado}');
        print('Período de apuração: ${dados.tipoPeriodoFormatado}');
        print('Ativa: ${dados.ativa}');
        print('Vigente: ${dados.isVigente}');
        if (dados.observacoes != null) {
          print('Observações: ${dados.observacoes}');
        }
      }
    } else {
      print('✗ Erro ao consultar receita: ${consultarReceitaResponse.mensagemPrincipal}');
    }

    // 2. Gerar DARF para Pessoa Física (IRPF)
    print('\n--- 2. Gerando DARF para Pessoa Física (IRPF) ---');
    final darfPfResponse = await sicalcService.gerarDarfPessoaFisica(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      dataPA: '12/2023',
      vencimento: '2024-01-31T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2024-02-15T00:00:00',
      observacao: 'DARF calculado via SICALC',
    );

    if (darfPfResponse.sucesso) {
      print('✓ DARF gerado com sucesso');
      print('Status: ${darfPfResponse.status}');
      print('Mensagem: ${darfPfResponse.mensagemPrincipal}');
      print('Tem PDF: ${darfPfResponse.temPdf}');
      print('Tamanho do PDF: ${darfPfResponse.tamanhoPdfFormatado}');

      final dados = darfPfResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor principal: ${dados.valorPrincipalFormatado}');
        print('Valor total consolidado: ${dados.valorTotalFormatado}');
        print('Valor multa: ${dados.valorMultaFormatado}');
        print('Percentual multa: ${dados.percentualMultaMora}%');
        print('Valor juros: ${dados.valorJurosFormatado}');
        print('Percentual juros: ${dados.percentualJuros}%');
        print('Data de consolidação: ${dados.dataArrecadacaoConsolidacao}');
        print('Data de validade: ${dados.dataValidadeCalculo}');
      }
    } else {
      print('✗ Erro ao gerar DARF PF: ${darfPfResponse.mensagemPrincipal}');
    }

    // 3. Gerar DARF para Pessoa Jurídica (IRPJ)
    print('\n--- 3. Gerando DARF para Pessoa Jurídica (IRPJ) ---');
    final darfPjResponse = await sicalcService.gerarDarfPessoaJuridica(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '04/2023',
      vencimento: '2023-05-31T00:00:00',
      valorImposto: 5000.00,
      dataConsolidacao: '2023-06-15T00:00:00',
      observacao: 'DARF trimestral PJ',
    );

    if (darfPjResponse.sucesso) {
      print('✓ DARF PJ gerado com sucesso');
      print('Status: ${darfPjResponse.status}');
      print('Tem PDF: ${darfPjResponse.temPdf}');

      final dados = darfPjResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF PJ: ${darfPjResponse.mensagemPrincipal}');
    }

    // 4. Gerar DARF para PIS/PASEP
    print('\n--- 4. Gerando DARF para PIS/PASEP ---');
    final darfPisResponse = await sicalcService.gerarDarfPisPasep(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 500.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      observacao: 'DARF PIS/PASEP mensal',
    );

    if (darfPisResponse.sucesso) {
      print('✓ DARF PIS/PASEP gerado com sucesso');
      print('Status: ${darfPisResponse.status}');
      print('Tem PDF: ${darfPisResponse.temPdf}');

      final dados = darfPisResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF PIS/PASEP: ${darfPisResponse.mensagemPrincipal}');
    }

    // 5. Gerar DARF para COFINS
    print('\n--- 5. Gerando DARF para COFINS ---');
    final darfCofinsResponse = await sicalcService.gerarDarfCofins(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 1000.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      observacao: 'DARF COFINS mensal',
    );

    if (darfCofinsResponse.sucesso) {
      print('✓ DARF COFINS gerado com sucesso');
      print('Status: ${darfCofinsResponse.status}');
      print('Tem PDF: ${darfCofinsResponse.temPdf}');

      final dados = darfCofinsResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF COFINS: ${darfCofinsResponse.mensagemPrincipal}');
    }

    // 6. Gerar código de barras para DARF já calculado
    print('\n--- 6. Gerando Código de Barras para DARF ---');
    if (darfPfResponse.sucesso && darfPfResponse.dados != null) {
      final codigoBarrasResponse = await sicalcService.gerarCodigoBarrasDarf(
        contribuinteNumero: '00000000000',
        numeroDocumento: darfPfResponse.dados!.numeroDocumento,
      );

      if (codigoBarrasResponse.sucesso) {
        print('✓ Código de barras gerado com sucesso');
        print('Status: ${codigoBarrasResponse.status}');
        print('Tem código de barras: ${codigoBarrasResponse.temCodigoBarras}');
        print('Tamanho: ${codigoBarrasResponse.tamanhoCodigoBarrasFormatado}');

        final dados = codigoBarrasResponse.dados;
        if (dados != null) {
          print('Número do documento: ${dados.numeroDocumento}');
          print('Tem linha digitável: ${dados.temLinhaDigitavel}');
          print('Tem QR Code: ${dados.temQrCode}');
          print('Data de geração: ${dados.dataGeracaoFormatada}');
          print('Data de validade: ${dados.dataValidadeFormatada}');
          print('Válido: ${dados.isValido}');

          final info = dados.infoCodigoBarras;
          print('Informações do código de barras:');
          print('  - Disponível: ${info['disponivel']}');
          print('  - Tamanho: ${info['tamanho_bytes_aproximado']} bytes');
          print('  - Tem linha digitável: ${info['tem_linha_digitavel']}');
          print('  - Tem QR Code: ${info['tem_qr_code']}');
          print('  - Preview: ${info['preview']}');
        }
      } else {
        print('✗ Erro ao gerar código de barras: ${codigoBarrasResponse.mensagemPrincipal}');
      }
    }

    // 7. Fluxo completo: Gerar DARF e código de barras
    print('\n--- 7. Fluxo Completo: DARF + Código de Barras ---');
    final fluxoCompletoResponse = await sicalcService.gerarDarfECodigoBarras(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '02/2024',
      vencimento: '2024-03-31T00:00:00',
      valorImposto: 1500.00,
      dataConsolidacao: '2024-04-05T00:00:00',
      observacao: 'Fluxo completo SICALC',
    );

    if (fluxoCompletoResponse.sucesso) {
      print('✓ Fluxo completo executado com sucesso');
      print('Status: ${fluxoCompletoResponse.status}');
      print('Tem código de barras: ${fluxoCompletoResponse.temCodigoBarras}');

      final dados = fluxoCompletoResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Tem linha digitável: ${dados.temLinhaDigitavel}');
        print('Tem QR Code: ${dados.temQrCode}');
      }
    } else {
      print('✗ Erro no fluxo completo: ${fluxoCompletoResponse.mensagemPrincipal}');
    }

    // 8. Consultar informações detalhadas de receita
    print('\n--- 8. Consultando Informações Detalhadas de Receita ---');
    final infoReceita = await sicalcService.obterInfoReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 1162, // PIS/PASEP
    );

    if (infoReceita != null) {
      print('✓ Informações da receita obtidas');
      print('Código: ${infoReceita['codigoReceita']}');
      print('Descrição: ${infoReceita['descricaoReceita']}');
      print('Tipo de pessoa: ${infoReceita['tipoPessoa']}');
      print('Período de apuração: ${infoReceita['tipoPeriodoApuracao']}');
      print('Ativa: ${infoReceita['ativa']}');
      print('Vigente: ${infoReceita['vigente']}');
      print('Compatível com contribuinte: ${infoReceita['compativelComContribuinte']}');
      if (infoReceita['observacoes'] != null) {
        print('Observações: ${infoReceita['observacoes']}');
      }
    } else {
      print('✗ Não foi possível obter informações da receita');
    }

    // 9. Validar compatibilidade de receita
    print('\n--- 9. Validando Compatibilidade de Receita ---');
    final isCompatible = await sicalcService.validarCompatibilidadeReceita(
      contribuinteNumero: '00000000000',
      codigoReceita: 190, // IRPF
    );

    print('Receita 190 (IRPF) é compatível com CPF: $isCompatible');

    final isCompatiblePJ = await sicalcService.validarCompatibilidadeReceita(
      contribuinteNumero: '00000000000100',
      codigoReceita: 220, // IRPJ
    );

    print('Receita 220 (IRPJ) é compatível com CNPJ: $isCompatiblePJ');

    // 10. Exemplo com DARF manual (com multa e juros pré-calculados)
    print('\n--- 10. Exemplo com DARF Manual (Multa e Juros Pré-calculados) ---');
    final darfManualResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '03/2024',
      vencimento: '2024-04-30T00:00:00',
      valorImposto: 2000.00,
      dataConsolidacao: '2024-05-10T00:00:00',
      valorMulta: 100.00, // Multa pré-calculada
      valorJuros: 50.00, // Juros pré-calculados
      observacao: 'DARF manual com multa e juros',
    );

    if (darfManualResponse.sucesso) {
      print('✓ DARF manual gerado com sucesso');
      print('Status: ${darfManualResponse.status}');
      print('Tem PDF: ${darfManualResponse.temPdf}');

      final dados = darfManualResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor principal: ${dados.valorPrincipalFormatado}');
        print('Valor total: ${dados.valorTotalFormatado}');
        print('Valor multa: ${dados.valorMultaFormatado}');
        print('Valor juros: ${dados.valorJurosFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF manual: ${darfManualResponse.mensagemPrincipal}');
    }

    // 11. Exemplo com DARF de ganho de capital
    print('\n--- 11. Exemplo com DARF de Ganho de Capital ---');
    final darfGanhoCapitalResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '04/2024',
      vencimento: '2024-05-31T00:00:00',
      valorImposto: 5000.00,
      dataConsolidacao: '2024-06-15T00:00:00',
      ganhoCapital: true,
      dataAlienacao: '2024-04-15T00:00:00',
      observacao: 'DARF ganho de capital',
    );

    if (darfGanhoCapitalResponse.sucesso) {
      print('✓ DARF ganho de capital gerado com sucesso');
      print('Status: ${darfGanhoCapitalResponse.status}');
      print('Tem PDF: ${darfGanhoCapitalResponse.temPdf}');

      final dados = darfGanhoCapitalResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF ganho de capital: ${darfGanhoCapitalResponse.mensagemPrincipal}');
    }

    // 12. Exemplo com DARF com cota
    print('\n--- 12. Exemplo com DARF com Cota ---');
    final darfCotaResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 220,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-29T00:00:00',
      valorImposto: 3000.00,
      dataConsolidacao: '2024-03-10T00:00:00',
      cota: 1,
      observacao: 'DARF com cota',
    );

    if (darfCotaResponse.sucesso) {
      print('✓ DARF com cota gerado com sucesso');
      print('Status: ${darfCotaResponse.status}');
      print('Tem PDF: ${darfCotaResponse.temPdf}');

      final dados = darfCotaResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com cota: ${darfCotaResponse.mensagemPrincipal}');
    }

    // 13. Exemplo com DARF com CNO (Cadastro Nacional de Obras)
    print('\n--- 13. Exemplo com DARF com CNO ---');
    final darfCnoResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1162,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 800.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      cno: 12345,
      observacao: 'DARF com CNO',
    );

    if (darfCnoResponse.sucesso) {
      print('✓ DARF com CNO gerado com sucesso');
      print('Status: ${darfCnoResponse.status}');
      print('Tem PDF: ${darfCnoResponse.temPdf}');

      final dados = darfCnoResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com CNO: ${darfCnoResponse.mensagemPrincipal}');
    }

    // 14. Exemplo com DARF com CNPJ do prestador
    print('\n--- 14. Exemplo com DARF com CNPJ do Prestador ---');
    final darfCnpjPrestadorResponse = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1165,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 1200.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      cnpjPrestador: 12345678000199,
      observacao: 'DARF com CNPJ do prestador',
    );

    if (darfCnpjPrestadorResponse.sucesso) {
      print('✓ DARF com CNPJ do prestador gerado com sucesso');
      print('Status: ${darfCnpjPrestadorResponse.status}');
      print('Tem PDF: ${darfCnpjPrestadorResponse.temPdf}');

      final dados = darfCnpjPrestadorResponse.dados;
      if (dados != null) {
        print('Número do documento: ${dados.numeroDocumento}');
        print('Valor total: ${dados.valorTotalFormatado}');
      }
    } else {
      print('✗ Erro ao gerar DARF com CNPJ do prestador: ${darfCnpjPrestadorResponse.mensagemPrincipal}');
    }

    // 15. Exemplo com diferentes tipos de período de apuração
    print('\n--- 15. Exemplo com Diferentes Tipos de Período de Apuração ---');

    // Mensal
    print('Testando período mensal...');
    final darfMensal = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1162,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-02-15T00:00:00',
      valorImposto: 500.00,
      dataConsolidacao: '2024-02-20T00:00:00',
      tipoPA: 'ME',
      observacao: 'DARF mensal',
    );
    print('DARF mensal: ${darfMensal.sucesso ? 'Sucesso' : 'Erro'}');

    // Trimestral
    print('Testando período trimestral...');
    final darfTrimestral = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000100',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 1164,
      codigoReceitaExtensao: 1,
      dataPA: '01/2024',
      vencimento: '2024-04-30T00:00:00',
      valorImposto: 2000.00,
      dataConsolidacao: '2024-05-10T00:00:00',
      tipoPA: 'TR',
      observacao: 'DARF trimestral',
    );
    print('DARF trimestral: ${darfTrimestral.sucesso ? 'Sucesso' : 'Erro'}');

    // Anual
    print('Testando período anual...');
    final darfAnual = await sicalcService.consolidarEGerarDarf(
      contribuinteNumero: '00000000000',
      uf: 'SP',
      municipio: 7107,
      codigoReceita: 190,
      codigoReceitaExtensao: 1,
      dataPA: '2023',
      vencimento: '2024-03-31T00:00:00',
      valorImposto: 10000.00,
      dataConsolidacao: '2024-04-15T00:00:00',
      tipoPA: 'AN',
      observacao: 'DARF anual',
    );
    print('DARF anual: ${darfAnual.sucesso ? 'Sucesso' : 'Erro'}');

    print('\n=== Exemplos SICALC Concluídos ===');
  } catch (e) {
    print('Erro geral no serviço SICALC: $e');
  }
}
