import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_request.dart' as defis;
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as pgdasd_models;
import 'package:serpro_integra_contador_api/src/services/autenticaprocurador_service.dart';

void main() async {
  // Inicializar o cliente da API
  final apiClient = ApiClient();

  // Autenticar com dados da empresa contratante e autor do pedido
  await apiClient.authenticate(
    consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Key
    consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Secret
    certPath: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Caminho para seu certificado
    certPassword: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Senha do certificado
    contratanteNumero: '00000000000100', // CNPJ da empresa que contratou o serviço na Loja Serpro
    autorPedidoDadosNumero: '00000000000100', // CPF/CNPJ do autor da requisição (pode ser procurador/contador)
  );

  // Exemplo de uso dos serviços
  //await exemplosCaixaPostal(apiClient);
  //await exemplosPgmei(apiClient);
  //await exemplosCcmei(apiClient);
  //await exemplosPgdasd(apiClient);
  await exemplosDctfWeb(apiClient);
  //await exemplosProcuracoes(apiClient);
  //await exemplosDte(apiClient);
  //await exemplosSitfis(apiClient);
  //await exemplosDefis(apiClient);
  await exemplosPagtoWeb(apiClient);
  await exemplosAutenticaProcurador(apiClient);
}

Future<void> exemplosCcmei(ApiClient apiClient) async {
  print('=== Exemplos CCMEI ===');

  final ccmeiService = CcmeiService(apiClient);

  try {
    // Emitir CCMEI
    await ccmeiService.emitirCcmei('00000000000000');
    print('CCMEI emitido com sucesso');

    // Consultar Dados CCMEI
    final consultarResponse = await ccmeiService.consultarDadosCcmei('00000000000000');
    print('Dados CCMEI consultados: ${consultarResponse.dados.nomeEmpresarial}');

    // Consultar Situação Cadastral
    await ccmeiService.consultarSituacaoCadastral('00000000000');
    print('Situação cadastral consultada');
  } catch (e) {
    print('Erro nos serviços CCMEI: $e');
  }
}

Future<void> exemplosPgmei(ApiClient apiClient) async {
  print('=== Exemplos PGMEI ===');

  final pgmeiService = PgmeiService(apiClient);
  try {
    // Gerar DAS
    final response = await pgmeiService.gerarDas('00000000000100', '2023-10');
    print('DAS gerado com sucesso Padrao');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }
  try {
    final response = await pgmeiService.gerarDasCodigoDeBarras('00000000000100', '2023-10');
    print('DAS gerado com sucesso Codigo de Barras');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }
  try {
    final response = await pgmeiService.AtualizarBeneficio('00000000000100', '2023-10');
    print('DAS gerado com sucesso Atualizar Beneficio');

    if (response.dados.isNotEmpty) {
      //final das = response.dados.first;
      print("response: ${response.dados.first.toJson()}");
    }
  } catch (e) {
    print('Erro no serviço PGMEI: Atualizar Beneficio: $e');
  }
  try {
    final response = await pgmeiService.ConsultarDividaAtiva('00000000000100', '2020');
    print('DAS gerado com sucesso Consultar Divida Ativa');

    if (response.dados.isNotEmpty) {
      final das = response.dados.first;
      print('Valor total do DAS: R\$ ${das.detalhamento.valores.total}');
    }
  } catch (e) {
    print('Erro no serviço PGMEI: .... $e');
  }
}

