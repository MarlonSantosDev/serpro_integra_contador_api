# 📋 API Integra Contador - Cliente Dart

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
  documento: '12345678000195',
  anoBase: '2024',
);

if (resultPF.isSuccess) {
  print('Situação Fiscal: ${resultPF.data?.situacaoFiscal}');
  print('Débitos Pendentes: ${resultPF.data?.debitosPendentes}');
}
```

#### Consulta de Dados de Empresa

```dart
final result = await service.consultarDadosEmpresa(
  cnpj: '12345678000195',
  incluirSocios: true,
  incluirAtividades: true,
  incluirEndereco: true,
);

if (result.isSuccess) {
  print('Razão Social: ${result.data?.razaoSocial}');
  
  final dados = result.data?.dados;
  print('Situação: ${dados?['situacao']}');
  print('Data Abertura: ${dados?['data_abertura']}');
}
```

### 📄 Declarações

#### Envio de Declaração IRPF

```dart
final result = await service.enviarDeclaracaoIRPF(
  cpf: '12345678901',
  anoCalendario: '2024',
  tipoDeclaracao: 'completa',
  arquivoDeclaracao: 'base64_encoded_file_content',
  hashArquivo: 'sha256_hash_do_arquivo',
);

if (result.isSuccess) {
  print('Recibo: ${result.data?.numeroRecibo}');
  print('Status: ${result.data?.dados?['situacao']}');
}
```

### 💰 Emissões

#### Emissão de DARF

```dart
final result = await service.emitirDARF(
  documento: '12345678000195',
  codigoReceita: '0220',
  periodoApuracao: '012024',
  valorPrincipal: '1500.00',
  valorMulta: '75.00',
  valorJuros: '25.50',
  dataVencimento: DateTime(2024, 2, 20),
);

if (result.isSuccess) {
  print('Código de Barras: ${result.data?.codigoBarras}');
  print('Linha Digitável: ${result.data?.linhaDigitavel}');
  print('Valor Total: R\$ ${result.data?.valorTotal}');
}
```

### 📊 Monitoramento

#### Acompanhar Processamento

```dart
final result = await service.monitorarProcessamento(
  documento: '12345678901',
  numeroProtocolo: '2024123456789',
  tipoOperacao: 'declaracao_irpf',
);

if (result.isSuccess) {
  final dados = result.data?.dados;
  print('Status: ${dados?['status']}');
  print('Progresso: ${result.data?.percentualConcluido}%');
  
  if (dados?['status'] == 'concluido') {
    print('Resultado: ${result.data?.resultadoFinal}');
  }
}
```

### 🔐 Validação de Certificado

```dart
final result = await service.validarCertificado(
  certificadoBase64: 'base64_encoded_certificate',
  senha: 'senha_do_certificado',
  validarCadeia: true,
);

if (result.isSuccess) {
  final dados = result.data?.dados;
  print('Válido: ${dados?['certificado_valido']}');
  print('Titular: ${dados?['titular']}');
  print('Expira em: ${dados?['data_expiracao']}');
}
```

## ⚙️ Configuração Avançada

### Configuração Personalizada

```dart
final config = ApiConfig(
  baseUrl: 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1',
  timeout: Duration(seconds: 60),
  maxRetries: 5,
  retryDelay: Duration(seconds: 3),
  customHeaders: {
    'X-Custom-Header': 'valor',
  },
);

final service = IntegraContadorServiceBuilder()
    .withJwtToken('seu_token')
    .withConfig(config)
    .build();
```

### Cliente HTTP Customizado

```dart
import 'package:http/http.dart' as http;

final customClient = http.Client();

final service = IntegraContadorServiceBuilder()
    .withJwtToken('seu_token')
    .withHttpClient(customClient)
    .build();
```

## 🛡️ Tratamento de Erros

A biblioteca oferece tratamento robusto de erros com tipos específicos:

```dart
final result = await service.consultarSituacaoFiscal(
  documento: 'cpf_invalido',
  anoBase: '2024',
);

if (result.isFailure) {
  final error = result.error!;
  
  if (error is ValidationException) {
    print('Erro de validação: ${error.message}');
    // Tratar campos com erro
    error.fieldErrors?.forEach((field, errors) {
      print('$field: ${errors.join(', ')}');
    });
  } else if (error is AuthenticationException) {
    print('Token expirado ou inválido');
    // Renovar token
  } else if (error is NetworkException) {
    print('Problema de conectividade');
    // Tentar novamente mais tarde
  } else if (error is RateLimitException) {
    print('Muitas requisições');
    // Aguardar ${error.retryAfter} segundos
  }
}
```

### Tipos de Exceção

| Exceção | Descrição | Código HTTP |
|---------|-----------|-------------|
| `ValidationException` | Dados inválidos | 400 |
| `AuthenticationException` | Token inválido/expirado | 401 |
| `AuthorizationException` | Sem permissão | 403 |
| `NotFoundException` | Recurso não encontrado | 404 |
| `RateLimitException` | Limite de requisições | 429 |
| `ServerException` | Erro do servidor | 5xx |
| `NetworkException` | Problema de rede | - |
| `TimeoutException` | Timeout da requisição | - |

## 🔄 Transformação de Dados

Use o método `map` para transformar os resultados:

```dart
final result = await service.consultarSituacaoFiscal(
  documento: '12345678901',
  anoBase: '2024',
);

