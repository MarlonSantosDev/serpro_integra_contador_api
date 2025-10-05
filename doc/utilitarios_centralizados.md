# Utilitários Centralizados - Validações e Formatação

## Visão Geral

O projeto implementa utilitários centralizados para validações e formatação de dados, seguindo o princípio DRY (Don't Repeat Yourself) e garantindo consistência em todo o sistema.

## Validações Utilitárias (`ValidacoesUtils`)

### Validações de Documentos

#### Validar CNPJ
```dart
/// @validacoes_utils
///
/// Valida um CNPJ de contribuinte
///
/// **Exemplo de entrada:**
/// ```dart
/// validarCnpjContribuinte('12345678000195')
/// validarCnpjContribuinte(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'CNPJ é obrigatório'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarCnpjContribuinte(String? cnpj) {
  if (cnpj == null || cnpj.isEmpty) {
    return 'CNPJ é obrigatório';
  }

  final cleanCnpj = cleanDocumentNumber(cnpj);
  
  if (cleanCnpj.length != tamanhoCnpj) {
    return 'CNPJ deve ter $tamanhoCnpj dígitos';
  }

  if (!isValidCnpj(cnpj)) {
    return 'CNPJ inválido';
  }

  return null;
}
```

#### Validar CPF
```dart
/// @validacoes_utils
///
/// Valida um CPF
///
/// **Exemplo de entrada:**
/// ```dart
/// validarCpf('12345678901')
/// validarCpf(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'CPF é obrigatório'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarCpf(String? cpf) {
  if (cpf == null || cpf.isEmpty) {
    return 'CPF é obrigatório';
  }

  final cleanCpf = cleanDocumentNumber(cpf);
  
  if (cleanCpf.length != tamanhoCpf) {
    return 'CPF deve ter $tamanhoCpf dígitos';
  }

  if (!isValidCpf(cpf)) {
    return 'CPF inválido';
  }

  return null;
}
```

### Validações de Parcelamento

#### Validar Número de Parcelamento
```dart
/// @validacoes_utils
///
/// Valida um número de parcelamento
///
/// **Exemplo de entrada:**
/// ```dart
/// validarNumeroParcelamento(123456)
/// validarNumeroParcelamento(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'Número do parcelamento é obrigatório'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarNumeroParcelamento(int? numeroParcelamento) {
  if (numeroParcelamento == null) {
    return 'Número do parcelamento é obrigatório';
  }

  if (numeroParcelamento <= 0) {
    return 'Número do parcelamento deve ser maior que zero';
  }

  if (numeroParcelamento > 999999) {
    return 'Número do parcelamento deve ser menor que 999999';
  }

  return null;
}
```

#### Validar Ano/Mês
```dart
/// @validacoes_utils
///
/// Valida um ano/mês no formato AAAAMM
///
/// **Exemplo de entrada:**
/// ```dart
/// validarAnoMes(202401)
/// validarAnoMes(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'Ano/mês é obrigatório'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarAnoMes(int? anoMes) {
  if (anoMes == null) {
    return 'Ano/mês é obrigatório';
  }

  final anoMesStr = anoMes.toString();
  
  if (anoMesStr.length != 6) {
    return 'Ano/mês deve ter 6 dígitos (AAAAMM)';
  }

  final ano = int.tryParse(anoMesStr.substring(0, 4));
  final mes = int.tryParse(anoMesStr.substring(4, 6));

  if (ano == null || mes == null) {
    return 'Ano/mês deve conter apenas números';
  }

  if (ano < 2000 || ano > 2100) {
    return 'Ano deve estar entre 2000 e 2100';
  }

  if (mes < 1 || mes > 12) {
    return 'Mês deve estar entre 1 e 12';
  }

  return null;
}
```

### Validações de Data

#### Validar Data Int
```dart
/// @validacoes_utils
///
/// Valida uma data no formato AAAAMMDD
///
/// **Exemplo de entrada:**
/// ```dart
/// validarDataInt(20240115)
/// validarDataInt(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'Data é obrigatória'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarDataInt(int? data) {
  if (data == null) {
    return 'Data é obrigatória';
  }

  final dataStr = data.toString();
  
  if (dataStr.length != 8) {
    return 'Data deve ter 8 dígitos (AAAAMMDD)';
  }

  final ano = int.tryParse(dataStr.substring(0, 4));
  final mes = int.tryParse(dataStr.substring(4, 6));
  final dia = int.tryParse(dataStr.substring(6, 8));

  if (ano == null || mes == null || dia == null) {
    return 'Data deve conter apenas números';
  }

  try {
    DateTime(ano, mes, dia);
  } catch (e) {
    return 'Data inválida';
  }

  return null;
}
```

#### Validar Data/Hora Int
```dart
/// @validacoes_utils
///
/// Valida uma data/hora no formato AAAAMMDDHHMMSS
///
/// **Exemplo de entrada:**
/// ```dart
/// validarDataHoraInt(20240115143000)
/// validarDataHoraInt(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'Data/hora é obrigatória'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarDataHoraInt(int? dataHora) {
  if (dataHora == null) {
    return 'Data/hora é obrigatória';
  }

  final dataHoraStr = dataHora.toString();
  
  if (dataHoraStr.length != 14) {
    return 'Data/hora deve ter 14 dígitos (AAAAMMDDHHMMSS)';
  }

  final ano = int.tryParse(dataHoraStr.substring(0, 4));
  final mes = int.tryParse(dataHoraStr.substring(4, 6));
  final dia = int.tryParse(dataHoraStr.substring(6, 8));
  final hora = int.tryParse(dataHoraStr.substring(8, 10));
  final minuto = int.tryParse(dataHoraStr.substring(10, 12));
  final segundo = int.tryParse(dataHoraStr.substring(12, 14));

  if (ano == null || mes == null || dia == null || 
      hora == null || minuto == null || segundo == null) {
    return 'Data/hora deve conter apenas números';
  }

  try {
    DateTime(ano, mes, dia, hora, minuto, segundo);
  } catch (e) {
    return 'Data/hora inválida';
  }

  return null;
}
```

### Validações Monetárias

#### Validar Valor Monetário
```dart
/// @validacoes_utils
///
/// Valida um valor monetário
///
/// **Exemplo de entrada:**
/// ```dart
/// validarValorMonetario(1000.50)
/// validarValorMonetario(null)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// null  // válido
/// 'Valor é obrigatório'  // inválido
/// ```
///
/// Retorna null se válido, ou uma mensagem de erro se inválido
static String? validarValorMonetario(double? valor) {
  if (valor == null) {
    return 'Valor é obrigatório';
  }

  if (valor < 0) {
    return 'Valor não pode ser negativo';
  }

  if (valor > 999999999.99) {
    return 'Valor não pode ser maior que 999.999.999,99';
  }

  return null;
}
```

## Formatação Utilitária (`FormatadorUtils`)

### Formatação de Documentos

#### Formatar CNPJ
```dart
/// @formatador_utils
///
/// Formata CNPJ com máscara (XX.XXX.XXX/XXXX-XX)
///
/// **Exemplo de entrada:**
/// ```dart
/// formatCnpj('12345678000195')
/// formatCnpj('12.345.678/0001-95') // aceita já formatado
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// '12.345.678/0001-95'
/// '12.345.678/0001-95'
/// ```
///
/// [cnpj] - CNPJ sem formatação ou já formatado
///
/// Throws [ArgumentError] se o CNPJ não tiver 14 dígitos após limpeza
static String formatCnpj(String cnpj) {
  final cleanCnpj = ValidacoesUtils.cleanDocumentNumber(cnpj);

  if (cleanCnpj.length != ValidacoesUtils.tamanhoCnpj) {
    throw ArgumentError('CNPJ deve ter ${ValidacoesUtils.tamanhoCnpj} dígitos. Recebido: $cleanCnpj');
  }

  return '${cleanCnpj.substring(0, 2)}.${cleanCnpj.substring(2, 5)}.${cleanCnpj.substring(5, 8)}/${cleanCnpj.substring(8, 12)}-${cleanCnpj.substring(12)}';
}
```

#### Formatar CPF
```dart
/// @formatador_utils
///
/// Formata CPF com máscara (XXX.XXX.XXX-XX)
///
/// **Exemplo de entrada:**
/// ```dart
/// formatCpf('12345678901')
/// formatCpf('123.456.789-01') // aceita já formatado
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// '123.456.789-01'
/// '123.456.789-01'
/// ```
///
/// [cpf] - CPF sem formatação ou já formatado
///
/// Throws [ArgumentError] se o CPF não tiver 11 dígitos após limpeza
static String formatCpf(String cpf) {
  final cleanCpf = ValidacoesUtils.cleanDocumentNumber(cpf);

  if (cleanCpf.length != ValidacoesUtils.tamanhoCpf) {
    throw ArgumentError('CPF deve ter ${ValidacoesUtils.tamanhoCpf} dígitos. Recebido: $cleanCpf');
  }

  return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
}
```

### Formatação Monetária

#### Formatar Moeda
```dart
/// @formatador_utils
///
/// Formata valor monetário em reais (R$ X.XXX,XX)
///
/// **Exemplo de entrada:**
/// ```dart
/// formatCurrency(1234.56)
/// formatCurrency(0.0)
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// 'R\$ 1.234,56'
/// 'R\$ 0,00'
/// ```
///
/// [valor] - Valor monetário a ser formatado
static String formatCurrency(double valor) {
  final formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  
  return formatter.format(valor);
}
```

### Formatação de Data

#### Formatar Data de String
```dart
/// @formatador_utils
///
/// Formata data no formato DD/MM/AAAA
///
/// **Exemplo de entrada:**
/// ```dart
/// formatDateFromString('20240115')
/// formatDateFromString('20240301')
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// '15/01/2024'
/// '01/03/2024'
/// ```
///
/// [dataStr] - Data no formato AAAAMMDD
///
/// Throws [ArgumentError] se a data não tiver 8 dígitos
static String formatDateFromString(String dataStr) {
  if (dataStr.length != 8) {
    throw ArgumentError('Data deve ter 8 dígitos (AAAAMMDD). Recebido: $dataStr');
  }

  final ano = dataStr.substring(0, 4);
  final mes = dataStr.substring(4, 6);
  final dia = dataStr.substring(6, 8);

  return '$dia/$mes/$ano';
}
```

#### Formatar Período de String
```dart
/// @formatador_utils
///
/// Formata período no formato Mês/AAAA
///
/// **Exemplo de entrada:**
/// ```dart
/// formatPeriodFromString('202401')
/// formatPeriodFromString('202403')
/// ```
///
/// **Exemplo de saída:**
/// ```dart
/// 'Janeiro/2024'
/// 'Março/2024'
/// ```
///
/// [periodoStr] - Período no formato AAAAMM
///
/// Throws [ArgumentError] se o período não tiver 6 dígitos
static String formatPeriodFromString(String periodoStr) {
  if (periodoStr.length != 6) {
    throw ArgumentError('Período deve ter 6 dígitos (AAAAMM). Recebido: $periodoStr');
  }

  final ano = periodoStr.substring(0, 4);
  final mes = int.parse(periodoStr.substring(4, 6));

  final meses = [
    '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  if (mes < 1 || mes > 12) {
    throw ArgumentError('Mês inválido: $mes');
  }

  return '${meses[mes]}/$ano';
}
```

## Uso dos Utilitários

### Exemplo de Validação Completa

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() {
  // Validar CNPJ
  final errorCnpj = ValidacoesUtils.validarCnpjContribuinte('12345678000195');
  if (errorCnpj != null) {
    print('CNPJ inválido: $errorCnpj');
    return;
  }

  // Validar CPF
  final errorCpf = ValidacoesUtils.validarCpf('12345678901');
  if (errorCpf != null) {
    print('CPF inválido: $errorCpf');
    return;
  }

  // Validar período
  final errorPeriodo = ValidacoesUtils.validarAnoMes(202401);
  if (errorPeriodo != null) {
    print('Período inválido: $errorPeriodo');
    return;
  }

  // Validar valor
  final errorValor = ValidacoesUtils.validarValorMonetario(1000.50);
  if (errorValor != null) {
    print('Valor inválido: $errorValor');
    return;
  }

  print('Todos os dados são válidos!');
}
```

