import 'dart:convert';
import 'sitfis_mensagens.dart';

/// Response da emissão do relatório de situação fiscal
class EmitirRelatorioResponse {
  final int status;
  final List<SitfisMensagem> mensagens;
  final EmitirRelatorioDados? dados;

  EmitirRelatorioResponse({required this.status, required this.mensagens, this.dados});

  factory EmitirRelatorioResponse.fromJson(Map<String, dynamic> json) {
    return EmitirRelatorioResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => SitfisMensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: json['dados'] != null ? EmitirRelatorioDados.fromJson(json['dados'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados?.toJson()};
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get isSuccess => status == 200;

  /// Verifica se está em processamento
  bool get isProcessing => status == 202;

  /// Verifica se há PDF disponível
  bool get hasPdf => dados?.pdf != null && dados!.pdf!.isNotEmpty;

  /// Verifica se há tempo de espera
  bool get hasTempoEspera => dados?.tempoEspera != null;
}

/// Dados retornados na emissão do relatório
class EmitirRelatorioDados {
  final String? pdf;
  final int? tempoEspera;

  EmitirRelatorioDados({this.pdf, this.tempoEspera});

  factory EmitirRelatorioDados.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = _parseJsonString(jsonString);
      return EmitirRelatorioDados(pdf: json['pdf'] as String?, tempoEspera: json['tempoEspera'] as int?);
    } catch (e) {
      return EmitirRelatorioDados();
    }
  }

  Map<String, dynamic> toJson() {
    return {'pdf': pdf, 'tempoEspera': tempoEspera};
  }

  /// Converte tempo de espera de milissegundos para segundos
  int? get tempoEsperaEmSegundos => tempoEspera != null ? tempoEspera! ~/ 1000 : null;

  /// Converte tempo de espera de milissegundos para minutos
  double? get tempoEsperaEmMinutos => tempoEspera != null ? tempoEspera! / 60000 : null;

  /// Tamanho do PDF em bytes (aproximado)
  int? get pdfSizeInBytes {
    if (pdf == null || pdf!.isEmpty) return null;
    // Base64 tem aproximadamente 4/3 do tamanho original
    return (pdf!.length * 3 / 4).round();
  }
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
