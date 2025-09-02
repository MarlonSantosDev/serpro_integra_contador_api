// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dados_saida.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DadosSaida _$DadosSaidaFromJson(Map<String, dynamic> json) => DadosSaida(
  resultado: _stringFromJson(json['resultado']),
  dados: json['dados'] as Map<String, dynamic>?,
  status: _stringFromJson(json['status']),
  codigo: _stringFromJson(json['codigo']),
  mensagem: _stringFromJson(json['mensagem']),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  numeroProtocolo: _stringFromJson(json['numero_protocolo']),
);

Map<String, dynamic> _$DadosSaidaToJson(DadosSaida instance) =>
    <String, dynamic>{
      'resultado': instance.resultado,
      'dados': instance.dados,
      'status': instance.status,
      'codigo': instance.codigo,
      'mensagem': instance.mensagem,
      'timestamp': instance.timestamp?.toIso8601String(),
      'numero_protocolo': instance.numeroProtocolo,
    };

