import 'dart:convert';

/// Modelo de resposta para gerar código de barras de DARF calculado (GERARDARFCODBARRA53)
class GerarCodigoBarrasResponse {
  final int status;
  final List<String> mensagens;
  final GerarCodigoBarrasDados? dados;

  GerarCodigoBarrasResponse({required this.status, required this.mensagens, this.dados});

  factory GerarCodigoBarrasResponse.fromJson(Map<String, dynamic> json) {
    GerarCodigoBarrasDados? dadosParsed;

    if (json['dados'] != null) {
      try {
        // Se dados é uma string JSON, fazer parse
        if (json['dados'] is String) {
          final dadosJson = jsonDecode(json['dados'] as String) as Map<String, dynamic>;
          dadosParsed = GerarCodigoBarrasDados.fromJson(dadosJson);
        } else if (json['dados'] is Map<String, dynamic>) {
          dadosParsed = GerarCodigoBarrasDados.fromJson(json['dados'] as Map<String, dynamic>);
        }
      } catch (e) {
        // Se falhar o parse, dadosParsed fica null
      }
    }

    return GerarCodigoBarrasResponse(
      status: json['status'] as int? ?? 0,
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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

  /// Indica se há código de barras disponível
  bool get temCodigoBarras => dados?.codigoBarras != null && dados!.codigoBarras!.isNotEmpty;

  /// Retorna o tamanho do código de barras em bytes (aproximado)
  int get tamanhoCodigoBarrasBytes {
    if (!temCodigoBarras) return 0;
    return dados!.codigoBarras!.length * 3 ~/ 4; // Aproximação para Base64
  }

  /// Retorna o tamanho do código de barras formatado
  String get tamanhoCodigoBarrasFormatado {
    final bytes = tamanhoCodigoBarrasBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'GerarCodigoBarrasResponse(status: $status, sucesso: $sucesso, temCodigoBarras: $temCodigoBarras)';
  }
}

/// Dados retornados pela geração de código de barras
class GerarCodigoBarrasDados {
  final int numeroDocumento;
  final String? codigoBarras;
  final String? linhaDigitavel;
  final String? qrCode;
  final String? dataGeracao;
  final String? dataValidade;

  GerarCodigoBarrasDados({required this.numeroDocumento, this.codigoBarras, this.linhaDigitavel, this.qrCode, this.dataGeracao, this.dataValidade});

  factory GerarCodigoBarrasDados.fromJson(Map<String, dynamic> json) {
    return GerarCodigoBarrasDados(
      numeroDocumento: json['numeroDocumento'] as int? ?? 0,
      codigoBarras: json['codigoBarras'] as String?,
      linhaDigitavel: json['linhaDigitavel'] as String?,
      qrCode: json['qrCode'] as String?,
      dataGeracao: json['dataGeracao'] as String?,
      dataValidade: json['dataValidade'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDocumento': numeroDocumento,
      'codigoBarras': codigoBarras,
      'linhaDigitavel': linhaDigitavel,
      'qrCode': qrCode,
      'dataGeracao': dataGeracao,
      'dataValidade': dataValidade,
    };
  }

  /// Indica se há linha digitável disponível
  bool get temLinhaDigitavel => linhaDigitavel != null && linhaDigitavel!.isNotEmpty;

  /// Indica se há QR Code disponível
  bool get temQrCode => qrCode != null && qrCode!.isNotEmpty;

  /// Retorna informações do código de barras
  Map<String, dynamic> get infoCodigoBarras {
    return {
      'disponivel': temCodigoBarras,
      'tamanho_caracteres': codigoBarras?.length ?? 0,
      'tamanho_bytes_aproximado': tamanhoCodigoBarrasBytes,
      'tem_linha_digitavel': temLinhaDigitavel,
      'tem_qr_code': temQrCode,
      'preview': codigoBarras?.substring(0, codigoBarras!.length > 50 ? 50 : codigoBarras!.length) ?? '',
    };
  }

  /// Retorna o tamanho do código de barras em bytes (aproximado)
  int get tamanhoCodigoBarrasBytes {
    if (!temCodigoBarras) return 0;
    return codigoBarras!.length * 3 ~/ 4; // Aproximação para Base64
  }

  /// Indica se há código de barras disponível
  bool get temCodigoBarras => codigoBarras != null && codigoBarras!.isNotEmpty;

  /// Formata data de geração
  String get dataGeracaoFormatada {
    if (dataGeracao == null) return 'Não disponível';
    try {
      final data = DateTime.parse(dataGeracao!);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataGeracao!;
    }
  }

  /// Formata data de validade
  String get dataValidadeFormatada {
    if (dataValidade == null) return 'Não disponível';
    try {
      final data = DateTime.parse(dataValidade!);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } catch (e) {
      return dataValidade!;
    }
  }

  /// Indica se o código de barras está válido
  bool get isValido {
    if (!temCodigoBarras) return false;
    if (dataValidade == null) return true; // Se não há data de validade, considera válido

    try {
      final dataValidadeParsed = DateTime.parse(dataValidade!);
      return DateTime.now().isBefore(dataValidadeParsed);
    } catch (e) {
      return true; // Se não conseguir fazer parse, considera válido
    }
  }

  @override
  String toString() {
    return 'GerarCodigoBarrasDados(numeroDocumento: $numeroDocumento, temCodigoBarras: $temCodigoBarras, temLinhaDigitavel: $temLinhaDigitavel)';
  }
}
