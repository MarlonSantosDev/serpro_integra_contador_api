import 'dart:convert';

/// Categorias de declaração DCTFWeb
enum CategoriaDctf {
  geralMensal(40, 'GERAL_MENSAL'),
  geral13Salario(41, 'GERAL_13o_SALARIO'),
  afericao(44, 'AFERICAO'),
  espetaculoDesportivo(45, 'ESPETACULO_DESPORTIVO'),
  reclamatoriaTrabalhista(46, 'RECLAMATORIA_TRABALHISTA'),
  pfMensal(50, 'PF_MENSAL'),
  pf13Salario(51, 'PF_13o_SALARIO');

  const CategoriaDctf(this.codigo, this.nome);
  final int codigo;
  final String nome;

  /// Verifica se a categoria requer mês de apuração
  bool get requerMes => this != geral13Salario && this != pf13Salario;

  /// Verifica se a categoria requer dia de apuração
  bool get requerDia => this == espetaculoDesportivo;

  /// Verifica se a categoria requer CNO de aferição
  bool get requerCnoAfericao => this == afericao;

  /// Verifica se a categoria requer número do processo de reclamatória
  bool get requerNumProcReclamatoria => this == reclamatoriaTrabalhista;

  static CategoriaDctf? fromCodigo(int codigo) {
    for (final categoria in CategoriaDctf.values) {
      if (categoria.codigo == codigo) return categoria;
    }
    return null;
  }

  static CategoriaDctf? fromNome(String nome) {
    for (final categoria in CategoriaDctf.values) {
      if (categoria.nome == nome) return categoria;
    }
    return null;
  }
}

/// Sistemas de origem das receitas
enum SistemaOrigem {
  esocial(1),
  sero(5),
  reinfCp(6),
  reinfRet(7),
  mit(8);

  const SistemaOrigem(this.id);
  final int id;
}

/// Request base para serviços DCTFWeb
class DctfWebRequest {
  final CategoriaDctf categoria;
  final String anoPA;
  final String? mesPA;
  final String? diaPA;
  final int? cnoAfericao;
  final int? numeroReciboEntrega;
  final String? numProcReclamatoria;
  final int? dataAcolhimentoProposta;
  final List<SistemaOrigem>? idsSistemaOrigem;

  DctfWebRequest({
    required this.categoria,
    required this.anoPA,
    this.mesPA,
    this.diaPA,
    this.cnoAfericao,
    this.numeroReciboEntrega,
    this.numProcReclamatoria,
    this.dataAcolhimentoProposta,
    this.idsSistemaOrigem,
  }) {
    _validarCampos();
  }

  void _validarCampos() {
    // Validar mês de apuração
    if (categoria.requerMes && (mesPA == null || mesPA!.isEmpty)) {
      throw ArgumentError('Mês de apuração é obrigatório para categoria ${categoria.nome}');
    }

    // Validar dia de apuração
    if (categoria.requerDia && (diaPA == null || diaPA!.isEmpty)) {
      throw ArgumentError('Dia de apuração é obrigatório para categoria ${categoria.nome}');
    }

    // Validar CNO de aferição
    if (categoria.requerCnoAfericao && cnoAfericao == null) {
      throw ArgumentError('CNO de aferição é obrigatório para categoria ${categoria.nome}');
    }

    // Validar número do processo de reclamatória
    if (categoria.requerNumProcReclamatoria && (numProcReclamatoria == null || numProcReclamatoria!.isEmpty)) {
      throw ArgumentError('Número do processo de reclamatória é obrigatório para categoria ${categoria.nome}');
    }

    // Validar formato do ano
    if (anoPA.length != 4 || int.tryParse(anoPA) == null) {
      throw ArgumentError('Ano de apuração deve estar no formato AAAA');
    }

    // Validar formato do mês
    if (mesPA != null && mesPA!.isNotEmpty) {
      if (mesPA!.length != 2 || int.tryParse(mesPA!) == null) {
        throw ArgumentError('Mês de apuração deve estar no formato MM');
      }
      final mes = int.parse(mesPA!);
      if (mes < 1 || mes > 12) {
        throw ArgumentError('Mês de apuração deve estar entre 01 e 12');
      }
    }

    // Validar formato do dia
    if (diaPA != null && diaPA!.isNotEmpty) {
      if (diaPA!.length != 2 || int.tryParse(diaPA!) == null) {
        throw ArgumentError('Dia de apuração deve estar no formato DD');
      }
      final dia = int.parse(diaPA!);
      if (dia < 1 || dia > 31) {
        throw ArgumentError('Dia de apuração deve estar entre 01 e 31');
      }
    }
  }

  Map<String, dynamic> toDados() {
    final dados = <String, dynamic>{};

    // Categoria pode ser string ou número
    dados['categoria'] = categoria.nome;
    dados['anoPA'] = anoPA;

    if (mesPA != null && mesPA!.isNotEmpty) {
      dados['mesPA'] = mesPA;
    }

    if (diaPA != null && diaPA!.isNotEmpty) {
      dados['diaPA'] = diaPA;
    }

    if (cnoAfericao != null) {
      dados['cnoAfericao'] = cnoAfericao;
    }

    if (numeroReciboEntrega != null) {
      dados['numeroReciboEntrega'] = numeroReciboEntrega;
    }

    if (numProcReclamatoria != null && numProcReclamatoria!.isNotEmpty) {
      dados['numProcReclamatoria'] = numProcReclamatoria;
    }

    if (dataAcolhimentoProposta != null) {
      dados['DataAcolhimentoProposta'] = dataAcolhimentoProposta;
    }

    if (idsSistemaOrigem != null && idsSistemaOrigem!.isNotEmpty) {
      dados['idsSistemaOrigem'] = idsSistemaOrigem!.map((s) => s.id).toList();
    }

    return dados;
  }

  String toDadosJson() => jsonEncode(toDados());
}

/// Request específico para transmissão de declaração DCTFWeb
class TransmitirDeclaracaoDctfRequest extends DctfWebRequest {
  final String xmlAssinadoBase64;

  TransmitirDeclaracaoDctfRequest({
    required super.categoria,
    required super.anoPA,
    super.mesPA,
    super.diaPA,
    super.numProcReclamatoria,
    required this.xmlAssinadoBase64,
  }) {
    if (xmlAssinadoBase64.isEmpty) {
      throw ArgumentError('XML assinado em Base64 é obrigatório para transmissão');
    }
  }

  @override
  Map<String, dynamic> toDados() {
    final dados = super.toDados();
    dados['xmlAssinadoBase64'] = xmlAssinadoBase64;
    return dados;
  }
}

/// Request para consultas que podem usar filtros por CNPJ de referência
class ConsultarDctfWebRequest extends DctfWebRequest {
  final String? cnpjReferencia;

  ConsultarDctfWebRequest({
    required super.categoria,
    required super.anoPA,
    super.mesPA,
    super.diaPA,
    super.cnoAfericao,
    super.numeroReciboEntrega,
    super.numProcReclamatoria,
    this.cnpjReferencia,
  });

  @override
  Map<String, dynamic> toDados() {
    final dados = super.toDados();
    if (cnpjReferencia != null && cnpjReferencia!.isNotEmpty) {
      dados['cnpjReferencia'] = cnpjReferencia;
    }
    return dados;
  }
}
