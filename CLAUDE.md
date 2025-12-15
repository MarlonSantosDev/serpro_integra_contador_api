# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart/Flutter package providing comprehensive integration with Brazil's SERPRO Integra Contador API (Federal Revenue). The package offers 20+ services for tax operations, MEI management, payment processing, and electronic procurations with full mTLS authentication support.

**Key Characteristics:**
- Pure Dart with optional Flutter support
- Multi-platform: Android, iOS, Web, Desktop, Windows, Linux, macOS
- OAuth2 + mTLS + XML digital signature authentication
- 24 service modules following identical patterns
- Current version: 2.0.0

## Development Commands

### Package Management
```bash
# Install dependencies
dart pub get          # Pure Dart
flutter pub get       # With Flutter

# Check for outdated packages
dart pub outdated

# Upgrade dependencies
dart pub upgrade
```

### Code Quality
```bash
# Analyze code for errors and warnings
dart analyze
dart analyze --fatal-infos

# Format code
dart format lib/
dart format .
dart format --set-exit-if-changed lib/  # Check formatting
```

### Testing
```bash
# Run all tests
dart test

# Run specific test file
dart test test/specific_test.dart

# Run with coverage
dart test --coverage=coverage

# Watch mode for development
dart test --watch
```

### Examples
```bash
# Run Dart examples (from example/example_dart/)
cd example/example_dart
dart run main.dart
dart run autentica_procurador.dart
dart run src/ccmei/ccmei_example.dart
```

### Publishing
```bash
# Dry run (verify package before publishing)
dart pub publish --dry-run

# Publish to pub.dev
dart pub publish
```

## Architecture Overview

### 4-Layer Architecture

```
lib/src/
├── core/           [Infrastructure Layer]
│   ├── api_client.dart           # Central orchestrator (944 lines)
│   └── auth/                     # OAuth2 + mTLS + Procurador
│       ├── auth_service.dart
│       ├── authentication_model.dart
│       ├── http_client_adapter*.dart  # Platform-specific
│
├── services/       [Service/Domain Layer - 24 services]
│   ├── ccmei/                    # Each service follows identical pattern:
│   │   ├── ccmei_service.dart    # - Main service class
│   │   └── model/                # - Request/Response DTOs
│   │       ├── *_request.dart
│   │       ├── *_response.dart
│   │       └── *_validations.dart
│   ├── pgmei/, pgdasd/, defis/   # Same structure for all 24 services
│   └── ...
│
├── base/           [Common Layer]
│   ├── base_request.dart         # Unified request structure
│   ├── mensagem.dart             # Business messages
│   └── tipo_documento.dart
│
└── util/           [Cross-cutting Utilities]
    ├── validacoes_utils.dart     # CPF/CNPJ validation (20KB)
    ├── formatador_utils.dart     # Formatting utilities (12KB)
    ├── arquivo_utils.dart        # File operations
    └── catalogo_servicos_utils.dart
```

### ApiClient: The Central Hub

**File:** [lib/src/core/api_client.dart](lib/src/core/api_client.dart:1)

The `ApiClient` class is the single entry point for all API operations:

1. **Authentication Management:**
   - Stores `AuthenticationModel` with `accessToken`, `jwtToken`, `procuradorToken`
   - Automatic token renewal when < 5 minutes to expiration
   - Supports both basic OAuth2 and unified OAuth2+Procurador authentication

2. **Request Orchestration:**
   - All services call `apiClient.post()` for HTTP requests
   - Automatically merges auth tokens into request headers
   - Generates unique `X-Request-Tag` for traceability
   - Handles parameter overrides (contratante/autor per request)

