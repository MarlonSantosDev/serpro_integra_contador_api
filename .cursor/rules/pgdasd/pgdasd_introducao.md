# Introdução ao PGDASD

## O que é o Integra PGDAS-D?

É uma solução integrada ao sistema Programa Gerador do Documento de Arrecadação do Simples Nacional - Declaratório (PGDAS-D 2018) que é um sistema eletrônico para a realização do cálculo do Simples Nacional para os períodos de apuração (PA) a partir de janeiro de 2018, conforme determinam a Lei Complementar nº 123, de 14 de dezembro de 2006 (e alterações) e Resolução CGSN nº 140, de 22 de maio de 2018.

## Como funciona o uso via Integra Contador?

Para utilizar os serviços do Integra PGDASD, é necessário fazer uma chamada à API por meio do Integra Contador, que é responsável por gerenciar o envio e o recebimento dos dados.

A requisição deve ser feita via método `POST`, com um corpo (`body`) em formato `JSON`, contendo as seguintes informações:

*   Contratante
*   Autor do Pedido de Dados
*   Contribuinte
*   Pedido de Dados

> ⚠️ **Importante:** O sistema aceita apenas contribuintes do tipo 2 (Pessoa Jurídica). Pedidos com outros tipos de contribuinte não serão processados.

O Integra Contador estabelece um canal seguro de comunicação com o sistema PGDASD, garantindo a integridade e a confidencialidade das informações transmitidas.
