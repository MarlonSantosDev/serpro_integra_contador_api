// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servico.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Servico _$ServicoFromJson(Map<String, dynamic> json) => Servico(
  idSistema: json['idSistema'] as String,
  idServico: json['idServico'] as String,
  tipo: json['tipo'] as String,
);

Map<String, dynamic> _$ServicoToJson(Servico instance) => <String, dynamic>{
  'idSistema': instance.idSistema,
  'idServico': instance.idServico,
  'tipo': instance.tipo,
};
