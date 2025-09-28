# SERPRO Integra Contador API

Um package Dart completo para acessar todos os serviços da API do SERPRO Integra Contador.

## Visão Geral

O **SERPRO Integra Contador** é uma plataforma de serviços que fornece um conjunto de APIs para escritórios de contabilidade e demais empresas do ramo contábil, otimizando a prestação de serviços aos contribuintes.

Este package oferece uma interface Dart/Flutter para interagir com todos os serviços disponíveis, incluindo:

- **DEFIS** - Declaração de Informações Socioeconômicas e Fiscais
- **PGDASD** - Programa Gerador do DAS do Simples Nacional  
- **PGMEI** - Programa Gerador do DAS do MEI
- **CCMEI** - Certificado da Condição de Microempreendedor Individual
- **Regime de Apuração** - Opção pelo Regime de Apuração de Receitas
- E muitos outros serviços

## Características

✅ **Cobertura Completa**: Suporte a todos os serviços disponíveis na API  
✅ **Modelos Tipados**: Classes Dart com serialização JSON automática  
✅ **Documentação Detalhada**: Documentação completa para cada serviço  
✅ **Exemplos Práticos**: Exemplos de uso para todos os serviços  
✅ **Dados de Teste**: CNPJs/CPFs e payloads de exemplo para desenvolvimento  
✅ **Tratamento de Erros**: Gestão adequada de códigos de status e mensagens de erro  

## Instalação

Adicione o package ao seu `pubspec.yaml`:

```yaml
dependencies:
  serpro_integra_contador_api: ^1.0.0
```

Execute:

```bash
dart pub get
```

## Configuração

### Pré-requisitos

Para usar este package em produção, você precisa:

1. **Certificado Digital e-CNPJ** (padrão ICP-Brasil)
2. **Consumer Key e Consumer Secret** (obtidos na área do cliente SERPRO)
3. **Contrato ativo** com o SERPRO para os serviços desejados

### Autenticação

A API do SERPRO utiliza autenticação OAuth2 com certificado digital obrigatório:

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

**⚠️ Importante**: A implementação atual da autenticação é simplificada. Para uso em produção, será necessário implementar suporte a mTLS (Mutual TLS) com certificados digitais, que não é suportado nativamente pelo pacote `http` do Dart.

## Guia de Configuração e Utilização

### Configuração Inicial

Todos os serviços seguem o mesmo padrão de configuração:

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

// 1. Configurar cliente de API
final apiClient = ApiClient();
await apiClient.authenticate(
  'seu_consumer_key',
  'seu_consumer_secret', 
  'caminho/para/certificado.p12',
  'senha_do_certificado',
);

// 2. Criar instância do serviço desejado
final service = NomeDoService(apiClient);
```

### Como Utilizar Cada Serviço

#### 🏢 DEFIS - Declaração de Informações Socioeconômicas e Fiscais
```dart
final defisService = DefisService(apiClient);

// Transmitir declaração DEFIS
final response = await defisService.transmitirDeclaracao(
  '00000000000000', // CNPJ Contratante
  declaracaoData,
);
```
**📖 [Documentação Completa](doc/defis_service.md)**

#### 📊 PGDASD - Programa Gerador do DAS do Simples Nacional
```dart
final pgdasdService = PgdasdService(apiClient);

// Entregar declaração mensal
final response = await pgdasdService.entregarDeclaracaoSimples(
  cnpj: '00000000000000',
  periodoApuracao: 202401,
  declaracao: declaracao,
  transmitir: true,
);

// Gerar DAS
final dasResponse = await pgdasdService.gerarDasSimples(
  cnpj: '00000000000000',
  periodoApuracao: '202401',
);
```
**📖 [Documentação Completa](doc/pgdasd_service.md)**

#### 📋 DCTFWeb - Declaração de Débitos e Créditos Tributários Federais
```dart
final dctfWebService = DctfWebService(apiClient);

// Gerar DARF
final response = await dctfWebService.gerarDarfGeralMensal(
  contribuinteNumero: '00000000000000',
  anoPA: '2024',
  mesPA: '01',
);

