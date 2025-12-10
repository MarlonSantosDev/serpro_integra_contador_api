[1.0.0] - 2025-10-05
- Primeira versão do pacote.

[1.0.1] - 2025-10-05
- Ajustes no README.md.

[1.0.2] - 2025-10-31
- Ajustes no README.md.

[1.0.3] - 2025-11-06
- Ajustes no modelo de resposta da API Caixa Postal.

[1.0.4] - 2025-11-10
- Ajustes no modelo de resposta da API PGDASD.

 [1.1.0] - 2025-12-04
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
  - Suite completa de testes em `example/main.dart`
  - 4 testes: Trial Mode, Validação de Certificado, Produção (Path), Produção (Base64)
- **Modo Trial**:
  - Assinatura XML simulada para desenvolvimento sem certificado
  - Funciona apenas com ambiente Trial do SERPRO
  - Facilita testes de integração
[1.1.2] - 2025-12-09
- Ajustes e correções no código.
- Adicionado autenticação com procurador.
[1.1.3] - 2025-12-10
- Ajustes e correções no código.
- Removido cache de tokens do procurador.
- Adicionado método para limpar cache de tokens do procurador.