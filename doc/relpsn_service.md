# RELPSN Service

## Visão Geral

O `RelpsnService` é responsável pela integração com o sistema RELPSN (Parcelamento do Simples Nacional). Este serviço permite consultar pedidos de parcelamento, consultar parcelamentos específicos, consultar parcelas disponíveis, consultar detalhes de pagamento e emitir DAS para parcelas.

## Funcionalidades Principais

- **Consultar Pedidos**: Consulta todos os pedidos de parcelamento RELPSN
- **Consultar Parcelamento**: Consulta informações detalhadas de um parcelamento específico
- **Consultar Parcelas**: Consulta parcelas disponíveis para um parcelamento específico
- **Consultar Detalhes de Pagamento**: Consulta detalhes de pagamento de uma parcela
- **Emitir DAS**: Emite DAS para parcelas específicas
- **Validações**: Validações específicas do sistema RELPSN

## Métodos Disponíveis

### 1. Consultar Pedidos

```dart
Future<ConsultarPedidosResponse> consultarPedidos()
```

**Retorna:** Lista de todos os parcelamentos ativos do contribuinte

**Exemplo:**
```dart
final response = await relpsnService.consultarPedidos();
if (response.sucesso) {
  final parcelamentos = response.dadosParsed?.parcelamentos ?? [];
  for (final parcela in parcelamentos) {
    print('Parcelamento ${parcela.numero}: ${parcela.situacao}');
  }
}
```

### 2. Consultar Parcelamento

```dart
Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento)
```

**Parâmetros:**
- `numeroParcelamento`: Número do parcelamento a ser consultado

**Exemplo:**
```dart
final response = await relpsnService.consultarParcelamento(123456);
if (response.sucesso) {
  final parcelamento = response.dadosParsed;
  print('Situação: ${parcelamento?.situacao}');
  print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
}
```

### 3. Consultar Parcelas

```dart
Future<ConsultarParcelasResponse> consultarParcelas(int numeroParcelamento)
```

**Parâmetros:**
- `numeroParcelamento`: Número do parcelamento

**Exemplo:**
```dart
final response = await relpsnService.consultarParcelas(123456);
if (response.sucesso) {
  final parcelas = response.dadosParsed?.listaParcelas ?? [];
  for (final parcela in parcelas) {
    print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
  }
}
```

### 4. Consultar Detalhes de Pagamento

```dart
Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(
  int numeroParcelamento,
  int anoMesParcela,
)
```

**Parâmetros:**
- `numeroParcelamento`: Número do parcelamento
- `anoMesParcela`: Ano/mês da parcela no formato AAAAMM

**Exemplo:**
```dart
final response = await relpsnService.consultarDetalhesPagamento(123456, 202401);
if (response.sucesso) {
  final detalhes = response.dadosParsed;
  print('DAS: ${detalhes?.numeroDas}');
  print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
}
```

### 5. Emitir DAS

```dart
Future<EmitirDasResponse> emitirDas(int numeroParcelamento, int parcelaParaEmitir)
```

**Parâmetros:**
- `numeroParcelamento`: Número do parcelamento
- `parcelaParaEmitir`: Parcela para emitir no formato AAAAMM

**Exemplo:**
```dart
final response = await relpsnService.emitirDas(123456, 202401);
if (response.sucesso && response.pdfGeradoComSucesso) {
  final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
}
```

## Validações Disponíveis

### Validações de Parâmetros

```dart
// Validar número de parcelamento
String? validarNumeroParcelamento(int? numeroParcelamento)

// Validar ano/mês de parcela
String? validarAnoMesParcela(int? anoMesParcela)

// Validar parcela para emissão
String? validarParcelaParaEmitir(int? parcelaParaEmitir)

// Validar prazo para emissão
String? validarPrazoEmissaoParcela(int parcelaParaEmitir)
```

## Tratamento de Erros

### Análise de Erros

```dart
// Analisar erro específico
RelpsnErrorAnalysis analyzeError(String codigo, String mensagem)

// Verificar se erro é conhecido
bool isKnownError(String codigo)

// Obter informações do erro
RelpsnErrorInfo? getErrorInfo(String codigo)
```

