# SITFIS - Situação Fiscal do Contribuinte

## Visão Geral

O serviço SITFIS permite obter relatórios de situação fiscal de contribuintes Pessoa Jurídica e Pessoa Física no âmbito da Receita Federal do Brasil e Procuradoria-Geral da Fazenda Nacional.

## Funcionalidades

- **Solicitar Protocolo**: Solicitação de protocolo para emissão do relatório
- **Emitir Relatório**: Geração do relatório de situação fiscal em PDF
- **Fluxo Completo**: Execução automática do fluxo completo com retry
- **Cache de Protocolo**: Suporte a cache para evitar solicitações desnecessárias
- **Salvamento de PDF**: Utilitário para salvar PDF em arquivo

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço SITFIS

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
final sitfisService = SitfisService(apiClient);
```

### 2. Solicitar Protocolo

```dart
try {
  final response = await sitfisService.solicitarProtocoloRelatorio('00000000000000');
  
  if (response.isSuccess && response.hasProtocolo) {
    print('Protocolo obtido com sucesso!');
    print('Protocolo: ${response.dados?.protocoloRelatorio}');
    
    if (response.hasTempoEspera) {
      print('Tempo de espera: ${response.dados?.tempoEspera}ms');
    }
  } else {
    print('Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
  }
} catch (e) {
  print('Erro ao solicitar protocolo: $e');
}
```

### 3. Emitir Relatório

```dart
try {
  final response = await sitfisService.emitirRelatorioSituacaoFiscal(
    '00000000000000',
    '123456789', // Protocolo obtido anteriormente
  );
  
  if (response.isSuccess && response.hasPdf) {
    print('Relatório emitido com sucesso!');
    print('Tamanho do PDF: ${response.dados?.pdfSizeInBytes} bytes');
  } else if (response.isProcessing && response.hasTempoEspera) {
    print('Relatório em processamento. Aguarde ${response.dados?.tempoEspera}ms');
  } else {
    print('Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
  }
} catch (e) {
  print('Erro ao emitir relatório: $e');
}
```

### 4. Fluxo Completo com Retry Automático

```dart
try {
  final response = await sitfisService.obterRelatorioCompleto(
    '00000000000000',
    maxTentativas: 5,
    callbackProgresso: (etapa, tempoEspera) {
      print('$etapa');
      if (tempoEspera != null) {
        print('Aguardando ${tempoEspera}ms...');
      }
    },
  );
  
  if (response.isSuccess && response.hasPdf) {
    print('Relatório obtido com sucesso!');
    print('Tamanho: ${response.dados?.pdfSizeInBytes} bytes');
  } else {
    print('Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
  }
} catch (e) {
  print('Erro no fluxo completo: $e');
}
```

### 5. Emitir Relatório com Retry Manual

```dart
try {
  final response = await sitfisService.emitirRelatorioComRetry(
    '00000000000000',
    '123456789', // Protocolo
    maxTentativas: 3,
    callbackProgresso: (tentativa, tempoEspera) {
      print('Tentativa $tentativa - Aguardando ${tempoEspera}ms...');
    },
  );
  
  if (response.isSuccess && response.hasPdf) {
    print('Relatório obtido com sucesso!');
  }
} catch (e) {
  print('Erro com retry: $e');
}
```

### 6. Usar Cache de Protocolo

```dart
try {
  // Criar cache (opcional)
  final cache = SitfisCache(
    protocolo: '123456789',
    dataHora: DateTime.now(),
    tempoValidade: Duration(minutes: 30),
  );
  
  // Solicitar protocolo com cache
  final protocoloResponse = await sitfisService.solicitarProtocoloComCache(
    '00000000000000',
    cache: cache,
  );
  
  if (protocoloResponse == null) {
    print('Usando protocolo do cache');
  } else {
    print('Novo protocolo obtido: ${protocoloResponse.dados?.protocoloRelatorio}');
  }
} catch (e) {
  print('Erro com cache: $e');
}
```

### 7. Salvar PDF em Arquivo

```dart
try {
  final response = await sitfisService.obterRelatorioCompleto('00000000000000');
  
  if (response.isSuccess && response.hasPdf) {
    final sucesso = await sitfisService.salvarPdfEmArquivo(
      response,
      '/caminho/para/relatorio.pdf',
    );
    
    if (sucesso) {
      print('PDF salvo com sucesso!');
    } else {
      print('Erro ao salvar PDF');
    }
  }
} catch (e) {
  print('Erro ao salvar PDF: $e');
}
```

### 8. Obter Informações do PDF

```dart
try {
  final response = await sitfisService.obterRelatorioCompleto('00000000000000');
  
  if (response.isSuccess && response.hasPdf) {
    final info = sitfisService.obterInformacoesPdf(response);
    
    print('PDF disponível: ${info['disponivel']}');
    print('Tamanho em bytes: ${info['tamanhoBytes']}');
    print('Tamanho em KB: ${info['tamanhoKB']}');
    print('Tamanho em MB: ${info['tamanhoMB']}');
    print('Tamanho Base64: ${info['tamanhoBase64']}');
  }
} catch (e) {
  print('Erro ao obter informações: $e');
}
```

## Estrutura de Dados

### SolicitarProtocoloResponse

```dart
class SolicitarProtocoloResponse {
  final bool sucesso;
  final List<Mensagem> mensagens;
  final SolicitarProtocoloDados? dados;
  
  bool get isSuccess => sucesso;
  bool get hasProtocolo => dados?.protocoloRelatorio != null;
  bool get hasTempoEspera => dados?.tempoEspera != null;
}

class SolicitarProtocoloDados {
  final String? protocoloRelatorio;
  final int? tempoEspera;
}
```

### EmitirRelatorioResponse

```dart
class EmitirRelatorioResponse {
  final bool sucesso;
  final List<Mensagem> mensagens;
  final EmitirRelatorioDados? dados;
  
  bool get isSuccess => sucesso;
  bool get hasPdf => dados?.pdf != null;
  bool get isProcessing => dados?.emProcessamento == true;
  bool get hasTempoEspera => dados?.tempoEspera != null;
}

class EmitirRelatorioDados {
  final String? pdf;
  final int? pdfSizeInBytes;
  final bool? emProcessamento;
  final int? tempoEspera;
}
```

### SitfisCache

```dart
class SitfisCache {
  final String protocolo;
  final DateTime dataHora;
  final Duration tempoValidade;
  
  bool get isValid {
    final agora = DateTime.now();
    final expiracao = dataHora.add(tempoValidade);
    return agora.isBefore(expiracao);
  }
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ/CPF inválido | Verificar formato do documento |
| 003 | Protocolo inválido | Verificar se protocolo existe |
| 004 | Relatório em processamento | Aguardar tempo especificado |
| 005 | Relatório não disponível | Verificar se relatório foi gerado |

## Exemplos Práticos

### Exemplo Completo - Obter Relatório SITFIS

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
  final sitfisService = SitfisService(apiClient);
  
  // 3. Obter relatório completo
  try {
    final response = await sitfisService.obterRelatorioCompleto(
      '00000000000000',
      maxTentativas: 5,
      callbackProgresso: (etapa, tempoEspera) {
        print('$etapa');
        if (tempoEspera != null) {
          print('Aguardando ${tempoEspera}ms...');
        }
      },
    );
    
    if (response.isSuccess && response.hasPdf) {
      print('Relatório obtido com sucesso!');
      
      // 4. Obter informações do PDF
      final info = sitfisService.obterInformacoesPdf(response);
      print('Tamanho: ${info['tamanhoMB']} MB');
      
      // 5. Salvar PDF
      final sucesso = await sitfisService.salvarPdfEmArquivo(
        response,
        'relatorio_sitfis.pdf',
      );
      
      if (sucesso) {
        print('PDF salvo com sucesso!');
      } else {
        print('Erro ao salvar PDF');
      }
    } else {
      print('Erro: ${response.mensagens.map((m) => m.texto).join(', ')}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Fluxo Manual com Controle de Tempo

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
  final sitfisService = SitfisService(apiClient);
  
  // 3. Solicitar protocolo
  try {
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio('00000000000000');
    
    if (protocoloResponse.isSuccess && protocoloResponse.hasProtocolo) {
      print('Protocolo obtido: ${protocoloResponse.dados?.protocoloRelatorio}');
      
      // 4. Aguardar se necessário
      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Aguardando ${tempoEspera}ms...');
        await Future.delayed(Duration(milliseconds: tempoEspera));
      }
      
      // 5. Emitir relatório
      final relatorioResponse = await sitfisService.emitirRelatorioSituacaoFiscal(
        '00000000000000',
        protocoloResponse.dados!.protocoloRelatorio!,
      );
      
      if (relatorioResponse.isSuccess && relatorioResponse.hasPdf) {
        print('Relatório emitido com sucesso!');
        print('Tamanho: ${relatorioResponse.dados?.pdfSizeInBytes} bytes');
      } else if (relatorioResponse.isProcessing) {
        print('Relatório ainda em processamento');
      } else {
        print('Erro: ${relatorioResponse.mensagens.map((m) => m.texto).join(', ')}');
      }
    } else {
      print('Erro ao obter protocolo: ${protocoloResponse.mensagens.map((m) => m.texto).join(', ')}');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Protocolo de teste
const protocoloTeste = '123456789';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Tempo de Processamento**: Relatórios podem demorar para serem gerados
4. **Tamanho do PDF**: PDFs podem ser grandes, considere o espaço em disco

## Suporte

Para dúvidas sobre o serviço SITFIS:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
