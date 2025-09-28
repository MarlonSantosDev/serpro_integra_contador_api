import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter procurações eletrônicas
class ObterProcuracaoResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String dados;
  final List<Procuracao>? dadosParsed;

  ObterProcuracaoResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Indica se a requisição foi bem-sucedida
  bool get sucesso => status == 200;

  /// Retorna a mensagem principal (primeira mensagem)
  String get mensagemPrincipal => mensagens.isNotEmpty ? mensagens.first.texto : '';

  /// Retorna o código da mensagem principal
  String get codigoMensagem => mensagens.isNotEmpty ? mensagens.first.codigo : '';

  factory ObterProcuracaoResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'].toString();
    List<Procuracao>? dadosParsed;

    try {
      if (dados.isNotEmpty) {
        final dadosJson = jsonDecode(dados) as List<dynamic>;
        dadosParsed = dadosJson.map((e) => Procuracao.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Se não conseguir parsear, mantém dados como string
    }

    return ObterProcuracaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>? ?? []).map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dados,
      dadosParsed: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }
}

/// Modelo de uma procuração eletrônica
class Procuracao {
  final String dtexpiracao;
  final int nrsistemas;
  final List<String> sistemas;

  Procuracao({required this.dtexpiracao, required this.nrsistemas, required this.sistemas});

  /// Data de expiração formatada (aaaa-MM-dd)
  String get dataExpiracaoFormatada {
    if (dtexpiracao.length == 8) {
      final ano = dtexpiracao.substring(0, 4);
      final mes = dtexpiracao.substring(4, 6);
      final dia = dtexpiracao.substring(6, 8);
      return '$ano-$mes-$dia';
    }
    return dtexpiracao;
  }

  /// Indica se a procuração está expirada
  bool get isExpirada {
    if (dtexpiracao.length == 8) {
      final ano = int.parse(dtexpiracao.substring(0, 4));
      final mes = int.parse(dtexpiracao.substring(4, 6));
      final dia = int.parse(dtexpiracao.substring(6, 8));
      final dataExpiracao = DateTime(ano, mes, dia);
      return DateTime.now().isAfter(dataExpiracao);
    }
    return false;
  }

  /// Indica se a procuração expira em breve (próximos 30 dias)
  bool get expiraEmBreve {
    if (dtexpiracao.length == 8) {
      final ano = int.parse(dtexpiracao.substring(0, 4));
      final mes = int.parse(dtexpiracao.substring(4, 6));
      final dia = int.parse(dtexpiracao.substring(6, 8));
      final dataExpiracao = DateTime(ano, mes, dia);
      final agora = DateTime.now();
      final diferenca = dataExpiracao.difference(agora).inDays;
      return diferenca <= 30 && diferenca >= 0;
    }
    return false;
  }

  /// Lista de sistemas formatada
  String get sistemasFormatados => sistemas.join(', ');

  factory Procuracao.fromJson(Map<String, dynamic> json) {
    return Procuracao(
      dtexpiracao: json['dtexpiracao'].toString(),
      nrsistemas: int.parse(json['nrsistemas'].toString()),
      sistemas: (json['sistemas'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'dtexpiracao': dtexpiracao, 'nrsistemas': nrsistemas, 'sistemas': sistemas};
  }

  @override
  String toString() {
    return 'Procuracao(dtexpiracao: $dtexpiracao, nrsistemas: $nrsistemas, sistemas: $sistemas)';
  }
}
