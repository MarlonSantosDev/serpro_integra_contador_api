# SERPRO Integra Contador API - Documentação Completa para IA

> **Documentação técnica otimizada para geração automática de código via AI Code Editors**
>
> **Versão do Pacote:** 1.0.4
> **Linguagem:** Dart
> **SDK Mínimo:** 3.9.0
> **Repositório:** https://github.com/MarlonSantosDev/serpro_integra_contador_api

---

## 📋 Índice

1. [Visão Geral do Pacote](#visão-geral-do-pacote)
2. [Arquitetura e Padrões](#arquitetura-e-padrões)
3. [Autenticação e Segurança](#autenticação-e-segurança)
4. [Serviços Disponíveis](#serviços-disponíveis)
5. [Modelos de Dados](#modelos-de-dados)
6. [Utilitários](#utilitários)
7. [Tratamento de Erros](#tratamento-de-erros)
8. [Exemplos de Implementação](#exemplos-de-implementação)
9. [Casos de Uso Comuns](#casos-de-uso-comuns)
10. [Referência Completa de APIs](#referência-completa-de-apis)

---

## 🎯 Visão Geral do Pacote

### Propósito

Este pacote fornece uma interface completa e type-safe para integração com a API do SERPRO Integra Contador, que permite acesso programático aos serviços da Receita Federal do Brasil para contadores e empresas.

### Características Principais

- ✅ **Autenticação Automática**: OAuth2 + mTLS (certificados cliente ICP-Brasil)
- ✅ **Cache Inteligente**: Tokens de procurador com gerenciamento automático de expiração
- ✅ **Validação Centralizada**: CPF, CNPJ, períodos e datas validados automaticamente
- ✅ **Type-Safe**: Modelos tipados para todas as requisições e respostas
- ✅ **Multi-Contexto**: Suporte a múltiplos contratantes/autores em uma sessão
- ✅ **Tratamento Robusto de Erros**: Erros HTTP e de negócio padronizados
- ✅ **23 Serviços**: Cobertura completa das APIs SERPRO
- ✅ **Procurações Eletrônicas**: Suporte completo a autenticação de procuradores

### Dependências Externas

```yaml
dependencies:
  http: ^1.1.0  # Cliente HTTP padrão (não suporta mTLS nativamente)

dev_dependencies:
  test: ^1.24.3
```

**⚠️ IMPORTANTE**: O pacote `http` padrão **não suporta certificados cliente (mTLS)** nativamente. Para produção, é necessário:
- Usar `flutter_client_ssl` (Flutter)
- Implementar cliente HTTP nativo específico da plataforma
- Usar proxy/gateway que gerencie os certificados

### Dados de Teste

Todos os exemplos nesta documentação utilizam dados de teste fornecidos pela SERPRO para o ambiente Trial. Estes dados permitem testar a integração sem necessidade de certificados reais:

**Credenciais de Autenticação:**
- `consumerKey`: `'06aef429-a981-3ec5-a1f8-71d38d86481e'`
- `consumerSecret`: `'06aef429-a981-3ec5-a1f8-71d38d86481e'`
- `certPath`: `'06aef429-a981-3ec5-a1f8-71d38d86481e'`
- `certPassword`: `'06aef429-a981-3ec5-a1f8-71d38d86481e'`

**Documentos de Teste:**
- CNPJ Contratante/Autor: `'00000000000100'` ou `'00000000000000'`
- CNPJ Contribuinte: `'00000000000100'`, `'99999999999999'` ou `'00000000000000'`
- CPF Contribuinte/Procurador: `'99999999999'`

**Períodos de Teste:**
- Ano/Mês: `'201801'`, `'202101'`, `'202301'`, `'202401'`
- Ano: `'2018'`, `'2021'`, `'2023'`, `'2024'`

**Outros Dados:**
- Número Declaração: `'00000000201801001'`
- Número DAS: `'07202136999997159'`
- Número Processo: `'00000000000000000'`

> **Nota**: Estes dados são válidos apenas no ambiente Trial (`https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1`). Para produção, utilize suas credenciais reais obtidas no Portal SERPRO.

---

## 🏗️ Arquitetura e Padrões

### Estrutura de Diretórios

```
lib/
├── serpro_integra_contador_api.dart  # Entry point (exports)
├── src/
│   ├── core/
│   │   ├── api_client.dart                 # Cliente HTTP principal
│   │   └── auth/
│   │       └── authentication_model.dart   # Modelo de autenticação
│   ├── base/
│   │   ├── base_request.dart              # Classe base para requests
│   │   ├── mensagem_negocio.dart          # Mensagens de negócio
│   │   ├── mensagem.dart                  # Mensagens gerais
│   │   └── tipo_documento.dart            # Tipos de documento (CPF/CNPJ)
│   ├── util/
│   │   ├── validacoes_utils.dart          # Validações centralizadas
│   │   ├── formatador_utils.dart          # Formatação de dados
│   │   ├── arquivo_utils.dart             # Operações com arquivos
│   │   └── request_tag_generator.dart     # Gerador de X-Request-Tag
│   └── services/
│       ├── ccmei/                         # Certificado MEI
│       ├── pgdasd/                        # Pagamento DAS Débito Direto
│       ├── pgmei/                         # Pagamento DAS MEI
│       ├── dctfweb/                       # Declaração DCTFWeb
│       ├── defis/                         # Declaração DEFIS
│       ├── sicalc/                        # Sistema de Cálculo
│       ├── sitfis/                        # Sistema Informações Tributárias
│       ├── parcsn/                        # Parcelamento Simples Nacional
│       ├── parcmei/                       # Parcelamento MEI
│       ├── pertsn/                        # Pertinência Simples Nacional
│       ├── pertmei/                       # Pertinência MEI
│       ├── relpsn/                        # Relatório Pagamento SN
│       ├── relpmei/                       # Relatório Pagamento MEI
│       ├── procuracoes/                   # Procurações Eletrônicas
│       ├── autenticaprocurador/           # Autenticação Procurador
│       ├── caixa_postal/                  # Caixa Postal RFB
│       ├── eventos_atualizacao/           # Eventos de Atualização
│       ├── dte/                           # Domicílio Tributário Eletrônico
│       ├── pagtoweb/                      # Consulta Pagamentos
│       ├── regime_apuracao/               # Regime de Apuração
│       ├── mit/                           # Manifesto Importação Trânsito
│       ├── parcsn_especial/               # Parcelamento Especial SN
│       └── parcmei_especial/              # Parcelamento Especial MEI
```

### Padrão de Arquitetura

#### 1. **Cliente API (ApiClient)**

```dart
// Localização: lib/src/core/api_client.dart
class ApiClient {
  // URLs Base
  static const String _baseUrlDemo = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';
  static const String _baseUrlProd = 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1';

  // Responsabilidades:
  // - Autenticação OAuth2 + mTLS
  // - Gerenciamento de tokens (OAuth e Procurador)
  // - Headers automáticos (Authorization, jwt_token, X-Request-Tag)
  // - Cache de tokens de procurador
  // - Requisições HTTP POST
}
```

#### 2. **Padrão Service**

Todos os serviços seguem este padrão:

```dart
class [ServiceName]Service {
  final ApiClient _apiClient;

  [ServiceName]Service(this._apiClient);

  // Métodos de serviço com assinatura padrão:
  Future<[ResponseType]> methodName(
    [required parameters],
    {
      String? contratanteNumero,      // Opcional: usa padrão da auth
      String? autorPedidoDadosNumero, // Opcional: usa padrão da auth
      String? procuradorToken,        // Opcional: para operações com procuração
    }
  ) async {
    // 1. Validação de parâmetros
    // 2. Criação de BaseRequest
    // 3. Chamada _apiClient.post()
    // 4. Deserialização de resposta
    // 5. Retorno de objeto tipado
  }
}
```

#### 3. **Padrão Request/Response**

##### BaseRequest (Todas as requisições herdam)

```dart
// Localização: lib/src/base/base_request.dart
class BaseRequest {
  final String contribuinteNumero;        // CPF/CNPJ do contribuinte
  final int contribuinteTipo;             // 1=CPF, 2=CNPJ
  final PedidoDados pedidoDados;          // Dados do serviço

  // Serializa com dados de autenticação
  Map<String, dynamic> toJsonWithAuth({
    required String contratanteNumero,
    required int contratanteTipo,
    required String autorPedidoDadosNumero,
    required int autorPedidoDadosTipo,
  });
}

class PedidoDados {
  final String idSistema;        // Ex: "CCMEI", "PGDASD"
  final String idServico;        // Ex: "EMITIRCCMEI121"
  final String? versaoSistema;   // Ex: "2.0.0"
  final String dados;            // JSON serializado dos dados específicos
}
```

##### Response Padrão

```dart
// Padrão comum a todas as respostas
{
  "mensagens": [
    {
      "codigo": "Sucesso",  // ou "ERRO", "Aviso"
      "texto": "Operação realizada com sucesso"
    }
  ],
  "dados": {
    // Dados específicos do serviço
  }
}
```

#### 4. **Padrão de Flexibilidade**

**Importante**: Todos os serviços suportam 3 formas de uso:

##### Forma 1: Usar valores padrão da autenticação

```dart
final apiClient = ApiClient();
await apiClient.authenticate(
  consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  certPath: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  certPassword: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  contratanteNumero: '00000000000100',
  autorPedidoDadosNumero: '00000000000100',
);

final service = CcmeiService(apiClient);
// Usa os valores da authenticate()
final response = await service.emitirCcmei('00000000000100');
```

##### Forma 2: Sobrescrever valores por requisição

```dart
// Mesmo apiClient, valores diferentes
final response = await service.emitirCcmei(
  '99999999999999',
  contratanteNumero: '00000000000000',     // Sobrescreve
  autorPedidoDadosNumero: '00000000000000',   // Sobrescreve
);
```

##### Forma 3: Uso com procurador

```dart
// Autenticar procurador
final tokenResponse = await apiClient.autenticarProcurador(
  termoAutorizacaoBase64: termoAssinado,
  contratanteNumero: '00000000000100',
  autorPedidoDadosNumero: '99999999999',
);

// Usar token em operações
final response = await service.emitirCcmei(
  '00000000000100',
  procuradorToken: tokenResponse['autenticar_procurador_token'],
);
```

---

## 🔐 Autenticação e Segurança

### Modelo de Autenticação

#### AuthenticationModel

```dart
// Localização: lib/src/core/auth/authentication_model.dart
class AuthenticationModel {
  final String accessToken;              // Token OAuth2 Bearer
  final String jwtToken;                 // Token JWT adicional
  final int expiresIn;                   // Tempo de expiração em segundos
  final String contratanteNumero;        // CNPJ do contratante
  final String autorPedidoDadosNumero;   // CPF/CNPJ do autor
  final DateTime issuedAt;               // Data/hora de emissão

  // Getters úteis
  bool get isExpired;                    // Verifica se token expirou
  DateTime get expiresAt;                // Data/hora de expiração
}
```

### Fluxo de Autenticação OAuth2 + mTLS

```
┌─────────────┐                                    ┌──────────────┐
│  Aplicação  │                                    │  SERPRO API  │
└──────┬──────┘                                    └──────┬───────┘
       │                                                  │
       │  1. POST /token                                 │
       │     Authorization: Basic {credentials}          │
       │     Role-Type: TERCEIROS                        │
       │     Certificate: {client_cert.p12}              │
       │─────────────────────────────────────────────────>│
       │                                                  │
       │  2. Response                                    │
       │     {                                           │
       │       "access_token": "...",                    │
       │       "jwt_token": "...",                       │
       │       "expires_in": 3600                        │
       │     }                                           │
       │<─────────────────────────────────────────────────│
       │                                                  │
       │  3. POST /[Service]                             │
       │     Authorization: Bearer {access_token}        │
       │     jwt_token: {jwt_token}                      │
       │     X-Request-Tag: {unique_id}                  │
       │     { request body }                            │
       │─────────────────────────────────────────────────>│
       │                                                  │
       │  4. Response (Dados do Serviço)                 │
       │<─────────────────────────────────────────────────│
```

### Autenticação de Procurador

#### Fluxo Completo

```dart
// Passo 1: Gerar termo de autorização
final procuracoesService = ProcuracoesService(apiClient);
final termoResponse = await procuracoesService.obterTermoAutorizacao(
  contribuinteNumero: '00000000000100',
  contribuinteTipo: 2,
  procuradorNumero: '99999999999',
  procuradorTipo: 1,
);

// Passo 2: Assinar digitalmente o termo
// (Implementação depende da biblioteca de assinatura digital)
final termoAssinado = assinarDigitalmente(
  termoResponse.termoAutorizacao,
  certificadoDigital,
);

// Passo 3: Autenticar procurador
final autenticaService = AutenticaProcuradorService(apiClient);
final authResponse = await autenticaService.autenticarComTermoAssinado(
  termoAutorizacaoAssinado: termoAssinado,
  contratanteNumero: '00000000000100',
  autorPedidoDadosNumero: '99999999999',
);

// Passo 4: Token fica em cache automaticamente
final token = apiClient.procuradorToken;

// Passo 5: Usar em serviços
final ccmeiService = CcmeiService(apiClient);
final response = await ccmeiService.emitirCcmei(
  '00000000000100',
  procuradorToken: token,
);
```

#### Cache de Token de Procurador

```dart
// Localização: lib/src/services/autenticaprocurador/model/cache_model.dart
class CacheModel {
  final String token;                     // Token de procurador
  final DateTime dataCriacao;             // Data de criação
  final DateTime dataExpiracao;           // Data de expiração (24h)
  final String contratanteNumero;         // CNPJ do contratante
  final String autorPedidoDadosNumero;    // CPF/CNPJ do procurador

  // Getters úteis
  bool get isTokenValido;                 // Verifica se não expirou
  bool get expiraEmBreve;                 // Expira em menos de 1h
  Duration get tempoRestante;             // Tempo até expiração
}

// Uso do cache
if (apiClient.hasProcuradorToken) {
  print('Token válido: ${apiClient.procuradorToken}');
  print('Info: ${apiClient.procuradorCacheInfo}');
} else {
  // Reautenticar
}
```

### Certificados Cliente (mTLS)

#### Requisitos

- **Formato**: .p12 ou .pfx
- **Tipo**: e-CNPJ ou e-CPF (ICP-Brasil)
- **Validade**: Certificado deve estar válido
- **Identidade**: Deve corresponder ao contratante/autor

#### Obtenção

1. **Portal SERPRO**: https://cliente.serpro.gov.br
2. **API Center**: https://apicenter.estaleiro.serpro.gov.br
3. **Credenciais**: Consumer Key + Consumer Secret

#### Ambientes

| Ambiente  | URL Base                                                      | Propósito          |
|-----------|---------------------------------------------------------------|--------------------|
| Trial     | https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1 | Desenvolvimento    |
| Produção  | https://gateway.apiserpro.serpro.gov.br/integra-contador/v1      | Operação Real      |

### Headers de Requisição

Todas as requisições incluem automaticamente:

```dart
{
  'Authorization': 'Bearer {access_token}',        // Token OAuth2
  'jwt_token': '{jwt_token}',                      // Token JWT adicional
  'Content-Type': 'application/json',              // Tipo de conteúdo
  'X-Request-Tag': '{tag}',                        // Identificador único
  'autenticar_procurador_token': '{token}',       // Apenas se procurador
}
```

#### X-Request-Tag

Formato: `{autor}_{contribuinte}_{servico}_{timestamp}_{random}`

Exemplo: `12345678000100_98765432000100_EMITIRCCMEI121_20250110120000_a7f3e9`

---

## 🚀 Serviços Disponíveis

### Categorias de Serviços

#### 1. MEI (Microempreendedor Individual)

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| CCMEI | `CcmeiService` | `lib/src/services/ccmei/ccmei_service.dart` | Certificado de MEI |
| PGMEI | `PgmeiService` | `lib/src/services/pgmei/pgmei_service.dart` | Pagamento DAS MEI |
| PARCMEI | `ParcmeiService` | `lib/src/services/parcmei/parcmei_service.dart` | Parcelamento MEI |
| PARCMEI Especial | `ParcmeiEspecialService` | `lib/src/services/parcmei_especial/parcmei_especial_service.dart` | Parcelamento Especial MEI |
| PERTMEI | `PertmeiService` | `lib/src/services/pertmei/pertmei_service.dart` | Pertinência/Relevância MEI |
| RELPMEI | `RelpmeiService` | `lib/src/services/relpmei/relpmei_service.dart` | Relatório Pagamento MEI |

#### 2. Simples Nacional

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| PGDASD | `PgdasdService` | `lib/src/services/pgdasd/pgdasd_service.dart` | Pagamento DAS Débito Direto |
| PARCSN | `ParcsnService` | `lib/src/services/parcsn/parcsn_service.dart` | Parcelamento Simples Nacional |
| PARCSN Especial | `ParcsnEspecialService` | `lib/src/services/parcsn_especial/parcsn_especial_service.dart` | Parcelamento Especial SN |
| PERTSN | `PertsnService` | `lib/src/services/pertsn/pertsn_service.dart` | Pertinência Simples Nacional |
| RELPSN | `RelPsnService` | `lib/src/services/relpsn/relpsn_service.dart` | Relatório Pagamento SN |
| Regime Apuração | `RegimeApuracaoService` | `lib/src/services/regime_apuracao/regime_apuracao_service.dart` | Regime de Apuração SN |

#### 3. Tributos Federais

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| DCTFWeb | `DctfwebService` | `lib/src/services/dctfweb/dctfweb_service.dart` | Declaração Débitos/Créditos |
| DEFIS | `DefisService` | `lib/src/services/defis/defis_service.dart` | Declaração Socioeconômica |
| SICALC | `SicalcService` | `lib/src/services/sicalc/sicalc_service.dart` | Sistema Cálculo Impostos |
| SITFIS | `SitfisService` | `lib/src/services/sitfis/sitfis_service.dart` | Sistema Info Tributárias |

#### 4. Comunicação e Consultas

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| Caixa Postal | `CaixaPostalService` | `lib/src/services/caixa_postal/caixa_postal_service.dart` | Mensagens da RFB |
| Eventos Atualização | `EventosAtualizacaoService` | `lib/src/services/eventos_atualizacao/eventos_atualizacao_service.dart` | Monitoramento Eventos |
| DTE | `DteService` | `lib/src/services/dte/dte_service.dart` | Domicílio Tributário |
| PagtoWeb | `PagtoWebService` | `lib/src/services/pagtoweb/pagtoweb_service.dart` | Consulta Pagamentos |

#### 5. Procurações e Autorização

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| Procurações | `ProcuracoesService` | `lib/src/services/procuracoes/procuracoes_service.dart` | Gestão Procurações |
| Autenticação Procurador | `AutenticaProcuradorService` | `lib/src/services/autenticaprocurador/autenticaprocurador_service.dart` | Autenticação Procurador |

#### 6. Comércio Exterior

| Serviço | Classe | Arquivo | Funcionalidade |
|---------|--------|---------|----------------|
| MIT | `MitService` | `lib/src/services/mit/mit_service.dart` | Manifesto Importação |

---

### Detalhamento por Serviço

#### 1. CCMEI Service - Certificado de MEI

**Arquivo**: `lib/src/services/ccmei/ccmei_service.dart`

##### Operações Disponíveis

```dart
class CcmeiService {
  // 1. Emitir Certificado CCMEI (PDF)
  Future<EmitirCcmeiResponse> emitirCcmei(
    String cnpj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Consultar Dados Completos do MEI
  Future<ConsultarDadosCcmeiResponse> consultarDadosCcmei(
    String cnpj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Consultar Situação Cadastral (por CPF)
  Future<ConsultarSituacaoCadastralCcmeiResponse> consultarSituacaoCadastral(
    String cpf, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });
}
```

##### IDs de Serviço

- `EMITIRCCMEI121` - Emissão de certificado
- `DADOSCCMEI122` - Consulta de dados
- `CCMEISITCADASTRAL123` - Situação cadastral

##### Modelos de Resposta

```dart
// Emitir CCMEI
class EmitirCcmeiResponse {
  final String pdf;                    // Base64 do PDF
  final List<MensagemNegocio> mensagens;
}

// Consultar Dados
class ConsultarDadosCcmeiResponse {
  final String cnpj;
  final String nomeEmpresarial;
  final String nomeFantasia;
  final String situacaoCadastral;
  final DateTime dataSituacaoCadastral;
  final DateTime dataInicioAtividade;
  final String cnaePrincipal;
  final List<String> cnaesSecundarios;
  final Endereco endereco;
  final String telefone;
  final String email;
  // ... outros campos
}

// Situação Cadastral
class ConsultarSituacaoCadastralCcmeiResponse {
  final String cpf;
  final String situacao;              // ATIVO, BAIXADO, SUSPENSO
  final DateTime? dataSituacao;
  final String? motivo;
}
```

##### Exemplo de Uso

```dart
final ccmeiService = CcmeiService(apiClient);

// Emitir certificado
final pdfResponse = await ccmeiService.emitirCcmei('00000000000100');
final pdfBytes = base64Decode(pdfResponse.pdf);
await File('ccmei.pdf').writeAsBytes(pdfBytes);

// Consultar dados
final dadosResponse = await ccmeiService.consultarDadosCcmei('00000000000100');
print('Nome: ${dadosResponse.nomeEmpresarial}');
print('CNAE: ${dadosResponse.cnaePrincipal}');

// Verificar situação (por CPF do titular)
final sitResponse = await ccmeiService.consultarSituacaoCadastral('99999999999');
print('Situação: ${sitResponse.situacao}');
```

---

#### 2. PGDASD Service - Pagamento DAS Simples Nacional

**Arquivo**: `lib/src/services/pgdasd/pgdasd_service.dart`

##### Operações Disponíveis

```dart
class PgdasdService {
  // 1. Entregar Declaração Mensal
  Future<EntregarDeclaracaoResponse> entregarDeclaracao(
    EntregarDeclaracaoRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Gerar DAS para Declaração
  Future<GerarDasResponse> gerarDas(
    GerarDasRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Consultar Declarações
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoes(
    String cnpj,
    int ano, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 4. Consultar Última Declaração Recebida
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracao(
    String cnpj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 5. Consultar Declaração por Número
  Future<ConsultarDeclaracaoNumeroResponse> consultarDeclaracaoPorNumero(
    String cnpj,
    String numeroDeclaracao, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 6. Consultar Extrato DAS
  Future<ConsultarExtratoDasResponse> consultarExtratoDas(
    String cnpj,
    int anoMes, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 7. Gerar DAS para Cobrança
  Future<GerarDasCobrancaResponse> gerarDasCobranca(
    String cnpj,
    int anoMes, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 8. Gerar DAS para Processo Judicial
  Future<GerarDasProcessoResponse> gerarDasProcesso(
    String cnpj,
    int anoMes, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 9. Gerar DAS Avulso
  Future<GerarDasAvulsoResponse> gerarDasAvulso(
    String cnpj,
    int anoMes, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });
}
```

##### IDs de Serviço

```dart
'TRANSDECLARACAO11'     // Transmitir declaração
'GERARDAS12'            // Gerar DAS
'CONSDECLARACAO13'      // Consultar declarações
'CONSULTIMADECREC14'    // Consultar última declaração
'CONSDECREC15'          // Consultar declaração por número
'CONSEXTRATO16'         // Consultar extrato DAS
'GERARDASCOBRANCA17'    // Gerar DAS cobrança
'GERARDASPROCESSO18'    // Gerar DAS processo
'GERARDASAVULSO19'      // Gerar DAS avulso
```

##### Modelo de Declaração

```dart
class EntregarDeclaracaoRequest {
  final String cnpj;
  final int anoCalendario;
  final int mesApuracao;
  final List<Estabelecimento> estabelecimentos;
  final bool optanteSimples;
  final bool optanteMei;

  // Cada estabelecimento tem:
  class Estabelecimento {
    final String cnpj;
    final double receitaBrutaTotal;
    final List<Atividade> atividades;
    final Map<String, double> impostos;  // IRPJ, CSLL, COFINS, etc.
  }
}
```

##### Exemplo Completo

```dart
final pgdasdService = PgdasdService(apiClient);

// 1. Criar declaração
final declaracao = EntregarDeclaracaoRequest(
  cnpj: '00000000000100',
  anoCalendario: 2021,
  mesApuracao: 1,
  estabelecimentos: [
    Estabelecimento(
      cnpj: '00000000000100',
      receitaBrutaTotal: 50000.00,
      atividades: [
        Atividade(
          cnae: '4781400',
          receita: 50000.00,
        ),
      ],
      impostos: {
        'IRPJ': 1500.00,
        'CSLL': 900.00,
        'COFINS': 1100.00,
        'PIS': 300.00,
      },
    ),
  ],
  optanteSimples: true,
  optanteMei: false,
);

// 2. Entregar declaração
final entregaResponse = await pgdasdService.entregarDeclaracao(declaracao);
print('Número da declaração: ${entregaResponse.numeroDeclaracao}');
print('Recibo: ${entregaResponse.numeroRecibo}');

// 3. Gerar DAS
final dasRequest = GerarDasRequest(
  cnpj: '00000000000100',
  anoMes: 202101,
);
final dasResponse = await pgdasdService.gerarDas(dasRequest);
print('DAS PDF: ${dasResponse.pdf}');
print('Código de barras: ${dasResponse.codigoBarras}');
print('Valor total: R\$ ${dasResponse.valorTotal}');

// 4. Consultar declarações do ano
final consultaResponse = await pgdasdService.consultarDeclaracoes(
  '00000000000000',
  2018,
);
for (final dec in consultaResponse.declaracoes) {
  print('Mês: ${dec.mes} - Número: ${dec.numero} - Situação: ${dec.situacao}');
}
```

---

#### 3. SICALC Service - Sistema de Cálculo

**Arquivo**: `lib/src/services/sicalc/sicalc_service.dart`

##### Operações Disponíveis

```dart
class SicalcService {
  // 1. Consolidar e Emitir DARF
  Future<ConsolidarEmitirDarfResponse> consolidarEmitirDarf(
    ConsolidarEmitirDarfRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Gerar Código de Barras para DARF
  Future<GerarCodigoBarrasResponse> gerarCodigoBarras(
    GerarCodigoBarrasRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Consultar Códigos de Receita
  Future<ConsultarCodigosReceitaResponse> consultarCodigosReceita({
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 4. Consultar Pagamentos
  Future<ConsultarPagamentosResponse> consultarPagamentos(
    String documento,
    int tipoDocumento, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 5. Consultar Saldo de Parcelamento
  Future<ConsultarSaldoParcelamentoResponse> consultarSaldoParcelamento(
    String documento,
    int tipoDocumento,
    int numeroParcelamento, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // Métodos auxiliares
  Future<bool> receitaPermiteCodigoBarras(String codigoReceita);
  Future<Map<String, dynamic>?> obterInfoReceita(String codigoReceita);

  // Factories para criar requests
  static ConsolidarEmitirDarfRequest criarDarfPessoaFisica({...});
  static ConsolidarEmitirDarfRequest criarDarfPessoaJuridica({...});
  static GerarCodigoBarrasRequest criarCodigoBarras({...});
}
```

##### IDs de Serviço

```dart
'CONSOLEMITEDARF111'      // Consolidar e emitir DARF
'CALCULOSICALC112'        // Gerar código de barras
'CONSCODIGOSRECEITA113'   // Consultar códigos receita
'CONSPAGAMENTOS114'       // Consultar pagamentos
'CONSSALDOPARC115'        // Consultar saldo parcelamento
```

##### Modelo de DARF

```dart
class ConsolidarEmitirDarfRequest {
  final String contribuinteNumero;
  final int contribuinteTipo;         // 1=PF, 2=PJ
  final String codigoReceita;         // Ex: "0190" (IRPF)
  final int dataApuracao;             // Formato: AAAAMMDD
  final double valorPrincipal;
  final double? valorMulta;
  final double? valorJuros;
  final int? referencia;              // Formato: AAAA ou AAAAMM
  final int? dataPagamento;           // Formato: AAAAMMDD
  final String? numeroParcelamento;
  final String? cpfResponsavel;       // Para PJ
}

class ConsolidarEmitirDarfResponse {
  final String pdf;                   // Base64 do PDF
  final String codigoBarras;
  final double valorTotal;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final DateTime dataVencimento;
  final String numeroReceita;
  final int periodoApuracao;
}
```

##### Exemplo: Gerar DARF de IRPF

```dart
final sicalcService = SicalcService(apiClient);

// Método 1: Usando factory
final darfRequest = SicalcService.criarDarfPessoaFisica(
  cpf: '99999999999',
  codigoReceita: '0190',
  dataApuracao: DateTime(2024, 12, 31),
  valorPrincipal: 1000.00,
  referencia: 2024,
);

// Método 2: Criação manual
final darfRequest2 = ConsolidarEmitirDarfRequest(
  contribuinteNumero: '99999999999',
  contribuinteTipo: 1,
  codigoReceita: '0190',
  dataApuracao: 20241231,
  valorPrincipal: 1000.00,
  valorMulta: 10.00,
  valorJuros: 5.00,
  referencia: 2024,
  dataPagamento: 20250115,
);

// Gerar DARF
final darfResponse = await sicalcService.consolidarEmitirDarf(darfRequest);
print('Valor total: R\$ ${darfResponse.valorTotal}');
print('Código de barras: ${darfResponse.codigoBarras}');

// Salvar PDF
final pdfBytes = base64Decode(darfResponse.pdf);
await File('darf.pdf').writeAsBytes(pdfBytes);

// Verificar se receita permite código de barras
final permiteBarras = await sicalcService.receitaPermiteCodigoBarras('0190');
if (permiteBarras) {
  final barrasRequest = SicalcService.criarCodigoBarras(
    contribuinteNumero: '99999999999',
    contribuinteTipo: 1,
    codigoReceita: '0190',
    dataVencimento: DateTime.now().add(Duration(days: 30)),
    valorTotal: 1015.00,
  );

  final barrasResponse = await sicalcService.gerarCodigoBarras(barrasRequest);
  print('Código de barras: ${barrasResponse.codigoBarras}');
}
```

##### Códigos de Receita Comuns

```dart
// IRPF
'0190' - Imposto de Renda Pessoa Física
'0211' - IRPF - Carnê Leão
'0246' - IRPF - Ganho de Capital

// IRPJ
'0220' - IRPJ - Lucro Real
'0221' - IRPJ - Lucro Presumido
'5993' - IRPJ - Simples Nacional

// CSLL
'2469' - CSLL - Lucro Real
'2484' - CSLL - Lucro Presumido

// PIS/COFINS
'5856' - PIS - Não Cumulativo
'2172' - COFINS - Não Cumulativo

// Previdenciário
'2003' - INSS - Contribuinte Individual
'2100' - INSS - Empresa

// Outros
'0507' - FGTS
'4095' - IOF
```

---

#### 4. DCTFWeb Service - Declaração de Débitos

**Arquivo**: `lib/src/services/dctfweb/dctfweb_service.dart`

##### Operações Disponíveis

```dart
class DctfwebService {
  // 1. Transmitir Declaração
  Future<TransmitirDeclaracaoResponse> transmitirDeclaracao(
    TransmitirDeclaracaoRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Consultar Declarações
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoes(
    String cnpj,
    String ano,
    String? mes, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Consultar XML da Declaração
  Future<ConsultarXmlResponse> consultarXml(
    String cnpj,
    String numeroRecibo, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 4. Gerar Guia de Pagamento (DARF)
  Future<GerarGuiaResponse> gerarGuia(
    String cnpj,
    String ano,
    String mes,
    String codigoReceita, {
    String? dia,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 5. Consultar Relatório
  Future<ConsultarRelatorioResponse> consultarRelatorio(
    String cnpj,
    String ano,
    String mes, {
    String? dia,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });
}
```

##### Modelo de Declaração DCTFWeb

```dart
class TransmitirDeclaracaoRequest {
  final String cnpj;
  final String ano;
  final String mes;
  final String? dia;                   // Apenas para eventos quinzenais
  final bool retificadora;
  final String? numeroReciboAnterior;  // Se retificadora
  final List<Debito> debitos;

  class Debito {
    final String codigoReceita;
    final double valor;
    final String natureza;            // Próprio, Responsável, etc.
    final String? cnpjOrigemRetencao; // Se retido de terceiros
  }
}

class TransmitirDeclaracaoResponse {
  final String numeroRecibo;
  final DateTime dataHoraTransmissao;
  final String situacao;              // PROCESSADA, EM_PROCESSAMENTO
  final List<MensagemNegocio> mensagens;
}
```

##### Exemplo: Transmitir DCTFWeb

```dart
final dctfwebService = DctfwebService(apiClient);

// Criar declaração
final declaracao = TransmitirDeclaracaoRequest(
  cnpj: '00000000000100',
  ano: '2025',
  mes: '01',
  retificadora: false,
  debitos: [
    Debito(
      codigoReceita: '1708',      // PIS
      valor: 1000.00,
      natureza: 'Próprio',
    ),
    Debito(
      codigoReceita: '2172',      // COFINS
      valor: 4600.00,
      natureza: 'Próprio',
    ),
    Debito(
      codigoReceita: '0561',      // IRRF
      valor: 500.00,
      natureza: 'Responsável',
    ),
  ],
);

// Transmitir
final response = await dctfwebService.transmitirDeclaracao(declaracao);
print('Recibo: ${response.numeroRecibo}');
print('Data: ${response.dataHoraTransmissao}');

// Consultar declarações do período
final consultaResponse = await dctfwebService.consultarDeclaracoes(
  '00000000000100',
  '2025',
  '01',
);

for (final dec in consultaResponse.declaracoes) {
  print('Recibo: ${dec.numeroRecibo}');
  print('Situação: ${dec.situacao}');
  print('Total débitos: R\$ ${dec.valorTotal}');
}

// Gerar DARF para um débito
final darfResponse = await dctfwebService.gerarGuia(
  '00000000000100',
  '2025',
  '01',
  '1708',  // PIS
);
print('DARF PDF: ${darfResponse.pdf}');

// Baixar XML
final xmlResponse = await dctfwebService.consultarXml(
  '00000000000100',
  response.numeroRecibo,
);
await File('dctfweb.xml').writeAsString(xmlResponse.xml);
```

---

#### 5. Procurações Service

**Arquivo**: `lib/src/services/procuracoes/procuracoes_service.dart`

##### Operações Disponíveis

```dart
class ProcuracoesService {
  // 1. Obter Procuração
  Future<ObterProcuracaoResponse> obterProcuracao(
    String contribuinteNumero,
    int contribuinteTipo,
    String procuradorNumero,
    int procuradorTipo, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Listar Autorizações do Procurador
  Future<ListarAutorizacoesResponse> listarAutorizacoes(
    String procuradorNumero,
    int procuradorTipo, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Validar Permissões
  Future<bool> validarPermissoes(
    String contribuinteNumero,
    String procuradorNumero,
    List<String> servicos, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 4. Obter Termo de Autorização (para assinatura)
  Future<TermoAutorizacaoResponse> obterTermoAutorizacao(
    String contribuinteNumero,
    int contribuinteTipo,
    String procuradorNumero,
    int procuradorTipo, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });
}
```

##### Modelo de Procuração

```dart
class ObterProcuracaoResponse {
  final String contribuinteNumero;
  final String contribuinteNome;
  final String procuradorNumero;
  final String procuradorNome;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool ativa;
  final List<Autorizacao> autorizacoes;

  class Autorizacao {
    final String servico;             // Ex: "CCMEI", "PGDASD"
    final String descricao;
    final List<String> operacoes;     // Ex: ["CONSULTAR", "EMITIR"]
  }
}
```

##### Exemplo: Verificar e Usar Procuração

```dart
final procuracoesService = ProcuracoesService(apiClient);

// 1. Verificar procuração
final procuracao = await procuracoesService.obterProcuracao(
  '00000000000100',  // CNPJ do cliente
  2,                 // Tipo: CNPJ
  '99999999999',     // CPF do contador
  1,                 // Tipo: CPF
);

if (procuracao.ativa) {
  print('Procuração ativa de ${procuracao.contribuinteNome}');
  print('Procurador: ${procuracao.procuradorNome}');
  print('Válida até: ${procuracao.dataFim}');

  // Listar serviços autorizados
  for (final auth in procuracao.autorizacoes) {
    print('Serviço: ${auth.servico}');
    print('Operações: ${auth.operacoes.join(", ")}');
  }

  // Validar permissões específicas
  final temPermissao = await procuracoesService.validarPermissoes(
    '00000000000100',
    '99999999999',
    ['CCMEI', 'PGDASD'],
  );

  if (temPermissao) {
    // Gerar termo para autenticação
    final termo = await procuracoesService.obterTermoAutorizacao(
      '00000000000100',
      2,
      '99999999999',
      1,
    );

    // Assinar e autenticar
    final termoAssinado = assinarDigitalmente(termo.termoAutorizacao);

    final autenticaService = AutenticaProcuradorService(apiClient);
    await autenticaService.autenticarComTermoAssinado(
      termoAutorizacaoAssinado: termoAssinado,
      contratanteNumero: '00000000000100',
      autorPedidoDadosNumero: '99999999999',
    );

    // Usar serviços com procuração
    final ccmeiService = CcmeiService(apiClient);
    final response = await ccmeiService.emitirCcmei(
      '00000000000100',
      procuradorToken: apiClient.procuradorToken,
    );
  }
} else {
  print('Procuração inativa ou inexistente');
}
```

---

#### 6. Eventos de Atualização Service

**Arquivo**: `lib/src/services/eventos_atualizacao/eventos_atualizacao_service.dart`

##### Operações Disponíveis

```dart
class EventosAtualizacaoService {
  // Pessoa Física
  Future<SolicitarEventosPfResponse> solicitarEventosPf(...);
  Future<ObterEventosPfResponse> obterEventosPf(...);
  Future<ObterEventosPfResponse> solicitarEObterEventosPf(...);

  // Pessoa Jurídica
  Future<SolicitarEventosPjResponse> solicitarEventosPj(...);
  Future<ObterEventosPjResponse> obterEventosPj(...);
  Future<ObterEventosPjResponse> solicitarEObterEventosPj(...);
}
```

##### Tipos de Eventos

```dart
enum TipoEvento {
  DCTFWEB,      // Eventos DCTFWeb
  DEFIS,        // Eventos DEFIS
  PGMEI,        // Eventos PGMEI
  SIMPLES,      // Eventos Simples Nacional
}
```

##### Exemplo: Monitorar Eventos

```dart
final eventosService = EventosAtualizacaoService(apiClient);

// Para Pessoa Jurídica
final eventosPj = await eventosService.solicitarEObterEventosPj(
  cnpj: '00000000000100',
  dataInicio: DateTime(2025, 1, 1),
  dataFim: DateTime(2025, 1, 31),
  tiposEvento: [TipoEvento.DCTFWEB, TipoEvento.PGDASD],
);

print('Total de eventos: ${eventosPj.eventos.length}');

for (final evento in eventosPj.eventos) {
  print('Data: ${evento.dataEvento}');
  print('Tipo: ${evento.tipo}');
  print('Descrição: ${evento.descricao}');
  print('Situação: ${evento.situacao}');

  if (evento.tipo == 'DCTFWEB') {
    print('Recibo: ${evento.numeroRecibo}');
  }
}

// Para Pessoa Física (ex: MEI)
final eventosPf = await eventosService.solicitarEObterEventosPf(
  cpf: '99999999999',
  dataInicio: DateTime(2025, 1, 1),
  dataFim: DateTime(2025, 1, 31),
  tiposEvento: [TipoEvento.PGMEI],
);
```

---

#### 7. Caixa Postal Service

**Arquivo**: `lib/src/services/caixa_postal/caixa_postal_service.dart`

##### Operações Disponíveis

```dart
class CaixaPostalService {
  // 1. Listar Todas as Mensagens
  Future<ListaMensagensResponse> listarMensagens(
    String documento,
    int tipoDocumento, {
    DateTime? dataInicio,
    DateTime? dataFim,
    bool? apenasNaoLidas,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 2. Obter Detalhes de Mensagem
  Future<DetalhesMensagemResponse> obterMensagem(
    String documento,
    int tipoDocumento,
    String idMensagem, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });

  // 3. Obter Indicador de Mensagens Não Lidas
  Future<IndicadorMensagensResponse> obterIndicadorNaoLidas(
    String documento,
    int tipoDocumento, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  });
}
```

##### Modelo de Mensagem

```dart
class Mensagem {
  final String id;
  final String assunto;
  final DateTime dataEnvio;
  final String remetente;
  final bool lida;
  final String? categoria;           // AVISO, NOTIFICACAO, INTIMACAO
  final int? prioridade;             // 1=ALTA, 2=NORMAL, 3=BAIXA
}

class DetalhesMensagemResponse {
  final Mensagem mensagem;
  final String conteudo;             // Corpo da mensagem
  final List<Anexo> anexos;

  class Anexo {
    final String nome;
    final String tipo;               // PDF, XML, etc.
    final String conteudoBase64;
  }
}
```

##### Exemplo: Gerenciar Caixa Postal

```dart
final caixaPostalService = CaixaPostalService(apiClient);

// Verificar mensagens não lidas
final indicador = await caixaPostalService.obterIndicadorNaoLidas(
  '99999999999',
  1,
);
print('Mensagens não lidas: ${indicador.quantidadeNaoLidas}');

if (indicador.quantidadeNaoLidas > 0) {
  // Listar mensagens não lidas
  final mensagens = await caixaPostalService.listarMensagens(
    '99999999999999',
    2,
    apenasNaoLidas: true,
    dataInicio: DateTime.now().subtract(Duration(days: 30)),
  );

  for (final msg in mensagens.mensagens) {
    print('---');
    print('Assunto: ${msg.assunto}');
    print('Data: ${msg.dataEnvio}');
    print('Categoria: ${msg.categoria}');

    if (msg.prioridade == 1) {
      print('⚠️ PRIORIDADE ALTA');

      // Abrir mensagem prioritária
      final detalhes = await caixaPostalService.obterMensagem(
        '00000000000000',
        2,
        msg.id,
      );

      print('Conteúdo: ${detalhes.conteudo}');

      // Salvar anexos
      for (final anexo in detalhes.anexos) {
        final bytes = base64Decode(anexo.conteudoBase64);
        await File('anexos/${anexo.nome}').writeAsBytes(bytes);
        print('Anexo salvo: ${anexo.nome}');
      }
    }
  }
}
```

---

## 📊 Modelos de Dados

### Hierarquia de Classes

```
BaseRequest (abstract)
  ├── Todas as classes *Request de serviços
  │
PedidoDados
  └── Contém dados serializados específicos

MensagemNegocio (base)
  ├── MensagemNegocioProcuracoes
  ├── MensagemNegocioDte
  └── Outras extensões específicas

TipoDocumento (enum)
  ├── CPF = 1
  └── CNPJ = 2
```

### Classes Base Comuns

#### 1. BaseRequest

```dart
// Localização: lib/src/base/base_request.dart
abstract class BaseRequest {
  final String contribuinteNumero;
  final int contribuinteTipo;
  final PedidoDados pedidoDados;

  BaseRequest({
    required this.contribuinteNumero,
    required this.contribuinteTipo,
    required this.pedidoDados,
  });

  // Serializa com dados de autenticação
  Map<String, dynamic> toJsonWithAuth({
    required String contratanteNumero,
    required int contratanteTipo,
    required String autorPedidoDadosNumero,
    required int autorPedidoDadosTipo,
  }) {
    return {
      'contratante': {
        'numero': contratanteNumero,
        'tipo': contratanteTipo,
      },
      'autorPedidoDados': {
        'numero': autorPedidoDadosNumero,
        'tipo': autorPedidoDadosTipo,
      },
      'contribuinte': {
        'numero': contribuinteNumero,
        'tipo': contribuinteTipo,
      },
      'pedidoDados': pedidoDados.toJson(),
    };
  }
}
```

#### 2. MensagemNegocio

```dart
// Localização: lib/src/base/mensagem_negocio.dart
class MensagemNegocio {
  final String codigo;
  final String texto;

  // Getters de conveniência
  bool get isSucesso => codigo.toLowerCase() == 'sucesso';
  bool get isErro => codigo.toLowerCase() == 'erro';
  bool get isAviso => codigo.toLowerCase() == 'aviso';

  String get tipo {
    if (isSucesso) return 'Sucesso';
    if (isErro) return 'Erro';
    if (isAviso) return 'Aviso';
    return 'Indefinido';
  }
}
```

#### 3. TipoDocumento

```dart
// Localização: lib/src/base/tipo_documento.dart
enum TipoDocumento {
  CPF(1, 'CPF'),
  CNPJ(2, 'CNPJ');

  final int codigo;
  final String descricao;

  const TipoDocumento(this.codigo, this.descricao);

  static TipoDocumento fromNumero(String numero) {
    final limpo = numero.replaceAll(RegExp(r'\D'), '');
    return limpo.length == 11 ? CPF : CNPJ;
  }

  static int detectType(String numero) {
    return fromNumero(numero).codigo;
  }
}
```

### Convenções de Nomenclatura

#### Requests

```dart
// Padrão: [Ação][Contexto]Request
class EntregarDeclaracaoRequest extends BaseRequest { }
class ConsultarDeclaracoesRequest extends BaseRequest { }
class GerarDasRequest extends BaseRequest { }
class EmitirCcmeiRequest extends BaseRequest { }
```

#### Responses

```dart
// Padrão: [Ação][Contexto]Response
class EntregarDeclaracaoResponse {
  final String numeroRecibo;
  final DateTime dataHora;
  final List<MensagemNegocio> mensagens;
}

class ConsultarDeclaracoesResponse {
  final List<Declaracao> declaracoes;
  final List<MensagemNegocio> mensagens;
}
```

### Serialização JSON

#### To JSON (Request)

```dart
class MinhaRequest extends BaseRequest {
  final String campo1;
  final int campo2;
  final DateTime data;

  // Serializa APENAS os dados específicos
  // O BaseRequest adiciona contratante/autor/contribuinte
  Map<String, dynamic> toDadosJson() {
    return {
      'campo1': campo1,
      'campo2': campo2,
      'data': FormatadorUtils.formatDateFromStringISO(
        data.toIso8601String().substring(0, 10),
      ),
    };
  }

  // Construtor deve criar PedidoDados
  MinhaRequest({
    required String contribuinteNumero,
    required this.campo1,
    required this.campo2,
    required this.data,
  }) : super(
    contribuinteNumero: contribuinteNumero,
    contribuinteTipo: ValidacoesUtils.detectDocumentType(contribuinteNumero),
    pedidoDados: PedidoDados(
      idSistema: 'SISTEMA',
      idServico: 'SERVICO123',
      versaoSistema: '1.0.0',
      dados: jsonEncode({
        'campo1': campo1,
        'campo2': campo2,
        'data': FormatadorUtils.formatDateFromStringISO(
          data.toIso8601String().substring(0, 10),
        ),
      }),
    ),
  );
}
```

#### From JSON (Response)

```dart
class MinhaResponse {
  final String resultado;
  final int codigo;
  final List<MensagemNegocio> mensagens;

  MinhaResponse({
    required this.resultado,
    required this.codigo,
    required this.mensagens,
  });

  factory MinhaResponse.fromJson(Map<String, dynamic> json) {
    return MinhaResponse(
      resultado: json['dados']['resultado'] as String,
      codigo: json['dados']['codigo'] as int,
      mensagens: (json['mensagens'] as List)
          .map((m) => MensagemNegocio.fromJson(m))
          .toList(),
    );
  }
}
```

### Enums por Serviço

Cada serviço pode ter seus próprios enums:

```dart
// DCTFWeb
enum NaturezaDebito {
  PROPRIO('Próprio'),
  RESPONSAVEL('Responsável'),
  RETIDO('Retido na Fonte');

  final String descricao;
  const NaturezaDebito(this.descricao);
}

// DEFIS
enum TipoOptante {
  SIMPLES_NACIONAL('Simples Nacional'),
  NAO_OPTANTE('Não Optante'),
  MEI('Microempreendedor Individual');

  final String descricao;
  const TipoOptante(this.descricao);
}

// Regime Apuração
enum RegimeApuracao {
  CAIXA('Regime de Caixa'),
  COMPETENCIA('Regime de Competência');

  final String descricao;
  const RegimeApuracao(this.descricao);
}
```

---

## 🛠️ Utilitários

### 1. ValidacoesUtils

**Localização**: `lib/src/util/validacoes_utils.dart`

#### Métodos de Detecção

```dart
class ValidacoesUtils {
  // Detecta tipo de documento (1=CPF, 2=CNPJ)
  static int detectDocumentType(String numero);

  // Valida consistência de lista de documentos
  static int validateDocumentListConsistency(List<String> documentos);

  // Remove formatação (pontos, traços, barras)
  static String cleanDocumentNumber(String numero);
}
```

#### Validações de Documento

```dart
// CPF
static bool isValidCpf(String cpf) {
  // Remove formatação
  // Verifica tamanho
  // Calcula dígitos verificadores
  // Retorna true/false
}

// CNPJ
static bool isValidCnpj(String cnpj) {
  // Remove formatação
  // Verifica tamanho
  // Calcula dígitos verificadores
  // Retorna true/false
}

// Genérico (detecta automaticamente)
static bool isValidDocument(String documento);

// Exemplos
ValidacoesUtils.isValidCpf('123.456.789-09');      // true/false
ValidacoesUtils.isValidCnpj('12.345.678/0001-00'); // true/false
ValidacoesUtils.isValidDocument('12345678900');    // auto-detecta e valida
```

#### Validações de Formato

```dart
// Período (AAAAMM)
static bool isValidPeriodo(String periodo);
// Ex: '202501' -> true, '202513' -> false

// Número de Declaração
static bool isValidNumeroDeclaracao(String numero);

// Número de DAS
static bool isValidNumeroDas(String numero);

// Ano (AAAA)
static bool isValidAno(String ano);
// Ex: '2025' -> true, '25' -> false

// Período de Apuração DCTFWeb
static bool isValidPeriodoApuracao(String ano, String? mes, String? dia);
// Valida combinações válidas:
// - ano + mes + dia (quinzenal)
// - ano + mes (mensal)
// - ano (anual)

// Data como int (AAAAMMDD)
static bool isValidDataAcolhimento(int dataAcolhimento);
```

#### Validações com Mensagens de Erro

```dart
// Retorna null se válido, string de erro se inválido
static String? validarNumeroParcelamento(int? numeroParcelamento);
static String? validarAnoMes(int? anoMes);
static String? validarDataInt(int? data);
static String? validarDataHoraInt(int? dataHora);
static String? validarValorMonetario(double? valor);
static String? validarCnpjContribuinte(String? cnpj);

// Exemplo de uso
final erro = ValidacoesUtils.validarCnpjContribuinte('12345');
if (erro != null) {
  throw ArgumentError(erro);
}
```

---

### 2. FormatadorUtils

**Localização**: `lib/src/util/formatador_utils.dart`

#### Formatação Monetária

```dart
// Formatar valor double
static String formatCurrency(double value, {bool includeSymbol = true});
// Ex: 1234.56 -> 'R$ 1.234,56' ou '1.234,56'

// Formatar string
static String formatCurrencyString(String value, {bool includeSymbol = true});

// Formatar número genérico
static String formatNumber(double value, {int decimals = 2});
// Ex: 1234.5678 -> '1.234,57'

// Exemplos
FormatadorUtils.formatCurrency(1500.50);           // 'R$ 1.500,50'
FormatadorUtils.formatCurrency(1500.50, includeSymbol: false); // '1.500,50'
FormatadorUtils.formatNumber(123.456, decimals: 3); // '123,456'
```

#### Formatação de Documentos

```dart
// CPF
static String formatCpf(String cpf);
// Ex: '12345678900' -> '123.456.789-00'

// CNPJ
static String formatCnpj(String cnpj);
// Ex: '12345678000100' -> '12.345.678/0001-00'

// Genérico (detecta automaticamente)
static String formatDocument(String document);
// Ex: '12345678900' -> '123.456.789-00'
//     '12345678000100' -> '12.345.678/0001-00'

// Exemplos
FormatadorUtils.formatCpf('12345678900');      // '123.456.789-00'
FormatadorUtils.formatCnpj('12345678000100');  // '12.345.678/0001-00'
FormatadorUtils.formatDocument('12345678900'); // '123.456.789-00'
```

#### Formatação de Datas

```dart
// De string AAAAMMDD para DD/MM/AAAA
static String formatDateFromString(String dateString);
// Ex: '20250110' -> '10/01/2025'

// De string AAAAMMDD para AAAA-MM-DD
static String formatDateFromStringISO(String dateString);
// Ex: '20250110' -> '2025-01-10'

// DateTime para DD/MM/AAAA
static String formatDate(DateTime date);
// Ex: DateTime(2025, 1, 10) -> '10/01/2025'

// DateTime para AAAA-MM-DD
static String formatDateISO(DateTime date);
// Ex: DateTime(2025, 1, 10) -> '2025-01-10'

// DateTime com hora (AAAAMMDDHHMMSS)
static String formatDateTimeFromString(String dateTimeString);
// Ex: '20250110143000' -> '10/01/2025 14:30:00'

// Exemplos
FormatadorUtils.formatDateFromString('20250110');    // '10/01/2025'
FormatadorUtils.formatDate(DateTime.now());          // '10/01/2025'
FormatadorUtils.formatDateISO(DateTime(2025, 1, 10)); // '2025-01-10'
```

#### Formatação de Períodos

```dart
// De AAAAMM para AAAA/MM
static String formatPeriodFromString(String periodString);
// Ex: '202501' -> '2025/01'

// De AAAAMM para MM/AAAA
static String formatPeriodFromStringReverse(String periodString);
// Ex: '202501' -> '01/2025'

// De ano e mês para string formatada
static String formatPeriod(int year, int month);
// Ex: formatPeriod(2025, 1) -> '2025/01'

// Exemplos
FormatadorUtils.formatPeriodFromString('202501');        // '2025/01'
FormatadorUtils.formatPeriodFromStringReverse('202501'); // '01/2025'
FormatadorUtils.formatPeriod(2025, 1);                   // '2025/01'
```

#### Formatação Específica DCTFWeb

```dart
// Formatar data de apuração
static String formatDataApuracao(String ano, String? mes, String? dia);
// Ex: ('2025', '01', null) -> '01/2025'
//     ('2025', '01', '15') -> '15/01/2025'

// Converter DateTime para int de acolhimento (AAAAMMDD)
static int converterDataParaAcolhimento(DateTime data);
// Ex: DateTime(2025, 1, 10) -> 20250110

// Converter int de acolhimento para DateTime
static DateTime? converterAcolhimentoParaData(int dataAcolhimento);
// Ex: 20250110 -> DateTime(2025, 1, 10)

// Exemplos
FormatadorUtils.formatDataApuracao('2025', '01', null);     // '01/2025'
FormatadorUtils.formatDataApuracao('2025', '01', '15');     // '15/01/2025'
FormatadorUtils.converterDataParaAcolhimento(DateTime.now()); // 20250110
```

---

### 3. ArquivoUtils

**Localização**: `lib/src/util/arquivo_utils.dart`

```dart
class ArquivoUtils {
  // Salvar conteúdo Base64 em arquivo
  static Future<bool> salvarArquivo(
    String base64Content,
    String fileName,
  );

  // Ler arquivo e retornar Base64
  static Future<String?> lerArquivo(String fileName);
}

// Exemplos
// Salvar PDF
await ArquivoUtils.salvarArquivo(
  response.pdf,
  'documentos/ccmei_12345678000100.pdf',
);

// Salvar XML
await ArquivoUtils.salvarArquivo(
  base64Encode(utf8.encode(xmlString)),
  'declaracoes/dctfweb_2025_01.xml',
);

// Ler certificado
final certBase64 = await ArquivoUtils.lerArquivo('certificados/cert.p12');
```

---

### 4. RequestTagGenerator

**Localização**: `lib/src/util/request_tag_generator.dart`

```dart
class RequestTagGenerator {
  // Gera X-Request-Tag único para requisições
  static String generateRequestTag({
    required String autorPedidoDadosNumero,
    required String contribuinteNumero,
    required String idServico,
  });

  // Formato: {autor}_{contribuinte}_{servico}_{timestamp}_{random}
  // Ex: 12345678000100_98765432000100_EMITIRCCMEI121_20250110120000_a7f3e9
}

// Uso interno pelo ApiClient
// Não precisa chamar diretamente
```

---

## ⚠️ Tratamento de Erros

### Tipos de Erros

#### 1. Erros HTTP (Status Code != 2xx)

```dart
try {
  final response = await service.method();
} catch (e) {
  if (e.toString().contains('Falha na requisição: 401')) {
    // Token expirado ou inválido
    print('Erro de autenticação');
  } else if (e.toString().contains('Falha na requisição: 403')) {
    // Sem permissão
    print('Acesso negado');
  } else if (e.toString().contains('Falha na requisição: 404')) {
    // Endpoint não encontrado
    print('Serviço não encontrado');
  } else if (e.toString().contains('Falha na requisição: 500')) {
    // Erro no servidor
    print('Erro interno do servidor');
  }
}
```

#### 2. Erros de Negócio (Status 200 com ERRO)

```dart
try {
  final response = await service.method();
} catch (e) {
  // API retornou status 200 mas com código ERRO nas mensagens
  // Formato: Exception com Map contendo:
  // {
  //   "rota": "/Ccmei/Emitir",
  //   "status": 200,
  //   "idSistema": "CCMEI",
  //   "idServico": "EMITIRCCMEI121",
  //   "mensagens": "Contribuinte não encontrado",
  //   "body": "{...json da requisição...}"
  // }

  final errorMap = parseErrorException(e);
  print('Erro no serviço: ${errorMap['idServico']}');
  print('Mensagem: ${errorMap['mensagens']}');
  print('Request: ${errorMap['body']}');
}
```

#### 3. Erros de Validação

```dart
try {
  final service = CcmeiService(apiClient);
  await service.emitirCcmei('123');  // CNPJ inválido
} catch (e) {
  if (e is ArgumentError) {
    print('Erro de validação: ${e.message}');
    // Ex: "CNPJ inválido"
  }
}
```

### Códigos de Erro por Serviço

#### PARCSN Errors

```dart
// Localização: lib/src/services/parcsn/model/parcsn_errors.dart
enum ParcsnErrorCode {
  ACESSO_NEGADO('0001', 'Acesso negado ao serviço'),
  CONTRIBUINTE_INVALIDO('0002', 'Contribuinte inválido'),
  PARCELAMENTO_NAO_ENCONTRADO('0003', 'Parcelamento não encontrado'),
  PARCELA_NAO_ENCONTRADA('0004', 'Parcela não encontrada'),
  // ... outros códigos
}
```

#### PGMEI Errors

```dart
// Localização: lib/src/services/pgmei/model/pgmei_validations.dart
class PgmeiValidations {
  static const CNPJ_INVALIDO = 'CNPJ inválido ou não pertence a MEI';
  static const PERIODO_INVALIDO = 'Período de apuração inválido';
  static const DAS_NAO_GERADO = 'Não foi possível gerar o DAS';
  // ... outras mensagens
}
```

### Tratamento Recomendado

```dart
Future<void> processarServico() async {
  try {
    // Tentar operação
    final response = await service.method();

    // Verificar mensagens de negócio
    for (final msg in response.mensagens) {
      if (msg.isErro) {
        print('Erro: ${msg.texto}');
        // Tratar erro específico
      } else if (msg.isAviso) {
        print('Aviso: ${msg.texto}');
        // Mostrar aviso ao usuário
      }
    }

    // Processar dados
    if (response.dados != null) {
      // Sucesso
      processar(response.dados);
    }

  } on ArgumentError catch (e) {
    // Erro de validação
    print('Validação falhou: ${e.message}');
    mostrarErroParaUsuario('Dados inválidos: ${e.message}');

  } on SocketException {
    // Erro de rede
    print('Sem conexão com a internet');
    mostrarErroParaUsuario('Verifique sua conexão com a internet');

  } on TimeoutException {
    // Timeout
    print('Requisição expirou');
    mostrarErroParaUsuario('O servidor demorou muito para responder');

  } catch (e) {
    // Outros erros
    if (e.toString().contains('Falha na requisição: 401')) {
      print('Token expirado');
      // Reautenticar
      await apiClient.authenticate(...);
      // Tentar novamente
      return processarServico();

    } else if (e.toString().contains('Falha na autenticação')) {
      print('Erro de autenticação');
      mostrarErroParaUsuario('Erro ao autenticar. Verifique suas credenciais.');

    } else {
      print('Erro desconhecido: $e');
      mostrarErroParaUsuario('Erro inesperado. Tente novamente.');
    }
  }
}
```

### Retry Pattern

```dart
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      return await operation();
    } catch (e) {
      attempts++;

      if (attempts >= maxRetries) {
        rethrow;
      }

      // Retry apenas para erros temporários
      if (e.toString().contains('500') ||
          e.toString().contains('503') ||
          e is SocketException ||
          e is TimeoutException) {
        print('Tentativa $attempts falhou. Tentando novamente em ${delay.inSeconds}s...');
        await Future.delayed(delay);
      } else {
        // Erro permanente, não retry
        rethrow;
      }
    }
  }

  throw Exception('Operação falhou após $maxRetries tentativas');
}

// Uso
final response = await retryOperation(
  () => ccmeiService.emitirCcmei('00000000000100'),
  maxRetries: 3,
  delay: Duration(seconds: 5),
);
```

---

## 💡 Exemplos de Implementação

### Template de Service Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

class MeuServicoCompleto {
  final ApiClient _apiClient;

  MeuServicoCompleto(this._apiClient);

  /// Emitir documento com tratamento completo de erros
  Future<EmitirDocumentoResponse?> emitirDocumento({
    required String cnpj,
    required String tipo,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // 1. Validação de entrada
    if (!ValidacoesUtils.isValidCnpj('00000000000100')) {
      throw ArgumentError('CNPJ inválido: 00000000000100');
    }

    // 2. Log inicial
    print('Iniciando emissão de documento para CNPJ: ${FormatadorUtils.formatCnpj('00000000000100')}');

    try {
      // 3. Criar request
      final request = EmitirDocumentoRequest(
        contribuinteNumero: '00000000000100',
        tipoDocumento: tipo,
      );

      // 4. Executar operação com retry
      final response = await retryOperation(
        () => _serviceMethod(
          request,
          contratanteNumero: contratanteNumero,
          autorPedidoDadosNumero: autorPedidoDadosNumero,
        ),
        maxRetries: 3,
      );

      // 5. Verificar mensagens de negócio
      for (final msg in response.mensagens) {
        if (msg.isErro) {
          print('❌ Erro: ${msg.texto}');
          throw Exception('Erro de negócio: ${msg.texto}');
        } else if (msg.isAviso) {
          print('⚠️  Aviso: ${msg.texto}');
        } else if (msg.isSucesso) {
          print('✅ Sucesso: ${msg.texto}');
        }
      }

      // 6. Processar dados
      if (response.dados != null) {
        // Salvar PDF se houver
        if (response.dados.pdf != null && response.dados.pdf!.isNotEmpty) {
          await ArquivoUtils.salvarArquivo(
            response.dados.pdf!,
            'documentos/00000000000100_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print('📄 PDF salvo com sucesso');
        }

        return response.dados;
      }

      return null;

    } on ArgumentError catch (e) {
      print('❌ Erro de validação: ${e.message}');
      rethrow;

    } on SocketException {
      print('❌ Erro de rede');
      throw Exception('Sem conexão com a internet');

    } on TimeoutException {
      print('❌ Timeout');
      throw Exception('O servidor demorou muito para responder');

    } catch (e) {
      if (e.toString().contains('Falha na requisição: 401')) {
        print('❌ Token expirado, reautenticando...');
        throw Exception('Token expirado. Reautentique e tente novamente.');
      } else {
        print('❌ Erro desconhecido: $e');
        rethrow;
      }
    }
  }

  /// Método interno de serviço
  Future<EmitirDocumentoResponse> _serviceMethod(
    EmitirDocumentoRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final response = await _apiClient.post(
      '/MeuServico/Emitir',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return EmitirDocumentoResponse.fromJson(response);
  }

  /// Método auxiliar de retry
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) rethrow;

        if (e.toString().contains('500') ||
            e.toString().contains('503') ||
            e is SocketException ||
            e is TimeoutException) {
          print('Tentativa $attempts falhou. Tentando novamente...');
          await Future.delayed(delay);
        } else {
          rethrow;
        }
      }
    }

    throw Exception('Falhou após $maxRetries tentativas');
  }
}
```

---

### Template de Aplicação Flutter

```dart
import 'package:flutter/material.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SERPRO Integra',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ApiClient apiClient;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await apiClient.authenticate(
        consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
        consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
        certPath: '06aef429-a981-3ec5-a1f8-71d38d86481e',
        certPassword: '06aef429-a981-3ec5-a1f8-71d38d86481e',
        contratanteNumero: '00000000000100',
        autorPedidoDadosNumero: '00000000000100',
        ambiente: 'trial',
      );

      setState(() {
        isAuthenticated = true;
      });

    } catch (e) {
      setState(() {
        errorMessage = 'Erro na autenticação: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _emitirCCMEI(String cnpj) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final ccmeiService = CcmeiService(apiClient);
      final response = await ccmeiService.emitirCcmei('00000000000100');

      // Salvar PDF
      final pdfBytes = base64Decode(response.pdf);
      // ... salvar arquivo

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CCMEI emitido com sucesso!')),
      );

    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao emitir CCMEI: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SERPRO Integra'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (isAuthenticated)
                    ElevatedButton(
                      onPressed: () => _emitirCCMEI('00000000000100'),
                      child: Text('Emitir CCMEI'),
                    ),
                ],
              ),
      ),
    );
  }
}
```

---

## 🎯 Casos de Uso Comuns

### 1. Sistema de Contabilidade

```dart
class SistemaContabilidade {
  final ApiClient apiClient;
  final Map<String, CacheModel> tokensProcuradores = {};

  SistemaContabilidade(this.apiClient);

  /// Autenticar como procurador de um cliente
  Future<void> autenticarCliente(String cnpjCliente, String cpfContador) async {
    // Verificar cache
    final cacheKey = '${cnpjCliente}_$cpfContador';
    if (tokensProcuradores.containsKey(cacheKey) &&
        tokensProcuradores[cacheKey]!.isTokenValido) {
      print('Usando token em cache');
      return;
    }

    // Obter termo
    final procuracoesService = ProcuracoesService(apiClient);
    final termo = await procuracoesService.obterTermoAutorizacao(
      '00000000000100',
      2,
      '99999999999',
      1,
    );

    // Assinar
    final termoAssinado = await assinarDigitalmente(termo.termoAutorizacao);

    // Autenticar
    final autenticaService = AutenticaProcuradorService(apiClient);
    await autenticaService.autenticarComTermoAssinado(
      termoAutorizacaoAssinado: termoAssinado,
      contratanteNumero: '00000000000100',
      autorPedidoDadosNumero: '99999999999',
    );

    // Cachear
    tokensProcuradores[cacheKey] = apiClient._procuradorCache!;
  }

  /// Entregar declaração PGDASD para cliente
  Future<void> entregarPGDASD({
    required String cnpjCliente,
    required String cpfContador,
    required int ano,
    required int mes,
    required Map<String, double> impostos,
    required double receitaBruta,
  }) async {
    // Autenticar
    await autenticarCliente(cnpjCliente, cpfContador);

    // Criar declaração
    final pgdasdService = PgdasdService(apiClient);
    final declaracao = EntregarDeclaracaoRequest(
      cnpj: '00000000000100',
      anoCalendario: ano,
      mesApuracao: mes,
      estabelecimentos: [
        Estabelecimento(
          cnpj: '00000000000100',
          receitaBrutaTotal: receitaBruta,
          impostos: impostos,
        ),
      ],
      optanteSimples: true,
      optanteMei: false,
    );

    // Entregar
    final response = await pgdasdService.entregarDeclaracao(
      declaracao,
      procuradorToken: apiClient.procuradorToken,
    );

    print('Declaração entregue: ${response.numeroDeclaracao}');

    // Gerar DAS automaticamente
    final dasResponse = await pgdasdService.gerarDas(
      GerarDasRequest(cnpj: '00000000000100', anoMes: ano * 100 + mes),
      procuradorToken: apiClient.procuradorToken,
    );

    // Salvar DAS
    await ArquivoUtils.salvarArquivo(
      dasResponse.pdf,
      'das/00000000000100_${ano}_${mes}.pdf',
    );
  }

  /// Processar lote de clientes
  Future<void> processarLoteDeclaracoes(
    List<Map<String, dynamic>> clientes,
    int ano,
    int mes,
  ) async {
    final resultados = <String, String>{};

    for (final cliente in clientes) {
      try {
        await entregarPGDASD(
          cnpjCliente: cliente['cnpj'],
          cpfContador: cliente['contador_cpf'],
          ano: ano,
          mes: mes,
          impostos: cliente['impostos'],
          receitaBruta: cliente['receita_bruta'],
        );

        resultados[cliente['cnpj']] = 'Sucesso';

      } catch (e) {
        resultados[cliente['cnpj']] = 'Erro: $e';
      }
    }

    // Gerar relatório
    print('=== Relatório de Processamento ===');
    resultados.forEach((cnpj, resultado) {
      print('$cnpj: $resultado');
    });
  }
}
```

---

### 2. Portal de Autoatendimento MEI

```dart
class PortalMEI {
  final ApiClient apiClient;

  PortalMEI(this.apiClient);

  /// Dashboard completo do MEI
  Future<Map<String, dynamic>> obterDashboard(String cnpj) async {
    final dashboard = <String, dynamic>{};

    // 1. Dados cadastrais
    final ccmeiService = CcmeiService(apiClient);
    final dadosResponse = await ccmeiService.consultarDadosCcmei('00000000000100');
    dashboard['dados_cadastrais'] = {
      'nome': dadosResponse.nomeEmpresarial,
      'situacao': dadosResponse.situacaoCadastral,
      'data_abertura': dadosResponse.dataInicioAtividade,
      'cnae': dadosResponse.cnaePrincipal,
    };

    // 2. Pendências de pagamento
    final relpmeiService = RelpmeiService(apiClient);
    final pagamentosResponse = await relpmeiService.consultarPendencias('00000000000100');
    dashboard['pendencias'] = pagamentosResponse.pagamentosPendentes;

    // 3. Parcelamentos ativos
    final parcmeiService = ParcmeiService(apiClient);
    final parcelamentosResponse = await parcmeiService.consultarPedidos('00000000000100');
    dashboard['parcelamentos'] = parcelamentosResponse.parcelamentos
        .where((p) => p.situacao == 'ATIVO')
        .toList();

    // 4. Mensagens não lidas
    final caixaPostalService = CaixaPostalService(apiClient);
    final indicador = await caixaPostalService.obterIndicadorNaoLidas('00000000000100', 2);
    dashboard['mensagens_nao_lidas'] = indicador.quantidadeNaoLidas;

    // 5. Divida ativa
    final pgmeiService = PgmeiService(apiClient);
    try {
      final dividaResponse = await pgmeiService.consultarDividaAtiva('00000000000100');
      dashboard['divida_ativa'] = dividaResponse.temDivida;
    } catch (e) {
      dashboard['divida_ativa'] = false;
    }

    return dashboard;
  }

  /// Gerar DAS do mês
  Future<String> gerarDASMes(String cnpj, int ano, int mes) async {
    final pgmeiService = PgmeiService(apiClient);

    // Gerar DAS
    final dasResponse = await pgmeiService.gerarDas(
      cnpj: '00000000000100',
      anoMes: ano * 100 + mes,
    );

    // Salvar PDF
    final fileName = 'das_mei_00000000000100_${ano}_${mes}.pdf';
    await ArquivoUtils.salvarArquivo(dasResponse.pdf, fileName);

    return fileName;
  }

  /// Solicitar parcelamento
  Future<String> solicitarParcelamento({
    required String cnpj,
    required List<int> periodosDevidos,
    required int quantidadeParcelas,
  }) async {
    // Aqui implementaria a lógica de solicitação
    // (não há endpoint específico na API, geralmente é feito no Portal)
    throw UnimplementedError('Solicitação de parcelamento deve ser feita pelo Portal RFB');
  }

  /// Emitir certificado CCMEI
  Future<String> emitirCertificado(String cnpj) async {
    final ccmeiService = CcmeiService(apiClient);
    final response = await ccmeiService.emitirCcmei('00000000000100');

    final fileName = 'ccmei_00000000000100_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await ArquivoUtils.salvarArquivo(response.pdf, fileName);

    return fileName;
  }
}
```

---

### 3. Robô de Monitoramento

```dart
class RoboMonitoramento {
  final ApiClient apiClient;
  final Duration intervaloVerificacao;
  Timer? _timer;

  RoboMonitoramento(
    this.apiClient, {
    this.intervaloVerificacao = const Duration(hours: 1),
  });

  /// Iniciar monitoramento
  void iniciar(List<String> cnpjs) {
    _timer?.cancel();
    _timer = Timer.periodic(intervaloVerificacao, (_) {
      _verificarTodos(cnpjs);
    });

    // Primeira verificação imediata
    _verificarTodos(cnpjs);
  }

  /// Parar monitoramento
  void parar() {
    _timer?.cancel();
  }

  /// Verificar todos os CNPJs
  Future<void> _verificarTodos(List<String> cnpjs) async {
    print('=== Verificação ${DateTime.now()} ===');

    for (final cnpj in cnpjs) {
      try {
        await _verificarCNPJ(cnpj);
      } catch (e) {
        print('Erro ao verificar $cnpj: $e');
      }
    }
  }

  /// Verificar um CNPJ específico
  Future<void> _verificarCNPJ(String cnpj) async {
    // 1. Verificar mensagens novas
    await _verificarMensagens(cnpj);

    // 2. Verificar eventos de atualização
    await _verificarEventos(cnpj);

    // 3. Verificar vencimentos próximos
    await _verificarVencimentos(cnpj);
  }

  /// Verificar novas mensagens
  Future<void> _verificarMensagens(String cnpj) async {
    final caixaPostalService = CaixaPostalService(apiClient);

    final indicador = await caixaPostalService.obterIndicadorNaoLidas('99999999999999', 2);

    if (indicador.quantidadeNaoLidas > 0) {
      print('📬 $cnpj tem ${indicador.quantidadeNaoLidas} mensagens não lidas');

      final mensagens = await caixaPostalService.listarMensagens(
        '99999999999999',
        2,
        apenasNaoLidas: true,
      );

      for (final msg in mensagens.mensagens) {
        if (msg.prioridade == 1) {
          print('⚠️  PRIORITÁRIO: ${msg.assunto}');
          await _notificar(cnpj, 'Mensagem prioritária', msg.assunto);
        }
      }
    }
  }

  /// Verificar eventos de atualização
  Future<void> _verificarEventos(String cnpj) async {
    final eventosService = EventosAtualizacaoService(apiClient);

    final eventos = await eventosService.solicitarEObterEventosPj(
      cnpj: '00000000000100',
      dataInicio: DateTime.now().subtract(Duration(days: 1)),
      dataFim: DateTime.now(),
      tiposEvento: [TipoEvento.DCTFWEB, TipoEvento.PGDASD],
    );

    if (eventos.eventos.isNotEmpty) {
      print('📊 $cnpj tem ${eventos.eventos.length} eventos novos');

      for (final evento in eventos.eventos) {
        print('  - ${evento.tipo}: ${evento.descricao}');
        await _notificar(cnpj, 'Novo evento', evento.descricao);
      }
    }
  }

  /// Verificar vencimentos próximos
  Future<void> _verificarVencimentos(String cnpj) async {
    // Verificar DAS do mês seguinte
    final mesAtual = DateTime.now();
    final mesSeguinte = DateTime(mesAtual.year, mesAtual.month + 1);

    // Se estamos nos últimos 5 dias do mês, alertar sobre próximo DAS
    if (mesAtual.day >= 25) {
      print('📅 $cnpj: DAS de ${mesSeguinte.month}/${mesSeguinte.year} vence em breve');
      await _notificar(
        cnpj,
        'Vencimento próximo',
        'DAS de ${mesSeguinte.month}/${mesSeguinte.year} vence dia 20',
      );
    }
  }

  /// Notificar (implementar conforme necessidade)
  Future<void> _notificar(String cnpj, String titulo, String mensagem) async {
    // Enviar email, push notification, etc.
    print('🔔 Notificação para $cnpj: $titulo - $mensagem');
  }
}

// Uso
void main() async {
  final apiClient = ApiClient();
  await apiClient.authenticate(...);

  final robo = RoboMonitoramento(
    apiClient,
    intervaloVerificacao: Duration(hours: 2),
  );

  robo.iniciar([
    '00000000000100',
    '99999999999999',
    '00000000000000',
  ]);

  // Rodar indefinidamente
  await Future.delayed(Duration(days: 365));
}
```

---

## 📚 Referência Completa de APIs

### Mapeamento de Endpoints

| Serviço | Endpoint Base | Métodos Disponíveis |
|---------|---------------|---------------------|
| CCMEI | `/Ccmei` | Emitir, ConsultarDados, ConsultarSituacao |
| PGDASD | `/Pgdasd` | Declarar, GerarDAS, ConsultarDeclaracoes, ConsultarExtrato |
| PGMEI | `/Pgmei` | GerarDAS, GerarCodigoBarras, AtualizarBeneficio, ConsultarDivida |
| DCTFWeb | `/Dctfweb` | Transmitir, Consultar, ConsultarXML, GerarGuia, ConsultarRelatorio |
| DEFIS | `/Defis` | Transmitir, Consultar, ConsultarUltima, ConsultarEspecifica |
| SICALC | `/Sicalc` | ConsolidarDARF, GerarCodigoBarras, ConsultarReceitas, ConsultarPagamentos |
| Procurações | `/Procuracoes` | Obter, ListarAutorizacoes, ObterTermo |
| Autentica Procurador | `/AutenticarProcurador` | Autenticar |
| Caixa Postal | `/CaixaPostal` | Listar, Obter, ObterIndicador |
| Eventos | `/EventosAtualizacao` | SolicitarPF, ObterPF, SolicitarPJ, ObterPJ |

### IDs de Sistema e Serviço

#### CCMEI
```dart
idSistema: 'CCMEI'
idServico: 'EMITIRCCMEI121'       // Emitir certificado
idServico: 'DADOSCCMEI122'        // Consultar dados
idServico: 'CCMEISITCADASTRAL123' // Situação cadastral
```

#### PGDASD
```dart
idSistema: 'PGDASD'
idServico: 'TRANSDECLARACAO11'    // Transmitir declaração
idServico: 'GERARDAS12'           // Gerar DAS
idServico: 'CONSDECLARACAO13'     // Consultar declarações
idServico: 'CONSULTIMADECREC14'   // Consultar última
idServico: 'CONSDECREC15'         // Consultar por número
idServico: 'CONSEXTRATO16'        // Consultar extrato
idServico: 'GERARDASCOBRANCA17'   // DAS cobrança
idServico: 'GERARDASPROCESSO18'   // DAS processo
idServico: 'GERARDASAVULSO19'     // DAS avulso
```

#### DCTFWeb
```dart
idSistema: 'DCTFWEB'
idServico: 'TRANSMITIRDECLARACAO91' // Transmitir
idServico: 'CONSULTARDECLARACOES92' // Consultar
idServico: 'CONSULTARXML93'         // Consultar XML
idServico: 'GERARGUIA94'            // Gerar guia
idServico: 'CONSULTARRELATORIO95'   // Consultar relatório
```

#### DEFIS
```dart
idSistema: 'DEFIS'
idServico: 'TRANSMITIRDECLARACAO81'        // Transmitir
idServico: 'CONSULTARDECLARACOES82'        // Consultar
idServico: 'CONSULTARULTIMADECLARACAO83'   // Consultar última
idServico: 'CONSULTARDECLARACAOESPECIFICA84' // Consultar específica
```

#### SICALC
```dart
idSistema: 'SICALC'
idServico: 'CONSOLEMITEDARF111'     // Consolidar DARF
idServico: 'CALCULOSICALC112'       // Código de barras
idServico: 'CONSCODIGOSRECEITA113'  // Consultar receitas
idServico: 'CONSPAGAMENTOS114'      // Consultar pagamentos
idServico: 'CONSSALDOPARC115'       // Saldo parcelamento
```

---

## 🔧 Configuração para Produção

### Checklist de Deploy

- [ ] Substituir autenticação mock por implementação real com mTLS
- [ ] Implementar suporte a certificados cliente (flutter_client_ssl ou nativo)
- [ ] Configurar ambiente de produção (`ambiente: 'producao'`)
- [ ] Implementar cache persistente de tokens (SQLite, SharedPreferences)
- [ ] Adicionar logging estruturado (ex: logger package)
- [ ] Implementar monitoramento de erros (ex: Sentry, Firebase Crashlytics)
- [ ] Adicionar retry automático com backoff exponencial
- [ ] Implementar rate limiting para evitar sobrecarga
- [ ] Configurar timeouts apropriados
- [ ] Adicionar testes automatizados
- [ ] Documentar fluxos de autenticação
- [ ] Configurar CI/CD
- [ ] Implementar rotação de certificados
- [ ] Adicionar health checks

### Exemplo de Configuração de Produção

```dart
class ProdApiClient extends ApiClient {
  final Logger _logger;
  final CertificateManager _certManager;
  final TokenCache _tokenCache;

  ProdApiClient({
    required Logger logger,
    required CertificateManager certManager,
    required TokenCache tokenCache,
  }) : _logger = logger,
       _certManager = certManager,
       _tokenCache = tokenCache;

  @override
  Future<void> authenticate({...}) async {
    // Verificar cache
    if (_tokenCache.hasValidToken()) {
      _authModel = _tokenCache.getToken();
      _logger.info('Using cached token');
      return;
    }

    // Verificar certificado
    if (!await _certManager.isValid(certPath)) {
      throw Exception('Certificado inválido ou expirado');
    }

    try {
      // Implementação real com mTLS
      final httpClient = await _createSecureClient(certPath, certPassword);

      final credentials = base64.encode(
        utf8.encode('$consumerKey:$consumerSecret'),
      );

      final response = await httpClient.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Role-Type': 'TERCEIROS',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final authData = json.decode(response.body);
        _authModel = AuthenticationModel(
          accessToken: authData['access_token'],
          jwtToken: authData['jwt_token'],
          expiresIn: authData['expires_in'],
          contratanteNumero: contratanteNumero,
          autorPedidoDadosNumero: autorPedidoDadosNumero,
        );

        // Cachear
        await _tokenCache.saveToken(_authModel!);
        _logger.info('Authentication successful');

      } else {
        _logger.error('Authentication failed: ${response.statusCode}');
        throw Exception('Falha na autenticação: ${response.body}');
      }

    } catch (e) {
      _logger.error('Authentication error', error: e);
      rethrow;
    }
  }

  Future<http.Client> _createSecureClient(
    String certPath,
    String certPassword,
  ) async {
    // Implementar cliente com suporte a mTLS
    // Exemplo usando flutter_client_ssl:
    return FlutterClientSsl.createHttpClient(
      certificate: certPath,
      password: certPassword,
    );
  }
}
```

---

## 🎓 Glossário

| Termo | Significado |
|-------|-------------|
| **mTLS** | Mutual TLS - Autenticação bidirecional com certificados cliente |
| **ICP-Brasil** | Infraestrutura de Chaves Públicas Brasileira |
| **DAS** | Documento de Arrecadação do Simples Nacional |
| **DARF** | Documento de Arrecadação de Receitas Federais |
| **MEI** | Microempreendedor Individual |
| **CCMEI** | Certificado de Condição de Microempreendedor Individual |
| **Simples Nacional** | Regime tributário simplificado para micro e pequenas empresas |
| **DCTFWeb** | Declaração de Débitos e Créditos Tributários Federais Web |
| **DEFIS** | Declaração de Informações Socioeconômicas e Fiscais |
| **CNAE** | Classificação Nacional de Atividades Econômicas |
| **RFB** | Receita Federal do Brasil |
| **SERPRO** | Serviço Federal de Processamento de Dados |
| **Bearer Token** | Token de autenticação usado no header Authorization |
| **X-Request-Tag** | Identificador único de requisição |
| **Procuração Eletrônica** | Autorização digital para representação |

---

## 📝 Notas Finais

### Para o Cursor AI Code Editor

Este documento contém todas as informações necessárias para:

1. **Gerar novos serviços** seguindo os padrões estabelecidos
2. **Implementar funcionalidades** usando os serviços existentes
3. **Criar aplicações completas** que integram com SERPRO
4. **Tratar erros** de forma adequada
5. **Validar e formatar** dados corretamente
6. **Autenticar** usuários e procuradores
7. **Gerenciar tokens** e cache
8. **Processar respostas** da API

### Padrões a Seguir

Ao gerar código usando este pacote, sempre:

- Use os utilitários de validação antes de enviar requisições
- Implemente tratamento de erros robusto
- Formate valores monetários e datas corretamente
- Verifique mensagens de negócio nas respostas
- Use os parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero` quando necessário
- Implemente retry para erros temporários
- Cache tokens de procurador quando possível
- Log operações importantes

### Exemplos de Prompts Efetivos

**Bom prompt:**
> "Crie um serviço que use o PGDASD para entregar declarações mensais do Simples Nacional. O serviço deve validar o CNPJ, tratar erros de autenticação, gerar o DAS automaticamente após a entrega, e salvar o PDF do DAS em arquivo."

**Bom prompt:**
> "Implemente um método que consulte todas as mensagens não lidas da caixa postal de um CNPJ, filtre apenas as de alta prioridade, baixe os anexos em PDF, e retorne um relatório estruturado."

**Bom prompt:**
> "Crie uma classe que gerencie múltiplos clientes (CNPJs) para um contador (CPF). Deve autenticar como procurador de cada cliente, verificar pendências de pagamento, e gerar DAS para todos os períodos em aberto."

---

## 📄 Licença e Contato

- **Repositório**: https://github.com/MarlonSantosDev/serpro_integra_contador_api
- **Versão**: 1.0.4
- **Autor**: Marlon Santos
- **Licença**: Verificar no repositório

---

**Última atualização desta documentação**: 10/01/2025
**Versão da documentação**: 1.0.0
