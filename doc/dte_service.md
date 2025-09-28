# DTE Service

## Visão Geral

O `DteService` é responsável por consultar informações sobre o DTE (Domicílio Tributário Eletrônico) de contribuintes. Este serviço permite verificar se um contribuinte possui adesão ao DTE no Caixa Postal do Simples Nacional e no e-CAC.

## Funcionalidades Principais

- **Consulta de Indicador DTE**: Verifica se um contribuinte é optante do DTE
- **Validação de CNPJ**: Valida CNPJs para uso no sistema DTE
- **Análise de Resposta**: Analisa respostas e fornece informações úteis
- **Formatação de Dados**: Formata CNPJs para exibição

## Métodos Disponíveis

### 1. Obter Indicador DTE

```dart
Future<DteResponse> obterIndicadorDte(String cnpj)
```

**Parâmetros:**
- `cnpj`: CNPJ do contribuinte (apenas Pessoa Jurídica - tipo 2)

**Retorna:** `DteResponse` com o indicador de enquadramento e status

**Exemplo:**
```dart
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.sucesso) {
  print('Status: ${response.statusEnquadramentoDescricao}');
  print('É optante DTE: ${response.isOptanteDte}');
}
```

### 2. Validar CNPJ para DTE

```dart
bool validarCnpjDte(String cnpj)
```

**Exemplo:**
```dart
final isValid = dteService.validarCnpjDte('12345678000195');
if (isValid) {
  print('CNPJ válido para consulta DTE');
}
```

### 3. Formatar CNPJ

```dart
String formatarCnpj(String cnpj)
```

**Exemplo:**
```dart
final cnpjFormatado = dteService.formatarCnpj('12345678000195');
print('CNPJ formatado: $cnpjFormatado'); // 12.345.678/0001-95
```

### 4. Limpar CNPJ

```dart
String limparCnpj(String cnpj)
```

**Exemplo:**
```dart
final cnpjLimpo = dteService.limparCnpj('12.345.678/0001-95');
print('CNPJ limpo: $cnpjLimpo'); // 12345678000195
```

### 5. Obter Descrição do Indicador

```dart
String obterDescricaoIndicador(int indicador)
```

**Exemplo:**
```dart
final descricao = dteService.obterDescricaoIndicador(0);
print('Descrição: $descricao'); // NI Optante DTE
```

### 6. Verificar se Indicador é Válido

```dart
bool isIndicadorValido(int indicador)
```

**Exemplo:**
```dart
final isValid = dteService.isIndicadorValido(0);
print('Indicador válido: $isValid'); // true
```

### 7. Analisar Resposta DTE

```dart
Map<String, dynamic> analisarResposta(DteResponse response)
```

**Exemplo:**
```dart
final analysis = dteService.analisarResposta(response);
print('Análise: $analysis');
```

### 8. Verificar se Erro é Conhecido

```dart
bool isErroConhecido(String codigo)
```

**Exemplo:**
```dart
final isKnown = dteService.isErroConhecido('Erro-DTE-04');
print('Erro conhecido: $isKnown');
```

### 9. Obter Informações de Erro

```dart
Map<String, String>? obterInfoErro(String codigo)
```

**Exemplo:**
```dart
final errorInfo = dteService.obterInfoErro('Erro-DTE-04');
if (errorInfo != null) {
  print('Tipo: ${errorInfo['tipo']}');
  print('Descrição: ${errorInfo['descricao']}');
  print('Ação: ${errorInfo['acao']}');
}
```

## Indicadores de Enquadramento

| Código | Descrição |
|--------|-----------|
| -2 | NI inválido |
| -1 | NI Não optante |
| 0 | NI Optante DTE |
| 1 | NI Optante Simples |
| 2 | NI Optante DTE e Simples |

## Códigos de Erro Conhecidos

| Código | Tipo | Descrição | Ação |
|--------|------|-----------|------|
| Erro-DTE-04 | Validação | CPF inválido (9 dígitos) | Verifique se o CPF tem exatamente 9 dígitos e é válido |
| Erro-DTE-05 | Validação | CNPJ inválido (8 dígitos) | Verifique se o CNPJ tem exatamente 8 dígitos e é válido |
| Erro-DTE-991 | Sistema | Serviço não disponibilizado pelo sistema | Verifique se o serviço CONSULTASITUACAODTE111 está disponível |
| Erro-DTE-992 | Sistema | Serviço inválido | Verifique se o idServico está correto |
| Erro-DTE-993 | Sistema | Erro na conversão do retorno do serviço DTE | Tente novamente em alguns minutos |
| Erro-DTE-994 | Validação | Campo informado inválido | Verifique os dados enviados na requisição |
| Erro-DTE-995 | Conexão | Erro ao conectar com o serviço DTE | Verifique sua conexão e tente novamente |

