# DEFIS - Declaração de Informações Socioeconômicas e Fiscais

O serviço DEFIS permite efetuar a Declaração de Informações Socioeconômicas e Fiscais conforme determina a Lei Complementar nº 123, de 2006, art. 25, caput e a Resolução CGSN nº 140/2018.

## Características

- ✅ **Apenas Pessoa Jurídica**: O sistema aceita apenas contribuintes do tipo 2 (Pessoa Jurídica)
- ✅ **Enums Tipados**: Todos os dados de domínio são representados por enums com validação
- ✅ **4 Serviços Completos**: Transmissão e consultas de declarações
- ✅ **Suporte a Procurador**: Todos os métodos suportam token de procurador opcional

## Serviços Disponíveis

### 1. Transmitir Declaração Sócio Econômica (TRANSDECLARACAO141)

Transmite uma nova declaração DEFIS para o ano especificado.

```dart
final response = await defisService.transmitirDeclaracao(
  contribuinteNumero: '00000000000000',
  declaracaoData: declaracao,
  contratanteNumero: '00000000000100', // Opcional
  autorPedidoDadosNumero: '00000000000100', // Opcional
  procuradorToken: 'token_procurador', // Opcional
);
```

**Parâmetros:**
- `contribuinteNumero` (obrigatório): CNPJ do contribuinte
- `declaracaoData` (obrigatório): Dados da declaração
- `contratanteNumero` (opcional): Usa dados da autenticação se não informado
- `autorPedidoDadosNumero` (opcional): Usa dados da autenticação se não informado
- `procuradorToken` (opcional): Token de procurador

**Retorno:**
- `status`: Status HTTP da operação
- `mensagens`: Lista de mensagens de retorno
- `dados`: Objeto com `idDefis`, `declaracaoPdf` e `reciboPdf`

### 2. Consultar Declarações Transmitidas (CONSDECLARACAO142)

Consulta todas as declarações transmitidas pelo contribuinte.

```dart
final response = await defisService.consultarDeclaracoesTransmitidas(
  contribuinteNumero: '00000000000000',
);
```

**Retorno:**
- `status`: Status HTTP da operação
- `mensagens`: Lista de mensagens de retorno
- `dados`: Lista de declarações com `idDefis`, `ano`, `dataTransmissao`, `situacao`, etc.

### 3. Consultar Última Declaração Transmitida (CONSULTIMADECREC143)

Consulta a última declaração transmitida para um ano específico.

```dart
final response = await defisService.consultarUltimaDeclaracao(
  contribuinteNumero: '00000000000000',
  ano: 2023,
);
```

**Parâmetros:**
- `contribuinteNumero` (obrigatório): CNPJ do contribuinte
- `ano` (obrigatório): Ano calendário para consulta

**Retorno:**
- `status`: Status HTTP da operação
- `mensagens`: Lista de mensagens de retorno
- `dados`: Objeto com dados da última declaração

### 4. Consultar Declaração Específica (CONSDECREC144)

Consulta uma declaração específica pelo seu ID DEFIS.

```dart
final response = await defisService.consultarDeclaracaoEspecifica(
  contribuinteNumero: '00000000000000',
  idDefis: 12345,
);
```

**Parâmetros:**
- `contribuinteNumero` (obrigatório): CNPJ do contribuinte
- `idDefis` (obrigatório): ID da declaração específica

**Retorno:**
- `status`: Status HTTP da operação
- `mensagens`: Lista de mensagens de retorno
- `dados`: Objeto com dados da declaração específica

## Dados de Domínio (Enums)

### Tipos de Evento para Situação Especial

```dart
enum TipoEventoSituacaoEspecial {
  cisaoParcial(1, 'Cisão parcial'),
  cisaoTotal(2, 'Cisão total'),
  extincao(3, 'Extinção'),
  fusao(4, 'Fusão'),
  incorporacaoIncorporada(5, 'Incorporação/Incorporada');
}
```

### Regras de Inatividade

