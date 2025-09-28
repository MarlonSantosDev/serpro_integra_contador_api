# PGMEI - Programa Gerador do DAS do MEI

## Visão Geral

O serviço PGMEI permite gerar DAS (Documento de Arrecadação do Simples Nacional) para Microempreendedores Individuais (MEI), incluindo geração de DAS em PDF e código de barras, atualização de benefícios e consulta de dívida ativa.

## Funcionalidades

- **Gerar DAS PDF**: Geração de DAS em formato PDF
- **Gerar DAS Código de Barras**: Geração de DAS com código de barras
- **Atualizar Benefício**: Atualização de benefícios do MEI
- **Consultar Dívida Ativa**: Consulta de dívida ativa do MEI

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PGMEI

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
final pgmeiService = PgmeiService(apiClient);
```

### 2. Gerar DAS PDF

```dart
try {
  final response = await pgmeiService.gerarDas('00000000000000', '202401');
  
  if (response.sucesso) {
    print('DAS gerado com sucesso!');
    print('Número do DAS: ${response.dados.numeroDas}');
    print('Valor: ${response.dados.valor}');
    print('Data de vencimento: ${response.dados.dataVencimento}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS: $e');
}
```

### 3. Gerar DAS com Código de Barras

```dart
try {
  final response = await pgmeiService.gerarDasCodigoDeBarras('00000000000000', '202401');
  
  if (response.sucesso) {
    print('DAS com código de barras gerado com sucesso!');
    print('Número do DAS: ${response.dados.numeroDas}');
    print('Código de barras: ${response.dados.codigoBarras}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS com código de barras: $e');
}
```

### 4. Atualizar Benefício

```dart
try {
  final response = await pgmeiService.AtualizarBeneficio('00000000000000', '202401');
  
  if (response.sucesso) {
    print('Benefício atualizado com sucesso!');
    print('Status: ${response.dados.status}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao atualizar benefício: $e');
}
```

### 5. Consultar Dívida Ativa

```dart
try {
  final response = await pgmeiService.ConsultarDividaAtiva('00000000000000', '2024');
  
  if (response.sucesso) {
    print('Dívida ativa consultada com sucesso!');
    print('Valor total: ${response.dados.valorTotal}');
    print('Quantidade de débitos: ${response.dados.quantidadeDebitos}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar dívida ativa: $e');
}
```

## Estrutura de Dados

### GerarDasResponse

```dart
class GerarDasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final GerarDasDados? dados;
}

class GerarDasDados {
  final String numeroDas;
  final double valor;
  final String dataVencimento;
  final String? pdfBase64;
  final String? codigoBarras;
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Período inválido | Verificar formato do período (AAAAMM) |
| 004 | MEI não encontrado | Verificar se MEI está cadastrado |
| 005 | DAS não disponível | Verificar se DAS está disponível para o período |

## Exemplos Práticos

### Exemplo Completo - Gerar DAS

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
  final pgmeiService = PgmeiService(apiClient);
  
  // 3. Gerar DAS PDF
  try {
    final response = await pgmeiService.gerarDas('00000000000000', '202401');
    
    if (response.sucesso) {
      print('DAS gerado com sucesso!');
      print('Número do DAS: ${response.dados?.numeroDas}');
      print('Valor: ${response.dados?.valor}');
      print('Data de vencimento: ${response.dados?.dataVencimento}');
      
      // 4. Gerar DAS com código de barras
      final codigoBarrasResponse = await pgmeiService.gerarDasCodigoDeBarras('00000000000000', '202401');
      
      if (codigoBarrasResponse.sucesso) {
        print('DAS com código de barras gerado!');
        print('Código de barras: ${codigoBarrasResponse.dados?.codigoBarras}');
      }
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Consultar Dívida Ativa

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
  final pgmeiService = PgmeiService(apiClient);
  
  // 3. Consultar dívida ativa
  try {
    final response = await pgmeiService.ConsultarDividaAtiva('00000000000000', '2024');
    
    if (response.sucesso) {
      print('Dívida ativa consultada com sucesso!');
      print('Valor total: ${response.dados?.valorTotal}');
      print('Quantidade de débitos: ${response.dados?.quantidadeDebitos}');
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro ao consultar dívida ativa: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// Períodos de teste
const periodoApuracao = '202401'; // AAAAMM
const anoCalendario = '2024';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **MEI Ativo**: MEI deve estar ativo para geração do DAS

## Suporte

Para dúvidas sobre o serviço PGMEI:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
