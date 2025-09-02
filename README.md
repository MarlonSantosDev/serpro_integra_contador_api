[![Pub Version](https://img.shields.io/pub/v/integra_contador_api.svg)](https://pub.dev/packages/integra_contador_api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Cliente Dart **100% pronto para produção** para a API Integra Contador do SERPRO. Esta biblioteca oferece uma interface completa, type-safe e robusta para integração com todos os serviços da API.

## 🚀 Características

- ✅ **100% Type-Safe**: Todos os modelos são tipados e validados
- ✅ **Pronto para Produção**: Inclui tratamento de erros, retry automático e timeouts
- ✅ **Fácil de Usar**: Interface intuitiva com métodos de conveniência
- ✅ **Testado**: Cobertura completa de testes unitários
- ✅ **Documentado**: Documentação completa com exemplos práticos
- ✅ **Flexível**: Configuração customizável para diferentes ambientes

## 📦 Instalação

### Opção 1: Usando pub.dev (Recomendado)

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  integra_contador_api: ^1.0.0
```

### Opção 2: Usando este repositório

```yaml
dependencies:
  integra_contador_api:
    git:
      url: https://github.com/MarlonSantosDev/serpro_integra_contador_api.git
      ref: main
```

### Opção 3: Local (Para desenvolvimento)

1. Clone este repositório
2. Copie a pasta `lib` para seu projeto
3. Adicione as dependências necessárias:

```yaml
dependencies:
  http: ^1.1.0
  meta: ^1.9.1
  json_annotation: ^4.8.1
```

## 🔧 Configuração Inicial

### 1. Importe a biblioteca

```dart
import 'package:integra_contador_api/integra_contador_api.dart';
```

### 2. Configure o serviço

```dart
final service = IntegraContadorServiceBuilder()
    .withJwtToken('SEU_TOKEN_JWT_AQUI')
    .withProcuradorToken('TOKEN_PROCURADOR_OPCIONAL') // Opcional
    .withTimeout(Duration(seconds: 30))
    .withMaxRetries(3)
    .build();
```

### 3. Use o serviço

```dart
final result = await service.consultarSituacaoFiscal(
  documento: '12345678901',
  anoBase: '2024',
);

if (result.isSuccess) {
  print('Situação: ${result.data?.situacaoFiscal}');
} else {
  print('Erro: ${result.error?.message}');
}
```

## 🧪 Ambiente de Demonstração (Trial)

A API Integra Contador oferece um ambiente de demonstração (trial) para testes. Este ambiente permite testar as funcionalidades da API sem a necessidade de um token JWT real.

### Configurando o ambiente de demonstração

#### Método 1: Usando o Factory (Recomendado)

```dart
// Cria um serviço configurado para o ambiente de demonstração
final service = IntegraContadorFactory.createTrialService();

// A chave de teste padrão já está configurada, mas você pode especificar outra se necessário
final serviceCustom = IntegraContadorFactory.createTrialService(
  jwtToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
);
```

#### Método 2: Usando o Builder com método específico

```dart
final service = IntegraContadorBuilder()
    .withJwtToken('06aef429-a981-3ec5-a1f8-71d38d86481e')
    .forTrialEnvironment() // Configura automaticamente a URL e headers para o ambiente de demonstração
    .build();
```

#### Método 3: Configuração manual

```dart
final service = IntegraContadorBuilder()
    .withJwtToken('06aef429-a981-3ec5-a1f8-71d38d86481e')
    .withBaseUrl('https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1')
    .withCustomHeaders({'X-Environment': 'trial'})
    .build();
```

### Exemplos de uso do ambiente de demonstração

Consulte o arquivo `example/example_trial.dart` para exemplos completos de uso do ambiente de demonstração.

```dart
// Exemplo de consulta de declarações PGDASD
final result = await service.consultarDeclaracoesSN(
  documento: '00000000000000',
  anoCalendario: '2018',
);

// Exemplo de geração de DAS
final result = await service.gerarDASSN(
  documento: '00000000000100',
  periodoApuracao: '201801',
);
```

## 📚 Guia de Uso

### 🔍 Consultas

#### Consulta de Situação Fiscal

```dart
// Para pessoa física (CPF)
final resultPF = await service.consultarSituacaoFiscal(
  documento: '12345678901',
  anoBase: '2024',
  incluirDebitos: true,
  incluirCertidoes: true,
);

// Para pessoa jurídica (CNPJ)
final resultPJ = await service.consultarSituacaoFiscal(
  documento: '12345678901234',
  anoBase: '2024',
);
```

#### Consulta de Dados de Empresa

```dart
final result = await service.consultarDadosEmpresa(
  cnpj: '12345678901234',
  incluirSocios: true,
  incluirAtividades: true,
  incluirEndereco: true,
);
```

### 📝 Declarações

#### Envio de Declaração IRPF

```dart
final result = await service.enviarDeclaracaoIRPF(
  cpf: '12345678901',
  anoCalendario: '2024',
  tipoDeclaracao: 'completa',
  arquivoDeclaracao: 'base64_encoded_file_content',
  hashArquivo: 'sha256_hash_do_arquivo',
);
```

### 💰 Emissões

#### Emissão de DARF

```dart
final result = await service.emitirDARF(
  documento: '12345678901234',
  codigoReceita: '0220',
  periodoApuracao: '012024',
  valorPrincipal: '1500.00',
  valorMulta: '75.00',
  valorJuros: '25.50',
  dataVencimento: DateTime(2024, 2, 20),
);
```

### 🔄 Monitoramento

```dart
final result = await service.monitorarProcessamento(
  documento: '12345678901',
  numeroProtocolo: '2024123456789',
  tipoOperacao: 'declaracao_irpf',
);
```

### 🔐 Validação de Certificado

```dart
final result = await service.validarCertificado(
  certificadoBase64: 'base64_encoded_certificate',
  senha: 'senha_do_certificado',
  validarCadeia: true,
);
```

## 🛠️ Configurações Avançadas

### Configuração de Timeout e Retries

```dart
final service = IntegraContadorServiceBuilder()
    .withJwtToken('SEU_TOKEN_JWT_AQUI')
    .withTimeout(Duration(seconds: 60))
    .withMaxRetries(5)
    .withRetryDelay(Duration(seconds: 3))
    .build();
```

### Headers Customizados

```dart
final service = IntegraContadorServiceBuilder()
    .withJwtToken('SEU_TOKEN_JWT_AQUI')
    .withCustomHeaders({
      'X-Custom-Header': 'valor',
      'X-Application-Name': 'MeuApp',
    })
    .build();
```

### Cliente HTTP Customizado

```dart
import 'package:http/http.dart' as http;

final client = http.Client();
// Configure o cliente conforme necessário

final service = IntegraContadorServiceBuilder()
    .withJwtToken('SEU_TOKEN_JWT_AQUI')
    .withHttpClient(client)
    .build();
```

### Ambientes Específicos

```dart
// Ambiente de desenvolvimento
final devService = IntegraContadorFactory.createDevelopmentService(
  jwtToken: 'SEU_TOKEN_JWT_AQUI',
);

// Ambiente de produção
final prodService = IntegraContadorFactory.createProductionService(
  jwtToken: 'SEU_TOKEN_JWT_AQUI',
);

// Ambiente de teste
final testService = IntegraContadorFactory.createTestService(
  jwtToken: 'SEU_TOKEN_JWT_AQUI',
);

// Ambiente de demonstração (trial)
final trialService = IntegraContadorFactory.createTrialService();
```

## 🧩 Serviços Disponíveis

Esta biblioteca oferece suporte a todos os 84 serviços da API Integra Contador, organizados em categorias:

### Simples Nacional (PGDASD)
- Entregar declaração mensal
- Gerar DAS
- Consultar declarações transmitidas
- Consultar última declaração/recibo
- Consultar declaração/recibo específico
- Consultar extrato do DAS
- Gerar DAS de cobrança
- Gerar DAS de processo
- Gerar DAS avulso

### DEFIS
- Transmitir declaração
- Consultar declarações
- Consultar última declaração/recibo
- Consultar declaração/recibo específico

### MEI
- Gerar DAS
- Gerar DAS com código de barras
- Atualizar benefício
- Consultar dívida ativa
- Emitir CCMEI
- Consultar dados CCMEI
- Consultar situação cadastral CCMEI

### DCTFWeb
- Gerar guia
- Consultar recibo
- Consultar declaração completa
- Consultar XML da declaração
- Entregar declaração
- Gerar guia em andamento

### MIT
- Encerrar apuração
- Consultar situação de encerramento
- Consultar apuração
- Consultar apuração por ano/mês

### Outros Sistemas
- Procurações
- Sicalc
- Caixa Postal
- DTE
- PagtoWeb
- Autenticação de Procurador
- Eventos de Atualização
- SITFIS
- Parcelamentos

## 📊 Exemplos Completos

Consulte a pasta `example` para exemplos completos de uso da biblioteca:

- `example.dart`: Exemplo básico com as principais funcionalidades
- `example_extended.dart`: Exemplo completo com todas as 84 funcionalidades
- `example_trial.dart`: Exemplo de uso do ambiente de demonstração

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

