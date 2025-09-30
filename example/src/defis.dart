import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

Future<void> Defis(ApiClient apiClient) async {
  print('=== Exemplos DEFIS ===');

  final defisService = DefisService(apiClient);

  try {
    /*
    try {
      
      print('\n--- 1. Transmitir Declaração Sócio Econômica ---');
      // Criar uma declaração de exemplo usando os enums
      final declaracao = defis.TransmitirDeclaracaoRequest(
        ano: 2021,
        situacaoEspecial: defis.SituacaoEspecial(tipoEvento: defis.TipoEventoSituacaoEspecial.cisaoParcial, dataEvento: 20230101),
        inatividade: defis.RegraInatividade.atividadesMaiorZero,
        empresa: defis.Empresa(
          ganhoCapital: 0,
          qtdEmpregadoInicial: 1,
          qtdEmpregadoFinal: 1,
          receitaExportacaoDireta: 0,
          socios: [
            defis.Socio(
              cpf: '00000000000',
              rendimentosIsentos: 10000,
              rendimentosTributaveis: 5000,
              participacaoCapitalSocial: 100,
              irRetidoFonte: 0,
            ),
          ],
          ganhoRendaVariavel: 0,
          doacoesCampanhaEleitoral: [
            defis.Doacao(
              cnpjBeneficiario: '00000000000000',
              tipoBeneficiario: defis.TipoBeneficiarioDoacao.candidatoCargoPolitico,
              formaDoacao: defis.FormaDoacao.dinheiro,
              valor: 1000.00,
            ),
          ],
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
              operacoesInterestaduais: [defis.OperacaoInterestadual(uf: 'SP', valor: 5000.00, tipoOperacao: defis.TipoOperacao.entrada)],
            ),
          ],
          naoOptante: defis.NaoOptante(
            administracaoTributaria: defis.AdministracaoTributaria.federal,
            uf: 'SP',
            codigoMunicipio: '3550308',
            numeroProcesso: '12345678901234567890',
          ),
        ),
      );

      final transmitirResponse = await defisService.transmitirDeclaracao(
        contratanteNumero: '00000000000000',
        contribuinteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
        declaracaoData: declaracao,
      );

      print('Status: ${transmitirResponse.status}');
      print('Mensagens: ${transmitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('ID DEFIS: ${transmitirResponse.dados.idDefis}');
      print('Declaração PDF: ${transmitirResponse.dados.declaracaoPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
      print('Recibo PDF: ${transmitirResponse.dados.reciboPdf.isNotEmpty ? 'Disponível' : 'Não disponível'}');
    } catch (e) {
      print('❌ Erro ao transmitir declaração: $e');
    }
    await Future.delayed(Duration(seconds: 10));
    */

    try {
      print('\n--- 2. Consultar Declarações Transmitidas ---');
      final consultarDeclaracoesResponse = await defisService.consultarDeclaracoesTransmitidas(
        contribuinteNumero: '00000000000000',
        contratanteNumero: '00000000000000',
        autorPedidoDadosNumero: '00000000000000',
      );

      print('Status: ${consultarDeclaracoesResponse.status}');
      print('Mensagens: ${consultarDeclaracoesResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('Quantidade de declarações: ${consultarDeclaracoesResponse.dados.length}');

      for (var declaracao in consultarDeclaracoesResponse.dados) {
        print('  - ID: ${declaracao.idDefis}, Ano: ${declaracao.ano}, Data: ${declaracao.dataTransmissao}, Situação: ${declaracao.situacao}');
      }
    } catch (e) {
      print('❌ Erro ao consultar declarações transmitidas: $e');
    }
    await Future.delayed(Duration(seconds: 10));
    /*
    try {
      print('\n--- 3. Consultar Última Declaração Transmitida ---');
      final consultarUltimaResponse = await defisService.consultarUltimaDeclaracao(contribuinteNumero: '00000000000000', ano: 2023);

      print('Status: ${consultarUltimaResponse.status}');
      print('Mensagens: ${consultarUltimaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('ID DEFIS: ${consultarUltimaResponse.dados.idDefis}');
      print('Ano: ${consultarUltimaResponse.dados.ano}');
      print('Data Transmissão: ${consultarUltimaResponse.dados.dataTransmissao}');
      print('Situação: ${consultarUltimaResponse.dados.situacao}');
      print('Declaração PDF: ${consultarUltimaResponse.dados.declaracaoPdf != null ? 'Disponível' : 'Não disponível'}');
      print('Recibo PDF: ${consultarUltimaResponse.dados.reciboPdf != null ? 'Disponível' : 'Não disponível'}');
    } catch (e) {
      print('❌ Erro ao consultar última declaração transmitida: $e');
    }
    await Future.delayed(Duration(seconds: 10));

    try {
      print('\n--- 4. Consultar Declaração Específica ---');
      final consultarEspecificaResponse = await defisService.consultarDeclaracaoEspecifica(
        contribuinteNumero: '00000000000000',
        idDefis: 12345, // Usar um ID real se disponível
      );

      print('Status: ${consultarEspecificaResponse.status}');
      print('Mensagens: ${consultarEspecificaResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('ID DEFIS: ${consultarEspecificaResponse.dados.idDefis}');
      print('Ano: ${consultarEspecificaResponse.dados.ano}');
      print('Data Transmissão: ${consultarEspecificaResponse.dados.dataTransmissao}');
      print('Situação: ${consultarEspecificaResponse.dados.situacao}');
    } catch (e) {
      print('❌ Erro ao consultar declaração específica: $e');
    }

    try {
      print('\n--- 5. Exemplo com Procurador ---');
      // Exemplo usando token de procurador (se disponível)
      if (apiClient.hasProcuradorToken) {
        final procuradorResponse = await defisService.consultarDeclaracoesTransmitidas(
          contribuinteNumero: '00000000000000',
          procuradorToken: apiClient.procuradorToken,
        );

        print('Status com procurador: ${procuradorResponse.status}');
        print('Quantidade de declarações: ${procuradorResponse.dados.length}');
      } else {
        print('Token de procurador não disponível');
      }
    } catch (e) {
      print('❌ Erro ao consultar declarações transmitidas com procurador: $e');
    }

    try {
      print('\n--- 6. Exemplo de Validação de Enums ---');
      print('Tipos de evento disponíveis:');
      for (var tipo in defis.TipoEventoSituacaoEspecial.values) {
        print('  ${tipo.codigo}: ${tipo.descricao}');
      }

      print('Regras de inatividade disponíveis:');
      for (var regra in defis.RegraInatividade.values) {
        print('  ${regra.codigo}: ${regra.descricao}');
      }

      print('Tipos de beneficiário de doação:');
      for (var tipo in defis.TipoBeneficiarioDoacao.values) {
        print('  ${tipo.codigo}: ${tipo.descricao}');
      }

      print('Formas de doação:');
      for (var forma in defis.FormaDoacao.values) {
        print('  ${forma.codigo}: ${forma.descricao}');
      }

      print('Administrações tributárias:');
      for (var admin in defis.AdministracaoTributaria.values) {
        print('  ${admin.codigo}: ${admin.descricao}');
      }
    } catch (e) {
      print('❌ Erro ao consultar validação de enums: $e');
    }*/
  } catch (e) {
    print('Erro no serviço DEFIS: $e');
  }
}
