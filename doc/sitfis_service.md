# SITFIS - Sistema de Informações Tributárias Fiscais

## Visão Geral

O serviço SITFIS permite consultar informações tributárias e fiscais de contribuintes, incluindo consulta de situação fiscal, consulta de débitos, consulta de créditos e consulta de informações gerais do contribuinte.

## Funcionalidades

- **Consultar Situação Fiscal**: Consulta da situação fiscal do contribuinte
- **Consultar Débitos**: Consulta de débitos tributários
- **Consultar Créditos**: Consulta de créditos tributários
- **Consultar Informações Gerais**: Consulta de informações gerais do contribuinte
- **Validações**: Validações específicas do sistema SITFIS

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço SITFIS

### Autenticação

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

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final sitfisService = SitfisService(apiClient);
```

### 2. Consultar Situação Fiscal

```dart
try {
  final response = await sitfisService.consultarSituacaoFiscal('00000000000000');
  
  if (response.sucesso) {
    print('Situação fiscal encontrada!');
    print('CNPJ: ${response.dadosParsed?.cnpj}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Data de consulta: ${response.dadosParsed?.dataConsultaFormatada}');
    print('Regime tributário: ${response.dadosParsed?.regimeTributario}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar situação fiscal: $e');
}
```

### 3. Consultar Débitos

```dart
try {
  final response = await sitfisService.consultarDebitos('00000000000000');
  
  if (response.sucesso) {
    print('Débitos encontrados: ${response.dadosParsed?.listaDebitos.length ?? 0}');
    
    for (final debito in response.dadosParsed?.listaDebitos ?? []) {
      print('Débito: ${debito.numeroDocumento}');
      print('Valor: ${debito.valorFormatado}');
      print('Vencimento: ${debito.dataVencimentoFormatada}');
      print('Situação: ${debito.situacao}');
    }
    
    print('Valor total: ${response.valorTotalDebitosFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar débitos: $e');
}
```

### 4. Consultar Créditos

```dart
try {
  final response = await sitfisService.consultarCreditos('00000000000000');
  
  if (response.sucesso) {
    print('Créditos encontrados: ${response.dadosParsed?.listaCreditos.length ?? 0}');
    
    for (final credito in response.dadosParsed?.listaCreditos ?? []) {
      print('Crédito: ${credito.numeroDocumento}');
      print('Valor: ${credito.valorFormatado}');
      print('Data: ${credito.dataFormatada}');
      print('Situação: ${credito.situacao}');
    }
    
    print('Valor total: ${response.valorTotalCreditosFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar créditos: $e');
}
```

### 5. Consultar Informações Gerais

```dart
try {
  final response = await sitfisService.consultarInformacoesGerais('00000000000000');
  
  if (response.sucesso) {
    print('Informações gerais encontradas!');
    print('Razão social: ${response.dadosParsed?.razaoSocial}');
    print('Nome fantasia: ${response.dadosParsed?.nomeFantasia}');
    print('Regime tributário: ${response.dadosParsed?.regimeTributario}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Data de abertura: ${response.dadosParsed?.dataAberturaFormatada}');
    print('Capital social: ${response.dadosParsed?.capitalSocialFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar informações gerais: $e');
}
```

## Estrutura de Dados

### ConsultarSituacaoFiscalResponse

```dart
class ConsultarSituacaoFiscalResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarSituacaoFiscalDados? dadosParsed;
}

class ConsultarSituacaoFiscalDados {
  final String cnpj;
  final String situacao;
  final String dataConsultaFormatada;
  final String regimeTributario;
  // ... outros campos
}
```

### ConsultarDebitosResponse

```dart
class ConsultarDebitosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarDebitosDados? dadosParsed;
  final String valorTotalDebitosFormatado;
}

class ConsultarDebitosDados {
  final List<DebitoItem> listaDebitos;
  // ... outros campos
}

class DebitoItem {
  final String numeroDocumento;
  final String valorFormatado;
  final String dataVencimentoFormatada;
  final String situacao;
  // ... outros campos
}
```

### ConsultarCreditosResponse

```dart
class ConsultarCreditosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarCreditosDados? dadosParsed;
  final String valorTotalCreditosFormatado;
}

class ConsultarCreditosDados {
  final List<CreditoItem> listaCreditos;
  // ... outros campos
}

class CreditoItem {
  final String numeroDocumento;
  final String valorFormatado;
  final String dataFormatada;
  final String situacao;
  // ... outros campos
}
```

### ConsultarInformacoesGeraisResponse

```dart
class ConsultarInformacoesGeraisResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarInformacoesGeraisDados? dadosParsed;
}

class ConsultarInformacoesGeraisDados {
  final String razaoSocial;
  final String nomeFantasia;
  final String regimeTributario;
  final String situacao;
  final String dataAberturaFormatada;
  final String capitalSocialFormatado;
  // ... outros campos
}
```

## Validações Disponíveis

O serviço SITFIS inclui várias validações para garantir a integridade dos dados:

```dart
// Validar CNPJ do contribuinte
final erro = sitfisService.validarCnpjContribuinte('00000000000000');
if (erro != null) {
  print('Erro: $erro');
}

// Validar CPF do contribuinte
final erroCpf = sitfisService.validarCpfContribuinte('00000000000');
if (erroCpf != null) {
  print('Erro: $erroCpf');
}