### Exemplo de Formatação Completa

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() {
  // Formatar documentos
  final cnpjFormatado = FormatadorUtils.formatCnpj('12345678000195');
  print('CNPJ: $cnpjFormatado'); // 12.345.678/0001-95

  final cpfFormatado = FormatadorUtils.formatCpf('12345678901');
  print('CPF: $cpfFormatado'); // 123.456.789-01

  // Formatar moeda
  final valorFormatado = FormatadorUtils.formatCurrency(1234.56);
  print('Valor: $valorFormatado'); // R$ 1.234,56

  // Formatar data
  final dataFormatada = FormatadorUtils.formatDateFromString('20240115');
  print('Data: $dataFormatada'); // 15/01/2024

  // Formatar período
  final periodoFormatado = FormatadorUtils.formatPeriodFromString('202401');
  print('Período: $periodoFormatado'); // Janeiro/2024
}
```

### Exemplo de Integração com Serviços

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final ccmeiService = CcmeiService(apiClient);
  
  // Validar CNPJ antes de usar
  const cnpj = '12345678000195';
  final errorCnpj = ValidacoesUtils.validarCnpjContribuinte(cnpj);
  
  if (errorCnpj != null) {
    print('CNPJ inválido: $errorCnpj');
    return;
  }
  
  // CNPJ válido, prosseguir
  final response = await ccmeiService.consultarDadosCcmei(cnpj);
  
  if (response.sucesso) {
    // Formatar dados para exibição
    print('=== Dados do MEI ===');
    print('CNPJ: ${FormatadorUtils.formatCnpj(response.dados?.cnpj ?? '')}');
    print('Nome: ${response.dados?.nomeEmpresarial}');
    print('Capital Social: ${FormatadorUtils.formatCurrency(response.dados?.capitalSocial ?? 0)}');
    print('Data Início: ${FormatadorUtils.formatDateFromString(response.dados?.dataInicioAtividades ?? '')}');
    
    // Empresário
    print('Empresário: ${response.dados?.empresario.nomeCivil}');
    print('CPF: ${FormatadorUtils.formatCpf(response.dados?.empresario.cpf ?? '')}');
  }
}
```