Future<void> exemplosPgdasd(ApiClient apiClient) async {
  print('=== Exemplos PGDASD ===');

  final pgdasdService = PgdasdService(apiClient);

  try {
    // 1. Entregar Declaração Mensal (TRANSDECLARACAO11)
    print('\n--- Entregando Declaração Mensal ---');

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

    print('Status: ${entregarResponse.status}');
    print('Sucesso: ${entregarResponse.sucesso}');

    if (entregarResponse.dadosParsed != null) {
      final declaracaoTransmitida = entregarResponse.dadosParsed!.first;
      print('ID Declaração: ${declaracaoTransmitida.idDeclaracao}');
      print('Data Transmissão: ${declaracaoTransmitida.dataHoraTransmissao}');
      print('Valor Total Devido: R\$ ${declaracaoTransmitida.valorTotalDevido}');
      print('Tem MAED: ${declaracaoTransmitida.temMaed}');
    }

    // 2. Gerar DAS (GERARDAS12)
    print('\n--- Gerando DAS ---');

    final gerarDasResponse = await pgdasdService.gerarDasSimples(
      cnpj: '00000000000100',
      periodoApuracao: '202101',
      dataConsolidacao: '20220831', // Data futura para consolidação
    );

    print('Status: ${gerarDasResponse.status}');
    print('Sucesso: ${gerarDasResponse.sucesso}');

    if (gerarDasResponse.dadosParsed != null) {
      final das = gerarDasResponse.dadosParsed!.first;
      print('CNPJ: ${das.cnpjCompleto}');
      print('Período: ${das.detalhamento.periodoApuracao}');
      print('Número Documento: ${das.detalhamento.numeroDocumento}');
      print('Data Vencimento: ${das.detalhamento.dataVencimento}');
      print('Valor Total: R\$ ${das.detalhamento.valores.total}');
      print('PDF disponível: ${das.pdf.isNotEmpty}');
    }

    // 3. Consultar Declarações por Ano-Calendário (CONSDECLARACAO13)
    print('\n--- Consultando Declarações por Ano ---');

    final consultarAnoResponse = await pgdasdService.consultarDeclaracoesPorAno(cnpj: '00000000000000', anoCalendario: '2018');

    print('Status: ${consultarAnoResponse.status}');
    print('Sucesso: ${consultarAnoResponse.sucesso}');

    if (consultarAnoResponse.dadosParsed != null) {
      final declaracoes = consultarAnoResponse.dadosParsed!;
      print('Ano Calendário: ${declaracoes.anoCalendario}');
      print('Períodos encontrados: ${declaracoes.listaPeriodos.length}');

      for (final periodo in declaracoes.listaPeriodos.take(3)) {
        print('\nPeríodo ${periodo.periodoApuracao}:');
        print('  Operações: ${periodo.operacoes.length}');

        for (final operacao in periodo.operacoes.take(2)) {
          print('    ${operacao.tipoOperacao}');
          if (operacao.isDeclaracao) {
            print('      Número: ${operacao.indiceDeclaracao!.numeroDeclaracao}');
            print('      Malha: ${operacao.indiceDeclaracao!.malha ?? 'Não está em malha'}');
          }
          if (operacao.isDas) {
            print('      DAS: ${operacao.indiceDas!.numeroDas}');
            print('      Pago: ${operacao.indiceDas!.foiPago}');
          }
        }
      }
    }

    // 4. Consultar Declarações por Período (CONSDECLARACAO13)
    print('\n--- Consultando Declarações por Período ---');

    final consultarPeriodoResponse = await pgdasdService.consultarDeclaracoesPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

    print('Status: ${consultarPeriodoResponse.status}');
    print('Sucesso: ${consultarPeriodoResponse.sucesso}');

    // 5. Consultar Última Declaração (CONSULTIMADECREC14)
    print('\n--- Consultando Última Declaração ---');

    final ultimaDeclaracaoResponse = await pgdasdService.consultarUltimaDeclaracaoPorPeriodo(cnpj: '00000000000000', periodoApuracao: '201801');

    print('Status: ${ultimaDeclaracaoResponse.status}');
    print('Sucesso: ${ultimaDeclaracaoResponse.sucesso}');

    if (ultimaDeclaracaoResponse.dadosParsed != null) {
      final declaracao = ultimaDeclaracaoResponse.dadosParsed!;
      print('Número Declaração: ${declaracao.numeroDeclaracao}');
      print('Recibo disponível: ${declaracao.recibo.pdf.isNotEmpty}');
      print('Declaração disponível: ${declaracao.declaracao.pdf.isNotEmpty}');
      print('Tem MAED: ${declaracao.temMaed}');

      if (declaracao.temMaed) {
        print('  Notificação MAED: ${declaracao.maed!.pdfNotificacao.isNotEmpty}');
        print('  DARF MAED: ${declaracao.maed!.pdfDarf.isNotEmpty}');
      }
    }

    // 6. Consultar Declaração por Número (CONSDECREC15)
    print('\n--- Consultando Declaração por Número ---');

    final declaracaoNumeroResponse = await pgdasdService.consultarDeclaracaoPorNumeroSimples(
      cnpj: '00000000000000',
      numeroDeclaracao: '00000000201801001',
    );

    print('Status: ${declaracaoNumeroResponse.status}');
    print('Sucesso: ${declaracaoNumeroResponse.sucesso}');

    // 7. Consultar Extrato do DAS (CONSEXTRATO16)
    print('\n--- Consultando Extrato do DAS ---');

    final extratoDasResponse = await pgdasdService.consultarExtratoDasSimples(cnpj: '00000000000000', numeroDas: '07202136999997159');

    print('Status: ${extratoDasResponse.status}');
    print('Sucesso: ${extratoDasResponse.sucesso}');

    if (extratoDasResponse.dadosParsed != null) {
      final extrato = extratoDasResponse.dadosParsed!;
      print('Número DAS: ${extrato.numeroDas}');
      print('CNPJ: ${extrato.cnpjCompleto}');
      print('Período: ${extrato.periodoApuracao}');
      print('Data Vencimento: ${extrato.dataVencimento}');
      print('Valor Total: R\$ ${extrato.valorTotal}');
      print('Status Pagamento: ${extrato.statusPagamento}');
      print('Foi Pago: ${extrato.foiPago}');
      print('Está Vencido: ${extrato.estaVencido}');
      print('Composição: ${extrato.composicao.length} tributos');

      for (final composicao in extrato.composicao.take(3)) {
        print('  ${composicao.nomeTributo}: R\$ ${composicao.valorTributo} (${composicao.percentual}%)');
      }
    }

    // 8. Exemplo com declaração complexa (receitas brutas anteriores, folha de salário, etc.)
    print('\n--- Exemplo com Declaração Complexa ---');

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

    print('Declaração complexa criada com:');
    print('- Receitas brutas anteriores: ${declaracaoComplexa.receitasBrutasAnteriores!.length} períodos');
    print('- Folhas de salário: ${declaracaoComplexa.folhasSalario!.length} períodos');
    print('- Estabelecimentos: ${declaracaoComplexa.estabelecimentos.length}');
    print('- Atividades: ${declaracaoComplexa.estabelecimentos.first.atividades!.length}');
    print(
      '- Qualificações tributárias: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.qualificacoesTributarias!.length}',
    );
    print(
      '- Exigibilidades suspensas: ${declaracaoComplexa.estabelecimentos.first.atividades!.first.receitasAtividade.first.exigibilidadesSuspensas!.length}',
    );

    // 9. Exemplo de validação de dados
    print('\n--- Exemplo de Validação de Dados ---');

    // CNPJ inválido
    try {
      final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
        cnpjCompleto: '123', // CNPJ inválido
        pa: 202101,
        indicadorTransmissao: true,
        indicadorComparacao: false,
        declaracao: declaracao,
      );
      print('CNPJ inválido detectado: ${!requestInvalido.isCnpjValido}');
    } catch (e) {
      print('Erro esperado na validação: $e');
    }

    // Período inválido
    try {
      final requestInvalido = pgdasd_models.EntregarDeclaracaoRequest(
        cnpjCompleto: '00000000000100',
        pa: 201701, // Período anterior a 2018
        indicadorTransmissao: true,
        indicadorComparacao: false,
        declaracao: declaracao,
      );
      print('Período inválido detectado: ${!requestInvalido.isPaValido}');
    } catch (e) {
      print('Erro esperado na validação: $e');
    }

    print('\n=== Exemplos PGDASD Concluídos ===');
  } catch (e) {
    print('Erro no serviço PGDASD: $e');
  }
}

