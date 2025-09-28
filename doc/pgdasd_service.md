# PGDASD - Programa Gerador do DAS do Simples Nacional

## Visão Geral

O serviço PGDASD permite gerenciar declarações mensais do Simples Nacional, incluindo entrega de declarações, geração de DAS, consulta de declarações transmitidas e consulta de extratos.

## Funcionalidades

- **Entregar Declaração Mensal**: Transmissão de declarações mensais do Simples Nacional
- **Gerar DAS**: Geração de Documento de Arrecadação do Simples Nacional
- **Consultar Declarações**: Consulta de declarações transmitidas por ano ou período
- **Consultar Última Declaração**: Consulta da última declaração/recibo transmitida
- **Consultar Declaração por Número**: Consulta de declaração específica por número
- **Consultar Extrato do DAS**: Consulta de extrato da apuração do DAS

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
  'seu_consumer_key',
  'seu_consumer_secret', 
  'caminho/para/certificado.p12',
  'senha_do_certificado',
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final pgdasdService = PgdasdService(apiClient);
```

### 2. Entregar Declaração Mensal

```dart
try {
  final declaracao = Declaracao(
    receitaBruta: 100000.0,
    receitaBrutaAcumulada: 100000.0,
    // ... outros campos obrigatórios
  );
  
  final response = await pgdasdService.entregarDeclaracaoSimples(
    cnpj: '00000000000000',
    periodoApuracao: 202401, // AAAAMM
    declaracao: declaracao,
    transmitir: true,
    compararValores: false,
  );
  
  if (response.sucesso) {
    print('Declaração entregue com sucesso!');
    print('Número da declaração: ${response.dados.numeroDeclaracao}');
  }
} catch (e) {
  print('Erro ao entregar declaração: $e');
}
```

### 3. Gerar DAS

```dart
try {
  final response = await pgdasdService.gerarDasSimples(
    cnpj: '00000000000000',
    periodoApuracao: '202401',
    dataConsolidacao: '20240215', // Opcional
  );
  
  if (response.sucesso) {
    print('DAS gerado com sucesso!');
    print('Número do DAS: ${response.dados.numeroDas}');
  }
} catch (e) {
  print('Erro ao gerar DAS: $e');
}
```

### 4. Consultar Declarações por Ano

```dart
try {
  final response = await pgdasdService.consultarDeclaracoesPorAno(
    cnpj: '00000000000000',
    anoCalendario: '2024',
  );
  
  if (response.sucesso) {
    print('Declarações encontradas: ${response.dados.length}');
    for (final declaracao in response.dados) {
      print('Período: ${declaracao.periodoApuracao}');
      print('Número: ${declaracao.numeroDeclaracao}');
    }
  }
} catch (e) {
  print('Erro ao consultar declarações: $e');
}
```

### 5. Consultar Declarações por Período

```dart
try {
  final response = await pgdasdService.consultarDeclaracoesPorPeriodo(
    cnpj: '00000000000000',
    periodoApuracao: '202401',
  );
  
  if (response.sucesso) {
    print('Declarações encontradas: ${response.dados.length}');
  }
} catch (e) {
  print('Erro ao consultar declarações: $e');
}
```

### 6. Consultar Última Declaração

```dart
try {
  final response = await pgdasdService.consultarUltimaDeclaracaoPorPeriodo(
    cnpj: '00000000000000',
    periodoApuracao: '202401',
  );
  
  if (response.sucesso) {
    print('Última declaração encontrada!');
    print('Número: ${response.dados.numeroDeclaracao}');
    print('Data de transmissão: ${response.dados.dataTransmissao}');
  }
} catch (e) {
  print('Erro ao consultar última declaração: $e');
}
```

### 7. Consultar Declaração por Número

```dart
try {
  final response = await pgdasdService.consultarDeclaracaoPorNumeroSimples(
    cnpj: '00000000000000',
    numeroDeclaracao: '12345678901234567', // 17 dígitos
  );
  
  if (response.sucesso) {
    print('Declaração encontrada!');
    print('Período: ${response.dados.periodoApuracao}');
    print('Valor total: ${response.dados.valorTotal}');
  }
} catch (e) {
  print('Erro ao consultar declaração: $e');
}
```

### 8. Consultar Extrato do DAS

```dart
try {
  final response = await pgdasdService.consultarExtratoDasSimples(
    cnpj: '00000000000000',
    numeroDas: '12345678901234567', // 17 dígitos
  );
  
  if (response.sucesso) {
    print('Extrato encontrado!');
    print('Valor total: ${response.dados.valorTotal}');
    print('Data de vencimento: ${response.dados.dataVencimento}');
  }
} catch (e) {
  print('Erro ao consultar extrato: $e');
}
```

## Estrutura de Dados

### Declaracao

```dart
class Declaracao {
  final double receitaBruta;           // Receita bruta do período
  final double receitaBrutaAcumulada;  // Receita bruta acumulada
  final double valorDevido;           // Valor devido
  final double valorPago;             // Valor pago
  // ... outros campos obrigatórios
}
```

### EntregarDeclaracaoRequest

```dart
class EntregarDeclaracaoRequest {
  final String cnpjCompleto;           // CNPJ completo
  final int pa;                        // Período de apuração (AAAAMM)
  final bool indicadorTransmissao;     // Se deve transmitir
  final bool indicadorComparacao;     // Se deve comparar valores
  final Declaracao declaracao;        // Dados da declaração
  final List<ValorDevido>? valoresParaComparacao; // Valores para comparação
}
```

### GerarDasRequest

```dart
class GerarDasRequest {
  final String periodoApuracao;       // Período de apuração (AAAAMM)
  final String? dataConsolidacao;     // Data de consolidação (AAAAMMDD)
}
```

## Métodos de Conveniência

### Entregar Declaração com Dados Simplificados

```dart
final response = await pgdasdService.entregarDeclaracaoSimples(
  cnpj: '00000000000000',
  periodoApuracao: 202401,
  declaracao: declaracao,
  transmitir: true,
  compararValores: false,
);
```

### Gerar DAS com Dados Simplificados

```dart
final response = await pgdasdService.gerarDasSimples(
  cnpj: '00000000000000',
  periodoApuracao: '202401',
  dataConsolidacao: '20240215',
);
```

### Consultar Declarações por Ano

```dart
final response = await pgdasdService.consultarDeclaracoesPorAno(
  cnpj: '00000000000000',
  anoCalendario: '2024',
);
```

### Consultar Declarações por Período

```dart
final response = await pgdasdService.consultarDeclaracoesPorPeriodo(
  cnpj: '00000000000000',
  periodoApuracao: '202401',
);
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Período inválido | Verificar formato do período (AAAAMM) |
| 004 | Declaração não encontrada | Verificar se declaração existe |
| 005 | DAS não encontrado | Verificar se DAS existe |

