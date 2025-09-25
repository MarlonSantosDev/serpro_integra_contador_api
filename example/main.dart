import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_request.dart' as defis;
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as pgdasd_models;

void main() async {
  // Inicializar o cliente da API
  final apiClient = ApiClient();

  // Autenticar com dados da empresa contratante e autor do pedido
  await apiClient.authenticate(
    consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Key
    consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Substitua pelo seu Consumer Secret
    certPath: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Caminho para seu certificado
    certPassword: '06aef429-a981-3ec5-a1f8-71d38d86481e', // Senha do certificado
    contratanteNumero: '00000000000000', // CNPJ da empresa que contratou o serviço na Loja Serpro
    autorPedidoDadosNumero: '00000000000000', // CPF/CNPJ do autor da requisição (pode ser procurador/contador)
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
    // 1. Consultar XML de uma declaração (Geral Mensal)
    print('\n--- Consultando XML da declaração ---');
    final xmlResponse = await dctfWebService.consultarXmlDeclaracao(
      contribuinteNumero: '00000000000',
      categoria: CategoriaDctf.pfMensal,
      anoPA: '2022',
      mesPA: '06',
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
      contribuinteNumero: '00000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2027',
      mesPA: '11',
    );

    print('Status: ${darfResponse.status}');
    print('DARF disponível: ${darfResponse.pdfBase64 != null}');

    if (darfResponse.pdfBase64 != null) {
      print('Tamanho do PDF: ${darfResponse.tamanhoPdfBytes} bytes');
    }

    // 3. Gerar documento de arrecadação para declaração EM ANDAMENTO
    print('\n--- Gerando DARF para declaração em andamento ---');
    final darfAndamentoResponse = await dctfWebService.gerarDocumentoArrecadacaoAndamento(
      contribuinteNumero: '00000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2025',
      mesPA: '01',
      idsSistemaOrigem: [SistemaOrigem.mit], // Apenas receitas do MIT
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
    );

    print('Status: ${declaracaoResponse.status}');
    print('Declaração completa disponível: ${declaracaoResponse.pdfBase64 != null}');

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
