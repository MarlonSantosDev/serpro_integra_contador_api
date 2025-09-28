# PARCSN Service

## Visão Geral

O `ParcsnService` é responsável pela integração com o sistema PARCSN (Parcelamento do Simples Nacional). Este serviço permite consultar pedidos de parcelamento ordinário, consultar parcelamentos específicos, consultar parcelas disponíveis para impressão, consultar detalhes de pagamento e emitir DAS para parcelas.

## Funcionalidades Principais

- **Consultar Pedidos**: Consulta todos os pedidos de parcelamento ordinário
- **Consultar Parcelamento**: Consulta informações detalhadas de um parcelamento específico
- **Consultar Parcelas**: Consulta parcelas disponíveis para impressão
- **Consultar Detalhes de Pagamento**: Consulta detalhes de pagamento de uma parcela
- **Emitir DAS**: Emite DAS para parcelas específicas
- **Validações**: Validações específicas do sistema PARCSN

## Métodos Disponíveis

### 1. Consultar Pedidos

```dart
Future<ConsultarPedidosResponse> consultarPedidos()
```

**Retorna:** Lista de todos os parcelamentos ordinários do contribuinte

**Exemplo:**
```dart
final response = await parcsnService.consultarPedidos();
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
final response = await parcsnService.consultarParcelamento(1);
if (response.sucesso) {
  final parcelamento = response.dadosParsed;
  print('Situação: ${parcelamento?.situacao}');
  print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
}
```

### 3. Consultar Detalhes de Pagamento

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
final response = await parcsnService.consultarDetalhesPagamento(1, 201612);
if (response.sucesso) {
  final detalhes = response.dadosParsed;
  print('DAS: ${detalhes?.numeroDas}');
  print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
}
```

### 4. Consultar Parcelas

```dart
Future<ConsultarParcelasResponse> consultarParcelas()
```

**Retorna:** Lista de parcelas disponíveis para emissão de DAS

**Exemplo:**
```dart
final response = await parcsnService.consultarParcelas();
if (response.sucesso) {
  final parcelas = response.dadosParsed?.listaParcelas ?? [];
  for (final parcela in parcelas) {
    print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
  }
}
```

### 5. Emitir DAS

```dart
Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir)
```

**Parâmetros:**
- `parcelaParaEmitir`: Parcela para emitir no formato AAAAMM

**Exemplo:**
```dart
final response = await parcsnService.emitirDas(202306);
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

### Validações de Dados

```dart
// Validar CNPJ do contribuinte
String? validarCnpjContribuinte(String? cnpj)

// Validar tipo de contribuinte
String? validarTipoContribuinte(int? tipoContribuinte)
```

## Tratamento de Erros

### Análise de Erros

```dart
// Analisar erro específico
PertsnErrorAnalysis analyzeError(String codigo, String mensagem)

// Verificar se erro é conhecido
bool isKnownError(String codigo)

// Obter informações do erro
PertsnErrorInfo? getErrorInfo(String codigo)
```

### Categorias de Erros

```dart
// Obter avisos
List<PertsnErrorInfo> getAvisos()

// Obter entradas incorretas
List<PertsnErrorInfo> getEntradasIncorretas()

// Obter erros gerais
List<PertsnErrorInfo> getErros()

// Obter sucessos
List<PertsnErrorInfo> getSucessos()
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
  final parcsnService = ParcsnService(apiClient);

  try {
    // 1. Consultar pedidos
    print('=== Consultando Pedidos ===');
    final pedidos = await parcsnService.consultarPedidos();
    
    if (pedidos.sucesso) {
      final parcelamentos = pedidos.dadosParsed?.parcelamentos ?? [];
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      
      for (final parcelamento in parcelamentos) {
        print('Número: ${parcelamento.numero}');
        print('Situação: ${parcelamento.situacao}');
        print('---');
      }
    }
    
    // 2. Consultar parcelas disponíveis
    print('\n=== Consultando Parcelas ===');
    final parcelas = await parcsnService.consultarParcelas();
    
    if (parcelas.sucesso) {
      final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
      print('Parcelas disponíveis: ${listaParcelas.length}');
      
      for (final parcela in listaParcelas) {
        print('Parcela: ${parcela.parcelaFormatada}');
        print('Valor: ${parcela.valorFormatado}');
        print('---');
      }
    }
    
    // 3. Emitir DAS para primeira parcela
    if (parcelas.dadosParsed?.listaParcelas.isNotEmpty == true) {
      final primeiraParcela = parcelas.dadosParsed!.listaParcelas.first;
      print('\n=== Emitindo DAS ===');
      
      final das = await parcsnService.emitirDas(primeiraParcela.parcelaParaEmitir);
      if (das.sucesso && das.pdfGeradoComSucesso) {
        print('DAS emitido com sucesso!');
        print('Tamanho do PDF: ${das.tamanhoPdfFormatado}');
      }
    }
    
  } catch (e) {
    print('Erro: $e');
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
    final parcelamento = await parcsnService.consultarParcelamento(numeroParcelamento);
    if (!parcelamento.sucesso) return;
    
    // Consultar parcelas
    final parcelas = await parcsnService.consultarParcelas();
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
Future<void> emitirDasLote() async {
  try {
    // Consultar parcelas disponíveis
    final parcelas = await parcsnService.consultarParcelas();
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
    
    for (final parcela in listaParcelas) {
      try {
        final das = await parcsnService.emitirDas(parcela.parcelaParaEmitir);
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

O PARCSN Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas aos parcelamentos
- **MIT Service**: Para consultar apurações relacionadas aos parcelamentos
- **Eventos Atualização Service**: Para monitorar atualizações de parcelamentos

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de parcelamentos
- Monitorar emissões de DAS
- Alertar sobre parcelas próximas do vencimento
- Rastrear erros de validação
