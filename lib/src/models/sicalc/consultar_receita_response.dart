import 'dart:convert';

/// Modelo de resposta para consultar código de receita SICALC (CONSULTAAPOIORECEITAS52)
class ConsultarReceitaResponse {
  final int status;
  final List<String> mensagens;
  final ConsultarReceitaDados? dados;

  ConsultarReceitaResponse({required this.status, required this.mensagens, this.dados});

  factory ConsultarReceitaResponse.fromJson(Map<String, dynamic> json) {
    ConsultarReceitaDados? dadosParsed;

    if (json['dados'] != null) {
      try {
        // Se dados é uma string JSON, fazer parse
        if (json['dados'] is String) {
          final dadosJson = jsonDecode(json['dados'] as String) as Map<String, dynamic>;
          dadosParsed = ConsultarReceitaDados.fromJson(dadosJson);
        } else if (json['dados'] is Map<String, dynamic>) {
          dadosParsed = ConsultarReceitaDados.fromJson(json['dados'] as Map<String, dynamic>);
        }
      } catch (e) {
        // Se falhar o parse, dadosParsed fica null
      }
    }

    return ConsultarReceitaResponse(
      status: json['status'] as int? ?? 0,
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados?.toJson()};
  }

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200 && dados != null;

  /// Retorna a mensagem principal (primeira mensagem)
  String get mensagemPrincipal => mensagens.isNotEmpty ? mensagens.first : '';

  @override
  String toString() {
    return 'ConsultarReceitaResponse(status: $status, sucesso: $sucesso)';
  }
}

/// Dados retornados pela consulta de código de receita
class ConsultarReceitaDados {
  final int codigoReceita;
  final String descricaoReceita;
  final String tipoPessoa;
  final String? tipoPeriodoApuracao;
  final String? observacoes;
  final bool ativa;
  final String? dataInicioVigencia;
  final String? dataFimVigencia;

  ConsultarReceitaDados({
    required this.codigoReceita,
    required this.descricaoReceita,
    required this.tipoPessoa,
    this.tipoPeriodoApuracao,
    this.observacoes,
    required this.ativa,
    this.dataInicioVigencia,
    this.dataFimVigencia,
  });

  factory ConsultarReceitaDados.fromJson(Map<String, dynamic> json) {
    return ConsultarReceitaDados(
      codigoReceita: json['codigoReceita'] as int? ?? 0,
      descricaoReceita: json['descricaoReceita'] as String? ?? '',
      tipoPessoa: json['tipoPessoa'] as String? ?? '',
      tipoPeriodoApuracao: json['tipoPeriodoApuracao'] as String?,
      observacoes: json['observacoes'] as String?,
      ativa: json['ativa'] as bool? ?? true,
      dataInicioVigencia: json['dataInicioVigencia'] as String?,
      dataFimVigencia: json['dataFimVigencia'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigoReceita': codigoReceita,
      'descricaoReceita': descricaoReceita,
      'tipoPessoa': tipoPessoa,
      'tipoPeriodoApuracao': tipoPeriodoApuracao,
      'observacoes': observacoes,
      'ativa': ativa,
      'dataInicioVigencia': dataInicioVigencia,
      'dataFimVigencia': dataFimVigencia,
    };
  }

  /// Indica se a receita é para pessoa física
  bool get isPessoaFisica => tipoPessoa.toLowerCase().contains('física') || tipoPessoa.toLowerCase().contains('fisica');

  /// Indica se a receita é para pessoa jurídica
  bool get isPessoaJuridica => tipoPessoa.toLowerCase().contains('jurídica') || tipoPessoa.toLowerCase().contains('juridica');

  /// Indica se a receita é para ambos os tipos
  bool get isAmbosTipos => tipoPessoa.toLowerCase().contains('ambos') || tipoPessoa.toLowerCase().contains('todos');

  /// Retorna descrição do tipo de pessoa formatada
  String get tipoPessoaFormatado {
    if (isPessoaFisica) return 'Pessoa Física';
    if (isPessoaJuridica) return 'Pessoa Jurídica';
    if (isAmbosTipos) return 'Ambos os tipos';
    return tipoPessoa;
  }

  /// Retorna descrição do período de apuração formatada
  String get tipoPeriodoFormatado {
    if (tipoPeriodoApuracao == null) return 'Não especificado';

    switch (tipoPeriodoApuracao!.toUpperCase()) {
      case 'AN':
        return 'Anual';
      case 'TR':
        return 'Trimestral';
      case 'ME':
        return 'Mensal';
      case 'QZ':
        return 'Quinzenal';
      case 'DC':
        return 'Decendial';
      case 'SM':
        return 'Semanal';
      case 'DI':
        return 'Diário';
      default:
        return tipoPeriodoApuracao!;
    }
  }

  /// Indica se a receita está vigente na data atual
  bool get isVigente {
    if (!ativa) return false;

    final agora = DateTime.now();

    if (dataInicioVigencia != null) {
      try {
        final inicio = DateTime.parse(dataInicioVigencia!);
        if (agora.isBefore(inicio)) return false;
      } catch (e) {
        // Se não conseguir fazer parse da data, considera vigente
      }
    }

    if (dataFimVigencia != null) {
      try {
        final fim = DateTime.parse(dataFimVigencia!);
        if (agora.isAfter(fim)) return false;
      } catch (e) {
        // Se não conseguir fazer parse da data, considera vigente
      }
    }

    return true;
  }

  @override
  String toString() {
    return 'ConsultarReceitaDados(codigoReceita: $codigoReceita, descricao: $descricaoReceita, tipoPessoa: $tipoPessoaFormatado)';
  }
}
