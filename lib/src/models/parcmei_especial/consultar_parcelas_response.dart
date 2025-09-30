import 'mensagem.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelasResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List)
          .map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados,
    };
  }

  /// Dados parseados do JSON string
  ListaParcelasData? get dadosParsed {
    try {
      final dadosJson = dados;
      final parsed = ListaParcelasData.fromJson(dadosJson);
      return parsed;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get sucesso => status == '200';

  /// Mensagem principal de sucesso ou erro
  String get mensagemPrincipal {
    if (mensagens.isNotEmpty) {
      return mensagens.first.texto;
    }
    return sucesso ? 'Requisição efetuada com sucesso.' : 'Erro na requisição.';
  }

  /// Verifica se há parcelas disponíveis
  bool get temParcelas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.isNotEmpty ?? false;
  }

  /// Quantidade de parcelas disponíveis
  int get quantidadeParcelas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.length ?? 0;
  }

  /// Valor total das parcelas disponíveis
  double get valorTotalParcelas {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return 0.0;

    return dadosParsed.listaParcelas.fold(
      0.0,
      (sum, parcela) => sum + parcela.valor,
    );
  }

  /// Valor total das parcelas formatado
  String get valorTotalParcelasFormatado {
    return 'R\$ ${valorTotalParcelas.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    final json = jsonString as Map<String, dynamic>;
    return ListaParcelasData(
      listaParcelas: (json['listaParcela'] as List)
          .map((e) => Parcela.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'listaParcela': listaParcelas.map((e) => e.toJson()).toList()};
  }
}

class Parcela {
  final int parcela;
  final double valor;

  Parcela({required this.parcela, required this.valor});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      parcela: int.parse(json['parcela'].toString()),
      valor: double.parse(json['valor'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }

  /// Parcela formatada (AAAAMM)
  String get parcelaFormatada {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return '${parcelaStr.substring(0, 4)}/${parcelaStr.substring(4, 6)}';
    }
    return parcelaStr;
  }

  /// Valor formatado
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Ano da parcela
  int get ano {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.parse(parcelaStr.substring(0, 4));
    }
    return 0;
  }

  /// Mês da parcela
  int get mes {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.parse(parcelaStr.substring(4, 6));
    }
    return 0;
  }

  /// Data da parcela como DateTime
  DateTime? get dataParcela {
    try {
      return DateTime(ano, mes);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a parcela é do mês atual
  bool get isMesAtual {
    final hoje = DateTime.now();
    return ano == hoje.year && mes == hoje.month;
  }

  /// Verifica se a parcela é de um mês futuro
  bool get isMesFuturo {
    final hoje = DateTime.now();
    final parcelaData = DateTime(ano, mes);
    return parcelaData.isAfter(DateTime(hoje.year, hoje.month));
  }

  /// Verifica se a parcela é de um mês passado
  bool get isMesPassado {
    final hoje = DateTime.now();
    final parcelaData = DateTime(ano, mes);
    return parcelaData.isBefore(DateTime(hoje.year, hoje.month));
  }

  /// Descrição da parcela
  String get descricao {
    final meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    if (mes >= 1 && mes <= 12) {
      return '${meses[mes]} de $ano';
    }

    return parcelaFormatada;
  }
}