final transformedResult = result.map((dados) => {
  'documento': '12345678901',
  'situacao': dados.situacaoFiscal ?? 'Desconhecida',
  'regular': dados.situacaoFiscal == 'regular',
  'consultadoEm': DateTime.now().toIso8601String(),
});

if (transformedResult.isSuccess) {
  print('Dados transformados: ${transformedResult.data}');
}
```

## 🔄 Processamento Assíncrono

Para processar múltiplas requisições em paralelo:

```dart
final documentos = ['12345678901', '12345678000195'];

final futures = documentos.map((doc) => 
  service.consultarSituacaoFiscal(documento: doc, anoBase: '2024')
);

final results = await Future.wait(futures);

for (int i = 0; i < documentos.length; i++) {
  final doc = documentos[i];
  final result = results[i];
  
  if (result.isSuccess) {
    print('$doc: ${result.data?.situacaoFiscal}');
  } else {
    print('$doc: Erro - ${result.error?.message}');
  }
}
```

## 🧪 Testes

### Executar Testes

```bash
dart test
```

### Exemplo de Teste

```dart
import 'package:test/test.dart';
import 'package:integra_contador_api/integra_contador_api.dart';

void main() {
  group('Identificacao', () {
    test('deve validar CPF correto', () {
      final id = Identificacao.cpf('11144477735');
      expect(id.isValid, isTrue);
    });
    
    test('deve formatar CPF corretamente', () {
      final id = Identificacao.cpf('12345678901');
      expect(id.numeroFormatado, equals('123.456.789-01'));
    });
  });
}
```

## 📁 Estrutura do Projeto

```
integra_contador_dart/
├── lib/
│   ├── models/                 # Modelos de dados
│   │   ├── dados_entrada.dart
│   │   ├── dados_saida.dart
│   │   ├── identificacao.dart
│   │   ├── pedido_dados.dart
│   │   ├── problem_details.dart
│   │   └── tipo_ni.dart
│   ├── services/               # Serviços
│   │   └── integra_contador_service.dart
│   ├── exceptions/             # Exceções customizadas
│   │   └── api_exception.dart
│   └── integra_contador_api.dart # Arquivo principal
├── test/                       # Testes
├── example/                    # Exemplos de uso
├── pubspec.yaml               # Dependências
└── README.md                  # Esta documentação
```

## 🔒 Segurança

### Boas Práticas

1. **Nunca hardcode tokens**:
```dart
// ❌ Não faça isso
final service = IntegraContadorServiceBuilder()
    .withJwtToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...')
    .build();

// ✅ Faça isso
final token = Platform.environment['INTEGRA_CONTADOR_JWT_TOKEN']!;
final service = IntegraContadorServiceBuilder()
    .withJwtToken(token)
    .build();
```

2. **Valide dados antes de enviar**:
```dart
final identificacao = Identificacao.cpf(cpf);
if (!identificacao.isValid) {
  throw ValidationException('CPF inválido');
}
```

3. **Use HTTPS sempre**:
```dart
final config = ApiConfig(
  baseUrl: 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1',
  // Nunca use HTTP em produção
);
```

## 🚀 Deploy em Produção

### Flutter

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:integra_contador_api/integra_contador_api.dart';

class IntegraContadorProvider {
  static IntegraContadorService? _instance;
  
  static IntegraContadorService get instance {
    _instance ??= IntegraContadorServiceBuilder()
        .withJwtToken(const String.fromEnvironment('JWT_TOKEN'))
        .withTimeout(const Duration(seconds: 30))
        .build();
    return _instance!;
  }
}

// Uso em widgets
class ConsultaWidget extends StatefulWidget {
  @override
  _ConsultaWidgetState createState() => _ConsultaWidgetState();
}

class _ConsultaWidgetState extends State<ConsultaWidget> {
  Future<void> _consultar() async {
    final service = IntegraContadorProvider.instance;
    
    final result = await service.consultarSituacaoFiscal(
      documento: '12345678901',
      anoBase: '2024',
    );
    
    if (result.isSuccess) {
      // Atualizar UI com sucesso
    } else {
      // Mostrar erro para usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error?.message ?? 'Erro desconhecido')),
      );
    }
  }
  
  // ... resto do widget
}
```

### Dart Server

```dart
// server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:integra_contador_api/integra_contador_api.dart';

void main() async {
  final service = IntegraContadorServiceBuilder()
      .withJwtToken(Platform.environment['JWT_TOKEN']!)
      .build();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) async {
        if (request.url.path == 'consulta') {
          final cpf = request.url.queryParameters['cpf'];
          final ano = request.url.queryParameters['ano'];
          
          if (cpf == null || ano == null) {
            return Response.badRequest(body: 'CPF e ano são obrigatórios');
          }
          
          final result = await service.consultarSituacaoFiscal(
            documento: cpf,
            anoBase: ano,
          );
          
          if (result.isSuccess) {
            return Response.ok(jsonEncode(result.data?.toJson()));
          } else {
            return Response.internalServerError(
              body: result.error?.message,
            );
          }
        }
        
        return Response.notFound('Endpoint não encontrado');
      });

  final server = await serve(handler, 'localhost', 8080);
  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- 📧 Email: seu-email@exemplo.com
- 🐛 Issues: [GitHub Issues](https://github.com/MarlonSantosDev/serpro_integra_contador_api/issues)
- 📖 Documentação: [Wiki](https://github.com/MarlonSantosDev/serpro_integra_contador_api/wiki)

---

**Desenvolvido com ❤️ para a comunidade Dart/Flutter**

