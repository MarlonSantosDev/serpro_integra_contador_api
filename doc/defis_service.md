# DEFIS - Declaração de Informações Socioeconômicas e Fiscais

## Visão Geral

O serviço DEFIS permite transmitir declarações de informações socioeconômicas e fiscais para empresas do Simples Nacional. Este serviço é essencial para empresas que precisam declarar suas informações fiscais periodicamente.

## Funcionalidades

- **Transmitir Declaração**: Envio de declarações DEFIS com dados socioeconômicos e fiscais
- **Validação de Dados**: Validação automática dos dados antes do envio
- **Tratamento de Erros**: Gestão adequada de códigos de status e mensagens de erro

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço DEFIS

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
final defisService = DefisService(apiClient);
```

### 2. Preparar Dados da Declaração

```dart
final declaracao = TransmitirDeclaracaoRequest(
  ano: 2024,
  inatividade: 2,
  empresa: Empresa(
    ganhoCapital: 0.0,
    qtdEmpregadoInicial: 1,
    qtdEmpregadoFinal: 1,
    receitaBruta: 100000.0,
    // ... outros campos obrigatórios
  ),
);
```

### 3. Transmitir Declaração

```dart
try {
  final response = await defisService.transmitirDeclaracao(
    '00000000000000', // CNPJ Contratante
    declaracao,
  );
  
  if (response.sucesso) {
    print('Sucesso! ID DEFIS: ${response.dados.idDefis}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro na transmissão: $e');
}
```

## Estrutura de Dados

### TransmitirDeclaracaoRequest

```dart
class TransmitirDeclaracaoRequest {
  final int ano;                    // Ano da declaração
  final int inatividade;            // Indicador de inatividade
  final Empresa empresa;            // Dados da empresa
  // ... outros campos
}
```

### Empresa

```dart
class Empresa {
  final double ganhoCapital;        // Ganho de capital
  final int qtdEmpregadoInicial;    // Quantidade de empregados inicial
  final int qtdEmpregadoFinal;      // Quantidade de empregados final
  final double receitaBruta;        // Receita bruta
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Ano inválido | Usar ano válido para declaração |
| 004 | Empresa não encontrada | Verificar se empresa está cadastrada |

## Exemplos Práticos

### Exemplo Completo

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
  final defisService = DefisService(apiClient);
  
  // 3. Preparar dados da declaração
  final declaracao = TransmitirDeclaracaoRequest(
    ano: 2024,
    inatividade: 2,
    empresa: Empresa(
      ganhoCapital: 0.0,
      qtdEmpregadoInicial: 1,
      qtdEmpregadoFinal: 1,
      receitaBruta: 100000.0,
      // ... outros campos obrigatórios
    ),
  );
  
  // 4. Transmitir declaração
  try {
    final response = await defisService.transmitirDeclaracao(
      '00000000000000', // CNPJ Contratante
      declaracao,
    );
    
    if (response.sucesso) {
      print('Sucesso! ID DEFIS: ${response.dados.idDefis}');
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro na transmissão: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Estrutura base para testes (usando a nova API simplificada)
final requestTeste = BaseRequest(
  contribuinteNumero: cnpjTeste,
  pedidoDados: PedidoDados(
    idSistema: 'DEFIS',
    idServico: 'SERVICO_EXEMPLO',
    dados: 'dados_do_servico',
  ),
);
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio

## Suporte

Para dúvidas sobre o serviço DEFIS:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
