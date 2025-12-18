## [2.0.2] - 2024-12-18
- Ajustes e correções no código.
- Atualização de documentação.
- Limpeza de código desnecessário.

## [2.0.1] - 2024-12-15
- Implementação de autenticação
- Exemplo de uso em example_flutter e example_dart
- Ajustes e correções no código.

## [2.0.0] - 2024-12-14

### Breaking Changes
- Refatorado `HttpClientAdapter` para suportar múltiplas plataformas via conditional exports
- Renomeado arquivo interno `lib/src/core/auth/http_client_adapter.dart` → `http_client_adapter_io.dart`
- Adicionado suporte completo para Flutter Web via proxy mTLS (Cloud Functions ou servidor próprio)

### Added
- ✨ **Suporte Flutter Web** via servidor próprio ou localhost
- Implementação `http_client_adapter_web.dart` para plataforma Web
- Implementação `http_client_adapter_io.dart` para Desktop/Mobile (código anterior sem alterações)
- Implementação `http_client_adapter_stub.dart` para conditional exports
- Parâmetros `urlServidor`, `certSecretName`, `certPasswordSecretName`, `firebaseToken`
- Detecção automática de plataforma e roteamento inteligente
- Enum `CertificateErrorReason.platformNotSupported`

### Changed
- mTLS agora é platform-aware (detecta automaticamente Web vs Desktop/Mobile)
- Desktop/Mobile continuam usando `dart:io` SecurityContext sem mudanças
- Web usa `package:http` sem mTLS nativo, requer Cloud Function para OAuth2
- Assinatura digital XML continua funcionando em Web (pure Dart)

### Migration Guide

**Desktop/Mobile (sem alterações):**
```dart
await apiClient.authenticate(
  consumerKey: 'key',
  certificadoDigitalBase64: certBase64,
  senhaCertificado: 'senha',
  ambiente: 'producao',
);
```

**Web (nova sintaxe):**
```dart
await apiClient.authenticate(
  consumerKey: 'key',
  ambiente: 'producao',
  urlServidor: 'https://servidor.com.br',
  certificadoDigitalBase64: certBase64,
  senhaCertificado: senha,
  firebaseToken: await FirebaseAuth.instance.currentUser?.getIdToken(),
);
```

---

## [1.1.6] - 2025-12-12
- Implementação urlServidor.

## [1.1.5] - 2025-12-12
- Correções no nome do token do procurador.

## [1.1.4] - 2025-12-11
- Ajustes e correções no código.

## [1.1.3] - 2025-12-10
- Ajustes e correções no código.
- Removido cache de tokens do procurador.
- Adicionado método para limpar cache de tokens do procurador.

## [1.1.2] - 2025-12-09
- Ajustes e correções no código.
- Adicionado autenticação com procurador.

## [1.1.0] - 2025-12-04
- Implementação de autenticação mTLS usando API nativa do Dart (SecurityContext)
- Suporte completo multiplataforma: Android, iOS, Web, Desktop, Windows
- Suporte a certificados PKCS12/PFX com algoritmos legados (RC2-40-CBC, 3DES, etc.)
- Removidas dependências externas (pointycastle, asn1lib) - solução 100% Dart nativo
- Código simplificado e mais confiável usando SecurityContext nativo
- Correção: certificados Base64 agora são processados corretamente antes da validação
- Adicionado getter `info` em AuthenticationModel para visualização formatada de todos os dados
- Adicionado campo `origem` no info mostrando se autenticação é nova ou recuperada do cache
- Exemplos simplificados: agora basta usar `print(apiClient.authModel!.info)`
- **NOVA FUNCIONALIDADE**: Assinatura XML Digital para Autentica Procurador
  - Implementação completa de XMLDSig (W3C) com RSA-SHA256
  - Suporte a certificados ICP-Brasil (e-CPF e e-CNPJ)
  - Validação automática de certificados ICP-Brasil
  - Cache inteligente de tokens com suporte a HTTP 304
- **Suporte a Certificados PEM (Pure Dart)**:
  - Parser PEM nativo compatível com Web, Desktop e Mobile
  - Suporte a PKCS#1 e PKCS#8 para chaves privadas
  - Detecção automática de formato (PEM vs PKCS#12)
  - Sem dependências de OpenSSL ou ferramentas externas
- **Novo Parâmetro `certificadoBase64`**:
  - Adicionado em `autenticarProcurador()` para enviar certificado em Base64
  - Ideal para aplicações Web/Mobile que armazenam certificados em banco de dados
  - Funciona com certificados PEM e PKCS#12
- **Dependências Adicionadas**:
  - `pointycastle: ^3.9.1` - Criptografia RSA
  - `asn1lib: ^1.6.5` - Parsing ASN.1
  - `xml: ^6.5.0` - Manipulação de XML
  - `crypto: ^3.0.3` - Hash SHA-256
- **Exemplos e Documentação**:
  - Suite completa de testes em `example_dart/main.dart`
  - 4 testes: Trial Mode, Validação de Certificado, Produção (Path), Produção (Base64)
- **Modo Trial**:
  - Assinatura XML simulada para desenvolvimento sem certificado
  - Funciona apenas com ambiente Trial do SERPRO
  - Facilita testes de integração

## [1.0.4] - 2025-11-10
- Ajustes no modelo de resposta da API PGDASD.

## [1.0.3] - 2025-11-06
- Ajustes no modelo de resposta da API Caixa Postal.

## [1.0.2] - 2025-10-31
- Ajustes no README.md.

## [1.0.1] - 2025-10-05
- Ajustes no README.md.

## [1.0.0] - 2025-10-05
- Primeira versão do pacote.
