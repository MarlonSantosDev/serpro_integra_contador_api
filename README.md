# SERPRO Integra Contador API - Dart Package

[![pub package](https://img.shields.io/pub/v/serpro_integra_contador_api.svg)](https://pub.dev/packages/serpro_integra_contador_api)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Package Dart para integração completa com a API do SERPRO Integra Contador, fornecendo uma interface type-safe para todos os serviços disponíveis da Receita Federal do Brasil.

## 🚀 Características Principais

- **Autenticação automática** com certificados cliente (mTLS)
- **Cache inteligente** de tokens de procurador
- **Validação automática** de documentos (CPF/CNPJ) com utilitários centralizados
- **Tratamento de erros** padronizado e robusto
- **Suporte completo** a procurações eletrônicas
- **Modelos de dados** type-safe para todas as operações
- **Flexibilidade de contratante e autor do pedido**: Todos os serviços suportam parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero`
- **Documentação completa** com exemplos práticos e anotações `@formatador_utils` e `@validacoes_utils`
- **Suporte a múltiplos ambientes** (trial e produção)
- **Utilitários centralizados** para validações e formatação
- **Exemplos completos** para todos os serviços com entrada e saída detalhadas

## 📋 Serviços Disponíveis

### 🏢 Serviços de Microempreendedor Individual (MEI)
- **CCMEI**: Certificado da Condição de Microempreendedor Individual
- **PGMEI**: Pagamento de DAS do MEI
- **PARCMEI**: Parcelamento do MEI
- **PARCMEI Especial**: Parcelamento Especial do MEI
- **PERTMEI**: Pertinência do MEI
- **RELPMEI**: Relatório de Pagamentos do MEI

### 🏛️ Serviços do Simples Nacional
- **PARCSN**: Parcelamento do Simples Nacional
- **PARCSN Especial**: Parcelamento Especial do Simples Nacional
- **PERTSN**: Pertinência do Simples Nacional
- **RELPSN**: Relatório de Pagamentos do Simples Nacional

### 📊 Serviços Tributários Gerais
- **DCTFWeb**: Declaração de Débitos e Créditos Tributários Federais
- **DEFIS**: Declaração de Informações Socioeconômicas e Fiscais
- **SICALC**: Sistema de Cálculo de Impostos
- **SITFIS**: Sistema de Informações Tributárias Fiscais
- **MIT**: Módulo de Inclusão de Tributos
- **PGDASD**: Pagamento de DAS por Débito Direto Autorizado

### 📬 Serviços de Comunicação
- **Caixa Postal**: Consulta de mensagens da Receita Federal
- **Eventos de Atualização**: Monitoramento de atualizações em sistemas

### 🔐 Serviços de Autenticação e Procuração
- **Autentica Procurador**: Gestão de autenticação de procuradores
- **Procurações**: Gestão de procurações eletrônicas

### 🏠 Serviços Especiais
- **DTE**: Domicílio Tributário Eletrônico
- **PagtoWeb**: Consulta de pagamentos e emissão de comprovantes

## 🔧 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  serpro_integra_contador_api: ^1.0.0
```

Execute:

```bash
flutter pub get
```

## 💡 Uso Básico

### Autenticação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Inicializar cliente da API
  final apiClient = ApiClient();

  // Autenticar com certificados
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    contratanteNumero: '12345678000100',
    autorPedidoDadosNumero: '12345678000100',
    ambiente: 'trial', // ou 'producao'
  );
}
```

### Usando Serviços com Valores Padrão

```dart
// Usar valores padrão da autenticação
final ccmeiService = CcmeiService(apiClient);
final response = await ccmeiService.emitirCcmei('12345678000100');
print('CCMEI emitido: ${response.dados.pdf.isNotEmpty}');
```

### Usando Serviços com Valores Específicos

```dart
// Usar valores específicos para esta requisição
final sicalcService = SicalcService(apiClient);
final darfResponse = await sicalcService.consolidarEGerarDarf(
  contribuinteNumero: '12345678000100',
  contratanteNumero: '98765432000100', // Valor específico
  autorPedidoDadosNumero: '11122233344', // Valor específico
  uf: 'SP',
  municipio: 3550308,
  codigoReceita: 190,
  codigoReceitaExtensao: 1,
  dataPA: '2024-01',
  vencimento: '2024-02-15',
  valorImposto: 1000.00,
  dataConsolidacao: '2024-01-15',
);
```

## 🔄 Flexibilidade de Contratante e Autor do Pedido

Todos os serviços da biblioteca suportam parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero`. Isso permite:

### Cenários de Uso

1. **Valores Padrão**: Quando não especificados, usa os valores definidos na autenticação
2. **Valores Específicos**: Permite usar diferentes contratantes ou autores para requisições específicas
3. **Contextos Múltiplos**: Ideal para sistemas que atendem múltiplos clientes ou contextos

### Exemplos Práticos

```dart
// Consulta DTE com valores padrão
final dteService = DteService(apiClient);
final dteResponse = await dteService.obterIndicadorDte('12345678000100');

// Consulta DTE com contratante específico
final dteResponse2 = await dteService.obterIndicadorDte(
  '12345678000100',
  contratanteNumero: '98765432000100',
  autorPedidoDadosNumero: '11122233344',
);

// Caixa Postal com autor específico
final caixaPostalService = CaixaPostalService(apiClient);
final mensagens = await caixaPostalService.listarTodasMensagens(
  '12345678000100',
  contratanteNumero: '98765432000100',
);
```

## 🛠️ Utilitários Centralizados

### Validações Utilitárias

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

// Validar CNPJ
final isValidCnpj = ValidacoesUtils.isValidCnpj('12345678000195');

// Validar CPF
final isValidCpf = ValidacoesUtils.isValidCpf('12345678901');

// Validar número de parcelamento
final error = ValidacoesUtils.validarNumeroParcelamento(123456);
if (error != null) {
  print('Erro: $error');
}

// Validar ano/mês
final errorAnoMes = ValidacoesUtils.validarAnoMes(202401);
if (errorAnoMes != null) {
  print('Erro: $errorAnoMes');
}

// Validar valor monetário
final errorValor = ValidacoesUtils.validarValorMonetario(1000.50);
if (errorValor != null) {
  print('Erro: $errorValor');
}
```

### Formatação Utilitária

```dart
// Formatar CNPJ
final cnpjFormatado = FormatadorUtils.formatCnpj('12345678000195');
// Resultado: 12.345.678/0001-95

// Formatar CPF
final cpfFormatado = FormatadorUtils.formatCpf('12345678901');
// Resultado: 123.456.789-01

// Formatar moeda
final valorFormatado = FormatadorUtils.formatCurrency(1234.56);
// Resultado: R$ 1.234,56

// Formatar data
final dataFormatada = FormatadorUtils.formatDateFromString('20240115');
// Resultado: 15/01/2024

