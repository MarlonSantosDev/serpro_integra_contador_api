/// Enum para tipo de documento utilizado no módulo MIT
///
/// Este enum é específico para o módulo MIT e representa CPF/CNPJ
/// com códigos numéricos específicos.
enum MitTipoDocumento {
  /// CPF (código 1)
  cpf(1, 'CPF'),

  /// CNPJ (código 2)
  cnpj(2, 'CNPJ');

  const MitTipoDocumento(this.codigo, this.descricao);

  /// Código numérico do tipo (1=CPF, 2=CNPJ).
  final int codigo;

  /// Descrição do tipo de documento.
  final String descricao;

  /// Obtém o enum a partir do código numérico.
  static MitTipoDocumento? fromCodigo(int codigo) {
    for (final tipo in MitTipoDocumento.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}

/// Classe para tipo de documento utilizado no módulo PAGTOWEB
///
/// Esta classe é específica para o módulo PAGTOWEB e representa
/// tipos de documento com informações mais detalhadas.
class PagtoWebTipoDocumento {
  /// Código do tipo de documento.
  final String codigo;

  /// Descrição completa do tipo.
  final String descricao;

  /// Descrição abreviada do tipo.
  final String descricaoAbreviada;

  /// Construtor para [PagtoWebTipoDocumento].
  PagtoWebTipoDocumento({
    required this.codigo,
    required this.descricao,
    required this.descricaoAbreviada,
  });

  /// Cria uma instância a partir de um mapa JSON.
  factory PagtoWebTipoDocumento.fromJson(Map<String, dynamic> json) {
    return PagtoWebTipoDocumento(
      codigo: json['codigo'].toString(),
      descricao: json['descricao'].toString(),
      descricaoAbreviada: json['descricaoAbreviada'].toString(),
    );
  }

  /// Serializa para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'descricaoAbreviada': descricaoAbreviada,
    };
  }

  @override
  String toString() {
    return 'PagtoWebTipoDocumento(codigo: $codigo, descricao: $descricao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PagtoWebTipoDocumento &&
        other.codigo == codigo &&
        other.descricao == descricao &&
        other.descricaoAbreviada == descricaoAbreviada;
  }

  @override
  int get hashCode =>
      codigo.hashCode ^ descricao.hashCode ^ descricaoAbreviada.hashCode;
}
