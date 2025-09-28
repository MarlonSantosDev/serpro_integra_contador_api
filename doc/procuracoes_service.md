# Procurações - Gestão de Procurações Eletrônicas

## Visão Geral

O serviço Procurações permite consultar procurações eletrônicas entre outorgantes e procuradores, incluindo validação de documentos e formatação de CPF/CNPJ.

## Funcionalidades

- **Obter Procuração**: Consulta de procurações eletrônicas entre outorgante e procurador
- **Validação de Documentos**: Validação de CPF e CNPJ
- **Formatação de Documentos**: Formatação automática de CPF e CNPJ
- **Detecção de Tipo**: Detecção automática do tipo de documento (CPF ou CNPJ)

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço Procurações

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

### 2. Obter Procuração Básica

```dart
try {
  final response = await procuracoesService.obterProcuracao(
    '00000000000000', // Outorgante (CNPJ)
    '00000000000000', // Procurador (CNPJ)
  );
  
  if (response.sucesso) {
    print('Procuração encontrada!');
    print('Outorgante: ${response.dadosParsed?.outorgante}');
    print('Procurador: ${response.dadosParsed?.procurador}');
    print('Data de início: ${response.dadosParsed?.dataInicio}');
    print('Data de fim: ${response.dadosParsed?.dataFim}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao obter procuração: $e');
}
```

### 3. Obter Procuração com Tipos Específicos

```dart
try {
  final response = await procuracoesService.obterProcuracaoComTipos(
    '00000000000000', // Outorgante
    '2', // Tipo outorgante (2 = CNPJ)
    '00000000000', // Procurador
    '1', // Tipo procurador (1 = CPF)
  );
  
  if (response.sucesso) {
    print('Procuração encontrada!');
  }
} catch (e) {
  print('Erro ao obter procuração: $e');
}
```

### 4. Obter Procuração Pessoa Física

```dart
try {
  final response = await procuracoesService.obterProcuracaoPf(
    '00000000000', // CPF Outorgante
    '00000000000', // CPF Procurador
  );
  
  if (response.sucesso) {
    print('Procuração PF encontrada!');
  }
} catch (e) {
  print('Erro ao obter procuração PF: $e');
}
```

### 5. Obter Procuração Pessoa Jurídica

```dart
try {
  final response = await procuracoesService.obterProcuracaoPj(
    '00000000000000', // CNPJ Outorgante
    '00000000000000', // CNPJ Procurador
  );
  
  if (response.sucesso) {
    print('Procuração PJ encontrada!');
  }
} catch (e) {
  print('Erro ao obter procuração PJ: $e');
}
```

### 6. Obter Procuração Mista

```dart
try {
  final response = await procuracoesService.obterProcuracaoMista(
    '00000000000000', // Documento Outorgante
    '00000000000', // Documento Procurador
    true, // Outorgante é PJ
    false, // Procurador é PF
  );
  
  if (response.sucesso) {
    print('Procuração mista encontrada!');
  }
} catch (e) {
  print('Erro ao obter procuração mista: $e');
}
```

## Validações e Utilitários

### Validar CPF

```dart
final isValid = procuracoesService.isCpfValido('00000000000');
if (isValid) {
  print('CPF válido');
} else {
  print('CPF inválido');
}
```

### Validar CNPJ

```dart
final isValid = procuracoesService.isCnpjValido('00000000000000');
if (isValid) {
  print('CNPJ válido');
} else {
  print('CNPJ inválido');
}
```

### Detectar Tipo de Documento

```dart
final tipo = procuracoesService.detectarTipoDocumento('00000000000');
print('Tipo: $tipo'); // 1 = CPF, 2 = CNPJ
```

### Limpar Documento

```dart
final limpo = procuracoesService.limparDocumento('000.000.000-00');
print('Documento limpo: $limpo'); // 00000000000
```

### Formatar CPF

```dart
final formatado = procuracoesService.formatarCpf('00000000000');
print('CPF formatado: $formatado'); // 000.000.000-00
```

### Formatar CNPJ

```dart
final formatado = procuracoesService.formatarCnpj('00000000000000');
print('CNPJ formatado: $formatado'); // 00.000.000/0000-00
```

## Estrutura de Dados

### ObterProcuracaoResponse

```dart
class ObterProcuracaoResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ObterProcuracaoDados? dadosParsed;
}

class ObterProcuracaoDados {
  final String outorgante;
  final String procurador;
  final String? dataInicio;
  final String? dataFim;
  final String situacao;
  final List<String> poderes;
  // ... outros campos
}
```

