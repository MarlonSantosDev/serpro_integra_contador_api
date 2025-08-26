import 'package:json_annotation/json_annotation.dart';
import 'identificacao.dart';

part 'pedido_dados.g.dart';

/// Modelo para pedidos de dados nas operações da API
@JsonSerializable()
class PedidoDados {
  /// Identificação do contribuinte
  final Identificacao? identificacao;
  
  /// Nome do serviço a ser executado
  final String servico;
  
  /// Parâmetros específicos do serviço
  final Map<String, dynamic>? parametros;
  
  /// Data de referência para a operação
  @JsonKey(name: 'data_referencia')
  final DateTime? dataReferencia;
  
  /// Período de apuração (formato MMAAAA)
  @JsonKey(name: 'periodo_apuracao')
  final String? periodoApuracao;
  
  /// Ano base para consultas
  @JsonKey(name: 'ano_base')
  final String? anoBase;

  const PedidoDados({
    this.identificacao,
    required this.servico,
    this.parametros,
    this.dataReferencia,
    this.periodoApuracao,
    this.anoBase,
  });

  /// Cria uma instância a partir de JSON
  factory PedidoDados.fromJson(Map<String, dynamic> json) =>
      _$PedidoDadosFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$PedidoDadosToJson(this);

  /// Valida se o pedido está completo
  bool get isValid {
    return servico.isNotEmpty && identificacao?.isValid == true;
  }

  /// Cria uma cópia com novos valores
  PedidoDados copyWith({
    Identificacao? identificacao,
    String? servico,
    Map<String, dynamic>? parametros,
    DateTime? dataReferencia,
    String? periodoApuracao,
    String? anoBase,
  }) {
    return PedidoDados(
      identificacao: identificacao ?? this.identificacao,
      servico: servico ?? this.servico,
      parametros: parametros ?? this.parametros,
      dataReferencia: dataReferencia ?? this.dataReferencia,
      periodoApuracao: periodoApuracao ?? this.periodoApuracao,
      anoBase: anoBase ?? this.anoBase,
    );
  }

  @override
  String toString() {
    return 'PedidoDados(servico: $servico, identificacao: $identificacao, anoBase: $anoBase)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PedidoDados &&
        other.identificacao == identificacao &&
        other.servico == servico &&
        other.anoBase == anoBase &&
        other.periodoApuracao == periodoApuracao;
  }

  @override
  int get hashCode {
    return Object.hash(identificacao, servico, anoBase, periodoApuracao);
  }
  /// Construtor de fábrica para consulta de situação fiscal
  factory PedidoDados.consultaSituacaoFiscal({
    required Identificacao identificacao,
    required String anoBase,
  }) {
    return PedidoDados(
      identificacao: identificacao,
      servico: 'CONSULTASITUACAOFISCAL',
      anoBase: anoBase,
    );
  }

}