Future<void> exemplosDctfWeb(ApiClient apiClient) async {
  print('=== Exemplos DCTFWeb ===');

  final dctfWebService = DctfWebService(apiClient);

  try {
    /*
    // 1. Consultar XML de uma declaração (Geral Mensal)
    print('\n--- Consultando XML da declaração ---');
    final xmlResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000',
      categoria: CategoriaDctf.pfMensal,
      anoPA: '2022',
      mesPA: '06',
      contratanteNumero: '00000000000',
      autorPedidoDadosNumero: '00000000000',
    );

    print('Status: ${xmlResponse.status}');
    print('XML disponível: ${xmlResponse.xmlBase64 != null}');

    if (xmlResponse.xmlBase64 != null) {
      print('Tamanho do XML: ${xmlResponse.xmlBase64!.length} caracteres');
    }

    // Exibir mensagens
    for (final msg in xmlResponse.mensagens) {
      print('${msg.tipo}: ${msg.texto}');
    }

    // 2. Gerar documento de arrecadação para declaração ATIVA
    print('\n--- Gerando documento de arrecadação (DARF) ---');
    final darfResponse = await dctfWebService.gerarDocumentoArrecadacao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2027',
      mesPA: '11',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('Status: ${darfResponse.status}');
    print('DARF disponível: ${darfResponse.pdfBase64 != null}');

    if (darfResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${darfResponse.tamanhoPdfBytes} bytes');
    }

    // 3. Gerar documento de arrecadação para declaração EM ANDAMENTO
    print('\n--- Gerando DARF para declaração em andamento ---');
    final darfAndamentoResponse = await dctfWebService.gerarDocumentoArrecadacaoAndamento(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2025',
      mesPA: '01',
      idsSistemaOrigem: [SistemaOrigem.mit], // Apenas receitas do MIT
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('Status: ${darfAndamentoResponse.status}');
    print('DARF em andamento disponível: ${darfAndamentoResponse.pdfBase64 != null}');

    // 4. Consultar recibo de transmissão
    print('\n--- Consultando recibo de transmissão ---');
    final reciboResponse = await dctfWebService.consultarReciboTransmissao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2027',
      mesPA: '11',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('Status: ${reciboResponse.status}');
    print('Recibo disponível: ${reciboResponse.pdfBase64 != null}');

    // 5. Consultar declaração completa
    print('\n--- Consultando declaração completa ---');
    final declaracaoResponse = await dctfWebService.consultarDeclaracaoCompleta(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2027',
      mesPA: '11',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('Status: ${declaracaoResponse.status}');
    print('Declaração completa disponível: ${declaracaoResponse.pdfBase64 != null}');
*/
    // 6. Exemplo de métodos de conveniência
    print('\n--- Métodos de conveniência ---');

    // DARF Geral Mensal
    final darfGeralResponse = await dctfWebService.gerarDarfGeralMensal(
      contribuinteNumero: '00000000000000',
      anoPA: '2027',
      mesPA: '11',
      idsSistemaOrigem: [SistemaOrigem.esocial, SistemaOrigem.mit],
    );
    print('DARF Geral Mensal: ${darfGeralResponse.sucesso}');

    // DARF Pessoa Física Mensal
    final darfPfResponse = await dctfWebService.gerarDarfPfMensal(contribuinteNumero: '00000000000', anoPA: '2022', mesPA: '06');
    print('DARF PF Mensal: ${darfPfResponse.sucesso}');

    // DARF 13º Salário
    final darf13Response = await dctfWebService.gerarDarf13Salario(contribuinteNumero: '00000000000000', anoPA: '2022', isPessoaFisica: false);
    print('DARF 13º Salário: ${darf13Response.sucesso}');

    // 7. Exemplo com categoria específica - Espetáculo Desportivo
    print('\n--- Exemplo Espetáculo Desportivo ---');
    final espetaculoResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.espetaculoDesportivo,
      anoPA: '2022',
      mesPA: '05',
      diaPA: '14', // Dia obrigatório para espetáculo desportivo
    );
    print('XML Espetáculo Desportivo: ${espetaculoResponse.sucesso}');

    // 8. Exemplo com categoria Aferição
    print('\n--- Exemplo Aferição ---');
    final afericaoResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.afericao,
      anoPA: '2022',
      mesPA: '03',
      cnoAfericao: 28151, // CNO obrigatório para aferição
    );
    print('XML Aferição: ${afericaoResponse.sucesso}');

    // 9. Exemplo com categoria Reclamatória Trabalhista
    print('\n--- Exemplo Reclamatória Trabalhista ---');
    final reclamatoriaResponse = await dctfWebService.consultarReciboTransmissao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.reclamatoriaTrabalhista,
      anoPA: '2022',
      mesPA: '12',
      numProcReclamatoria: '00365354520004013400', // Processo obrigatório
    );
    print('Recibo Reclamatória: ${reclamatoriaResponse.sucesso}');

    // 10. Exemplo de transmissão completa (simulada)
    print('\n--- Exemplo de fluxo completo (simulado) ---');
    print('ATENÇÃO: Este exemplo simula a assinatura digital.');
    print('Em produção, você deve implementar a assinatura real com certificado digital.');

    try {
      final transmissaoResponse = await dctfWebService.consultarXmlETransmitir(
        contribuinteNumero: '00000000000',
        categoria: CategoriaDctf.pfMensal,
        anoPA: '2022',
        mesPA: '06',
        assinadorXml: (xmlBase64) async {
          // SIMULAÇÃO: Em produção, aqui você faria a assinatura digital real
          print('Simulando assinatura digital do XML...');

          // Esta é apenas uma simulação - NÃO USE EM PRODUÇÃO
          // Você deve implementar a assinatura digital real com seu certificado
          return xmlBase64 + '_ASSINADO_SIMULADO';
        },
      );

      print('Transmissão simulada: ${transmissaoResponse.status}');
      print('Tem MAED: ${transmissaoResponse.temMaed}');

      if (transmissaoResponse.infoTransmissao != null) {
        final info = transmissaoResponse.infoTransmissao!;
        print('Número do recibo: ${info.numeroRecibo}');
        print('Data transmissão: ${info.dataTransmissao}');
      }
    } catch (e) {
      print('Erro na transmissão simulada (esperado): $e');
    }
  } catch (e) {
    print('Erro no serviço DCTFWeb: $e');
  }
}

