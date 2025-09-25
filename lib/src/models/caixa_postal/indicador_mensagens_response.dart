import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter indicador de novas mensagens
class IndicadorMensagensResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String dados;
  final DadosIndicadorMensagens? dadosParsed;

  IndicadorMensagensResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  factory IndicadorMensagensResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'].toString();
    DadosIndicadorMensagens? dadosParsed;

    try {
      final dadosJson = jsonDecode(dados);
      dadosParsed = DadosIndicadorMensagens.fromJson(dadosJson);
    } catch (e) {
      // Se não conseguir parsear, mantém dados como string
    }

    return IndicadorMensagensResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>? ?? []).map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dados,
      dadosParsed: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }
}

/// Dados parseados do campo 'dados' para indicador de mensagens
class DadosIndicadorMensagens {
  final String codigo;
  final List<ConteudoIndicadorMensagens> conteudo;

  DadosIndicadorMensagens({required this.codigo, required this.conteudo});

  factory DadosIndicadorMensagens.fromJson(Map<String, dynamic> json) {
    return DadosIndicadorMensagens(
      codigo: json['codigo'] as String,
      conteudo: (json['conteudo'] as List<dynamic>? ?? []).map((e) => ConteudoIndicadorMensagens.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'conteudo': conteudo.map((e) => e.toJson()).toList()};
  }
}

/// Conteúdo do indicador de mensagens novas
class ConteudoIndicadorMensagens {
  final String indicadorMensagensNovas;

  ConteudoIndicadorMensagens({required this.indicadorMensagensNovas});

  factory ConteudoIndicadorMensagens.fromJson(Map<String, dynamic> json) {
    return ConteudoIndicadorMensagens(indicadorMensagensNovas: json['indicadorMensagensNovas'] as String? ?? '0');
  }

  Map<String, dynamic> toJson() {
    return {'indicadorMensagensNovas': indicadorMensagensNovas};
  }

  /// Obtém o status das mensagens novas
  StatusMensagensNovas get statusMensagensNovas {
    switch (indicadorMensagensNovas) {
      case '0':
        return StatusMensagensNovas.semMensagensNovas;
      case '1':
        return StatusMensagensNovas.umaMensagemNova;
      case '2':
        return StatusMensagensNovas.multiplasMensagensNovas;
      default:
        return StatusMensagensNovas.semMensagensNovas;
    }
  }

  /// Verifica se há mensagens novas
  bool get temMensagensNovas => indicadorMensagensNovas != '0';

  /// Obtém descrição do status
  String get descricaoStatus {
    switch (statusMensagensNovas) {
      case StatusMensagensNovas.semMensagensNovas:
        return 'Contribuinte não possui mensagens novas';
      case StatusMensagensNovas.umaMensagemNova:
        return 'Contribuinte possui uma mensagem nova';
      case StatusMensagensNovas.multiplasMensagensNovas:
        return 'Contribuinte possui mensagens novas';
    }
  }
}

/// Enum para status de mensagens novas
enum StatusMensagensNovas {
  /// 0 – Contribuinte não possui mensagens novas
  semMensagensNovas,

  /// 1 – Contribuinte possui uma mensagem nova
  umaMensagemNova,

  /// 2 – Contribuinte possui mensagens novas
  multiplasMensagensNovas,
}
