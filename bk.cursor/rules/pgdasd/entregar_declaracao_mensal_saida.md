# Entregar Declaração Mensal - Saída

## **Dados de Saída**

| Campo | Descrição | Tipo |
| --- | --- | --- |
| status | Status HTTP retornado no acionamento do serviço. | `Number` |
| mensagens | Mensagem explicativa retornada no acionamento do serviço. | `Array` |
| dados | Estrutura de dados de retorno, contendo uma lista com o objeto [DeclaracaoTransmitida](). | `String` |

### Objeto [DeclaracaoTransmitida:]()

| Campo | Descrição | Tipo |
| --- | --- | --- |
| idDeclaracao | Id da Declaração que foi transmitida | `String` |
| dataHoraTransmissao | Data e hora da transmissão no formato AAAAMMDDHHmmSS | `String` |
| valoresDevidos | Valor devidos calculados pelo sistema. | `Array` de object [ValorDevido]() |
| declaracao | PDF da declaração no formato Base64 | `String` |
| recibo | PDF do recibo no formato Base64 | `String` |
| notificacaoMaed | PDF da notificação MAED. No caso de não ter MAED este campo é nulo | `String` |
| darf | PDF do DARF. No caso de não ter MAED este campo é nulo | `String` |
| detalhamentoDarfMaed | Detalhamento dos valores do Darf. Ver [Detalhamento](). | `Object` |

### Objeto [ValorDevido:]()

| Campo | Descrição | Tipo |
| --- | --- | --- |
| codigoTributo | [Código do tributo]() | `Number` |
| valor | Valor devido do tributo | `Number` |

### Objeto [Detalhamento:]()

| Campo | Descrição | Tipo |
| --- | --- | --- |
| periodoApuracao | Período de Apuração no formato AAAAMM | `String` (6) |
| numeroDocumento | Número do documento gerado | `String` (17) |
| dataVencimento | Data de vencimento no formato AAAAMMDD | `String` (8) |
| dataLimiteAcolhimento | Data limite para acolhimento no formato AAAAMMDD | `String` (8) |
| valores | Discriminação dos valores contidos no DARF. Ver [Valores](). | `Object` |
| observacao1 | Observação 1 | `String` |
| observacao2 | Observação 2 | `String` |
| observacao3 | Observação 3 | `String` |
| composicao | Por se tratar de DARF, este campo não possui informação | `Null` |

### Objeto [Valores:]()

| Campo | Descrição | Tipo |
| --- | --- | --- |
| principal | Valor do principal | `Number` |
| multa | Valor da multa | `Number` |
| juros | Valor dos juros | `Number` |
| total | Valor total | `Number` |

