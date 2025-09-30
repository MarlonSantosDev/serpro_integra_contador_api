import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as pgdasd_models;

Future<void> Pgdasd(ApiClient apiClient) async {
  print('=== Exemplos PGDASD ===');

  final pgdasdService = PgdasdService(apiClient);

  try {
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
        print('💰 Valor Total Devido: R\$ ${declaracaoTransmitida.valorTotalDevido}');
        print('📋 Tem MAED: ${declaracaoTransmitida.temMaed}');
      }
    } catch (e) {
      print('❌ Erro ao entregar declaração mensal: $e');
    }

    // 2. Gerar DAS (GERARDAS12)
    try {
      print('\n--- 2. Gerando DAS ---');

      final gerarDasResponse = await pgdasdService.gerarDasSimples(
        cnpj: '00000000000100',
        periodoApuracao: '202101',
        dataConsolidacao: '20220831', // Data futura para consolidação
      );

      print('✅ Status: ${gerarDasResponse.status}');
      print('✅ Sucesso: ${gerarDasResponse.sucesso}');

      if (gerarDasResponse.dadosParsed != null) {
        final das = gerarDasResponse.dadosParsed!.first;
        print('🏢 CNPJ: ${das.cnpjCompleto}');
        print('📅 Período: ${das.detalhamento.periodoApuracao}');
        print('📄 Número Documento: ${das.detalhamento.numeroDocumento}');
        print('📅 Data Vencimento: ${das.detalhamento.dataVencimento}');
        print('💰 Valor Total: R\$ ${das.detalhamento.valores.total}');
        print('📄 PDF disponível: ${das.pdf.isNotEmpty}');
      }
    } catch (e) {
      print('❌ Erro ao gerar DAS: $e');
    }

    // 3. Consultar Declarações por Ano-Calendário (CONSDECLARACAO13)
    try {
      print('\n--- 3. Consultando Declarações por Ano ---');

      final consultarAnoResponse = await pgdasdService.consultarDeclaracoesPorAno(cnpj: '00000000000000', anoCalendario: '2018');

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
            }
            if (operacao.isDas) {
              print('      💰 DAS: ${operacao.indiceDas!.numeroDas}');
              print('      ✅ Pago: ${operacao.indiceDas!.foiPago}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao consultar declarações por ano: $e');
    }

    // 4. Consultar Declarações por Período (CONSDECLARACAO13)
    try {
      print('\n--- 4. Consultando Declarações por Período ---');

      final consultarPeriodoResponse = await pgdasdService.consultarDeclaracoesPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

      print('✅ Status: ${consultarPeriodoResponse.status}');
      print('✅ Sucesso: ${consultarPeriodoResponse.sucesso}');
    } catch (e) {
      print('❌ Erro ao consultar declarações por período: $e');
    }

    // 5. Consultar Última Declaração (CONSULTIMADECREC14)
    try {
      print('\n--- 5. Consultando Última Declaração ---');

      final ultimaDeclaracaoResponse = await pgdasdService.consultarUltimaDeclaracaoPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

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
    }

    // 6. Consultar Declaração por Número (CONSDECREC15)
    try {
      print('\n--- 6. Consultando Declaração por Número ---');

      final declaracaoNumeroResponse = await pgdasdService.consultarDeclaracaoPorNumeroSimples(
        cnpj: '00000000000000',
        numeroDeclaracao: '00000000201801001',
      );

      print('✅ Status: ${declaracaoNumeroResponse.status}');
      print('✅ Sucesso: ${declaracaoNumeroResponse.sucesso}');
    } catch (e) {
      print('❌ Erro ao consultar declaração por número: $e');
    }

    // 7. Consultar Extrato do DAS (CONSEXTRATO16)
    try {
      print('\n--- 7. Consultando Extrato do DAS ---');

      final extratoDasResponse = await pgdasdService.consultarExtratoDasSimples(cnpj: '00000000000000', numeroDas: '07202136999997159');

      print('✅ Status: ${extratoDasResponse.status}');
      print('✅ Sucesso: ${extratoDasResponse.sucesso}');

      if (extratoDasResponse.dadosParsed != null) {
        final extrato = extratoDasResponse.dadosParsed!;
        print('💰 Número DAS: ${extrato.numeroDas}');
        print('🏢 CNPJ: ${extrato.cnpjCompleto}');
        print('📅 Período: ${extrato.periodoApuracao}');
        print('📅 Data Vencimento: ${extrato.dataVencimento}');
        print('💰 Valor Total: R\$ ${extrato.valorTotal}');
        print('📊 Status Pagamento: ${extrato.statusPagamento}');
        print('✅ Foi Pago: ${extrato.foiPago}');
        print('⏰ Está Vencido: ${extrato.estaVencido}');
        print('📋 Composição: ${extrato.composicao.length} tributos');

        for (final composicao in extrato.composicao.take(3)) {
          print('  ${composicao.nomeTributo}: R\$ ${composicao.valorTributo} (${composicao.percentual}%)');
        }
      }
    } catch (e) {
      print('❌ Erro ao consultar extrato do DAS: $e');
    }

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
    }

    // 9. Exemplo de validação de dados
    try {
      print('\n--- 9. Exemplo de Validação de Dados ---');

      // CNPJ inválido
      try {
        final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
          cnpjCompleto: '123', // CNPJ inválido
          pa: 202101,
          indicadorTransmissao: true,
          indicadorComparacao: false,
          declaracao: pgdasd_models.Declaracao(
            tipoDeclaracao: 1,
            receitaPaCompetenciaInterno: 50000.00,
            receitaPaCompetenciaExterno: 10000.00,
            estabelecimentos: [],
          ),
        );
        print('❌ CNPJ inválido detectado: ${!requestInvalido.isCnpjValido}');
      } catch (e) {
        print('⚠️ Erro esperado na validação: $e');
      }

      // Período inválido
      try {
        final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
          cnpjCompleto: '00000000000100',
          pa: 201701, // Período anterior a 2018
          indicadorTransmissao: true,
          indicadorComparacao: false,
          declaracao: pgdasd_models.Declaracao(
            tipoDeclaracao: 1,
            receitaPaCompetenciaInterno: 50000.00,
            receitaPaCompetenciaExterno: 10000.00,
            estabelecimentos: [],
          ),
        );
        print('❌ Período inválido detectado: ${!requestInvalido.isPaValido}');
      } catch (e) {
        print('⚠️ Erro esperado na validação: $e');
      }
    } catch (e) {
      print('❌ Erro na validação de dados: $e');
    }

    print('\n🎉 Todos os serviços PGDASD executados com sucesso!');
  } catch (e) {
    print('💥 Erro geral no serviço PGDASD: $e');
  }
}
