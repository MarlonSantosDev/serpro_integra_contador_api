# Eventos Atualização Service

## Visão Geral

O `EventosAtualizacaoService` é responsável por monitorar atualizações em sistemas de negócio como DCTFWeb, CaixaPostal e PagamentoWeb para contribuintes específicos. Este serviço permite consultar eventos de última atualização de forma assíncrona.

## Funcionalidades Principais

- **Monitoramento Assíncrono**: Consulta eventos de atualização de forma assíncrona
- **Suporte a PF e PJ**: Monitora tanto Pessoa Física quanto Pessoa Jurídica
- **Múltiplos Sistemas**: Monitora DCTFWeb, CaixaPostal e PagamentoWeb
- **Processo em Duas Etapas**: Solicita eventos e depois obtém resultados
- **Métodos de Conveniência**: Operações simplificadas para casos comuns

## Tipos de Eventos Disponíveis

- **DCTFWeb**: Atualizações no sistema DCTFWeb
- **CaixaPostal**: Atualizações na Caixa Postal
- **PagamentoWeb**: Atualizações no sistema PagamentoWeb

## Métodos Disponíveis

### 1. Solicitar Eventos PF

```dart
Future<SolicitarEventosPFResponse> solicitarEventosPF({
  required List<String> cpfs,
  required TipoEvento evento,
})
```

**Parâmetros:**
- `cpfs`: Lista de CPFs (máximo 1000)
- `evento`: Tipo de evento a ser monitorado

**Retorna:** Protocolo para consulta posterior

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.solicitarEventosPF(
  cpfs: ['12345678901', '98765432109'],
  evento: TipoEvento.dctfweb,
);
print('Protocolo: ${response.dados.protocolo}');
```

### 2. Obter Eventos PF

```dart
Future<ObterEventosPFResponse> obterEventosPF({
  required String protocolo,
  required TipoEvento evento,
})
```

**Parâmetros:**
- `protocolo`: Protocolo retornado pela solicitação anterior
- `evento`: Tipo de evento consultado

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.obterEventosPF(
  protocolo: 'PROTOCOLO_123',
  evento: TipoEvento.dctfweb,
);
```

### 3. Solicitar Eventos PJ

```dart
Future<SolicitarEventosPJResponse> solicitarEventosPJ({
  required List<String> cnpjs,
  required TipoEvento evento,
})
```

**Parâmetros:**
- `cnpjs`: Lista de CNPJs (máximo 1000)
- `evento`: Tipo de evento a ser monitorado

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.solicitarEventosPJ(
  cnpjs: ['12345678000195', '98765432000100'],
  evento: TipoEvento.caixaPostal,
);
```

### 4. Obter Eventos PJ

```dart
Future<ObterEventosPJResponse> obterEventosPJ({
  required String protocolo,
  required TipoEvento evento,
})
```

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.obterEventosPJ(
  protocolo: 'PROTOCOLO_456',
  evento: TipoEvento.caixaPostal,
);
```

### 5. Solicitar e Obter Eventos PF (Conveniência)

```dart
Future<ObterEventosPFResponse> solicitarEObterEventosPF({
  required List<String> cpfs,
  required TipoEvento evento,
  Duration? tempoEsperaCustomizado,
})
```

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.solicitarEObterEventosPF(
  cpfs: ['12345678901'],
  evento: TipoEvento.pagamentoWeb,
  tempoEsperaCustomizado: Duration(seconds: 30),
);
```

### 6. Solicitar e Obter Eventos PJ (Conveniência)

```dart
Future<ObterEventosPJResponse> solicitarEObterEventosPJ({
  required List<String> cnpjs,
  required TipoEvento evento,
  Duration? tempoEsperaCustomizado,
})
```

**Exemplo:**
```dart
final response = await eventosAtualizacaoService.solicitarEObterEventosPJ(
  cnpjs: ['12345678000195'],
  evento: TipoEvento.dctfweb,
);
```

## Fluxo de Trabalho

### Processo Assíncrono (Recomendado)

```dart
// 1. Solicitar eventos
final solicitacao = await eventosAtualizacaoService.solicitarEventosPF(
  cpfs: ['12345678901'],
  evento: TipoEvento.dctfweb,
);

// 2. Aguardar tempo estimado
await Future.delayed(Duration(milliseconds: solicitacao.dados.tempoEsperaMedioEmMs));

