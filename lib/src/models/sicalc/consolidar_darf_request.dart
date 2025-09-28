/// Modelo de requisição para consolidar e gerar DARF (CONSOLIDARGERARDARF51)
class ConsolidarDarfRequest {
  final String uf;
  final int municipio;
  final int codigoReceita;
  final int codigoReceitaExtensao;
  final int? numeroReferencia;
  final String? tipoPA;
  final String dataPA;
  final String vencimento;
  final int? cota;
  final double valorImposto;
  final double? valorMulta;
  final double? valorJuros;
  final bool? ganhoCapital;
  final String? dataAlienacao;
  final String dataConsolidacao;
  final String? observacao;
  final int? cno;
  final int? cnpjPrestador;

  ConsolidarDarfRequest({
    required this.uf,
    required this.municipio,
    required this.codigoReceita,
    required this.codigoReceitaExtensao,
    this.numeroReferencia,
    this.tipoPA,
    required this.dataPA,
    required this.vencimento,
    this.cota,
    required this.valorImposto,
    this.valorMulta,
    this.valorJuros,
    this.ganhoCapital,
    this.dataAlienacao,
    required this.dataConsolidacao,
    this.observacao,
    this.cno,
    this.cnpjPrestador,
  });

  /// Converte para JSON string para ser usado no campo 'dados' do PedidoDados
  String toDadosJson() {
    final Map<String, dynamic> dados = {
      'uf': uf,
      'municipio': municipio.toString(),
      'codigoReceita': codigoReceita.toString(),
      'codigoReceitaExtensao': codigoReceitaExtensao.toString(),
      'dataPA': dataPA,
      'vencimento': vencimento,
      'valorImposto': valorImposto.toStringAsFixed(2),
      'dataConsolidacao': dataConsolidacao,
    };

    // Adicionar campos opcionais apenas se não forem null
    if (numeroReferencia != null) {
      dados['numeroReferencia'] = numeroReferencia.toString();
    }
    if (tipoPA != null) {
      dados['tipoPA'] = tipoPA;
    }
    if (cota != null) {
      dados['cota'] = cota.toString();
    }
    if (valorMulta != null) {
      dados['valorMulta'] = valorMulta!.toStringAsFixed(2);
    }
    if (valorJuros != null) {
      dados['valorJuros'] = valorJuros!.toStringAsFixed(2);
    }
    if (ganhoCapital != null) {
      dados['ganhoCapital'] = ganhoCapital;
    }
    if (dataAlienacao != null) {
      dados['dataAlienacao'] = dataAlienacao;
    }
    if (observacao != null) {
      dados['observacao'] = observacao;
    }
    if (cno != null) {
      dados['cno'] = cno.toString();
    }
    if (cnpjPrestador != null) {
      dados['cnpjPrestador'] = cnpjPrestador.toString();
    }

    return _mapToJsonString(dados);
  }

  /// Converte Map para JSON string
  String _mapToJsonString(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    buffer.write('{');

    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":');

      if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else if (entry.value is bool) {
        buffer.write(entry.value);
      } else {
        buffer.write('"${entry.value}"');
      }

      if (i < entries.length - 1) {
        buffer.write(',');
      }
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Valida os dados da requisição
  List<String> validar() {
    final List<String> erros = [];

    if (uf.isEmpty) {
      erros.add('UF é obrigatória');
    } else if (uf.length != 2) {
      erros.add('UF deve ter 2 caracteres');
    }

    if (municipio <= 0) {
      erros.add('Código do município deve ser maior que zero');
    }

    if (codigoReceita <= 0) {
      erros.add('Código da receita deve ser maior que zero');
    }

    if (codigoReceitaExtensao <= 0) {
      erros.add('Código da extensão da receita deve ser maior que zero');
    }

    if (dataPA.isEmpty) {
      erros.add('Data do período de apuração é obrigatória');
    }

    if (vencimento.isEmpty) {
      erros.add('Data de vencimento é obrigatória');
    }

    if (valorImposto <= 0) {
      erros.add('Valor do imposto deve ser maior que zero');
    }

    if (dataConsolidacao.isEmpty) {
      erros.add('Data de consolidação é obrigatória');
    }

    // Validar formato de datas ISO 8601
    if (!_isValidIsoDate(vencimento)) {
      erros.add('Data de vencimento deve estar no formato ISO 8601 (aaaa-mm-ddThh:mm:ss)');
    }

    if (!_isValidIsoDate(dataConsolidacao)) {
      erros.add('Data de consolidação deve estar no formato ISO 8601 (aaaa-mm-ddThh:mm:ss)');
    }

    if (dataAlienacao != null && !_isValidIsoDate(dataAlienacao!)) {
      erros.add('Data de alienação deve estar no formato ISO 8601 (aaaa-mm-ddThh:mm:ss)');
    }

    return erros;
  }

  /// Valida se a string está no formato ISO 8601
  bool _isValidIsoDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cria uma cópia com novos valores
  ConsolidarDarfRequest copyWith({
    String? uf,
    int? municipio,
    int? codigoReceita,
    int? codigoReceitaExtensao,
    int? numeroReferencia,
    String? tipoPA,
    String? dataPA,
    String? vencimento,
    int? cota,
    double? valorImposto,
    double? valorMulta,
    double? valorJuros,
    bool? ganhoCapital,
    String? dataAlienacao,
    String? dataConsolidacao,
    String? observacao,
    int? cno,
    int? cnpjPrestador,
  }) {
    return ConsolidarDarfRequest(
      uf: uf ?? this.uf,
      municipio: municipio ?? this.municipio,
      codigoReceita: codigoReceita ?? this.codigoReceita,
      codigoReceitaExtensao: codigoReceitaExtensao ?? this.codigoReceitaExtensao,
      numeroReferencia: numeroReferencia ?? this.numeroReferencia,
      tipoPA: tipoPA ?? this.tipoPA,
      dataPA: dataPA ?? this.dataPA,
      vencimento: vencimento ?? this.vencimento,
      cota: cota ?? this.cota,
      valorImposto: valorImposto ?? this.valorImposto,
      valorMulta: valorMulta ?? this.valorMulta,
      valorJuros: valorJuros ?? this.valorJuros,
      ganhoCapital: ganhoCapital ?? this.ganhoCapital,
      dataAlienacao: dataAlienacao ?? this.dataAlienacao,
      dataConsolidacao: dataConsolidacao ?? this.dataConsolidacao,
      observacao: observacao ?? this.observacao,
      cno: cno ?? this.cno,
      cnpjPrestador: cnpjPrestador ?? this.cnpjPrestador,
    );
  }

  @override
  String toString() {
    return 'ConsolidarDarfRequest(uf: $uf, municipio: $municipio, codigoReceita: $codigoReceita, codigoReceitaExtensao: $codigoReceitaExtensao, dataPA: $dataPA, vencimento: $vencimento, valorImposto: $valorImposto, dataConsolidacao: $dataConsolidacao)';
  }
}
