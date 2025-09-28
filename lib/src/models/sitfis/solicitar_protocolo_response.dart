import 'dart:convert';
import 'sitfis_mensagens.dart';

/// Response da solicitação de protocolo do relatório de situação fiscal
class SolicitarProtocoloResponse {
  final int status;
  final List<SitfisMensagem> mensagens;
  final SolicitarProtocoloDados? dados;

  SolicitarProtocoloResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory SolicitarProtocoloResponse.fromJson(Map<String, dynamic> json) {
    return SolicitarProtocoloResponse(
      status: int.parse(json['status'].toString()),
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => SitfisMensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dados: json['dados'] != null
          ? SolicitarProtocoloDados.fromJson(json['dados'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados?.toJson(),
    };
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get isSuccess => status == 200;

  /// Verifica se há tempo de espera
  bool get hasTempoEspera => dados?.tempoEspera != null;

  /// Verifica se há protocolo disponível
  bool get hasProtocolo =>
      dados?.protocoloRelatorio != null &&
      dados!.protocoloRelatorio!.isNotEmpty;
}

/// Dados retornados na solicitação de protocolo
class SolicitarProtocoloDados {
  final String? protocoloRelatorio;
  final int? tempoEspera;

  SolicitarProtocoloDados({this.protocoloRelatorio, this.tempoEspera});

  factory SolicitarProtocoloDados.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = _parseJsonString(jsonString);
      return SolicitarProtocoloDados(
        protocoloRelatorio: json['protocoloRelatorio']?.toString(),
        tempoEspera: int.parse(json['tempoEspera'].toString()),
      );
    } catch (e) {
      return SolicitarProtocoloDados();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'protocoloRelatorio': protocoloRelatorio,
      'tempoEspera': tempoEspera,
    };
  }

  /// Converte tempo de espera de milissegundos para segundos
  int? get tempoEsperaEmSegundos =>
      tempoEspera != null ? tempoEspera! ~/ 1000 : null;

  /// Converte tempo de espera de milissegundos para minutos
  double? get tempoEsperaEmMinutos =>
      tempoEspera != null ? tempoEspera! / 60000 : null;
}

/// Função auxiliar para fazer parse de JSON string escapada
Map<String, dynamic> _parseJsonString(String jsonString) {
  try {
    // Remove aspas externas se existirem
    String cleanString = jsonString.trim();
    if (cleanString.startsWith('"') && cleanString.endsWith('"')) {
      cleanString = cleanString.substring(1, cleanString.length - 1);
    }

    // Decodifica caracteres escapados
    cleanString = cleanString.replaceAll('\\"', '"');

    // Tenta fazer parse como JSON
    return Map<String, dynamic>.from(jsonDecode(cleanString));
  } catch (e) {
    // Se falhar, retorna mapa vazio
    return <String, dynamic>{};
  }
}