3. **Platform-Specific mTLS:**
   - Uses conditional exports to select HTTP adapter at compile time
   - Desktop/Mobile: Native `SecurityContext` (dart:io)
   - Web: Cloud Functions proxy (browsers can't do mTLS)

### Authentication Flow

**Three-tier security:**

1. **OAuth2 Client Credentials** ([lib/src/core/auth/auth_service.dart](lib/src/core/auth/auth_service.dart:1))
   - Basic Auth: `consumerKey:consumerSecret`
   - Returns: `accessToken` + `jwtToken` + `expiresIn`
   - Trial mode: Uses hardcoded demo tokens (no certificate needed)
   - Production: Requires real mTLS + OAuth2

2. **mTLS (Mutual TLS)** via Platform Adapters:
   - [http_client_adapter_io.dart](lib/src/core/auth/http_client_adapter_io.dart:1) - Desktop/Mobile (native SecurityContext)
   - [http_client_adapter_web.dart](lib/src/core/auth/http_client_adapter_web.dart:1) - Web (Cloud Function proxy)
   - [http_client_adapter_stub.dart](lib/src/core/auth/http_client_adapter_stub.dart:1) - Fallback/no-op
   - Selection via conditional exports in [http_client_adapter.dart](lib/src/core/auth/http_client_adapter.dart:1)

3. **Procurador Token** ([lib/src/services/autenticaprocurador/](lib/src/services/autenticaprocurador/:1))
   - XML digital signature with RSA-SHA256
   - Cached in static variable for reuse
   - Cleared on `apiClient.clearAuthentication()`

**Automatic Token Renewal:**
```dart
// In ApiClient.post() - happens transparently before every request
if (token.shouldRefresh || token.isExpired) {
  _authModel = await _authService!.authenticate(_storedCredentials!);
}
```

## Key Architectural Patterns

### 1. Flexible Contratante/Autor Override System

**Every service method accepts optional parameters:**
```dart
Future<Response> serviceMethod(String param, {
  String? contratanteNumero,      // Override default from auth
  String? autorPedidoDadosNumero  // Override default from auth
})
```

This allows:
- Default behavior: Uses values from `apiClient.authenticate()`
- Per-request override: Different actors within same session
- No re-authentication needed for different contratantes

**Implementation:** Parameters flow through `ApiClient.post()` which merges them with stored auth values.

### 2. Platform-Specific Compilation (Conditional Exports)

**File:** [lib/src/core/auth/http_client_adapter.dart](lib/src/core/auth/http_client_adapter.dart:1)

```dart
export 'http_client_adapter_stub.dart'
    if (dart.library.io) 'http_client_adapter_io.dart'      // Desktop/Mobile
    if (dart.library.html) 'http_client_adapter_web.dart';  // Web
```

- **No runtime checks** - selected at compile time
- Enables native `SecurityContext` on platforms that support it
- Forces Cloud Function proxy for web (CORS + mTLS workaround)

### 3. Service Pattern Consistency

All 24 services follow **identical structure**:

```
services/{service_name}/
├── {service_name}_service.dart
└── model/
    ├── {operation}_request.dart
    ├── {operation}_response.dart
    └── {service}_validations.dart
```

**Common traits:**
- Constructor accepts `ApiClient` instance
- All methods return `Future<*Response>`
- Validation happens in dedicated `*_validations.dart` files
- Requests extend `BaseRequest` from [lib/src/base/base_request.dart](lib/src/base/base_request.dart:1)

### 4. Request Tag Generation

**File:** [lib/src/util/request_tag_generator.dart](lib/src/util/request_tag_generator.dart:1)

Every request includes `X-Request-Tag` header:
```dart
RequestTagGenerator.generateRequestTag()
// Based on: autorPedidoDadosNumero + contribuinteNumero + idServico
```

Enables end-to-end request tracing in SERPRO systems.

### 5. Service-Specific Message Extensions

**Pattern:** Extensions on base `Mensagem` class for service-specific codes

```dart
// In lib/src/services/pertsn/model/pertsn_response.dart
extension MensagemPertsn on Mensagem {
  bool get isSucessoPertsn => codigo.contains('[Sucesso-PERTSN]');
  bool get isErroPertsn => codigo.contains('[Erro-PERTSN]');
}
```

Allows: `mensagem.isSucessoPertsn` on any Mensagem instance from PERTSN service.

### 6. Trial vs Production Environment Branching

In `AuthService.authenticate()`:
```dart
if (credentials.ambiente == 'trial') {
  return AuthenticationModel(
    accessToken: "06aef429-a981-3ec5-a1f8-71d38d86481e",  // Fixed demo token
    jwtToken: "06aef429-a981-3ec5-a1f8-71d38d86481e",
    expiresIn: 2008,
  );
}
// Otherwise: Real OAuth2 + mTLS flow
```

Trial mode enables testing without certificates.

## Working with Services

### Adding a New Service

1. **Create service directory:** `lib/src/services/{service_name}/`

2. **Create service class:** `{service_name}_service.dart`
   - Import: `import '../../core/api_client.dart';`
   - Constructor: `final ApiClient _apiClient;`
   - Methods follow pattern:
   ```dart
   Future<{Operation}Response> {operationName}(
     String mainParam,
     {String? contratanteNumero, String? autorPedidoDadosNumero}
   ) async {
     final request = BaseRequest(
       contribuinte: Contribuinte(numero: mainParam),
       pedidoDados: PedidoDados(...),
     );

     final response = await _apiClient.post(
       endpoint: '/path/to/endpoint',
       body: request,
       contratanteNumero: contratanteNumero,
       autorPedidoDadosNumero: autorPedidoDadosNumero,
     );

     return {Operation}Response.fromJson(response);
   }
   ```

3. **Create model directory:** `lib/src/services/{service_name}/model/`
   - `{operation}_request.dart` - Request DTOs
   - `{operation}_response.dart` - Response DTOs
   - `{service}_validations.dart` - Service-specific validation logic

4. **Export in main file:** Add to `lib/serpro_integra_contador_api.dart`
   ```dart
   export 'src/services/{service_name}/{service_name}_service.dart';
   export 'src/services/{service_name}/model/{operation}_request.dart';
   export 'src/services/{service_name}/model/{operation}_response.dart';
   ```

5. **Add documentation:** Create `doc/{service_name}_service.md`

6. **Add example:** Create `example/example_dart/src/{service_name}/{service_name}_example.dart`

### Validation Guidelines

**File:** [lib/src/util/validacoes_utils.dart](lib/src/util/validacoes_utils.dart:1)

Use centralized utilities:
- `ValidacoesUtils.isValidCnpj(cnpj)` - CNPJ validation
- `ValidacoesUtils.isValidCpf(cpf)` - CPF validation
- `ValidacoesUtils.validarAnoMes(anoMes)` - Year/month format (YYYYMM)
- `ValidacoesUtils.validarValorMonetario(valor)` - Monetary value validation
- `ValidacoesUtils.validarNumeroParcelamento(numero)` - Installment number

For service-specific rules, create `{service}_validations.dart` in the model directory.

### Formatting Guidelines

**File:** [lib/src/util/formatador_utils.dart](lib/src/util/formatador_utils.dart:1)

- `FormatadorUtils.formatCnpj(cnpj)` - Format CNPJ (XX.XXX.XXX/XXXX-XX)
- `FormatadorUtils.formatCpf(cpf)` - Format CPF (XXX.XXX.XXX-XX)
- `FormatadorUtils.formatCurrency(value)` - Format currency (R$ X.XXX,XX)
- `FormatadorUtils.formatDateFromString(yyyymmdd)` - Format date (DD/MM/YYYY)
- `FormatadorUtils.formatPeriodFromString(yyyymm)` - Format period (Month/Year)

## Important Implementation Notes

### Authentication Token Management

**Status checking:**
```dart
print(apiClient.authTokenInfo);  // JSON with token status, expiration, environment
print(apiClient.hasProcuradorToken);  // bool
```

**Cache clearing:**
```dart
AutenticaProcuradorService.limparCache();  // Clear procurador token cache
apiClient.clearAuthentication();  // Clear all auth state
```

### Error Handling

All responses follow standardized structure:
```dart
class ApiResponse<T> {
  final bool sucesso;
  final String? mensagemErro;
  final T? dados;
  final List<MensagemNegocio> mensagens;
}
```

Always check `response.sucesso` before accessing `response.dados`.

### Testing Data

Use zeros for test CNPJs/CPFs:
- CNPJ test: `'00000000000000'`
- CPF test: `'00000000000'`

### Dependencies

Core dependencies (see [pubspec.yaml](pubspec.yaml:1)):
- `http: ^1.6.0` - HTTP client
- `pointycastle: ^4.0.0` - RSA-SHA256 signature
- `asn1lib: ^1.6.5` - PKCS12 certificate parsing
- `xml: ^6.6.1` - XML manipulation
- `crypto: ^3.0.7` - SHA-256 hashing

### File References

Critical files for understanding the architecture:
- [lib/src/core/api_client.dart](lib/src/core/api_client.dart:1) - Central API client (944 lines)
- [lib/src/core/auth/auth_service.dart](lib/src/core/auth/auth_service.dart:1) - OAuth2 authentication
- [lib/src/core/auth/authentication_model.dart](lib/src/core/auth/authentication_model.dart:1) - Token state management
- [lib/src/base/base_request.dart](lib/src/base/base_request.dart:1) - Base request structure
- [lib/src/util/validacoes_utils.dart](lib/src/util/validacoes_utils.dart:1) - Validation utilities (20KB)
- [lib/src/util/formatador_utils.dart](lib/src/util/formatador_utils.dart:1) - Formatting utilities (12KB)

### Service Examples

Reference implementation for adding services:
- [lib/src/services/ccmei/ccmei_service.dart](lib/src/services/ccmei/ccmei_service.dart:1) - Simple service (one operation)
- [lib/src/services/pgdasd/pgdasd_service.dart](lib/src/services/pgdasd/pgdasd_service.dart:1) - Multi-operation service
- [lib/src/services/caixa_postal/caixa_postal_service.dart](lib/src/services/caixa_postal/caixa_postal_service.dart:1) - Complex data parsing

## Additional Resources

- **README.md**: User-facing documentation with usage examples
- **doc/**: Individual service documentation (23 markdown files)
- **.cursor/rules/**: Comprehensive service specifications (30+ .mdc files with API contracts)
- **example/example_dart/**: Complete working examples for all services
- **SERPRO API Docs**: https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/
