# AutenticaProcurador Service

## Visão Geral

O `AutenticaProcuradorService` é responsável por gerenciar a autenticação de procuradores junto aos sistemas da Receita Federal. Este serviço permite criar termos de autorização, assinar digitalmente documentos e obter tokens de autenticação para uso em outros serviços.

## Funcionalidades Principais

- **Criação de Termos de Autorização**: Cria termos de autorização com dados do contratante e autor do pedido
- **Assinatura Digital**: Assina termos digitalmente usando certificados ICP-Brasil
- **Autenticação de Procurador**: Autentica procuradores e obtém tokens de acesso
- **Gerenciamento de Cache**: Gerencia cache de tokens para otimizar performance
- **Validação de Certificados**: Valida certificados digitais ICP-Brasil

## Métodos Disponíveis

### 1. Criar Termo de Autorização

```dart
Future<TermoAutorizacaoRequest> criarTermoAutorizacao({
  required String contratanteNumero,
  required String contratanteNome,
  required String autorPedidoDadosNumero,
  required String autorPedidoDadosNome,
  String? dataAssinatura,
  String? dataVigencia,
  String? certificadoPath,
  String? certificadoPassword,
})
```

**Parâmetros:**
- `contratanteNumero`: CNPJ do contratante
- `contratanteNome`: Nome do contratante
- `autorPedidoDadosNumero`: CNPJ do autor do pedido
- `autorPedidoDadosNome`: Nome do autor do pedido
- `dataAssinatura`: Data de assinatura (opcional, padrão: data atual)
- `dataVigencia`: Data de vigência (opcional, padrão: 1 ano)
- `certificadoPath`: Caminho do certificado digital (opcional)
- `certificadoPassword`: Senha do certificado (opcional)

**Exemplo:**
```dart
final termo = await autenticaProcuradorService.criarTermoAutorizacao(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
  certificadoPath: '/path/to/certificate.p12',
  certificadoPassword: 'senha123',
);
```

### 2. Criar Termo com Data Atual

```dart
Future<TermoAutorizacaoRequest> criarTermoComDataAtual({
  required String contratanteNumero,
  required String contratanteNome,
  required String autorPedidoDadosNumero,
  required String autorPedidoDadosNome,
  String? certificadoPath,
  String? certificadoPassword,
})
```

**Exemplo:**
```dart
final termo = await autenticaProcuradorService.criarTermoComDataAtual(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
);
```

### 3. Assinar Termo Digitalmente

```dart
Future<String> assinarTermoDigital(TermoAutorizacaoRequest termo)
```

**Exemplo:**
```dart
final xmlAssinado = await autenticaProcuradorService.assinarTermoDigital(termo);
print('XML assinado: $xmlAssinado');
```

### 4. Autenticar Procurador

```dart
Future<TermoAutorizacaoResponse> autenticarProcurador({
  required String xmlAssinado,
  required String contratanteNumero,
  required String autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await autenticaProcuradorService.autenticarProcurador(
  xmlAssinado: xmlAssinado,
  contratanteNumero: '12345678000195',
  autorPedidoDadosNumero: '98765432000100',
);

if (response.sucesso) {
  print('Token obtido: ${response.autenticarProcuradorToken}');
}
```

### 5. Verificar Cache de Token

```dart
Future<CacheModel?> verificarCacheToken({
  required String contratanteNumero,
  required String autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final cache = await autenticaProcuradorService.verificarCacheToken(
  contratanteNumero: '12345678000195',
  autorPedidoDadosNumero: '98765432000100',
);

if (cache != null && cache.isTokenValido) {
  print('Token válido encontrado: ${cache.token}');
}
```

### 6. Renovar Token

```dart
Future<TermoAutorizacaoResponse> renovarToken({
  required String contratanteNumero,
  required String contratanteNome,
  required String autorPedidoDadosNumero,
  required String autorPedidoDadosNome,
  String? certificadoPath,
  String? certificadoPassword,
})
```

**Exemplo:**
```dart
final response = await autenticaProcuradorService.renovarToken(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
);
```

### 7. Obter Token Válido

```dart
Future<String> obterTokenValido({
  required String contratanteNumero,
  required String contratanteNome,
  required String autorPedidoDadosNumero,
  required String autorPedidoDadosNome,
  String? certificadoPath,
  String? certificadoPassword,
})
```

**Exemplo:**
```dart
final token = await autenticaProcuradorService.obterTokenValido(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
);
```

### 8. Gerenciamento de Cache

```dart
// Limpar cache
Future<void> limparCache()

// Remover caches expirados
Future<int> removerCachesExpirados()

// Obter estatísticas do cache
Future<Map<String, dynamic>> obterEstatisticasCache()
```