## Benefícios dos Utilitários Centralizados

### 1. Consistência
- Todas as validações seguem o mesmo padrão
- Formatação uniforme em todo o sistema
- Mensagens de erro padronizadas

### 2. Reutilização
- Evita duplicação de código
- Facilita manutenção
- Reduz possibilidade de erros

### 3. Documentação
- Anotações `@validacoes_utils` e `@formatador_utils`
- Exemplos de entrada e saída
- Documentação inline completa

### 4. Testabilidade
- Funções puras e testáveis
- Validações isoladas
- Fácil criação de testes unitários

### 5. Manutenibilidade
- Mudanças centralizadas
- Fácil atualização de regras
- Versionamento controlado

## Migração de Código Legado

### Antes (Código Duplicado)
```dart
// Em cada serviço
String? validarCnpj(String? cnpj) {
  if (cnpj == null || cnpj.isEmpty) {
    return 'CNPJ é obrigatório';
  }
  // ... validação específica
}

String formatarCnpj(String cnpj) {
  // ... formatação específica
}
```

### Depois (Código Centralizado)
```dart
// Usar utilitários centralizados
final errorCnpj = ValidacoesUtils.validarCnpjContribuinte(cnpj);
final cnpjFormatado = FormatadorUtils.formatCnpj(cnpj);
```

## Conclusão

Os utilitários centralizados proporcionam:

- **Padronização** de validações e formatações
- **Redução** de código duplicado
- **Facilidade** de manutenção
- **Consistência** em todo o sistema
- **Documentação** completa e exemplos práticos

Esta implementação segue as melhores práticas de desenvolvimento e garante a qualidade e manutenibilidade do código.
