# Guia de implementação – authenticateWithProcurador, PGDAS e PGMEI

Documento único para implementar a autenticação unificada (OAuth2 + procurador) e consumir os serviços PGDAS/PGMEI usando o pacote `serpro_integra_contador_api`.

## Pré-requisitos
- Dart/Flutter configurado.
- Certificados digitais (`.pfx`) válidos do contratante e do procurador.
- Credenciais SERPRO (`consumerKey`, `consumerSecret`) e números CNPJ/CPF corretos.
- Ambiente: `producao` ou `trial` (quando disponível).

## Fluxo padrão (qualquer serviço)
1) Instale o pacote:
```yaml
dependencies:
  serpro_integra_contador_api: ^<versao>
```
2) Importe: `import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';`
3) Crie um `ApiClient` e autentique com `authenticateWithProcurador`.
4) Instancie o serviço (`PgdasdService`, `PgmeiService`, etc.) passando o `apiClient`.
5) Monte o request (model ou `BaseRequest`) e chame o método do serviço.
6) Verifique `response.sucesso`, leia `response.dados`/modelos e trate exceções.

### Metadados rápidos
| Serviço | idSistema | idServico | Endpoint (padrão) |
| --- | --- | --- | --- |
| authenticateWithProcurador | OAuth2 | AUTENTICARPROCURADOR | `/AutenticarProcurador` (interno) |
| PGDASD – entregar declaração | PGDASD | TRANSDECLARACAO11 | `/Declarar` |
| PGDASD – gerar DAS | PGDASD | GERARDAS12 | `/Emitir` |
| PGDASD – consultar declarações | PGDASD | CONSDECLARACAO13 | `/Consultar` |
| PGDASD – última declaração | PGDASD | CONSULTIMADECREC14 | `/Consultar` |
| PGDASD – declaração por número | PGDASD | CONSDECREC15 | `/Consultar` |
| PGDASD – extrato do DAS | PGDASD | CONSEXTRATO16 | `/Consultar` |
| PGDASD – DAS cobrança | PGDASD | GERARDASCOBRANCA17 | `/Emitir` |
| PGDASD – DAS processo | PGDASD | GERARDASPROCESSO18 | `/Emitir` |
| PGDASD – DAS avulso | PGDASD | GERARDASAVULSO19 | `/Emitir` |
| PGMEI – DAS PDF | PGMEI | GERARDASPDF21 | `/Emitir` |
| PGMEI – DAS código barras | PGMEI | GERARDASCODBARRA22 | `/Emitir` |
| PGMEI – atualizar benefício | PGMEI | ATUBENEFICIO23 | `/Emitir` |
| PGMEI – dívida ativa | PGMEI | DIVIDAATIVA24 | `/Consultar` |

---

## Autenticação – `authenticateWithProcurador`
Autentica via OAuth2 e obtém o token do procurador numa única chamada.

**Parâmetros OAuth2**
- `consumerKey`, `consumerSecret`: credenciais SERPRO.
- `contratanteNumero`: CNPJ do contratante.
- `autorPedidoDadosNumero`: CNPJ/CPF que solicita os dados.
- Certificado do contratante: `certificadoDigitalPath` **ou** `certificadoDigitalBase64` + `senhaCertificado`.
- `ambiente`: `producao` ou `trial`.

**Parâmetros do Procurador (obr. para token de procuração)**
- `contratanteNome`, `autorNome`
- `contribuinteNumero`: CNPJ consultado (default: contratanteNumero)
- `autorNumero`: CPF/CNPJ do procurador (default: autorPedidoDadosNumero)
- Certificado do procurador: `certificadoProcuradorPath` ou `certificadoProcuradorBase64` + `certificadoProcuradorPassword`

**Exemplo**
```dart
final apiClient = ApiClient();

await apiClient.authenticateWithProcurador(
  consumerKey: '<consumerKey>',
  consumerSecret: '<consumerSecret>',
  contratanteNumero: '<CNPJ_CONTRATANTE>',
  autorPedidoDadosNumero: '<CNPJ_SOLICITANTE>',
  certificadoDigitalPath: 'contratante.pfx',
  senhaCertificado: '<senha_certificado_contratante>',
  ambiente: 'producao',
  contratanteNome: 'NOME EMPRESA CONTRATANTE',
  autorNome: 'Nome do procurador',
  autorNumero: '<CPF_CNPJ_PROCURADOR>',
  contribuinteNumero: '<CNPJ_CONSULTADO>',
  certificadoProcuradorPath: 'procurador.pfx',
  certificadoProcuradorPassword: '<senha_certificado_procurador>',
);

print('Token procurador: ${apiClient.procuradorToken}');
```

**Saída esperada (simplificada)**
```
✅ Autenticação unificada (OAuth2 + Procurador) realizada com sucesso!
Token: eyJhbGciOi...
```

---

## PGDAS – `PgdasdService`
Serviços completos com ID de sistema/serviço embutidos nas chamadas.

### Consulta rápida (CONSDECLARACAO13)
```dart
final pgdasd = PgdasdService(apiClient);
final resp = await pgdasd.consultarDeclaracoesPorPeriodo(
  cnpj: '<CNPJ_CONSULTADO>',
  periodoApuracao: '202509',
);
if (resp.sucesso) {
  print(resp.dados?.anoCalendario);
  print(resp.dados?.listaPeriodos.length);
}
```

Saída típica:
```
✅ Status: 200
✅ Sucesso: true
📅 Ano Calendário: 2025
🔍 Períodos encontrados: 1
```

### Mapeamento de operações PGDASD
- **TRANSDECLARACAO11** (`/Declarar`) – transmitir declaração mensal.
  - Dados: declaração completa (`EntregarDeclaracaoRequest`).