**Exemplo:**
```dart
// Limpar todo o cache
await autenticaProcuradorService.limparCache();

// Remover apenas caches expirados
final removidos = await autenticaProcuradorService.removerCachesExpirados();
print('Caches expirados removidos: $removidos');

// Obter estatísticas
final stats = await autenticaProcuradorService.obterEstatisticasCache();
print('Estatísticas: $stats');
```

### 9. Validações

```dart
// Validar termo de autorização
Future<List<String>> validarTermoAutorizacao(String xml)

// Validar assinatura digital
Future<Map<String, dynamic>> validarAssinaturaDigital(String xmlAssinado)

// Obter informações do certificado
Future<Map<String, dynamic>> obterInfoCertificado({
  required String certificadoPath,
  required String senha,
})
```

**Exemplo:**
```dart
// Validar termo
final erros = await autenticaProcuradorService.validarTermoAutorizacao(xml);
if (erros.isNotEmpty) {
  print('Erros encontrados: ${erros.join(', ')}');
}

// Validar assinatura
final validacao = await autenticaProcuradorService.validarAssinaturaDigital(xmlAssinado);
print('Assinatura válida: ${validacao['assinatura_valida']}');

// Obter info do certificado
final info = await autenticaProcuradorService.obterInfoCertificado(
  certificadoPath: '/path/to/certificate.p12',
  senha: 'senha123',
);
print('Certificado: ${info['subject']}');
```

## Fluxo Completo de Autenticação

```dart
// 1. Criar termo de autorização
final termo = await autenticaProcuradorService.criarTermoComDataAtual(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
  certificadoPath: '/path/to/certificate.p12',
  certificadoPassword: 'senha123',
);

// 2. Assinar termo digitalmente
final xmlAssinado = await autenticaProcuradorService.assinarTermoDigital(termo);

// 3. Autenticar procurador
final response = await autenticaProcuradorService.autenticarProcurador(
  xmlAssinado: xmlAssinado,
  contratanteNumero: '12345678000195',
  autorPedidoDadosNumero: '98765432000100',
);

if (response.sucesso) {
  print('Autenticação realizada com sucesso!');
  print('Token: ${response.autenticarProcuradorToken}');
} else {
  print('Erro na autenticação: ${response.mensagemPrincipal}');
}
```

## Tratamento de Erros

O serviço possui tratamento robusto de erros com validações específicas:

- **Validação de Certificados**: Verifica se o certificado é válido ICP-Brasil
- **Validação de XML**: Verifica estrutura do XML do termo
- **Validação de Assinatura**: Verifica integridade da assinatura digital
- **Tratamento de Cache**: Gerencia erros de cache graciosamente

## Configurações

### Certificados Digitais

O serviço suporta certificados ICP-Brasil nos formatos:
- **A1**: Arquivo .p12/.pfx
- **A3**: Token/cartão inteligente

### Algoritmos de Assinatura

- **Algoritmo de Assinatura**: RSA-SHA256
- **Algoritmo de Hash**: SHA-256
- **Canonicalização**: XML-C14N

## Limitações

- Certificados devem ser válidos ICP-Brasil
- Termos têm validade máxima de 1 ano
- Cache de tokens tem TTL configurável
- Assinatura simulada apenas para demonstração

## Exemplo de Uso Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient(
    baseUrl: 'https://apigateway.serpro.gov.br/integra-contador-trial/v1',
    clientId: 'seu_client_id',
    clientSecret: 'seu_client_secret',
  );

  // Criar serviço
  final autenticaProcuradorService = AutenticaProcuradorService(apiClient);

  try {
    // Verificar cache primeiro
    final cache = await autenticaProcuradorService.verificarCacheToken(
      contratanteNumero: '12345678000195',
      autorPedidoDadosNumero: '98765432000100',
    );

    String token;
    if (cache != null && cache.isTokenValido) {
      token = cache.token;
      print('Token obtido do cache');
    } else {
      // Obter novo token
      token = await autenticaProcuradorService.obterTokenValido(
        contratanteNumero: '12345678000195',
        contratanteNome: 'Empresa Exemplo LTDA',
        autorPedidoDadosNumero: '98765432000100',
        autorPedidoDadosNome: 'Contador Exemplo',
        certificadoPath: '/path/to/certificate.p12',
        certificadoPassword: 'senha123',
      );
      print('Novo token obtido');
    }

    print('Token válido: $token');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Códigos de Erro Comuns

- **CERTIFICADO_INVALIDO**: Certificado digital inválido
- **XML_INVALIDO**: Estrutura XML do termo inválida
- **ASSINATURA_INVALIDA**: Assinatura digital inválida
- **TOKEN_EXPIRADO**: Token de autenticação expirado
- **CACHE_ERROR**: Erro no gerenciamento de cache
