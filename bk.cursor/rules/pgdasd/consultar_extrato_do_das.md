# Consultar Extrato do DAS

Essa funcionalidade consulta um extrato detalhado específico do DAS gerado.

## Identificação no Pedido de Dados

- **idSistema**: PGDASD
- **idServico**: CONSEXTRATO16
- **versaoSistema**: "1.0"

## Dados de Entrada

**Campo: dados**

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| numeroDas | Número do DAS que se deseja fazer a consulta do Extrato. | `String` (17) | SIM |

**Exemplo de entrada (JSON):**

```json
{
  "contratante": {
    "numero": "00000000000000",
    "tipo": 2
  },
  "autorPedidoDados": {
    "numero": "00000000000000",
    "tipo": 2
  },
  "contribuinte": {
    "numero": "00000000000000",
    "tipo": 2
  },
  "pedidoDados": {
    "idSistema": "PGDASD",
    "idServico": "CONSEXTRATO16",
    "versaoSistema": "1.0",
    "dados": "{ \"numeroDas\": \"07202136999997159\" }"
  }
}
```

## Dados de Saída

| Campo | Descrição | Tipo |
| --- | --- | --- |
| status | Status HTTP retornado no acionamento do serviço. | `Number` |
| mensagens | Mensagem explicativa retornada no acionamento do serviço. É um array composto de Código e texto da mensagem. O campo Código é um Texto de tamanho 5 que representa um código interno do negócio. | `Array` |
| dados | Estrutura de dados de retorno, contendo uma lista em SCAPED Texto JSON com o objeto ExtratoDas. | `String` |

### Objeto: ExtratoDas

| Campo | Descrição | Tipo |
| --- | --- | --- |
| numeroDas | Número do DAS (Documento de Arrecadação do Simples Nacional). | `String` (17) |
| extrato | Estrutura de dados do Extrato do DAS. A saída é um PDF. | `Object` |

### Objeto: ArquivoExtrato

| Campo | Descrição | Tipo |
| --- | --- | --- |
| nomeArquivo | Nome do arquivo do extrato para ser utilizado no processo de decodificação do base64. Ex. “extrato-pgdasd-{numeroDeclaracao}.pdf”. | `String` (50) |
| pdf | Obtém o arquivo em base 64 para conversão em PDF. | `String` |