## Exemplos Práticos

### Exemplo Completo - Entregar Declaração e Gerar DAS

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret', 
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );
  
  // 2. Criar serviço
  final pgdasdService = PgdasdService(apiClient);
  
  // 3. Preparar dados da declaração
  final declaracao = Declaracao(
    receitaBruta: 100000.0,
    receitaBrutaAcumulada: 100000.0,
    valorDevido: 1000.0,
    valorPago: 0.0,
    // ... outros campos obrigatórios
  );
  
  // 4. Entregar declaração
  try {
    final response = await pgdasdService.entregarDeclaracaoSimples(
      cnpj: '00000000000000',
      periodoApuracao: 202401,
      declaracao: declaracao,
      transmitir: true,
      compararValores: false,
    );
    
    if (response.sucesso) {
      print('Declaração entregue com sucesso!');
      print('Número da declaração: ${response.dados.numeroDeclaracao}');
      
      // 5. Gerar DAS
      final dasResponse = await pgdasdService.gerarDasSimples(
        cnpj: '00000000000000',
        periodoApuracao: '202401',
      );
      
      if (dasResponse.sucesso) {
        print('DAS gerado com sucesso!');
        print('Número do DAS: ${dasResponse.dados.numeroDas}');
      }
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// Períodos de teste
const periodoApuracao = 202401; // AAAAMM
const anoCalendario = '2024';

// Dados de declaração de teste
final declaracaoTeste = Declaracao(
  receitaBruta: 100000.0,
  receitaBrutaAcumulada: 100000.0,
  valorDevido: 1000.0,
  valorPago: 0.0,
  // ... outros campos obrigatórios
);
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Período**: Período de apuração deve estar no formato AAAAMM

## Suporte

Para dúvidas sobre o serviço PGDASD:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