## Exemplo de Uso Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Configurar cliente
  final apiClient = ApiClient(
    baseUrl: 'https://apigateway.serpro.gov.br/integra-contador-trial/v1',
    clientId: 'seu_client_id',
    clientSecret: 'seu_client_secret',
  );

  // Criar serviço
  final dteService = DteService(apiClient);

  try {
    // CNPJ para consulta
    const cnpj = '12345678000195';
    
    // Validar CNPJ primeiro
    if (!dteService.validarCnpjDte(cnpj)) {
      print('CNPJ inválido para consulta DTE');
      return;
    }

    // Consultar indicador DTE
    final response = await dteService.obterIndicadorDte(cnpj);
    
    if (response.sucesso) {
      print('=== Resultado da Consulta DTE ===');
      print('CNPJ: ${dteService.formatarCnpj(cnpj)}');
      print('Status HTTP: ${response.status}');
      print('Código da Mensagem: ${response.codigoMensagem}');
      print('Mensagem: ${response.mensagemPrincipal}');
      
      if (response.temIndicadorValido) {
        final dados = response.dadosParsed!;
        print('Indicador: ${dados.indicadorEnquadramento}');
        print('Descrição: ${dteService.obterDescricaoIndicador(dados.indicadorEnquadramento)}');
        print('Status Enquadramento: ${response.statusEnquadramentoDescricao}');
        
        // Verificar tipos de optante
        print('É optante DTE: ${response.isOptanteDte}');
        print('É optante Simples: ${response.isOptanteSimples}');
        print('É optante DTE e Simples: ${response.isOptanteDteESimples}');
        print('É não optante: ${response.isNaoOptante}');
        print('É NI inválido: ${response.isNiInvalido}');
      }
      
      // Analisar resposta completa
      final analysis = dteService.analisarResposta(response);
      print('\n=== Análise Completa ===');
      analysis.forEach((key, value) {
        print('$key: $value');
      });
      
    } else {
      print('Erro na consulta: ${response.mensagemPrincipal}');
      
      // Verificar se é um erro conhecido
      for (final mensagem in response.mensagens) {
        if (mensagem.isErro) {
          final errorInfo = dteService.obterInfoErro(mensagem.codigo);
          if (errorInfo != null) {
            print('Erro conhecido: ${errorInfo['descricao']}');
            print('Ação recomendada: ${errorInfo['acao']}');
          } else {
            print('Erro não mapeado: ${mensagem.codigo} - ${mensagem.texto}');
          }
        }
      }
    }
    
  } catch (e) {
    print('Erro na consulta DTE: $e');
  }
}
```

## Tratamento de Erros

O serviço possui tratamento robusto de erros com validações específicas:

### Validações de Entrada

- **CNPJ Vazio**: Verifica se o CNPJ não está vazio
- **CNPJ Inválido**: Valida formato e dígitos verificadores
- **Tipo de Contribuinte**: Verifica se é Pessoa Jurídica (14 dígitos)

### Validações de Resposta

- **Status HTTP**: Verifica se a resposta é HTTP 200
- **Mensagens de Erro**: Analisa mensagens específicas do DTE
- **Indicador Válido**: Verifica se o indicador está no range esperado

### Tratamento de Exceções

```dart
try {
  final response = await dteService.obterIndicadorDte('12345678000195');
  // Processar resposta
} on ArgumentError catch (e) {
  print('Erro de validação: $e');
} catch (e) {
  print('Erro de sistema: $e');
}
```

## Limitações

- Apenas CNPJs são aceitos (Pessoa Jurídica)
- CNPJ deve ter exatamente 14 dígitos
- Serviço pode estar temporariamente indisponível
- Alguns CNPJs podem não ter informações DTE disponíveis

## Casos de Uso Comuns

### 1. Verificar Optante DTE

```dart
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.isOptanteDte) {
  print('Contribuinte é optante do DTE');
}
```

### 2. Verificar Optante Simples

```dart
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.isOptanteSimples) {
  print('Contribuinte é optante do Simples Nacional');
}
```

### 3. Verificar Ambos

```dart
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.isOptanteDteESimples) {
  print('Contribuinte é optante do DTE e Simples Nacional');
}
```

### 4. Verificar Não Optante

```dart
final response = await dteService.obterIndicadorDte('12345678000195');
if (response.isNaoOptante) {
  print('Contribuinte não é optante de nenhum regime');
}
```

## Integração com Outros Serviços

O DTE Service pode ser usado em conjunto com outros serviços para:

- **Caixa Postal**: Verificar se contribuinte tem DTE antes de consultar caixa postal
- **Simples Nacional**: Verificar status de optante antes de operações específicas
- **Relatórios**: Gerar relatórios de contribuintes por tipo de enquadramento

## Monitoramento e Logs

Para monitoramento eficaz, considere:

- Logar todas as consultas DTE
- Monitorar taxa de erro por CNPJ
- Alertar sobre erros de sistema (991-995)
- Rastrear tempo de resposta das consultas
