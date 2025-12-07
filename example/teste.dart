import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  print('=== SERPRO Integra Contador API - Exemplo de Uso ===\n');

  try {
    final apiClient = ApiClient();

    await apiClient.authenticate(
      consumerKey: '',
      consumerSecret: '',
      contratanteNumero: '',
      autorPedidoDadosNumero: '',
      certificadoDigitalPath: 'certificado.pfx',
      senhaCertificado: '',
      ambiente: 'producao',
    );

    print('✅ Autenticado com sucesso!\n');

    // Exibir informações do token
    if (apiClient.authModel != null) {
      final procuracoesService = ProcuracoesService(apiClient);

      final responsePjPj = await procuracoesService.consultarProcuracao(outorgante: '');

      print('✅ Status HTTP: ${responsePjPj.status}');
      print('✅ Sucesso: ${responsePjPj.sucesso}');
      print('✅ Mensagem: ${responsePjPj.mensagemPrincipal}');
      print('✅ Código Mensagem: ${responsePjPj.codigoMensagem}');
      print('✅ Dados: ${responsePjPj.dados}');

      final indicadorResponse = await CaixaPostalService(apiClient).obterIndicadorNovasMensagens('');
      print('📤 RESPOSTA HTTP:');
      print('   Status: ${indicadorResponse.status}\n');

      if (indicadorResponse.dados != null) {
        print('📊 DADOS PARSEADOS:');
        print('   Código: ${indicadorResponse.dados!.codigo}');

        if (indicadorResponse.dados!.conteudo.isNotEmpty) {
          final conteudo = indicadorResponse.dados!.conteudo.first;

          print('\n📋 CONTEÚDO:');
          print('   ┌─────────────────────────────────────────────────────────┐');
          print('   │ Indicador Mensagens Novas:                               │');
          print('   │   ${conteudo.indicadorMensagensNovas}│');
          print('   │   (Valor descritivo retornado diretamente)              │');
          print('   ├─────────────────────────────────────────────────────────┤');
          print('   │ Status (Enum): ${conteudo.statusMensagensNovas}│');
          print('   │ Descrição: ${conteudo.descricaoStatus}│');
          print('   │ Tem Mensagens Novas: ${conteudo.temMensagensNovas}│');
          print('   └─────────────────────────────────────────────────────────┘');
        }

        print('\n✅ Serviço INNOVAMSG63 executado com sucesso!\n');
      } else {
        print('⚠️  Não foi possível parsear os dados da resposta\n');
      }
    }
  } catch (e) {
    print('❌ Erro: ${e}\n');
  }
}