// Validar período de consulta
final erroPeriodo = sitfisService.validarPeriodoConsulta('2024-01-01', '2024-12-31');
if (erroPeriodo != null) {
  print('Erro: $erroPeriodo');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do SITFIS:

```dart
// Analisar erro
final analise = sitfisService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (sitfisService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = sitfisService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ/CPF inválido | Verificar formato do documento |
| 003 | Contribuinte não encontrado | Verificar se contribuinte existe |
| 004 | Período inválido | Verificar formato do período |
| 005 | Acesso negado | Verificar permissões de acesso |

## Exemplos Práticos

### Exemplo Completo - Consulta Completa

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret', 
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );
  
  // 2. Criar serviço
  final sitfisService = SitfisService(apiClient);
  
  // 3. Consulta completa
  try {
    const contribuinteNumero = '00000000000000';
    
    // Consultar situação fiscal
    print('=== Situação Fiscal ===');
    final situacao = await sitfisService.consultarSituacaoFiscal(contribuinteNumero);
    if (situacao.sucesso) {
      print('Situação: ${situacao.dadosParsed?.situacao}');
      print('Regime: ${situacao.dadosParsed?.regimeTributario}');
    }
    
    // Consultar débitos
    print('\n=== Débitos ===');
    final debitos = await sitfisService.consultarDebitos(contribuinteNumero);
    if (debitos.sucesso) {
      print('Total de débitos: ${debitos.dadosParsed?.listaDebitos.length ?? 0}');
      print('Valor total: ${debitos.valorTotalDebitosFormatado}');
    }
    
    // Consultar créditos
    print('\n=== Créditos ===');
    final creditos = await sitfisService.consultarCreditos(contribuinteNumero);
    if (creditos.sucesso) {
      print('Total de créditos: ${creditos.dadosParsed?.listaCreditos.length ?? 0}');
      print('Valor total: ${creditos.valorTotalCreditosFormatado}');
    }
    
    // Consultar informações gerais
    print('\n=== Informações Gerais ===');
    final info = await sitfisService.consultarInformacoesGerais(contribuinteNumero);
    if (info.sucesso) {
      print('Razão social: ${info.dadosParsed?.razaoSocial}');
      print('Nome fantasia: ${info.dadosParsed?.nomeFantasia}');
      print('Capital social: ${info.dadosParsed?.capitalSocialFormatado}');
    }
    
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Períodos de teste
const dataInicial = '2024-01-01';
const dataFinal = '2024-12-31';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Acesso**: Algumas informações podem ter restrições de acesso
5. **Período**: Consultas podem ter limitações de período

## Casos de Uso Comuns

### 1. Consulta Completa de Contribuinte

```dart
Future<void> consultarContribuinteCompleto(String contribuinteNumero) async {
  try {
    // Consultar situação fiscal
    final situacao = await sitfisService.consultarSituacaoFiscal(contribuinteNumero);
    if (!situacao.sucesso) return;
    
    // Consultar débitos
    final debitos = await sitfisService.consultarDebitos(contribuinteNumero);
    if (!debitos.sucesso) return;
    
    // Consultar créditos
    final creditos = await sitfisService.consultarCreditos(contribuinteNumero);
    if (!creditos.sucesso) return;
    
    // Consultar informações gerais
    final info = await sitfisService.consultarInformacoesGerais(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório Completo ===');
    print('Contribuinte: ${contribuinteNumero}');
    print('Situação: ${situacao.dadosParsed?.situacao}');
    print('Regime: ${situacao.dadosParsed?.regimeTributario}');
    print('Débitos: ${debitos.valorTotalDebitosFormatado}');
    print('Créditos: ${creditos.valorTotalCreditosFormatado}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Monitoramento de Débitos

```dart
Future<void> monitorarDebitos(String contribuinteNumero) async {
  try {
    // Consultar débitos
    final debitos = await sitfisService.consultarDebitos(contribuinteNumero);
    if (!debitos.sucesso) return;
    
    final listaDebitos = debitos.dadosParsed?.listaDebitos ?? [];
    
    for (final debito in listaDebitos) {
      final vencimento = DateTime.tryParse(debito.dataVencimentoFormatada);
      if (vencimento != null) {
        final diasParaVencimento = vencimento.difference(DateTime.now()).inDays;
        
        if (diasParaVencimento <= 5) {
          print('⚠️ Débito ${debito.numeroDocumento} vence em $diasParaVencimento dias');
          print('Valor: ${debito.valorFormatado}');
        }
      }
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

### 3. Relatório de Situação Fiscal

```dart
Future<void> relatorioSituacaoFiscal(String contribuinteNumero) async {
  try {
    // Consultar situação fiscal
    final situacao = await sitfisService.consultarSituacaoFiscal(contribuinteNumero);
    if (!situacao.sucesso) return;
    
    // Consultar informações gerais
    final info = await sitfisService.consultarInformacoesGerais(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Situação Fiscal ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Nome fantasia: ${info.dadosParsed?.nomeFantasia}');
    print('Situação: ${situacao.dadosParsed?.situacao}');
    print('Regime tributário: ${situacao.dadosParsed?.regimeTributario}');
    print('Data de abertura: ${info.dadosParsed?.dataAberturaFormatada}');
    print('Capital social: ${info.dadosParsed?.capitalSocialFormatado}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Integração com Outros Serviços

O SITFIS Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas
- **MIT Service**: Para consultar apurações relacionadas
- **Eventos Atualização Service**: Para monitorar atualizações
- **Caixa Postal Service**: Para consultar mensagens relacionadas

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de informações fiscais
- Monitorar consultas de débitos e créditos
- Alertar sobre débitos próximos do vencimento
- Rastrear erros de validação
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço SITFIS:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package