import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'src/import.dart';

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
  //await AutenticaProcurador(apiClient);
  //await CaixaPostal(apiClient);
  //await Ccmei(apiClient);
  //await DctfWeb(apiClient);
  //await Defis(apiClient);
  //await Dte(apiClient);
  //await EventosAtualizacao(apiClient);
  //await Mit(apiClient);
  await PagtoWeb(apiClient);

  // await ParcmeiEspecial(apiClient);
  // await Parcmei(apiClient);
  // await ParcsnEspecial(apiClient);
  // await Parcsn(apiClient);
  // await Pertmei(apiClient);
  // await Pertsn(apiClient);
  // await Pgdasd(apiClient);
  // await Pgmei(apiClient);
  // await Procuracoes(apiClient);
  // await Regime(apiClient);
  // await Relpmei(apiClient);
  // await Relpsn(apiClient);
  // await Sicalc(apiClient); (Refazer arquivo mdc e serviço completo)
  // await Sitfis(apiClient);
}
