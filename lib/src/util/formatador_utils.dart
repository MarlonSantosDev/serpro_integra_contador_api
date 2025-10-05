import 'validacoes_utils.dart';

/// Utilitários centralizados para formatação de dados
///
/// Esta classe fornece todas as funcionalidades necessárias para:
/// - Formatação de valores monetários
/// - Formatação de datas e horários
/// - Formatação de documentos (CPF/CNPJ)
/// - Formatação de números
class FormatadorUtils {
  // Padrões regex para formatação
  static final RegExp _currencyRegex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');

  /// @formatador_utils
  ///
  /// Formata um valor monetário para o padrão brasileiro (R$ X.XXX,XX)
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// formatCurrency(1234.56)
  /// formatCurrency(1234.56, includeSymbol: false)
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// 'R$ 1.234,56'
  /// '1.234,56'
  /// ```
  ///
  /// [value] - Valor numérico a ser formatado
  /// [includeSymbol] - Se deve incluir o símbolo R$ (padrão: true)
  static String formatCurrency(double value, {bool includeSymbol = true}) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',').replaceAll(_currencyRegex, r'$1.');
    return includeSymbol ? 'R\$ $formatted' : formatted;
  }

  /// Formata um valor monetário a partir de uma string
  ///
  /// [value] - String contendo o valor numérico
  /// [includeSymbol] - Se deve incluir o símbolo R$ (padrão: true)
  static String formatCurrencyString(String value, {bool includeSymbol = true}) {
    final doubleValue = double.tryParse(value) ?? 0.0;
    return formatCurrency(doubleValue, includeSymbol: includeSymbol);
  }

  /// Formata um número com separadores de milhares
  ///
  /// [value] - Valor numérico
  /// [decimals] - Número de casas decimais (padrão: 2)
  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals).replaceAll(_currencyRegex, r'$1.');
  }

  /// Formata um número inteiro com separadores de milhares
  ///
  /// [value] - Valor inteiro
  static String formatInteger(int value) {
    return value.toString().replaceAll(_currencyRegex, r'$1.');
  }

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

  /// Formata documento automaticamente baseado no tipo detectado
  ///
  /// [document] - Documento sem formatação
  static String formatDocument(String document) {
    final cleanDocument = ValidacoesUtils.cleanDocumentNumber(document);

    if (cleanDocument.length == ValidacoesUtils.tamanhoCpf) {
      return formatCpf(document);
    } else if (cleanDocument.length == ValidacoesUtils.tamanhoCnpj) {
      return formatCnpj(document);
    } else {
      throw ArgumentError('Documento inválido: $document');
    }
  }

  /// @formatador_utils
  ///
  /// Formata data no formato AAAAMMDD para DD/MM/AAAA
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// formatDateFromString('20240315')
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// '15/03/2024'
  /// ```
  ///
  /// [dateString] - Data no formato AAAAMMDD
  ///
  /// Throws [ArgumentError] se não tiver 8 dígitos
  static String formatDateFromString(String dateString) {
    if (dateString.length != 8) {
      throw ArgumentError('Data deve ter 8 dígitos (AAAAMMDD). Recebido: $dateString');
    }

    return '${dateString.substring(6, 8)}/${dateString.substring(4, 6)}/${dateString.substring(0, 4)}';
  }

  /// Formata data no formato AAAAMMDD para AAAA-MM-DD
  ///
  /// [dateString] - Data no formato AAAAMMDD
  static String formatDateFromStringISO(String dateString) {
    if (dateString.length != 8) {
      throw ArgumentError('Data deve ter 8 dígitos (AAAAMMDD). Recebido: $dateString');
    }

    return '${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6, 8)}';
  }

  /// Formata data e hora no formato AAAAMMDDHHMMSS para DD/MM/AAAA HH:MM:SS
  ///
  /// [dateTimeString] - Data e hora no formato AAAAMMDDHHMMSS
  static String formatDateTimeFromString(String dateTimeString) {
    if (dateTimeString.length != 14) {
      throw ArgumentError('Data e hora deve ter 14 dígitos (AAAAMMDDHHMMSS). Recebido: $dateTimeString');
    }

    final date = dateTimeString.substring(0, 8);
    final time = dateTimeString.substring(8, 14);

    return '${date.substring(6, 8)}/${date.substring(4, 6)}/${date.substring(0, 4)} ${time.substring(0, 2)}:${time.substring(2, 4)}:${time.substring(4, 6)}';
  }

  /// Formata data e hora no formato AAAAMMDDHHMMSS para AAAA-MM-DD HH:MM:SS
  ///
  /// [dateTimeString] - Data e hora no formato AAAAMMDDHHMMSS
  static String formatDateTimeFromStringISO(String dateTimeString) {
    if (dateTimeString.length != 14) {
      throw ArgumentError('Data e hora deve ter 14 dígitos (AAAAMMDDHHMMSS). Recebido: $dateTimeString');
    }

    final date = dateTimeString.substring(0, 8);
    final time = dateTimeString.substring(8, 14);

    return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)} ${time.substring(0, 2)}:${time.substring(2, 4)}:${time.substring(4, 6)}';
  }

  /// @formatador_utils
  ///
  /// Formata período no formato AAAAMM para AAAA/MM
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// formatPeriodFromString('202403')
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// '2024/03'
  /// ```
  ///
  /// [periodString] - Período no formato AAAAMM
  ///
  /// Throws [ArgumentError] se não tiver 6 dígitos
  static String formatPeriodFromString(String periodString) {
    if (periodString.length != 6) {
      throw ArgumentError('Período deve ter 6 dígitos (AAAAMM). Recebido: $periodString');
    }

    return '${periodString.substring(0, 4)}/${periodString.substring(4, 6)}';
  }

  /// Formata período no formato AAAAMM para MM/AAAA
  ///
  /// [periodString] - Período no formato AAAAMM
  static String formatPeriodFromStringReverse(String periodString) {
    if (periodString.length != 6) {
      throw ArgumentError('Período deve ter 6 dígitos (AAAAMM). Recebido: $periodString');
    }

    return '${periodString.substring(4, 6)}/${periodString.substring(0, 4)}';
  }

  /// Formata data e hora no formato AAAAMMDDHHMM para AAAA-MM-DD HH:MM
  ///
  /// [dateTimeString] - Data e hora no formato AAAAMMDDHHMM
  static String formatDateTimeShortFromString(String dateTimeString) {
    if (dateTimeString.length != 12) {
      throw ArgumentError('Data e hora deve ter 12 dígitos (AAAAMMDDHHMM). Recebido: $dateTimeString');
    }

    final date = dateTimeString.substring(0, 8);
    final time = dateTimeString.substring(8, 12);

    return '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)} ${time.substring(0, 2)}:${time.substring(2, 4)}';
  }

  /// Formata um DateTime para string no formato DD/MM/AAAA
  ///
  /// [date] - Data a ser formatada
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formata um DateTime para string no formato AAAA-MM-DD
  ///
  /// [date] - Data a ser formatada
  static String formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formata um DateTime para string no formato DD/MM/AAAA HH:MM:SS
  ///
  /// [dateTime] - Data e hora a serem formatadas
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Formata um DateTime para string no formato AAAA-MM-DD HH:MM:SS
  ///
  /// [dateTime] - Data e hora a serem formatadas
  static String formatDateTimeISO(DateTime dateTime) {
    return '${formatDateISO(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Formata um período (ano/mês) para string no formato AAAA/MM
  ///
  /// [year] - Ano
  /// [month] - Mês
  static String formatPeriod(int year, int month) {
    return '$year/${month.toString().padLeft(2, '0')}';
  }

  /// Formata um período (ano/mês) para string no formato MM/AAAA
  ///
  /// [year] - Ano
  /// [month] - Mês
  static String formatPeriodReverse(int year, int month) {
    return '${month.toString().padLeft(2, '0')}/$year';
  }

  // ===== FORMATAÇÕES ESPECÍFICAS PARA DCTFWEB =====

  /// Formata data de apuração no formato legível baseado nos parâmetros fornecidos
  ///
  /// [ano] - Ano com 4 dígitos
  /// [mes] - Mês com 2 dígitos (opcional)
  /// [dia] - Dia com 2 dígitos (opcional)
  static String formatDataApuracao(String ano, String? mes, String? dia) {
    if (mes == null || mes.isEmpty) {
      return ano; // Apenas ano para categorias anuais
    }

    if (dia == null || dia.isEmpty) {
      return '$mes/$ano'; // Mês/Ano para categorias mensais
    }

    return '$dia/$mes/$ano'; // Dia/Mês/Ano para categorias diárias
  }

  /// Converte data DateTime para formato AAAAMMDD
  ///
  /// [data] - Data a ser convertida
  static int converterDataParaAcolhimento(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return int.parse('$ano$mes$dia');
  }

  /// Converte formato AAAAMMDD para DateTime
  ///
  /// [dataAcolhimento] - Data no formato AAAAMMDD
  static DateTime? converterAcolhimentoParaData(int dataAcolhimento) {
    final dataStr = dataAcolhimento.toString();

    if (dataStr.length != 8) return null;

    final ano = int.tryParse(dataStr.substring(0, 4));
    final mes = int.tryParse(dataStr.substring(4, 6));
    final dia = int.tryParse(dataStr.substring(6, 8));

    if (ano == null || mes == null || dia == null) return null;

    try {
      return DateTime(ano, mes, dia);
    } catch (e) {
      return null;
    }
  }
}
