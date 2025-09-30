# RELPMEI - Relatório de Pagamentos do MEI

## Visão Geral

O serviço RELPMEI permite consultar relatórios de pagamentos de Microempreendedores Individuais (MEI), incluindo consulta de pagamentos realizados, consulta de pagamentos pendentes e consulta de informações detalhadas de pagamentos.

## Funcionalidades

- **Consultar Pagamentos Realizados**: Consulta de pagamentos já realizados pelo MEI
- **Consultar Pagamentos Pendentes**: Consulta de pagamentos pendentes
- **Consultar Informações Detalhadas**: Consulta de informações detalhadas de pagamentos
- **Validações**: Validações específicas do sistema RELPMEI

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço RELPMEI

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
final relpmeiService = RelpmeiService(apiClient);
```

### 2. Consultar Pagamentos Realizados

```dart
try {
  final response = await relpmeiService.consultarPagamentosRealizados('00000000000000');
  
  if (response.sucesso) {
    print('Pagamentos realizados: ${response.dadosParsed?.listaPagamentos.length ?? 0}');
    
    for (final pagamento in response.dadosParsed?.listaPagamentos ?? []) {
      print('Pagamento: ${pagamento.numeroDocumento}');
      print('Valor: ${pagamento.valorFormatado}');
      print('Data: ${pagamento.dataPagamentoFormatada}');
      print('Situação: ${pagamento.situacao}');
    }
    
    print('Valor total: ${response.valorTotalPagamentosFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar pagamentos realizados: $e');
}
```

### 3. Consultar Pagamentos Pendentes

```dart
try {
  final response = await relpmeiService.consultarPagamentosPendentes('00000000000000');
  
  if (response.sucesso) {
    print('Pagamentos pendentes: ${response.dadosParsed?.listaPagamentos.length ?? 0}');
    
    for (final pagamento in response.dadosParsed?.listaPagamentos ?? []) {
      print('Pagamento: ${pagamento.numeroDocumento}');
      print('Valor: ${pagamento.valorFormatado}');
      print('Vencimento: ${pagamento.dataVencimentoFormatada}');
      print('Situação: ${pagamento.situacao}');
    }
    
    print('Valor total: ${response.valorTotalPagamentosFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar pagamentos pendentes: $e');
}
```

### 4. Consultar Informações Detalhadas

```dart
try {
  final response = await relpmeiService.consultarInformacoesDetalhadas('00000000000000');
  
  if (response.sucesso) {
    print('Informações detalhadas encontradas!');
    print('CNPJ: ${response.dadosParsed?.cnpj}');
    print('Razão social: ${response.dadosParsed?.razaoSocial}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Regime tributário: ${response.dadosParsed?.regimeTributario}');
    print('Data de abertura: ${response.dadosParsed?.dataAberturaFormatada}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar informações detalhadas: $e');
}
```

## Estrutura de Dados

### ConsultarPagamentosRealizadosResponse

```dart
class ConsultarPagamentosRealizadosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarPagamentosRealizadosDados? dadosParsed;
  final String valorTotalPagamentosFormatado;
}

class ConsultarPagamentosRealizadosDados {
  final List<PagamentoItem> listaPagamentos;
  // ... outros campos
}

class PagamentoItem {
  final String numeroDocumento;
  final String valorFormatado;
  final String dataPagamentoFormatada;
  final String situacao;
  // ... outros campos
}
```

### ConsultarPagamentosPendentesResponse

```dart
class ConsultarPagamentosPendentesResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarPagamentosPendentesDados? dadosParsed;
  final String valorTotalPagamentosFormatado;
}

class ConsultarPagamentosPendentesDados {
  final List<PagamentoItem> listaPagamentos;
  // ... outros campos
}

class PagamentoItem {
  final String numeroDocumento;
  final String valorFormatado;
  final String dataVencimentoFormatada;
  final String situacao;
  // ... outros campos
}
```

### ConsultarInformacoesDetalhadasResponse

```dart
class ConsultarInformacoesDetalhadasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarInformacoesDetalhadasDados? dadosParsed;
}

class ConsultarInformacoesDetalhadasDados {
  final String cnpj;
  final String razaoSocial;
  final String situacao;
  final String regimeTributario;
  final String dataAberturaFormatada;
  // ... outros campos
}
```

## Validações Disponíveis

O serviço RELPMEI inclui várias validações para garantir a integridade dos dados:

```dart
// Validar CNPJ do contribuinte
final erro = relpmeiService.validarCnpjContribuinte('00000000000000');
if (erro != null) {
  print('Erro: $erro');
}

// Validar período de consulta
final erroPeriodo = relpmeiService.validarPeriodoConsulta('2024-01-01', '2024-12-31');
if (erroPeriodo != null) {
  print('Erro: $erroPeriodo');
}

