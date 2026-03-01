# Exemplo de Json de retorno - Entregar Declaração Mensal

Exemplo de uma declaração transmitida.

## Json de retorno completo

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
    "idServico": "TRANSDECLARACAO11",
    "versaoSistema": "1.0",
    "dados": "{\"cnpjCompleto\":\"00000000000100\",\"pa\":202101,\"indicadorTransmissao\":true,\"indicadorComparacao\":true,\"declaracao\":{\"tipoDeclaracao\":1,\"receitaPaCompetenciaInterno\":10000.00,\"receitaPaCompetenciaExterno\":0.00,\"receitaPaCaixaInterno\":null,\"receitaPaCaixaExterno\":null,\"valorFixoIcms\":100.00,\"valorFixoIss\":null,\"receitasBrutasAnteriores\":[{\"pa\":202001,\"valorInterno\":100.00,\"valorExterno\":200.00},{\"pa\":202002,\"valorInterno\":300.00,\"valorExterno\":0.00},{\"pa\":202003,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202004,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202005,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202006,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202007,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202008,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202009,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202010,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202011,\"valorInterno\":0.00,\"valorExterno\":0.00},{\"pa\":202012,\"valorInterno\":0.00,\"valorExterno\":0.00}],\"folhasSalario\":[{\"pa\":202001,\"valor\":2000.00},{\"pa\":202002,\"valor\":2000.00},{\"pa\":202003,\"valor\":2000.00},{\"pa\":202004,\"valor\":2000.00},{\"pa\":202005,\"valor\":0.00},{\"pa\":202006,\"valor\":0.00},{\"pa\":202007,\"valor\":0.00},{\"pa\":202008,\"valor\":0.00},{\"pa\":202009,\"valor\":0.00},{\"pa\":202010,\"valor\":0.00},{\"pa\":202011,\"valor\":0.00},{\"pa\":202012,\"valor\":0.00}],\"naoOptante\":null,\"estabelecimentos\":[{\"cnpjCompleto\":\"0000000000100\",\"atividades\":[{\"idAtividade\":1,\"valorAtividade\":4000.00,\"receitasAtividade\":[{\"valor\":4000.00,\"codigoOutroMunicipio\":null,\"outraUf\":null,\"isencoes\":[{\"codTributo\":1007,\"valor\":100.00,\"identificador\":1}],\"reducoes\":[{\"codTributo\":1007,\"valor\":1500.00,\"percentualReducao\":50.00,\"identificador\":1}],\"qualificacoesTributarias\":[],\"exigibilidadesSuspensas\":null}]},{\"idAtividade\":10,\"valorAtividade\":6000.00,\"receitasAtividade\":[{\"valor\":6000.00,\"codigoOutroMunicipio\":9701,\"outraUf\":\"DF\",\"isencoes\":null,\"reducoes\":null,\"qualificacoesTributarias\":null,\"exigibilidadesSuspensas\":null}]}]}]},\"valoresParaComparacao\":[{\"codigoTributo\":1001,\"valor\":23.20},{\"codigoTributo\":1002,\"valor\":18.20},{\"codigoTributo\":1004,\"valor\":66.53},{\"codigoTributo\":1005,\"valor\":14.43},{\"codigoTributo\":1006,\"valor\":222.64},{\"codigoTributo\":1007,\"valor\":100.00},{\"codigoTributo\":1010,\"valor\":120.60}]}"
  },
  "status": "200",
  "mensagens": [
    {
      "codigo": "Sucesso-PGDASD",
      "texto": "Requisição efetuada com sucesso."
    },
    {
      "codigo": "Aviso-PGDASD-MSG_ISN_034",
      "texto": "A declaração do período 04/2021 da empresa TESTE, CNPJ 00.000.000/0001-00 foi transmitida com sucesso. Entretanto, foi entregue fora do prazo, o que ensejou a aplicação de multa. "
    }
  ],
  "dados": "{\"idDeclaracao\":\"00000000202104001\",\"dataHoraTransmissao\":\"20220803044803\",\"valoresDevidos\":[{\"codigoTributo\":1001,\"valor\":44.00},{\"codigoTributo\":1002,\"valor\":28.00},{\"codigoTributo\":1004,\"valor\":101.92},{\"codigoTributo\":1005,\"valor\":22.08},{\"codigoTributo\":1006,\"valor\":332.00},{\"codigoTributo\":1007,\"valor\":272.00}],\"declaracao\":\"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...290945 bytes truncated..."}"
}
```