// 3. Obter resultados
final resultados = await eventosAtualizacaoService.obterEventosPF(
  protocolo: solicitacao.dados.protocolo,
  evento: TipoEvento.dctfweb,
);
```

### Processo Simplificado

```dart
// Usar método de conveniência
final resultados = await eventosAtualizacaoService.solicitarEObterEventosPF(
  cpfs: ['12345678901'],
  evento: TipoEvento.dctfweb,
);
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
  final eventosService = EventosAtualizacaoService(apiClient);

  try {
    // Lista de CPFs para monitorar
    final cpfs = ['12345678901', '98765432109'];
    
    print('=== Monitorando Eventos PF ===');
    
    // Solicitar eventos
    final solicitacao = await eventosService.solicitarEventosPF(
      cpfs: cpfs,
      evento: TipoEvento.dctfweb,
    );
    
    print('Protocolo: ${solicitacao.dados.protocolo}');
    print('Tempo estimado: ${solicitacao.dados.tempoEsperaMedioEmMs}ms');
    
    // Aguardar tempo estimado
    print('Aguardando processamento...');
    await Future.delayed(Duration(milliseconds: solicitacao.dados.tempoEsperaMedioEmMs));
    
    // Obter resultados
    final resultados = await eventosService.obterEventosPF(
      protocolo: solicitacao.dados.protocolo,
      evento: TipoEvento.dctfweb,
    );
    
    if (resultados.sucesso) {
      print('=== Resultados ===');
      for (final evento in resultados.dados.eventos) {
        print('CPF: ${evento.cpf}');
        print('Última atualização: ${evento.ultimaAtualizacao}');
        print('Sistema: ${evento.sistema}');
        print('---');
      }
    } else {
      print('Erro: ${resultados.mensagemPrincipal}');
    }
    
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Monitoramento de Múltiplos Sistemas

```dart
Future<void> monitorarTodosSistemas(List<String> cnpjs) async {
  final sistemas = [
    TipoEvento.dctfweb,
    TipoEvento.caixaPostal,
    TipoEvento.pagamentoWeb,
  ];
  
  for (final sistema in sistemas) {
    try {
      print('=== Monitorando $sistema ===');
      
      final response = await eventosAtualizacaoService.solicitarEObterEventosPJ(
        cnpjs: cnpjs,
        evento: sistema,
      );
      
      if (response.sucesso) {
        print('Eventos encontrados: ${response.dados.eventos.length}');
        for (final evento in response.dados.eventos) {
          print('CNPJ: ${evento.cnpj} - Última atualização: ${evento.ultimaAtualizacao}');
        }
      } else {
        print('Erro no sistema $sistema: ${response.mensagemPrincipal}');
      }
      
    } catch (e) {
      print('Erro ao monitorar $sistema: $e');
    }
  }
}
```

## Tratamento de Erros

### Erros Comuns

- **Lista Vazia**: CPFs/CNPJs não podem estar vazios
- **Limite Excedido**: Máximo de 1000 documentos por consulta
- **Protocolo Inválido**: Protocolo deve ser válido
- **Timeout**: Tempo de espera pode ser insuficiente

### Tratamento de Exceções

```dart
try {
  final response = await eventosAtualizacaoService.solicitarEventosPF(
    cpfs: cpfs,
    evento: TipoEvento.dctfweb,
  );
} catch (e) {
  if (e.toString().contains('lista vazia')) {
    print('Lista de CPFs não pode estar vazia');
  } else if (e.toString().contains('limite excedido')) {
    print('Máximo de 1000 documentos por consulta');
  } else {
    print('Erro inesperado: $e');
  }
}
```

## Limitações

- Máximo de 1000 documentos por consulta
- Processo assíncrono requer aguardar tempo estimado
- Alguns sistemas podem ter limitações de frequência
- Protocolos têm validade limitada

## Casos de Uso Comuns

### 1. Monitoramento de Clientes

```dart
// Monitorar atualizações de clientes específicos
final clientes = ['12345678000195', '98765432000100'];
final eventos = await eventosAtualizacaoService.solicitarEObterEventosPJ(
  cnpjs: clientes,
  evento: TipoEvento.dctfweb,
);
```

### 2. Verificação de Atualizações

```dart
// Verificar se houve atualizações recentes
final eventos = await eventosAtualizacaoService.solicitarEObterEventosPF(
  cpfs: ['12345678901'],
  evento: TipoEvento.caixaPostal,
);

if (eventos.dados.eventos.isNotEmpty) {
  print('Atualizações encontradas!');
}
```

### 3. Monitoramento Contínuo

```dart
// Monitorar continuamente
Timer.periodic(Duration(minutes: 30), (timer) async {
  try {
    final eventos = await eventosAtualizacaoService.solicitarEObterEventosPJ(
      cnpjs: ['12345678000195'],
      evento: TipoEvento.pagamentoWeb,
    );
    
    if (eventos.dados.eventos.isNotEmpty) {
      print('Novas atualizações detectadas!');
      // Processar atualizações
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
});
```

## Integração com Outros Serviços

O EventosAtualizacaoService pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações após detectar atualizações
- **Caixa Postal Service**: Para consultar mensagens após detectar atualizações
- **PagamentoWeb Service**: Para consultar pagamentos após detectar atualizações

## Performance e Otimização

### Dicas de Performance

1. **Agrupar Consultas**: Use listas maiores em vez de consultas individuais
2. **Cache de Resultados**: Implemente cache para evitar consultas desnecessárias
3. **Tempo de Espera**: Use o tempo estimado fornecido pelo sistema
4. **Monitoramento Seletivo**: Monitore apenas sistemas relevantes

### Exemplo de Cache

```dart
class EventosCache {
  final Map<String, DateTime> _ultimaConsulta = {};
  
  Future<bool> precisaConsultar(String documento, TipoEvento evento) async {
    final chave = '$documento-${evento.name}';
    final ultimaConsulta = _ultimaConsulta[chave];
    
    if (ultimaConsulta == null) return true;
    
    // Consultar apenas se passou mais de 1 hora
    return DateTime.now().difference(ultimaConsulta).inHours >= 1;
  }
  
  void marcarConsulta(String documento, TipoEvento evento) {
    final chave = '$documento-${evento.name}';
    _ultimaConsulta[chave] = DateTime.now();
  }
}
```

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as solicitações de eventos
- Monitorar tempo de resposta
- Alertar sobre falhas de protocolo
- Rastrear taxa de sucesso por sistema
