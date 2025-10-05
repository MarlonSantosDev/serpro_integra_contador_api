# SITFIS - Sistema de Informações Tributárias Fiscais

## Visão Geral

O serviço SITFIS permite emitir relatórios de situação fiscal de contribuintes (Pessoa Física e Jurídica) na Receita Federal e Procuradoria-Geral da Fazenda Nacional.

## Funcionalidades

- **Solicitar Protocolo**: Solicita protocolo para geração do relatório
- **Emitir Relatório**: Emite relatório de situação fiscal em PDF
- **Fluxo Assíncrono**: Processo em duas etapas com tempo de espera

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
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret', 
  certPath: 'caminho/para/certificado.p12',
  certPassword: 'senha_do_certificado',
  ambiente: 'trial', // ou 'producao'
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final sitfisService = SitfisService(apiClient);
```

### 2. Fluxo Completo - Solicitar Protocolo e Emitir Relatório

```dart
try {
  const contribuinteNumero = '99999999999'; // CPF ou CNPJ
  
  // 1. Solicitar protocolo
  print('=== Solicitando Protocolo ===');
  final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(
    contribuinteNumero,
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );

  print('Status: ${protocoloResponse.status}');
  print('Mensagens: ${protocoloResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');

  if (protocoloResponse.isSuccess) {
    print('✅ Sucesso ao solicitar protocolo');

    if (protocoloResponse.hasProtocolo) {
      final protocolo = protocoloResponse.dados!.protocoloRelatorio!;
      print('Protocolo obtido: ${protocolo.substring(0, 20)}...');

      // 2. Aguardar tempo de espera se necessário
      if (protocoloResponse.hasTempoEspera) {
        final tempoEspera = protocoloResponse.dados!.tempoEspera!;
        print('Tempo de espera: ${tempoEspera}ms (${protocoloResponse.dados!.tempoEsperaEmSegundos}s)');
        
        print('Aguardando ${tempoEspera}ms antes de emitir...');
        await Future.delayed(Duration(milliseconds: tempoEspera));
      }

      // 3. Emitir relatório
      print('\n=== Emitindo Relatório ===');
      final emitirResponse = await sitfisService.emitirRelatorioSituacaoFiscal(
        contribuinteNumero,
        protocolo,
        contratanteNumero: '00000000000000', // Opcional
        autorPedidoDadosNumero: '00000000000000', // Opcional
      );

      print('Status: ${emitirResponse.status}');
      print('Mensagens: ${emitirResponse.mensagens.map((m) => '${m.codigo}: ${m.texto}').join(', ')}');
      print('Sucesso: ${emitirResponse.isSuccess}');
      print('Em processamento: ${emitirResponse.isProcessing}');
      print('PDF disponível: ${emitirResponse.hasPdf}');

      if (emitirResponse.hasPdf) {
        print('✅ Relatório emitido com sucesso!');
        
        // Salvar PDF
        final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
          emitirResponse.dados!.pdf!,
          'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
        
      } else if (emitirResponse.isProcessing) {
        print('⏳ Relatório em processamento...');
        if (emitirResponse.hasTempoEspera) {
          final tempoEspera = emitirResponse.dados!.tempoEspera!;
          print('Tempo de espera: ${tempoEspera}ms (${emitirResponse.dados!.tempoEsperaEmSegundos}s)');
        }
      } else {
        print('❌ Erro ao emitir relatório');
      }
    } else {
      print('❌ Protocolo não disponível para emissão');
    }
  } else {
    print('❌ Erro ao solicitar protocolo');
  }
} catch (e) {
  print('Erro na operação: $e');
}
```

### 3. Método Simplificado - Fluxo Automático

```dart
try {
  const contribuinteNumero = '99999999999';
  
  // Método que executa o fluxo completo automaticamente
  final response = await sitfisService.solicitarProtocoloEEmitirRelatorio(
    contribuinteNumero,
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );

  if (response.sucesso) {
    print('✅ Relatório emitido com sucesso!');
    print('PDF disponível: ${response.hasPdf}');
    
    if (response.hasPdf) {
      // Salvar PDF
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados!.pdf!,
        'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('❌ Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro: $e');
}
```

### 4. Consultar Status de Processamento

```dart
try {
  const contribuinteNumero = '99999999999';
  const protocolo = 'PROTOCOLO_OBTIDO_ANTERIORMENTE';
  
  // Verificar status do processamento
  final statusResponse = await sitfisService.verificarStatusProcessamento(
    contribuinteNumero,
    protocolo,
  );

  if (statusResponse.isSuccess) {
    if (statusResponse.hasPdf) {
      print('✅ Relatório pronto!');
      // Baixar PDF
    } else if (statusResponse.isProcessing) {
      print('⏳ Ainda processando...');
      // Aguardar mais tempo
    } else {
      print('❌ Erro no processamento');
    }
  } else {
    print('❌ Erro ao verificar status');
  }
} catch (e) {
  print('Erro: $e');
}
```

## Validações Disponíveis

O serviço utiliza validações centralizadas do `ValidacoesUtils`:

```dart
// Validar CPF/CNPJ antes de usar
final errorDocumento = ValidacoesUtils.validarCpf(contribuinteNumero) ?? 
                      ValidacoesUtils.validarCnpjContribuinte(contribuinteNumero);
if (errorDocumento != null) {
  print('Documento inválido: $errorDocumento');
  return;
}
```

## Formatação de Dados

Utilize os utilitários de formatação do `FormatadorUtils`:

```dart
// Formatar CPF/CNPJ para exibição
String documentoFormatado;
if (contribuinteNumero.length == 11) {
  documentoFormatado = FormatadorUtils.formatCpf(contribuinteNumero);
} else {
  documentoFormatado = FormatadorUtils.formatCnpj(contribuinteNumero);
}
print('Contribuinte: $documentoFormatado');

// Formatar tempo de espera
final tempoFormatado = FormatadorUtils.formatDuration(Duration(milliseconds: tempoEspera));
print('Tempo de espera: $tempoFormatado');
```

## Estrutura de Dados

### SolicitarProtocoloResponse

```dart
class SolicitarProtocoloResponse {
  final bool isSuccess;
  final String? mensagemPrincipal;
  final List<SitfisMensagem> mensagens;
  final SolicitarProtocoloDados? dados;
}

class SolicitarProtocoloDados {
  final String? protocoloRelatorio;
  final int? tempoEspera;
  
  // Propriedades de conveniência
  bool get hasProtocolo => protocoloRelatorio != null && protocoloRelatorio!.isNotEmpty;
  bool get hasTempoEspera => tempoEspera != null && tempoEspera! > 0;
  int get tempoEsperaEmSegundos => (tempoEspera ?? 0) ~/ 1000;
}
```

### EmitirRelatorioResponse

```dart
class EmitirRelatorioResponse {
  final bool isSuccess;
  final bool isProcessing;
  final String? mensagemPrincipal;
  final List<SitfisMensagem> mensagens;
  final EmitirRelatorioDados? dados;
  
  // Propriedades de conveniência
  bool get hasPdf => dados?.pdf != null && dados!.pdf!.isNotEmpty;
  bool get hasTempoEspera => dados?.tempoEspera != null && dados!.tempoEspera! > 0;
}
```

### SitfisMensagem

```dart
class SitfisMensagem {
  final String codigo;
  final String texto;
  
  // Propriedades de conveniência
  bool get isSuccess => codigo.contains('Sucesso-Sitfis');
  bool get isWarning => codigo.contains('Aviso-Sitfis');
  bool get isError => codigo.contains('Erro-Sitfis');
  bool get isInputError => codigo.contains('EntradaIncorreta-Sitfis');
}
```

## Códigos de Mensagem Específicos

### Sucessos
- `[Sucesso-Sitfis-SC01]`: Protocolo solicitado com sucesso
- `[Sucesso-Sitfis-SC02]`: Relatório emitido com sucesso

### Avisos
- `[Aviso-Sitfis-AV01]`: Obtenha o relatório no serviço /emitir
- `[Aviso-Sitfis-AV02]`: Limite de solicitações atingido
- `[Aviso-Sitfis-AV03]`: Não foi possível concluir a ação

### Erros de Entrada
- `[EntradaIncorreta-Sitfis-EI01]`: Requisição inválida
- `[EntradaIncorreta-Sitfis-EI02]`: Versão inexistente
- `[EntradaIncorreta-Sitfis-EI03]`: Versão descontinuada

### Erros Gerais
- `[Erro-Sitfis-ER01]`: URL não encontrada
- `[Erro-Sitfis-ER02]`: Erro ao solicitar protocolo
- `[Erro-Sitfis-ER03]`: Erro ao obter relatório
- `[Erro-Sitfis-ER04]`: Erro ao processar requisição
- `[Erro-Sitfis-ER05]`: Erro ao processar requisição

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CPF/CNPJ inválido | Verificar formato do documento |
| 003 | Protocolo inválido | Verificar se protocolo é válido |
| 004 | Contribuinte não encontrado | Verificar se contribuinte está cadastrado |
| 005 | Sistema indisponível | Tentar novamente mais tarde |

## Exemplos Práticos

### Exemplo Completo - Fluxo Completo SITFIS

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret', 
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    ambiente: 'trial',
  );
  
  // 2. Criar serviço
  final sitfisService = SitfisService(apiClient);
  
  try {
    const contribuinteNumero = '99999999999';
    
    // Validar documento antes de usar
    final errorDocumento = ValidacoesUtils.validarCpf(contribuinteNumero) ?? 
                          ValidacoesUtils.validarCnpjContribuinte(contribuinteNumero);
    if (errorDocumento != null) {
      print('Documento inválido: $errorDocumento');
      return;
    }
    
    // 3. Solicitar protocolo
    print('=== Solicitando Protocolo ===');
    final protocoloResponse = await sitfisService.solicitarProtocoloRelatorio(contribuinteNumero);
    
    if (protocoloResponse.isSuccess) {
      print('✅ Protocolo solicitado com sucesso!');
      
      if (protocoloResponse.hasProtocolo) {
        final protocolo = protocoloResponse.dados!.protocoloRelatorio!;
        print('Protocolo: ${protocolo.substring(0, 20)}...');
        
        // 4. Aguardar tempo de espera
        if (protocoloResponse.hasTempoEspera) {
          final tempoEspera = protocoloResponse.dados!.tempoEspera!;
          print('Tempo de espera: ${FormatadorUtils.formatDuration(Duration(milliseconds: tempoEspera))}');
          
          print('Aguardando processamento...');
          await Future.delayed(Duration(milliseconds: tempoEspera));
        }
        
        // 5. Emitir relatório
        print('\n=== Emitindo Relatório ===');
        final emitirResponse = await sitfisService.emitirRelatorioSituacaoFiscal(
          contribuinteNumero,
          protocolo,
        );
        
        if (emitirResponse.isSuccess) {
          if (emitirResponse.hasPdf) {
            print('✅ Relatório emitido com sucesso!');
            
            // Salvar PDF
            final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
              emitirResponse.dados!.pdf!,
              'relatorio_sitfis_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
            print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
            
          } else if (emitirResponse.isProcessing) {
            print('⏳ Relatório ainda em processamento...');
            if (emitirResponse.hasTempoEspera) {
              final tempoEspera = emitirResponse.dados!.tempoEspera!;
              print('Tempo adicional: ${FormatadorUtils.formatDuration(Duration(milliseconds: tempoEspera))}');
            }
          } else {
            print('❌ Erro ao emitir relatório');
          }
        } else {
          print('❌ Erro: ${emitirResponse.mensagemPrincipal}');
          
          // Analisar mensagens específicas
          for (final mensagem in emitirResponse.mensagens) {
            if (mensagem.isError) {
              print('Erro: ${mensagem.codigo} - ${mensagem.texto}');
            } else if (mensagem.isWarning) {
              print('Aviso: ${mensagem.codigo} - ${mensagem.texto}');
            }
          }
        }
      } else {
        print('❌ Protocolo não disponível');
      }
    } else {
      print('❌ Erro ao solicitar protocolo: ${protocoloResponse.mensagemPrincipal}');
      
      // Analisar mensagens de erro
      for (final mensagem in protocoloResponse.mensagens) {
        if (mensagem.isError) {
          print('Erro: ${mensagem.codigo} - ${mensagem.texto}');
        } else if (mensagem.isInputError) {
          print('Entrada incorreta: ${mensagem.codigo} - ${mensagem.texto}');
        }
      }
    }
    
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Validação e Formatação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final sitfisService = SitfisService(apiClient);
  
  // Validar documento antes de usar
  const contribuinteNumero = '12345678901';
  final errorCpf = ValidacoesUtils.validarCpf(contribuinteNumero);
  
  if (errorCpf != null) {
    print('CPF inválido: $errorCpf');
    return;
  }
  
  // CPF válido, prosseguir
  final response = await sitfisService.solicitarProtocoloRelatorio(contribuinteNumero);
  
  if (response.isSuccess) {
    print('=== Protocolo Solicitado ===');
    print('CPF: ${FormatadorUtils.formatCpf(contribuinteNumero)}');
    print('Status: ${response.status}');
    print('Sucesso: ${response.isSuccess}');
    
    if (response.hasProtocolo) {
      final protocolo = response.dados!.protocoloRelatorio!;
      print('Protocolo: ${protocolo.substring(0, 20)}...');
    }
    
    if (response.hasTempoEspera) {
      final tempoEspera = response.dados!.tempoEspera!;
      print('Tempo de espera: ${FormatadorUtils.formatDuration(Duration(milliseconds: tempoEspera))}');
    }
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CPFs/CNPJs de teste (sempre usar zeros)
const cpfTeste = '99999999999';
const cnpjTeste = '00000000000000';

// Protocolos de teste
const protocoloTeste = 'PROTOCOLO_TESTE_123';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Processamento Assíncrono**: Requer aguardar tempo de processamento
5. **Limite de Solicitações**: Sistema pode ter limite de solicitações simultâneas

## Suporte

Para dúvidas sobre o serviço SITFIS:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package