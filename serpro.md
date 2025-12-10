# Guia de Implementação e Uso - SERPRO Integra Contador API

Este documento serve como guia para entender a estrutura do pacote `serpro_integra_contador_api` e como implementar ou utilizar seus serviços. Ele foi desenhado para ser consumido por IAs ou desenvolvedores que desejam estender ou utilizar a biblioteca.

## 1. Visão Geral

O pacote fornece uma interface em Dart para acessar a API do SERPRO Integra Contador. Ele encapsula a complexidade de autenticação (OAuth2 com mTLS e assinatura de termos) e fornece métodos tipados para os diversos endpoints fiscais (Simples Nacional, MEI, DCTFWeb, etc.).

### Principais Componentes

*   **`ApiClient`**: Classe central responsável por gerenciar a conexão HTTP, autenticação OAuth2, armazenamento de tokens e configuração de certificados digitais.
*   **Serviços (`*Service`)**: Classes que encapsulam a lógica de negócio de cada módulo do SERPRO (ex: `CaixaPostalService`, `PgdasdService`).
*   **Modelos**: Classes que representam as requisições e respostas da API, garantindo tipagem segura.

## 2. Estrutura do Projeto

A estrutura de pastas segue o padrão:

```
lib/
├── serpro_integra_contador_api.dart  # Exporta os principais membros
├── src/
│   ├── core/                         # Núcleo da API
│   │   ├── api_client.dart           # Cliente HTTP e Auth
│   │   └── auth/                     # Lógica de autenticação
│   ├── services/                     # Implementação dos serviços
│   │   ├── [nome_servico]/           # Pasta de cada serviço
│   │   │   ├── [nome]_service.dart   # Lógica do serviço
│   │   │   └── model/                # DTOs (Request/Response)
│   └── util/                         # Utilitários (Validadores, Formatadores)
```

## 3. Autenticação

A autenticação é o passo mais crítico. Existem dois níveis:

1.  **OAuth2 (Acesso à API)**: Feito via `ApiClient.authenticate()`. Requer `Consumer Key`, `Consumer Secret` e certificado digital (pfx) do contratante (quem paga a API).
2.  **Autentica Procurador (Assinatura de Termo)**: Necessário para agir em nome de terceiros (procuração). Requer o serviço `AutenticaProcuradorService` e o certificado digital do procurador/contador.

### Configuração do `ApiClient`

```dart
final apiClient = ApiClient();

await apiClient.authenticate(
  consumerKey: 'SEU_CONSUMER_KEY',
  consumerSecret: 'SEU_CONSUMER_SECRET',
  contratanteNumero: 'CNPJ_CONTRATANTE', // Quem contratou a API
  autorPedidoDadosNumero: 'CPF_CNPJ_AUTOR', // Quem está fazendo a requisição
  certificadoDigitalPath: 'caminho/para/certificado_contratante.pfx',
  senhaCertificado: 'SENHA_CERTIFICADO',
  ambiente: 'producao', // ou 'trial'
);
```

### Melhorias na Versão 1.1.x

A versão 1.1.x trouxe melhorias significativas em segurança e compatibilidade:

#### Autenticação mTLS Nativa

- **SecurityContext nativo**: Utiliza APIs nativas do Dart para mTLS, garantindo compatibilidade multiplataforma
- **Suporte a algoritmos legados**: Compatível com certificados antigos (RC2-40-CBC, 3DES)
- **Sem dependências externas**: Removidas dependências de criptografia externa
- **Processamento Base64**: Certificados em Base64 são processados automaticamente

#### Assinatura XML Digital

- **XMLDSig completo**: Implementação W3C de assinatura digital XML
- **RSA-SHA256**: Algoritmo padrão para assinaturas digitais
- **Certificados ICP-Brasil**: Suporte total a e-CPF e e-CNPJ
- **Modo Trial**: Assinatura simulada para desenvolvimento
- **Cache inteligente**: Suporte a HTTP 304 para otimização de tokens

### Autenticação do Procurador (Se necessário)

```dart
final autenticaService = AutenticaProcuradorService(apiClient);

await autenticaService.autenticarProcurador(
  contratanteNome: 'NOME CONTRATANTE',
  contratanteNumero: 'CNPJ_CONTRATANTE',
  autorNome: 'NOME PROCURADOR',
  autorNumero: 'CPF_CNPJ_PROCURADOR',
  contribuinteNumero: 'CNPJ_CLIENTE', // Cliente do contador
  certificadoPath: 'caminho/para/certificado_procurador.pfx',
  certificadoPassword: 'SENHA',
);
```

## 4. Lista de Serviços Disponíveis

Abaixo a lista de serviços já implementados em `lib/src/services/`. Para implementar um novo, siga o padrão destes.

