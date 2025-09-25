# Integra Contador API

## Base URL

Base URL do endereço da Loja de APIs do Serpro:
`https://gateway.apiserpro.serpro.gov.br/integra-contador/v1/`

**IMPORTANTE**

Acesse a seção do swagger de [Demonstração](https://gateway.apiserpro.serpro.gov.br/integra-contador/v1/Demonstracao) para experimentar a API.



## Caminhos

Os caminhos para acionar qualquer serviço de negócio estão organizados nos tipos definidos logo abaixo.

### Apoiar

Este tipo refere-se aos serviços auxiliares ou de suporte.
URL: `https://gateway.apiserpro.serpro.gov.br/integra-contador/v1/Apoiar`

### Consultar

É o caminho para os serviços do tipo consulta.
URL: `https://gateway.apiserpro.serpro.gov.br/integra-contador/v1/Consultar`

### Declarar

Este tipo refere-se aos serviços de entrega ou transmissão de declaração.

### Emitir

É o caminho para os serviços relacionados a emissão de comprovantes, relatórios, guia de recolhimento ou documento de arrecadação.

### Monitorar

Este tipo refere-se aos serviços de monitoração.

**Informação**

Acesse a seção do [Catálogo de Serviços]() para descobrir todos os serviços e o tipo de caminho que deve ser utilizado.



## Padrões

*   RESTFUL/JSON (JavaScript Object Notation);
*   Application/json;
*   URL HTTPS;
*   Método: POST;
*   camelCase;
*   Encode UTF-8;
*   SCAPED STRING para o json do objeto "dados", exemplo:
    
    `{     "dados": "{\"cnpjBasico\": \"23478643\", \"pa\": \


202001\", \"dataConsolidacao\": null}" }`

## Body

O corpo da mensagem de entrada é representado por um objeto JSON com a seguinte estrutura obrigatória:

```json
{ 
  "contratante": { 
    "numero": "string", 
    "tipo": 1 
  }, 
  "autorPedidoDados": { 
    "numero": "string", 
    "tipo": 1 
  }, 
  "contribuinte": { 
    "numero": "string", 
    "tipo": 1 
  }, 
  "pedidoDados": { 
    "idSistema": "string", 
    "idServico": "string", 
    "versaoSistema": "string", 
    "dados": "string" 
  } 
}
```

Objeto Contratante:

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| numero | Número do CNPJ completo (incluindo o DV) do contratante do produto na Loja Serpro. Só são aceitos números e sem a máscara de formatação. | String (14) | SIM |
| tipo | Tipo do NI. Só é aceito o valor 2 que significa que o tipo do NI (número indicador) é CNPJ. | Number (1) | SIM |

Objeto AutorPedidoDados:

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| numero | Autor da requisição com o pedido de dados. Pode ser o próprio Contratante, Procurador ou Contribuinte. Esse campo aceita um número de CPF ou CNPJ completo (incluindo o DV). Só são aceitos números e sem a máscara de formatação. | String (11) - CPF / String (14) - CNPJ | SIM |
| tipo | Tipo do NI. Tipo 1 representa o CPF e tipo 2 é CNPJ. | Number (1) | SIM |

Objeto Contribuinte:

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| numero | Número do CNPJ completo (incluindo o DV) do Contribuinte que está sendo realizado alguma operação de obrigação fiscal ou consulta de dados. Esse campo aceita um número de CPF ou CNPJ completo (incluindo o DV). Só são aceitos números e sem a máscara de formatação. | String (11) - CPF / String (14) - CNPJ | SIM |
| tipo | Tipo do NI. Tipo 1 representa o CPF e tipo 2 é CNPJ.  Em serviços com envio de contribuinte em lote ou lista é representado por tipo 3 lista de PF e tipo 4 lista PJ. | Number (1) | SIM |

Objeto PedidoDados:

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| idSistema | Identificador do sistema. | String | SIM |
| idServico | Identificador do serviço que contém a funcionalidade do sistema. | String | SIM |
| versaoSistema | Versão do sistema acionado | String | SIM |
| dados | Contém os parâmetros de entrada no sistema acionado. | String (SCAPED STRING JSON) | SIM |




# Catálogo de Serviços

Este catálogo de serviços do Integra Contador exibe a situação de todos os serviços. Não é uma página de Health Check, mas sim um local que contém o "roadmap" de todos os serviços do produto.

**Informação**

As colunas `idSistema` e `idServico` são utilizados no do pedido de dados. A coluna `Tipo` representa o método a ser invocado pelo serviço.



## Integra-SN

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 001 | 1.1 | PGDAST | TRANSDECLARACAO11 | 23/09/2022 | Declarar | Entregar declaração me |
| 002 | 1.2 | PGDAST | GERARDAS12 | 23/09/2022 | Emitir | Gerar DAS |
| 003 | 1.3 | PGDAST | CONSDECLARACA013 | 23/09/2022 | Consultar | Consultar Declarações transmitidas |
| 004 | 1.4 | PGDAST | CONSULTIMADECREC14 | 23/09/2022 | Consultar | Consultar a Últ Declaração/Re transmitida |



_


## Integra-MEI

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 005 | 2.1 | PGDAST | GERADASNMEI01 | 23/09/2022 | Emitir | Gerar DASN-SIMEI |
| 006 | 2.2 | PGDAST | CONSULTASNMEI02 | 23/09/2022 | Consultar | Consultar DASN-SIMEI |



## Integra-DCTFWeb

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 007 | 3.1 | PGDAST | CONSULTDCTFWEB01 | 23/09/2022 | Consultar | Consultar DCTFWeb |
| 008 | 3.2 | PGDAST | CONSULTDEBCRED02 | 23/09/2022 | Consultar | Consultar Débitos e Créditos Previdenciários |
| 009 | 3.3 | PGDAST | EMITIRDARF03 | 23/09/2022 | Emitir | Emitir DARF |



## Integra-Procurações

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 010 | 4.1 | PGDAST | CONSULTPROCURA01 | 23/09/2022 | Consultar | Consultar Procurações |



## Integra-Sicalc

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 011 | 5.1 | PGDAST | CONSULTDARF01 | 23/09/2022 | Consultar | Consultar DARF |
| 012 | 5.2 | PGDAST | EMITIRDARF02 | 23/09/2022 | Emitir | Emitir DARF |



## Integra-CaixaPostal

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 013 | 6.1 | PGDAST | CONSULTCAIXAPOSTAL01 | 23/09/2022 | Consultar | Consultar Caixa Postal |



## Integra-Pagamento

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 014 | 7.1 | PGDAST | CONSULTCOMPENSACAO01 | 23/09/2022 | Consultar | Consultar Compensação |
| 015 | 7.2 | PGDAST | CONSULTRESTITUICAO02 | 23/09/2022 | Consultar | Consultar Restituição |
| 016 | 7.3 | PGDAST | CONSULTPAGAMENTO03 | 23/09/2022 | Consultar | Consultar Pagamento |



## Integra-Contador-Gerenciador

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 017 | 8.1 | PGDAST | CONSULTLOGEXECUCAO01 | 23/09/2022 | Consultar | Consultar Log de Execução |



## Integra-SITFIS

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 018 | 9.1 | PGDAST | CONSULTINTIMACAO01 | 23/09/2022 | Consultar | Consultar Intimação |
| 019 | 9.2 | PGDAST | CONSULTPROCESSO02 | 23/09/2022 | Consultar | Consultar Processo |



## Integra-Parcelamentos

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 020 | 10.1 | PGDAST | CONSULTPARCELAMENTO01 | 23/09/2022 | Consultar | Consultar Parcelamento |
| 021 | 10.2 | PGDAST | EMITIRPARCELAMENTO02 | 23/09/2022 | Emitir | Emitir Parcelamento |



## Integra-Redesim

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 022 | 11.1 | PGDAST | CONSULTREDESIM01 | 23/09/2022 | Consultar | Consultar Redesim |



## Integra-e-Processo

| Sequencial | Código | idSistema | idServico | Situação e Data da Implantação | Tipo | Descrição |
| --- | --- | --- | --- | --- | --- | --- |
| 023 | 12.1 | PGDAST | CONSULTPROCESSO01 | 23/09/2022 | Consultar | Consultar Processo |

## Legenda

| Status | Descrição |
| --- | --- |
| Em produção | Disponível em produção |
| Em demonstração | Disponível em demonstração |
| Em construção | Em desenvolvimento |
| Em prospecção | Em análise e planejamento |
| Cancelado | Serviço Descontinuado |


