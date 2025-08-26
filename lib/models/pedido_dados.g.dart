// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_dados.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoDados _$PedidoDadosFromJson(Map<String, dynamic> json) => PedidoDados(
  identificacao: json['identificacao'] == null
      ? null
      : Identificacao.fromJson(json['identificacao'] as Map<String, dynamic>),
  servico: json['servico'] as String,
  parametros: json['parametros'] as Map<String, dynamic>?,
  dataReferencia: json['data_referencia'] == null
      ? null
      : DateTime.parse(json['data_referencia'] as String),
  periodoApuracao: json['periodo_apuracao'] as String?,
  anoBase: json['ano_base'] as String?,
);

Map<String, dynamic> _$PedidoDadosToJson(PedidoDados instance) =>
    <String, dynamic>{
      'identificacao': instance.identificacao,
      'servico': instance.servico,
      'parametros': instance.parametros,
      'data_referencia': instance.dataReferencia?.toIso8601String(),
      'periodo_apuracao': instance.periodoApuracao,
      'ano_base': instance.anoBase,
    };