Future<void> exemplosProcuracoes(ApiClient apiClient) async {
  print('=== Exemplos Procurações ===');

  final procuracoesService = ProcuracoesService(apiClient);

  try {
    // Obter Procuração
    final response = await procuracoesService.obterProcuracao('00000000000000');
    print('Procurações obtidas: ${response.dadosSaida.procuracoes.length}');
  } catch (e) {
    print('Erro no serviço de Procurações: $e');
  }
}

Future<void> exemplosCaixaPostal(ApiClient apiClient) async {
  print('=== Exemplos Caixa Postal ===');

  final caixaPostalService = CaixaPostalService(apiClient);

  try {
    // 1. Verificar se há mensagens novas
    print('\n--- Verificando mensagens novas ---');
    final temNovas = await caixaPostalService.temMensagensNovas('99999999999');
    print('Tem mensagens novas: $temNovas');

    // 2. Obter indicador detalhado de mensagens novas
    print('\n--- Indicador de mensagens novas ---');
    final indicadorResponse = await caixaPostalService.obterIndicadorNovasMensagens('99999999999');
    print('Status HTTP: ${indicadorResponse.status}');
    if (indicadorResponse.dadosParsed != null) {
      final conteudo = indicadorResponse.dadosParsed!.conteudo.first;
      print('Indicador: ${conteudo.indicadorMensagensNovas}');
      print('Status: ${conteudo.statusMensagensNovas}');
      print('Descrição: ${conteudo.descricaoStatus}');
      print('Tem mensagens novas: ${conteudo.temMensagensNovas}');
    }

    // 3. Listar todas as mensagens
    print('\n--- Listando todas as mensagens ---');
    final listaResponse = await caixaPostalService.listarTodasMensagens('99999999999');
    print('Status HTTP: ${listaResponse.status}');
    if (listaResponse.dadosParsed != null && listaResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = listaResponse.dadosParsed!.conteudo.first;
      print('Quantidade de mensagens: ${conteudo.quantidadeMensagensInt}');
      print('É última página: ${conteudo.isUltimaPagina}');
      print('Ponteiro próxima página: ${conteudo.ponteiroProximaPagina}');

      // Exibir primeiras 3 mensagens
      final mensagens = conteudo.listaMensagens.take(3);
      for (var i = 0; i < mensagens.length; i++) {
        final msg = mensagens.elementAt(i);
        print('\nMensagem ${i + 1}:');
        print('  ISN: ${msg.isn}');
        print('  Assunto: ${msg.assuntoProcessado}');
        print('  Data envio: ${MessageUtils.formatarData(msg.dataEnvio)}');
        print('  Foi lida: ${msg.foiLida}');
        print('  É favorita: ${msg.isFavorita}');
        print('  Relevância: ${MessageUtils.obterDescricaoRelevancia(msg.relevancia)}');
        print('  Origem: ${msg.descricaoOrigem}');
      }
    }

    // 4. Listar apenas mensagens não lidas
    print('\n--- Listando mensagens não lidas ---');
    final naoLidasResponse = await caixaPostalService.listarMensagensNaoLidas('99999999999');
    if (naoLidasResponse.dadosParsed != null && naoLidasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = naoLidasResponse.dadosParsed!.conteudo.first;
      print('Mensagens não lidas: ${conteudo.quantidadeMensagensInt}');
    }

    // 5. Listar apenas mensagens lidas
    print('\n--- Listando mensagens lidas ---');
    final lidasResponse = await caixaPostalService.listarMensagensLidas('99999999999');
    if (lidasResponse.dadosParsed != null && lidasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = lidasResponse.dadosParsed!.conteudo.first;
      print('Mensagens lidas: ${conteudo.quantidadeMensagensInt}');
    }

    // 6. Listar mensagens favoritas
    print('\n--- Listando mensagens favoritas ---');
    final favoritasResponse = await caixaPostalService.listarMensagensFavoritas('99999999999');
    if (favoritasResponse.dadosParsed != null && favoritasResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = favoritasResponse.dadosParsed!.conteudo.first;
      print('Mensagens favoritas: ${conteudo.quantidadeMensagensInt}');
    }

    // 7. Obter detalhes de uma mensagem específica (usando ISN da primeira mensagem)
    if (listaResponse.dadosParsed != null &&
        listaResponse.dadosParsed!.conteudo.isNotEmpty &&
        listaResponse.dadosParsed!.conteudo.first.listaMensagens.isNotEmpty) {
      final primeiraMsg = listaResponse.dadosParsed!.conteudo.first.listaMensagens.first;
      print('\n--- Detalhes da mensagem ISN: ${primeiraMsg.isn} ---');

      final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica('99999999999', primeiraMsg.isn);

      if (detalhesResponse.dadosParsed != null && detalhesResponse.dadosParsed!.conteudo.isNotEmpty) {
        final detalhe = detalhesResponse.dadosParsed!.conteudo.first;
        print('Assunto processado: ${detalhe.assuntoProcessado}');
        print('Data de envio: ${MessageUtils.formatarData(detalhe.dataEnvio)}');
        print('Data de expiração: ${MessageUtils.formatarData(detalhe.dataExpiracao)}');
        print('É favorita: ${detalhe.isFavorita}');

        // Corpo da mensagem processado
        final corpoProcessado = detalhe.corpoProcessado;
        final corpoLimpo = MessageUtils.removerTagsHtml(corpoProcessado);
        print('Corpo (primeiros 200 caracteres):');
        print('${corpoLimpo.length > 200 ? corpoLimpo.substring(0, 200) + '...' : corpoLimpo}');

        // Mostrar variáveis se existirem
        if (detalhe.variaveis.isNotEmpty) {
          print('\nVariáveis da mensagem:');
          for (var i = 0; i < detalhe.variaveis.length; i++) {
            print('  ++${i + 1}++: ${detalhe.variaveis[i]}');
          }
        }
      }
    }

    // 8. Exemplo de paginação (se houver mais páginas)
    if (listaResponse.dadosParsed != null &&
        listaResponse.dadosParsed!.conteudo.isNotEmpty &&
        !listaResponse.dadosParsed!.conteudo.first.isUltimaPagina) {
      print('\n--- Exemplo de paginação ---');
      final proximaPagina = listaResponse.dadosParsed!.conteudo.first.ponteiroProximaPagina;

      final paginaResponse = await caixaPostalService.listarMensagensComPaginacao('99999999999', ponteiroPagina: proximaPagina);

      if (paginaResponse.dadosParsed != null && paginaResponse.dadosParsed!.conteudo.isNotEmpty) {
        final conteudo = paginaResponse.dadosParsed!.conteudo.first;
        print('Mensagens da próxima página: ${conteudo.quantidadeMensagensInt}');
      }
    }

    // 9. Exemplo usando filtros específicos
    print('\n--- Exemplo com filtros específicos ---');
    final filtradaResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
      '99999999999',
      statusLeitura: 0, // Todas as mensagens
      indicadorFavorito: null, // Sem filtro de favorita
      indicadorPagina: 0, // Página inicial
    );

    if (filtradaResponse.dadosParsed != null && filtradaResponse.dadosParsed!.conteudo.isNotEmpty) {
      final conteudo = filtradaResponse.dadosParsed!.conteudo.first;
      print('Mensagens com filtros específicos: ${conteudo.quantidadeMensagensInt}');
    }
  } catch (e) {
    print('Erro no serviço da Caixa Postal: $e');
  }
}

