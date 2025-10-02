import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_request.dart' as defis show NaoOptante;

Future<void> Defis(ApiClient apiClient) async {
  print('=== Exemplos DEFIS ===');

  final defisService = DefisService(apiClient);
  bool servicoOk = true;

  // 1. Transmitir Declaração Sócio Econômica
  try {
    print('\n--- 1. Transmitir Declaração Sócio Econômica ---');
    // Criar uma declaração de exemplo usando os enums
    final declaracao = TransmitirDeclaracaoRequest(
      ano: 2021,
      situacaoEspecial: SituacaoEspecial(tipoEvento: TipoEventoSituacaoEspecial.cisaoParcial, dataEvento: 20230101),
      inatividade: RegraInatividade.atividadesMaiorZero,
      empresa: Empresa(
        ganhoCapital: 10.0,
        qtdEmpregadoInicial: 20,
        qtdEmpregadoFinal: 0,
        lucroContabil: 20.0,
        receitaExportacaoDireta: 10.0,
        comerciaisExportadoras: [ComercialExportadora(cnpjCompleto: '00000000000000', valor: 123.0)],
        socios: [
          Socio(cpf: '00000000000', rendimentosIsentos: 50.0, rendimentosTributaveis: 20.0, participacaoCapitalSocial: 90.0, irRetidoFonte: 10.0),
        ],
        participacaoCotasTesouraria: 10.0,
        ganhoRendaVariavel: 10.0,
        doacoesCampanhaEleitoral: [
          Doacao(
            cnpjBeneficiario: '00000000000000',
            tipoBeneficiario: TipoBeneficiarioDoacao.candidatoCargoPolitico,
            formaDoacao: FormaDoacao.dinheiro,
            valor: 10.0,
          ),
        ],
        estabelecimentos: [
          Estabelecimento(
            cnpjCompleto: '00000000000000',
            totalDevolucoesCompras: 200.0,
            operacoesInterestaduais: [OperacaoInterestadual(uf: 'SP', valor: 15.0, tipoOperacao: TipoOperacao.entrada)],
            issRetidosFonte: [IssRetidoFonte(uf: 'SP', codMunicipio: '7107', valor: 20.0)],
            prestacoesServicoComunicacao: [PrestacaoServicoComunicacao(uf: 'SP', codMunicipio: '7107', valor: 20.0)],
            mudancaOutroMunicipio: [],
            prestacoesServicoTransporte: [PrestacaoServicoTransporte(uf: 'SP', codMunicipio: '7107', valor: 20.0)],
            informacaoOpcional: InformacaoOpcional(
              vendasRevendedorAmbulante: [VendaRevendedorAmbulante(uf: 'SP', codigoMunicipio: '7107', valor: 20.0)],
              preparosComercializacaoRefeicoes: [PreparoComercializacaoRefeicoes(uf: 'SP', codigoMunicipio: '7107', valor: 20.0)],
              producoesRurais: [ProducaoRural(uf: 'SP', codigoMunicipio: '7107', valor: 20.0)],
              aquisicoesProdutoresRurais: [AquisicaoProdutoresRurais(uf: 'SP', codigoMunicipio: '7107', valor: 20.0)],
              aquisicoesDispensadosInscricao: [AquisicaoDispensadosInscricao(uf: 'SP', codigoMunicipio: '7107', valor: 20.0)],
              rateiosReceitaRegimeEspecial: [RateioReceitaRegimeEspecial(uf: 'SP', codigoMunicipio: '7107', valor: 20.0, numeroRegime: '999999')],
              rateiosDecisaoJudicial: [RateioDecisaoJudicial(uf: 'SP', codigoMunicipio: '7107', valor: 20.0, identificacaoDecisao: 'teste')],
              rateiosReceitaOutrosRateios: [RateioReceitaOutrosRateios(uf: 'SP', codigoMunicipio: '7107', valor: 20.0, origemExigencia: 'teste')],
              saidaTransferenciaMercadoria: 20.0,
              autoInfracaoPago: 20.0,
            ),
            estoqueInicial: 10.0,
            estoqueFinal: 20.0,
            saldoCaixaInicial: -100.0,
            saldoCaixaFinal: -50.0,
            aquisicoesMercadoInterno: 20.0,
            importacoes: 50.0,
            totalEntradasPorTransferencia: 200.0,
            totalSaidasPorTransferencia: 200.0,
            totalDevolucoesVendas: 300.0,
            totalEntradas: 5000.0,
            totalDespesas: 10000.0,
          ),
        ],
        naoOptante: defis.NaoOptante(
          administracaoTributaria: AdministracaoTributaria.federal,
          uf: 'SP',
          codigoMunicipio: '3550308',
          numeroProcesso: '12345678901234567890',
        ),
      ),
    );

    final transmitirResponse = await defisService.transmitirDeclaracao(
      contribuinteNumero: '00000000000000',
      declaracaoData: declaracao,
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${transmitirResponse.status}');
    print('Mensagens: ${transmitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('ID DEFIS: ${transmitirResponse.dados.idDefis}');
    print('Declaração PDF: ${transmitirResponse.dados.declaracaoPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
    print('Recibo PDF: ${transmitirResponse.dados.reciboPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
  } catch (e) {
    print('❌ Erro ao transmitir declaração: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 2. Consultar Declarações Transmitidas
  try {
    print('\n--- 2. Consultar Declarações Transmitidas ---');
    final consultarDeclaracoesResponse = await defisService.consultarDeclaracoesTransmitidas(
      contribuinteNumero: '00000000000000',
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarDeclaracoesResponse.status}');
    print('Mensagens: ${consultarDeclaracoesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Quantidade de declarações: ${consultarDeclaracoesResponse.dados.length}');

    for (var declaracao in consultarDeclaracoesResponse.dados) {
      print('  - ID: ${declaracao.idDefis}, Ano: ${declaracao.anoCalendario}, Tipo: ${declaracao.tipo}, Data: ${declaracao.dataHora}');
    }
  } catch (e) {
    print('❌ Erro ao consultar declarações transmitidas: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 3. Consultar Última Declaração Transmitida
  try {
    print('\n--- 3. Consultar Última Declaração Transmitida ---');
    final consultarUltimaResponse = await defisService.consultarUltimaDeclaracao(
      contribuinteNumero: '00000000000000',
      ano: 2021,
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarUltimaResponse.status}');
    print('Mensagens: ${consultarUltimaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('ID DEFIS: ${consultarUltimaResponse.dados.idDefis}');
    print('Declaração PDF: ${consultarUltimaResponse.dados.declaracaoPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
    print('Recibo PDF: ${consultarUltimaResponse.dados.reciboPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
  } catch (e) {
    print('❌ Erro ao consultar última declaração transmitida: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 4. Consultar Declaração Específica
  try {
    print('\n--- 4. Consultar Declaração Específica ---');
    final consultarEspecificaResponse = await defisService.consultarDeclaracaoEspecifica(
      contribuinteNumero: '00000000000000',
      idDefis: '000000002021002', // Usar um ID real se disponível
      contratanteNumero: '00000000000000',
      autorPedidoDadosNumero: '00000000000000',
    );

    print('✅ Status: ${consultarEspecificaResponse.status}');
    print('Mensagens: ${consultarEspecificaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
    print('Declaração PDF: ${consultarEspecificaResponse.dados.declaracaoPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
    print('Recibo PDF: ${consultarEspecificaResponse.dados.reciboPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
  } catch (e) {
    print('❌ Erro ao consultar declaração específica: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 5. Exemplo com Procurador
  try {
    print('\n--- 5. Exemplo com Procurador ---');
    // Exemplo usando token de procurador (se disponível)
    if (apiClient.hasProcuradorToken) {
      final procuradorResponse = await defisService.consultarDeclaracoesTransmitidas(
        contribuinteNumero: '00000000000000',
        procuradorToken: apiClient.procuradorToken,
      );

      print('✅ Status com procurador: ${procuradorResponse.status}');
      print('Quantidade de declarações: ${procuradorResponse.dados.length}');
    } else {
      print('⚠️ Token de procurador não disponível');
    }
  } catch (e) {
    print('❌ Erro ao consultar declarações transmitidas com procurador: $e');
    servicoOk = false;
  }
  await Future.delayed(Duration(seconds: 2));

  // 6. Exemplo de Validação de Enums
  try {
    print('\n--- 6. Exemplo de Validação de Enums ---');
    print('Tipos de evento disponíveis:');
    for (var tipo in TipoEventoSituacaoEspecial.values) {
      print('  ${tipo.codigo}: ${tipo.descricao}');
    }

    print('\nRegras de inatividade disponíveis:');
    for (var regra in RegraInatividade.values) {
      print('  ${regra.codigo}: ${regra.descricao}');
    }

    print('\nTipos de beneficiário de doação:');
    for (var tipo in TipoBeneficiarioDoacao.values) {
      print('  ${tipo.codigo}: ${tipo.descricao}');
    }

    print('\nFormas de doação:');
    for (var forma in FormaDoacao.values) {
      print('  ${forma.codigo}: ${forma.descricao}');
    }

    print('\nTipos de operação:');
    for (var tipo in TipoOperacao.values) {
      print('  ${tipo.codigo}: ${tipo.descricao}');
    }

    print('\nAdministrações tributárias:');
    for (var admin in AdministracaoTributaria.values) {
      print('  ${admin.codigo}: ${admin.descricao}');
    }
    print('✅ Validação de enums concluída');
  } catch (e) {
    print('❌ Erro ao consultar validação de enums: $e');
    servicoOk = false;
  }

  // 7. Exemplo de Criação de Informação Opcional
  try {
    print('\n--- 7. Exemplo de Criação de Informação Opcional ---');
    final informacaoOpcional = InformacaoOpcional(
      vendasRevendedorAmbulante: [VendaRevendedorAmbulante(uf: 'SP', codigoMunicipio: '3550308', valor: 1000.0)],
      preparosComercializacaoRefeicoes: [PreparoComercializacaoRefeicoes(uf: 'RJ', codigoMunicipio: '3304557', valor: 500.0)],
      producoesRurais: [ProducaoRural(uf: 'MG', codigoMunicipio: '3106200', valor: 2000.0)],
      aquisicoesProdutoresRurais: [AquisicaoProdutoresRurais(uf: 'RS', codigoMunicipio: '4314902', valor: 1500.0)],
      aquisicoesDispensadosInscricao: [AquisicaoDispensadosInscricao(uf: 'PR', codigoMunicipio: '4106902', valor: 800.0)],
      rateiosReceitaRegimeEspecial: [RateioReceitaRegimeEspecial(uf: 'SC', codigoMunicipio: '4205407', valor: 3000.0, numeroRegime: '123456')],
      rateiosDecisaoJudicial: [
        RateioDecisaoJudicial(uf: 'BA', codigoMunicipio: '2927408', valor: 1200.0, identificacaoDecisao: 'Processo 123456789'),
      ],
      rateiosReceitaOutrosRateios: [
        RateioReceitaOutrosRateios(uf: 'CE', codigoMunicipio: '2304400', valor: 900.0, origemExigencia: 'Exigência especial'),
      ],
      saidaTransferenciaMercadoria: 5000.0,
      autoInfracaoPago: 2000.0,
    );

    print('✅ Informação opcional criada com sucesso!');
    print('Total de vendas revendedor ambulante: ${informacaoOpcional.vendasRevendedorAmbulante?.length ?? 0}');
    print('Total de preparos comercialização refeições: ${informacaoOpcional.preparosComercializacaoRefeicoes?.length ?? 0}');
    print('Saída transferência mercadoria: ${informacaoOpcional.saidaTransferenciaMercadoria}');
    print('Auto infração pago: ${informacaoOpcional.autoInfracaoPago}');
  } catch (e) {
    print('❌ Erro ao criar informação opcional: $e');
    servicoOk = false;
  }

  // Resumo final
  print('\n=== RESUMO DO SERVIÇO DEFIS ===');
  if (servicoOk) {
    print('✅ Serviço DEFIS: OK');
  } else {
    print('❌ Serviço DEFIS: ERRO');
  }

  print('\n=== Exemplos DEFIS Concluídos ===');
}
