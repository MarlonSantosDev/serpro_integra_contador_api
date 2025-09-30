# PGDASD - Pagamento de DAS por Débito Direto Autorizado

## Visão Geral

O serviço PGDASD permite gerenciar pagamentos de DAS (Documento de Arrecadação do Simples Nacional) por débito direto autorizado, incluindo consulta de DAS disponíveis, consulta de DAS específicos, consulta de detalhes de pagamento e emissão de DAS.

## Funcionalidades

- **Consultar DAS Disponíveis**: Consulta de todos os DAS disponíveis para pagamento por débito direto
- **Consultar DAS Específico**: Consulta de informações detalhadas de um DAS específico
- **Consultar Detalhes de Pagamento**: Consulta de detalhes de pagamento de um DAS
- **Emitir DAS**: Emissão de DAS para pagamento por débito direto
- **Validações**: Validações específicas do sistema PGDASD

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PGDASD
- Autorização de débito direto configurada

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
final pgdasdService = PgdasdService(apiClient);
```

### 2. Consultar DAS Disponíveis

```dart
try {
  final response = await pgdasdService.consultarDasDisponiveis();
  
  if (response.sucesso) {
    print('DAS disponíveis: ${response.dadosParsed?.listaDas.length ?? 0}');
    
    for (final das in response.dadosParsed?.listaDas ?? []) {
      print('DAS ${das.numeroDas}: ${das.valorFormatado}');
      print('Vencimento: ${das.dataVencimentoFormatada}');
      print('Situação: ${das.situacao}');
      print('Débito direto: ${das.debitoDiretoAutorizado}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar DAS: $e');
}
```

### 3. Consultar DAS Específico

```dart
try {
  final response = await pgdasdService.consultarDasEspecifico('DAS123456');
  
  if (response.sucesso) {
    print('DAS encontrado!');
    print('Número: ${response.dadosParsed?.numeroDas}');
    print('Valor: ${response.dadosParsed?.valorFormatado}');
    print('Vencimento: ${response.dadosParsed?.dataVencimentoFormatada}');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Débito direto: ${response.dadosParsed?.debitoDiretoAutorizado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar DAS específico: $e');
}
```

### 4. Consultar Detalhes de Pagamento

```dart
try {
  final response = await pgdasdService.consultarDetalhesPagamento('DAS123456');
  
  if (response.sucesso) {
    print('Detalhes de pagamento encontrados!');
    print('Valor pago: ${response.valorPagoFormatado}');
    print('Data de pagamento: ${response.dataPagamentoFormatada}');
    print('Forma de pagamento: ${response.formaPagamento}');
    print('Débito direto: ${response.debitoDiretoUtilizado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar detalhes: $e');
}
```

### 5. Emitir DAS

```dart
try {
  final response = await pgdasdService.emitirDas('DAS123456');
  
  if (response.sucesso && response.pdfGeradoComSucesso) {
    print('DAS emitido com sucesso!');
    print('Tamanho do PDF: ${response.tamanhoPdfFormatado}');
    print('Débito direto: ${response.debitoDiretoAutorizado}');
    
    // Salvar PDF
    final pdfBytes = response.pdfBytes;
    if (pdfBytes != null) {
      // Implementar salvamento do PDF
      print('PDF pronto para salvamento');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao emitir DAS: $e');
}
```

## Estrutura de Dados

### ConsultarDasDisponiveisResponse

```dart
class ConsultarDasDisponiveisResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarDasDisponiveisDados? dadosParsed;
}

class ConsultarDasDisponiveisDados {
  final List<DasItem> listaDas;
  // ... outros campos
}

class DasItem {
  final String numeroDas;
  final String valorFormatado;
  final String dataVencimentoFormatada;
  final String situacao;
  final bool debitoDiretoAutorizado;
  // ... outros campos
}
```

### ConsultarDasEspecificoResponse

```dart
class ConsultarDasEspecificoResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarDasEspecificoDados? dadosParsed;
}

class ConsultarDasEspecificoDados {
  final String numeroDas;
  final String valorFormatado;
  final String dataVencimentoFormatada;
  final String situacao;
  final bool debitoDiretoAutorizado;
  // ... outros campos
}
```

### EmitirDasResponse

```dart
class EmitirDasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final EmitirDasDados? dadosParsed;
  final bool pdfGeradoComSucesso;
  final String tamanhoPdfFormatado;
  final Uint8List? pdfBytes;
  final bool debitoDiretoAutorizado;
}
```

## Validações Disponíveis

O serviço PGDASD inclui várias validações para garantir a integridade dos dados:

```dart
// Validar número do DAS
final erro = pgdasdService.validarNumeroDas('DAS123456');
if (erro != null) {
  print('Erro: $erro');
}

// Validar CNPJ do contribuinte
final erroCnpj = pgdasdService.validarCnpjContribuinte('00000000000000');
if (erroCnpj != null) {
  print('Erro: $erroCnpj');
}

// Validar autorização de débito direto
final erroDebito = pgdasdService.validarDebitoDiretoAutorizado(true);
if (erroDebito != null) {
  print('Erro: $erroDebito');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do PGDASD:

```dart
// Analisar erro
final analise = pgdasdService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (pgdasdService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = pgdasdService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | DAS não encontrado | Verificar se DAS existe |
| 004 | DAS não disponível | Verificar se DAS está disponível para emissão |
| 005 | Débito direto não autorizado | Verificar autorização de débito direto |
| 006 | Prazo expirado | Verificar prazo para emissão do DAS |

## Exemplos Práticos

### Exemplo Completo - Consultar e Emitir DAS

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
  final pgdasdService = PgdasdService(apiClient);
  
  // 3. Consultar DAS disponíveis
  try {
    final dasResponse = await pgdasdService.consultarDasDisponiveis();
    
    if (dasResponse.sucesso) {
      print('DAS encontrados: ${dasResponse.dadosParsed?.listaDas.length ?? 0}');
      
      // 4. Emitir DAS para o primeiro disponível
      final listaDas = dasResponse.dadosParsed?.listaDas ?? [];
      if (listaDas.isNotEmpty) {
        final primeiroDas = listaDas.first;
        
        // Verificar se tem débito direto autorizado
        if (primeiroDas.debitoDiretoAutorizado) {
          final emitirResponse = await pgdasdService.emitirDas(primeiroDas.numeroDas);
          
          if (emitirResponse.sucesso && emitirResponse.pdfGeradoComSucesso) {
            print('DAS emitido com sucesso!');
            print('Tamanho: ${emitirResponse.tamanhoPdfFormatado}');
            print('Débito direto autorizado: ${emitirResponse.debitoDiretoAutorizado}');
          }
        } else {
          print('DAS ${primeiroDas.numeroDas} não tem débito direto autorizado');
        }
      }
    } else {
      print('Erro: ${dasResponse.mensagemErro}');
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

// Números de DAS de teste
const numeroDasTeste = 'DAS123456';

// Situações de teste
const situacaoTeste = 'ATIVO';

// Débito direto autorizado
const debitoDiretoAutorizado = true;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Prazo**: DAS têm prazo específico para emissão
5. **Débito Direto**: Requer autorização prévia de débito direto
6. **Simples Nacional**: Apenas para contribuintes optantes do Simples Nacional

## Casos de Uso Comuns

### 1. Consulta Completa de DAS

```dart
Future<void> consultarDasCompleto(String numeroDas) async {
  try {
    // Consultar DAS específico
    final das = await pgdasdService.consultarDasEspecifico(numeroDas);
    if (!das.sucesso) return;
    
    // Consultar detalhes de pagamento
    final detalhes = await pgdasdService.consultarDetalhesPagamento(numeroDas);
    if (!detalhes.sucesso) return;
    
    print('=== DAS $numeroDas ===');
    print('Valor: ${das.dadosParsed?.valorFormatado}');
    print('Vencimento: ${das.dadosParsed?.dataVencimentoFormatada}');
    print('Situação: ${das.dadosParsed?.situacao}');
    print('Débito direto: ${das.dadosParsed?.debitoDiretoAutorizado}');
    print('Valor pago: ${detalhes.valorPagoFormatado}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Emissão de DAS com Débito Direto

```dart
Future<void> emitirDasComDebitoDireto() async {
  try {
    // Consultar DAS disponíveis
    final das = await pgdasdService.consultarDasDisponiveis();
    if (!das.sucesso) return;
    
    final listaDas = das.dadosParsed?.listaDas ?? [];
    
    // Filtrar apenas DAS com débito direto autorizado
    final dasComDebitoDireto = listaDas.where((d) => d.debitoDiretoAutorizado).toList();
    
    for (final dasItem in dasComDebitoDireto) {
      try {
        final emitir = await pgdasdService.emitirDas(dasItem.numeroDas);
        if (emitir.sucesso && emitir.pdfGeradoComSucesso) {
          print('DAS emitido para ${dasItem.numeroDas} com débito direto');
          // Salvar PDF
        }
      } catch (e) {
        print('Erro ao emitir DAS ${dasItem.numeroDas}: $e');
      }
    }
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

### 3. Monitoramento de DAS

```dart
Future<void> monitorarDas() async {
  try {
    // Consultar DAS disponíveis
    final das = await pgdasdService.consultarDasDisponiveis();
    if (!das.sucesso) return;
    
    final listaDas = das.dadosParsed?.listaDas ?? [];
    
    for (final dasItem in listaDas) {
      final vencimento = DateTime.tryParse(dasItem.dataVencimentoFormatada);
      if (vencimento != null) {
        final diasParaVencimento = vencimento.difference(DateTime.now()).inDays;
        
        if (diasParaVencimento <= 5) {
          print('⚠️ DAS ${dasItem.numeroDas} vence em $diasParaVencimento dias');
          if (dasItem.debitoDiretoAutorizado) {
            print('✅ Débito direto autorizado');
          } else {
            print('❌ Débito direto não autorizado');
          }
        }
      }
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

## Integração com Outros Serviços

O PGDASD Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas aos DAS
- **MIT Service**: Para consultar apurações relacionadas aos DAS
- **Eventos Atualização Service**: Para monitorar atualizações de DAS
- **Caixa Postal Service**: Para consultar mensagens sobre pagamentos

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de DAS
- Monitorar emissões de DAS
- Alertar sobre DAS próximos do vencimento
- Rastrear erros de validação
- Monitorar autorizações de débito direto
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço PGDASD:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package