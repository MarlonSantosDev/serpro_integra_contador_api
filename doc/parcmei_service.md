# PARCMEI - Parcelamento do MEI

## Visão Geral

O serviço PARCMEI permite gerenciar parcelamentos de débitos do Microempreendedor Individual (MEI), incluindo consulta de pedidos de parcelamento, consulta de parcelas disponíveis para impressão, consulta de detalhes de pagamento e emissão de DAS para parcelas.

## Funcionalidades

- **Consultar Pedidos de Parcelamento**: Consulta de todos os pedidos de parcelamento do tipo PARCMEI
- **Consultar Parcelamento Específico**: Consulta de informações detalhadas de um parcelamento específico
- **Consultar Parcelas Disponíveis**: Consulta de parcelas disponíveis para impressão de DAS
- **Consultar Detalhes de Pagamento**: Consulta de detalhes de pagamento de uma parcela específica
- **Emitir DAS para Parcela**: Emissão de DAS para uma parcela específica

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PARCMEI

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
final parcmeiService = ParcmeiService(apiClient);
```

### 2. Consultar Pedidos de Parcelamento

```dart
try {
  final response = await parcmeiService.consultarPedidos();
  
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
  final response = await parcmeiService.consultarParcelamento(1);
  
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
  final response = await parcmeiService.consultarParcelas();
  
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
  final response = await parcmeiService.consultarDetalhesPagamento(1, 202107);
  
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
  final response = await parcmeiService.emitirDas(202107);
  
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

O serviço PARCMEI inclui várias validações para garantir a integridade dos dados:

```dart
// Validar número de parcelamento
final erro = parcmeiService.validarNumeroParcelamento(1);
if (erro != null) {
  print('Erro: $erro');
}

// Validar ano/mês de parcela
final erroAnoMes = parcmeiService.validarAnoMesParcela(202107);
if (erroAnoMes != null) {
  print('Erro: $erroAnoMes');
}

// Validar parcela para emissão
final erroParcela = parcmeiService.validarParcelaParaEmitir(202107);
if (erroParcela != null) {
  print('Erro: $erroParcela');
}
```

## Análise de Erros

O serviço inclui análise detalhada de erros específicos do PARCMEI:

```dart
// Analisar erro
final analise = parcmeiService.analyzeError('001', 'Erro de validação');
print('Tipo: ${analise.tipo}');
print('Descrição: ${analise.descricao}');
print('Solução: ${analise.solucao}');

// Verificar se erro é conhecido
if (parcmeiService.isKnownError('001')) {
  print('Erro conhecido pelo sistema');
}

// Obter informações do erro
final info = parcmeiService.getErrorInfo('001');
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
  final parcmeiService = ParcmeiService(apiClient);
  
  // 3. Consultar pedidos de parcelamento
  try {
    final pedidosResponse = await parcmeiService.consultarPedidos();
    
    if (pedidosResponse.sucesso) {
      print('Pedidos encontrados: ${pedidosResponse.dadosParsed?.parcelamentos.length ?? 0}');
      
      // 4. Consultar parcelas disponíveis
      final parcelasResponse = await parcmeiService.consultarParcelas();
      
      if (parcelasResponse.sucesso) {
        print('Parcelas disponíveis: ${parcelasResponse.dadosParsed?.listaParcelas.length ?? 0}');
        
        // 5. Emitir DAS para primeira parcela disponível
        final parcelas = parcelasResponse.dadosParsed?.listaParcelas ?? [];
        if (parcelas.isNotEmpty) {
          final primeiraParcela = parcelas.first;
          final parcelaParaEmitir = int.tryParse(primeiraParcela.parcelaFormatada.replaceAll('/', ''));
          
          if (parcelaParaEmitir != null) {
            final dasResponse = await parcmeiService.emitirDas(parcelaParaEmitir);
            
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
const anoMesParcela = 202107;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Prazo**: Parcelas têm prazo específico para emissão

## Suporte

Para dúvidas sobre o serviço PARCMEI:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
