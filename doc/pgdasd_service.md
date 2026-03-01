# PGDASD - Programa Gerador do DAS do Simples Nacional

## Visão Geral

O serviço PGDASD permite gerenciar declarações e pagamentos do Simples Nacional, incluindo entrega de declarações mensais, geração de DAS, consulta de declarações e extratos.

## Funcionalidades

- **Entregar Declaração Mensal** (`TRANSDECLARACAO11`): Transmissão de declarações mensais do Simples Nacional
- **Gerar DAS** (`GERARDAS12`): Geração de Documento de Arrecadação Simples Nacional
- **Consultar Declarações** (`CONSDECLARACAO13`): Consulta de declarações transmitidas por ano ou período
- **Consultar Última Declaração** (`CONSULTIMADECREC14`): Consulta da última declaração/recibo transmitida
- **Consultar Declaração por Número** (`CONSDECREC15`): Consulta de declaração/recibo específica por número
- **Consultar Extrato DAS** (`CONSEXTRATO16`): Consulta de extrato da apuração por número de DAS
- **Gerar DAS Cobrança** (`GERARDASCOBRANCA17`): Geração de DAS com débitos em sistema de cobrança
- **Gerar DAS Processo** (`GERARDASPROCESSO18`): Geração de DAS de processo
- **Gerar DAS Avulso** (`GERARDASAVULSO19`): Geração de DAS avulso com tributos específicos
- **Métodos Compostos**:
  - **Consultar Última Declaração com Pagamento**: Consulta a última declaração e verifica se o DAS foi pago
  - **Entregar Declaração com DAS**: Entrega a declaração e gera o DAS automaticamente

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PGDASD

### Autenticação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

