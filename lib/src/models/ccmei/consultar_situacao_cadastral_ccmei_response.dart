import 'mensagem_ccmei.dart';

class ConsultarSituacaoCadastralCcmeiResponse {
  final int status;
  final List<MensagemCcmei> mensagens;
  final List<CcmeiSituacaoCadastral> dados;

  ConsultarSituacaoCadastralCcmeiResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarSituacaoCadastralCcmeiResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarSituacaoCadastralCcmeiResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((e) => MensagemCcmei.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: (json['dados'] as List<dynamic>)
          .map(
            (e) => CcmeiSituacaoCadastral.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.map((e) => e.toJson()).toList(),
    };
  }
}

class CcmeiSituacaoCadastral {
  final String cnpj;
  final String situacao;
  final bool enquadradoMei;

  CcmeiSituacaoCadastral({
    required this.cnpj,
    required this.situacao,
    required this.enquadradoMei,
  });

  factory CcmeiSituacaoCadastral.fromJson(Map<String, dynamic> json) {
    return CcmeiSituacaoCadastral(
      cnpj: json['cnpj'].toString(),
      situacao: json['situacao'].toString(),
      enquadradoMei: json['enquadradoMei'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'cnpj': cnpj, 'situacao': situacao, 'enquadradoMei': enquadradoMei};
  }
}
