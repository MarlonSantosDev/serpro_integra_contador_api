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
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e)).toList(),
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
      print('Erro ao parsear JSON consultar parcelas: $e');
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
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return ListaParcelasData(listaParcelas: (json['listaParcelas'] as List).map((e) => Parcela.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'listaParcelas': listaParcelas.map((e) => e.toJson()).toList()};
  }

  /// Retorna o total de parcelas disponíveis
  int get totalParcelas => listaParcelas.length;

  /// Retorna o valor total das parcelas
  double get valorTotalParcelas {
    return listaParcelas.fold(0.0, (sum, parcela) => sum + parcela.valor);
  }

  /// Retorna as parcelas ordenadas por número
  List<Parcela> get parcelasOrdenadas {
    final parcelasOrdenadas = List<Parcela>.from(listaParcelas);
    parcelasOrdenadas.sort((a, b) => a.parcela.compareTo(b.parcela));
    return parcelasOrdenadas;
  }

  /// Retorna a próxima parcela a vencer
  Parcela? get proximaParcela {
    if (listaParcelas.isEmpty) return null;

    final hoje = DateTime.now();
    final anoMesAtual = int.parse('${hoje.year}${hoje.month.toString().padLeft(2, '0')}');

    final parcelasFuturas = listaParcelas.where((p) => p.parcelaInt >= anoMesAtual).toList();

    if (parcelasFuturas.isEmpty) return null;

    parcelasFuturas.sort((a, b) => a.parcelaInt.compareTo(b.parcelaInt));
    return parcelasFuturas.first;
  }
}

class Parcela {
  final String parcela;
  final double valor;

  Parcela({required this.parcela, required this.valor});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(parcela: json['parcela'].toString(), valor: (num.parse(json['valor'].toString())).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }

  /// Converte a parcela (AAAAMM) para inteiro para comparações
  int get parcelaInt {
    return int.parse(parcela);
  }

  /// Formata a parcela (AAAAMM) para exibição
  String get parcelaFormatada {
    if (parcela.length == 6) {
      return '${parcela.substring(0, 4)}/${parcela.substring(4, 6)}';
    }
    return parcela;
  }

  /// Retorna o ano da parcela
  int get ano {
    return int.parse(parcela.substring(0, 4));
  }

  /// Retorna o mês da parcela
  int get mes {
    return int.parse(parcela.substring(4, 6));
  }

  /// Retorna a data de vencimento estimada (último dia do mês)
  DateTime get dataVencimentoEstimada {
    final ano = this.ano;
    final mes = this.mes;
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    return DateTime(ano, mes, ultimoDia);
  }

  /// Verifica se a parcela está vencida
  bool get isVencida {
    return dataVencimentoEstimada.isBefore(DateTime.now());
  }

  /// Retorna o número de dias até o vencimento (negativo se vencida)
  int get diasAteVencimento {
    final hoje = DateTime.now();
    final vencimento = dataVencimentoEstimada;
    return vencimento.difference(hoje).inDays;
  }

  /// Formata o valor para exibição
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Retorna uma descrição completa da parcela
  String get descricaoCompleta {
    return 'Parcela ${parcelaFormatada} - ${valorFormatado} - Vencimento: ${dataVencimentoEstimada.day}/${dataVencimentoEstimada.month}/${dataVencimentoEstimada.year}';
  }
}
