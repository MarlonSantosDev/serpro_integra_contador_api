# SERPRO Integra Contador API

Um package Dart completo para acessar todos os serviços da API do SERPRO Integra Contador.

## Visão Geral

O **SERPRO Integra Contador** é uma plataforma de serviços que fornece um conjunto de APIs para escritórios de contabilidade e demais empresas do ramo contábil, otimizando a prestação de serviços aos contribuintes.

Este package oferece uma interface Dart/Flutter para interagir com todos os serviços disponíveis, incluindo:

- **DEFIS** - Declaração de Informações Socioeconômicas e Fiscais
- **PGDASD** - Programa Gerador do DAS do Simples Nacional  
- **PGMEI** - Programa Gerador do DAS do MEI
- **CCMEI** - Certificado da Condição de Microempreendedor Individual
- **DCTFWeb** - Declaração de Débitos e Créditos Tributários Federais
- **MIT** - Módulo de Inclusão de Tributos
- **DTE** - Domicílio Tributário Eletrônico
- **PagtoWeb** - Sistema de Pagamentos Web
- **Eventos Atualização** - Monitoramento de Atualizações
- **Autentica Procurador** - Autenticação de Procuradores
- **Parcelamentos** - PARCMEI, PARCSN, PERTMEI, PERTSN, RELPMEI, RELPSN
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

#### 📋 DEFIS - Declaração de Informações Socioeconômicas e Fiscais
```dart
final defisService = DefisService(apiClient);

// Transmitir declaração usando enums tipados
final declaracao = TransmitirDeclaracaoRequest(
  ano: 2023,
  situacaoEspecial: SituacaoEspecial(
    tipoEvento: TipoEventoSituacaoEspecial.cisaoParcial,
    dataEvento: 20230101,
  ),
  inatividade: RegraInatividade.atividadesMaiorZero,
  empresa: Empresa(
    ganhoCapital: 0,
    qtdEmpregadoInicial: 1,
    qtdEmpregadoFinal: 1,
    receitaExportacaoDireta: 0,
    socios: [
      Socio(
        cpf: '00000000000',
        rendimentosIsentos: 10000,
        rendimentosTributaveis: 5000,
        participacaoCapitalSocial: 100,
        irRetidoFonte: 0,
      ),
    ],
    ganhoRendaVariavel: 0,
    estabelecimentos: [
      Estabelecimento(
        cnpjCompleto: '00000000000000',
        estoqueInicial: 1000,
        estoqueFinal: 2000,
        saldoCaixaInicial: 5000,
        saldoCaixaFinal: 15000,
        aquisicoesMercadoInterno: 10000,
        importacoes: 0,
        totalEntradasPorTransferencia: 0,
        totalSaidasPorTransferencia: 0,
        totalDevolucoesVendas: 100,
        totalEntradas: 10100,
        totalDevolucoesCompras: 50,
        totalDespesas: 8000,
        operacoesInterestaduais: [
          OperacaoInterestadual(
            uf: 'SP',
            valor: 5000.00,
            tipoOperacao: TipoOperacao.entrada,
          ),
        ],
      ),
    ],
  ),
);

// Transmitir declaração
final transmitirResponse = await defisService.transmitirDeclaracao(
  contribuinteNumero: '00000000000000',
  declaracaoData: declaracao,
);

// Consultar declarações transmitidas
final consultarResponse = await defisService.consultarDeclaracoesTransmitidas(
  contribuinteNumero: '00000000000000',
);

// Consultar última declaração por ano
final ultimaResponse = await defisService.consultarUltimaDeclaracao(
  contribuinteNumero: '00000000000000',
  ano: 2023,
);

// Consultar declaração específica
final especificaResponse = await defisService.consultarDeclaracaoEspecifica(
  contribuinteNumero: '00000000000000',
  idDefis: 12345,
);
```
**📖 [Documentação Completa](doc/defis_service.md)**

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

#### 🔐 Autentica Procurador - Autenticação de Procuradores
```dart
final autenticaProcuradorService = AutenticaProcuradorService(apiClient);

// Criar termo de autorização
final termo = await autenticaProcuradorService.criarTermoComDataAtual(
  contratanteNumero: '12345678000195',
  contratanteNome: 'Empresa Exemplo LTDA',
  autorPedidoDadosNumero: '98765432000100',
  autorPedidoDadosNome: 'Contador Exemplo',
);

// Assinar termo digitalmente
final xmlAssinado = await autenticaProcuradorService.assinarTermoDigital(termo);

// Autenticar procurador
final response = await autenticaProcuradorService.autenticarProcurador(
  xmlAssinado: xmlAssinado,
  contratanteNumero: '12345678000195',
  autorPedidoDadosNumero: '98765432000100',
);
```
**📖 [Documentação Completa](doc/autenticaprocurador_service.md)**

