# PGDASD - Cenários de Demonstração

**IMPORTANTE**

A chamada da API Trial é apenas para demonstração. As APIs disponíveis e suas respectivas URLs (endpoints) para consumo são disponibilizadas (através da documentação dos seus respectivos swaggers) na seção [Referência da API]().

Na chamada da API Trial o parâmetro do tipo header `jwt_token` não é obrigatório, apenas no contexto real de produção esse parâmetro é obrigatório. Saiba mais sobre o `jwt_token` na seção [Como Autenticar na API]().

## Serviços PGDAS-D

### Consultar Declarações Transmitidas por Ano-Calendário ou Período de Apuração

Esta simulação lista um índice com todas as declarações transmitidas no ano-calendário indicado.

### Gerar DAS

| header | valor |
| --- | --- |
| `jwt_token` | vazio (não precisa preencher) |
| `autenticar_procurador_token` | vazio (não precisa preencher) |

**Body:**

```json
{ 
    "contratante": { 
        "numero": "00000000000100", 
        "tipo": 2 
    }, 
    "autorPedidoDados": { 
        "numero": "00000000000100", 
        "tipo": 2 
    }, 
    "contribuinte": { 
        "numero": "00000000000100", 
        "tipo": 2 
    }, 
    "pedidoDados": { 
        "idSistema": "PGDASD", 
        "idServico": "GERARDAS12", 
        "versaoSistema": "1.0", 
        "dados": "{ \"periodoApuracao\": \"201801\" }" 
    } 
}
```

**Curl:**

```bash
curl -X 'POST' \
   'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1/Emitir' \
   -H 'accept: text/plain' \
   -H "Authorization: Bearer 06aef429-a981-3ec5-a1f8-71d38d86481e" \
   -H 'Content-Type: application/json' \
   -d '{   "contratante": {     "numero": "00000000000100",     "tipo": 2   },   "autorPedidoDados": {     "numero": "00000000000100",     "tipo": 2    },   "contribuinte": {     "numero": "00000000000100",     "tipo": 2    },   "pedidoDados": {     "idSistema": "PGDASD",     "idServico": "GERARDAS12",     "versaoSistema": "1.0",     "dados": "{ \"periodoApuracao\": \"201801\" }"    } }'
```

