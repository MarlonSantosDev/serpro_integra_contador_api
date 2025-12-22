import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter indicador de novas mensagens
class IndicadorMensagensResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final DadosIndicadorMensagens? dados;

  IndicadorMensagensResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory IndicadorMensagensResponse.fromJson(Map<String, dynamic> json) {
    final dadosStr = json['dados']?.toString() ?? '';
    DadosIndicadorMensagens? dadosParsed;

    try {
      if (dadosStr.isNotEmpty) {
        final dadosJson = jsonDecode(dadosStr);
        dadosParsed = DadosIndicadorMensagens.fromJson(dadosJson);
      }
    } catch (e) {
      // Se não conseguir parsear, mantém dados como null
    }

    return IndicadorMensagensResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>? ?? [])
          .map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>))
          .toList(),
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
}

/// Dados parseados do campo 'dados' para indicador de mensagens
class DadosIndicadorMensagens {
  final String codigo;
  final List<ConteudoIndicadorMensagens> conteudo;

  DadosIndicadorMensagens({required this.codigo, required this.conteudo});

  factory DadosIndicadorMensagens.fromJson(Map<String, dynamic> json) {
    return DadosIndicadorMensagens(
      codigo: json['codigo'].toString(),
      conteudo: (json['conteudo'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                ConteudoIndicadorMensagens.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'conteudo': conteudo.map((e) => e.toJson()).toList(),
    };
  }
}

/// Conteúdo do indicador de mensagens novas
class ConteudoIndicadorMensagens {
  final String indicadorMensagensNovas;
  final bool temMensagensNovas;
  final StatusMensagensNovas statusMensagensNovas;
  final String descricaoStatus;

  ConteudoIndicadorMensagens({
    required this.indicadorMensagensNovas,
    required this.temMensagensNovas,
    required this.statusMensagensNovas,
    required this.descricaoStatus,
  });

  factory ConteudoIndicadorMensagens.fromJson(Map<String, dynamic> json) {
    final indicador = json['indicadorMensagensNovas']?.toString() ?? '0';

    // Converter valor numérico para descrição descritiva
    final indicadorMensagensNovas = switch (indicador) {
      '0' => 'Contribuinte não possui mensagens novas',
      '1' => 'Contribuinte possui uma mensagem nova',
      '2' => 'Contribuinte possui mensagens novas',
      _ => indicador,
    };

    final status = switch (indicador) {
      '0' => StatusMensagensNovas.semMensagensNovas,
      '1' => StatusMensagensNovas.umaMensagemNova,
      '2' => StatusMensagensNovas.multiplasMensagensNovas,
      _ => StatusMensagensNovas.semMensagensNovas,
    };

    final descricao = switch (status) {
      StatusMensagensNovas.semMensagensNovas =>
        'Contribuinte não possui mensagens novas',
      StatusMensagensNovas.umaMensagemNova =>
        'Contribuinte possui uma mensagem nova',
      StatusMensagensNovas.multiplasMensagensNovas =>
        'Contribuinte possui mensagens novas',
    };

    return ConteudoIndicadorMensagens(
      indicadorMensagensNovas: indicadorMensagensNovas,
      temMensagensNovas: indicador != '0',
      statusMensagensNovas: status,
      descricaoStatus: descricao,
    );
  }

  Map<String, dynamic> toJson() {
    return {'indicadorMensagensNovas': indicadorMensagensNovas};
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
