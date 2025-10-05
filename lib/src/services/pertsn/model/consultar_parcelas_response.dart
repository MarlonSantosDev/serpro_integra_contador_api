import 'mensagem.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelasResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Quantidade de parcelas encontradas
  int get quantidadeParcelas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.length ?? 0;
  }

  /// Valor total das parcelas
  double get valorTotalParcelas {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return 0.0;

    return dadosParsed.listaParcelas.fold(0.0, (sum, parcela) => sum + parcela.valor);
  }

  /// Formata o valor total das parcelas
  String get valorTotalParcelasFormatado {
    return 'R\$ ${valorTotalParcelas.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Obtém parcelas por ano
  Map<int, List<Parcela>> get parcelasPorAno {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return {};

    final Map<int, List<Parcela>> parcelasPorAno = {};

    for (final parcela in dadosParsed.listaParcelas) {
      final ano = parcela.ano;
      if (!parcelasPorAno.containsKey(ano)) {
        parcelasPorAno[ano] = [];
      }
      parcelasPorAno[ano]!.add(parcela);
    }

    return parcelasPorAno;
  }

  /// Obtém parcelas por mês de um ano específico
  List<Parcela> parcelasDoAno(int ano) {
    final parcelasPorAno = this.parcelasPorAno;
    return parcelasPorAno[ano] ?? [];
  }

  /// Obtém parcelas pendentes (futuras)
  List<Parcela> get parcelasPendentes {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return [];

    final hoje = DateTime.now();
    final anoMesAtual = hoje.year * 100 + hoje.month;

    return dadosParsed.listaParcelas.where((parcela) => parcela.parcela > anoMesAtual).toList();
  }

  /// Obtém parcelas vencidas
  List<Parcela> get parcelasVencidas {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return [];

    final hoje = DateTime.now();
    final anoMesAtual = hoje.year * 100 + hoje.month;

    return dadosParsed.listaParcelas.where((parcela) => parcela.parcela < anoMesAtual).toList();
  }

  /// Obtém parcelas do mês atual
  List<Parcela> get parcelasMesAtual {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return [];

    final hoje = DateTime.now();
    final anoMesAtual = hoje.year * 100 + hoje.month;

    return dadosParsed.listaParcelas.where((parcela) => parcela.parcela == anoMesAtual).toList();
  }
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    final json = jsonString as Map<String, dynamic>;
    return ListaParcelasData(listaParcelas: (json['listaParcelas'] as List).map((e) => Parcela.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'listaParcelas': listaParcelas.map((e) => e.toJson()).toList()};
  }
}

class Parcela {
  final int parcela;
  final double valor;

  Parcela({required this.parcela, required this.valor});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(parcela: int.parse(json['parcela'].toString()), valor: double.parse(json['valor'].toString()));
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }

  /// Obtém o ano da parcela
  int get ano {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.parse(parcelaStr.substring(0, 4));
    }
    return 0;
  }

  /// Obtém o mês da parcela
  int get mes {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.parse(parcelaStr.substring(4, 6));
    }
    return 0;
  }

  /// Formata a parcela (AAAAMM)
  String get parcelaFormatada {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return '${parcelaStr.substring(0, 4)}/${parcelaStr.substring(4, 6)}';
    }
    return parcelaStr;
  }

  /// Formata o valor da parcela
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Obtém o nome do mês da parcela
  String get nomeMes {
    final meses = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

    final mesAtual = this.mes;
    if (mesAtual >= 1 && mesAtual <= 12) {
      return meses[mesAtual];
    }
    return 'Mês inválido';
  }

  /// Obtém a descrição completa da parcela
  String get descricaoCompleta {
    return '$parcelaFormatada - $nomeMes de $ano';
  }

  /// Verifica se a parcela é do mês atual
  bool get isMesAtual {
    final hoje = DateTime.now();
    return ano == hoje.year && mes == hoje.month;
  }

  /// Verifica se a parcela é futura
  bool get isFutura {
    final hoje = DateTime.now();
    final anoMesAtual = hoje.year * 100 + hoje.month;
    return parcela > anoMesAtual;
  }

  /// Verifica se a parcela é passada
  bool get isPassada {
    final hoje = DateTime.now();
    final anoMesAtual = hoje.year * 100 + hoje.month;
    return parcela < anoMesAtual;
  }

  /// Obtém a data de vencimento da parcela
  DateTime? get dataVencimento {
    try {
      return DateTime(ano, mes, 1);
    } catch (e) {
      return null;
    }
  }

  /// Formata a data de vencimento
  String get dataVencimentoFormatada {
    final data = dataVencimento;
    if (data != null) {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    }
    return 'Data inválida';
  }
}

