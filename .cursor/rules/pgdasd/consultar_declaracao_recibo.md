# Consultar Declaração/Recibo

Consulta uma declaração/recibo específica com o número identificador da declaração. Nos casos de Multa de Atraso na Entrega da Declaração (MAED) a Notificação e o DARF da MAED serão apresentados nos dados de saída.

## Identificação no Pedido de Dados

- **idSistema**: PGDASD
- **idServico**: CONSDECREC15
- **versaoSistema**: "1.0"

## Dados de Entrada

**Campo: dados**

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| numeroDeclaracao | Número identificador único da declaração. | `String` (17) | SIM |

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
    "idServico": "CONSDECREC15",
    "versaoSistema": "1.0",
    "dados": "{ \"numeroDeclaracao\": \"00000000201801001\" }"
  }
}
```

## Dados de Saída (retorno)

| Campo | Descrição | Tipo |
| --- | --- | --- |
| status | Status HTTP retornado no acionamento do serviço. | `Number` |
| mensagens | Mensagem explicativa retornada no acionamento do serviço. É um array composto de Código e texto da mensagem. O campo Código é um Texto de tamanho 5 que representa um código interno do negócio. | `Array` |
| dados | Estrutura de dados de retorno, contendo uma lista em SCAPED Texto JSON com o objeto Declaracao. | `String` |

### Objeto: Declaracao

| Campo | Descrição | Tipo |
| --- | --- | --- |
| numeroDeclaracao | Identificador único da declaração transmitida. | `String` (17) |
| recibo | Estrutura de dados do Recibo de entrega da declaração. A saída é um PDF. | `Object` |
| declaracao | Estrutura de dados completa da declaração entregue. A saída é um PDF | `Object` |
| maed | Nos casos de declaração original entregue fora do prazo, o PGDAS-D gera uma MAED. Essa estrutura representa os documentos de Notificação e DARF da MAED. | `Object` |

### Objeto: ArquivoRecibo

| Campo | Descrição | Tipo |
| --- | --- | --- |
| nomeArquivo | Nome do arquivo do recibo para ser utilizado no processo de decodificação do base64. Ex. “recibo-pgdasd-{numeroDeclaracao}.pdf” | `String` (28) |
| pdf | Obtém o arquivo em base 64 para conversão em PDF. | `String` |

### Objeto: ArquivoDeclaracao

| Campo | Descrição | Tipo |
| --- | --- | --- |
| nomeArquivo | Nome do arquivo da declaracao para ser utilizado no processo de decodificação do base64. Ex. “dec-pgdasd-{numeroDeclaracao}.pdf” | `String` (25) |
| pdf | Obtém o arquivo em base 64 para conversão em PDF. | `String` |

### Objeto: ArquivoMaed

| Campo | Descrição | Tipo |
| --- | --- | --- |
| nomeArquivoNotificacao | Nome do arquivo da notificação da multa da declaracao entregue em atraso. para ser utilizado no processo de decodificação do base64. Ex. “notificacao-maed-pgdasd-{numeroDeclaracao}.pdf” | `String` (50) |
| pdfNotificacao | Obtém o arquivo em base 64 para conversão em PDF da notificação da MAED. | `String` |
| nomeArquivoDarf | Nome do arquivo do DARF da multa da declaracao entregue em atraso. para ser utilizado no processo de decodificação do base64. Ex. “darf-maed-pgdasd-{numeroDeclaracao}.pdf” | `String` (50) |
| pdfDarf | Obtém o arquivo em base 64 para conversão em PDF da DARF da MAED. | `String` |
