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