# PERTMEI Service

## Visão Geral

O `PertmeiService` é responsável pela integração com o sistema PERTMEI (Parcelamento Especial de Regularização Tributária para MEI). Este serviço implementa todos os métodos disponíveis para consultar pedidos de parcelamento, consultar parcelamentos existentes, consultar parcelas para impressão, consultar detalhes de pagamento e emitir DAS.

## Funcionalidades Principais

- **Consultar Pedidos**: Consulta todos os pedidos de parcelamento PERTMEI
- **Consultar Parcelamento**: Consulta informações detalhadas de um parcelamento específico
- **Consultar Parcelas**: Consulta parcelas disponíveis para impressão
- **Consultar Detalhes de Pagamento**: Consulta detalhes de pagamento de uma parcela
- **Emitir DAS**: Emite DAS para parcelas específicas
- **Tratamento de Erros**: Tratamento robusto de erros com validações específicas

## Métodos Disponíveis

### 1. Consultar Pedidos

```dart
Future<ConsultarPedidosResponse> consultarPedidos(String contribuinteNumero)
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (obrigatório)

**Retorna:** Lista de parcelamentos encontrados ou erro detalhado

**Exemplo:**
```dart
final response = await pertmeiService.consultarPedidos('12345678000195');
if (response.sucesso) {
  final parcelamentos = response.dadosParsed?.parcelamentos ?? [];
  for (final parcelamento in parcelamentos) {
    print('Parcelamento ${parcelamento.numero}: ${parcelamento.situacao}');
  }
}
```

### 2. Consultar Parcelamento

```dart
Future<ConsultarParcelamentoResponse> consultarParcelamento(
  String contribuinteNumero,
  int numeroParcelamento,
)
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (obrigatório)
- `numeroParcelamento`: Número do parcelamento que se deseja consultar (obrigatório)

**Exemplo:**
```dart
final response = await pertmeiService.consultarParcelamento('12345678000195', 12345);
if (response.sucesso) {
  final parcelamento = response.dadosParsed;
  print('Situação: ${parcelamento?.situacao}');
  print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
}
```

### 3. Consultar Parcelas para Impressão

```dart
Future<ConsultarParcelasResponse> consultarParcelasParaImpressao(String contribuinteNumero)
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (obrigatório)

**Retorna:** Lista de parcelas disponíveis para geração do DAS

**Exemplo:**
```dart
final response = await pertmeiService.consultarParcelasParaImpressao('12345678000195');
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
  String contribuinteNumero,
  int numeroParcelamento,
  int anoMesParcela,
)
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (obrigatório)
- `numeroParcelamento`: Número do parcelamento (obrigatório)
- `anoMesParcela`: Mês da parcela paga no formato AAAAMM (obrigatório)

**Exemplo:**
```dart
final response = await pertmeiService.consultarDetalhesPagamento(
  '12345678000195',
  12345,
  202306,
);
if (response.sucesso) {
  final detalhes = response.dadosParsed;
  print('DAS: ${detalhes?.numeroDas}');
  print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
  print('Data de pagamento: ${detalhes?.dataPagamentoFormatada}');
}
```

### 5. Emitir DAS

