import 'dart:convert';

/// Request para obter procurações eletrônicas
class ObterProcuracaoRequest {
  final String outorgante;
  final String tipoOutorgante;
  final String outorgado;
  final String tipoOutorgado;

  ObterProcuracaoRequest({required this.outorgante, required this.tipoOutorgante, required this.outorgado, required this.tipoOutorgado});

  /// Cria request a partir de CPF/CNPJ
  factory ObterProcuracaoRequest.fromDocuments({required String outorgante, required String outorgado}) {
    return ObterProcuracaoRequest(
      outorgante: outorgante,
      tipoOutorgante: _detectDocumentType(outorgante),
      outorgado: outorgado,
      tipoOutorgado: _detectDocumentType(outorgado),
    );
  }

  /// Detecta o tipo de documento (1=CPF, 2=CNPJ)
  static String _detectDocumentType(String document) {
    final cleaned = document.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 11 ? '1' : '2';
  }

  /// Valida os dados da requisição
  List<String> validate() {
    final errors = <String>[];

    // Validar outorgante
    if (outorgante.isEmpty) {
      errors.add('Outorgante é obrigatório');
    } else {
      final cleanedOutorgante = outorgante.replaceAll(RegExp(r'[^0-9]'), '');
      if (tipoOutorgante == '1' && cleanedOutorgante.length != 11) {
        errors.add('CPF do outorgante deve ter 11 dígitos');
      } else if (tipoOutorgante == '2' && cleanedOutorgante.length != 14) {
        errors.add('CNPJ do outorgante deve ter 14 dígitos');
      }
    }

    // Validar outorgado
    if (outorgado.isEmpty) {
      errors.add('Outorgado é obrigatório');
    } else {
      final cleanedOutorgado = outorgado.replaceAll(RegExp(r'[^0-9]'), '');
      if (tipoOutorgado == '1' && cleanedOutorgado.length != 11) {
        errors.add('CPF do outorgado deve ter 11 dígitos');
      } else if (tipoOutorgado == '2' && cleanedOutorgado.length != 14) {
        errors.add('CNPJ do outorgado deve ter 14 dígitos');
      }
    }

    // Validar tipos
    if (tipoOutorgante != '1' && tipoOutorgante != '2') {
      errors.add('Tipo do outorgante deve ser 1 (CPF) ou 2 (CNPJ)');
    }

    if (tipoOutorgado != '1' && tipoOutorgado != '2') {
      errors.add('Tipo do outorgado deve ser 1 (CPF) ou 2 (CNPJ)');
    }

    return errors;
  }

  /// Converte para JSON string para envio na API
  String toJsonString() {
    final data = {'outorgante': outorgante, 'tipoOutorgante': tipoOutorgante, 'outorgado': outorgado, 'tipoOutorgado': tipoOutorgado};
    return jsonEncode(data);
  }

  /// Converte para Map
  Map<String, dynamic> toJson() {
    return {'outorgante': outorgante, 'tipoOutorgante': tipoOutorgante, 'outorgado': outorgado, 'tipoOutorgado': tipoOutorgado};
  }

  /// Cria a partir de JSON
  factory ObterProcuracaoRequest.fromJson(Map<String, dynamic> json) {
    return ObterProcuracaoRequest(
      outorgante: json['outorgante'] as String,
      tipoOutorgante: json['tipoOutorgante'] as String,
      outorgado: json['outorgado'] as String,
      tipoOutorgado: json['tipoOutorgado'] as String,
    );
  }

  @override
  String toString() {
    return 'ObterProcuracaoRequest(outorgante: $outorgante, tipoOutorgante: $tipoOutorgante, outorgado: $outorgado, tipoOutorgado: $tipoOutorgado)';
  }
}
