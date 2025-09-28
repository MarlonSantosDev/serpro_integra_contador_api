import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  EmitirDasResponse({required this.status, required this.mensagens, required this.dados});

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    return EmitirDasResponse(
      status: json['status']?.toString() ?? '',
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Retorna os dados parseados como objeto DAS
  DasGerado? get dasGerado {
    try {
      if (dados.isEmpty) return null;

      // Em implementação real, seria feito parsing do JSON string
      // Por enquanto retornamos null - seria implementado com dart:convert
      return null;
    } catch (e) {
      return null;
    }
  }
}

class DasGerado {
  final String docArrecadacaoPdfB64;

  DasGerado({required this.docArrecadacaoPdfB64});

  factory DasGerado.fromJson(Map<String, dynamic> json) {
    return DasGerado(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }
}