// Consultar XML e transmitir declaração
final response = await dctfWebService.consultarXmlETransmitir(
  contribuinteNumero: '00000000000000',
  categoria: CategoriaDctf.geralMensal,
  anoPA: '2024',
  mesPA: '01',
  assinadorXml: (xmlBase64) async {
    // Implementar assinatura digital
    return await assinarXmlDigitalmente(xmlBase64);
  },
);
```
**📖 [Documentação Completa](doc/dctfweb_service.md)**

#### 🏪 PGMEI - Programa Gerador do DAS do MEI
```dart
final pgmeiService = PgmeiService(apiClient);

// Gerar DAS PDF
final response = await pgmeiService.gerarDas('00000000000000', '202401');

// Gerar DAS com código de barras
final codigoBarrasResponse = await pgmeiService.gerarDasCodigoDeBarras(
  '00000000000000', 
  '202401',
);
```
**📖 [Documentação Completa](doc/pgmei_service.md)**

#### 📜 CCMEI - Certificado da Condição de MEI
```dart
final ccmeiService = CcmeiService(apiClient);

// Emitir CCMEI
final response = await ccmeiService.emitirCcmei('00000000000000');

// Consultar dados do MEI
final dadosResponse = await ccmeiService.consultarDadosCcmei('00000000000000');
```
**📖 [Documentação Completa](doc/ccmei_service.md)**

#### 💰 PARCMEI - Parcelamento do MEI
```dart
final parcmeiService = ParcmeiService(apiClient);

// Consultar pedidos de parcelamento
final pedidosResponse = await parcmeiService.consultarPedidos();

// Emitir DAS para parcela
final dasResponse = await parcmeiService.emitirDas(202107);
```
**📖 [Documentação Completa](doc/parcmei_service.md)**

#### 🧮 SICALC - Sistema de Cálculos Tributários
```dart
final sicalcService = SicalcService(apiClient);

// Gerar DARF IRPF
final response = await sicalcService.gerarDarfPessoaFisica(
  contribuinteNumero: '00000000000',
  uf: 'SP',
  municipio: 3550308,
  dataPA: '20240101',
  vencimento: '20240215',
  valorImposto: 1000.0,
  dataConsolidacao: '20240215',
);
```
**📖 [Documentação Completa](doc/sicalc_service.md)**

#### 📬 Caixa Postal - Consulta de Mensagens da RFB
```dart
final caixaPostalService = CaixaPostalService(apiClient);

// Verificar mensagens novas
final temNovas = await caixaPostalService.temMensagensNovas('00000000000000');

// Listar mensagens não lidas
final mensagensResponse = await caixaPostalService.listarMensagensNaoLidas('00000000000000');
```
**📖 [Documentação Completa](doc/caixa_postal_service.md)**

#### 📋 Procurações - Gestão de Procurações Eletrônicas
```dart
final procuracoesService = ProcuracoesService(apiClient);

// Obter procuração PJ
final response = await procuracoesService.obterProcuracaoPj(
  '00000000000000', // CNPJ Outorgante
  '00000000000000', // CNPJ Procurador
);

// Validar e formatar documentos
final cpfValido = procuracoesService.isCpfValido('00000000000');
final cpfFormatado = procuracoesService.formatarCpf('00000000000');
```
**📖 [Documentação Completa](doc/procuracoes_service.md)**

#### 📊 SITFIS - Situação Fiscal do Contribuinte
```dart
final sitfisService = SitfisService(apiClient);

// Obter relatório completo
final response = await sitfisService.obterRelatorioCompleto(
  '00000000000000',
  maxTentativas: 5,
  callbackProgresso: (etapa, tempoEspera) {
    print('$etapa');
    if (tempoEspera != null) {
      print('Aguardando ${tempoEspera}ms...');
    }
  },
);

