import 'dart:convert';

/// Modelo de resposta para consolidar e gerar DARF (CONSOLIDARGERARDARF51)
class ConsolidarDarfResponse {
  final int status;
  final List<String> mensagens;
  final ConsolidarDarfDados? dados;

  ConsolidarDarfResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory ConsolidarDarfResponse.fromJson(Map<String, dynamic> json) {
    ConsolidarDarfDados? dadosParsed;

    if (json['dados'] != null) {
      try {
        // Se dados é uma string JSON, fazer parse
        if (json['dados'] is String) {
          final dadosJson =
              jsonDecode(json['dados'].toString()) as Map<String, dynamic>;
          dadosParsed = ConsolidarDarfDados.fromJson(dadosJson);
        } else if (json['dados'] is Map<String, dynamic>) {
          dadosParsed = ConsolidarDarfDados.fromJson(
            json['dados'] as Map<String, dynamic>,
          );
        }
      } catch (e) {
        // Se falhar o parse, dadosParsed fica null
      }
    }

    return ConsolidarDarfResponse(
      status: int.parse(json['status'].toString()),
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados?.toJson()};
  }

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200 && dados != null;

  /// Retorna a mensagem principal (primeira mensagem)
  String get mensagemPrincipal => mensagens.isNotEmpty ? mensagens.first : '';

  /// Indica se há PDF disponível
  bool get temPdf => dados?.darf != null && dados!.darf!.isNotEmpty;

  /// Retorna o tamanho do PDF em bytes (aproximado)
  int get tamanhoPdfBytes {
    if (!temPdf) return 0;
    return dados!.darf!.length * 3 ~/ 4; // Aproximação para Base64
  }

  /// Retorna o tamanho do PDF formatado
  String get tamanhoPdfFormatado {
    final bytes = tamanhoPdfBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'ConsolidarDarfResponse(status: $status, sucesso: $sucesso, temPdf: $temPdf)';
  }
}

/// Dados retornados pela consolidação e geração de DARF
class ConsolidarDarfDados {
  final String valorPrincipalMoedaCorrente;
  final String valorTotalConsolidado;
  final String valorMultaMora;
  final double percentualMultaMora;
  final String valorJuros;
  final double percentualJuros;
  final String termoInicialJuros;
  final String dataArrecadacaoConsolidacao;
  final String dataValidadeCalculo;
  final String? darf;
  final int numeroDocumento;

  ConsolidarDarfDados({
    required this.valorPrincipalMoedaCorrente,
    required this.valorTotalConsolidado,
    required this.valorMultaMora,
    required this.percentualMultaMora,
    required this.valorJuros,
    required this.percentualJuros,
    required this.termoInicialJuros,
    required this.dataArrecadacaoConsolidacao,
    required this.dataValidadeCalculo,
    this.darf,
    required this.numeroDocumento,
  });

  factory ConsolidarDarfDados.fromJson(Map<String, dynamic> json) {
    return ConsolidarDarfDados(
      valorPrincipalMoedaCorrente:
          json['valorPrincipalMoedaCorrente']?.toString() ?? '',
      valorTotalConsolidado: json['valorTotalConsolidado']?.toString() ?? '',
      valorMultaMora: json['valorMultaMora']?.toString() ?? '',
      percentualMultaMora: (num.parse(
        json['percentualMultaMora'].toString(),
      )).toDouble(),
      valorJuros: json['valorJuros']?.toString() ?? '',
      percentualJuros: (num.parse(
        json['percentualJuros'].toString(),
      )).toDouble(),
      termoInicialJuros: json['termoInicialJuros']?.toString() ?? '',
      dataArrecadacaoConsolidacao:
          json['dataArrecadacaoConsolidacao']?.toString() ?? '',
      dataValidadeCalculo: json['dataValidadeCalculo']?.toString() ?? '',
      darf: json['darf']?.toString(),
      numeroDocumento: int.parse(json['numeroDocumento'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorPrincipalMoedaCorrente': valorPrincipalMoedaCorrente,
      'valorTotalConsolidado': valorTotalConsolidado,
      'valorMultaMora': valorMultaMora,
      'percentualMultaMora': percentualMultaMora,
      'valorJuros': valorJuros,
      'percentualJuros': percentualJuros,
      'termoInicialJuros': termoInicialJuros,
      'dataArrecadacaoConsolidacao': dataArrecadacaoConsolidacao,
      'dataValidadeCalculo': dataValidadeCalculo,
      'darf': darf,
      'numeroDocumento': numeroDocumento,
    };
  }

  /// Converte valor string para double
  double get valorPrincipalDouble {
    try {
      return double.parse(valorPrincipalMoedaCorrente.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  /// Converte valor string para double
  double get valorTotalDouble {
    try {
      return double.parse(valorTotalConsolidado.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  /// Converte valor string para double
  double get valorMultaDouble {
    try {
      return double.parse(valorMultaMora.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  /// Converte valor string para double
  double get valorJurosDouble {
    try {
      return double.parse(valorJuros.replaceAll(',', '.'));
    } catch (e) {
      return 0.0;
    }
  }

  /// Formata valor monetário
  String formatarValor(String valor) {
    try {
      final doubleValor = double.parse(valor.replaceAll(',', '.'));
      return 'R\$ ${doubleValor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return valor;
    }
  }

  /// Retorna valor principal formatado
  String get valorPrincipalFormatado =>
      formatarValor(valorPrincipalMoedaCorrente);

  /// Retorna valor total formatado
  String get valorTotalFormatado => formatarValor(valorTotalConsolidado);

  /// Retorna valor multa formatado
  String get valorMultaFormatado => formatarValor(valorMultaMora);

  /// Retorna valor juros formatado
  String get valorJurosFormatado => formatarValor(valorJuros);

  @override
  String toString() {
    return 'ConsolidarDarfDados(numeroDocumento: $numeroDocumento, valorTotal: $valorTotalFormatado)';
  }
}