// Formatar período
final periodoFormatado = FormatadorUtils.formatPeriodFromString('202401');
// Resultado: Janeiro/2024
```

## 📚 Documentação Completa

### Documentação dos Serviços

- [Autentica Procurador Service](doc/autenticaprocurador_service.md) - Gestão de autenticação de procuradores
- [Caixa Postal Service](doc/caixa_postal_service.md) - Consulta de mensagens da RFB
- [CCMEI Service](doc/ccmei_service.md) - Certificado da Condição de MEI
- [DCTFWeb Service](doc/dctfweb_service.md) - Declaração de Débitos e Créditos Tributários
- [DEFIS Service](doc/defis_service.md) - Declaração de Informações Socioeconômicas e Fiscais
- [DTE Service](doc/dte_service.md) - Domicílio Tributário Eletrônico
- [Eventos Atualização Service](doc/eventos_atualizacao_service.md) - Monitoramento de atualizações
- [MIT Service](doc/mit_service.md) - Módulo de Inclusão de Tributos
- [PagtoWeb Service](doc/pagtoweb_service.md) - Consulta de pagamentos
- [PARCMEI Service](doc/parcmei_service.md) - Parcelamento do MEI
- [PARCMEI Especial Service](doc/parcmei_especial_service.md) - Parcelamento Especial do MEI
- [PARCSN Service](doc/parcsn_service.md) - Parcelamento do Simples Nacional
- [PARCSN Especial Service](doc/parcsn_especial_service.md) - Parcelamento Especial do Simples Nacional
- [PERTMEI Service](doc/pertmei_service.md) - Pertinência do MEI
- [PERTSN Service](doc/pertsn_service.md) - Pertinência do Simples Nacional
- [PGDASD Service](doc/pgdasd_service.md) - Pagamento de DAS por Débito Direto Autorizado
- [PGMEI Service](doc/pgmei_service.md) - Pagamento de DAS do MEI
- [Procurações Service](doc/procuracoes_service.md) - Gestão de procurações eletrônicas
- [RELPMEI Service](doc/relpmei_service.md) - Relatório de Pagamentos do MEI
- [RELPSN Service](doc/relpsn_service.md) - Relatório de Pagamentos do Simples Nacional
- [SICALC Service](doc/sicalc_service.md) - Sistema de Cálculo de Impostos
- [SITFIS Service](doc/sitfis_service.md) - Sistema de Informações Tributárias Fiscais

### Guias de Início Rápido

#### 1. Primeiro Uso - Consultar CCMEI

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    ambiente: 'trial',
  );

  // Consultar CCMEI
  final ccmeiService = CcmeiService(apiClient);
  final response = await ccmeiService.emitirCcmei('00000000000000');
  
  if (response.sucesso) {
    print('CCMEI emitido com sucesso!');
    print('Número: ${response.dados?.numeroCertificado}');
    
    // Salvar PDF
    if (response.dados?.pdf.isNotEmpty == true) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados!.pdf,
        'ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
}
```

#### 2. Gerar DARF com SICALC

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    ambiente: 'trial',
  );

  // Gerar DARF
  final sicalcService = SicalcService(apiClient);
  final response = await sicalcService.gerarDarfPessoaFisica(
    contribuinteNumero: '00000000000',
    uf: 'SP',
    municipio: 3550308,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.0,
    dataConsolidacao: '20240215',
  );
  
  if (response.sucesso) {
    print('DARF gerado com sucesso!');
    print('Número: ${response.dados?.numeroDocumento}');
    print('Valor total: R\$ ${response.dados?.valorTotal}');
  }
}
```

#### 3. Consultar Caixa Postal

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    ambiente: 'trial',
  );

  // Consultar caixa postal
  final caixaPostalService = CaixaPostalService(apiClient);
  final response = await caixaPostalService.listarTodasMensagens('00000000000000');
  
  if (response.sucesso) {
    print('Mensagens encontradas: ${response.dadosParsed?.mensagens.length ?? 0}');
    for (final mensagem in response.dadosParsed?.mensagens ?? []) {
      print('Assunto: ${mensagem.assunto}');
      print('Data: ${mensagem.dataEnvio}');
    }
  }
}
```

## 🛠️ Configuração Avançada

### Configuração de Ambiente

```dart
// Ambiente Trial (desenvolvimento)
final apiClient = ApiClient();

await apiClient.authenticate(
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret',
  certPath: 'caminho/para/certificado.p12',
  certPassword: 'senha_do_certificado',
  ambiente: 'trial', // Usa URL de trial
);

// Ambiente Produção
await apiClient.authenticate(
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret',
  certPath: 'caminho/para/certificado.p12',
  certPassword: 'senha_do_certificado',
  ambiente: 'producao', // Usa URL de produção
);
```

### Configuração de Timeout

```dart
final apiClient = ApiClient(
  timeout: Duration(seconds: 30),
);
```

### Configuração de Logs

```dart
final apiClient = ApiClient(
  enableLogs: true,
  logLevel: LogLevel.debug,
);
```

## 🔒 Segurança

### Certificados Digitais

O package suporta certificados ICP-Brasil nos formatos:
- **A1**: Arquivo .p12/.pfx
- **A3**: Token/cartão inteligente

### Validação de Documentos

```dart
// Validar CNPJ
final isValidCnpj = ValidacoesUtils.isValidCnpj('12345678000195');

// Validar CPF
final isValidCpf = ValidacoesUtils.isValidCpf('12345678901');

// Formatar documento
final cnpjFormatado = FormatadorUtils.formatCnpj('12345678000195');
// Resultado: 12.345.678/0001-95
```

