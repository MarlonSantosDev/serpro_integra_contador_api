# CCMEI - Certificado da Condição de Microempreendedor Individual

## Visão Geral

O serviço CCMEI permite emitir e consultar certificados da condição de Microempreendedor Individual (MEI), incluindo consulta de dados do MEI e verificação de situação cadastral.

## Funcionalidades

- **Emitir CCMEI**: Emissão de certificado da condição de MEI
- **Consultar Dados CCMEI**: Consulta de dados do MEI
- **Consultar Situação Cadastral**: Verificação da situação cadastral do MEI

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço CCMEI

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
final ccmeiService = CcmeiService(apiClient);
```

### 2. Emitir CCMEI

```dart
try {
  final response = await ccmeiService.emitirCcmei('00000000000000');
  
  if (response.sucesso) {
    print('CCMEI emitido com sucesso!');
    print('Número do certificado: ${response.dados.numeroCertificado}');
    print('Data de emissão: ${response.dados.dataEmissao}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao emitir CCMEI: $e');
}
```

### 3. Consultar Dados CCMEI

```dart
try {
  final response = await ccmeiService.consultarDadosCcmei('00000000000000');
  
  if (response.sucesso) {
    print('Dados do MEI encontrados!');
    print('Nome: ${response.dados.nome}');
    print('CNPJ: ${response.dados.cnpj}');
    print('Situação: ${response.dados.situacao}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar dados: $e');
}
```

### 4. Consultar Situação Cadastral

```dart
try {
  final response = await ccmeiService.consultarSituacaoCadastral('00000000000');
  
  if (response.sucesso) {
    print('Situação cadastral encontrada!');
    print('CPF: ${response.dados.cpf}');
    print('Situação: ${response.dados.situacao}');
    print('Data de cadastro: ${response.dados.dataCadastro}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar situação: $e');
}
```

## Estrutura de Dados

### EmitirCcmeiResponse

```dart
class EmitirCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final EmitirCcmeiDados? dados;
}

class EmitirCcmeiDados {
  final String numeroCertificado;
  final String dataEmissao;
  final String? pdfBase64;
  // ... outros campos
}
```

### ConsultarDadosCcmeiResponse

```dart
class ConsultarDadosCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarDadosCcmeiDados? dados;
}

class ConsultarDadosCcmeiDados {
  final String nome;
  final String cnpj;
  final String situacao;
  final String? dataCadastro;
  // ... outros campos
}
```

### ConsultarSituacaoCadastralCcmeiResponse

```dart
class ConsultarSituacaoCadastralCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarSituacaoCadastralCcmeiDados? dados;
}

class ConsultarSituacaoCadastralCcmeiDados {
  final String cpf;
  final String situacao;
  final String? dataCadastro;
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | CPF inválido | Verificar formato do CPF |
| 004 | MEI não encontrado | Verificar se MEI está cadastrado |
| 005 | Situação inválida | Verificar situação do MEI |

## Exemplos Práticos

### Exemplo Completo - Emitir CCMEI

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
  final ccmeiService = CcmeiService(apiClient);
  
  // 3. Emitir CCMEI
  try {
    final response = await ccmeiService.emitirCcmei('00000000000000');
    
    if (response.sucesso) {
      print('CCMEI emitido com sucesso!');
      print('Número do certificado: ${response.dados?.numeroCertificado}');
      print('Data de emissão: ${response.dados?.dataEmissao}');
      
      // 4. Consultar dados do MEI
      final dadosResponse = await ccmeiService.consultarDadosCcmei('00000000000000');
      
      if (dadosResponse.sucesso) {
        print('Dados do MEI:');
        print('Nome: ${dadosResponse.dados?.nome}');
        print('CNPJ: ${dadosResponse.dados?.cnpj}');
        print('Situação: ${dadosResponse.dados?.situacao}');
      }
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Consultar Situação Cadastral

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
  final ccmeiService = CcmeiService(apiClient);
  
  // 3. Consultar situação cadastral
  try {
    final response = await ccmeiService.consultarSituacaoCadastral('00000000000');
    
    if (response.sucesso) {
      print('Situação cadastral encontrada!');
      print('CPF: ${response.dados?.cpf}');
      print('Situação: ${response.dados?.situacao}');
      print('Data de cadastro: ${response.dados?.dataCadastro}');
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro ao consultar situação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// CPFs de teste (sempre usar zeros)
const cpfTeste = '00000000000';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **MEI Ativo**: MEI deve estar ativo para emissão do certificado

## Suporte

Para dúvidas sobre o serviço CCMEI:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
