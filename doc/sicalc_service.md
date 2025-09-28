# SICALC - Sistema de Cálculos Tributários

## Visão Geral

O serviço SICALC permite gerar DARF (Documento de Arrecadação de Receitas Federais) com cálculos automáticos de multa e juros, consultar códigos de receita e gerar códigos de barras para DARFs calculados.

## Funcionalidades

- **Consolidar e Gerar DARF**: Cálculo automático de multa e juros com geração de DARF em PDF
- **Consultar Código de Receita**: Consulta de informações sobre códigos de receita
- **Gerar Código de Barras**: Geração de código de barras para DARF já calculado

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço SICALC

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
final sicalcService = SicalcService(apiClient);
```

### 2. Consolidar e Gerar DARF

```dart
try {
  final response = await sicalcService.consolidarEGerarDarf(
    contribuinteNumero: '00000000000000',
    uf: 'SP',
    municipio: 3550308, // São Paulo
    codigoReceita: 190,
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.0,
    dataConsolidacao: '20240215',
    observacao: 'DARF de teste',
  );
  
  if (response.sucesso) {
    print('DARF gerado com sucesso!');
    print('Número do documento: ${response.dados?.numeroDocumento}');
    print('Valor total: ${response.dados?.valorTotal}');
    print('PDF disponível: ${response.dados?.pdfBase64 != null}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DARF: $e');
}
```

### 3. Consultar Código de Receita

```dart
try {
  final response = await sicalcService.consultarCodigoReceita(
    contribuinteNumero: '00000000000000',
    codigoReceita: 190,
  );
  
  if (response.sucesso) {
    print('Código de receita encontrado!');
    print('Descrição: ${response.dados?.descricaoReceita}');
    print('Tipo de pessoa: ${response.dados?.tipoPessoaFormatado}');
    print('Período: ${response.dados?.tipoPeriodoFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar receita: $e');
}
```

### 4. Gerar Código de Barras

```dart
try {
  final response = await sicalcService.gerarCodigoBarrasDarf(
    contribuinteNumero: '00000000000000',
    numeroDocumento: 123456789,
  );
  
  if (response.sucesso) {
    print('Código de barras gerado com sucesso!');
    print('Código: ${response.dados?.codigoBarras}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar código de barras: $e');
}
```

## Métodos de Conveniência

### Gerar DARF para Pessoa Física (IRPF)

```dart
final response = await sicalcService.gerarDarfPessoaFisica(
  contribuinteNumero: '00000000000',
  uf: 'SP',
  municipio: 3550308,
  dataPA: '20240101',
  vencimento: '20240215',
  valorImposto: 1000.0,
  dataConsolidacao: '20240215',
  observacao: 'IRPF',
);
```

### Gerar DARF para Pessoa Jurídica (IRPJ)

```dart
final response = await sicalcService.gerarDarfPessoaJuridica(
  contribuinteNumero: '00000000000000',
  uf: 'SP',
  municipio: 3550308,
  dataPA: '20240101',
  vencimento: '20240215',
  valorImposto: 1000.0,
  dataConsolidacao: '20240215',
  observacao: 'IRPJ',
);
```

### Gerar DARF para PIS/PASEP

```dart
final response = await sicalcService.gerarDarfPisPasep(
  contribuinteNumero: '00000000000000',
  uf: 'SP',
  municipio: 3550308,
  dataPA: '20240101',
  vencimento: '20240215',
  valorImposto: 1000.0,
  dataConsolidacao: '20240215',
  observacao: 'PIS/PASEP',
);
```

### Gerar DARF para COFINS

```dart
final response = await sicalcService.gerarDarfCofins(
  contribuinteNumero: '00000000000000',
  uf: 'SP',
  municipio: 3550308,
  dataPA: '20240101',
  vencimento: '20240215',
  valorImposto: 1000.0,
  dataConsolidacao: '20240215',
  observacao: 'COFINS',
);
```

## Fluxo Completo - Gerar DARF e Código de Barras

```dart
try {
  // 1. Gerar DARF
  final darfResponse = await sicalcService.gerarDarfECodigoBarras(
    contribuinteNumero: '00000000000000',
    uf: 'SP',
    municipio: 3550308,
    codigoReceita: 190,
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.0,
    dataConsolidacao: '20240215',
    observacao: 'DARF completo',
  );
  
  if (darfResponse.sucesso) {
    print('DARF e código de barras gerados com sucesso!');
    print('Número do documento: ${darfResponse.dados?.numeroDocumento}');
    print('Código de barras: ${darfResponse.dados?.codigoBarras}');
  }
} catch (e) {
  print('Erro no fluxo completo: $e');
}
```

## Validações e Utilitários

### Validar Compatibilidade de Receita

```dart
final isCompatible = await sicalcService.validarCompatibilidadeReceita(
  contribuinteNumero: '00000000000000',
  codigoReceita: 190,
);

if (isCompatible) {
  print('Receita compatível com o contribuinte');
} else {
  print('Receita não compatível');
}
```

### Obter Informações Detalhadas da Receita

```dart
final info = await sicalcService.obterInfoReceita(
  contribuinteNumero: '00000000000000',
  codigoReceita: 190,
);

if (info != null) {
  print('Código: ${info['codigoReceita']}');
  print('Descrição: ${info['descricaoReceita']}');
  print('Tipo de pessoa: ${info['tipoPessoa']}');
  print('Período: ${info['tipoPeriodoApuracao']}');
  print('Ativa: ${info['ativa']}');
  print('Compatível: ${info['compativelComContribuinte']}');
}
```

## Estrutura de Dados

### ConsolidarDarfResponse

```dart
class ConsolidarDarfResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsolidarDarfDados? dados;
}

class ConsolidarDarfDados {
  final int numeroDocumento;
  final double valorTotal;
  final double valorImposto;
  final double valorMulta;
  final double valorJuros;
  final String? pdfBase64;
  // ... outros campos
}
```

### ConsultarReceitaResponse

```dart
class ConsultarReceitaResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarReceitaDados? dados;
}

class ConsultarReceitaDados {
  final int codigoReceita;
  final String descricaoReceita;
  final String tipoPessoaFormatado;
  final String tipoPeriodoFormatado;
  final String? observacoes;
  final bool ativa;
  // ... outros campos
}
```

## Códigos de Receita Comuns

| Código | Descrição | Tipo de Pessoa |
|--------|-----------|----------------|
| 190 | IRPF | Pessoa Física |
| 220 | IRPJ | Pessoa Jurídica |
| 1162 | PIS/PASEP | Pessoa Jurídica |
| 1163 | COFINS | Pessoa Jurídica |
| 1164 | CSLL | Pessoa Jurídica |

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ/CPF inválido | Verificar formato do documento |
| 003 | Código de receita inválido | Verificar se código existe |
| 004 | UF inválida | Verificar código da UF |
| 005 | Município inválido | Verificar código do município |

## Exemplos Práticos

### Exemplo Completo - Gerar DARF IRPF

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
  final sicalcService = SicalcService(apiClient);
  
  // 3. Consultar receita antes de gerar
  try {
    final receitaResponse = await sicalcService.consultarCodigoReceita(
      contribuinteNumero: '00000000000',
      codigoReceita: 190,
    );
    
    if (receitaResponse.sucesso) {
      print('Receita encontrada: ${receitaResponse.dados?.descricaoReceita}');
      
      // 4. Gerar DARF
      final darfResponse = await sicalcService.gerarDarfPessoaFisica(
        contribuinteNumero: '00000000000',
        uf: 'SP',
        municipio: 3550308,
        dataPA: '20240101',
        vencimento: '20240215',
        valorImposto: 1000.0,
        dataConsolidacao: '20240215',
        observacao: 'IRPF - Janeiro 2024',
      );
      
      if (darfResponse.sucesso) {
        print('DARF gerado com sucesso!');
        print('Número: ${darfResponse.dados?.numeroDocumento}');
        print('Valor total: ${darfResponse.dados?.valorTotal}');
        
        // 5. Gerar código de barras
        final codigoBarrasResponse = await sicalcService.gerarCodigoBarrasDarf(
          contribuinteNumero: '00000000000',
          numeroDocumento: darfResponse.dados!.numeroDocumento,
        );
        
        if (codigoBarrasResponse.sucesso) {
          print('Código de barras: ${codigoBarrasResponse.dados?.codigoBarras}');
        }
      } else {
        print('Erro ao gerar DARF: ${darfResponse.mensagemErro}');
      }
    } else {
      print('Erro ao consultar receita: ${receitaResponse.mensagemErro}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Dados de teste
const uf = 'SP';
const municipio = 3550308; // São Paulo
const codigoReceita = 190; // IRPF
const dataPA = '20240101';
const vencimento = '20240215';
const valorImposto = 1000.0;
const dataConsolidacao = '20240215';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Códigos de Receita**: Apenas códigos válidos são aceitos

## Suporte

Para dúvidas sobre o serviço SICALC:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
