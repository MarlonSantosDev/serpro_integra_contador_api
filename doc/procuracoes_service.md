# Procurações - Gestão de Procurações Eletrônicas

## Visão Geral

O serviço Procurações permite gerenciar procurações eletrônicas junto à Receita Federal do Brasil, incluindo consulta de procurações ativas, consulta de procurações específicas, consulta de informações detalhadas e gestão de procuradores.

## Funcionalidades

- **Consultar Procurações Ativas**: Consulta de procurações ativas do contribuinte
- **Consultar Procuração Específica**: Consulta de informações de uma procuração específica
- **Consultar Informações Detalhadas**: Consulta de informações detalhadas de procurações
- **Gestão de Procuradores**: Gestão de procuradores autorizados
- **Validações**: Validações específicas do sistema de Procurações

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço de Procurações

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
final procuracoesService = ProcuracoesService(apiClient);
```

### 2. Consultar Procurações Ativas

```dart
try {
  final response = await procuracoesService.consultarProcuracoesAtivas('00000000000000');
  
  if (response.sucesso) {
    print('Procurações ativas: ${response.dadosParsed?.listaProcuracoes.length ?? 0}');
    
    for (final procuração in response.dadosParsed?.listaProcuracoes ?? []) {
      print('Procuração: ${procuração.numero}');
      print('Procurador: ${procuração.procuradorNome}');
      print('CPF Procurador: ${procuração.procuradorCpf}');
      print('Data de início: ${procuração.dataInicioFormatada}');
      print('Data de fim: ${procuração.dataFimFormatada}');
      print('Situação: ${procuração.situacao}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar procurações ativas: $e');
}
```

### 3. Consultar Procuração Específica

```dart
try {
  final response = await procuracoesService.consultarProcuraçãoEspecifica('00000000000000', 'PROC123456');
  
  if (response.sucesso) {
    print('Procuração encontrada!');
    print('Número: ${response.dadosParsed?.numero}');
    print('Procurador: ${response.dadosParsed?.procuradorNome}');
    print('CPF Procurador: ${response.dadosParsed?.procuradorCpf}');
    print('Data de início: ${response.dadosParsed?.dataInicioFormatada}');
    print('Data de fim: ${response.dadosParsed?.dataFimFormatada}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Escopo: ${response.dadosParsed?.escopo}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar procuração específica: $e');
}
```

### 4. Consultar Informações Detalhadas

```dart
try {
  final response = await procuracoesService.consultarInformacoesDetalhadas('00000000000000');
  
  if (response.sucesso) {
    print('Informações detalhadas encontradas!');
    print('CNPJ: ${response.dadosParsed?.cnpj}');
    print('Razão social: ${response.dadosParsed?.razaoSocial}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Regime tributário: ${response.dadosParsed?.regimeTributario}');
    print('Data de abertura: ${response.dadosParsed?.dataAberturaFormatada}');
    print('Total de procurações: ${response.dadosParsed?.totalProcuracoes}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar informações detalhadas: $e');
}
```

### 5. Consultar Procuradores Autorizados

```dart
try {
  final response = await procuracoesService.consultarProcuradoresAutorizados('00000000000000');
  
  if (response.sucesso) {
    print('Procuradores autorizados: ${response.dadosParsed?.listaProcuradores.length ?? 0}');
    
    for (final procurador in response.dadosParsed?.listaProcuradores ?? []) {
      print('Procurador: ${procurador.nome}');
      print('CPF: ${procurador.cpf}');
      print('Situação: ${procurador.situacao}');
      print('Data de autorização: ${procurador.dataAutorizacaoFormatada}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar procuradores: $e');
}
```

## Estrutura de Dados

### ConsultarProcuracoesAtivasResponse

```dart
class ConsultarProcuracoesAtivasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarProcuracoesAtivasDados? dadosParsed;
}

class ConsultarProcuracoesAtivasDados {
  final List<ProcuraçãoItem> listaProcuracoes;
  // ... outros campos
}

class ProcuraçãoItem {
  final String numero;
  final String procuradorNome;
  final String procuradorCpf;
  final String dataInicioFormatada;
  final String dataFimFormatada;
  final String situacao;
  // ... outros campos
}
```

### ConsultarProcuraçãoEspecificaResponse

```dart
class ConsultarProcuraçãoEspecificaResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarProcuraçãoEspecificaDados? dadosParsed;
}

class ConsultarProcuraçãoEspecificaDados {
  final String numero;
  final String procuradorNome;
  final String procuradorCpf;
  final String dataInicioFormatada;
  final String dataFimFormatada;
  final String situacao;
  final String escopo;
  // ... outros campos
}
```

### ConsultarProcuradoresAutorizadosResponse

```dart
class ConsultarProcuradoresAutorizadosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarProcuradoresAutorizadosDados? dadosParsed;
}

class ConsultarProcuradoresAutorizadosDados {
  final List<ProcuradorItem> listaProcuradores;
  // ... outros campos
}

class ProcuradorItem {
  final String nome;
  final String cpf;
  final String situacao;
  final String dataAutorizacaoFormatada;
  // ... outros campos
}
```

## Validações Disponíveis

O serviço Procurações inclui várias validações para garantir a integridade dos dados:

```dart
// Validar CNPJ do contribuinte
final erro = procuracoesService.validarCnpjContribuinte('00000000000000');
if (erro != null) {
  print('Erro: $erro');
}

// Validar número da procuração
final erroProcuração = procuracoesService.validarNumeroProcuração('PROC123456');
if (erroProcuração != null) {
  print('Erro: $erroProcuração');
}

// Validar CPF do procurador
final erroCpf = procuracoesService.validarCpfProcurador('00000000000');
if (erroCpf != null) {
  print('Erro: $erroCpf');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do sistema de Procurações:

```dart
// Analisar erro
final analise = procuracoesService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (procuracoesService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = procuracoesService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Procuração não encontrada | Verificar se procuração existe |
| 004 | Procurador não autorizado | Verificar autorização do procurador |
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
  final procuracoesService = ProcuracoesService(apiClient);
  
  // 3. Consulta completa
  try {
    const contribuinteNumero = '00000000000000';
    
    // Consultar procurações ativas
    print('=== Procurações Ativas ===');
    final procuracoes = await procuracoesService.consultarProcuracoesAtivas(contribuinteNumero);
    if (procuracoes.sucesso) {
      print('Total de procurações: ${procuracoes.dadosParsed?.listaProcuracoes.length ?? 0}');
      
      for (final procuração in procuracoes.dadosParsed?.listaProcuracoes ?? []) {
        print('Procuração: ${procuração.numero} - ${procuração.procuradorNome}');
      }
    }
    
    // Consultar procuradores autorizados
    print('\n=== Procuradores Autorizados ===');
    final procuradores = await procuracoesService.consultarProcuradoresAutorizados(contribuinteNumero);
    if (procuradores.sucesso) {
      print('Total de procuradores: ${procuradores.dadosParsed?.listaProcuradores.length ?? 0}');
      
      for (final procurador in procuradores.dadosParsed?.listaProcuradores ?? []) {
        print('Procurador: ${procurador.nome} - ${procurador.cpf}');
      }
    }
    
    // Consultar informações detalhadas
    print('\n=== Informações Detalhadas ===');
    final info = await procuracoesService.consultarInformacoesDetalhadas(contribuinteNumero);
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

// Números de procuração de teste
const numeroProcuraçãoTeste = 'PROC123456';

// CPFs de procuradores de teste
const cpfProcuradorTeste = '00000000000';

// Situações de teste
const situacaoTeste = 'ATIVA';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Acesso**: Algumas informações podem ter restrições de acesso
5. **Procurações**: Apenas procurações ativas são consultadas

## Casos de Uso Comuns

### 1. Consulta Completa de Procurações

```dart
Future<void> consultarProcuracoesCompleto(String contribuinteNumero) async {
  try {
    // Consultar procurações ativas
    final procuracoes = await procuracoesService.consultarProcuracoesAtivas(contribuinteNumero);
    if (!procuracoes.sucesso) return;
    
    // Consultar procuradores autorizados
    final procuradores = await procuracoesService.consultarProcuradoresAutorizados(contribuinteNumero);
    if (!procuradores.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await procuracoesService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Procurações ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Procurações ativas: ${procuracoes.dadosParsed?.listaProcuracoes.length}');
    print('Procuradores autorizados: ${procuradores.dadosParsed?.listaProcuradores.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Monitoramento de Procurações

```dart
Future<void> monitorarProcuracoes(String contribuinteNumero) async {
  try {
    // Consultar procurações ativas
    final procuracoes = await procuracoesService.consultarProcuracoesAtivas(contribuinteNumero);
    if (!procuracoes.sucesso) return;
    
    final listaProcuracoes = procuracoes.dadosParsed?.listaProcuracoes ?? [];
    
    for (final procuração in listaProcuracoes) {
      final dataFim = DateTime.tryParse(procuração.dataFimFormatada);
      if (dataFim != null) {
        final diasParaVencimento = dataFim.difference(DateTime.now()).inDays;
        
        if (diasParaVencimento <= 30) {
          print('⚠️ Procuração ${procuração.numero} vence em $diasParaVencimento dias');
          print('Procurador: ${procuração.procuradorNome}');
        }
      }
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

### 3. Relatório de Procurações

```dart
Future<void> relatorioProcuracoes(String contribuinteNumero) async {
  try {
    // Consultar procurações ativas
    final procuracoes = await procuracoesService.consultarProcuracoesAtivas(contribuinteNumero);
    if (!procuracoes.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await procuracoesService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Procurações ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Situação: ${info.dadosParsed?.situacao}');
    print('Regime tributário: ${info.dadosParsed?.regimeTributario}');
    print('Procurações ativas: ${procuracoes.dadosParsed?.listaProcuracoes.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Integração com Outros Serviços

O Procurações Service pode ser usado em conjunto com:

- **Autentica Procurador Service**: Para autenticação de procuradores
- **DCTFWeb Service**: Para consultar declarações relacionadas
- **MIT Service**: Para consultar apurações relacionadas
- **Eventos Atualização Service**: Para monitorar atualizações

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de procurações
- Monitorar procurações próximas do vencimento
- Alertar sobre mudanças de status
- Rastrear erros de validação
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço de Procurações:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package