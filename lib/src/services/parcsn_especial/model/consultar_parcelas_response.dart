import 'dart:convert';
import 'mensagem.dart';
import '../../../util/formatador_utils.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ListaParcelasData? dados;

  ConsultarParcelasResponse({required this.status, required this.mensagens, this.dados});

  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json) {
    ListaParcelasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = ListaParcelasData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarParcelasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
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
    return dados?.listaParcelas.isNotEmpty ?? false;
  }

  /// Quantidade de parcelas encontradas
  int get quantidadeParcelas {
    return dados?.listaParcelas.length ?? 0;
  }

  /// Valor total de todas as parcelas
  double get valorTotalParcelas {
    if (dados == null) return 0.0;
    return dados!.listaParcelas.fold(0.0, (sum, parcela) => sum + parcela.valor);
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalParcelasFormatado {
    return FormatadorUtils.formatCurrency(valorTotalParcelas);
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
  final double valor;

  Parcela({required this.parcela, required this.valor});

  factory Parcela.fromJson(Map<String, dynamic> json) {
    return Parcela(parcela: int.parse(json['parcela'].toString()), valor: (num.parse(json['valor'].toString())).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }

  /// Parcela formatada (MM/AAAA)
  String get parcelaFormatada {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return '${parcelaStr.substring(4, 6)}/${parcelaStr.substring(0, 4)}';
    }
    return parcelaStr;
  }

  /// Valor formatado como moeda brasileira
  String get valorFormatado {
    return FormatadorUtils.formatCurrency(valor);
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
    final agora = DateTime.now();
    return ano == agora.year && mes == agora.month;
  }

  /// Verifica se a parcela é de um mês futuro
  bool get isMesFuturo {
    final agora = DateTime.now();
    final dataParcela = this.dataParcela;
    if (dataParcela == null) return false;
    return dataParcela.isAfter(DateTime(agora.year, agora.month));
  }

  /// Verifica se a parcela é de um mês passado
  bool get isMesPassado {
    final agora = DateTime.now();
    final dataParcela = this.dataParcela;
    if (dataParcela == null) return false;
    return dataParcela.isBefore(DateTime(agora.year, agora.month));
  }

  @override
  String toString() {
    return 'Parcela(parcela: $parcelaFormatada, valor: $valorFormatado)';
  }
}
