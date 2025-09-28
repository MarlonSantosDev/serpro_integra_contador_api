# MIT Service

## Visão Geral

O `MitService` é responsável pela integração com o MIT (Módulo de Inclusão de Tributos) do sistema DCTFWeb. Este serviço implementa todos os serviços disponíveis do Integra MIT para gerenciamento de apurações tributárias.

## Funcionalidades Principais

- **Encerrar Apuração**: Inicia processo de encerramento de apurações
- **Consultar Situação**: Consulta status de encerramento de apurações
- **Consultar Apuração**: Consulta dados detalhados de apurações
- **Listar Apurações**: Lista apurações por ano/mês
- **Métodos de Conveniência**: Operações simplificadas para casos comuns

## Serviços Disponíveis

- **ENCAPURACAO314**: Encerrar Apuração
- **SITUACAOENC315**: Consultar Situação Encerramento
- **CONSAPURACAO316**: Consultar Apuração
- **LISTAAPURACOES317**: Listar Apurações

## Métodos Disponíveis

### 1. Encerrar Apuração

```dart
Future<EncerrarApuracaoResponse> encerrarApuracao({
  required String contribuinteNumero,
  required PeriodoApuracao periodoApuracao,
  required DadosIniciais dadosIniciais,
  Debitos? debitos,
  List<EventoEspecial>? listaEventosEspeciais,
  bool? transmissaoImediata,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Parâmetros:**
- `contribuinteNumero`: CNPJ do contribuinte (apenas PJ)
- `periodoApuracao`: Período da apuração (mês e ano)
- `dadosIniciais`: Dados iniciais da apuração
- `debitos`: Débitos da apuração (obrigatório se não for sem movimento)
- `listaEventosEspeciais`: Lista de eventos especiais (máximo 5)
- `transmissaoImediata`: Indicador de transmissão imediata
- `contratanteNumero`: CNPJ do contratante (opcional)
- `autorPedidoDadosNumero`: CNPJ do autor do pedido (opcional)

**Exemplo:**
```dart
final response = await mitService.encerrarApuracao(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  dadosIniciais: DadosIniciais(
    semMovimento: false,
    qualificacaoPj: QualificacaoPj.pjEmGeral,
    tributacaoLucro: TributacaoLucro.realAnual,
    responsavelApuracao: ResponsavelApuracao(
      nome: 'João Silva',
      cpf: '12345678901',
    ),
  ),
  debitos: Debitos(
    valorTotal: 1000.00,
    listaDebitos: [
      DebitoItem(
        codigoReceita: '1001',
        valor: 1000.00,
      ),
    ],
  ),
);
```

### 2. Consultar Situação de Encerramento

```dart
Future<ConsultarSituacaoEncerramentoResponse> consultarSituacaoEncerramento({
  required String contribuinteNumero,
  required String protocoloEncerramento,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.consultarSituacaoEncerramento(
  contribuinteNumero: '12345678000195',
  protocoloEncerramento: 'PROTOCOLO_123',
);
```

### 3. Consultar Apuração

```dart
Future<ConsultarApuracaoResponse> consultarApuracao({
  required String contribuinteNumero,
  required int idApuracao,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.consultarApuracao(
  contribuinteNumero: '12345678000195',
  idApuracao: 12345,
);
```

### 4. Listar Apurações

```dart
Future<ListarApuracaoesResponse> listarApuracaoes({
  required String contribuinteNumero,
  required int anoApuracao,
  int? mesApuracao,
  int? situacaoApuracao,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.listarApuracaoes(
  contribuinteNumero: '12345678000195',
  anoApuracao: 2024,
  mesApuracao: 1,
);
```

## Métodos de Conveniência

### 1. Criar Apuração Sem Movimento

```dart
Future<EncerrarApuracaoResponse> criarApuracaoSemMovimento({
  required String contribuinteNumero,
  required PeriodoApuracao periodoApuracao,
  required ResponsavelApuracao responsavelApuracao,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.criarApuracaoSemMovimento(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
);
```

### 2. Criar Apuração Com Movimento

```dart
Future<EncerrarApuracaoResponse> criarApuracaoComMovimento({
  required String contribuinteNumero,
  required PeriodoApuracao periodoApuracao,
  required ResponsavelApuracao responsavelApuracao,
  required Debitos debitos,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.criarApuracaoComMovimento(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
  debitos: Debitos(
    valorTotal: 1000.00,
    listaDebitos: [
      DebitoItem(
        codigoReceita: '1001',
        valor: 1000.00,
      ),
    ],
  ),
);
```

### 3. Consultar Apurações por Mês

```dart
Future<ListarApuracaoesResponse> consultarApuracaoesPorMes({
  required String contribuinteNumero,
  required int anoApuracao,
  required int mesApuracao,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

### 4. Consultar Apurações Encerradas

```dart
Future<ListarApuracaoesResponse> consultarApuracaoesEncerradas({
  required String contribuinteNumero,
  required int anoApuracao,
  int? mesApuracao,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

### 5. Aguardar Encerramento

```dart
Future<ConsultarSituacaoEncerramentoResponse> aguardarEncerramento({
  required String contribuinteNumero,
  required String protocoloEncerramento,
  int intervaloConsulta = 30,
  int timeoutSegundos = 300,
  String? contratanteNumero,
  String? autorPedidoDadosNumero,
})
```

**Exemplo:**
```dart
final response = await mitService.aguardarEncerramento(
  contribuinteNumero: '12345678000195',
  protocoloEncerramento: 'PROTOCOLO_123',
  intervaloConsulta: 30, // segundos
  timeoutSegundos: 300, // 5 minutos
);
```

## Exemplo de Uso Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient(
    baseUrl: 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1',
    clientId: 'seu_client_id',
    clientSecret: 'seu_client_secret',
  );

  // Criar serviço
  final mitService = MitService(apiClient);

  try {
    const contribuinteNumero = '12345678000195';
    
    // 1. Criar apuração sem movimento
    print('=== Criando Apuração Sem Movimento ===');
    final apuracaoSemMovimento = await mitService.criarApuracaoSemMovimento(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
      responsavelApuracao: ResponsavelApuracao(
        nome: 'João Silva',
        cpf: '12345678901',
      ),
    );
    
    if (apuracaoSemMovimento.sucesso) {
      print('Apuração criada com sucesso!');
      print('Protocolo: ${apuracaoSemMovimento.dados.protocoloEncerramento}');
      print('ID: ${apuracaoSemMovimento.dados.idApuracao}');
      
      // 2. Aguardar encerramento
      print('\n=== Aguardando Encerramento ===');
      final situacao = await mitService.aguardarEncerramento(
        contribuinteNumero: contribuinteNumero,
        protocoloEncerramento: apuracaoSemMovimento.dados.protocoloEncerramento,
      );
      
      if (situacao.sucesso) {
        print('Situação: ${situacao.situacaoEnum}');
        print('Data encerramento: ${situacao.dataEncerramento}');
        
        // 3. Consultar apuração
        print('\n=== Consultando Apuração ===');
        final apuracao = await mitService.consultarApuracao(
          contribuinteNumero: contribuinteNumero,
          idApuracao: apuracaoSemMovimento.dados.idApuracao,
        );
        
        if (apuracao.sucesso) {
          print('Apuração consultada com sucesso!');
          print('Período: ${apuracao.dados.periodoApuracao}');
          print('Situação: ${apuracao.dados.situacao}');
        }
      }
    }
    
    // 4. Listar apurações do ano
    print('\n=== Listando Apurações ===');
    final apuracoes = await mitService.listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: 2024,
    );
    
    if (apuracoes.sucesso) {
      print('Apurações encontradas: ${apuracoes.dados.apuracoes.length}');
      for (final apuracao in apuracoes.dados.apuracoes) {
        print('ID: ${apuracao.id} - Período: ${apuracao.periodo} - Situação: ${apuracao.situacao}');
      }
    }
    
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Tipos de Dados

### PeriodoApuracao

```dart
final periodo = PeriodoApuracao(ano: 2024, mes: 1);
```

### DadosIniciais

```dart
final dadosIniciais = DadosIniciais(
  semMovimento: false,
  qualificacaoPj: QualificacaoPj.pjEmGeral,
  tributacaoLucro: TributacaoLucro.realAnual,
  variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
  regimePisCofins: RegimePisCofins.naoCumulativa,
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
);
```

### Debitos

```dart
final debitos = Debitos(
  valorTotal: 1000.00,
  listaDebitos: [
    DebitoItem(
      codigoReceita: '1001',
      valor: 1000.00,
    ),
  ],
);
```

### ResponsavelApuracao

```dart
final responsavel = ResponsavelApuracao(
  nome: 'João Silva',
  cpf: '12345678901',
);
```

## Enums Disponíveis

### QualificacaoPj

- `pjEmGeral`
- `pjLucroPresumido`
- `pjLucroReal`

### TributacaoLucro

- `realAnual`
- `realTrimestral`
- `presumido`

### VariacoesMonetarias

- `regimeCaixa`
- `regimeCompetencia`

### RegimePisCofins

- `cumulativa`
- `naoCumulativa`

### SituacaoApuracao

- `emEdicao`
- `encerrada`
- `emEdicaoComPendencias`

## Tratamento de Erros

### Erros Comuns

- **CNPJ Inválido**: Apenas CNPJs são aceitos
- **Período Inválido**: Período deve ser válido
- **Dados Incompletos**: Dados obrigatórios não fornecidos
- **Protocolo Inválido**: Protocolo deve ser válido

### Tratamento de Exceções

```dart
try {
  final response = await mitService.encerrarApuracao(
    contribuinteNumero: '12345678000195',
    periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
    dadosIniciais: dadosIniciais,
  );
} catch (e) {
  if (e.toString().contains('CNPJ inválido')) {
    print('CNPJ deve ser válido');
  } else if (e.toString().contains('período inválido')) {
    print('Período deve ser válido');
  } else {
    print('Erro inesperado: $e');
  }
}
```

## Limitações

- Apenas CNPJs são aceitos (Pessoa Jurídica)
- Máximo de 5 eventos especiais por apuração
- Transmissão imediata apenas para sem movimento
- Timeout padrão de 5 minutos para aguardar encerramento

## Casos de Uso Comuns

### 1. Apuração Sem Movimento

```dart
// Para DCTFWeb sem movimento
final response = await mitService.criarApuracaoSemMovimento(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
);
```

### 2. Apuração Com Movimento

```dart
// Para DCTFWeb com movimento
final response = await mitService.criarApuracaoComMovimento(
  contribuinteNumero: '12345678000195',
  periodoApuracao: PeriodoApuracao(ano: 2024, mes: 1),
  responsavelApuracao: ResponsavelApuracao(
    nome: 'João Silva',
    cpf: '12345678901',
  ),
  debitos: Debitos(
    valorTotal: 1000.00,
    listaDebitos: [
      DebitoItem(
        codigoReceita: '1001',
        valor: 1000.00,
      ),
    ],
  ),
);
```

### 3. Monitoramento de Encerramento

```dart
// Aguardar encerramento com timeout customizado
final response = await mitService.aguardarEncerramento(
  contribuinteNumero: '12345678000195',
  protocoloEncerramento: 'PROTOCOLO_123',
  intervaloConsulta: 15, // 15 segundos
  timeoutSegundos: 600, // 10 minutos
);
```

## Integração com Outros Serviços

O MIT Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações após encerrar apurações
- **Eventos Atualização Service**: Para monitorar atualizações de apurações
- **Autentica Procurador Service**: Para autenticação de procuradores

## Performance e Otimização

### Dicas de Performance

1. **Usar Métodos de Conveniência**: Para casos comuns
2. **Aguardar Encerramento**: Usar timeout apropriado
3. **Consultar em Lote**: Listar apurações em vez de consultar individualmente
4. **Cache de Resultados**: Implementar cache para consultas frequentes

### Exemplo de Cache

```dart
class MitCache {
  final Map<String, ListarApuracaoesResponse> _cache = {};
  
  Future<ListarApuracaoesResponse> consultarComCache(
    MitService service,
    String contribuinteNumero,
    int anoApuracao,
  ) async {
    final chave = '$contribuinteNumero-$anoApuracao';
    
    if (_cache.containsKey(chave)) {
      return _cache[chave]!;
    }
    
    final response = await service.listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: anoApuracao,
    );
    
    _cache[chave] = response;
    return response;
  }
}
```

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as operações de encerramento
- Monitorar tempo de encerramento
- Alertar sobre falhas de protocolo
- Rastrear taxa de sucesso por contribuinte