```dart
Future<EmitirDasResponse> emitirDas(
  String contribuinteNumero,
  int parcelaParaEmitir,
)
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (obrigatório)
- `parcelaParaEmitir`: Ano e mês da parcela para emitir o DAS no formato AAAAMM (obrigatório)

**Exemplo:**
```dart
final response = await pertmeiService.emitirDas('12345678000195', 202306);
if (response.sucesso && response.pdfGeradoComSucesso) {
  final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  final pdfBytes = response.pdfBytes;
  print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
}
```

## Tratamento de Erros

### Validações Automáticas

O serviço realiza validações automáticas nos parâmetros:

- **CNPJ Vazio**: Verifica se o CNPJ não está vazio
- **Número de Parcelamento**: Verifica se é maior que zero
- **Ano/Mês da Parcela**: Verifica se está no formato AAAAMM válido (202001-209912)

### Códigos de Erro Específicos

- `[Erro-PERTMEI-VALIDATION]`: Erro de validação de parâmetros
- `[Erro-PERTMEI-INTERNAL]`: Erro interno do sistema

### Tratamento de Exceções

```dart
try {
  final response = await pertmeiService.consultarPedidos('12345678000195');
  if (response.sucesso) {
    // Processar resposta
  } else {
    print('Erro: ${response.mensagemPrincipal}');
  }
} catch (e) {
  print('Erro inesperado: $e');
}
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
  final pertmeiService = PertmeiService(apiClient);

  try {
    const contribuinteNumero = '12345678000195';
    
    // 1. Consultar pedidos
    print('=== Consultando Pedidos PERTMEI ===');
    final pedidos = await pertmeiService.consultarPedidos(contribuinteNumero);
    
    if (pedidos.sucesso) {
      final parcelamentos = pedidos.dadosParsed?.parcelamentos ?? [];
      print('Parcelamentos encontrados: ${parcelamentos.length}');
      
      for (final parcelamento in parcelamentos) {
        print('Número: ${parcelamento.numero}');
        print('Situação: ${parcelamento.situacao}');
        print('Data: ${parcelamento.dataDoPedidoFormatada}');
        print('---');
        
        // 2. Consultar parcelamento específico
        final detalhes = await pertmeiService.consultarParcelamento(
          contribuinteNumero,
          parcelamento.numero,
        );
        
        if (detalhes.sucesso) {
          print('Valor total: ${detalhes.dadosParsed?.valorTotalConsolidadoFormatado}');
        }
      }
    } else {
      print('Erro ao consultar pedidos: ${pedidos.mensagemPrincipal}');
    }
    
    // 3. Consultar parcelas para impressão
    print('\n=== Consultando Parcelas para Impressão ===');
    final parcelas = await pertmeiService.consultarParcelasParaImpressao(contribuinteNumero);
    
    if (parcelas.sucesso) {
      final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
      print('Parcelas disponíveis: ${listaParcelas.length}');
      
      for (final parcela in listaParcelas) {
        print('Parcela: ${parcela.parcelaFormatada}');
        print('Valor: ${parcela.valorFormatado}');
        print('Vencimento: ${parcela.dataVencimentoFormatada}');
        print('---');
      }
    }
    
    // 4. Emitir DAS para primeira parcela
    if (parcelas.dadosParsed?.listaParcelas.isNotEmpty == true) {
      final primeiraParcela = parcelas.dadosParsed!.listaParcelas.first;
      print('\n=== Emitindo DAS ===');
      
      final das = await pertmeiService.emitirDas(
        contribuinteNumero,
        primeiraParcela.parcelaParaEmitir,
      );
      
      if (das.sucesso && das.pdfGeradoComSucesso) {
        print('DAS emitido com sucesso!');
        print('Tamanho do PDF: ${das.tamanhoPdfFormatado}');
        // Salvar PDF
        // await File('das_${primeiraParcela.parcelaParaEmitir}.pdf').writeAsBytes(das.pdfBytes);
      } else {
        print('Erro ao emitir DAS: ${das.mensagemPrincipal}');
      }
    }
    
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

## Limitações

- Apenas CNPJs são aceitos (Pessoa Jurídica)
- Parcelas devem estar no formato AAAAMM (202001-209912)
- Número de parcelamento deve ser maior que zero
- Alguns parcelamentos podem ter restrições específicas

## Casos de Uso Comuns

### 1. Consulta Completa de Parcelamento

```dart
Future<void> consultarParcelamentoCompleto(String contribuinteNumero, int numeroParcelamento) async {
  try {
    // Consultar parcelamento
    final parcelamento = await pertmeiService.consultarParcelamento(contribuinteNumero, numeroParcelamento);
    if (!parcelamento.sucesso) {
      print('Erro ao consultar parcelamento: ${parcelamento.mensagemPrincipal}');
      return;
    }
    
    // Consultar parcelas
    final parcelas = await pertmeiService.consultarParcelasParaImpressao(contribuinteNumero);
    if (!parcelas.sucesso) {
      print('Erro ao consultar parcelas: ${parcelas.mensagemPrincipal}');
      return;
    }
    
    print('=== Parcelamento $numeroParcelamento ===');
    print('Situação: ${parcelamento.dadosParsed?.situacao}');
    print('Valor total: ${parcelamento.dadosParsed?.valorTotalConsolidadoFormatado}');
    print('Parcelas disponíveis: ${parcelas.dadosParsed?.listaParcelas.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Emissão de DAS em Lote

```dart
Future<void> emitirDasLote(String contribuinteNumero) async {
  try {
    // Consultar parcelas disponíveis
    final parcelas = await pertmeiService.consultarParcelasParaImpressao(contribuinteNumero);
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
    
    for (final parcela in listaParcelas) {
      try {
        final das = await pertmeiService.emitirDas(contribuinteNumero, parcela.parcelaParaEmitir);
        if (das.sucesso && das.pdfGeradoComSucesso) {
          print('DAS emitido para parcela ${parcela.parcelaFormatada}');
          // Salvar PDF
        } else {
          print('Erro ao emitir DAS para parcela ${parcela.parcelaFormatada}: ${das.mensagemPrincipal}');
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

### 3. Monitoramento de Parcelamentos

```dart
Future<void> monitorarParcelamentos(String contribuinteNumero) async {
  try {
    // Consultar pedidos
    final pedidos = await pertmeiService.consultarPedidos(contribuinteNumero);
    if (!pedidos.sucesso) return;
    
    final parcelamentos = pedidos.dadosParsed?.parcelamentos ?? [];
    
    for (final parcelamento in parcelamentos) {
      print('=== Parcelamento ${parcelamento.numero} ===');
      print('Situação: ${parcelamento.situacao}');
      print('Data: ${parcelamento.dataDoPedidoFormatada}');
      
      // Consultar parcelas para este parcelamento
      final parcelas = await pertmeiService.consultarParcelasParaImpressao(contribuinteNumero);
      if (parcelas.sucesso) {
        final parcelasDoParcelamento = parcelas.dadosParsed?.listaParcelas
            .where((p) => p.numeroParcelamento == parcelamento.numero)
            .toList() ?? [];
        
        print('Parcelas pendentes: ${parcelasDoParcelamento.length}');
        for (final parcela in parcelasDoParcelamento) {
          print('  - Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
        }
      }
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Integração com Outros Serviços

O PERTMEI Service pode ser usado em conjunto com:

- **PGMEI Service**: Para gerar DAS do MEI após parcelamento
- **CCMEI Service**: Para consultar dados do MEI
- **Eventos Atualização Service**: Para monitorar atualizações de parcelamentos

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de parcelamentos
- Monitorar emissões de DAS
- Alertar sobre parcelas próximas do vencimento
- Rastrear erros de validação
- Monitorar performance das consultas
