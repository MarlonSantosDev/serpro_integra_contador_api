# RELPMEI Service

## Visão Geral

O `RelpmeiService` é responsável pela integração com o sistema RELPMEI (Receita Federal) para parcelamento do MEI. Este serviço implementa todos os métodos disponíveis para consultar pedidos de parcelamento, consultar parcelamentos existentes, consultar parcelas para impressão, consultar detalhes de pagamento e emitir DAS.

## Funcionalidades Principais

- **Consultar Pedidos**: Consulta pedidos de parcelamento RELPMEI
- **Consultar Parcelamento**: Consulta parcelamentos existentes RELPMEI
- **Consultar Parcelas**: Consulta parcelas para impressão RELPMEI
- **Consultar Detalhes de Pagamento**: Consulta detalhes de pagamento RELPMEI
- **Emitir DAS**: Emite DAS RELPMEI
- **Tratamento de Erros**: Tratamento robusto de erros com validações específicas

## Métodos Disponíveis

### 1. Consultar Pedidos

```dart
Future<ConsultarPedidosResponse> consultarPedidos(ConsultarPedidosRequest request)
```

**Parâmetros:**
- `request`: Dados da consulta incluindo CPF/CNPJ obrigatório

**Exemplo:**
```dart
final request = ConsultarPedidosRequest(
  cpfCnpj: '12345678000195',
  // outros parâmetros opcionais
);

final response = await relpmeiService.consultarPedidos(request);
if (response.sucesso) {
  final pedidos = response.dadosParsed?.pedidos ?? [];
  for (final pedido in pedidos) {
    print('Pedido ${pedido.numero}: ${pedido.situacao}');
  }
}
```

### 2. Consultar Parcelamento

```dart
Future<ConsultarParcelamentoResponse> consultarParcelamento(ConsultarParcelamentoRequest request)
```

**Parâmetros:**
- `request`: Dados da consulta incluindo CPF/CNPJ obrigatório

**Exemplo:**
```dart
final request = ConsultarParcelamentoRequest(
  cpfCnpj: '12345678000195',
  numeroParcelamento: 12345,
);

final response = await relpmeiService.consultarParcelamento(request);
if (response.sucesso) {
  final parcelamento = response.dadosParsed;
  print('Situação: ${parcelamento?.situacao}');
  print('Valor total: ${parcelamento?.valorTotalFormatado}');
}
```

### 3. Consultar Parcelas para Impressão

```dart
Future<ConsultarParcelasImpressaoResponse> consultarParcelasImpressao(
  ConsultarParcelasImpressaoRequest request,
)
```

**Parâmetros:**
- `request`: Dados da consulta incluindo CPF/CNPJ obrigatório

**Exemplo:**
```dart
final request = ConsultarParcelasImpressaoRequest(
  cpfCnpj: '12345678000195',
);

final response = await relpmeiService.consultarParcelasImpressao(request);
if (response.sucesso) {
  final parcelas = response.dadosParsed?.parcelas ?? [];
  for (final parcela in parcelas) {
    print('Parcela ${parcela.numero}: ${parcela.valorFormatado}');
  }
}
```

### 4. Consultar Detalhes de Pagamento

```dart
Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(
  ConsultarDetalhesPagamentoRequest request,
)
```

**Parâmetros:**
- `request`: Dados da consulta incluindo CPF/CNPJ obrigatório

**Exemplo:**
```dart
final request = ConsultarDetalhesPagamentoRequest(
  cpfCnpj: '12345678000195',
  numeroParcelamento: 12345,
  numeroParcela: 1,
);

final response = await relpmeiService.consultarDetalhesPagamento(request);
if (response.sucesso) {
  final detalhes = response.dadosParsed;
  print('DAS: ${detalhes?.numeroDas}');
  print('Valor pago: ${detalhes?.valorPagoFormatado}');
}
```

### 5. Emitir DAS

```dart
Future<EmitirDasResponse> emitirDas(EmitirDasRequest request)
```

**Parâmetros:**
- `request`: Dados para emissão incluindo CPF/CNPJ obrigatório

**Exemplo:**
```dart
final request = EmitirDasRequest(
  cpfCnpj: '12345678000195',
  numeroParcelamento: 12345,
  numeroParcela: 1,
);

final response = await relpmeiService.emitirDas(request);
if (response.sucesso) {
  final das = response.dadosParsed;
  print('DAS emitido: ${das?.numeroDas}');
  print('PDF: ${das?.pdfBase64}');
}
```

## Tratamento de Erros

### Validações Automáticas

O serviço realiza validações automáticas nos parâmetros:

- **CPF/CNPJ Vazio**: Verifica se o CPF/CNPJ não está vazio
- **Dados Obrigatórios**: Verifica se todos os campos obrigatórios estão preenchidos

### Códigos de Erro Específicos

- `VALIDATION_ERROR`: Erro de validação de parâmetros
- `HTTP_ERROR`: Erro de comunicação HTTP
- `INTERNAL_ERROR`: Erro interno do sistema

### Tratamento de Exceções