// Validar situação do pagamento
final erroSituacao = relpmeiService.validarSituacaoPagamento('REALIZADO');
if (erroSituacao != null) {
  print('Erro: $erroSituacao');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do RELPMEI:

```dart
// Analisar erro
final analise = relpmeiService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (relpmeiService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = relpmeiService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | MEI não encontrado | Verificar se MEI existe |
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
  final relpmeiService = RelpmeiService(apiClient);
  
  // 3. Consulta completa
  try {
    const contribuinteNumero = '00000000000000';
    
    // Consultar pagamentos realizados
    print('=== Pagamentos Realizados ===');
    final realizados = await relpmeiService.consultarPagamentosRealizados(contribuinteNumero);
    if (realizados.sucesso) {
      print('Total de pagamentos: ${realizados.dadosParsed?.listaPagamentos.length ?? 0}');
      print('Valor total: ${realizados.valorTotalPagamentosFormatado}');
    }
    
    // Consultar pagamentos pendentes
    print('\n=== Pagamentos Pendentes ===');
    final pendentes = await relpmeiService.consultarPagamentosPendentes(contribuinteNumero);
    if (pendentes.sucesso) {
      print('Total de pendentes: ${pendentes.dadosParsed?.listaPagamentos.length ?? 0}');
      print('Valor total: ${pendentes.valorTotalPagamentosFormatado}');
    }
    
    // Consultar informações detalhadas
    print('\n=== Informações Detalhadas ===');
    final info = await relpmeiService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (info.sucesso) {
      print('Razão social: ${info.dadosParsed?.razaoSocial}');
      print('Situação: ${info.dadosParsed?.situacao}');
      print('Regime tributário: ${info.dadosParsed?.regimeTributario}');
    }
    
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// Períodos de teste
const dataInicial = '2024-01-01';
const dataFinal = '2024-12-31';

// Situações de teste
const situacaoTeste = 'REALIZADO';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **MEI**: Apenas para Microempreendedores Individuais
5. **Período**: Consultas podem ter limitações de período

## Casos de Uso Comuns

### 1. Consulta Completa de Pagamentos

```dart
Future<void> consultarPagamentosCompleto(String contribuinteNumero) async {
  try {
    // Consultar pagamentos realizados
    final realizados = await relpmeiService.consultarPagamentosRealizados(contribuinteNumero);
    if (!realizados.sucesso) return;
    
    // Consultar pagamentos pendentes
    final pendentes = await relpmeiService.consultarPagamentosPendentes(contribuinteNumero);
    if (!pendentes.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await relpmeiService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Pagamentos ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Pagamentos realizados: ${realizados.dadosParsed?.listaPagamentos.length}');
    print('Valor total realizados: ${realizados.valorTotalPagamentosFormatado}');
    print('Pagamentos pendentes: ${pendentes.dadosParsed?.listaPagamentos.length}');
    print('Valor total pendentes: ${pendentes.valorTotalPagamentosFormatado}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Monitoramento de Pagamentos Pendentes

```dart
Future<void> monitorarPagamentosPendentes(String contribuinteNumero) async {
  try {
    // Consultar pagamentos pendentes
    final pendentes = await relpmeiService.consultarPagamentosPendentes(contribuinteNumero);
    if (!pendentes.sucesso) return;
    
    final listaPagamentos = pendentes.dadosParsed?.listaPagamentos ?? [];
    
    for (final pagamento in listaPagamentos) {
      final vencimento = DateTime.tryParse(pagamento.dataVencimentoFormatada);
      if (vencimento != null) {
        final diasParaVencimento = vencimento.difference(DateTime.now()).inDays;
        
        if (diasParaVencimento <= 5) {
          print('⚠️ Pagamento ${pagamento.numeroDocumento} vence em $diasParaVencimento dias');
          print('Valor: ${pagamento.valorFormatado}');
        }
      }
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

### 3. Relatório de Pagamentos

```dart
Future<void> relatorioPagamentos(String contribuinteNumero) async {
  try {
    // Consultar pagamentos realizados
    final realizados = await relpmeiService.consultarPagamentosRealizados(contribuinteNumero);
    if (!realizados.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await relpmeiService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Pagamentos ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Situação: ${info.dadosParsed?.situacao}');
    print('Regime tributário: ${info.dadosParsed?.regimeTributario}');
    print('Pagamentos realizados: ${realizados.dadosParsed?.listaPagamentos.length}');
    print('Valor total: ${realizados.valorTotalPagamentosFormatado}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Integração com Outros Serviços

O RELPMEI Service pode ser usado em conjunto com:

- **CCMEI Service**: Para consultar dados do MEI
- **PGMEI Service**: Para consultar pagamentos relacionados
- **PARCMEI Service**: Para consultar parcelamentos relacionados
- **Eventos Atualização Service**: Para monitorar atualizações

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de pagamentos
- Monitorar pagamentos pendentes
- Alertar sobre pagamentos próximos do vencimento
- Rastrear erros de validação
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço RELPMEI:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package