final apiClient = ApiClient();
await apiClient.authenticate(
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret',
  contratanteNumero: '12345678000100',
  autorPedidoDadosNumero: '12345678000100',
  certificadoDigitalPath: 'caminho/para/certificado.p12',
  senhaCertificado: 'senha_do_certificado',
  ambiente: 'trial', // ou 'producao'
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final pgdasdService = PgdasdService(apiClient);
```

### 2. Entregar Declaração Mensal (TRANSDECLARACAO11)

```dart
try {
  // Criar declaração de exemplo
  final declaracao = Declaracao(
    tipoDeclaracao: 1, // Original
    receitaPaCompetenciaInterno: 50000.00,
    receitaPaCompetenciaExterno: 10000.00,
    estabelecimentos: [
      Estabelecimento(
        cnpjCompleto: '00000000000100',
        atividades: [
          Atividade(
            idAtividade: 1,
            valorAtividade: 60000.00,
            receitasAtividade: [
              ReceitaAtividade(
                valor: 60000.00,
                isencoes: [
                  Isencao(codTributo: 1, valor: 1000.00, identificador: 1),
                ],
                reducoes: [
                  Reducao(codTributo: 1, valor: 500.00, percentualReducao: 5.0, identificador: 1),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  final response = await pgdasdService.entregarDeclaracao(
    cnpj: '00000000000100',
    periodoApuracao: 202504,
    declaracao: declaracao,
    indicadorTransmissao: true,
    indicadorComparacao: true,
    valoresParaComparacao: [
      ValorDevido(codigoTributo: 1, valor: 1000.00),
      ValorDevido(codigoTributo: 2, valor: 500.00),
    ],
  );

  if (response.sucesso) {
    print('Declaração entregue com sucesso!');
    final dados = response.dados;
    if (dados != null) {
      print('ID Declaração: ${dados.idDeclaracao}');
      print('Data Transmissão: ${dados.dataHoraTransmissao}');
      print('Valor Total Devido: R\$ ${dados.valorTotalDevido.toStringAsFixed(2)}');
      
      // Detalhamento dos valores devidos
      for (final valor in dados.valoresDevidos) {
        print('Tributo ${valor.codigoTributo}: R\$ ${valor.valor.toStringAsFixed(2)}');
      }
      
      // Detalhamento MAED se houver
      if (dados.temMaed) {
        final maed = dados.detalhamentoDarfMaed!;
      print('MAED:');
      print('  Número Documento: ${maed.numeroDocumento}');
      print('  Data Vencimento: ${maed.dataVencimento}');
      print('  Principal: R\$ ${maed.valores.principal.toStringAsFixed(2)}');
      print('  Multa: R\$ ${maed.valores.multa.toStringAsFixed(2)}');
      print('  Juros: R\$ ${maed.valores.juros.toStringAsFixed(2)}');
      print('  Total: R\$ ${maed.valores.total.toStringAsFixed(2)}');
      }
    }
  } else {
    print('Erro: ${response.mensagens.isNotEmpty ? response.mensagens.first.texto : ""}');
  }
} catch (e) {
  print('Erro ao entregar declaração: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte (14 dígitos, usa ApiClient se não fornecido) |
| `periodoApuracao` | `int` | Sim | Período de apuração (formato: AAAAMM, ex: 202504) |
| `declaracao` | `Declaracao` | Sim | Objeto com os dados da declaração |
| `indicadorTransmissao` | `bool` | Não | Se deve transmitir (padrão: `true`) |
| `indicadorComparacao` | `bool` | Não | Se há comparação de valores (padrão: `true`) |
| `valoresParaComparacao` | `List<ValorDevido>?` | Não | Valores para comparação |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 3. Gerar DAS (GERARDAS12)

```dart
try {
  final response = await pgdasdService.gerarDas(
    contribuinteNumero: '00000000000100',
    periodoApuracao: '202504',
    // dataConsolidacao: '20250531', // Opcional
  );

  if (response.sucesso && response.dados != null && response.dados!.isNotEmpty) {
    final das = response.dados!.first;
    final det = das.detalhamento;
    print('DAS gerado com sucesso!');
    print('Número do DAS: ${det.numeroDocumento}');
    print('Valor Total: R\$ ${det.valores.total.toStringAsFixed(2)}');
    print('Data Vencimento: ${det.dataVencimento}');
    
    // Salvar PDF
    if (das.pdf.isNotEmpty) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        das.pdf,
        'das_${det.numeroDocumento}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagens.isNotEmpty ? response.mensagens.first.texto : ""}');
  }
} catch (e) {
  print('Erro ao gerar DAS: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `periodoApuracao` | `String` | Sim | Período de apuração (formato: AAAAMM) |
| `dataConsolidacao` | `String?` | Não | Data de consolidação futura (formato: AAAAMMDD) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 4. Consultar Declarações (CONSDECLARACAO13)

Pode consultar por **ano calendário** ou **período de apuração**.

```dart
// Por ano calendário
try {
  final response = await pgdasdService.consultarDeclaracoes(
    contribuinteNumero: '00000000000100',
    anoCalendario: '2024',
  );

  if (response.sucesso) {
    print('Declarações encontradas!');
  }
} catch (e) {
  print('Erro: $e');
}

// Por período de apuração
try {
  final response = await pgdasdService.consultarDeclaracoes(
    contribuinteNumero: '00000000000100',
    periodoApuracao: '202504',
  );

  if (response.sucesso) {
    print('Declarações no período encontradas!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `anoCalendario` | `String?` | Condicional | Ano calendário (AAAA) — forneça este OU `periodoApuracao` |
| `periodoApuracao` | `String?` | Condicional | Período de apuração (AAAAMM) — forneça este OU `anoCalendario` |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 5. Consultar Última Declaração (CONSULTIMADECREC14)

```dart
try {
  final response = await pgdasdService.consultarUltimaDeclaracao(
    contribuinteNumero: '00000000000100',
    periodoApuracao: '202504',
  );

  if (response.sucesso) {
    print('Última declaração encontrada!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `periodoApuracao` | `String` | Sim | Período de apuração (formato: AAAAMM) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 6. Consultar Declaração por Número (CONSDECREC15)

```dart
try {
  final response = await pgdasdService.consultarDeclaracaoPorNumero(
    contribuinteNumero: '00000000000100',
    numeroDeclaracao: '07202136999997159',
  );

  if (response.sucesso) {
    print('Declaração encontrada!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `numeroDeclaracao` | `String` | Sim | Número da declaração (17 dígitos) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 7. Consultar Extrato DAS (CONSEXTRATO16)

```dart
try {
  final response = await pgdasdService.consultarExtratoDas(
    contribuinteNumero: '00000000000100',
    numeroDas: '07202136999997159',
  );

  if (response.sucesso) {
    print('Extrato DAS encontrado!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `numeroDas` | `String` | Sim | Número do DAS (17 dígitos) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 8. Gerar DAS Cobrança (GERARDASCOBRANCA17)

```dart
try {
  final response = await pgdasdService.gerarDasCobranca(
    contribuinteNumero: '00000000000100',
    periodoApuracao: '202504',
  );

  if (response.sucesso) {
    print('DAS Cobrança gerado!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `periodoApuracao` | `String` | Sim | Período de apuração (formato: AAAAMM) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 9. Gerar DAS Processo (GERARDASPROCESSO18)

```dart
try {
  final response = await pgdasdService.gerarDasProcesso(
    contribuinteNumero: '00000000000100',
    numeroProcesso: '00000000000000000',
  );

  if (response.sucesso) {
    print('DAS Processo gerado!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `numeroProcesso` | `String` | Sim | Número do processo (17 dígitos) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 10. Gerar DAS Avulso (GERARDASAVULSO19)

```dart
try {
  final response = await pgdasdService.gerarDasAvulso(
    contribuinteNumero: '00000000000100',
    request: GerarDasAvulsoRequest(
      periodoApuracao: '202504',
      listaTributos: [
        TributoAvulso(codigoTributo: 1, valor: 1000.00),
      ],
    ),
  );

  if (response.sucesso) {
    print('DAS Avulso gerado!');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `request` | `GerarDasAvulsoRequest` | Sim | Dados para geração do DAS Avulso |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

### 11. Consultar Última Declaração com Pagamento (Método Composto)

Combina a consulta da última declaração com verificação automática do status de pagamento do DAS.

```dart
try {
  final response = await pgdasdService.consultarUltimaDeclaracaoComPagamento(
    contribuinteNumero: '00000000000100',
    periodoApuracao: '202504',
  );

  if (response.sucesso) {
    print('Última declaração encontrada!');
    print('Número: ${response.dados?.numeroDeclaracao}');
    print('Período: ${response.dados?.periodoApuracao}');
    print('DAS Pago: ${response.dasPago ? "Sim" : "Não"}');
    
    // Alerta de pagamento (pendências no ano)
    if (response.alertaPagamento != null) {
      print('⚠️ ${response.alertaPagamento}');
    }
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `contribuinteNumero` | `String?` | Não* | CNPJ do contribuinte |
| `periodoApuracao` | `String` | Sim | Período de apuração (formato: AAAAMM) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Comportamento do campo `dasPago`:**
- `true`: DAS foi pago OU não foi encontrado DAS para o período (assume pago)
- `false`: DAS existe e não consta pagamento

### 12. Entregar Declaração com DAS (Método Composto)

Combina a entrega da declaração com geração automática do DAS em uma única operação.

```dart
try {
  final declaracao = Declaracao(
    tipoDeclaracao: 1,
    receitaPaCompetenciaInterno: 50000.00,
    receitaPaCompetenciaExterno: 10000.00,
    estabelecimentos: [
      Estabelecimento(
        cnpjCompleto: '00000000000100',
        atividades: [
          Atividade(
            idAtividade: 1,
            valorAtividade: 60000.00,
            receitasAtividade: [
              ReceitaAtividade(valor: 60000.00, isencoes: [], reducoes: []),
            ],
          ),
        ],
      ),
    ],
  );

  final response = await pgdasdService.entregarDeclaracaoComDas(
    cnpj: '00000000000100',
    periodoApuracao: 202504,
    declaracao: declaracao,
    indicadorTransmissao: true,
    indicadorComparacao: true,
    valoresParaComparacao: [],
    // dataConsolidacao: '20250515', // Opcional
  );

  if (response.sucesso) {
    print('✅ Declaração e DAS gerados com sucesso!');
    print('ID Declaração: ${response.dadosDeclaracao?.idDeclaracao}');
    
    if (response.dasGerado) {
      final das = response.dadosDas!.first;
      print('Número DAS: ${das.detalhamento.numeroDocumento}');
      print('Valor DAS: R\$ ${das.detalhamento.valores.total.toStringAsFixed(2)}');
    }
  } else if (response.declaracaoEntregue) {
    print('⚠️ Declaração entregue, mas DAS falhou');
    print('Tente gerar DAS manualmente usando gerarDas()');
  } else {
    print('❌ Erro ao entregar declaração: ${response.mensagens.isNotEmpty ? response.mensagens.first.texto : ""}');
  }
} catch (e) {
  print('Erro: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte |
| `periodoApuracao` | `int` | Sim | Período de apuração (formato: AAAAMM) |
| `declaracao` | `Declaracao` | Sim | Dados da declaração |
| `indicadorTransmissao` | `bool` | Não | Se transmitir (padrão: `true`) |
| `indicadorComparacao` | `bool` | Não | Se comparar valores (padrão: `true`) |
| `valoresParaComparacao` | `List<ValorDevido>?` | Não | Valores para comparação |
| `dataConsolidacao` | `String?` | Não | Data de consolidação para o DAS (AAAAMMDD) |
| `contratanteNumero` | `String?` | Não | CNPJ do contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Comportamento em caso de erros:**
- Se a declaração falhar: retorna erro imediatamente, não tenta gerar DAS
- Se o DAS falhar: retorna erro MAS preserva os dados da declaração para geração manual posterior

**Getters úteis:** `sucesso`, `declaracaoEntregue`, `dasGerado`

## Estrutura de Dados

### EntregarDeclaracaoResponse

```dart
class EntregarDeclaracaoResponse {
  final int status;
  final List<Mensagem> mensagens;
  final DeclaracaoTransmitida? dados;  // objeto único, não lista
  bool get sucesso => status == 200;
}

class DeclaracaoTransmitida {
  final String idDeclaracao;
  final String dataHoraTransmissao;
  final List<ValorDevido> valoresDevidos;
  double get valorTotalDevido => ...;
  bool get temMaed => ...;
  final DetalhamentoDarfMaed? detalhamentoDarfMaed;
}
```

### GerarDasResponse

```dart
class GerarDasResponse {
  final int status;
  final List<Mensagem> mensagens;
  final List<Das>? dados;
  bool get sucesso => status == 200;
}

// Cada item de dados possui:
// - pdf: String (PDF em Base64)
// - cnpjCompleto: String
// - detalhamento: objeto com numeroDocumento, dataVencimento, valores.total
```

### ConsultarUltimaDeclaracaoComPagamentoResponse

```dart
class ConsultarUltimaDeclaracaoComPagamentoResponse {
  final int status;
  final List<Mensagem> mensagens;
  final DeclaracaoCompleta? dados;
  final bool dasPago;
  final String? alertaPagamento; // Alerta sobre pendências no ano
  bool get sucesso => status == 200;
}
```

### EntregarDeclaracaoComDasResponse

```dart
class EntregarDeclaracaoComDasResponse {
  final int status;
  final List<Mensagem> mensagens;
  final DeclaracaoTransmitida? dadosDeclaracao;
  final List<Das>? dadosDas;
  bool get sucesso => status == 200;
  bool get declaracaoEntregue => dadosDeclaracao != null;
  bool get dasGerado => dadosDas != null && dadosDas!.isNotEmpty;
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Período inválido | Verificar formato do período de apuração (AAAAMM) |
| 004 | Declaração não encontrada | Verificar se declaração foi transmitida |
| 005 | Valores inválidos | Verificar valores monetários |

## Exemplo Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    contratanteNumero: '12345678000100',
    autorPedidoDadosNumero: '12345678000100',
    certificadoDigitalPath: 'caminho/para/certificado.p12',
    senhaCertificado: 'senha_do_certificado',
    ambiente: 'trial',
  );
  
  // 2. Criar serviço
  final pgdasdService = PgdasdService(apiClient);
  
  try {
    const cnpj = '00000000000100';
    
    // 3. Entregar declaração mensal
    print('=== Entregando Declaração ===');
    final declaracao = Declaracao(
      tipoDeclaracao: 1,
      receitaPaCompetenciaInterno: 50000.00,
      receitaPaCompetenciaExterno: 10000.00,
      estabelecimentos: [
        Estabelecimento(
          cnpjCompleto: cnpj,
          atividades: [
            Atividade(
              idAtividade: 1,
              valorAtividade: 60000.00,
              receitasAtividade: [
                ReceitaAtividade(
                  valor: 60000.00,
                  isencoes: [Isencao(codTributo: 1, valor: 1000.00, identificador: 1)],
                  reducoes: [Reducao(codTributo: 1, valor: 500.00, percentualReducao: 5.0, identificador: 1)],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final entregarResponse = await pgdasdService.entregarDeclaracao(
      cnpj: cnpj,
      periodoApuracao: 202504,
      declaracao: declaracao,
    );

    if (entregarResponse.sucesso && entregarResponse.dados != null) {
      final decl = entregarResponse.dados!;
      print('Declaração entregue!');
      print('ID: ${decl.idDeclaracao}');
      print('Valor: ${FormatadorUtils.formatCurrency(decl.valorTotalDevido)}');
      
      // 4. Gerar DAS
      print('\n=== Gerando DAS ===');
      final dasResponse = await pgdasdService.gerarDas(
        contribuinteNumero: cnpj,
        periodoApuracao: '202504',
      );

      if (dasResponse.sucesso && dasResponse.dados != null && dasResponse.dados!.isNotEmpty) {
        final das = dasResponse.dados!.first;
        final det = das.detalhamento;
        print('DAS gerado!');
        print('Número: ${det.numeroDocumento}');
        print('Valor: ${FormatadorUtils.formatCurrency(det.valores.total)}');
        
        // Salvar PDF
        if (das.pdf.isNotEmpty) {
          await ArquivoUtils.salvarArquivo(das.pdf, 'das_${det.numeroDocumento}.pdf');
        }
      }
      
      // 5. Consultar declarações do ano
      print('\n=== Consultando Declarações ===');
      final consultarResponse = await pgdasdService.consultarDeclaracoes(
        contribuinteNumero: cnpj,
        anoCalendario: '2025',
      );

      if (consultarResponse.sucesso) {
        print('Declarações encontradas!');
      }
    }
    
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Dados de Teste

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000100';

// Períodos de teste
const periodoTeste = 202504;
const anoTeste = '2025';

// Valores de teste
const valorTeste = 1000.00;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados são validados automaticamente antes do envio
4. **Período de Apuração**: Deve estar no formato AAAAMM (int para `entregarDeclaracao`, String para os demais)
5. **Valores Monetários**: Devem ser valores positivos válidos

## Suporte

Para dúvidas sobre o serviço PGDASD:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package