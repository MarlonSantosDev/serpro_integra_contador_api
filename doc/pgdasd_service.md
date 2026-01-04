# PGDASD - Pagamento de DAS por Débito Direto Autorizado

## Visão Geral

O serviço PGDASD permite gerenciar declarações e pagamentos do Simples Nacional para MEI, incluindo entrega de declarações mensais, geração de DAS, consulta de declarações e extratos.

## Funcionalidades

- **Entregar Declaração Mensal**: Transmissão de declarações mensais do Simples Nacional
- **Gerar DAS**: Geração de Documento de Arrecadação Simples Nacional
- **Consultar Declarações**: Consulta de declarações transmitidas por ano ou período
- **Consultar Última Declaração**: Consulta da última declaração transmitida
- **Consultar Declaração por Número**: Consulta de declaração específica
- **Consultar Extrato DAS**: Consulta de extrato de DAS
- **Gerar DAS Cobrança**: Geração de DAS para cobrança
- **Gerar DAS Processo**: Geração de DAS para processo
- **Gerar DAS Avulso**: Geração de DAS avulso

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço PGDASD

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
final pgdasdService = PgdasdService(apiClient);
```

### 2. Entregar Declaração Mensal

```dart
try {
  // Criar declaração de exemplo
  final declaracao = Declaracao(
    tipoDeclaracao: 1, // Original
    receitaPaCompetenciaInterno: 50000.00,
    receitaPaCompetenciaExterno: 10000.00,
    estabelecimentos: [
      Estabelecimento(
        cnpjCompleto: '00000000000100',
        atividades: [
          Atividade(
            idAtividade: 1,
            valorAtividade: 60000.00,
            receitasAtividade: [
              ReceitaAtividade(
                valor: 60000.00,
                isencoes: [
                  Isencao(
                    codTributo: 1,
                    valor: 1000.00,
                    identificador: 1,
                  ),
                ],
                reducoes: [
                  Reducao(
                    codTributo: 1,
                    valor: 500.00,
                    percentualReducao: 5.0,
                    identificador: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  final response = await pgdasdService.entregarDeclaracao(
    contribuinteNumero: '00000000000100',
    request: EntregarDeclaracaoRequest(
      cnpjCompleto: '00000000000100',
      pa: 202101,
      indicadorTransmissao: true,
      indicadorComparacao: true,
      declaracao: declaracao,
      valoresParaComparacao: [
        ValorDevido(codigoTributo: 1, valor: 1000.00),
      ValorDevido(codigoTributo: 2, valor: 500.00),
    ],
  );

  if (response.sucesso) {
    print('Declaração entregue com sucesso!');
    print('ID Declaração: ${response.dadosParsed?.first.idDeclaracao}');
    print('Data Transmissão: ${response.dadosParsed?.first.dataHoraTransmissao}');
    print('Valor Total Devido: R\$ ${response.dadosParsed?.first.valorTotalDevido.toStringAsFixed(2)}');
    
    // Detalhamento dos valores devidos
    for (final valor in response.dadosParsed?.first.valoresDevidos ?? []) {
      print('Tributo ${valor.codigoTributo}: R\$ ${valor.valor.toStringAsFixed(2)}');
    }
    
    // Detalhamento MAED se houver
    if (response.dadosParsed?.first.temMaed == true) {
      final maed = response.dadosParsed!.first.detalhamentoDarfMaed!;
      print('MAED:');
      print('  Número Documento: ${maed.numeroDocumento}');
      print('  Data Vencimento: ${maed.dataVencimento}');
      print('  Principal: R\$ ${maed.valores.principal.toStringAsFixed(2)}');
      print('  Multa: R\$ ${maed.valores.multa.toStringAsFixed(2)}');
      print('  Juros: R\$ ${maed.valores.juros.toStringAsFixed(2)}');
      print('  Total: R\$ ${maed.valores.total.toStringAsFixed(2)}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao entregar declaração: $e');
}
```

### 3. Gerar DAS

```dart
try {
  final response = await pgdasdService.gerarDas(
    contribuinteNumero: '00000000000100',
    request: GerarDasRequest(
      periodoApuracao: '202101',
      // dataConsolidacao: '20220831', // Opcional
    ),
  );

  if (response.sucesso) {
    print('DAS gerado com sucesso!');
    print('Número do DAS: ${response.dadosParsed?.first.numeroDas}');
    print('Valor Total: R\$ ${response.dadosParsed?.first.valorTotal.toStringAsFixed(2)}');
    print('Data Vencimento: ${response.dadosParsed?.first.dataVencimento}');
    
    // Salvar PDF
    if (response.dadosParsed?.first.pdfBase64.isNotEmpty == true) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dadosParsed!.first.pdfBase64,
        'das_${response.dadosParsed!.first.numeroDas}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS: $e');
}
```

### 4. Consultar Declarações por Ano

```dart
try {
  final response = await pgdasdService.consultarDeclaracoes(
    contribuinteNumero: '00000000000100',
    request: ConsultarDeclaracoesRequest.porAnoCalendario('2021'),
  );

  if (response.sucesso) {
    print('Declarações encontradas: ${response.dadosParsed?.length ?? 0}');
    
    for (final declaracao in response.dadosParsed ?? []) {
      print('Período: ${declaracao.periodoApuracao}');
      print('Situação: ${declaracao.situacao}');
      print('Data Transmissão: ${declaracao.dataHoraTransmissao}');
      print('Valor Total: R\$ ${declaracao.valorTotalDevido.toStringAsFixed(2)}');
      print('---');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar declarações: $e');
}
```

### 5. Consultar Declarações por Período

```dart
try {
  final response = await pgdasdService.consultarDeclaracoes(
    contribuinteNumero: '00000000000100',
    request: ConsultarDeclaracoesRequest.porPeriodoApuracao('202101'),
  );

  if (response.sucesso) {
    print('Declarações no período: ${response.dadosParsed?.length ?? 0}');
    
    for (final declaracao in response.dadosParsed ?? []) {
      print('Período: ${declaracao.periodoApuracao}');
      print('Situação: ${declaracao.situacao}');
      print('Valor: R\$ ${declaracao.valorTotalDevido.toStringAsFixed(2)}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar por período: $e');
}
```

### 6. Consultar Última Declaração

```dart
try {
  final response = await pgdasdService.consultarUltimaDeclaracao(
    contribuinteNumero: '00000000000100',
    request: ConsultarUltimaDeclaracaoRequest(periodoApuracao: '202101'),
  );

  if (response.sucesso) {
    print('Última declaração encontrada!');
    print('Período: ${response.dadosParsed?.first.periodoApuracao}');
    print('Situação: ${response.dadosParsed?.first.situacao}');
    print('Data Transmissão: ${response.dadosParsed?.first.dataHoraTransmissao}');
    print('Valor Total: R\$ ${response.dadosParsed?.first.valorTotalDevido.toStringAsFixed(2)}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar última declaração: $e');
}
```

### 7. Consultar Extrato DAS

```dart
try {
  final response = await pgdasdService.consultarExtratoDas(
    contribuinteNumero: '00000000000100',
    request: ConsultarExtratoDasRequest(numeroDas: '07202136999997159'),
  );

  if (response.sucesso) {
    print('Extrato DAS encontrado!');
    print('Período: ${response.dadosParsed?.first.periodoApuracao}');
    print('Valor Total: R\$ ${response.dadosParsed?.first.valorTotal.toStringAsFixed(2)}');
    print('Data Vencimento: ${response.dadosParsed?.first.dataVencimento}');
    
    // Detalhamento dos tributos
    for (final tributo in response.dadosParsed?.first.tributos ?? []) {
      print('Tributo ${tributo.codigoTributo}: R\$ ${tributo.valor.toStringAsFixed(2)}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar extrato: $e');
}
```

### 8. Gerar DAS Cobrança

```dart
try {
  final response = await pgdasdService.gerarDasCobranca(
    contribuinteNumero: '00000000000100',
    request: GerarDasCobrancaRequest(periodoApuracao: '202301'),
  );

  if (response.sucesso) {
    print('DAS Cobrança gerado!');
    print('Número: ${response.dadosParsed?.first.numeroDas}');
    print('Valor: R\$ ${response.dadosParsed?.first.valorTotal.toStringAsFixed(2)}');
    
    // Salvar PDF
    if (response.dadosParsed?.first.pdfBase64.isNotEmpty == true) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dadosParsed!.first.pdfBase64,
        'das_cobranca_${response.dadosParsed!.first.numeroDas}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS cobrança: $e');
}
```

### 9. Gerar DAS Processo

```dart
try {
  final response = await pgdasdService.gerarDasProcesso(
    contribuinteNumero: '00000000000100',
    request: GerarDasProcessoRequest(numeroProcesso: '00000000000000000'),
  );

  if (response.sucesso) {
    print('DAS Processo gerado!');
    print('Número: ${response.dadosParsed?.first.numeroDas}');
    print('Valor: R\$ ${response.dadosParsed?.first.valorTotal.toStringAsFixed(2)}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS processo: $e');
}
```

### 10. Gerar DAS Avulso

```dart
try {
  final response = await pgdasdService.gerarDasAvulso(
    contribuinteNumero: '00000000000100',
    request: GerarDasAvulsoRequest(
      periodoApuracao: '202301',
      listaTributos: [
        TributoAvulso(codigoTributo: 1, valor: 1000.00),
      ],
    ),
  );

  if (response.sucesso) {
    print('DAS Avulso gerado!');
    print('Número: ${response.dadosParsed?.first.numeroDas}');
    print('Valor: R\$ ${response.dadosParsed?.first.valorTotal.toStringAsFixed(2)}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAS avulso: $e');
}
```

## Validações Disponíveis

O serviço utiliza validações centralizadas do `ValidacoesUtils`:

```dart
// Validar CNPJ
final errorCnpj = ValidacoesUtils.validarCnpjContribuinte('12345678000195');
if (errorCnpj != null) {
  print('CNPJ inválido: $errorCnpj');
}

// Validar período de apuração
final errorPeriodo = ValidacoesUtils.validarAnoMes(202401);
if (errorPeriodo != null) {
  print('Período inválido: $errorPeriodo');
}

// Validar valor monetário
final errorValor = ValidacoesUtils.validarValorMonetario(1000.50);
if (errorValor != null) {
  print('Valor inválido: $errorValor');
}
```

## Formatação de Dados

Utilize os utilitários de formatação do `FormatadorUtils`:

```dart
// Formatar CNPJ
final cnpjFormatado = FormatadorUtils.formatCnpj('12345678000195');
print('CNPJ: $cnpjFormatado'); // 12.345.678/0001-95

// Formatar moeda
final valorFormatado = FormatadorUtils.formatCurrency(1234.56);
print('Valor: $valorFormatado'); // R$ 1.234,56

// Formatar período
final periodoFormatado = FormatadorUtils.formatPeriodFromString('202401');
print('Período: $periodoFormatado'); // Janeiro/2024

// Formatar data
final dataFormatada = FormatadorUtils.formatDateFromString('20240315');
print('Data: $dataFormatada'); // 15/03/2024
```

## Estrutura de Dados

### EntregarDeclaracaoResponse

```dart
class EntregarDeclaracaoResponse {
  final bool sucesso;
  final String? mensagemErro;
  final List<DeclaracaoTransmitida>? dadosParsed;
  final List<MensagemNegocio> mensagens;
}

class DeclaracaoTransmitida {
  final String idDeclaracao;
  final String dataHoraTransmissao;
  final double valorTotalDevido;
  final bool temMaed;
  final List<ValorDevido> valoresDevidos;
  final DetalhamentoDarfMaed? detalhamentoDarfMaed;
  // ... outros campos
}
```

### GerarDasResponse

```dart
class GerarDasResponse {
  final bool sucesso;
  final String? mensagemErro;
  final List<DasGerado>? dadosParsed;
  final List<MensagemNegocio> mensagens;
}

class DasGerado {
  final String numeroDas;
  final double valorTotal;
  final String dataVencimento;
  final String pdfBase64;
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Período inválido | Verificar formato do período de apuração |
| 004 | Declaração não encontrada | Verificar se declaração foi transmitida |
| 005 | Valores inválidos | Verificar valores monetários |

## Exemplos Práticos

### Exemplo Completo - Fluxo Completo PGDASD

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
  final pgdasdService = PgdasdService(apiClient);
  
  try {
    const cnpj = '00000000000100';
    const periodoApuracao = 202101;
    
    // 3. Entregar declaração mensal
    print('=== Entregando Declaração Mensal ===');
    final declaracao = Declaracao(
      tipoDeclaracao: 1,
      receitaPaCompetenciaInterno: 50000.00,
      receitaPaCompetenciaExterno: 10000.00,
      estabelecimentos: [
        Estabelecimento(
          cnpjCompleto: cnpj,
          atividades: [
            Atividade(
              idAtividade: 1,
              valorAtividade: 60000.00,
              receitasAtividade: [
                ReceitaAtividade(
                  valor: 60000.00,
                  isencoes: [
                    Isencao(codTributo: 1, valor: 1000.00, identificador: 1),
                  ],
                  reducoes: [
                    Reducao(codTributo: 1, valor: 500.00, percentualReducao: 5.0, identificador: 1),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final entregarResponse = await pgdasdService.entregarDeclaracao(
      contribuinteNumero: cnpj,
      request: EntregarDeclaracaoRequest(
        cnpjCompleto: cnpj,
        pa: periodoApuracao,
        indicadorTransmissao: true,
        indicadorComparacao: true,
        declaracao: declaracao,
        valoresParaComparacao: [
          ValorDevido(codigoTributo: 1, valor: 1000.00),
          ValorDevido(codigoTributo: 2, valor: 500.00),
        ],
      ),
    );

    if (entregarResponse.sucesso) {
      print('Declaração entregue com sucesso!');
      final declaracaoTransmitida = entregarResponse.dadosParsed!.first;
      print('ID: ${declaracaoTransmitida.idDeclaracao}');
      print('Data: ${declaracaoTransmitida.dataHoraTransmissao}');
      print('Valor Total: ${FormatadorUtils.formatCurrency(declaracaoTransmitida.valorTotalDevido)}');
      
      // 4. Gerar DAS
      print('\n=== Gerando DAS ===');
      final dasResponse = await pgdasdService.gerarDas(
        contribuinteNumero: cnpj,
        request: GerarDasRequest(periodoApuracao: periodoApuracao.toString()),
      );

      if (dasResponse.sucesso) {
        print('DAS gerado com sucesso!');
        final das = dasResponse.dadosParsed!.first;
        print('Número: ${das.numeroDas}');
        print('Valor: ${FormatadorUtils.formatCurrency(das.valorTotal)}');
        print('Vencimento: ${FormatadorUtils.formatDateFromString(das.dataVencimento)}');
        
        // Salvar PDF
        if (das.pdfBase64.isNotEmpty) {
          final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
            das.pdfBase64,
            'das_${das.numeroDas}.pdf',
          );
          print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
        }
      }
      
      // 5. Consultar declarações do ano
      print('\n=== Consultando Declarações do Ano ===');
      final consultarAnoResponse = await pgdasdService.consultarDeclaracoes(
        contribuinteNumero: cnpj,
        request: ConsultarDeclaracoesRequest.porAnoCalendario('2021'),
      );

      if (consultarAnoResponse.sucesso) {
        print('Declarações encontradas: ${consultarAnoResponse.dadosParsed?.length ?? 0}');
        for (final declaracao in consultarAnoResponse.dadosParsed ?? []) {
          print('Período: ${FormatadorUtils.formatPeriodFromString(declaracao.periodoApuracao.toString())}');
          print('Situação: ${declaracao.situacao}');
          print('Valor: ${FormatadorUtils.formatCurrency(declaracao.valorTotalDevido)}');
          print('---');
        }
      }
      
      // 6. Consultar extrato DAS
      print('\n=== Consultando Extrato DAS ===');
      final extratoResponse = await pgdasdService.consultarExtratoDas(
        contribuinteNumero: cnpj,
        request: ConsultarExtratoDasRequest(numeroDas: '07202136999997159'),
      );

      if (extratoResponse.sucesso) {
        print('Extrato encontrado!');
        final extrato = extratoResponse.dadosParsed!.first;
        print('Período: ${FormatadorUtils.formatPeriodFromString(extrato.periodoApuracao)}');
        print('Valor Total: ${FormatadorUtils.formatCurrency(extrato.valorTotal)}');
        print('Vencimento: ${FormatadorUtils.formatDateFromString(extrato.dataVencimento)}');
        
        // Detalhamento dos tributos
        for (final tributo in extrato.tributos ?? []) {
          print('Tributo ${tributo.codigoTributo}: ${FormatadorUtils.formatCurrency(tributo.valor)}');
        }
      }
      
    } else {
      print('Erro ao entregar declaração: ${entregarResponse.mensagemErro}');
      
      // Analisar mensagens de erro
      for (final mensagem in entregarResponse.mensagens) {
        if (mensagem.isErro) {
          print('Erro: ${mensagem.codigo} - ${mensagem.texto}');
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
  final pgdasdService = PgdasdService(apiClient);
  
  // Validar CNPJ antes de usar
  const cnpj = '12345678000195';
  final errorCnpj = ValidacoesUtils.validarCnpjContribuinte(cnpj);
  
  if (errorCnpj != null) {
    print('CNPJ inválido: $errorCnpj');
    return;
  }
  
  // Validar período
  const periodo = 202401;
  final errorPeriodo = ValidacoesUtils.validarAnoMes(periodo);
  
  if (errorPeriodo != null) {
    print('Período inválido: $errorPeriodo');
    return;
  }
  
  // CNPJ e período válidos, prosseguir
  final response = await pgdasdService.consultarDeclaracoes(
    contribuinteNumero: cnpj,
    request: ConsultarDeclaracoesRequest.porAnoCalendario('2024'),
  );
  
  if (response.sucesso) {
    print('=== Declarações do Ano ===');
    print('CNPJ: ${FormatadorUtils.formatCnpj(cnpj)}');
    print('Ano: 2024');
    print('Declarações: ${response.dadosParsed?.length ?? 0}');
    
    double valorTotalAno = 0;
    for (final declaracao in response.dadosParsed ?? []) {
      print('\nPeríodo: ${FormatadorUtils.formatPeriodFromString(declaracao.periodoApuracao.toString())}');
      print('Situação: ${declaracao.situacao}');
      print('Data Transmissão: ${FormatadorUtils.formatDateFromString(declaracao.dataHoraTransmissao)}');
      print('Valor: ${FormatadorUtils.formatCurrency(declaracao.valorTotalDevido)}');
      
      valorTotalAno += declaracao.valorTotalDevido;
    }
    
    print('\nValor Total do Ano: ${FormatadorUtils.formatCurrency(valorTotalAno)}');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000100';

// Períodos de teste
const periodoTeste = 202101;
const anoTeste = 2021;

// Valores de teste
const valorTeste = 1000.00;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Período de Apuração**: Deve estar no formato AAAAMM
5. **Valores Monetários**: Devem ser valores positivos válidos

## Suporte

Para dúvidas sobre o serviço PGDASD:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package