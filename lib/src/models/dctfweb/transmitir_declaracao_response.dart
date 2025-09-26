import 'dart:convert';
import 'dctfweb_common.dart';

/// Response para transmissão de declaração DCTFWeb
class TransmitirDeclaracaoDctfResponse {
  final String status;
  final String dados;
  final List<MensagemDctf> mensagens;

  TransmitirDeclaracaoDctfResponse({
    required this.status,
    required this.dados,
    required this.mensagens,
  });

  factory TransmitirDeclaracaoDctfResponse.fromJson(Map<String, dynamic> json) {
    return TransmitirDeclaracaoDctfResponse(
      status: json['status']?.toString() ?? '',
      dados: json['dados']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((m) => MensagemDctf.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Obtém informações da transmissão do campo dados
  TransmissaoInfo? get infoTransmissao {
    try {
      if (dados.isEmpty) return null;

      final dadosJson = Map<String, dynamic>.from(jsonDecode(dados) as Map);

      return TransmissaoInfo.fromJson(dadosJson);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a transmissão foi bem-sucedida
  bool get sucesso => status == '200' && mensagens.any((m) => m.isSucesso);

  /// Verifica se houve aplicação de MAED (Multa por Atraso)
  bool get temMaed => mensagens.any(
    (m) =>
        m.codigo == 'TRANS14' ||
        m.texto.toLowerCase().contains('maed') ||
        m.texto.toLowerCase().contains('multa por atraso'),
  );

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

/// Informações da transmissão extraídas do campo dados
class TransmissaoInfo {
  final String? numeroRecibo;
  final String? dataTransmissao;
  final String? horaTransmissao;
  final String? situacao;

  TransmissaoInfo({
    this.numeroRecibo,
    this.dataTransmissao,
    this.horaTransmissao,
    this.situacao,
  });

  factory TransmissaoInfo.fromJson(Map<String, dynamic> json) {
    return TransmissaoInfo(
      numeroRecibo: json['numeroRecibo']?.toString(),
      dataTransmissao: json['dataTransmissao']?.toString(),
      horaTransmissao: json['horaTransmissao']?.toString(),
      situacao: json['situacao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroRecibo': numeroRecibo,
      'dataTransmissao': dataTransmissao,
      'horaTransmissao': horaTransmissao,
      'situacao': situacao,
    };
  }
}