- **GERARDAS12** (`/Emitir`) – gerar DAS de declaração transmitida.
  - Dados: `periodoApuracao` e opcional `dataConsolidacao`.
- **CONSDECLARACAO13** (`/Consultar`) – listar declarações por ano ou período.
  - Dados: ano (AAAA) ou período (AAAAMM).
- **CONSULTIMADECREC14** (`/Consultar`) – última declaração/recibo por período.
- **CONSDECREC15** (`/Consultar`) – declaração/recibo por número (17 dígitos).
- **CONSEXTRATO16** (`/Consultar`) – extrato do DAS por número.
- **GERARDASCOBRANCA17** (`/Emitir`) – DAS com débitos em cobrança.
  - Dados mínimos: `periodoApuracao`.
- **GERARDASPROCESSO18** (`/Emitir`) – DAS de processo.
  - Dados mínimos: `numeroProcesso`.
- **GERARDASAVULSO19** (`/Emitir`) – DAS avulso com lista de tributos.
  - Dados mínimos: `periodoApuracao`, `listaTributos`.

### Exemplo: gerar DAS (GERARDAS12)
```dart
final resp = await pgdasd.gerarDasSimples(
  cnpj: '<CNPJ>',
  periodoApuracao: '202403',
  dataConsolidacao: '20240430', // opcional
);
if (resp.sucesso) {
  final das = resp.dados?.first;
  print('PDF base64: ${das?.pdf.length} chars');
  print('Valor total: ${das?.detalhamento.valores.total}');
}
```

### Exemplo: declarar (TRANSDECLARACAO11)
```dart
final resp = await pgdasd.entregarDeclaracaoSimples(
  cnpj: '<CNPJ>',
  periodoApuracao: 202501,
  declaracao: /* Declaracao model */,
  transmitir: true,
);
print('Status: ${resp.status}');
print('Número recibo: ${resp.numeroRecibo}');
```

### Exemplo: extrato do DAS (CONSEXTRATO16)
```dart
final extrato = await pgdasd.consultarExtratoDasSimples(
  cnpj: '<CNPJ>',
  numeroDas: '<NUMERO_DAS>',
);
print('Sucesso: ${extrato.sucesso}');
print('Mensagens: ${extrato.mensagens.map((m) => m.texto).join(', ')}');
```

---

## PGMEI – `PgmeiService`
Operações suportadas:
- **GERARDASPDF21** (`/Emitir`) – gerar DAS com PDF.
- **GERARDASCODBARRA22** (`/Emitir`) – gerar DAS com código de barras.
- **ATUBENEFICIO23** (`/Emitir`) – atualizar benefício.
- **DIVIDAATIVA24** (`/Consultar`) – consultar dívida ativa.

### Gerar DAS (PDF) – GERARDASPDF21
```dart
final pgmei = PgmeiService(apiClient);
final r = await pgmei.gerarDas(
  cnpj: '00000000000100',
  periodoApuracao: '201901',
);
if (r.sucesso) {
  final das = r.dasGerados?.first;
  final det = das?.primeiroDetalhamento;
  print('PDF base64: ${das?.pdf.length} chars');
  print('Valor total: R\$ ${det?.valores.total.toStringAsFixed(2)}');
  print('Vencimento: ${det?.dataVencimento}');
}
```

Saída esperada:
```
✅ Successo: DAS gerado
📄 PDF gerado: 12345 caracteres
💰 Valor total: R$ 120.00
📅 Vencimento: 20190220
```

### Gerar DAS código de barras – GERARDASCODBARRA22
```dart
final r = await pgmei.gerarDasCodigoBarras(
  cnpj: '00000000000100',
  periodoApuracao: '201901',
);
if (r.sucesso) {
  final det = r.dasGerados?.first.primeiroDetalhamento;
  print('Código de barras: ${det?.codigoDeBarras.join(' ')}');
}
```

### Atualizar benefício – ATUBENEFICIO23
```dart
final r = await pgmei.atualizarBeneficio(
  cnpj: '00000000000100',
  anoCalendario: 2021,
  beneficios: [
    InfoBeneficio(periodoApuracao: '202101', indicadorBeneficio: true),
    InfoBeneficio(periodoApuracao: '202102', indicadorBeneficio: true),
  ],
);
print('Sucesso: ${r.sucesso}');
print('Benefícios atualizados: ${r.beneficiosAtualizados?.length}');
```

### Consultar dívida ativa – DIVIDAATIVA24
```dart
final r = await pgmei.consultarDividaAtiva(
  cnpj: '00000000000101',
  anoCalendario: '2020',
);
if (r.sucesso && r.temDebitosDividaAtiva) {
  print('Valor total: ${r.valorTotalDividaAtiva}');
  for (final d in r.debitosDividaAtiva!) {
    print('${d.periodoApuracao} - ${d.tributo}: ${d.valor}');
  }
}
```

Saída típica:
```
🚨 Situação: CONTRIBUINTE EM DÍVIDA ATIVA
💰 Valor total em dívida: R$ 999.99
Período: 202001 - DAS: R$ 999.99
```

---

## Padronização/boas práticas
1) Sempre autentique com `authenticateWithProcurador` antes de serviços que exigem procuração.
2) Passe `contratanteNumero`/`autorPedidoDadosNumero` explícitos se diferente do autenticado.
3) Use os métodos `*Simples` (PGDASD) quando quiser menos campos; os modelos completos existem para cenários avançados.
4) Trate erros com `try/catch` e logue `response.mensagens`.
5) Tokens são renovados automaticamente pelo `ApiClient`, mas é possível limpar cache de procurador via `AutenticaProcuradorService.limparCache()`.
