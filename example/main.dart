import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplo básico de uso do package serpro_integra_contador_api
///
/// Este exemplo demonstra como:
/// 1. Inicializar o cliente da API
/// 2. Autenticar com certificados digitais
/// 3. Usar os serviços disponíveis
void main() async {
  // Inicializar cliente da API
  final apiClient = ApiClient();

  try {
    // Autenticar com certificados
    await apiClient.authenticate(
      consumerKey: 'seu_consumer_key',
      consumerSecret: 'seu_consumer_secret',
      certificadoDigitalPath: 'caminho/para/certificado.pfx',
      senhaCertificado: 'senha_do_certificado',
      contratanteNumero: '12345678000100', // CNPJ da empresa contratante
      autorPedidoDadosNumero: '12345678000100', // CPF/CNPJ do autor do pedido
    );

    // Exemplo: Usar serviço CCMEI
    final ccmeiService = CcmeiService(apiClient);
    final response = await ccmeiService.emitirCcmei('12345678000100');

    if (response.dados.pdf.isNotEmpty) {
      print('CCMEI emitido com sucesso!');
    }

    // Exemplo: Consultar situação cadastral por CPF
    final situacaoResponse = await ccmeiService.consultarSituacaoCadastral(
      '12345678900', // CPF do empresário MEI
    );
    print('CNPJs encontrados: ${situacaoResponse.dados.length}');
    for (var situacao in situacaoResponse.dados) {
      print('CNPJ: ${situacao.cnpj}, Situação: ${situacao.situacao}');
    }
  } catch (e) {
    print('Erro: $e');
  }
}