```dart
try {
  final request = ConsultarPedidosRequest(cpfCnpj: '12345678000195');
  final response = await relpmeiService.consultarPedidos(request);
  
  if (response.sucesso) {
    // Processar resposta
  } else {
    print('Erro: ${response.mensagem}');
    print('Código: ${response.codigoErro}');
    print('Detalhes: ${response.detalhesErro}');
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
  final relpmeiService = RelpmeiService(apiClient);

  try {
    const cpfCnpj = '12345678000195';
    
    // 1. Consultar pedidos
    print('=== Consultando Pedidos RELPMEI ===');
    final pedidosRequest = ConsultarPedidosRequest(cpfCnpj: cpfCnpj);
    final pedidos = await relpmeiService.consultarPedidos(pedidosRequest);
    
    if (pedidos.sucesso) {
      final listaPedidos = pedidos.dadosParsed?.pedidos ?? [];
      print('Pedidos encontrados: ${listaPedidos.length}');
      
      for (final pedido in listaPedidos) {
        print('Número: ${pedido.numero}');
        print('Situação: ${pedido.situacao}');
        print('Data: ${pedido.dataPedidoFormatada}');
        print('---');
        
        // 2. Consultar parcelamento específico
        final parcelamentoRequest = ConsultarParcelamentoRequest(
          cpfCnpj: cpfCnpj,
          numeroParcelamento: pedido.numero,
        );
        
        final parcelamento = await relpmeiService.consultarParcelamento(parcelamentoRequest);
        if (parcelamento.sucesso) {
          print('Valor total: ${parcelamento.dadosParsed?.valorTotalFormatado}');
        }
      }
    } else {
      print('Erro ao consultar pedidos: ${pedidos.mensagem}');
    }
    
    // 3. Consultar parcelas para impressão
    print('\n=== Consultando Parcelas para Impressão ===');
    final parcelasRequest = ConsultarParcelasImpressaoRequest(cpfCnpj: cpfCnpj);
    final parcelas = await relpmeiService.consultarParcelasImpressao(parcelasRequest);
    
    if (parcelas.sucesso) {
      final listaParcelas = parcelas.dadosParsed?.parcelas ?? [];
      print('Parcelas disponíveis: ${listaParcelas.length}');
      
      for (final parcela in listaParcelas) {
        print('Parcela: ${parcela.numero}');
        print('Valor: ${parcela.valorFormatado}');
        print('Vencimento: ${parcela.dataVencimentoFormatada}');
        print('---');
      }
    }
    
    // 4. Emitir DAS para primeira parcela
    if (parcelas.dadosParsed?.parcelas.isNotEmpty == true) {
      final primeiraParcela = parcelas.dadosParsed!.parcelas.first;
      print('\n=== Emitindo DAS ===');
      
      final dasRequest = EmitirDasRequest(
        cpfCnpj: cpfCnpj,
        numeroParcelamento: primeiraParcela.numeroParcelamento,
        numeroParcela: primeiraParcela.numero,
      );
      
      final das = await relpmeiService.emitirDas(dasRequest);
      if (das.sucesso) {
        print('DAS emitido com sucesso!');
        print('Número: ${das.dadosParsed?.numeroDas}');
        // Salvar PDF
        // await File('das_${primeiraParcela.numero}.pdf').writeAsBytes(das.dadosParsed?.pdfBytes);
      } else {
        print('Erro ao emitir DAS: ${das.mensagem}');
      }
    }
    
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

## Limitações

- CPF/CNPJ é obrigatório em todas as operações
- Alguns parcelamentos podem ter restrições específicas
- DAS só pode ser emitido para parcelas válidas
- Alguns dados podem não estar disponíveis dependendo do status do parcelamento

## Casos de Uso Comuns

### 1. Consulta Completa de Parcelamento

```dart
Future<void> consultarParcelamentoCompleto(String cpfCnpj, int numeroParcelamento) async {
  try {
    // Consultar parcelamento
    final parcelamentoRequest = ConsultarParcelamentoRequest(
      cpfCnpj: cpfCnpj,
      numeroParcelamento: numeroParcelamento,
    );
    
    final parcelamento = await relpmeiService.consultarParcelamento(parcelamentoRequest);
    if (!parcelamento.sucesso) {
      print('Erro ao consultar parcelamento: ${parcelamento.mensagem}');
      return;
    }
    
    // Consultar parcelas
    final parcelasRequest = ConsultarParcelasImpressaoRequest(cpfCnpj: cpfCnpj);
    final parcelas = await relpmeiService.consultarParcelasImpressao(parcelasRequest);
    if (!parcelas.sucesso) {
      print('Erro ao consultar parcelas: ${parcelas.mensagem}');
      return;
    }
    
    print('=== Parcelamento $numeroParcelamento ===');
    print('Situação: ${parcelamento.dadosParsed?.situacao}');
    print('Valor total: ${parcelamento.dadosParsed?.valorTotalFormatado}');
    print('Parcelas disponíveis: ${parcelas.dadosParsed?.parcelas.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Emissão de DAS em Lote

```dart
Future<void> emitirDasLote(String cpfCnpj) async {
  try {
    // Consultar parcelas disponíveis
    final parcelasRequest = ConsultarParcelasImpressaoRequest(cpfCnpj: cpfCnpj);
    final parcelas = await relpmeiService.consultarParcelasImpressao(parcelasRequest);
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.parcelas ?? [];
    
    for (final parcela in listaParcelas) {
      try {
        final dasRequest = EmitirDasRequest(
          cpfCnpj: cpfCnpj,
          numeroParcelamento: parcela.numeroParcelamento,
          numeroParcela: parcela.numero,
        );
        
        final das = await relpmeiService.emitirDas(dasRequest);
        if (das.sucesso) {
          print('DAS emitido para parcela ${parcela.numero}');
          // Salvar PDF
        } else {
          print('Erro ao emitir DAS para parcela ${parcela.numero}: ${das.mensagem}');
        }
      } catch (e) {
        print('Erro ao emitir DAS para parcela ${parcela.numero}: $e');
      }
    }
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

## Integração com Outros Serviços

O RELPMEI Service pode ser usado em conjunto com:

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