Future<void> exemplosDte(ApiClient apiClient) async {
  print('=== Exemplos DTE ===');

  final dteService = DteService(apiClient);

  try {
    // Declarar
    final response = await dteService.declarar('00000000000000', '{}');
    print('Declaração DTE realizada: ${response.status}');
  } catch (e) {
    print('Erro no serviço DTE: $e');
  }
}

Future<void> exemplosSitfis(ApiClient apiClient) async {
  print('=== Exemplos SITFIS ===');

  final sitfisService = SitfisService(apiClient);

  try {
    // Solicitar Protocolo
    await sitfisService.solicitarProtocolo('00000000000');
    print('Protocolo solicitado');

    // Simular protocolo para exemplo
    final protocolo = 'exemplo_protocolo';

    // Emitir Relatório
    await sitfisService.emitirRelatorio('00000000000', protocolo);
    print('Relatório SITFIS emitido');
  } catch (e) {
    print('Erro no serviço SITFIS: $e');
  }
}

Future<void> exemplosDefis(ApiClient apiClient) async {
  print('=== Exemplos DEFIS ===');

  final defisService = DefisService(apiClient);

  try {
    // Criar uma declaração de exemplo
    final declaracao = defis.TransmitirDeclaracaoRequest(
      ano: 2023,
      situacaoEspecial: null,
      inatividade: 2,
      empresa: defis.Empresa(
        ganhoCapital: 0,
        qtdEmpregadoInicial: 1,
        qtdEmpregadoFinal: 1,
        receitaExportacaoDireta: 0,
        socios: [
          defis.Socio(cpf: '00000000000', rendimentosIsentos: 10000, rendimentosTributaveis: 5000, participacaoCapitalSocial: 100, irRetidoFonte: 0),
        ],
        ganhoRendaVariavel: 0,
        estabelecimentos: [
          defis.Estabelecimento(
            cnpjCompleto: '00000000000000',
            estoqueInicial: 1000,
            estoqueFinal: 2000,
            saldoCaixaInicial: 5000,
            saldoCaixaFinal: 15000,
            aquisicoesMercadoInterno: 10000,
            importacoes: 0,
            totalEntradasPorTransferencia: 0,
            totalSaidasPorTransferencia: 0,
            totalDevolucoesVendas: 100,
            totalEntradas: 10100,
            totalDevolucoesCompras: 50,
            totalDespesas: 8000,
          ),
        ],
      ),
    );

    // Transmitir Declaração
    final response = await defisService.transmitirDeclaracao('00000000000000', declaracao);
    print('Declaração DEFIS transmitida: ${response.dados.idDefis}');
  } catch (e) {
    print('Erro no serviço DEFIS: $e');
  }
}

