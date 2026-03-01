# PGMEI - Programa Gerador do DAS para o MEI

## Visão Geral

O serviço PGMEI permite gerar e consultar o DAS (Documento de Arrecadação do Simples Nacional) para contribuintes Microempreendedores Individuais (MEI), incluindo geração com PDF completo, geração apenas com código de barras, atualização de benefícios e consulta de dívida ativa.

## Funcionalidades

- **Gerar DAS com PDF** (`GERARDASPDF21`): Gera o DAS com PDF completo para contribuintes MEI
- **Gerar DAS com Código de Barras** (`GERARDASCODBARRA22`): Gera o DAS apenas com código de barras, sem PDF
- **Atualizar Benefício** (`ATUBENEFICIO23`): Registra benefício para determinada apuração do PGMEI
- **Consultar Dívida Ativa** (`DIVIDAATIVA24`): Consulta se o contribuinte está em dívida ativa
- **Atualizar Benefício Período Único** (conveniência): Wrapper simplificado para atualizar benefício de um único período

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
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret',
  certificadoDigitalPath: 'caminho/para/certificado.p12',
  senhaCertificado: 'senha_do_certificado',
  ambiente: 'trial', // ou 'producao'
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final pgmeiService = PgmeiService(apiClient);
```

### 2. Gerar DAS com PDF (GERARDASPDF21)

Gera o Documento de Arrecadação do Simples Nacional com PDF completo.

```dart
try {
  final response = await pgmeiService.gerarDas(
    cnpj: '12345678000190',
    periodoApuracao: '202403',
    // dataConsolidacao: '20240331', // Opcional, formato AAAAMMDD
  );

  if (response.sucesso) {
    print('DAS gerado com sucesso!');
    // Acessar dados do DAS gerado
    final dasGerados = response.dasGerados;
    if (dasGerados != null && dasGerados.isNotEmpty) {
      final das = dasGerados.first;
      print('PDF Base64: ${das.pdf}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte MEI (usa o do ApiClient se não fornecido) |
| `periodoApuracao` | `String` | Sim | Período no formato AAAAMM (ex: `'202403'`) |
| `dataConsolidacao` | `String?` | Não | Data de consolidação no formato AAAAMMDD |
| `contratanteNumero` | `String?` | Não | CNPJ da empresa contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Retorna:** `PgmeiGerarDasResponse`

### 3. Gerar DAS com Código de Barras (GERARDASCODBARRA22)

Gera o DAS contendo apenas código de barras, sem PDF, para contribuintes MEI.

```dart
try {
  final response = await pgmeiService.gerarDasCodigoBarras(
    cnpj: '12345678000190',
    periodoApuracao: '202403',
    // dataConsolidacao: '20240331', // Opcional
  );

  if (response.sucesso) {
    print('DAS com código de barras gerado!');
    // Acessar dados do código de barras
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS código de barras: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte MEI |
| `periodoApuracao` | `String` | Sim | Período no formato AAAAMM |
| `dataConsolidacao` | `String?` | Não | Data de consolidação no formato AAAAMMDD |
| `contratanteNumero` | `String?` | Não | CNPJ da empresa contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Retorna:** `GerarDasCodigoBarrasResponse`

### 4. Atualizar Benefício (ATUBENEFICIO23)

Registra benefício para determinada apuração do PGMEI.

```dart
try {
  final response = await pgmeiService.atualizarBeneficio(
    cnpj: '12345678000190',
    anoCalendario: 2024,
    beneficios: [
      InfoBeneficio(
        periodoApuracao: '202401',
        indicadorBeneficio: true,
      ),
      InfoBeneficio(
        periodoApuracao: '202402',
        indicadorBeneficio: false,
      ),
    ],
  );

  if (response.sucesso) {
    print('Benefício atualizado com sucesso!');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao atualizar benefício: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte MEI |
| `anoCalendario` | `int` | Sim | Ano calendário (formato AAAA, entre 1900-2099) |
| `beneficios` | `List<InfoBeneficio>` | Sim | Lista de benefícios por período |
| `contratanteNumero` | `String?` | Não | CNPJ da empresa contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Retorna:** `AtualizarBeneficioResponse`

### 5. Consultar Dívida Ativa (DIVIDAATIVA24)

Consulta se o contribuinte está em dívida ativa.

```dart
try {
  final response = await pgmeiService.consultarDividaAtiva(
    cnpj: '12345678000190',
    anoCalendario: '2024',
  );

  if (response.sucesso) {
    print('Consulta de dívida ativa realizada!');
    // Processar resultado
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar dívida ativa: $e');
}
```

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `cnpj` | `String?` | Não* | CNPJ do contribuinte MEI |
| `anoCalendario` | `String` | Sim | Ano calendário no formato AAAA |
| `contratanteNumero` | `String?` | Não | CNPJ da empresa contratante |
| `autorPedidoDadosNumero` | `String?` | Não | CPF/CNPJ do autor do pedido |

**Retorna:** `ConsultarDividaAtivaResponse`

### 6. Atualizar Benefício Período Único (Conveniência)

Wrapper simplificado para atualizar benefício de um único período.

```dart
try {
  final response = await pgmeiService.atualizarBeneficioPeriodoUnico(
    cnpj: '12345678000190',
    anoCalendario: 2024,
    periodoApuracao: '202403',
    indicadorBeneficio: true,
  );

  if (response.sucesso) {
    print('Benefício atualizado para período único!');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro: $e');
}
```

## Validações Internas

O serviço realiza as seguintes validações automaticamente:

- **CNPJ**: Validação de formato e dígitos verificadores via `ValidacoesUtils.validateCNPJ()`
- **Período de Apuração**: Validação de formato AAAAMM via `PgmeiValidations.validarPeriodoApuracao()`
- **Data de Consolidação**: Validação de formato AAAAMMDD via `PgmeiValidations.validarDataConsolidacao()`
- **Ano Calendário**: Deve estar entre 1900 e 2099
- **Lista de Benefícios**: Validação via `PgmeiValidations.validarInfoBeneficio()`

> **Nota:** Se o `cnpj` não for fornecido, será utilizado o `contribuinteNumero` do `ApiClient` (definido na autenticação). Se ambos forem nulos, será lançado um `ArgumentError`.

## Estrutura de Dados

### PgmeiGerarDasResponse

```dart
// Resposta da geração de DAS com PDF
class PgmeiGerarDasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final List<DasGerado>? dasGerados;
  // ... outros campos
}
```

### GerarDasCodigoBarrasResponse

```dart
// Resposta da geração de DAS com código de barras
class GerarDasCodigoBarrasResponse {
  final bool sucesso;
  final String? mensagemErro;
  // ... campos com dados do código de barras
}
```

### AtualizarBeneficioResponse

```dart
// Resposta da atualização de benefício
class AtualizarBeneficioResponse {
  final bool sucesso;
  final String? mensagemErro;
  // ... outros campos
}
```

### ConsultarDividaAtivaResponse

```dart
// Resposta da consulta de dívida ativa
class ConsultarDividaAtivaResponse {
  final bool sucesso;
  final String? mensagemErro;
  // ... campos com dados da dívida ativa
}
```

### InfoBeneficio (Request)

```dart
// Usado no método atualizarBeneficio
class InfoBeneficio {
  final String periodoApuracao;  // Formato AAAAMM
  final bool indicadorBeneficio; // true para ativar, false para desativar
}
```

## Exemplo Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certificadoDigitalPath: 'caminho/para/certificado.p12',
    senhaCertificado: 'senha_do_certificado',
    ambiente: 'trial',
  );
  
  // 2. Criar serviço
  final pgmeiService = PgmeiService(apiClient);
  
  try {
    const cnpj = '12345678000190';
    
    // 3. Gerar DAS com PDF
    print('=== Gerando DAS com PDF ===');
    final dasResponse = await pgmeiService.gerarDas(
      cnpj: cnpj,
      periodoApuracao: '202403',
    );
    
    if (dasResponse.sucesso) {
      print('DAS gerado com sucesso!');
      final dasGerados = dasResponse.dasGerados;
      if (dasGerados != null && dasGerados.isNotEmpty) {
        final das = dasGerados.first;
        print('PDF disponível: ${das.pdf?.isNotEmpty == true}');
      }
    }
    
    // 4. Gerar DAS com Código de Barras
    print('\n=== Gerando DAS com Código de Barras ===');
    final codBarraResponse = await pgmeiService.gerarDasCodigoBarras(
      cnpj: cnpj,
      periodoApuracao: '202403',
    );
    
    if (codBarraResponse.sucesso) {
      print('DAS com código de barras gerado!');
    }
    
    // 5. Atualizar Benefício
    print('\n=== Atualizando Benefício ===');
    final beneficioResponse = await pgmeiService.atualizarBeneficio(
      cnpj: cnpj,
      anoCalendario: 2024,
      beneficios: [
        InfoBeneficio(
          periodoApuracao: '202401',
          indicadorBeneficio: true,
        ),
      ],
    );
    
    if (beneficioResponse.sucesso) {
      print('Benefício atualizado!');
    }
    
    // 6. Consultar Dívida Ativa
    print('\n=== Consultando Dívida Ativa ===');
    final dividaResponse = await pgmeiService.consultarDividaAtiva(
      cnpj: cnpj,
      anoCalendario: '2024',
    );
    
    if (dividaResponse.sucesso) {
      print('Consulta de dívida ativa realizada!');
    }
    
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ (14 dígitos) |
| 003 | Período de apuração inválido | Verificar formato AAAAMM |
| 004 | Data de consolidação inválida | Verificar formato AAAAMMDD |
| 005 | Ano calendário inválido | Verificar se está entre 1900-2099 |

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJ de teste
const cnpjTeste = '12345678000190';

// Períodos de teste
const periodoTeste = '202403';

// Ano calendário de teste
const anoCalendarioTeste = 2024;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: CNPJ, período e dados de benefícios são validados automaticamente
4. **MEI**: Exclusivo para contribuintes Microempreendedores Individuais
5. **Ano Calendário**: Deve estar entre 1900 e 2099

## Integração com Outros Serviços

O PGMEI Service pode ser usado em conjunto com:

- **CCMEI Service**: Para consultar dados cadastrais do MEI antes de gerar DAS
- **PARCMEI Service**: Para consultar parcelamentos relacionados
- **Caixa Postal Service**: Para consultar mensagens sobre pagamentos
- **DTE Service**: Para verificar adesão ao Domicílio Tributário Eletrônico

## Suporte

Para dúvidas sobre o serviço PGMEI:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package