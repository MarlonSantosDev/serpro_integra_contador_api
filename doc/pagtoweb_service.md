# PagtoWeb Service

## Visão Geral

O `PagtoWebService` é responsável pela integração com o sistema PAGTOWEB da Receita Federal. Este serviço implementa todos os serviços disponíveis do Integra PAGTOWEB para consulta de pagamentos e emissão de comprovantes.

## Funcionalidades Principais

- **Consultar Pagamentos**: Consulta pagamentos com filtros opcionais
- **Contar Pagamentos**: Conta pagamentos com filtros opcionais
- **Emitir Comprovante**: Emite comprovante de pagamento
- **Métodos de Conveniência**: Operações simplificadas para casos comuns

## Serviços Disponíveis

- **PAGAMENTOS71**: Consultar Pagamentos
- **CONTACONSDOCARRPG73**: Contar Pagamentos
- **EMITECOMPROVANTEPAGAMENTO72**: Emitir Comprovante de Pagamento

## Métodos Disponíveis

### 1. Consultar Pagamentos

```dart
Future<ConsultarPagamentosResponse> consultarPagamentos({
  required String contribuinteNumero,
  String? dataInicial,
  String? dataFinal,
  List<String>? codigoReceitaLista,
  double? valorInicial,
  double? valorFinal,
  List<String>? numeroDocumentoLista,
  List<String>? codigoTipoDocumentoLista,
  int primeiroDaPagina = 0,
  int tamanhoDaPagina = 100,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Parâmetros:**
- `contribuinteNumero`: CPF ou CNPJ do contribuinte
- `dataInicial`: Data inicial do intervalo (formato: AAAA-MM-DD)
- `dataFinal`: Data final do intervalo (formato: AAAA-MM-DD)
- `codigoReceitaLista`: Lista de códigos de receita
- `valorInicial`: Valor inicial do intervalo
- `valorFinal`: Valor final do intervalo
- `numeroDocumentoLista`: Lista de números de documento
- `codigoTipoDocumentoLista`: Lista de tipos de documento
- `primeiroDaPagina`: Índice do primeiro item da página (padrão: 0)
- `tamanhoDaPagina`: Tamanho da página (padrão: 100)
- `contratanteNumero`: Número do contratante (opcional)
- `autorPedidoDadosNumero`: Número do autor do pedido (opcional)

**Exemplo:**
```dart
final response = await pagtoWebService.consultarPagamentos(
  contribuinteNumero: '12345678000195',
  dataInicial: '2024-01-01',
  dataFinal: '2024-01-31',
  primeiroDaPagina: 0,
  tamanhoDaPagina: 50,
);
```

### 2. Contar Pagamentos

```dart
Future<ContarPagamentosResponse> contarPagamentos({
  required String contribuinteNumero,
  String? dataInicial,
  String? dataFinal,
  List<String>? codigoReceitaLista,
  double? valorInicial,
  double? valorFinal,
  List<String>? numeroDocumentoLista,
  List<String>? codigoTipoDocumentoLista,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await pagtoWebService.contarPagamentos(
  contribuinteNumero: '12345678000195',
  dataInicial: '2024-01-01',
  dataFinal: '2024-01-31',
);
```

### 3. Emitir Comprovante

```dart
Future<EmitirComprovanteResponse> emitirComprovante({
  required String contribuinteNumero,
  required String numeroDocumento,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await pagtoWebService.emitirComprovante(
  contribuinteNumero: '12345678000195',
  numeroDocumento: 'DOC123456',
);
```

## Métodos de Conveniência

### 1. Consultar Pagamentos por Data

```dart
Future<ConsultarPagamentosResponse> consultarPagamentosPorData({
  required String contribuinteNumero,
  required String dataInicial,
  required String dataFinal,
  int primeiroDaPagina = 0,
  int tamanhoDaPagina = 100,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

### 2. Consultar Pagamentos por Receita

```dart
Future<ConsultarPagamentosResponse> consultarPagamentosPorReceita({
  required String contribuinteNumero,
  required List<String> codigoReceitaLista,
  int primeiroDaPagina = 0,
  int tamanhoDaPagina = 100,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

### 3. Consultar Pagamentos por Valor

```dart
Future<ConsultarPagamentosResponse> consultarPagamentosPorValor({
  required String contribuinteNumero,
  required double valorInicial,
  required double valorFinal,
  int primeiroDaPagina = 0,
  int tamanhoDaPagina = 100,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

### 4. Consultar Pagamentos por Documento

```dart
Future<ConsultarPagamentosResponse> consultarPagamentosPorDocumento({
  required String contribuinteNumero,
  required List<String> numeroDocumentoLista,
  int primeiroDaPagina = 0,
  int tamanhoDaPagina = 100,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
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
  final pagtoWebService = PagtoWebService(apiClient);

  try {
    const contribuinteNumero = '12345678000195';
    
    // 1. Contar pagamentos do mês
    print('=== Contando Pagamentos ===');
    final contagem = await pagtoWebService.contarPagamentosPorData(
      contribuinteNumero: contribuinteNumero,
      dataInicial: '2024-01-01',
      dataFinal: '2024-01-31',
    );
    
    if (contagem.sucesso) {
      print('Total de pagamentos: ${contagem.dados.totalPagamentos}');
    }
    
    // 2. Consultar pagamentos
    print('\n=== Consultando Pagamentos ===');
    final pagamentos = await pagtoWebService.consultarPagamentosPorData(
      contribuinteNumero: contribuinteNumero,
      dataInicial: '2024-01-01',
      dataFinal: '2024-01-31',
      tamanhoDaPagina: 10,
    );
    
    if (pagamentos.sucesso) {
      print('Pagamentos encontrados: ${pagamentos.dados.pagamentos.length}');
      for (final pagamento in pagamentos.dados.pagamentos) {
        print('Documento: ${pagamento.numeroDocumento}');
        print('Valor: ${pagamento.valor}');
        print('Data: ${pagamento.dataPagamento}');
        print('---');
      }
    }
    
    // 3. Emitir comprovante
    if (pagamentos.dados.pagamentos.isNotEmpty) {
      print('\n=== Emitindo Comprovante ===');
      final primeiroPagamento = pagamentos.dados.pagamentos.first;
      final comprovante = await pagtoWebService.emitirComprovante(
        contribuinteNumero: contribuinteNumero,
        numeroDocumento: primeiroPagamento.numeroDocumento,
      );
      
      if (comprovante.sucesso) {
        print('Comprovante emitido com sucesso!');
        print('PDF: ${comprovante.dados.pdfBase64}');
      }
    }
    
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Tratamento de Erros

### Erros Comuns

- **Contribuinte Inválido**: CPF/CNPJ deve ser válido
- **Data Inválida**: Formato de data deve ser AAAA-MM-DD
- **Documento Não Encontrado**: Número de documento não existe
- **Limite de Página**: Tamanho da página deve ser válido

### Tratamento de Exceções

```dart
try {
  final response = await pagtoWebService.consultarPagamentos(
    contribuinteNumero: '12345678000195',
    dataInicial: '2024-01-01',
    dataFinal: '2024-01-31',
  );
} catch (e) {
  if (e.toString().contains('contribuinte inválido')) {
    print('CPF/CNPJ deve ser válido');
  } else if (e.toString().contains('data inválida')) {
    print('Formato de data deve ser AAAA-MM-DD');
  } else {
    print('Erro inesperado: $e');
  }
}
```

## Limitações

- Máximo de 1000 itens por página
- Datas devem estar no formato AAAA-MM-DD
- Apenas documentos válidos podem ter comprovantes emitidos
- Alguns filtros podem ter limitações específicas

## Casos de Uso Comuns

### 1. Relatório Mensal de Pagamentos

```dart
Future<void> relatorioMensal(String contribuinteNumero, int ano, int mes) async {
  final dataInicial = '$ano-${mes.toString().padLeft(2, '0')}-01';
  final dataFinal = '$ano-${mes.toString().padLeft(2, '0')}-31';
  
  final pagamentos = await pagtoWebService.consultarPagamentosPorData(
    contribuinteNumero: contribuinteNumero,
    dataInicial: dataInicial,
    dataFinal: dataFinal,
  );
  
  if (pagamentos.sucesso) {
    print('=== Relatório Mensal ===');
    print('Período: $dataInicial a $dataFinal');
    print('Total de pagamentos: ${pagamentos.dados.pagamentos.length}');
    
    double valorTotal = 0;
    for (final pagamento in pagamentos.dados.pagamentos) {
      valorTotal += pagamento.valor;
    }
    print('Valor total: R\$ ${valorTotal.toStringAsFixed(2)}');
  }
}
```

### 2. Consulta por Código de Receita

```dart
Future<void> consultarPorReceita(String contribuinteNumero, List<String> codigos) async {
  final pagamentos = await pagtoWebService.consultarPagamentosPorReceita(
    contribuinteNumero: contribuinteNumero,
    codigoReceitaLista: codigos,
  );
  
  if (pagamentos.sucesso) {
    print('Pagamentos por receita: ${pagamentos.dados.pagamentos.length}');
  }
}
```

### 3. Emissão de Comprovantes em Lote

```dart
Future<void> emitirComprovantesLote(String contribuinteNumero, List<String> documentos) async {
  for (final documento in documentos) {
    try {
      final comprovante = await pagtoWebService.emitirComprovante(
        contribuinteNumero: contribuinteNumero,
        numeroDocumento: documento,
      );
      
      if (comprovante.sucesso) {
        print('Comprovante emitido para $documento');
        // Salvar PDF
      }
    } catch (e) {
      print('Erro ao emitir comprovante para $documento: $e');
    }
  }
}
```

## Integração com Outros Serviços

O PagtoWeb Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas aos pagamentos
- **Caixa Postal Service**: Para consultar mensagens sobre pagamentos
- **Eventos Atualização Service**: Para monitorar atualizações de pagamentos

## Performance e Otimização

### Dicas de Performance

1. **Usar Paginação**: Para grandes volumes de dados
2. **Filtrar por Data**: Reduzir o escopo da consulta
3. **Cache de Resultados**: Implementar cache para consultas frequentes
4. **Consultas em Lote**: Agrupar consultas quando possível

### Exemplo de Cache

```dart
class PagtoWebCache {
  final Map<String, ConsultarPagamentosResponse> _cache = {};
  
  Future<ConsultarPagamentosResponse> consultarComCache(
    PagtoWebService service,
    String contribuinteNumero,
    String dataInicial,
    String dataFinal,
  ) async {
    final chave = '$contribuinteNumero-$dataInicial-$dataFinal';
    
    if (_cache.containsKey(chave)) {
      return _cache[chave]!;
    }
    
    final response = await service.consultarPagamentosPorData(
      contribuinteNumero: contribuinteNumero,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    );
    
    _cache[chave] = response;
    return response;
  }
}
```

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de pagamentos
- Monitorar tempo de resposta
- Alertar sobre falhas de emissão
- Rastrear volume de pagamentos por contribuinte