Future<void> exemplosPagtoWeb(ApiClient apiClient) async {
  print('=== Exemplos PAGTOWEB ===');

  final pagtoWebService = PagtoWebService(apiClient);

  try {
    // 1. Consultar pagamentos por intervalo de data
    print('\n--- Consultando pagamentos por data ---');
    final consultarDataResponse = await pagtoWebService.consultarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDataResponse.status}');
    print('Sucesso: ${consultarDataResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDataResponse.dados.length}');

    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Primeiro pagamento:');
      print('  Número: ${pagamento.numeroDocumento}');
      print('  Tipo: ${pagamento.tipo.descricao}');
      print('  Período: ${pagamento.periodoApuracao}');
      print('  Data Arrecadação: ${pagamento.dataArrecadacao}');
      print('  Valor Total: R\$ ${pagamento.valorTotal}');
      print('  Receita: ${pagamento.receitaPrincipal.descricao}');
    }

    // 2. Consultar pagamentos por códigos de receita
    print('\n--- Consultando pagamentos por receita ---');
    final consultarReceitaResponse = await pagtoWebService.consultarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarReceitaResponse.status}');
    print('Sucesso: ${consultarReceitaResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarReceitaResponse.dados.length}');

    // 3. Consultar pagamentos por intervalo de valor
    print('\n--- Consultando pagamentos por valor ---');
    final consultarValorResponse = await pagtoWebService.consultarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Status: ${consultarValorResponse.status}');
    print('Sucesso: ${consultarValorResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarValorResponse.dados.length}');

    // 4. Consultar pagamentos por números de documento
    print('\n--- Consultando pagamentos por documento ---');
    final consultarDocumentoResponse = await pagtoWebService.consultarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
      primeiroDaPagina: 0,
      tamanhoDaPagina: 10,
    );

    print('Status: ${consultarDocumentoResponse.status}');
    print('Sucesso: ${consultarDocumentoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarDocumentoResponse.dados.length}');

    // 5. Contar pagamentos por data
    print('\n--- Contando pagamentos por data ---');
    final contarDataResponse = await pagtoWebService.contarPagamentosPorData(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
    );

    print('Status: ${contarDataResponse.status}');
    print('Sucesso: ${contarDataResponse.sucesso}');
    print('Quantidade total: ${contarDataResponse.quantidade}');

    // 6. Contar pagamentos por receita
    print('\n--- Contando pagamentos por receita ---');
    final contarReceitaResponse = await pagtoWebService.contarPagamentosPorReceita(
      contribuinteNumero: '00000000000100',
      codigoReceitaLista: ['0001', '0002'],
    );

    print('Status: ${contarReceitaResponse.status}');
    print('Sucesso: ${contarReceitaResponse.sucesso}');
    print('Quantidade total: ${contarReceitaResponse.quantidade}');

    // 7. Contar pagamentos por valor
    print('\n--- Contando pagamentos por valor ---');
    final contarValorResponse = await pagtoWebService.contarPagamentosPorValor(
      contribuinteNumero: '00000000000100',
      valorInicial: 100.00,
      valorFinal: 1000.00,
    );

    print('Status: ${contarValorResponse.status}');
    print('Sucesso: ${contarValorResponse.sucesso}');
    print('Quantidade total: ${contarValorResponse.quantidade}');

    // 8. Contar pagamentos por documento
    print('\n--- Contando pagamentos por documento ---');
    final contarDocumentoResponse = await pagtoWebService.contarPagamentosPorDocumento(
      contribuinteNumero: '00000000000100',
      numeroDocumentoLista: ['12345678901234567890', '09876543210987654321'],
    );

    print('Status: ${contarDocumentoResponse.status}');
    print('Sucesso: ${contarDocumentoResponse.sucesso}');
    print('Quantidade total: ${contarDocumentoResponse.quantidade}');

    // 9. Emitir comprovante de pagamento
    print('\n--- Emitindo comprovante de pagamento ---');
    final emitirComprovanteResponse = await pagtoWebService.emitirComprovante(
      contribuinteNumero: '00000000000100',
      numeroDocumento: '12345678901234567890',
    );

    print('Status: ${emitirComprovanteResponse.status}');
    print('Sucesso: ${emitirComprovanteResponse.sucesso}');
    print('PDF disponível: ${emitirComprovanteResponse.pdfBase64 != null}');

    if (emitirComprovanteResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${emitirComprovanteResponse.pdfBase64!.length} caracteres');
    }

    // 10. Exemplo com filtros combinados
    print('\n--- Exemplo com filtros combinados ---');
    final consultarCombinadoResponse = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-06-01',
      dataFinal: '2023-06-30',
      codigoReceitaLista: ['0001'],
      valorInicial: 500.00,
      valorFinal: 2000.00,
      primeiroDaPagina: 0,
      tamanhoDaPagina: 20,
    );

    print('Status: ${consultarCombinadoResponse.status}');
    print('Sucesso: ${consultarCombinadoResponse.sucesso}');
    print('Quantidade de pagamentos: ${consultarCombinadoResponse.dados.length}');

    // 11. Exemplo de paginação
    print('\n--- Exemplo de paginação ---');
    final pagina1Response = await pagtoWebService.consultarPagamentos(
      contribuinteNumero: '00000000000100',
      dataInicial: '2023-01-01',
      dataFinal: '2023-12-31',
      primeiroDaPagina: 0,
      tamanhoDaPagina: 5,
    );

    print('Página 1 - Status: ${pagina1Response.status}');
    print('Página 1 - Quantidade: ${pagina1Response.dados.length}');

    if (pagina1Response.dados.length == 5) {
      // Simular próxima página
      final pagina2Response = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000100',
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
        primeiroDaPagina: 5,
        tamanhoDaPagina: 5,
      );

      print('Página 2 - Status: ${pagina2Response.status}');
      print('Página 2 - Quantidade: ${pagina2Response.dados.length}');
    }

    // 12. Exemplo de tratamento de erros
    print('\n--- Exemplo de tratamento de erros ---');
    try {
      final erroResponse = await pagtoWebService.consultarPagamentos(
        contribuinteNumero: '00000000000000', // CNPJ inválido
        dataInicial: '2023-01-01',
        dataFinal: '2023-12-31',
      );

      print('Status: ${erroResponse.status}');
      print('Sucesso: ${erroResponse.sucesso}');

      if (!erroResponse.sucesso) {
        print('Mensagens de erro:');
        for (final mensagem in erroResponse.mensagens) {
          print('  ${mensagem.codigo}: ${mensagem.texto}');
        }
      }
    } catch (e) {
      print('Erro capturado: $e');
    }

    // 13. Exemplo de análise de desmembramentos
    print('\n--- Exemplo de análise de desmembramentos ---');
    if (consultarDataResponse.dados.isNotEmpty) {
      final pagamento = consultarDataResponse.dados.first;
      print('Análise do pagamento ${pagamento.numeroDocumento}:');
      print('  Desmembramentos: ${pagamento.desmembramentos.length}');

      for (int i = 0; i < pagamento.desmembramentos.length; i++) {
        final desmembramento = pagamento.desmembramentos[i];
        print('  Desmembramento ${i + 1}:');
        print('    Sequencial: ${desmembramento.sequencial}');
        print('    Receita: ${desmembramento.receitaPrincipal.descricao}');
        print('    Período: ${desmembramento.periodoApuracao}');
        print('    Valor Total: R\$ ${desmembramento.valorTotal ?? 0.0}');
        print('    Valor Principal: R\$ ${desmembramento.valorPrincipal ?? 0.0}');
        print('    Valor Multa: R\$ ${desmembramento.valorMulta ?? 0.0}');
        print('    Valor Juros: R\$ ${desmembramento.valorJuros ?? 0.0}');
      }
    }

    print('\n=== Exemplos PAGTOWEB Concluídos ===');
  } catch (e) {
    print('Erro no serviço PAGTOWEB: $e');
  }
}

Future<void> exemplosAutenticaProcurador(ApiClient apiClient) async {
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
