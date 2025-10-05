# SICALC - Sistema de Cálculo de Impostos

## Visão Geral

O serviço SICALC permite gerar documentos de arrecadação (DARF/DAE) para diversos tipos de tributos, incluindo IRPF, IRPJ, CSLL, PIS/COFINS, entre outros.

## Funcionalidades

- **Gerar DARF Pessoa Física**: Geração de DARF para IRPF
- **Gerar DARF Pessoa Jurídica**: Geração de DARF para IRPJ
- **Consolidar e Gerar DARF**: Consolidação de tributos e geração de DARF
- **Gerar DAE**: Geração de Documento de Arrecadação Estadual
- **Consultar Códigos de Receita**: Consulta de códigos de receita disponíveis
- **Validar Dados**: Validação automática de dados de entrada

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço SICALC

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
final sicalcService = SicalcService(apiClient);
```

### 2. Gerar DARF Pessoa Física

```dart
try {
  final response = await sicalcService.gerarDarfPessoaFisica(
    contribuinteNumero: '00000000000', // CPF
    uf: 'SP',
    municipio: 3550308, // São Paulo
    codigoReceita: 190, // IRPF
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.00,
    dataConsolidacao: '20240215',
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );

  if (response.sucesso) {
    print('DARF gerado com sucesso!');
    print('Número do documento: ${response.dados.numeroDocumento}');
    print('Valor total: R\$ ${response.dados.valorTotal.toStringAsFixed(2)}');
    print('Data de vencimento: ${response.dados.dataVencimento}');
    
    // Salvar PDF
    if (response.dados.pdfBase64.isNotEmpty) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados.pdfBase64,
        'darf_pf_${response.dados.numeroDocumento}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DARF PF: $e');
}
```

### 3. Gerar DARF Pessoa Jurídica

```dart
try {
  final response = await sicalcService.gerarDarfPessoaJuridica(
    contribuinteNumero: '00000000000000', // CNPJ
    uf: 'SP',
    municipio: 3550308,
    codigoReceita: 1001, // IRPJ
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 5000.00,
    dataConsolidacao: '20240215',
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );

  if (response.sucesso) {
    print('DARF PJ gerado com sucesso!');
    print('Número: ${response.dados.numeroDocumento}');
    print('Valor: R\$ ${response.dados.valorTotal.toStringAsFixed(2)}');
    
    // Salvar PDF
    if (response.dados.pdfBase64.isNotEmpty) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados.pdfBase64,
        'darf_pj_${response.dados.numeroDocumento}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DARF PJ: $e');
}
```

### 4. Consolidar e Gerar DARF

```dart
try {
  final response = await sicalcService.consolidarEGerarDarf(
    contribuinteNumero: '00000000000000',
    uf: 'SP',
    municipio: 3550308,
    codigoReceita: 190,
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.00,
    dataConsolidacao: '20240215',
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );

  if (response.sucesso) {
    print('DARF consolidado gerado!');
    print('Número: ${response.dados.numeroDocumento}');
    print('Valor: R\$ ${response.dados.valorTotal.toStringAsFixed(2)}');
    
    // Detalhamento dos tributos
    for (final tributo in response.dados.tributos) {
      print('Tributo ${tributo.codigo}: R\$ ${tributo.valor.toStringAsFixed(2)}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consolidar DARF: $e');
}
```

### 5. Gerar DAE (Documento de Arrecadação Estadual)

```dart
try {
  final response = await sicalcService.gerarDae(
    contribuinteNumero: '00000000000000',
    uf: 'SP',
    municipio: 3550308,
    codigoReceita: 1001,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: 1000.00,
    dataConsolidacao: '20240215',
  );

  if (response.sucesso) {
    print('DAE gerado com sucesso!');
    print('Número: ${response.dados.numeroDocumento}');
    print('Valor: R\$ ${response.dados.valorTotal.toStringAsFixed(2)}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao gerar DAE: $e');
}
```

### 6. Consultar Códigos de Receita

```dart
try {
  final response = await sicalcService.consultarCodigosReceita(
    uf: 'SP',
    municipio: 3550308,
  );

  if (response.sucesso) {
    print('Códigos de receita encontrados: ${response.dados.length}');
    
    for (final codigo in response.dados) {
      print('Código: ${codigo.codigo} - ${codigo.descricao}');
      print('Extensões: ${codigo.extensoes.map((e) => '${e.codigo}: ${e.descricao}').join(', ')}');
      print('---');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar códigos: $e');
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

// Validar valor monetário
final errorValor = ValidacoesUtils.validarValorMonetario(valorImposto);
if (errorValor != null) {
  print('Valor inválido: $errorValor');
  return;
}

// Validar data
final errorData = ValidacoesUtils.validarDataInt(int.tryParse(dataPA));
if (errorData != null) {
  print('Data inválida: $errorData');
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

// Formatar moeda
final valorFormatado = FormatadorUtils.formatCurrency(valorImposto);
print('Valor do Imposto: $valorFormatado');

// Formatar data
final dataFormatada = FormatadorUtils.formatDateFromString(dataPA);
print('Período de Apuração: $dataFormatada');

// Formatar período
final periodoFormatado = FormatadorUtils.formatPeriodFromString(dataPA.substring(0, 6));
print('Período: $periodoFormatado');
```

## Códigos de Receita Comuns

### Tributos Federais
- **190**: IRPF (Imposto de Renda Pessoa Física)
- **1001**: IRPJ (Imposto de Renda Pessoa Jurídica)
- **1002**: CSLL (Contribuição Social sobre o Lucro Líquido)
- **1003**: PIS (Programa de Integração Social)
- **1004**: COFINS (Contribuição para o Financiamento da Seguridade Social)

### Tributos Estaduais
- **1005**: ICMS (Imposto sobre Circulação de Mercadorias e Serviços)
- **1006**: IPVA (Imposto sobre Propriedade de Veículos Automotores)

### Tributos Municipais
- **1007**: IPTU (Imposto sobre Propriedade Predial e Territorial Urbana)
- **1008**: ISS (Imposto sobre Serviços)

## Estrutura de Dados

### GerarDarfResponse

```dart
class GerarDarfResponse {
  final bool sucesso;
  final String? mensagemErro;
  final GerarDarfDados? dados;
  final List<MensagemNegocio> mensagens;
}

class GerarDarfDados {
  final String numeroDocumento;
  final double valorTotal;
  final String dataVencimento;
  final String pdfBase64;
  final List<TributoDetalhado> tributos;
  // ... outros campos
}

class TributoDetalhado {
  final String codigo;
  final String descricao;
  final double valor;
  final String? extensao;
  // ... outros campos
}
```

### ConsultarCodigosReceitaResponse

```dart
class ConsultarCodigosReceitaResponse {
  final bool sucesso;
  final String? mensagemErro;
  final List<CodigoReceita> dados;
  final List<MensagemNegocio> mensagens;
}

class CodigoReceita {
  final String codigo;
  final String descricao;
  final List<ExtensaoReceita> extensoes;
  // ... outros campos
}

class ExtensaoReceita {
  final String codigo;
  final String descricao;
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CPF/CNPJ inválido | Verificar formato do documento |
| 003 | Código de receita inválido | Verificar se código existe |
| 004 | Data inválida | Verificar formato da data |
| 005 | Valor inválido | Verificar se valor é positivo |

## Exemplos Práticos

### Exemplo Completo - Fluxo Completo SICALC

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
  final sicalcService = SicalcService(apiClient);
  
  try {
    const contribuinteNumero = '00000000000'; // CPF
    const uf = 'SP';
    const municipio = 3550308; // São Paulo
    const codigoReceita = 190; // IRPF
    const valorImposto = 1000.00;
    
    // Validar dados antes de usar
    final errorCpf = ValidacoesUtils.validarCpf(contribuinteNumero);
    if (errorCpf != null) {
      print('CPF inválido: $errorCpf');
      return;
    }
    
    final errorValor = ValidacoesUtils.validarValorMonetario(valorImposto);
    if (errorValor != null) {
      print('Valor inválido: $errorValor');
      return;
    }
    
    // 3. Consultar códigos de receita disponíveis
    print('=== Consultando Códigos de Receita ===');
    final codigosResponse = await sicalcService.consultarCodigosReceita(
      uf: uf,
      municipio: municipio,
    );
    
    if (codigosResponse.sucesso) {
      print('Códigos disponíveis: ${codigosResponse.dados.length}');
      
      // Encontrar o código desejado
      final codigoDesejado = codigosResponse.dados.firstWhere(
        (c) => c.codigo == codigoReceita.toString(),
        orElse: () => codigosResponse.dados.first,
      );
      
      print('Usando código: ${codigoDesejado.codigo} - ${codigoDesejado.descricao}');
      
      // 4. Gerar DARF Pessoa Física
      print('\n=== Gerando DARF Pessoa Física ===');
      final darfResponse = await sicalcService.gerarDarfPessoaFisica(
        contribuinteNumero: contribuinteNumero,
        uf: uf,
        municipio: municipio,
        codigoReceita: int.parse(codigoDesejado.codigo),
        codigoReceitaExtensao: codigoDesejado.extensoes.first.codigo,
        dataPA: '20240101',
        vencimento: '20240215',
        valorImposto: valorImposto,
        dataConsolidacao: '20240215',
      );
      
      if (darfResponse.sucesso) {
        print('✅ DARF gerado com sucesso!');
        print('CPF: ${FormatadorUtils.formatCpf(contribuinteNumero)}');
        print('Número: ${darfResponse.dados.numeroDocumento}');
        print('Valor: ${FormatadorUtils.formatCurrency(darfResponse.dados.valorTotal)}');
        print('Vencimento: ${FormatadorUtils.formatDateFromString(darfResponse.dados.dataVencimento)}');
        
        // Detalhamento dos tributos
        print('\nDetalhamento dos Tributos:');
        for (final tributo in darfResponse.dados.tributos) {
          print('  ${tributo.codigo}: ${FormatadorUtils.formatCurrency(tributo.valor)}');
        }
        
        // Salvar PDF
        if (darfResponse.dados.pdfBase64.isNotEmpty) {
          final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
            darfResponse.dados.pdfBase64,
            'darf_pf_${darfResponse.dados.numeroDocumento}.pdf',
          );
          print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
        }
        
      } else {
        print('❌ Erro ao gerar DARF: ${darfResponse.mensagemErro}');
        
        // Analisar mensagens de erro
        for (final mensagem in darfResponse.mensagens) {
          if (mensagem.isErro) {
            print('Erro: ${mensagem.codigo} - ${mensagem.texto}');
          }
        }
      }
      
    } else {
      print('❌ Erro ao consultar códigos: ${codigosResponse.mensagemErro}');
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
  final sicalcService = SicalcService(apiClient);
  
  // Validar CPF antes de usar
  const contribuinteNumero = '12345678901';
  final errorCpf = ValidacoesUtils.validarCpf(contribuinteNumero);
  
  if (errorCpf != null) {
    print('CPF inválido: $errorCpf');
    return;
  }
  
  // Validar valor
  const valorImposto = 1500.75;
  final errorValor = ValidacoesUtils.validarValorMonetario(valorImposto);
  
  if (errorValor != null) {
    print('Valor inválido: $errorValor');
    return;
  }
  
  // CPF e valor válidos, prosseguir
  final response = await sicalcService.gerarDarfPessoaFisica(
    contribuinteNumero: contribuinteNumero,
    uf: 'SP',
    municipio: 3550308,
    codigoReceita: 190,
    codigoReceitaExtensao: 1,
    dataPA: '20240101',
    vencimento: '20240215',
    valorImposto: valorImposto,
    dataConsolidacao: '20240215',
  );
  
  if (response.sucesso) {
    print('=== DARF Gerado ===');
    print('CPF: ${FormatadorUtils.formatCpf(contribuinteNumero)}');
    print('Número: ${response.dados.numeroDocumento}');
    print('Valor: ${FormatadorUtils.formatCurrency(response.dados.valorTotal)}');
    print('Vencimento: ${FormatadorUtils.formatDateFromString(response.dados.dataVencimento)}');
    
    // Detalhamento
    print('\nDetalhamento:');
    for (final tributo in response.dados.tributos) {
      print('  ${tributo.codigo}: ${FormatadorUtils.formatCurrency(tributo.valor)}');
    }
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CPFs/CNPJs de teste (sempre usar zeros)
const cpfTeste = '00000000000';
const cnpjTeste = '00000000000000';

// Dados de teste comuns
const ufTeste = 'SP';
const municipioTeste = 3550308; // São Paulo
const codigoReceitaTeste = 190; // IRPF
const valorTeste = 1000.00;
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Códigos de Receita**: Deve usar códigos válidos para a UF/município
5. **Valores Monetários**: Devem ser valores positivos válidos

## Suporte

Para dúvidas sobre o serviço SICALC:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package