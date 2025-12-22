import 'dart:convert';

/// Modelo de resposta para consultar extrato do DAS PGDASD
///
/// Representa a resposta do serviço CONSEXTRATO16
class ConsultarExtratoDasResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagem explicativa retornada no acionamento do serviço
  final List<Mensagem> mensagens;

  /// Estrutura de dados de retorno, contendo uma lista em SCAPED Texto JSON com o objeto ExtratoDas
  final ExtratoDas dados;

  ConsultarExtratoDasResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      'dados': dados,
    };
  }

  factory ConsultarExtratoDasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarExtratoDasResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((m) => Mensagem.fromJson(m))
          .toList(),
      dados: ExtratoDas.fromJson(jsonDecode(json['dados'])),
    );
  }
}

/// Mensagem de retorno
class Mensagem {
  /// Código da mensagem
  final String codigo;

  /// Texto da mensagem
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo'].toString(),
      texto: json['texto'].toString(),
    );
  }
}

/// Extrato do DAS
class ExtratoDas {
  /// Número do DAS
  final String numeroDas;

  /// CNPJ completo sem formatação
  final Extrato extrato;

  ExtratoDas({required this.numeroDas, required this.extrato});

  Map<String, dynamic> toJson() {
    return {'numeroDas': numeroDas, 'extrato': extrato.toJson()};
  }

  factory ExtratoDas.fromJson(Map<String, dynamic> json) {
    return ExtratoDas(
      numeroDas: json['numeroDas'].toString(),
      extrato: Extrato.fromJson(json['extrato']),
    );
  }
}

class Extrato {
  final String nomeArquivo;
  final String pdf;
  Extrato({required this.nomeArquivo, required this.pdf});
  Map<String, dynamic> toJson() {
    return {'nomeArquivo': nomeArquivo, 'pdf': pdf};
  }

  factory Extrato.fromJson(Map<String, dynamic> json) {
    return Extrato(
      nomeArquivo: json['nomeArquivo'].toString(),
      pdf: json['pdf'].toString(),
    );
  }
}
