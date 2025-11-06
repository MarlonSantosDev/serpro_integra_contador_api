import 'dart:convert';
import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final DasData? dados;

  EmitirDasResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    DasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        // Se dadosJson já é um JSON válido, usa diretamente
        if (dadosStr.startsWith('{')) {
          final Map<String, dynamic> jsonMap = jsonDecode(dadosStr);
          dadosParsed = DasData(docArrecadacaoPdfB64: jsonMap['docArrecadacaoPdfB64']?.toString() ?? '');
        } else {
          // Caso contrário, tenta parsear como string
          final dadosJson = jsonDecode(dadosStr) as Map<String, dynamic>;
          dadosParsed = DasData.fromJson(dadosJson);
        }
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return EmitirDasResponse(
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get sucesso => status == '200';

  /// Retorna os dados parseados como objeto DAS
  DasData? get dasGerado {
    return dados;
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(Map<String, dynamic> json) {
    return DasData(
      docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }
}

