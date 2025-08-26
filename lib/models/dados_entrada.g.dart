// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dados_entrada.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DadosEntrada _$DadosEntradaFromJson(Map<String, dynamic> json) => DadosEntrada(
  identificacao: json['identificacao'] as String?,
  dados: json['dados'] as Map<String, dynamic>?,
  tipoOperacao: json['tipoOperacao'] as String?,
  versao: json['versao'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$DadosEntradaToJson(DadosEntrada instance) =>
    <String, dynamic>{
      'identificacao': instance.identificacao,
      'dados': instance.dados,
      'tipoOperacao': instance.tipoOperacao,
      'versao': instance.versao,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
