import 'dart:convert';

/// Modelo base de resposta para todos os serviços PGMEI
///
/// Representa a estrutura comum de resposta da API PGMEI
class PgmeiBaseResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  /// É um array composto de Código e texto da mensagem
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno (string JSON escapada)
  final String dados;

  PgmeiBaseResponse({required this.status, required this.mensagens, required this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  /// Parse dos dados JSON retornados
  Map<String, dynamic>? get dadosParsed {
    try {
      if (dados.isEmpty) return null;
      return jsonDecode(dados) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao parsear dados PGMEI: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((m) => m.toJson()).toList(), 'dados': dados};
  }

  factory PgmeiBaseResponse.fromJson(Map<String, dynamic> json) {
    return PgmeiBaseResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m)).toList(),
      dados: json['dados'].toString(),
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// Mensagem de retorno dos serviços PGMEI
class Mensagem {
  /// Código interno do negócio
  final String codigo;

  /// Texto da mensagem
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  @override
  String toString() {
    return '$codigo: $texto';
  }
}
