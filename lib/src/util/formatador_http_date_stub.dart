/// Implementação stub para Web - parse manual de HTTP date header
///
/// Esta implementação é usada em Web onde HttpDate não está disponível.
/// Faz parse manual do formato HTTP date (RFC 7231): "Day, DD Mon YYYY HH:MM:SS GMT"
library;

class HttpDateUtils {
  /// Parse manual de string de data HTTP para DateTime
  ///
  /// Suporta o formato padrão: "Sat, 15 Oct 2022 00:00:01 GMT"
  ///
  /// [httpDate] - String no formato HTTP date header
  /// Retorna DateTime ou null se não conseguir fazer parse
  static DateTime? parse(String httpDate) {
    try {
      // Remove espaços extras e normaliza
      final trimmed = httpDate.trim();

      // Formato esperado: "Day, DD Mon YYYY HH:MM:SS GMT"
      // Exemplo: "Sat, 15 Oct 2022 00:00:01 GMT"

      // Divide por vírgula para separar dia da semana
      final parts = trimmed.split(',');
      if (parts.length != 2) return null;

      final dateTimePart = parts[1].trim();

      // Divide por espaços: "15 Oct 2022 00:00:01 GMT"
      final dateTimeElements = dateTimePart.split(' ');
      if (dateTimeElements.length < 6) return null;

      // Remove elementos vazios
      final elements = dateTimeElements.where((e) => e.isNotEmpty).toList();
      if (elements.length < 5) return null;

      final day = int.tryParse(elements[0]);
      final monthStr = elements[1];
      final year = int.tryParse(elements[2]);
      final timeStr = elements[3];
      final timezone = elements[4];

      // Validar timezone (deve ser GMT ou UTC)
      if (timezone != 'GMT' && timezone != 'UTC') return null;

      // Parse time: "HH:MM:SS"
      final timeParts = timeStr.split(':');
      if (timeParts.length != 3) return null;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      final second = int.tryParse(timeParts[2]);

      // Validar valores numéricos básicos
      if (day == null ||
          year == null ||
          hour == null ||
          minute == null ||
          second == null) {
        return null;
      }

      // Validar ranges dos valores
      if (day < 1 || day > 31) return null;
      if (hour < 0 || hour > 23) return null;
      if (minute < 0 || minute > 59) return null;
      if (second < 0 || second > 59) return null;
      if (year < 1900 || year > 2100) return null; // Range razoável

      // Converter mês para número
      final month = _monthNameToNumber(monthStr);
      if (month == null) return null;

      // Validar se o dia é válido para o mês/ano específico
      if (!_isValidDate(year, month, day)) return null;

      // Criar DateTime (HTTP date é sempre UTC)
      // Usar try-catch para capturar datas inválidas que o DateTime possa ajustar automaticamente
      try {
        final dateTime = DateTime.utc(year, month, day, hour, minute, second);

        // Verificar se a data criada é exatamente a mesma que foi solicitada
        // (DateTime pode ajustar automaticamente datas inválidas)
        if (dateTime.year != year ||
            dateTime.month != month ||
            dateTime.day != day ||
            dateTime.hour != hour ||
            dateTime.minute != minute ||
            dateTime.second != second) {
          return null;
        }

        return dateTime;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Converte nome do mês para número (1-12)
  ///
  /// [monthName] - Nome do mês em inglês (3 letras)
  /// Retorna número do mês ou null se inválido
  static int? _monthNameToNumber(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[monthName];
  }

  /// Valida se uma data específica é válida
  ///
  /// [year] - Ano
  /// [month] - Mês (1-12)
  /// [day] - Dia
  /// Retorna true se a data for válida
  static bool _isValidDate(int year, int month, int day) {
    // Dias por mês (não bissexto)
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Verificar fevereiro em ano bissexto
    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return day <= (isLeapYear ? 29 : 28);
    }

    // Verificar outros meses
    return day <= daysInMonth[month - 1];
  }
}
