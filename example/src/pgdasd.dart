import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as pgdasd_models;
import 'package:serpro_integra_contador_api/src/models/pgdasd/gerar_das_avulso_request.dart' as pgdasd_avulso_models;

Future<void> Pgdasd(ApiClient apiClient) async {
  print('=== Exemplos PGDASD ===');

  final pgdasdService = PgdasdService(apiClient);
  bool servicoOk = true;

  // 1. Entregar Declaração Mensal (TRANSDECLARACAO11)
  try {
    print('\n--- 1. Entregando Declaração Mensal ---');

    // Criar declaração de exemplo com dados reais conforme documentação
    final declaracao = pgdasd_models.Declaracao(
      tipoDeclaracao: 1, // Original
      receitaPaCompetenciaInterno: 50000.00,
      receitaPaCompetenciaExterno: 10000.00,
      estabelecimentos: [
        pgdasd_models.Estabelecimento(
          cnpjCompleto: '00000000000100',
          atividades: [
            pgdasd_models.Atividade(
              idAtividade: 1,
              valorAtividade: 60000.00,
              receitasAtividade: [
                pgdasd_models.ReceitaAtividade(
                  valor: 60000.00,
                  isencoes: [pgdasd_models.Isencao(codTributo: 1, valor: 1000.00, identificador: 1)],
                  reducoes: [pgdasd_models.Reducao(codTributo: 1, valor: 500.00, percentualReducao: 5.0, identificador: 1)],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final entregarResponse = await pgdasdService.entregarDeclaracaoSimples(
      cnpj: '00000000000100',
      periodoApuracao: 202101,
      declaracao: declaracao,
      transmitir: true,
      compararValores: true,
      valoresParaComparacao: [
        pgdasd_models.ValorDevido(codigoTributo: 1, valor: 1000.00),
        pgdasd_models.ValorDevido(codigoTributo: 2, valor: 500.00),
      ],
    );

    print('✅ Status: ${entregarResponse.status}');
    print('✅ Sucesso: ${entregarResponse.sucesso}');

    if (entregarResponse.dadosParsed != null) {
      final declaracaoTransmitida = entregarResponse.dadosParsed!.first;
      print('🆔 ID Declaração: ${declaracaoTransmitida.idDeclaracao}');
      print('📅 Data Transmissão: ${declaracaoTransmitida.dataHoraTransmissao}');
      print('💰 Valor Total Devido: R\$ ${declaracaoTransmitida.valorTotalDevido.toStringAsFixed(2)}');
      print('📋 Tem MAED: ${declaracaoTransmitida.temMaed}');

      // Detalhamento dos valores devidos
      print('\n📊 Valores Devidos por Tributo:');
      for (final valor in declaracaoTransmitida.valoresDevidos) {
        print('  • Tributo ${valor.codigoTributo}: R\$ ${valor.valor.toStringAsFixed(2)}');
      }

      // Detalhamento MAED se houver
      if (declaracaoTransmitida.temMaed && declaracaoTransmitida.detalhamentoDarfMaed != null) {
        final maed = declaracaoTransmitida.detalhamentoDarfMaed!;
        print('\n📋 Detalhamento MAED:');
        print('  📄 Número Documento: ${maed.numeroDocumento}');
        print('  📅 Data Vencimento: ${maed.dataVencimento}');
        print('  💰 Principal: R\$ ${maed.valores.principal.toStringAsFixed(2)}');
        print('  💰 Multa: R\$ ${maed.valores.multa.toStringAsFixed(2)}');
        print('  💰 Juros: R\$ ${maed.valores.juros.toStringAsFixed(2)}');
        print('  💰 Total MAED: R\$ ${maed.valores.total.toStringAsFixed(2)}');
      }
    }
  } catch (e) {
    print('❌ Erro ao entregar declaração mensal: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Gerar DAS (GERARDAS12)
  try {
    print('\n--- 2. Gerando DAS ---');

    final gerarDasResponse = await pgdasdService.gerarDasSimples(
      cnpj: '00000000000100',
      periodoApuracao: '202101',
      //dataConsolidacao: '20220831', // Data futura para consolidação
    );

    print('✅ Status: ${gerarDasResponse.status}');
    print('✅ Sucesso: ${gerarDasResponse.sucesso}');

    if (gerarDasResponse.dadosParsed != null) {
      final das = gerarDasResponse.dadosParsed!.first;
      print('🏢 CNPJ: ${das.cnpjCompleto}');
      print('📅 Período: ${das.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${das.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${das.detalhamento.dataVencimento}');
      print('📅 Data Limite Acolhimento: ${das.detalhamento.dataLimiteAcolhimento}');
      print('💰 Valor Total: R\$ ${das.detalhamento.valores.total.toStringAsFixed(2)}');
      print('📄 PDF disponível: ${das.pdf.isNotEmpty}');

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print('  💰 Principal: R\$ ${das.detalhamento.valores.principal.toStringAsFixed(2)}');
      print('  💰 Multa: R\$ ${das.detalhamento.valores.multa.toStringAsFixed(2)}');
      print('  💰 Juros: R\$ ${das.detalhamento.valores.juros.toStringAsFixed(2)}');

      // Composição por tributo se disponível
      if (das.detalhamento.composicao != null && das.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in das.detalhamento.composicao!) {
          print('  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}');
        }
      }

      // Observações se houver
      if (das.detalhamento.observacao1 != null) print('📝 Observação 1: ${das.detalhamento.observacao1}');
      if (das.detalhamento.observacao2 != null) print('📝 Observação 2: ${das.detalhamento.observacao2}');
      if (das.detalhamento.observacao3 != null) print('📝 Observação 3: ${das.detalhamento.observacao3}');
    }
  } catch (e) {
    print('❌ Erro ao gerar DAS: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 3. Consultar Declarações por Ano-Calendário (CONSDECLARACAO13)
  try {
    print('\n--- 3. Consultando Declarações por Ano ---');

    final consultarAnoResponse = await pgdasdService.consultarDeclaracoesPorAno(
      cnpj: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      anoCalendario: '2018',
    );

    print('✅ Status: ${consultarAnoResponse.status}');
    print('✅ Sucesso: ${consultarAnoResponse.sucesso}');

    if (consultarAnoResponse.dadosParsed != null) {
      final declaracoes = consultarAnoResponse.dadosParsed!;
      print('📅 Ano Calendário: ${declaracoes.anoCalendario}');
      print('🔍 Períodos encontrados: ${declaracoes.listaPeriodos.length}');

      for (final periodo in declaracoes.listaPeriodos.take(3)) {
        print('\n📅 Período ${periodo.periodoApuracao}:');
        print('  🔧 Operações: ${periodo.operacoes.length}');

        for (final operacao in periodo.operacoes.take(2)) {
          print('    ${operacao.tipoOperacao}');
          if (operacao.isDeclaracao) {
            print('      📄 Número: ${operacao.indiceDeclaracao!.numeroDeclaracao}');
            print('      🔍 Malha: ${operacao.indiceDeclaracao!.malha ?? 'Não está em malha'}');
            print('      📅 Transmissão: ${operacao.indiceDeclaracao!.dataHoraTransmissao}');
          }
          if (operacao.isDas) {
            print('      💰 DAS: ${operacao.indiceDas!.numeroDas}');
            print('      ✅ Pago: ${operacao.indiceDas!.foiPago ? 'Sim' : 'Não'}');
            print('      📅 Emissão: ${operacao.indiceDas!.dataHoraEmissaoDas}');
          }
        }
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar declarações por ano: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 4. Consultar Declarações por Período (CONSDECLARACAO13)
  try {
    print('\n--- 4. Consultando Declarações por Período ---');

    final consultarPeriodoResponse = await pgdasdService.consultarDeclaracoesPorPeriodo(
      cnpj: '00000000000000',
      periodoApuracao: '201801',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarPeriodoResponse.status}');
    print('✅ Sucesso: ${consultarPeriodoResponse.sucesso}');

    if (consultarPeriodoResponse.dadosParsed != null) {
      final declaracoes = consultarPeriodoResponse.dadosParsed!;
      print('📅 Ano Calendário: ${declaracoes.anoCalendario}');
      print('🔍 Períodos encontrados: ${declaracoes.listaPeriodos.length}');
    }
  } catch (e) {
    print('❌ Erro ao consultar declarações por período: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 5. Consultar Última Declaração (CONSULTIMADECREC14)
  try {
    print('\n--- 5. Consultando Última Declaração ---');

    final ultimaDeclaracaoResponse = await pgdasdService.consultarUltimaDeclaracaoPorPeriodo(
      cnpj: '00000000000000',
      periodoApuracao: '201801',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${ultimaDeclaracaoResponse.status}');
    print('✅ Sucesso: ${ultimaDeclaracaoResponse.sucesso}');

    if (ultimaDeclaracaoResponse.dadosParsed != null) {
      final declaracao = ultimaDeclaracaoResponse.dadosParsed!;
      print('📄 Número Declaração: ${declaracao.numeroDeclaracao}');
      print('📄 Recibo disponível: ${declaracao.recibo.pdf.isNotEmpty}');
      print('📄 Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}');
      print('📋 Tem MAED: ${declaracao.temMaed}');

      if (declaracao.temMaed) {
        print('  📋 Notificação MAED: ${declaracao.maed!.pdfNotificacao.isNotEmpty}');
        print('  💰 DARF MAED: ${declaracao.maed!.pdfDarf.isNotEmpty}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar última declaração: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 6. Consultar Declaração por Número (CONSDECREC15)
  try {
    print('\n--- 6. Consultando Declaração por Número ---');

    final declaracaoNumeroResponse = await pgdasdService.consultarDeclaracaoPorNumeroSimples(
      cnpj: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
      numeroDeclaracao: '00000000201801001',
    );

    print('✅ Status: ${declaracaoNumeroResponse.status}');
    print('✅ Sucesso: ${declaracaoNumeroResponse.sucesso}');

    if (declaracaoNumeroResponse.dadosParsed != null) {
      final declaracao = declaracaoNumeroResponse.dadosParsed!;
      print('📄 Número Declaração: ${declaracao.numeroDeclaracao}');
      print('📄 Nome do arquivo: ${declaracao.declaracao.nomeArquivo}');
      print('📄 Arquivo Recibo: ${declaracao.recibo.pdf.isNotEmpty}');
      print('📄 Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}');
      print('📋 Tem MAED: ${declaracao.temMaed}');
    }
  } catch (e) {
    print('❌ Erro ao consultar declaração por número: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 7. Consultar Extrato do DAS (CONSEXTRATO16)
  try {
    print('\n--- 7. Consultando Extrato do DAS ---');

    final extratoDasResponse = await pgdasdService.consultarExtratoDasSimples(
      cnpj: '00000000000000',
      numeroDas: '07202136999997159',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${extratoDasResponse.status}');
    print('✅ Sucesso: ${extratoDasResponse.sucesso}');

    if (extratoDasResponse.dados.extrato.pdf.isNotEmpty) {
      print('✅ Número do DAS: ${extratoDasResponse.dados.numeroDas}');
      print('✅ Nome do arquivo: ${extratoDasResponse.dados.extrato.nomeArquivo}');
      print('✅ PDF: ${extratoDasResponse.dados.extrato.pdf.isNotEmpty}');
    }
  } catch (e) {
    print('❌ Erro ao consultar extrato do DAS: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 8. Exemplo com declaração complexa (receitas brutas anteriores, folha de salário, etc.)
  try {
    print('\n--- 8. Exemplo com Declaração Complexa ---');

    final declaracaoComplexa = pgdasd_models.Declaracao(
      tipoDeclaracao: 1, // Original
      receitaPaCompetenciaInterno: 100000.00,
      receitaPaCompetenciaExterno: 20000.00,
      receitasBrutasAnteriores: [
        pgdasd_models.ReceitaBrutaAnterior(pa: 202012, valorInterno: 80000.00, valorExterno: 15000.00),
        pgdasd_models.ReceitaBrutaAnterior(pa: 202011, valorInterno: 75000.00, valorExterno: 12000.00),
      ],
      folhasSalario: [pgdasd_models.FolhaSalario(pa: 202012, valor: 5000.00), pgdasd_models.FolhaSalario(pa: 202011, valor: 4800.00)],
      estabelecimentos: [
        pgdasd_models.Estabelecimento(
          cnpjCompleto: '00000000000100',
          atividades: [
            pgdasd_models.Atividade(
              idAtividade: 1,
              valorAtividade: 120000.00,
              receitasAtividade: [
                pgdasd_models.ReceitaAtividade(
                  valor: 120000.00,
                  qualificacoesTributarias: [
                    pgdasd_models.QualificacaoTributaria(codigoTributo: 1, id: 1),
                    pgdasd_models.QualificacaoTributaria(codigoTributo: 2, id: 2),
                  ],
                  exigibilidadesSuspensas: [
                    pgdasd_models.ExigibilidadeSuspensa(
                      codTributo: 1,
                      numeroProcesso: 123456789,
                      uf: 'SP',
                      vara: '1ª Vara Federal',
                      existeDeposito: true,
                      motivo: 1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    print('✅ Declaração complexa criada com:');
    print('📅 - Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos');
    print('💰 - Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos');
    print('🏢 - Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}');
    print('💼 - Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}');
    print(
      '🏷️ - Qualificações tributárias: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.qualificacoesTributarias!.length}',
    );
    print(
      '⚖️ - Exigibilidades suspensas: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.exigibilidadesSuspensas!.length}',
    );
  } catch (e) {
    print('❌ Erro ao criar declaração complexa: $e');
    servicoOk = false;
  }

  // 9. Gerar DAS Cobrança (GERARDASCOBRANCA17)
  try {
    print('\n--- 9. Gerando DAS Cobrança ---');

    final dasCobrancaResponse = await pgdasdService.gerarDasCobrancaSimples(cnpj: '00000000000100', periodoApuracao: '202301');

    print('✅ Status: ${dasCobrancaResponse.status}');
    print('✅ Sucesso: ${dasCobrancaResponse.sucesso}');

    if (dasCobrancaResponse.dadosParsed != null) {
      final dasCobranca = dasCobrancaResponse.dadosParsed!;
      print('🏢 CNPJ: ${dasCobranca.cnpjCompleto}');
      print('📅 Período: ${dasCobranca.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasCobranca.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${dasCobranca.detalhamento.dataVencimento}');
      print('📅 Data Limite Acolhimento: ${dasCobranca.detalhamento.dataLimiteAcolhimento}');
      print('💰 Valor Total: R\$ ${dasCobranca.detalhamento.valores.total.toStringAsFixed(2)}');
      print('📄 PDF disponível: ${dasCobranca.pdf.isNotEmpty}');

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print('  💰 Principal: R\$ ${dasCobranca.detalhamento.valores.principal.toStringAsFixed(2)}');
      print('  💰 Multa: R\$ ${dasCobranca.detalhamento.valores.multa.toStringAsFixed(2)}');
      print('  💰 Juros: R\$ ${dasCobranca.detalhamento.valores.juros.toStringAsFixed(2)}');

      // Composição por tributo se disponível
      if (dasCobranca.detalhamento.composicao != null && dasCobranca.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasCobranca.detalhamento.composicao!) {
          print('  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}');
        }
      }
    }
  } catch (e) {
    print('❌ Erro ao gerar DAS Cobrança: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 10. Gerar DAS de Processo (GERARDASPROCESSO18)
  try {
    print('\n--- 10. Gerando DAS de Processo ---');

    final dasProcessoResponse = await pgdasdService.gerarDasProcessoSimples(cnpj: '00000000000100', numeroProcesso: '00000000000000000');

    print('✅ Status: ${dasProcessoResponse.status}');
    print('✅ Sucesso: ${dasProcessoResponse.sucesso}');

    if (dasProcessoResponse.dadosParsed != null) {
      final dasProcesso = dasProcessoResponse.dadosParsed!;
      print('🏢 CNPJ: ${dasProcesso.cnpjCompleto}');
      print('📅 Período: ${dasProcesso.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasProcesso.detalhamento.numeroDocumento}');
      if (dasProcesso.detalhamento.dataVencimento != null) {
        print('📅 Data Vencimento: ${dasProcesso.detalhamento.dataVencimento}');
      }
      print('📅 Data Limite Acolhimento: ${dasProcesso.detalhamento.dataLimiteAcolhimento}');
      print('💰 Valor Total: R\$ ${dasProcesso.detalhamento.valores.total.toStringAsFixed(2)}');
      print('📄 PDF disponível: ${dasProcesso.pdf.isNotEmpty}');
      print('🔄 Múltiplos Períodos: ${dasProcesso.detalhamento.temMultiplosPeriodos ? 'Sim' : 'Não'}');

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print('  💰 Principal: R\$ ${dasProcesso.detalhamento.valores.principal.toStringAsFixed(2)}');
      print('  💰 Multa: R\$ ${dasProcesso.detalhamento.valores.multa.toStringAsFixed(2)}');
      print('  💰 Juros: R\$ ${dasProcesso.detalhamento.valores.juros.toStringAsFixed(2)}');

      // Composição por tributo se disponível
      if (dasProcesso.detalhamento.composicao != null && dasProcesso.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasProcesso.detalhamento.composicao!) {
          print('  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}');
        }
      }
    }
  } catch (e) {
    print('❌ Erro ao gerar DAS de Processo: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 11. Gerar DAS Avulso (GERARDASAVULSO19)
  try {
    print('\n--- 11. Gerando DAS Avulso ---');

    // Criar lista de tributos para DAS Avulso
    final listaTributos = [
      pgdasd_avulso_models.TributoAvulso(
        codigo: 1010, // ICMS
        valor: 111.22,
        codMunicipio: 375, // Código do município
        uf: 'PA',
      ),
      pgdasd_avulso_models.TributoAvulso(
        codigo: 1007, // ISS
        valor: 20.50,
        uf: 'RJ',
      ),
      pgdasd_avulso_models.TributoAvulso(
        codigo: 1001, // IRPJ
        valor: 100.00,
      ),
    ];

    final dasAvulsoResponse = await pgdasdService.gerarDasAvulsoSimples(
      cnpj: '00000000000100',
      periodoApuracao: '202401',
      listaTributos: listaTributos,
      dataConsolidacao: '20251231', // Data futura para consolidação
      prorrogacaoEspecial: 1, // Indicador de prorrogação especial
    );

    print('✅ Status: ${dasAvulsoResponse.status}');
    print('✅ Sucesso: ${dasAvulsoResponse.sucesso}');

    if (dasAvulsoResponse.dadosParsed != null) {
      final dasAvulso = dasAvulsoResponse.dadosParsed!;
      print('🏢 CNPJ: ${dasAvulso.cnpjCompleto}');
      print('📅 Período: ${dasAvulso.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasAvulso.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${dasAvulso.detalhamento.dataVencimento}');
      print('📅 Data Limite Acolhimento: ${dasAvulso.detalhamento.dataLimiteAcolhimento}');
      print('💰 Valor Total: R\$ ${dasAvulso.detalhamento.valores.total.toStringAsFixed(2)}');
      print('📄 PDF disponível: ${dasAvulso.pdf.isNotEmpty}');
      print('📋 Composição: ${dasAvulso.detalhamento.composicao?.length ?? 0} tributos');

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print('  💰 Principal: R\$ ${dasAvulso.detalhamento.valores.principal.toStringAsFixed(2)}');
      print('  💰 Multa: R\$ ${dasAvulso.detalhamento.valores.multa.toStringAsFixed(2)}');
      print('  💰 Juros: R\$ ${dasAvulso.detalhamento.valores.juros.toStringAsFixed(2)}');

      if (dasAvulso.detalhamento.composicao != null) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasAvulso.detalhamento.composicao!.take(3)) {
          print('  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}');
        }
      }
    }
  } catch (e) {
    print('❌ Erro ao gerar DAS Avulso: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 12. Exemplo com declaração complexa (receitas brutas anteriores, folha de salário, etc.)
  try {
    print('\n--- 12. Exemplo com Declaração Complexa ---');

    final declaracaoComplexa = pgdasd_models.Declaracao(
      tipoDeclaracao: 1, // Original
      receitaPaCompetenciaInterno: 100000.00,
      receitaPaCompetenciaExterno: 20000.00,
      receitasBrutasAnteriores: [
        pgdasd_models.ReceitaBrutaAnterior(pa: 202012, valorInterno: 80000.00, valorExterno: 15000.00),
        pgdasd_models.ReceitaBrutaAnterior(pa: 202011, valorInterno: 75000.00, valorExterno: 12000.00),
      ],
      folhasSalario: [pgdasd_models.FolhaSalario(pa: 202012, valor: 5000.00), pgdasd_models.FolhaSalario(pa: 202011, valor: 4800.00)],
      estabelecimentos: [
        pgdasd_models.Estabelecimento(
          cnpjCompleto: '00000000000100',
          atividades: [
            pgdasd_models.Atividade(
              idAtividade: 1,
              valorAtividade: 120000.00,
              receitasAtividade: [
                pgdasd_models.ReceitaAtividade(
                  valor: 120000.00,
                  qualificacoesTributarias: [
                    pgdasd_models.QualificacaoTributaria(codigoTributo: 1, id: 1),
                    pgdasd_models.QualificacaoTributaria(codigoTributo: 2, id: 2),
                  ],
                  exigibilidadesSuspensas: [
                    pgdasd_models.ExigibilidadeSuspensa(
                      codTributo: 1,
                      numeroProcesso: 123456789,
                      uf: 'SP',
                      vara: '1ª Vara Federal',
                      existeDeposito: true,
                      motivo: 1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    print('✅ Declaração complexa criada com:');
    print('📅 - Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos');
    print('💰 - Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos');
    print('🏢 - Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}');
    print('💼 - Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}');
    print(
      '🏷️ - Qualificações tributárias: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.qualificacoesTributarias!.length}',
    );
    print(
      '⚖️ - Exigibilidades suspensas: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.exigibilidadesSuspensas!.length}',
    );
  } catch (e) {
    print('❌ Erro ao criar declaração complexa: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PGDASD ===');
  if (servicoOk) {
    print('✅ Serviço PGDASD: OK');
  } else {
    print('❌ Serviço PGDASD: ERRO');
  }

  print('\n🎉 Todos os 9 serviços PGDASD executados!');
}