#### 🏠 DTE - Domicílio Tributário Eletrônico
```dart
final dteService = DteService(apiClient);

// Consultar indicador DTE
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.sucesso) {
  print('Status: ${response.statusEnquadramentoDescricao}');
  print('É optante DTE: ${response.isOptanteDte}');
}
```
**📖 [Documentação Completa](doc/dte_service.md)**

#### 📈 MIT - Módulo de Inclusão de Tributos
```dart
final mitService = MitService(apiClient);

// Criar apuração sem movimento
final response = await mitService.criarApuracaoSemMovimento(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
);

// Aguardar encerramento
final situacao = await mitService.aguardarEncerramento(
  contribuinteNumero: '12345678000195',
  protocoloEncerramento: response.dados.protocoloEncerramento,
);
```
**📖 [Documentação Completa](doc/mit_service.md)**

#### 💳 PagtoWeb - Sistema de Pagamentos Web
```dart
final pagtoWebService = PagtoWebService(apiClient);

// Consultar pagamentos por data
final response = await pagtoWebService.consultarPagamentosPorData(
  contribuinteNumero: '12345678000195',
  dataInicial: '2024-01-01',
  dataFinal: '2024-01-31',
);

// Emitir comprovante
final comprovante = await pagtoWebService.emitirComprovante(
  contribuinteNumero: '12345678000195',
  numeroDocumento: 'DOC123456',
);
```
**📖 [Documentação Completa](doc/pagtoweb_service.md)**

#### 📊 Eventos Atualização - Monitoramento de Atualizações
```dart
final eventosService = EventosAtualizacaoService(apiClient);

// Solicitar e obter eventos PF
final response = await eventosService.solicitarEObterEventosPF(
  cpfs: ['12345678901'],
  evento: TipoEvento.dctfweb,
);

// Monitorar múltiplos sistemas
final sistemas = [TipoEvento.dctfweb, TipoEvento.caixaPostal, TipoEvento.pagamentoWeb];
for (final sistema in sistemas) {
  final eventos = await eventosService.solicitarEObterEventosPJ(
    cnpjs: ['12345678000195'],
    evento: sistema,
  );
}
```
**📖 [Documentação Completa](doc/eventos_atualizacao_service.md)**

## Serviços Disponíveis

### Integra-SN (Simples Nacional)

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| DEFIS | `DefisService` | Declaração de Informações Socioeconômicas e Fiscais | [📖 DEFIS](doc/defis_service.md) |
| PGDASD | `PgdasdService` | Programa Gerador do DAS do Simples Nacional | [📖 PGDASD](doc/pgdasd_service.md) |
| DCTFWeb | `DctfWebService` | Declaração de Débitos e Créditos Tributários Federais | [📖 DCTFWeb](doc/dctfweb_service.md) |
| MIT | `MitService` | Módulo de Inclusão de Tributos | [📖 MIT](doc/mit_service.md) |
| DTE | `DteService` | Domicílio Tributário Eletrônico | [📖 DTE](doc/dte_service.md) |

### Integra-MEI

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| PGMEI | `PgmeiService` | Programa Gerador do DAS do MEI | [📖 PGMEI](doc/pgmei_service.md) |
| CCMEI | `CcmeiService` | Certificado da Condição de MEI | [📖 CCMEI](doc/ccmei_service.md) |
| PARCMEI | `ParcmeiService` | Parcelamento do MEI | [📖 PARCMEI](doc/parcmei_service.md) |
| PARCMEI-ESP | `ParcmeiEspecialService` | Parcelamento Especial do MEI | [📖 PARCMEI-ESP](doc/parcmei_especial_service.md) |
| PERTMEI | `PertmeiService` | Parcelamento Especial de Regularização Tributária para MEI | [📖 PERTMEI](doc/pertmei_service.md) |
| RELPMEI | `RelpmeiService` | Parcelamento do MEI (Receita Federal) | [📖 RELPMEI](doc/relpmei_service.md) |

### Parcelamentos e Regularizações

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| PARCSN | `ParcsnService` | Parcelamento do Simples Nacional | [📖 PARCSN](doc/parcsn_service.md) |
| PARCSN-ESP | `ParcsnEspecialService` | Parcelamento Especial do Simples Nacional | [📖 PARCSN-ESP](doc/parcsn_especial_service.md) |
| PERTSN | `PertsnService` | Parcelamento do Simples Nacional | [📖 PERTSN](doc/pertsn_service.md) |
| RELPSN | `RelpsnService` | Parcelamento do Simples Nacional (Receita Federal) | [📖 RELPSN](doc/relpsn_service.md) |

### Serviços Auxiliares

