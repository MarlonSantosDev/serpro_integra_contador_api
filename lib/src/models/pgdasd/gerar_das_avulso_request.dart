/// Modelo de dados para gerar DAS Avulso PGDASD
///
/// Representa os dados necessários para gerar um DAS Avulso através do serviço GERARDASAVULSO19
class GerarDasAvulsoRequest {
  /// Período de Apuração no formato AAAAMM
  final String periodoApuracao;

  /// Lista de tributos para serem incluídos no DAS Avulso
  final List<TributoAvulso> listaTributos;

  /// Data que se deseja emitir o DAS. Caso a emissão seja no próprio dia não informar este campo
  final String? dataConsolidacao;

  /// Indicador de Prorrogação Especial. Somente utilizar para os períodos prorrogados entre 03/2020 e 05/2020 ou 03/2021 e 05/2021
  final int? prorrogacaoEspecial;

  GerarDasAvulsoRequest({required this.periodoApuracao, required this.listaTributos, this.dataConsolidacao, this.prorrogacaoEspecial});

  /// Valida se o período de apuração está no formato correto (AAAAMM)
  bool get isPeriodoValido {
    if (periodoApuracao.length != 6) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao)) return false;

    final ano = int.parse(periodoApuracao.substring(0, 4));
    final mes = int.parse(periodoApuracao.substring(4, 6));

    return ano >= 2018 && ano <= 9999 && mes >= 1 && mes <= 12;
  }

  /// Valida se a data de consolidação está no formato correto (AAAAMMDD)
  bool get isDataConsolidacaoValida {
    if (dataConsolidacao == null) return true;
    if (dataConsolidacao!.length != 8) return false;
    if (!RegExp(r'^\d{8}$').hasMatch(dataConsolidacao!)) return false;

    final ano = int.parse(dataConsolidacao!.substring(0, 4));
    final mes = int.parse(dataConsolidacao!.substring(4, 6));
    final dia = int.parse(dataConsolidacao!.substring(6, 8));

    return ano >= 2018 && ano <= 9999 && mes >= 1 && mes <= 12 && dia >= 1 && dia <= 31;
  }

  /// Valida se a data de consolidação é futura
  bool get isDataConsolidacaoFutura {
    if (dataConsolidacao == null) return true;

    final hoje = DateTime.now();
    final dataConsolidacaoDate = DateTime(
      int.parse(dataConsolidacao!.substring(0, 4)),
      int.parse(dataConsolidacao!.substring(4, 6)),
      int.parse(dataConsolidacao!.substring(6, 8)),
    );

    return dataConsolidacaoDate.isAfter(hoje);
  }

  /// Valida se a lista de tributos não está vazia
  bool get isListaTributosValida => listaTributos.isNotEmpty;

  /// Valida se todos os tributos são válidos
  bool get isTributosValidos {
    for (final tributo in listaTributos) {
      if (!tributo.isValid) return false;
    }
    return true;
  }

  /// Valida se todos os campos estão corretos
  bool get isValid {
    if (!isPeriodoValido) return false;
    if (!isDataConsolidacaoValida) return false;
    if (!isDataConsolidacaoFutura) return false;
    if (!isListaTributosValida) return false;
    if (!isTributosValidos) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'listaTributos': listaTributos.map((t) => t.toJson()).toList(),
      if (dataConsolidacao != null) 'dataConsolidacao': dataConsolidacao,
      if (prorrogacaoEspecial != null) 'prorrogacaoEspecial': prorrogacaoEspecial,
    };
  }

  factory GerarDasAvulsoRequest.fromJson(Map<String, dynamic> json) {
    return GerarDasAvulsoRequest(
      periodoApuracao: json['periodoApuracao'].toString(),
      listaTributos: (json['listaTributos'] as List).map((t) => TributoAvulso.fromJson(t)).toList(),
      dataConsolidacao: json['dataConsolidacao']?.toString(),
      prorrogacaoEspecial: json['prorrogacaoEspecial'] != null ? int.parse(json['prorrogacaoEspecial'].toString()) : null,
    );
  }
}

/// Tributo para DAS Avulso
class TributoAvulso {
  /// Código do tributo
  final int codigo;

  /// Valor do tributo para ser gerado o DAS
  final double valor;

  /// Código de município TOM. Obrigatório para tributo ISS
  final int? codMunicipio;

  /// Destino da UF. Obrigatório para ICMS
  final String? uf;

  TributoAvulso({required this.codigo, required this.valor, this.codMunicipio, this.uf});

  /// Valida se o valor é positivo
  bool get isValorValido => valor > 0;

  /// Valida se o código do tributo é válido
  bool get isCodigoValido => codigo > 0;

  /// Valida se a UF tem 2 caracteres quando informada
  bool get isUfValida => uf == null || uf!.length == 2;

  /// Valida se o código do município é válido quando informado
  bool get isCodMunicipioValido => codMunicipio == null || codMunicipio! > 0;

  /// Valida se todos os campos estão corretos
  bool get isValid {
    if (!isValorValido) return false;
    if (!isCodigoValido) return false;
    if (!isUfValida) return false;
    if (!isCodMunicipioValido) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'valor': valor, if (codMunicipio != null) 'codMunicipio': codMunicipio, if (uf != null) 'uf': uf};
  }

  factory TributoAvulso.fromJson(Map<String, dynamic> json) {
    return TributoAvulso(
      codigo: int.parse(json['codigo'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
      codMunicipio: json['codMunicipio'] != null ? int.parse(json['codMunicipio'].toString()) : null,
      uf: json['uf']?.toString(),
    );
  }
}
