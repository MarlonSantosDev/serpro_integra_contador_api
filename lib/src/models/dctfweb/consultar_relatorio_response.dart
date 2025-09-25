import 'dart:convert';
import 'dctfweb_common.dart';

/// Response para consulta de relatórios (Recibo e Declaração Completa)
class ConsultarRelatorioResponse {
  final String status;
  final String dados;
  final List<MensagemDctf> mensagens;

  ConsultarRelatorioResponse({required this.status, required this.dados, required this.mensagens});

  factory ConsultarRelatorioResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarRelatorioResponse(
      status: json['status']?.toString() ?? '',
      dados: json['dados']?.toString() ?? '',
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((m) => MensagemDctf.fromJson(m as Map<String, dynamic>)).toList() ?? [],
    );
  }

  /// Obtém o PDF em Base64 do campo dados
  String? get pdfBase64 {
    try {
      if (dados.isEmpty) return null;

      final dadosJson = Map<String, dynamic>.from(jsonDecode(dados) as Map);

      return dadosJson['PDFByteArrayBase64'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a operação foi bem-sucedida
  bool get sucesso => status == '200' && pdfBase64 != null;

  /// Obtém o tamanho estimado do PDF em bytes
  int? get tamanhoPdfBytes {
    final pdf = pdfBase64;
    if (pdf == null) return null;

    // Base64 tem overhead de ~33%, então dividimos por 1.33
    return (pdf.length / 1.33).round();
  }

  /// Obtém mensagem de erro principal, se houver
  String? get mensagemErro {
    final erro = mensagens.where((m) => m.isErro).firstOrNull;
    return erro?.texto;
  }

  /// Obtém todas as mensagens de sucesso
  List<MensagemDctf> get mensagensSucesso => mensagens.where((m) => m.isSucesso).toList();

  /// Obtém todas as mensagens de erro
  List<MensagemDctf> get mensagensErro => mensagens.where((m) => m.isErro).toList();

  Map<String, dynamic> toJson() {
    return {'status': status, 'dados': dados, 'mensagens': mensagens.map((m) => m.toJson()).toList()};
  }
}