*   **`AutenticaProcuradorService`**: Assinatura digital de termos de procuração.
*   **`CaixaPostalService`**: Acesso a mensagens da caixa postal fiscal.
*   **`CcmeiService`**: Consulta e emissão de CCMEI.
*   **`DctfWebService`**: Declaração de Débitos e Créditos Tributários Federais.
*   **`DefisService`**: Declaração de Informações Socioeconômicas e Fiscais (Simples Nacional).
*   **`DteService`**: Domicílio Tributário Eletrônico.
*   **`EventosAtualizacaoService`**: Consulta eventos de atualização cadastral.
*   **`MitService`**: Microempreendedor Individual - Tributos.
*   **`PagtoWebService`**: Pagamentos Web.
*   **`ParcmeiService` / `ParcmeiEspecialService`**: Parcelamento MEI.
*   **`ParcsnService` / `ParcsnEspecialService`**: Parcelamento Simples Nacional.
*   **`PertmeiService` / `PertsnService`**: Programa Especial de Regularização Tributária.
*   **`PgdasdService`**: Programa Gerador do Documento de Arrecadação do Simples Nacional.
*   **`PgmeiService`**: Programa Gerador de DAS do Microempreendedor Individual.
*   **`ProcuracoesService`**: Gestão e consulta de procurações eletrônicas.
*   **`RegimeApuracaoService`**: Gestão completa do regime de apuração do Simples Nacional (Competência/Caixa) - efetuar opção, consultar anos calendários, consultar opções e resoluções.
*   **`RelpmeiService` / `RelpsnService`**: Programa de Reescalonamento (RELP).
*   **`SicalcService`**: Cálculo e emissão de DARF.
*   **`SitfisService`**: Situação Fiscal.

## 5. Como Implementar um Novo Serviço

Para adicionar um novo serviço ao pacote, siga este roteiro:

1.  **Crie a pasta**: `lib/src/services/NOVO_SERVICO/`.
2.  **Crie os Modelos**: Em `lib/src/services/NOVO_SERVICO/model/`, crie classes para o Request e Response do endpoint.
    *   Use `jsonEncode`/`jsonDecode` para serialização.
    *   Estenda de classes base se houver padrão comum.
3.  **Crie a Classe de Serviço**: Em `lib/src/services/NOVO_SERVICO/NOVO_SERVICO_service.dart`.
    *   A classe deve receber o `ApiClient` no construtor.
    *   Implemente métodos que chamam `apiClient.post`, `apiClient.get`, etc.
    *   Trate as rotas da API (endpoints).

**Exemplo de Template de Serviço:**

```dart
import '../../core/api_client.dart';
import 'model/meu_servico_response.dart';

class MeuServicoService {
  final ApiClient _apiClient;

  MeuServicoService(this._apiClient);

  Future<MeuServicoResponse> consultarAlgo(String parametro) async {
    final response = await _apiClient.get(
      '/meu-endpoint/v1/$parametro',
    );

    // O ApiClient já trata erros HTTP comuns e retorna o body parseado ou throw Exception
    // Aqui você converte o Map/String para seu Modelo
    return MeuServicoResponse.fromJson(response);
  }
}
```

## 5. Novos Utilitários (v1.1.x)

### ArquivoUtils

Utilitário para manipulação de arquivos, especialmente PDFs em base64:

```dart
// Salvar PDF da CCMEI
final pdfBase64 = response.dados?.pdf;
final sucesso = await ArquivoUtils.salvarArquivo(pdfBase64, 'ccmei.pdf');
// Arquivo salvo em: arquivos/pdf/ccmei.pdf
```

### CatalogoServicosUtils

Mapeamento de códigos de serviço para códigos funcionais conforme catálogo SERPRO:

```dart
// Obter código funcional
final codigo = CatalogoServicosUtils.getFunctionCode('TRANSDECLARACAO11');
// Resultado: '01'

// Verificar se serviço existe
final existe = CatalogoServicosUtils.isServiceInCatalog('GERARDAS12');
// Resultado: true
```

## 6. Exemplo Completo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();

  // 1. Autenticação Base
  await apiClient.authenticate(
    consumerKey: 'KEY',
    consumerSecret: 'SECRET',
    contratanteNumero: '00000000000000',
    autorPedidoDadosNumero: '00000000000000',
    certificadoDigitalPath: 'cert.pfx',
    senhaCertificado: '1234',
  );

  // 2. Usando um serviço (ex: Caixa Postal)
  final caixaPostal = CaixaPostalService(apiClient);
  
  try {
    final indicador = await caixaPostal.obterIndicadorNovasMensagens('CNPJ_DO_CLIENTE');
    print('Tem mensagens? ${indicador.dados?.conteudo.first.temMensagensNovas}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

