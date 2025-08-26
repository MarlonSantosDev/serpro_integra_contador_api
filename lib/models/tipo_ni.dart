import 'package:json_annotation/json_annotation.dart';

part 'tipo_ni.g.dart';

/// Modelo para tipo de número de identificação
@JsonSerializable()
class TipoNi {
  /// Código do tipo de identificação
  final String codigo;
  
  /// Descrição do tipo de identificação
  final String descricao;

  const TipoNi({
    required this.codigo,
    required this.descricao,
  });

  /// Cria uma instância a partir de JSON
  factory TipoNi.fromJson(Map<String, dynamic> json) => _$TipoNiFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$TipoNiToJson(this);

  /// Tipo CPF
  factory TipoNi.cpf() => const TipoNi(codigo: '1', descricao: 'CPF');

  /// Tipo CNPJ
  factory TipoNi.cnpj() => const TipoNi(codigo: '2', descricao: 'CNPJ');

  /// Tipo CEI
  factory TipoNi.cei() => const TipoNi(codigo: '3', descricao: 'CEI');

  /// Tipo PIS/PASEP
  factory TipoNi.pisPasep() => const TipoNi(codigo: '4', descricao: 'PIS/PASEP');

  /// Tipo NIT
  factory TipoNi.nit() => const TipoNi(codigo: '5', descricao: 'NIT');

  /// Tipo Título de Eleitor
  factory TipoNi.tituloEleitor() => const TipoNi(codigo: '6', descricao: 'Título de Eleitor');

  /// Verifica se é CPF
  bool get isCpf => codigo == '1';

  /// Verifica se é CNPJ
  bool get isCnpj => codigo == '2';

  /// Verifica se é pessoa física
  bool get isPessoaFisica => isCpf || codigo == '4' || codigo == '5' || codigo == '6';

  /// Verifica se é pessoa jurídica
  bool get isPessoaJuridica => isCnpj || codigo == '3';

  @override
  String toString() => 'TipoNi(codigo: $codigo, descricao: $descricao)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoNi &&
        other.codigo == codigo &&
        other.descricao == descricao;
  }

  @override
  int get hashCode => Object.hash(codigo, descricao);
}