```dart
enum RegraInatividade {
  atividadesZeroNao(0, 'Atividades zero - Responde NÃO à pergunta sobre inatividade'),
  atividadesZeroSim(1, 'Atividades zero - Responde SIM à pergunta sobre inatividade'),
  atividadesMaiorZero(2, 'Total das atividades maior que zero');
}
```

### Tipos de Beneficiário de Doação

```dart
enum TipoBeneficiarioDoacao {
  candidatoCargoPolitico(1, 'Candidato a cargo político eletivo'),
  comiteFinanceiro(2, 'Comitê financeiro'),
  partidoPolitico(3, 'Partido político');
}
```

### Formas de Doação

```dart
enum FormaDoacao {
  cheque(1, 'Cheque'),
  outrosTitulosCredito(2, 'Outro títulos de crédito'),
  transferenciaEletronica(3, 'Transferência eletrônica'),
  depositoEspecie(4, 'Depósito em espécie'),
  dinheiro(5, 'Dinheiro'),
  bens(6, 'Bens'),
  servicos(7, 'Serviços');
}
```

### Tipos de Operação

```dart
enum TipoOperacao {
  entrada(1, 'Entrada'),
  saida(2, 'Saída');
}
```

### Administrações Tributárias

```dart
enum AdministracaoTributaria {
  distrital(1, 'Distrital'),
  estadual(2, 'Estadual'),
  federal(3, 'Federal'),
  municipal(4, 'Municipal');
}
```

