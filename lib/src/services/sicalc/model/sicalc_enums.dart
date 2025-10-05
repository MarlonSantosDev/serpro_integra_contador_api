/// Enums para os serviços SICALC
class SicalcEnums {
  SicalcEnums._();
}

/// Tipos de período de apuração
enum TipoPeriodoApuracao {
  /// Mensal
  mensal('ME'),

  /// Trimestral
  trimestral('TR'),

  /// Anual
  anual('AN');

  const TipoPeriodoApuracao(this.codigo);
  final String codigo;

  static TipoPeriodoApuracao? fromCodigo(String codigo) {
    for (final tipo in TipoPeriodoApuracao.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}

/// Estados brasileiros (UF)
enum UnidadeFederativa {
  acre('AC'),
  alagoas('AL'),
  amapa('AP'),
  amazonas('AM'),
  bahia('BA'),
  ceara('CE'),
  distritoFederal('DF'),
  espiritoSanto('ES'),
  goias('GO'),
  maranhao('MA'),
  matoGrosso('MT'),
  matoGrossoDoSul('MS'),
  minasGerais('MG'),
  para('PA'),
  paraiba('PB'),
  parana('PR'),
  pernambuco('PE'),
  piaui('PI'),
  rioDeJaneiro('RJ'),
  rioGrandeDoNorte('RN'),
  rioGrandeDoSul('RS'),
  rondonia('RO'),
  roraima('RR'),
  santaCatarina('SC'),
  saoPaulo('SP'),
  sergipe('SE'),
  tocantins('TO');

  const UnidadeFederativa(this.sigla);
  final String sigla;

  static UnidadeFederativa? fromSigla(String sigla) {
    for (final uf in UnidadeFederativa.values) {
      if (uf.sigla == sigla.toUpperCase()) return uf;
    }
    return null;
  }

  String get nome {
    switch (this) {
      case UnidadeFederativa.acre:
        return 'Acre';
      case UnidadeFederativa.alagoas:
        return 'Alagoas';
      case UnidadeFederativa.amapa:
        return 'Amapá';
      case UnidadeFederativa.amazonas:
        return 'Amazonas';
      case UnidadeFederativa.bahia:
        return 'Bahia';
      case UnidadeFederativa.ceara:
        return 'Ceará';
      case UnidadeFederativa.distritoFederal:
        return 'Distrito Federal';
      case UnidadeFederativa.espiritoSanto:
        return 'Espírito Santo';
      case UnidadeFederativa.goias:
        return 'Goiás';
      case UnidadeFederativa.maranhao:
        return 'Maranhão';
      case UnidadeFederativa.matoGrosso:
        return 'Mato Grosso';
      case UnidadeFederativa.matoGrossoDoSul:
        return 'Mato Grosso do Sul';
      case UnidadeFederativa.minasGerais:
        return 'Minas Gerais';
      case UnidadeFederativa.para:
        return 'Pará';
      case UnidadeFederativa.paraiba:
        return 'Paraíba';
      case UnidadeFederativa.parana:
        return 'Paraná';
      case UnidadeFederativa.pernambuco:
        return 'Pernambuco';
      case UnidadeFederativa.piaui:
        return 'Piauí';
      case UnidadeFederativa.rioDeJaneiro:
        return 'Rio de Janeiro';
      case UnidadeFederativa.rioGrandeDoNorte:
        return 'Rio Grande do Norte';
      case UnidadeFederativa.rioGrandeDoSul:
        return 'Rio Grande do Sul';
      case UnidadeFederativa.rondonia:
        return 'Rondônia';
      case UnidadeFederativa.roraima:
        return 'Roraima';
      case UnidadeFederativa.santaCatarina:
        return 'Santa Catarina';
      case UnidadeFederativa.saoPaulo:
        return 'São Paulo';
      case UnidadeFederativa.sergipe:
        return 'Sergipe';
      case UnidadeFederativa.tocantins:
        return 'Tocantins';
    }
  }
}

/// Tipos de contribuinte
enum TipoContribuinte {
  /// Pessoa Física
  pessoaFisica(1),

  /// Pessoa Jurídica
  pessoaJuridica(2);

  const TipoContribuinte(this.codigo);
  final int codigo;

  static TipoContribuinte? fromCodigo(int codigo) {
    for (final tipo in TipoContribuinte.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}

/// Serviços disponíveis no SICALC
enum ServicoSicalc {
  /// Consolidar e Emitir um DARF
  consolidarEmitirDarf('CONSOLIDARGERARDARF51'),

  /// Consultar Receitas do SICALC
  consultarReceitas('CONSULTAAPOIORECEITAS52'),

  /// Consolidar e Emitir o Código de Barras do DARF
  gerarCodigoBarras('GERARDARFCODBARRA53');

  const ServicoSicalc(this.idServico);
  final String idServico;

  static ServicoSicalc? fromIdServico(String idServico) {
    for (final servico in ServicoSicalc.values) {
      if (servico.idServico == idServico) return servico;
    }
    return null;
  }
}

/// Endpoints dos serviços SICALC
enum EndpointSicalc {
  /// Endpoint para emissão
  emitir('/Emitir'),

  /// Endpoint para apoio/consulta
  apoiar('/Apoiar');

  const EndpointSicalc(this.endpoint);
  final String endpoint;
}