### ObterProcuracaoRequest

```dart
class ObterProcuracaoRequest {
  final String outorgante;
  final String tipoOutorgante;
  final String outorgado;
  final String tipoOutorgado;
  
  // Construtor de conveniência
  factory ObterProcuracaoRequest.fromDocuments({
    required String outorgante,
    required String outorgado,
  }) {
    return ObterProcuracaoRequest(
      outorgante: outorgante,
      tipoOutorgante: detectarTipoDocumento(outorgante),
      outorgado: outorgado,
      tipoOutorgado: detectarTipoDocumento(outorgado),
    );
  }
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CPF inválido | Verificar formato do CPF |
| 003 | CNPJ inválido | Verificar formato do CNPJ |
| 004 | Procuração não encontrada | Verificar se procuração existe |
| 005 | Documentos incompatíveis | Verificar compatibilidade dos documentos |

## Exemplos Práticos

### Exemplo Completo - Consultar Procuração

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
  
  // 3. Validar documentos antes de consultar
  final outorgante = '00000000000000';
  final procurador = '00000000000000';
  
  if (procuracoesService.isCnpjValido(outorgante) && 
      procuracoesService.isCnpjValido(procurador)) {
    
    // 4. Obter procuração
    try {
      final response = await procuracoesService.obterProcuracaoPj(
        outorgante,
        procurador,
      );
      
      if (response.sucesso) {
        print('Procuração encontrada!');
        print('Outorgante: ${procuracoesService.formatarCnpj(response.dadosParsed?.outorgante ?? '')}');
        print('Procurador: ${procuracoesService.formatarCnpj(response.dadosParsed?.procurador ?? '')}');
        print('Situação: ${response.dadosParsed?.situacao}');
        print('Data de início: ${response.dadosParsed?.dataInicio}');
        print('Data de fim: ${response.dadosParsed?.dataFim}');
        
        if (response.dadosParsed?.poderes != null) {
          print('Poderes:');
          for (final poder in response.dadosParsed!.poderes) {
            print('- $poder');
          }
        }
      } else {
        print('Erro: ${response.mensagemErro}');
      }
    } catch (e) {
      print('Erro ao obter procuração: $e');
    }
  } else {
    print('Documentos inválidos');
  }
}
```

### Exemplo - Consultar Procuração Mista

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
  
  // 3. Consultar procuração mista (PJ para PF)
  try {
    final response = await procuracoesService.obterProcuracaoMista(
      '00000000000000', // CNPJ Outorgante
      '00000000000', // CPF Procurador
      true, // Outorgante é PJ
      false, // Procurador é PF
    );
    
    if (response.sucesso) {
      print('Procuração mista encontrada!');
      print('Outorgante (PJ): ${procuracoesService.formatarCnpj(response.dadosParsed?.outorgante ?? '')}');
      print('Procurador (PF): ${procuracoesService.formatarCpf(response.dadosParsed?.procurador ?? '')}');
      print('Situação: ${response.dadosParsed?.situacao}');
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro ao obter procuração mista: $e');
  }
}
```

### Exemplo - Validar e Formatar Documentos

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() {
  final procuracoesService = ProcuracoesService(apiClient);
  
  // Documentos de teste
  final cpf = '00000000000';
  final cnpj = '00000000000000';
  
  // Validar CPF
  if (procuracoesService.isCpfValido(cpf)) {
    print('CPF válido: ${procuracoesService.formatarCpf(cpf)}');
  } else {
    print('CPF inválido');
  }
  
  // Validar CNPJ
  if (procuracoesService.isCnpjValido(cnpj)) {
    print('CNPJ válido: ${procuracoesService.formatarCnpj(cnpj)}');
  } else {
    print('CNPJ inválido');
  }
  
  // Detectar tipos
  print('Tipo CPF: ${procuracoesService.detectarTipoDocumento(cpf)}');
  print('Tipo CNPJ: ${procuracoesService.detectarTipoDocumento(cnpj)}');
  
  // Limpar documentos
  print('CPF limpo: ${procuracoesService.limparDocumento(cpf)}');
  print('CNPJ limpo: ${procuracoesService.limparDocumento(cnpj)}');
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// CPFs de teste (sempre usar zeros)
const cpfTeste = '00000000000';

// Tipos de documento
const tipoCpf = '1';
const tipoCnpj = '2';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Procuração Ativa**: Apenas procurações ativas são retornadas

## Suporte

Para dúvidas sobre o serviço Procurações:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
