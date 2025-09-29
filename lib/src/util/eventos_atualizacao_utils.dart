/// Utilitários para validação de eventos de atualização
class EventosAtualizacaoUtils {
  /// Valida formato de data AAAAMMDD
  static void validarData(String data) {
    if (data.isEmpty) {
      throw Exception('Data não pode estar vazia');
    }

    if (data.length != 8) {
      throw Exception('Data deve estar no formato AAAAMMDD');
    }

    final ano = int.tryParse(data.substring(0, 4));
    final mes = int.tryParse(data.substring(4, 6));
    final dia = int.tryParse(data.substring(6, 8));

    if (ano == null || mes == null || dia == null) {
      throw Exception('Data deve conter apenas números');
    }

    if (ano < 2000 || ano > 2100) {
      throw Exception('Ano deve estar entre 2000 e 2100');
    }

    if (mes < 1 || mes > 12) {
      throw Exception('Mês deve estar entre 01 e 12');
    }

    if (dia < 1 || dia > 31) {
      throw Exception('Dia deve estar entre 01 e 31');
    }

    // Validação básica de dias por mês
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (mes == 2 && _isLeapYear(ano)) {
      if (dia > 29) {
        throw Exception('Dia inválido para fevereiro em ano bissexto');
      }
    } else if (dia > daysInMonth[mes - 1]) {
      throw Exception('Dia inválido para o mês informado');
    }
  }

  /// Valida período de datas
  static void validarPeriodo(String dataInicial, String dataFinal) {
    validarData(dataInicial);
    validarData(dataFinal);

    if (dataInicial.compareTo(dataFinal) > 0) {
      throw Exception('Data inicial deve ser anterior à data final');
    }

    // Validar se o período não é muito longo (máximo 1 ano)
    final inicialDateTime = _parseDate(dataInicial);
    final finalDateTime = _parseDate(dataFinal);

    if (finalDateTime.difference(inicialDateTime).inDays > 365) {
      throw Exception('Período máximo permitido é de 1 ano');
    }
  }

  /// Valida protocolo (deve ser UUID)
  static void validarProtocolo(String protocolo) {
    if (protocolo.isEmpty) {
      throw Exception('Protocolo não pode estar vazio');
    }

    // Protocolo deve ser um UUID válido
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

    if (!uuidRegex.hasMatch(protocolo)) {
      throw Exception('Protocolo deve ser um UUID válido');
    }
  }

  /// Verifica se o ano é bissexto
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Converte string de data AAAAMMDD para DateTime
  static DateTime _parseDate(String data) {
    final ano = int.parse(data.substring(0, 4));
    final mes = int.parse(data.substring(4, 6));
    final dia = int.parse(data.substring(6, 8));
    return DateTime(ano, mes, dia);
  }
}