## Exemplo Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Inicializar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho_certificado',
    certPassword: 'senha_certificado',
    contratanteNumero: '00000000000100',
    autorPedidoDadosNumero: '00000000000100',
  );

  final defisService = DefisService(apiClient);

  // Criar declaração com enums tipados
  final declaracao = TransmitirDeclaracaoRequest(
    ano: 2021,
    situacaoEspecial: SituacaoEspecial(
      tipoEvento: TipoEventoSituacaoEspecial.cisaoParcial,
      dataEvento: 20230101,
    ),
    inatividade: RegraInatividade.atividadesMaiorZero,
    empresa: Empresa(
      ganhoCapital: 10.0,
      qtdEmpregadoInicial: 20,
      qtdEmpregadoFinal: 0,
      lucroContabil: 20.0,
      receitaExportacaoDireta: 10.0,
      comerciaisExportadoras: [
        ComercialExportadora(
          cnpjCompleto: '00000000000000',
          valor: 123.0,
        ),
      ],
      socios: [
        Socio(
          cpf: '00000000000',
          rendimentosIsentos: 50.0,
          rendimentosTributaveis: 20.0,
          participacaoCapitalSocial: 90.0,
          irRetidoFonte: 10.0,
        ),
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
          operacoesInterestaduais: [
            OperacaoInterestadual(
              uf: 'SP',
              valor: 15.0,
              tipoOperacao: TipoOperacao.entrada,
            ),
          ],
          issRetidosFonte: [
            IssRetidoFonte(
              uf: 'SP',
              codMunicipio: '7107',
              valor: 20.0,
            ),
          ],
          prestacoesServicoComunicacao: [
            PrestacaoServicoComunicacao(
              uf: 'SP',
              codMunicipio: '7107',
              valor: 20.0,
            ),
          ],
          mudancaOutroMunicipio: [],
          prestacoesServicoTransporte: [
            PrestacaoServicoTransporte(
              uf: 'SP',
              codMunicipio: '7107',
              valor: 20.0,
            ),
          ],
          informacaoOpcional: InformacaoOpcional(
            vendasRevendedorAmbulante: [
              VendaRevendedorAmbulante(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
              ),
            ],
            preparosComercializacaoRefeicoes: [
              PreparoComercializacaoRefeicoes(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
              ),
            ],
            producoesRurais: [
              ProducaoRural(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
              ),
            ],
            aquisicoesProdutoresRurais: [
              AquisicaoProdutoresRurais(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
              ),
            ],
            aquisicoesDispensadosInscricao: [
              AquisicaoDispensadosInscricao(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
              ),
            ],
            rateiosReceitaRegimeEspecial: [
              RateioReceitaRegimeEspecial(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
                numeroRegime: '999999',
              ),
            ],
            rateiosDecisaoJudicial: [
              RateioDecisaoJudicial(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
                identificacaoDecisao: 'teste',
              ),
            ],
            rateiosReceitaOutrosRateios: [
              RateioReceitaOutrosRateios(
                uf: 'SP',
                codigoMunicipio: '7107',
                valor: 20.0,
                origemExigencia: 'teste',
              ),
            ],
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
      naoOptante: NaoOptante(
        administracaoTributaria: AdministracaoTributaria.federal,
        uf: 'SP',
        codigoMunicipio: '3550308',
        numeroProcesso: '12345678901234567890',
      ),
    ),
  );

  try {
    // Transmitir declaração
    final transmitirResponse = await defisService.transmitirDeclaracao(
      contribuinteNumero: '00000000000000',
      declaracaoData: declaracao,
    );
    
    print('Declaração transmitida: ${transmitirResponse.dados.idDefis}');
    print('PDF disponível: ${transmitirResponse.dados.declaracaoPdf.isNotEmpty}');

    // Consultar declarações
    final consultarResponse = await defisService.consultarDeclaracoesTransmitidas(
      contribuinteNumero: '00000000000000',
    );
    
    print('Total de declarações: ${consultarResponse.dados.length}');

    // Consultar última declaração
    final ultimaResponse = await defisService.consultarUltimaDeclaracao(
      contribuinteNumero: '00000000000000',
      ano: 2021,
    );
    
    print('Última declaração: ${ultimaResponse.dados.idDefis}');

    // Consultar declaração específica
    final especificaResponse = await defisService.consultarDeclaracaoEspecifica(
      contribuinteNumero: '00000000000000',
      idDefis: '000000002021002',
    );
    
    print('Declaração específica PDF: ${especificaResponse.dados.declaracaoPdf.isNotEmpty}');

  } catch (e) {
    print('Erro: $e');
  }
}
```

## Mensagens de Erro Comuns

| Código | Mensagem | Ação |
|--------|----------|------|
| [EntradaIncorreta-DEFIS-MSG_0001] | O campo _campo_ possui valor inválido. Dever ser numérico com o valor mínimo de _valormínimo_ e o máximo _valormaximo_. | Corrigir o campo e reenviar |
| [Erro-DEFIS-MSG_0002] | Houve um erro ao utilizar o sistema. Tente novamente mais tarde. | Erro interno. Reenviar a requisição |
| [EntradaIncorreta-DEFIS-MSG_0006] | O ano deve estar entre _inicio_ e _fim_. | Corrigir o valor e reenviar |
| [EntradaIncorreta-DEFIS-MSG_0008] | Contribuinte não optante e bloco NaoOptante não preenchido. | Corrigir e reenviar |
| [EntradaIncorreta-DEFIS-MSG_0010] | Para administração tributária distrital deve ser passado DF no campo UF. | Corrigir e reenviar |

## Regras de Negócio

### Regra da Informação Opcional

O Estabelecimento incorreu em pelo menos uma das hipóteses a seguir?

- Saídas por transferência de mercadorias entre estabelecimentos do mesmo proprietário
- Vendas por meio de revendedores ambulantes autônomos em outros municípios dentro do estado
- Preparo e comercialização de refeições em municípios diferentes do município de localização
- Produção rural ocorrida no território de mais de um município do estado
- Aquisição de mercadorias de produtores rurais não equiparados a comerciantes ou industriais
- Aquisição de mercadorias de contribuintes dispensados de inscrição, exceto produtor rural
- Autos de infração pagos ou com decisão administrativa irrecorrível decorrentes de saídas de mercadorias ou prestações de serviço não oferecidas à tributação
- Rateio de receita oriundo de regime especial concedido pela secretaria estadual de fazenda e de decisão judicial ou de situações similares

## Links Úteis

- [Documentação Oficial DEFIS](https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1)
- [Lei Complementar nº 123/2006](https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp123.htm)
- [Resolução CGSN nº 140/2018](https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/legislacao/resolucoes-da-cgsn/resolucao-cgsn-n-140-de-2018)