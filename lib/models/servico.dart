import 'package:json_annotation/json_annotation.dart';

part 'servico.g.dart';

/// Modelo para representar um serviço específico da API Integra Contador
@JsonSerializable()
class Servico {
  /// Identificador do sistema ao qual o serviço pertence (ex: PGDASD, DEFIS)
  final String idSistema;
  
  /// Identificador único do serviço dentro do sistema (ex: TRANSDECLARACAO11, GERARDAS12)
  final String idServico;
  
  /// Tipo de operação do serviço (ex: Consultar, Declarar, Emitir, Monitorar, Apoiar)
  final String tipo;

  const Servico({
    required this.idSistema,
    required this.idServico,
    required this.tipo,
  });

  /// Cria uma instância a partir de JSON
  factory Servico.fromJson(Map<String, dynamic> json) =>
      _$ServicoFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$ServicoToJson(this);

  @override
  String toString() {
    return 'Servico(idSistema: $idSistema, idServico: $idServico, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Servico &&
        other.idSistema == idSistema &&
        other.idServico == idServico &&
        other.tipo == tipo;
  }

  @override
  int get hashCode {
    return Object.hash(idSistema, idServico, tipo);
  }
}


