# Consultar Declarações Transmitidas por Ano-Calendário ou Período de Apuração

Essa consulta lista um índice com todas as declarações transmitidas na base de dados da RFB de um contribuinte para um determinado ano-calendário ou período de apuração mensal do PGDAS-D por tipo de operação (Declaração Original, Declaração Retificadora, Geração de DAS, DAS Avulso, DAS Medida Judicial).

## PedidoDados

- **idSistema**: PGDASD
- **idServico**: CONSDECLARACAO13
- **versaoSistema**: "1.0"

## Dados de Entrada

### Pesquisa por ano-calendário

**Objeto Dados:**

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| anoCalendario | Ano-calendário da declaração. Quando for utilizado o ano-calendário no parâmetro da realização da consulta. | `String` (4) | SIM |

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
    "idServico": "CONSDECLARACAO13",
    "versaoSistema": "1.0",
    "dados": "{ \"anoCalendario\": \"2018\" }"
  }
}
```

### Pesquisa por período de apuração

**Objeto Dados:**

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| periodoApuracao | Período da apuração mensal. Quando for utilizado o periodo da apuração no parâmetro da realização da consulta. | `String` (6) | SIM |

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
    "idServico": "CONSDECLARACAO13",
    "versaoSistema": "1.0",
    "dados": "{ \"periodoApuracao\": \"201801\" }"
  }
}
```

## Dados de Saída

A estrutura de dados retornada é a mesma nos casos de pesquisa por ano-calendário ou período de apuração. O que muda é a quantidade itens retornados.

| Campo | Descrição | Tipo |
| --- | --- | --- |
| status | Status HTTP retornado no acionamento do serviço. | `Number` |
| mensagens | Mensagem explicativa retornada no acionamento do serviço. É um array composto de Código e texto da mensagem. O campo Código é um Texto de tamanho 5 que representa um código interno do negócio. | `Array` |
| dados | Estrutura de dados de retorno, contendo uma lista em SCAPED Texto JSON com o objeto DeclaracoesEntregues. | `String` |

### Objeto: DeclaracoesEntregues

| Campo | Descrição | Tipo |
| --- | --- | --- |
| anoCalendario | Ano-calendário. | `Number` |
| periodos | Contém uma lista de declarações em um determinado período de apuração (PA). Quando for utilizado o ano-calendário no parâmetro da realização da consulta. | `Array` de `Object` Periodo |
| periodo | Contém apenas um período de apuração (PA). Quando for utilizado o periodo da apuração no parâmetro da realização da consulta. | `Object` |

### Objeto: Periodo

| Campo | Descrição | Tipo |
| --- | --- | --- |
| periodoApuracao | Período da apuração, formato AAAAMM. | `Number` |
| operacoes | Lista todas as operações realizadas no período de apuração. | `Array` de `Object` Operacao |

### Objeto: Operacao

| Campo | Descrição | Tipo |
| --- | --- | --- |
| tipoOperacao | Tipo da operação realizada: (Declaração Original; Declaração Retificadora; Geração de DAS; DAS Avulso, DAS Medida Judicial ou DAS Cobrança). | `String` (30) |
| indiceDeclaracao | Estrutura de dados da declaração.Objeto: IndiceDeclaracao indiceDas Estrutura de dados do DAS. | `Object` |

### Objeto: IndiceDeclaracao

| Campo | Descrição | Tipo |
| --- | --- | --- |
| numeroDeclaracao | Identificador único da declaração transmitida. | `String` (17) |
| dataHoraTransmissao | Data e hora da entrega à RFB. Formato yyyyMMddHHmmss. | `Number` |
| malha | Situação da malha quando aplicável: (Retida em Malha; Liberada, Intimada ou Rejeitada). A situação Liberada contempla 3 situações diferentes, liberada sem análise, liberada por alteração de parâmetros e aceita. Quando não está em Malha o campo retorna null. | `String` (30) |

### Objeto: IndiceDas

| Campo | Descrição | Tipo |
| --- | --- | --- |
| numeroDas | Número do DAS (Documento de Arrecadação do Simples Nacional). | `String` (17) |
| dataHoraEmissaoDas | Data e hora da emissão do DAS. Formato yyyyMMddHHmmss. | `Number` |
| dasPago | Informa se houve ou não pagamento do DAS até o momento da consulta. Pago (true) e não consta pagamento até o momento (false). | `Boolean` |
