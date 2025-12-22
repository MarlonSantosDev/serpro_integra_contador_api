import 'dart:io';

/// Implementação nativa para Desktop/Mobile - usa HttpDate do dart:io
///
/// Esta implementação é usada em plataformas onde dart:io está disponível,
/// utilizando a implementação nativa do Dart para parse de HTTP date headers.

class HttpDateUtils {
  /// Parse de string de data HTTP usando HttpDate do dart:io
  ///
  /// [httpDate] - String no formato HTTP date header
  /// Retorna DateTime ou null se não conseguir fazer parse
  static DateTime? parse(String httpDate) {
    try {
      // Primeiro validar se a string representa uma data válida
      // (HttpDate.parse pode ajustar automaticamente datas inválidas)
      if (!_isValidHttpDateString(httpDate)) {
        return null;
      }

      return HttpDate.parse(httpDate);
    } catch (e) {
      return null;
    }
  }

  /// Valida se a string HTTP date representa uma data válida
  /// (evita ajustes automáticos do HttpDate.parse)
  static bool _isValidHttpDateString(String httpDate) {
    try {
      // Formato esperado: "Day, DD Mon YYYY HH:MM:SS GMT"
      final trimmed = httpDate.trim();
      final parts = trimmed.split(',');
      if (parts.length != 2) return false;

      final dateTimePart = parts[1].trim();
      final elements = dateTimePart
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toList();
      if (elements.length < 5) return false;

      final day = int.tryParse(elements[0]);
      final monthStr = elements[1];
      final year = int.tryParse(elements[2]);
      final timeStr = elements[3];
      final timezone = elements[4];

      // Validar timezone
      if (timezone != 'GMT' && timezone != 'UTC') return false;

      // Validar valores numéricos
      if (day == null || year == null) return false;
      if (day < 1 || day > 31) return false;
      if (year < 1900 || year > 2100) return false;

      // Validar hora
      final timeParts = timeStr.split(':');
      if (timeParts.length != 3) return false;
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      final second = int.tryParse(timeParts[2]);
      if (hour == null || minute == null || second == null) return false;
      if (hour < 0 || hour > 23) return false;
      if (minute < 0 || minute > 59) return false;
      if (second < 0 || second > 59) return false;

      // Validar mês
      final month = _monthNameToNumber(monthStr);
      if (month == null) return false;

      // Validar se o dia é válido para o mês/ano
      return _isValidDate(year, month, day);
    } catch (e) {
      return false;
    }
  }

  /// Converte nome do mês para número (1-12)
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
  static bool _isValidDate(int year, int month, int day) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return day <= (isLeapYear ? 29 : 28);
    }

    return day <= daysInMonth[month - 1];
  }
}