// Salvar PDF
if (response.isSuccess && response.hasPdf) {
  await sitfisService.salvarPdfEmArquivo(response, 'relatorio_sitfis.pdf');
}
```
**📖 [Documentação Completa](doc/sitfis_service.md)**

## Serviços Disponíveis

### Integra-SN (Simples Nacional)

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| DEFIS | `DefisService` | Declaração de Informações Socioeconômicas e Fiscais | [📖 DEFIS](doc/defis_service.md) |
| PGDASD | `PgdasdService` | Programa Gerador do DAS do Simples Nacional | [📖 PGDASD](doc/pgdasd_service.md) |
| DCTFWeb | `DctfWebService` | Declaração de Débitos e Créditos Tributários Federais | [📖 DCTFWeb](doc/dctfweb_service.md) |

### Integra-MEI

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| PGMEI | `PgmeiService` | Programa Gerador do DAS do MEI | [📖 PGMEI](doc/pgmei_service.md) |
| CCMEI | `CcmeiService` | Certificado da Condição de MEI | [📖 CCMEI](doc/ccmei_service.md) |
| PARCMEI | `ParcmeiService` | Parcelamento do MEI | [📖 PARCMEI](doc/parcmei_service.md) |

### Outros Serviços

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| SICALC | `SicalcService` | Sistema de Cálculos Tributários | [📖 SICALC](doc/sicalc_service.md) |
| Caixa Postal | `CaixaPostalService` | Consulta de mensagens da RFB | [📖 Caixa Postal](doc/caixa_postal_service.md) |
| Procurações | `ProcuracoesService` | Gestão de procurações eletrônicas | [📖 Procurações](doc/procuracoes_service.md) |
| SITFIS | `SitfisService` | Situação Fiscal do contribuinte | [📖 SITFIS](doc/sitfis_service.md) |

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Estrutura base para testes
final requestTeste = BaseRequest(
  contratante: Contratante(numero: cnpjTeste, tipo: 2),
  autorPedidoDados: AutorPedidoDados(numero: cnpjTeste, tipo: 2),
  contribuinte: Contribuinte(numero: cnpjTeste, tipo: 2),
  pedidoDados: PedidoDados(/* dados específicos do serviço */),
);
```

## Documentação Detalhada

### Serviços Principais
- [📖 DEFIS - Declaração de Informações Socioeconômicas e Fiscais](doc/defis_service.md)
- [📖 PGDASD - Programa Gerador do DAS do Simples Nacional](doc/pgdasd_service.md)
- [📖 DCTFWeb - Declaração de Débitos e Créditos Tributários Federais](doc/dctfweb_service.md)

### Serviços MEI
- [📖 PGMEI - Programa Gerador do DAS do MEI](doc/pgmei_service.md)
- [📖 CCMEI - Certificado da Condição de MEI](doc/ccmei_service.md)
- [📖 PARCMEI - Parcelamento do MEI](doc/parcmei_service.md)

### Serviços Auxiliares
- [📖 SICALC - Sistema de Cálculos Tributários](doc/sicalc_service.md)
- [📖 Caixa Postal - Consulta de Mensagens da RFB](doc/caixa_postal_service.md)
- [📖 Procurações - Gestão de Procurações Eletrônicas](doc/procuracoes_service.md)
- [📖 SITFIS - Situação Fiscal do Contribuinte](doc/sitfis_service.md)

### Recursos Adicionais
- [Exemplos de Uso](example/)
- [Testes](test/)

## Estrutura do Projeto

```
lib/
├── src/
│   ├── core/           # Classes base e autenticação
│   ├── models/         # Modelos de dados
│   │   ├── base/       # Modelos base
│   │   ├── defis/      # Modelos específicos do DEFIS
│   │   └── ...         # Outros serviços
│   └── services/       # Classes de serviço
├── doc/                # Documentação detalhada
├── example/            # Exemplos de uso
└── test/               # Testes unitários
```

## Limitações Conhecidas

1. **Certificado Digital**: A implementação atual não suporta mTLS com certificados digitais nativamente
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Cobertura de Serviços**: Implementação inicial focada no DEFIS, outros serviços em desenvolvimento

## Contribuição

Contribuições são bem-vindas! Por favor:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Implemente testes para novas funcionalidades
4. Envie um pull request

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## Suporte

Para dúvidas sobre a API do SERPRO, consulte:
- [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)

Para questões específicas deste package, abra uma issue no repositório.

---