| Serviço | Classe | Descrição | Documentação |
|---------|--------|-----------|--------------|
| SICALC | `SicalcService` | Sistema de Cálculos Tributários | [📖 SICALC](doc/sicalc_service.md) |
| Caixa Postal | `CaixaPostalService` | Consulta de mensagens da RFB | [📖 Caixa Postal](doc/caixa_postal_service.md) |
| Procurações | `ProcuracoesService` | Gestão de procurações eletrônicas | [📖 Procurações](doc/procuracoes_service.md) |
| SITFIS | `SitfisService` | Situação Fiscal do contribuinte | [📖 SITFIS](doc/sitfis_service.md) |
| PagtoWeb | `PagtoWebService` | Sistema de Pagamentos Web | [📖 PagtoWeb](doc/pagtoweb_service.md) |
| Eventos Atualização | `EventosAtualizacaoService` | Monitoramento de Atualizações | [📖 Eventos](doc/eventos_atualizacao_service.md) |
| Autentica Procurador | `AutenticaProcuradorService` | Autenticação de Procuradores | [📖 Autentica Procurador](doc/autenticaprocurador_service.md) |

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Estrutura base para testes (usando a nova API simplificada)
final requestTeste = BaseRequest(
  contribuinteNumero: cnpjTeste,
  pedidoDados: PedidoDados(
    idSistema: 'SISTEMA_EXEMPLO',
    idServico: 'SERVICO_EXEMPLO',
    dados: 'dados_do_servico',
  ),
);
```

## Documentação Detalhada

### Serviços Principais (Simples Nacional)
- [📖 DEFIS - Declaração de Informações Socioeconômicas e Fiscais](doc/defis_service.md)
- [📖 PGDASD - Programa Gerador do DAS do Simples Nacional](doc/pgdasd_service.md)
- [📖 DCTFWeb - Declaração de Débitos e Créditos Tributários Federais](doc/dctfweb_service.md)
- [📖 MIT - Módulo de Inclusão de Tributos](doc/mit_service.md)
- [📖 DTE - Domicílio Tributário Eletrônico](doc/dte_service.md)

### Serviços MEI
- [📖 PGMEI - Programa Gerador do DAS do MEI](doc/pgmei_service.md)
- [📖 CCMEI - Certificado da Condição de MEI](doc/ccmei_service.md)
- [📖 PARCMEI - Parcelamento do MEI](doc/parcmei_service.md)
- [📖 PARCMEI-ESP - Parcelamento Especial do MEI](doc/parcmei_especial_service.md)
- [📖 PERTMEI - Parcelamento Especial de Regularização Tributária para MEI](doc/pertmei_service.md)
- [📖 RELPMEI - Parcelamento do MEI (Receita Federal)](doc/relpmei_service.md)

### Parcelamentos e Regularizações
- [📖 PARCSN - Parcelamento do Simples Nacional](doc/parcsn_service.md)
- [📖 PARCSN-ESP - Parcelamento Especial do Simples Nacional](doc/parcsn_especial_service.md)
- [📖 PERTSN - Parcelamento do Simples Nacional](doc/pertsn_service.md)
- [📖 RELPSN - Parcelamento do Simples Nacional (Receita Federal)](doc/relpsn_service.md)

### Serviços Auxiliares
- [📖 SICALC - Sistema de Cálculos Tributários](doc/sicalc_service.md)
- [📖 Caixa Postal - Consulta de Mensagens da RFB](doc/caixa_postal_service.md)
- [📖 Procurações - Gestão de Procurações Eletrônicas](doc/procuracoes_service.md)
- [📖 SITFIS - Situação Fiscal do Contribuinte](doc/sitfis_service.md)
- [📖 PagtoWeb - Sistema de Pagamentos Web](doc/pagtoweb_service.md)
- [📖 Eventos Atualização - Monitoramento de Atualizações](doc/eventos_atualizacao_service.md)
- [📖 Autentica Procurador - Autenticação de Procuradores](doc/autenticaprocurador_service.md)

### Recursos Adicionais
- [Exemplos de Uso](example/)

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
└── example/            # Exemplos de uso
```

## Limitações Conhecidas

1. **Certificado Digital**: A implementação atual não suporta mTLS com certificados digitais nativamente
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Documentação**: Alguns serviços de parcelamento ainda estão em desenvolvimento de documentação

## Contribuição

Contribuições são bem-vindas! Por favor:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Implemente testes para novas funcionalidades
4. Envie um pull request

## Licença

Este projeto está licenciado sob a licença MIT.

**Desenvolvedor:** Marlon Santos
**E-mail:** marlon-20-12@hotmail.com

## Suporte

Para dúvidas sobre a API do SERPRO, consulte:
- [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)

Para questões específicas deste package, abra uma issue no repositório.

---
