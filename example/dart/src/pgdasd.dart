import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_request.dart'
    as pgdasd_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_avulso_request.dart'
    as pgdasd_avulso_models;

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
                  isencoes: [
                    pgdasd_models.Isencao(
                      codTributo: 1,
                      valor: 1000.00,
                      identificador: 1,
                    ),
                  ],
                  reducoes: [
                    pgdasd_models.Reducao(
                      codTributo: 1,
                      valor: 500.00,
                      percentualReducao: 5.0,
                      identificador: 1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final entregarResponse = await pgdasdService.entregarDeclaracao(
      cnpj: '00000000000100',
      periodoApuracao: 202101,
      declaracao: declaracao,
      indicadorTransmissao: true,
      indicadorComparacao: true,
      valoresParaComparacao: [
        pgdasd_models.ValorDevido(codigoTributo: 1, valor: 1000.00),
        pgdasd_models.ValorDevido(codigoTributo: 2, valor: 500.00),
      ],
      autorPedidoDadosNumero: '00000000000100',
      contratanteNumero: '00000000000100',
    );
    print('✅ Sucesso: ${entregarResponse.sucesso}');

    if (entregarResponse.dados != null) {
      print(
        "Mensagens: ${entregarResponse.mensagens.map((m) => m.toJson()).toList()}",
      );
      print("idDeclaracao: ${entregarResponse.dados!.idDeclaracao}.");
      print(
        "dataHoraTransmissao: ${entregarResponse.dados!.dataHoraTransmissao}",
      );
      print(
        "valoresDevidos: ${entregarResponse.dados!.valoresDevidos.map((v) => v.toJson()).toList()}",
      );
      print(
        "total valoresDevidos: ${entregarResponse.dados!.valorTotalDevido}",
      );
      print("declaracao: ${entregarResponse.dados!.declaracao.isEmpty}");
      print("recibo: ${entregarResponse.dados!.recibo.isEmpty}");
      print(
        "notificacaoMaed: ${entregarResponse.dados!.notificacaoMaed!.isEmpty}",
      );
      print("darf: ${entregarResponse.dados!.darf!.isEmpty}");
      print(
        "detalhamentoDarfMaed: ${entregarResponse.dados!.detalhamentoDarfMaed != null}",
      );
      print(
        "detalhamentoDarfMaed.periodoApuracao: ${entregarResponse.dados!.detalhamentoDarfMaed!.periodoApuracao}",
      );
      print(
        "detalhamentoDarfMaed.numeroDocumento: ${entregarResponse.dados!.detalhamentoDarfMaed?.numeroDocumento}",
      );
      print(
        "detalhamentoDarfMaed.dataVencimento: ${entregarResponse.dados!.detalhamentoDarfMaed?.dataVencimento}",
      );
      print(
        "detalhamentoDarfMaed.dataLimiteAcolhimento: ${entregarResponse.dados!.detalhamentoDarfMaed?.dataLimiteAcolhimento}",
      );
      print(
        "detalhamentoDarfMaed.valores: ${entregarResponse.dados!.detalhamentoDarfMaed?.valores.toJson()}",
      );
      print(
        "detalhamentoDarfMaed.observacao1: ${entregarResponse.dados!.detalhamentoDarfMaed?.observacao1}",
      );
      print(
        "detalhamentoDarfMaed.observacao2: ${entregarResponse.dados!.detalhamentoDarfMaed?.observacao2}",
      );
      print(
        "detalhamentoDarfMaed.observacao3: ${entregarResponse.dados!.detalhamentoDarfMaed?.observacao3}",
      );
      print(
        "detalhamentoDarfMaed.composicao: ${entregarResponse.dados!.detalhamentoDarfMaed?.composicao}\n\n",
      );
    }
  } catch (e) {
    print('❌ Erro ao entregar declaração mensal: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 2. Gerar DAS (GERARDAS12)
  try {
    print('\n--- 2. Gerando DAS ---');

    final gerarDasResponse = await pgdasdService.gerarDas(
      contribuinteNumero: '00000000000100',
      periodoApuracao: '202101',
      //dataConsolidacao: '20220831', // Data futura para consolidação
    );

    print('✅ Status: ${gerarDasResponse.status}');
    print('✅ Sucesso: ${gerarDasResponse.sucesso}');

    if (gerarDasResponse.dados != null) {
      final das = gerarDasResponse.dados!.first;
      print('🏢 CNPJ: ${das.cnpjCompleto}');
      print('📅 Período: ${das.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${das.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${das.detalhamento.dataVencimento}');
      print(
        '📅 Data Limite Acolhimento: ${das.detalhamento.dataLimiteAcolhimento}',
      );
      print(
        '💰 Valor Total: R\$ ${das.detalhamento.valores.total.toStringAsFixed(2)}',
      );
      print('📄 PDF disponível: ${das.pdf.isNotEmpty}');

      // Salvar PDF em arquivo
      if (das.pdf.isNotEmpty) {
        final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
          das.pdf,
          'das_pgdasd_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo em arquivo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print(
        '  💰 Principal: R\$ ${das.detalhamento.valores.principal.toStringAsFixed(2)}',
      );
      print(
        '  💰 Multa: R\$ ${das.detalhamento.valores.multa.toStringAsFixed(2)}',
      );
      print(
        '  💰 Juros: R\$ ${das.detalhamento.valores.juros.toStringAsFixed(2)}',
      );

      // Composição por tributo se disponível
      if (das.detalhamento.composicao != null &&
          das.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in das.detalhamento.composicao!) {
          print(
            '  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}',
          );
        }
      }

      // Observações se houver
      if (das.detalhamento.observacao1 != null) {
        print('📝 Observação 1: ${das.detalhamento.observacao1}');
      }
      if (das.detalhamento.observacao2 != null) {
        print('📝 Observação 2: ${das.detalhamento.observacao2}');
      }
      if (das.detalhamento.observacao3 != null) {
        print('📝 Observação 3: ${das.detalhamento.observacao3}');
      }
    }
  } catch (e) {
    print('❌ Erro ao gerar DAS: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 3. Consultar Declarações por Ano-Calendário (CONSDECLARACAO13)
  try {
    print('\n--- 3. Consultando Declarações por Ano ---');

    final consultarAnoResponse = await pgdasdService.consultarDeclaracoes(
      contribuinteNumero: '00000000000000',
      anoCalendario: '2018',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarAnoResponse.status}');
    print('✅ Sucesso: ${consultarAnoResponse.sucesso}');

    if (consultarAnoResponse.dados != null) {
      final declaracoes = consultarAnoResponse.dados!;
      print('📅 Ano Calendário: ${declaracoes.anoCalendario}');
      print('🔍 Períodos encontrados: ${declaracoes.listaPeriodos.length}');

      for (final periodo in declaracoes.listaPeriodos.take(3)) {
        print('\n📅 Período ${periodo.periodoApuracao}:');
        print('  🔧 Operações: ${periodo.operacoes.length}');

        for (final operacao in periodo.operacoes.take(2)) {
          print('    ${operacao.tipoOperacao}');
          if (operacao.indiceDeclaracao != null) {
            print(
              '      📄 Número: ${operacao.indiceDeclaracao!.numeroDeclaracao}',
            );
            print('      🔍 Malha: ${operacao.indiceDeclaracao!.malha}');
            print(
              '      📅 Transmissão: ${operacao.indiceDeclaracao!.dataHoraTransmissao}',
            );
          }
          if (operacao.indiceDas != null) {
            print('      💰 DAS: ${operacao.indiceDas!.numeroDas}');
            print(
              '      ✅ Pago: ${operacao.indiceDas!.dasPago ? 'Sim' : 'Não'}',
            );
            print(
              '      📅 Emissão: ${operacao.indiceDas!.dataHoraEmissaoDas}',
            );
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

    final consultarPeriodoResponse = await pgdasdService.consultarDeclaracoes(
      contribuinteNumero: '00000000000000',
      periodoApuracao: '201801',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarPeriodoResponse.status}');
    print('✅ Sucesso: ${consultarPeriodoResponse.sucesso}');

    if (consultarPeriodoResponse.dados != null) {
      final declaracoes = consultarPeriodoResponse.dados!;
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

    final ultimaDeclaracaoResponse = await pgdasdService
        .consultarUltimaDeclaracao(
          contribuinteNumero: '00000000000000',
          periodoApuracao: '201801',
          contratanteNumero: '00000000000000',
          autorPedidoDadosNumero: '00000000000000',
        );

    print('✅ Status: ${ultimaDeclaracaoResponse.status}');
    print('✅ Sucesso: ${ultimaDeclaracaoResponse.sucesso}');

    if (ultimaDeclaracaoResponse.dados != null) {
      final declaracao = ultimaDeclaracaoResponse.dados!;
      print('📄 Número Declaração: ${declaracao.numeroDeclaracao}');
      print('📄 Recibo disponível: ${declaracao.recibo.pdf.isNotEmpty}');
      print(
        '📄 Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}',
      );

      // Salvar PDFs em arquivo
      if (declaracao.recibo.pdf.isNotEmpty) {
        final sucessoRecibo = await ArquivoUtils.salvarArquivo(
          declaracao.recibo.pdf,
          'recibo_pgdasd_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('Recibo PDF salvo em arquivo: ${sucessoRecibo ? 'Sim' : 'Não'}');
      }

      if (declaracao.declaracao.pdf.isNotEmpty) {
        final sucessoDeclaracao = await ArquivoUtils.salvarArquivo(
          declaracao.declaracao.pdf,
          'declaracao_pgdasd_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print(
          'Declaração PDF salvo em arquivo: ${sucessoDeclaracao ? 'Sim' : 'Não'}',
        );
      }
      print('📋 Tem MAED: ${declaracao.temMaed}');

      if (declaracao.temMaed) {
        print(
          '  📋 Notificação MAED: ${declaracao.maed!.pdfNotificacao.isNotEmpty}',
        );
        print('  💰 DARF MAED: ${declaracao.maed!.pdfDarf.isNotEmpty}');

        // Salvar PDFs MAED em arquivo
        if (declaracao.maed!.pdfNotificacao.isNotEmpty) {
          final sucessoNotificacao = await ArquivoUtils.salvarArquivo(
            declaracao.maed!.pdfNotificacao,
            'notificacao_maed_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print(
            '  Notificação MAED PDF salvo em arquivo: ${sucessoNotificacao ? 'Sim' : 'Não'}',
          );
        }

        if (declaracao.maed!.pdfDarf.isNotEmpty) {
          final sucessoDarf = await ArquivoUtils.salvarArquivo(
            declaracao.maed!.pdfDarf,
            'darf_maed_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print(
            '  DARF MAED PDF salvo em arquivo: ${sucessoDarf ? 'Sim' : 'Não'}',
          );
        }
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

    final declaracaoNumeroResponse = await pgdasdService
        .consultarDeclaracaoPorNumero(
          contribuinteNumero: '00000000000000',
          numeroDeclaracao: '00000000201801001',
          contratanteNumero: '00000000000000',
          autorPedidoDadosNumero: '00000000000000',
        );

    print('✅ Status: ${declaracaoNumeroResponse.status}');
    print('✅ Sucesso: ${declaracaoNumeroResponse.sucesso}');

    if (declaracaoNumeroResponse.dados != null) {
      final declaracao = declaracaoNumeroResponse.dados!;
      print('📄 Número Declaração: ${declaracao.numeroDeclaracao}');
      print('📄 Nome do arquivo: ${declaracao.declaracao.nomeArquivo}');
      print('📄 Arquivo Recibo: ${declaracao.recibo.pdf.isNotEmpty}');
      print(
        '📄 Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}',
      );

      // Salvar PDFs em arquivo
      if (declaracao.recibo.pdf.isNotEmpty) {
        final sucessoRecibo = await ArquivoUtils.salvarArquivo(
          declaracao.recibo.pdf,
          'recibo_pgdasd_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('Recibo PDF salvo em arquivo: ${sucessoRecibo ? 'Sim' : 'Não'}');
      }

      if (declaracao.declaracao.pdf.isNotEmpty) {
        final sucessoDeclaracao = await ArquivoUtils.salvarArquivo(
          declaracao.declaracao.pdf,
          'declaracao_pgdasd_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print(
          'Declaração PDF salvo em arquivo: ${sucessoDeclaracao ? 'Sim' : 'Não'}',
        );
      }
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

    final extratoDasResponse = await pgdasdService.consultarExtratoDas(
      contribuinteNumero: '00000000000000',
      numeroDas: '07202136999997159',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${extratoDasResponse.status}');
    print('✅ Sucesso: ${extratoDasResponse.sucesso}');

    if (extratoDasResponse.dados.extrato.pdf.isNotEmpty) {
      print('✅ Número do DAS: ${extratoDasResponse.dados.numeroDas}');
      print(
        '✅ Nome do arquivo: ${extratoDasResponse.dados.extrato.nomeArquivo}',
      );
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
        pgdasd_models.ReceitaBrutaAnterior(
          pa: 202012,
          valorInterno: 80000.00,
          valorExterno: 15000.00,
        ),
        pgdasd_models.ReceitaBrutaAnterior(
          pa: 202011,
          valorInterno: 75000.00,
          valorExterno: 12000.00,
        ),
      ],
      folhasSalario: [
        pgdasd_models.FolhaSalario(pa: 202012, valor: 5000.00),
        pgdasd_models.FolhaSalario(pa: 202011, valor: 4800.00),
      ],
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
                    pgdasd_models.QualificacaoTributaria(
                      codigoTributo: 1,
                      id: 1,
                    ),
                    pgdasd_models.QualificacaoTributaria(
                      codigoTributo: 2,
                      id: 2,
                    ),
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
    print(
      '📅 - Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos',
    );
    print(
      '💰 - Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos',
    );
    print(
      '🏢 - Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}',
    );
    print(
      '💼 - Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}',
    );
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

    final dasCobrancaResponse = await pgdasdService.gerarDasCobranca(
      contribuinteNumero: '00000000000100',
      periodoApuracao: '202301',
    );

    print('✅ Status: ${dasCobrancaResponse.status}');
    print('✅ Sucesso: ${dasCobrancaResponse.sucesso}');

    if (dasCobrancaResponse.dados != null) {
      final dasCobranca = dasCobrancaResponse.dados!;
      print('🏢 CNPJ: ${dasCobranca.cnpjCompleto}');
      print('📅 Período: ${dasCobranca.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasCobranca.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${dasCobranca.detalhamento.dataVencimento}');
      print(
        '📅 Data Limite Acolhimento: ${dasCobranca.detalhamento.dataLimiteAcolhimento}',
      );
      print(
        '💰 Valor Total: R\$ ${dasCobranca.detalhamento.valores.total.toStringAsFixed(2)}',
      );
      print('📄 PDF disponível: ${dasCobranca.pdf.isNotEmpty}');

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print(
        '  💰 Principal: R\$ ${dasCobranca.detalhamento.valores.principal.toStringAsFixed(2)}',
      );
      print(
        '  💰 Multa: R\$ ${dasCobranca.detalhamento.valores.multa.toStringAsFixed(2)}',
      );
      print(
        '  💰 Juros: R\$ ${dasCobranca.detalhamento.valores.juros.toStringAsFixed(2)}',
      );

      // Composição por tributo se disponível
      if (dasCobranca.detalhamento.composicao != null &&
          dasCobranca.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasCobranca.detalhamento.composicao!) {
          print(
            '  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}',
          );
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

    final dasProcessoResponse = await pgdasdService.gerarDasProcesso(
      contribuinteNumero: '00000000000100',
      numeroProcesso: '00000000000000000',
    );

    print('✅ Status: ${dasProcessoResponse.status}');
    print('✅ Sucesso: ${dasProcessoResponse.sucesso}');

    if (dasProcessoResponse.dados != null) {
      final dasProcesso = dasProcessoResponse.dados!;
      print('🏢 CNPJ: ${dasProcesso.cnpjCompleto}');
      print('📅 Período: ${dasProcesso.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasProcesso.detalhamento.numeroDocumento}');
      if (dasProcesso.detalhamento.dataVencimento != null) {
        print('📅 Data Vencimento: ${dasProcesso.detalhamento.dataVencimento}');
      }
      print(
        '📅 Data Limite Acolhimento: ${dasProcesso.detalhamento.dataLimiteAcolhimento}',
      );
      print(
        '💰 Valor Total: R\$ ${dasProcesso.detalhamento.valores.total.toStringAsFixed(2)}',
      );
      print('📄 PDF disponível: ${dasProcesso.pdf.isNotEmpty}');
      print(
        '🔄 Múltiplos Períodos: ${dasProcesso.detalhamento.temMultiplosPeriodos ? 'Sim' : 'Não'}',
      );

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print(
        '  💰 Principal: R\$ ${dasProcesso.detalhamento.valores.principal.toStringAsFixed(2)}',
      );
      print(
        '  💰 Multa: R\$ ${dasProcesso.detalhamento.valores.multa.toStringAsFixed(2)}',
      );
      print(
        '  💰 Juros: R\$ ${dasProcesso.detalhamento.valores.juros.toStringAsFixed(2)}',
      );

      // Composição por tributo se disponível
      if (dasProcesso.detalhamento.composicao != null &&
          dasProcesso.detalhamento.composicao!.isNotEmpty) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasProcesso.detalhamento.composicao!) {
          print(
            '  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}',
          );
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

    final dasAvulsoResponse = await pgdasdService.gerarDasAvulso(
      contribuinteNumero: '00000000000100',
      request: GerarDasAvulsoRequest(
        periodoApuracao: '202401',
        listaTributos: listaTributos,
        dataConsolidacao: '20251231', // Data futura para consolidação
        prorrogacaoEspecial: 1, // Indicador de prorrogação especial
      ),
    );

    print('✅ Status: ${dasAvulsoResponse.status}');
    print('✅ Sucesso: ${dasAvulsoResponse.sucesso}');

    if (dasAvulsoResponse.dados != null) {
      final dasAvulso = dasAvulsoResponse.dados!;
      print('🏢 CNPJ: ${dasAvulso.cnpjCompleto}');
      print('📅 Período: ${dasAvulso.detalhamento.periodoApuracao}');
      print('📄 Número Documento: ${dasAvulso.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${dasAvulso.detalhamento.dataVencimento}');
      print(
        '📅 Data Limite Acolhimento: ${dasAvulso.detalhamento.dataLimiteAcolhimento}',
      );
      print(
        '💰 Valor Total: R\$ ${dasAvulso.detalhamento.valores.total.toStringAsFixed(2)}',
      );
      print('📄 PDF disponível: ${dasAvulso.pdf.isNotEmpty}');
      print(
        '📋 Composição: ${dasAvulso.detalhamento.composicao?.length ?? 0} tributos',
      );

      // Detalhamento dos valores
      print('\n📊 Composição dos Valores:');
      print(
        '  💰 Principal: R\$ ${dasAvulso.detalhamento.valores.principal.toStringAsFixed(2)}',
      );
      print(
        '  💰 Multa: R\$ ${dasAvulso.detalhamento.valores.multa.toStringAsFixed(2)}',
      );
      print(
        '  💰 Juros: R\$ ${dasAvulso.detalhamento.valores.juros.toStringAsFixed(2)}',
      );

      if (dasAvulso.detalhamento.composicao != null) {
        print('\n📋 Composição por Tributo:');
        for (final composicao in dasAvulso.detalhamento.composicao!.take(3)) {
          print(
            '  • ${composicao.denominacao} (${composicao.codigo}): R\$ ${composicao.valores.total.toStringAsFixed(2)}',
          );
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
        pgdasd_models.ReceitaBrutaAnterior(
          pa: 202012,
          valorInterno: 80000.00,
          valorExterno: 15000.00,
        ),
        pgdasd_models.ReceitaBrutaAnterior(
          pa: 202011,
          valorInterno: 75000.00,
          valorExterno: 12000.00,
        ),
      ],
      folhasSalario: [
        pgdasd_models.FolhaSalario(pa: 202012, valor: 5000.00),
        pgdasd_models.FolhaSalario(pa: 202011, valor: 4800.00),
      ],
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
                    pgdasd_models.QualificacaoTributaria(
                      codigoTributo: 1,
                      id: 1,
                    ),
                    pgdasd_models.QualificacaoTributaria(
                      codigoTributo: 2,
                      id: 2,
                    ),
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
    print(
      '📅 - Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos',
    );
    print(
      '💰 - Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos',
    );
    print(
      '🏢 - Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}',
    );
    print(
      '💼 - Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}',
    );
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

  // 13. Consultar Última Declaração com Pagamento (Método Composto)
  try {
    print(
      '\n--- 13. Consultar Última Declaração com Informação de Pagamento ---',
    );

    final consultaComPagamentoResponse = await pgdasdService
        .consultarUltimaDeclaracaoComPagamento(
          contribuinteNumero: '00000000000100',
          periodoApuracao: '202101',
          contratanteNumero: '00000000000100',
          autorPedidoDadosNumero: '00000000000100',
        );

    print('✅ Status: ${consultaComPagamentoResponse.status}');
    print('✅ Sucesso: ${consultaComPagamentoResponse.sucesso}');
    print(
      '💰 DAS Pago: ${consultaComPagamentoResponse.dasPago ? 'Sim ✅' : 'Não ❌'}',
    );

    if (consultaComPagamentoResponse.alertaPagamento != null &&
        consultaComPagamentoResponse.alertaPagamento!.isNotEmpty) {
      print('⚠️ Alerta: ${consultaComPagamentoResponse.alertaPagamento}');
    }

    if (consultaComPagamentoResponse.sucesso &&
        consultaComPagamentoResponse.dados != null) {
      final dados = consultaComPagamentoResponse.dados!;
      print('📋 Número Declaração: ${dados.numeroDeclaracao}');

      if (dados.declaracao.pdf.isNotEmpty) {
        print(
          '📄 Declaração disponível: Sim (${dados.declaracao.nomeArquivo})',
        );
      }
      if (dados.recibo.pdf.isNotEmpty) {
        print('📄 Recibo disponível: Sim (${dados.recibo.nomeArquivo})');
      }
      if (dados.maed != null) {
        print('📄 MAED disponível: Sim');
        print('   - Notificação: ${dados.maed!.nomeArquivoNotificacao}');
        print('   - DARF: ${dados.maed!.nomeArquivoDarf}');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar última declaração com pagamento: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 5));

  // 14. Entregar Declaração com DAS (Método Composto)
  try {
    print('\n--- 14. Entregar Declaração com Geração Automática de DAS ---');

    // Criar declaração simples para o exemplo
    final declaracaoSimples = pgdasd_models.Declaracao(
      tipoDeclaracao: 1, // Original
      receitaPaCompetenciaInterno: 30000.00,
      receitaPaCompetenciaExterno: 5000.00,
      estabelecimentos: [
        pgdasd_models.Estabelecimento(
          cnpjCompleto: '00000000000100',
          atividades: [
            pgdasd_models.Atividade(
              idAtividade: 1,
              valorAtividade: 35000.00,
              receitasAtividade: [
                pgdasd_models.ReceitaAtividade(valor: 35000.00),
              ],
            ),
          ],
        ),
      ],
    );

    final entregarComDasResponse = await pgdasdService.entregarDeclaracaoComDas(
      cnpj: '00000000000100',
      periodoApuracao: 202101,
      declaracao: declaracaoSimples,
      indicadorTransmissao: true,
      indicadorComparacao: true,
      contratanteNumero: '00000000000100',
      autorPedidoDadosNumero: '00000000000100',
    );

    print('✅ Status: ${entregarComDasResponse.status}');
    print('✅ Sucesso geral: ${entregarComDasResponse.sucesso}');
    print(
      '📋 Declaração entregue: ${entregarComDasResponse.declaracaoEntregue ? 'Sim ✅' : 'Não ❌'}',
    );
    print(
      '💰 DAS gerado: ${entregarComDasResponse.dasGerado ? 'Sim ✅' : 'Não ❌'}',
    );

    if (entregarComDasResponse.dadosDeclaracao != null) {
      print(
        '📋 ID Declaração: ${entregarComDasResponse.dadosDeclaracao!.idDeclaracao}',
      );
      print(
        '📅 Data/Hora Transmissão: ${entregarComDasResponse.dadosDeclaracao!.dataHoraTransmissao}',
      );
    }

    if (entregarComDasResponse.dadosDas != null &&
        entregarComDasResponse.dadosDas!.isNotEmpty) {
      final das = entregarComDasResponse.dadosDas!.first;
      print('📄 Número Documento DAS: ${das.detalhamento.numeroDocumento}');
      print('📅 Data Vencimento: ${das.detalhamento.dataVencimento}');
      print(
        '💰 Valor Total: R\$ ${das.detalhamento.valores.total.toStringAsFixed(2)}',
      );
    }

    if (entregarComDasResponse.mensagens.isNotEmpty) {
      print('\n📋 Mensagens:');
      for (final mensagem in entregarComDasResponse.mensagens) {
        print('  • ${mensagem.codigo}: ${mensagem.texto}');
      }
    }
  } catch (e) {
    print('❌ Erro ao entregar declaração com DAS: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO PGDASD ===');
  if (servicoOk) {
    print('✅ Serviço PGDASD: OK');
  } else {
    print('❌ Serviço PGDASD: ERRO');
  }

  print('\n🎉 Todos os serviços PGDASD executados!');
}
