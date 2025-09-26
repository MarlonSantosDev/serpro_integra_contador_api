import 'dart:convert';
import 'dctfweb_common.dart';

/// Response para consulta/geração de XML da declaração
class ConsultarXmlResponse {
  final String status;
  final String dados;
  final List<MensagemDctf> mensagens;

  ConsultarXmlResponse({
    required this.status,
    required this.dados,
    required this.mensagens,
  });

  factory ConsultarXmlResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarXmlResponse(
      status: json['status']?.toString() ?? '',
      dados: json['dados']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((m) => MensagemDctf.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Obtém o XML em Base64 do campo dados
  String? get xmlBase64 {
    try {
      if (dados.isEmpty) return null;

      final dadosJson = Map<String, dynamic>.from(jsonDecode(dados) as Map);

      return dadosJson['XMLStringBase64'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a operação foi bem-sucedida
  bool get sucesso => status == '200' && xmlBase64 != null;

  /// Obtém mensagem de erro principal, se houver
  String? get mensagemErro {
    final erro = mensagens.where((m) => m.isErro).firstOrNull;
    return erro?.texto;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'dados': dados,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
    };
  }
}
