import 'dart:convert';
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

  /// Quantidade de parcelas disponíveis
  int get quantidadeParcelas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.length ?? 0;
  }

  /// Lista de parcelas vencidas
  List<Parcela> get parcelasVencidas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.where((p) => p.isVencida).toList() ?? [];
  }

  /// Lista de parcelas em dia
  List<Parcela> get parcelasEmDia {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.listaParcelas.where((p) => !p.isVencida).toList() ?? [];
  }

  /// Valor total das parcelas disponíveis
  double get valorTotalParcelas {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed == null) return 0.0;
    return dadosParsed.listaParcelas.fold(0.0, (sum, parcela) => sum + parcela.valor);
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalParcelasFormatado {
    return 'R\$ ${valorTotalParcelas.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  @override
  String toString() {
    return 'ConsultarParcelasResponse(status: $status, mensagens: ${mensagens.length}, parcelas: $quantidadeParcelas)';
  }
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ListaParcelasData(listaParcelas: (json['listaParcelas'] as List).map((e) => Parcela.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'listaParcelas': listaParcelas.map((e) => e.toJson()).toList()};
  }
}

class Parcela {
  final int parcela;
  final int numeroParcelamento;
  final double valor;
  final int dataVencimento;
  final String situacao;

  Parcela({required this.parcela, required this.numeroParcelamento, required this.valor, required this.dataVencimento, required this.situacao});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(
      parcela: json['parcela'] as int,
      numeroParcelamento: json['numeroParcelamento'] as int,
      valor: (json['valor'] as num).toDouble(),
      dataVencimento: json['dataVencimento'] as int,
      situacao: json['situacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'numeroParcelamento': numeroParcelamento, 'valor': valor, 'dataVencimento': dataVencimento, 'situacao': situacao};
  }

  /// Valor formatado como moeda brasileira
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String get dataVencimentoFormatada {
    final data = dataVencimento.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Parcela formatada (ex: "1/12", "2/12")
  String get parcelaFormatada {
    return '$parcela';
  }

  /// Verifica se a parcela está vencida
  bool get isVencida {
    final hoje = DateTime.now();
    final vencimento = DateTime(
      int.parse(dataVencimento.toString().substring(0, 4)),
      int.parse(dataVencimento.toString().substring(4, 6)),
      int.parse(dataVencimento.toString().substring(6, 8)),
    );
    return hoje.isAfter(vencimento);
  }

  /// Verifica se a parcela está em dia
  bool get isEmDia => !isVencida;

  /// Verifica se a parcela está paga
  bool get isPaga => situacao.toLowerCase().contains('pago') || situacao.toLowerCase().contains('quitado');

  /// Verifica se a parcela está pendente
  bool get isPendente => !isPaga;

  /// Dias de atraso (se vencida)
  int get diasAtraso {
    if (!isVencida) return 0;
    final hoje = DateTime.now();
    final vencimento = DateTime(
      int.parse(dataVencimento.toString().substring(0, 4)),
      int.parse(dataVencimento.toString().substring(4, 6)),
      int.parse(dataVencimento.toString().substring(6, 8)),
    );
    return hoje.difference(vencimento).inDays;
  }

  @override
  String toString() {
    return 'Parcela(numero: $parcela, valor: $valorFormatado, vencimento: $dataVencimentoFormatada, situacao: $situacao)';
  }
}