## 📊 Tratamento de Erros

### Estrutura Padrão de Resposta

```dart
class ApiResponse<T> {
  final bool sucesso;
  final String? mensagemErro;
  final T? dados;
  final List<MensagemNegocio> mensagens;
}
```

### Tratamento de Erros Comum

```dart
try {
  final response = await service.metodoExemplo();
  
  if (response.sucesso) {
    // Processar dados
    print('Sucesso: ${response.dados}');
  } else {
    // Tratar erro
    print('Erro: ${response.mensagemErro}');
    
    // Analisar mensagens específicas
    for (final mensagem in response.mensagens) {
      if (mensagem.isErro) {
        print('Código: ${mensagem.codigo}');
        print('Texto: ${mensagem.texto}');
      }
    }
  }
} catch (e) {
  print('Exceção: $e');
}
```

## 🧪 Testes

### Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Dados de teste comuns
const ufTeste = 'SP';
const municipioTeste = 3550308; // São Paulo
const codigoReceitaTeste = 190; // IRPF
```

### Exemplo de Teste

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() {
  group('CCMEI Service Tests', () {
    late ApiClient apiClient;
    late CcmeiService ccmeiService;

    setUp(() {
      apiClient = ApiClient();
      ccmeiService = CcmeiService(apiClient);
    });

    test('deve emitir CCMEI com sucesso', () async {
      // Arrange
      const cnpj = '00000000000000';
      
      // Act
      final response = await ccmeiService.emitirCcmei(cnpj);
      
      // Assert
      expect(response.sucesso, isTrue);
      expect(response.dados, isNotNull);
    });
  });
}
```

## 🚀 Performance e Otimização

### Cache de Tokens

O package implementa cache automático de tokens de procurador:

```dart
// Verificar cache antes de autenticar
final cache = await autenticaProcuradorService.verificarCacheToken(
  contratanteNumero: '12345678000195',
  autorPedidoDadosNumero: '98765432000100',
);

if (cache != null && cache.isTokenValido) {
  print('Token válido encontrado no cache');
} else {
  print('Necessário obter novo token');
}
```

### Requisições em Lote

```dart
// Consultar múltiplos contribuintes
final cpfs = ['12345678901', '98765432109', '11122233344'];
final eventos = await eventosAtualizacaoService.solicitarEObterEventosPF(
  cpfs: cpfs,
  evento: TipoEvento.dctfweb,
);
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Erro de Certificado

```
Erro: Certificado digital inválido
```

**Solução**: Verificar se o certificado é válido ICP-Brasil e se a senha está correta.

#### 2. Erro de Autenticação

```
Erro: Consumer Key/Secret inválidos
```

**Solução**: Verificar as credenciais no Portal do Cliente SERPRO.

#### 3. Erro de Timeout

```
Erro: Timeout na requisição
```

**Solução**: Aumentar o timeout ou verificar a conexão de rede.

### Logs de Debug

```dart
final apiClient = ApiClient(
  enableLogs: true,
  logLevel: LogLevel.debug,
);
```

## 📈 Roadmap

### Próximas Funcionalidades

- [ ] Suporte a certificados A3 nativos
- [ ] Cache persistente de tokens
- [ ] Retry automático em falhas temporárias
- [ ] Métricas de performance
- [ ] Suporte a webhooks
- [ ] Interface gráfica para testes


## 🤝 Contribuição

Contribuições são bem-vindas!

### Padrões de Código

- Siga as convenções do Dart/Flutter
- Adicione testes para novas funcionalidades
- Atualize a documentação
- Use commits semânticos

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

### Documentação Oficial

- [SERPRO Integra Contador API](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)

### Comunidade

- [Issues do GitHub](https://github.com/MarlonSantosDev/serpro_integra_contador_api/issues)
- [Discussões](https://github.com/MarlonSantosDev/serpro_integra_contador_api/discussions)

### Contato

Para suporte técnico específico:
- Email: marlon-20-12@hotmail.com

---

**Desenvolvido com ❤️ para a comunidade brasileira de desenvolvedores**