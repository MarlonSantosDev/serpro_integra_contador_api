# PERTSN - Pertinência do Simples Nacional

## Visão Geral

O serviço PERTSN permite consultar informações sobre a pertinência de contribuintes optantes do Simples Nacional em relação a parcelamentos, incluindo consulta de pertinência, consulta de parcelamentos relacionados e consulta de informações detalhadas.

## Funcionalidades

- **Consultar Pertinência**: Consulta de pertinência do contribuinte em parcelamentos
- **Consultar Parcelamentos Relacionados**: Consulta de parcelamentos relacionados ao contribuinte
- **Consultar Informações Detalhadas**: Consulta de informações detalhadas de pertinência
- **Validações**: Validações específicas do sistema PERTSN

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PERTSN

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
final pertsnService = PertsnService(apiClient);
```

### 2. Consultar Pertinência

```dart
try {
  final response = await pertsnService.consultarPertinencia('00000000000000');
  
  if (response.sucesso) {
    print('Pertinência encontrada!');
    print('CNPJ: ${response.dadosParsed?.cnpj}');
    print('Pertinente: ${response.dadosParsed?.pertinente}');
    print('Data de consulta: ${response.dadosParsed?.dataConsultaFormatada}');
    print('Motivo: ${response.dadosParsed?.motivo}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar pertinência: $e');
}
```

### 3. Consultar Parcelamentos Relacionados

```dart
try {
  final response = await pertsnService.consultarParcelamentosRelacionados('00000000000000');
  
  if (response.sucesso) {
    print('Parcelamentos relacionados: ${response.dadosParsed?.listaParcelamentos.length ?? 0}');
    
    for (final parcelamento in response.dadosParsed?.listaParcelamentos ?? []) {
      print('Parcelamento: ${parcelamento.numero}');
      print('Situação: ${parcelamento.situacao}');
      print('Valor: ${parcelamento.valorFormatado}');
      print('Data: ${parcelamento.dataFormatada}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar parcelamentos: $e');
}
```

### 4. Consultar Informações Detalhadas

```dart
try {
  final response = await pertsnService.consultarInformacoesDetalhadas('00000000000000');
  
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

### ConsultarPertinenciaResponse

```dart
class ConsultarPertinenciaResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarPertinenciaDados? dadosParsed;
}

class ConsultarPertinenciaDados {
  final String cnpj;
  final bool pertinente;
  final String dataConsultaFormatada;
  final String motivo;
  // ... outros campos
}
```

### ConsultarParcelamentosRelacionadosResponse

```dart
class ConsultarParcelamentosRelacionadosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarParcelamentosRelacionadosDados? dadosParsed;
}

class ConsultarParcelamentosRelacionadosDados {
  final List<ParcelamentoItem> listaParcelamentos;
  // ... outros campos
}

class ParcelamentoItem {
  final String numero;
  final String situacao;
  final String valorFormatado;
  final String dataFormatada;
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

O serviço PERTSN inclui várias validações para garantir a integridade dos dados:

```dart
// Validar CNPJ do contribuinte
final erro = pertsnService.validarCnpjContribuinte('00000000000000');
if (erro != null) {
  print('Erro: $erro');
}

// Validar pertinência
final erroPertinencia = pertsnService.validarPertinencia(true);
if (erroPertinencia != null) {
  print('Erro: $erroPertinencia');
}

// Validar situação do parcelamento
final erroSituacao = pertsnService.validarSituacaoParcelamento('ATIVO');
if (erroSituacao != null) {
  print('Erro: $erroSituacao');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do PERTSN:

```dart
// Analisar erro
final analise = pertsnService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (pertsnService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = pertsnService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Contribuinte não encontrado | Verificar se contribuinte existe |
| 004 | Pertinência não disponível | Verificar se pertinência está disponível |
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
  final pertsnService = PertsnService(apiClient);
  
  // 3. Consulta completa
  try {
    const contribuinteNumero = '00000000000000';
    
    // Consultar pertinência
    print('=== Pertinência ===');
    final pertinencia = await pertsnService.consultarPertinencia(contribuinteNumero);
    if (pertinencia.sucesso) {
      print('Pertinente: ${pertinencia.dadosParsed?.pertinente}');
      print('Motivo: ${pertinencia.dadosParsed?.motivo}');
    }
    
    // Consultar parcelamentos relacionados
    print('\n=== Parcelamentos Relacionados ===');
    final parcelamentos = await pertsnService.consultarParcelamentosRelacionados(contribuinteNumero);
    if (parcelamentos.sucesso) {
      print('Total de parcelamentos: ${parcelamentos.dadosParsed?.listaParcelamentos.length ?? 0}');
      
      for (final parcelamento in parcelamentos.dadosParsed?.listaParcelamentos ?? []) {
        print('Parcelamento: ${parcelamento.numero} - ${parcelamento.situacao}');
      }
    }
    
    // Consultar informações detalhadas
    print('\n=== Informações Detalhadas ===');
    final info = await pertsnService.consultarInformacoesDetalhadas(contribuinteNumero);
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

// Situações de teste
const situacaoTeste = 'ATIVO';

// Pertinência de teste
const pertinenteTeste = true;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Simples Nacional**: Apenas para contribuintes optantes do Simples Nacional
5. **Acesso**: Algumas informações podem ter restrições de acesso

## Casos de Uso Comuns

### 1. Consulta Completa de Pertinência

```dart
Future<void> consultarPertinenciaCompleta(String contribuinteNumero) async {
  try {
    // Consultar pertinência
    final pertinencia = await pertsnService.consultarPertinencia(contribuinteNumero);
    if (!pertinencia.sucesso) return;
    
    // Consultar parcelamentos relacionados
    final parcelamentos = await pertsnService.consultarParcelamentosRelacionados(contribuinteNumero);
    if (!parcelamentos.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await pertsnService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Pertinência ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Pertinente: ${pertinencia.dadosParsed?.pertinente}');
    print('Motivo: ${pertinencia.dadosParsed?.motivo}');
    print('Parcelamentos: ${parcelamentos.dadosParsed?.listaParcelamentos.length}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Monitoramento de Pertinência

```dart
Future<void> monitorarPertinencia(String contribuinteNumero) async {
  try {
    // Consultar pertinência
    final pertinencia = await pertsnService.consultarPertinencia(contribuinteNumero);
    if (!pertinencia.sucesso) return;
    
    if (pertinencia.dadosParsed?.pertinente == true) {
      print('✅ Contribuinte pertinente a parcelamentos');
      
      // Consultar parcelamentos relacionados
      final parcelamentos = await pertsnService.consultarParcelamentosRelacionados(contribuinteNumero);
      if (parcelamentos.sucesso) {
        print('Parcelamentos relacionados: ${parcelamentos.dadosParsed?.listaParcelamentos.length}');
      }
    } else {
      print('❌ Contribuinte não pertinente a parcelamentos');
      print('Motivo: ${pertinencia.dadosParsed?.motivo}');
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

### 3. Relatório de Pertinência

```dart
Future<void> relatorioPertinencia(String contribuinteNumero) async {
  try {
    // Consultar pertinência
    final pertinencia = await pertsnService.consultarPertinencia(contribuinteNumero);
    if (!pertinencia.sucesso) return;
    
    // Consultar informações detalhadas
    final info = await pertsnService.consultarInformacoesDetalhadas(contribuinteNumero);
    if (!info.sucesso) return;
    
    print('=== Relatório de Pertinência ===');
    print('CNPJ: ${contribuinteNumero}');
    print('Razão social: ${info.dadosParsed?.razaoSocial}');
    print('Situação: ${info.dadosParsed?.situacao}');
    print('Regime tributário: ${info.dadosParsed?.regimeTributario}');
    print('Pertinente: ${pertinencia.dadosParsed?.pertinente}');
    print('Motivo: ${pertinencia.dadosParsed?.motivo}');
    print('Data de consulta: ${pertinencia.dadosParsed?.dataConsultaFormatada}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Integração com Outros Serviços

O PERTSN Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas
- **MIT Service**: Para consultar apurações relacionadas
- **PARCSN Service**: Para consultar parcelamentos relacionados
- **Eventos Atualização Service**: Para monitorar atualizações

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de pertinência
- Monitorar consultas de parcelamentos relacionados
- Alertar sobre mudanças de pertinência
- Rastrear erros de validação
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço PERTSN:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package