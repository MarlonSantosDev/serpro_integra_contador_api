# PARCSN - Parcelamento do Simples Nacional

## Visão Geral

O serviço PARCSN permite gerenciar parcelamentos de débitos do Simples Nacional, incluindo consulta de pedidos de parcelamento ordinário, consulta de parcelamentos específicos, consulta de parcelas disponíveis para impressão, consulta de detalhes de pagamento e emissão de DAS para parcelas.

## Funcionalidades

- **Consultar Pedidos de Parcelamento**: Consulta de todos os pedidos de parcelamento ordinário do tipo PARCSN
- **Consultar Parcelamento Específico**: Consulta de informações detalhadas de um parcelamento específico
- **Consultar Parcelas Disponíveis**: Consulta de parcelas disponíveis para impressão de DAS
- **Consultar Detalhes de Pagamento**: Consulta de detalhes de pagamento de uma parcela específica
- **Emitir DAS para Parcela**: Emissão de DAS para uma parcela específica

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PARCSN

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
final parcsnService = ParcsnService(apiClient);
```

### 2. Consultar Pedidos de Parcelamento

```dart
try {
  final response = await parcsnService.consultarPedidos();
  
  if (response.sucesso) {
    print('Pedidos de parcelamento encontrados: ${response.dadosParsed?.parcelamentos.length ?? 0}');
    
    for (final parcelamento in response.dadosParsed?.parcelamentos ?? []) {
      print('Parcelamento ${parcelamento.numero}: ${parcelamento.situacao}');
      print('Valor total: ${parcelamento.valorTotal}');
      print('Data do pedido: ${parcelamento.dataDoPedidoFormatada}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar pedidos: $e');
}
```

### 3. Consultar Parcelamento Específico

```dart
try {
  final response = await parcsnService.consultarParcelamento(1);
  
  if (response.sucesso) {
    print('Parcelamento encontrado!');
    print('Situação: ${response.dadosParsed?.situacao}');
    print('Data do pedido: ${response.dadosParsed?.dataDoPedidoFormatada}');
    print('Valor total consolidado: ${response.valorTotalConsolidadoFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar parcelamento: $e');
}
```

### 4. Consultar Parcelas Disponíveis

```dart
try {
  final response = await parcsnService.consultarParcelas();
  
  if (response.sucesso) {
    print('Parcelas disponíveis: ${response.dadosParsed?.listaParcelas.length ?? 0}');
    
    for (final parcela in response.dadosParsed?.listaParcelas ?? []) {
      print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
    }
    
    print('Valor total das parcelas: ${response.valorTotalParcelasFormatado}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar parcelas: $e');
}
```

### 5. Consultar Detalhes de Pagamento

```dart
try {
  final response = await parcsnService.consultarDetalhesPagamento(1, 201612);
  
  if (response.sucesso) {
    print('Detalhes de pagamento encontrados!');
    print('DAS: ${response.dadosParsed?.numeroDas}');
    print('Valor pago: ${response.valorPagoArrecadacaoFormatado}');
    print('Data de pagamento: ${response.dataPagamentoFormatada}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar detalhes: $e');
}
```

### 6. Emitir DAS para Parcela

```dart
try {
  final response = await parcsnService.emitirDas(202306);
  
  if (response.sucesso && response.pdfGeradoComSucesso) {
    print('DAS emitido com sucesso!');
    print('Tamanho do PDF: ${response.tamanhoPdfFormatado}');
    
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

### ConsultarPedidosResponse

```dart
class ConsultarPedidosResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarPedidosDados? dadosParsed;
}

class ConsultarPedidosDados {
  final List<Parcelamento> parcelamentos;
  // ... outros campos
}

class Parcelamento {
  final int numero;
  final String situacao;
  final double valorTotal;
  final String dataDoPedidoFormatada;
  // ... outros campos
}
```

### ConsultarParcelasResponse

```dart
class ConsultarParcelasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarParcelasDados? dadosParsed;
  final String valorTotalParcelasFormatado;
}

class ConsultarParcelasDados {
  final List<Parcela> listaParcelas;
  // ... outros campos
}

class Parcela {
  final String parcelaFormatada;
  final String valorFormatado;
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
}
```

## Validações Disponíveis

O serviço PARCSN inclui várias validações para garantir a integridade dos dados:

```dart
// Validar número de parcelamento
final erro = parcsnService.validarNumeroParcelamento(1);
if (erro != null) {
  print('Erro: $erro');
}

// Validar ano/mês de parcela
final erroAnoMes = parcsnService.validarAnoMesParcela(201612);
if (erroAnoMes != null) {
  print('Erro: $erroAnoMes');
}

// Validar parcela para emissão
final erroParcela = parcsnService.validarParcelaParaEmitir(202306);
if (erroParcela != null) {
  print('Erro: $erroParcela');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do PARCSN:

```dart
// Analisar erro
final analise = parcsnService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (parcsnService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = parcsnService.getErrorInfo('001');
if (info != null) {
  print('Informações: ${info.descricao}');
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Parcelamento não encontrado | Verificar se parcelamento existe |
| 004 | Parcela não disponível | Verificar se parcela está disponível para emissão |
| 005 | Prazo expirado | Verificar prazo para emissão da parcela |

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
  final parcsnService = ParcsnService(apiClient);
  
  // 3. Consultar pedidos de parcelamento
  try {
    final pedidosResponse = await parcsnService.consultarPedidos();
    
    if (pedidosResponse.sucesso) {
      print('Pedidos encontrados: ${pedidosResponse.dadosParsed?.parcelamentos.length ?? 0}');
      
      // 4. Consultar parcelas disponíveis
      final parcelasResponse = await parcsnService.consultarParcelas();
      
      if (parcelasResponse.sucesso) {
        print('Parcelas disponíveis: ${parcelasResponse.dadosParsed?.listaParcelas.length ?? 0}');
        
        // 5. Emitir DAS para primeira parcela disponível
        final parcelas = parcelasResponse.dadosParsed?.listaParcelas ?? [];
        if (parcelas.isNotEmpty) {
          final primeiraParcela = parcelas.first;
          final parcelaParaEmitir = int.tryParse(primeiraParcela.parcelaFormatada.replaceAll('/', ''));
          
          if (parcelaParaEmitir != null) {
            final dasResponse = await parcsnService.emitirDas(parcelaParaEmitir);
            
            if (dasResponse.sucesso && dasResponse.pdfGeradoComSucesso) {
              print('DAS emitido com sucesso!');
              print('Tamanho: ${dasResponse.tamanhoPdfFormatado}');
            }
          }
        }
      }
    } else {
      print('Erro: ${pedidosResponse.mensagemErro}');
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

// Números de parcelamento de teste
const numeroParcelamento = 1;

// Períodos de teste (formato AAAAMM)
const anoMesParcela = 201612;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Prazo**: Parcelas têm prazo específico para emissão
5. **Simples Nacional**: Apenas para contribuintes optantes do Simples Nacional

## Casos de Uso Comuns

### 1. Consulta Completa de Parcelamento

```dart
Future<void> consultarParcelamentoCompleto(int numeroParcelamento) async {
  try {
    // Consultar parcelamento
    final parcelamento = await parcsnService.consultarParcelamento(numeroParcelamento);
    if (!parcelamento.sucesso) return;
    
    // Consultar parcelas
    final parcelas = await parcsnService.consultarParcelas();
    if (!parcelas.sucesso) return;
    
    print('=== Parcelamento $numeroParcelamento ===');
    print('Situação: ${parcelamento.dadosParsed?.situacao}');
    print('Valor total: ${parcelamento.dadosParsed?.valorTotalConsolidadoFormatado}');
    print('Parcelas disponíveis: ${parcelas.dadosParsed?.listaParcelas.length}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### 2. Emissão de DAS em Lote

```dart
Future<void> emitirDasLote() async {
  try {
    // Consultar parcelas disponíveis
    final parcelas = await parcsnService.consultarParcelas();
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
    
    for (final parcela in listaParcelas) {
      try {
        final das = await parcsnService.emitirDas(parcela.parcelaParaEmitir);
        if (das.sucesso && das.pdfGeradoComSucesso) {
          print('DAS emitido para parcela ${parcela.parcelaFormatada}');
          // Salvar PDF
        }
      } catch (e) {
        print('Erro ao emitir DAS para parcela ${parcela.parcelaFormatada}: $e');
      }
    }
  } catch (e) {
    print('Erro geral: $e');
  }
}
```

### 3. Monitoramento de Parcelas

```dart
Future<void> monitorarParcelas() async {
  try {
    // Consultar parcelas disponíveis
    final parcelas = await parcsnService.consultarParcelas();
    if (!parcelas.sucesso) return;
    
    final listaParcelas = parcelas.dadosParsed?.listaParcelas ?? [];
    
    for (final parcela in listaParcelas) {
      final vencimento = DateTime.tryParse(parcela.dataVencimentoFormatada);
      if (vencimento != null) {
        final diasParaVencimento = vencimento.difference(DateTime.now()).inDays;
        
        if (diasParaVencimento <= 5) {
          print('⚠️ Parcela ${parcela.parcelaFormatada} vence em $diasParaVencimento dias');
        }
      }
    }
  } catch (e) {
    print('Erro no monitoramento: $e');
  }
}
```

## Integração com Outros Serviços

O PARCSN Service pode ser usado em conjunto com:

- **DCTFWeb Service**: Para consultar declarações relacionadas aos parcelamentos
- **MIT Service**: Para consultar apurações relacionadas aos parcelamentos
- **Eventos Atualização Service**: Para monitorar atualizações de parcelamentos
- **SITFIS Service**: Para consultar informações tributárias do contribuinte

## Monitoramento e Logs

Para monitoramento eficaz:

- Logar todas as consultas de parcelamentos
- Monitorar emissões de DAS
- Alertar sobre parcelas próximas do vencimento
- Rastrear erros de validação
- Monitorar performance das requisições

## Suporte

Para dúvidas sobre o serviço PARCSN:

- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package