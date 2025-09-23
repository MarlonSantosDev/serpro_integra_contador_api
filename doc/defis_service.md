# Documentação do Serviço DEFIS

Este documento detalha como utilizar o serviço DEFIS através do package `serpro_integra_contador_api`.

## Visão Geral

O serviço DEFIS permite a transmissão e consulta da Declaração de Informações Socioeconômicas e Fiscais para empresas do Simples Nacional.

## Serviços Disponíveis

- **Transmitir Declaração**: Envia uma nova declaração DEFIS.
- **Consultar Declarações**: Lista as declarações já transmitidas.
- **Consultar Última Declaração e Recibo**: Obtém a última declaração e seu recibo.
- **Consultar Declaração e Recibo**: Obtém uma declaração específica e seu recibo.

---

## 1. Transmitir Declaração (`transmitirDeclaracao`)

Este método permite enviar uma declaração DEFIS completa para a Receita Federal.

### Parâmetros

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| `contratanteNumero` | `String` | CNPJ da empresa contratante do serviço. | Sim |
| `contratanteTipo` | `int` | Tipo de pessoa do contratante (2 para CNPJ). | Sim |
| `autorPedidoDadosNumero` | `String` | CNPJ/CPF de quem está fazendo o pedido. | Sim |
| `autorPedidoDadosTipo` | `int` | Tipo de pessoa do autor do pedido (1 para CPF, 2 para CNPJ). | Sim |
| `contribuinteNumero` | `String` | CNPJ da empresa para a qual a declaração está sendo enviada. | Sim |
| `contribuinteTipo` | `int` | Tipo de pessoa do contribuinte (2 para CNPJ). | Sim |
| `declaracaoData` | `TransmitirDeclaracaoRequest` | Objeto contendo todos os dados da declaração. | Sim |

### Estrutura de `TransmitirDeclaracaoRequest`

O objeto `declaracaoData` é complexo e reflete a estrutura da DEFIS. Consulte a documentação oficial da API ou o código-fonte do modelo `transmitir_declaracao_request.dart` para ver todos os campos disponíveis.

**Principais campos:**

- `ano`: O ano-calendário da declaração.
- `situacaoEspecial`: Dados sobre eventos especiais (cisão, fusão, etc.), se aplicável.
- `inatividade`: Indicador se a empresa esteve inativa no período.
- `empresa`: Objeto principal que contém os dados da matriz e filiais.

### Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Inicialize o cliente da API
  final apiClient = ApiClient();

  // 2. Autentique-se (a implementação real requer certificado digital)
  // Em um ambiente de produção, forneça os dados reais do seu certificado.
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret',
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );

  // 3. Crie o serviço DEFIS
  final defisService = DefisService(apiClient);

  // 4. Monte o objeto da declaração
  // Este é um exemplo simplificado. Preencha todos os campos obrigatórios.
  final declaracao = TransmitirDeclaracaoRequest(
    ano: 2024,
    inatividade: 2, // 1 = Sim, 2 = Não
    empresa: Empresa(
      ganhoCapital: 0.0,
      qtdEmpregadoInicial: 1,
      qtdEmpregadoFinal: 1,
      receitaExportacaoDireta: 0.0,
      socios: [
        Socio(
          cpf: '12345678900',
          rendimentosIsentos: 10000.0,
          rendimentosTributaveis: 5000.0,
          participacaoCapitalSocial: 100.0,
          irRetidoFonte: 0.0,
        ),
      ],
      ganhoRendaVariavel: 0.0,
      estabelecimentos: [
        Estabelecimento(
          cnpjCompleto: '00123456000100',
          estoqueInicial: 1000.0,
          estoqueFinal: 2000.0,
          saldoCaixaInicial: 5000.0,
          saldoCaixaFinal: 15000.0,
          aquisicoesMercadoInterno: 10000.0,
          importacoes: 0.0,
          totalEntradasPorTransferencia: 0.0,
          totalSaidasPorTransferencia: 0.0,
          totalDevolucoesVendas: 100.0,
          totalEntradas: 10100.0,
          totalDevolucoesCompras: 50.0,
          totalDespesas: 8000.0,
        ),
      ],
    ),
  );

  // 5. Chame o método para transmitir a declaração
  try {
    final response = await defisService.transmitirDeclaracao(
      '00000000000000', // CNPJ Contratante
      2,
      '11111111111111', // CNPJ/CPF Autor do Pedido
      2,
      '00123456000100', // CNPJ Contribuinte
      2,
      declaracao,
    );

    print('Declaração transmitida com sucesso!');
    print('ID da DEFIS: ${response.dados.idDefis}');
    // Você pode salvar os PDFs decodificando as strings base64
    // final reciboBytes = base64Decode(response.dados.reciboPdf);
    // File('recibo.pdf').writeAsBytesSync(reciboBytes);

  } catch (e) {
    print('Erro ao transmitir a declaração: $e');
  }
}
```

### Retorno

O método retorna um objeto `TransmitirDeclaracaoResponse` que contém:

- `status`: O código de status HTTP da resposta.
- `mensagens`: Uma lista de mensagens informativas ou de erro.
- `dados`: Um objeto `SaidaEntregar` com os seguintes campos:
  - `declaracaoPdf`: A declaração em formato PDF, codificada em base64.
  - `reciboPdf`: O recibo de entrega em PDF, codificado em base64.
  - `idDefis`: O identificador único da declaração transmitida.

---

*A documentação para os outros serviços (consultas) será adicionada em breve.*