### Categorias de Erros

```dart
// Obter avisos
List<RelpsnErrorInfo> getAvisos()

// Obter entradas incorretas
List<RelpsnErrorInfo> getEntradasIncorretas()

// Obter erros gerais
List<RelpsnErrorInfo> getErros()
```

## Exemplo de Uso Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient(
    baseUrl: 'https://apigateway.serpro.gov.br/integra-contador-trial/v1',
    clientId: 'seu_client_id',
    clientSecret: 'seu_client_secret',
  );

  // Criar serviço
  final relpsnService = RelpsnService(apiClient);

  try {
    // 1. Consultar pedidos
    print('=== Consultando Pedidos RELPSN ===');
    final pedidos = await relpsnService.consultarPedidos();
    
    if (pedidos.sucesso) {
      final parcelamentos = pedidos.dadosParsed?.parcelamentos ?? [];
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      
      for (final parcelamento in parcelamentos) {
        print('Número: ${parcelamento.numero}');
        print('Situação: ${parcelamento.situacao}');
        print('---');
        
        // 2. Consultar parcelas para este parcelamento
        final parcelas = await relpsnService.consultarParcelas(parcelamento.numero);
        if (parcelas.sucesso) {
          final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
          print('Parcelas disponíveis: ${listaParcelas.length}');
          
          for (final parcela in listaParcelas) {
            print('Parcela: ${parcela.parcelaFormatada}');
            print('Valor: ${parcela.valorFormatado}');
            print('---');
          }
        }
      }
    }
    
  } catch (e) {
    print('Erro: $e');
    
    // Analisar erro se possível
    if (e is RelpsnError) {
      final analysis = relpsnService.analyzeError(e.codigo, e.mensagem);
      print('Análise do erro: ${analysis.summary}');
      print('Ação recomendada: ${analysis.recommendedAction}');
    }
  }
}
```

## Limitações

- Apenas CNPJs são aceitos (Pessoa Jurídica)
- Parcelas devem estar no formato AAAAMM
- Prazo para emissão de parcelas é limitado
- Alguns parcelamentos podem ter restrições específicas

## Casos de Uso Comuns

### 1. Consulta Completa de Parcelamento

```dart
Future<void> consultarParcelamentoCompleto(int numeroParcelamento) async {
  try {
    // Consultar parcelamento
    final parcelamento = await relpsnService.consultarParcelamento(numeroParcelamento);
    if (!parcelamento.sucesso) return;
    
    // Consultar parcelas
    final parcelas = await relpsnService.consultarParcelas(numeroParcelamento);
    if (!parcelas.sucesso) return;
    
    print('=== Parcelamento $numeroParcelamento ===');
    print('Situação: ${parcelamento.dadosParsed?.situacao}');
    print('Parcelas disponíveis: ${parcelas.dadosParsed?.listaParcelas.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Emissão de DAS em Lote

```dart
Future<void> emitirDasLote(int numeroParcelamento) async {
  try {
    // Consultar parcelas disponíveis
    final parcelas = await relpsnService.consultarParcelas(numeroParcelamento);
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
    
    for (final parcela in listaParcelas) {
      try {
        final das = await relpsnService.emitirDas(numeroParcelamento, parcela.parcelaParaEmitir);
        if (das.sucesso && das.pdfGeradoComSucesso) {
          print('DAS emitido para parcela ${parcela.parcelaFormatada}');
        }
      } catch (e) {
        print('Erro ao emitir DAS para parcela ${parcela.parcelaFormatada}: $e');
      }
    }
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

## Integração com Outros Serviços

O RELPSN Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas aos parcelamentos
- **MIT Service**: Para consultar apurações relacionadas aos parcelamentos
- **Eventos Atualização Service**: Para monitorar atualizações de parcelamentos

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de parcelamentos
- Monitorar emissões de DAS
- Alertar sobre parcelas próximas do vencimento
- Rastrear erros de validação
