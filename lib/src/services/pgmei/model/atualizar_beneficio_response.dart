import 'dart:convert';
import 'base_response.dart';

/// Modelo de resposta para ATUBENEFICIO23 - Atualizar Benefício
///
/// Representa a resposta do serviço ATUBENEFICIO23 que permite
/// registrar benefício para determinada apuração do PGMEI
class AtualizarBeneficioResponse extends PgmeiBaseResponse {
  AtualizarBeneficioResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como lista de benefícios atualizados
  List<AtualizarBeneficioIntegraMei>? get beneficiosAtualizados {
    try {
      if (dados == null) return [];

      // Se dados é uma lista, retorna diretamente
      if (dados is List) {
        return (dados as List).map((d) => AtualizarBeneficioIntegraMei.fromJson(d as Map<String, dynamic>)).toList();
      }

      // Se dados é um Map com uma chave 'beneficios' ou similar
      if (dados is Map) {
        final dadosMap = dados as Map<String, dynamic>;
        if (dadosMap.containsKey('beneficios') && dadosMap['beneficios'] is List) {
          return (dadosMap['beneficios'] as List).map((d) => AtualizarBeneficioIntegraMei.fromJson(d as Map<String, dynamic>)).toList();
        }
      }

      return [];
    } catch (e) {
      print('Erro ao parsear benefícios atualizados: $e');
      return null;
    }
  }

  factory AtualizarBeneficioResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final decoded = jsonDecode(dadosStr);
        if (decoded is List) {
          // Se for uma lista, converte para Map com chave 'beneficios'
          dadosParsed = {'beneficios': decoded};
        } else if (decoded is Map) {
          dadosParsed = decoded as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return AtualizarBeneficioResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m)).toList(),
      dados: dadosParsed,
    );
  }
}

/// Informação sobre benefício atualizado
class AtualizarBeneficioIntegraMei {
  /// Período de apuração original
  final String paOriginal;

  /// Indica se há benefício no período
  final bool indicadorBeneficio;

  /// PA que possui os períodos agrupados para emissão de DAS no formato AAAAMM
  final String paAgrupado;

  AtualizarBeneficioIntegraMei({required this.paOriginal, required this.indicadorBeneficio, required this.paAgrupado});

  Map<String, dynamic> toJson() {
    return {'paOriginal': paOriginal, 'indicadorBeneficio': indicadorBeneficio, 'paAgrupado': paAgrupado};
  }

  factory AtualizarBeneficioIntegraMei.fromJson(Map<String, dynamic> json) {
    return AtualizarBeneficioIntegraMei(
      paOriginal: json['paOriginal'].toString(),
      indicadorBeneficio: json['indicadorBeneficio'] == true,
      paAgrupado: json['paAgrupado'].toString(),
    );
  }
}
