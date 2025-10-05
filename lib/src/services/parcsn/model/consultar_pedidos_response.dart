import 'dart:convert';
import 'mensagem.dart';
import '../../../util/formatador_utils.dart';

class ConsultarPedidosResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarPedidosResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarPedidosResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarPedidosResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Dados parseados do JSON string
  ParcelamentosData? get dadosParsed {
    try {
      final dadosJson = dados;
      final parsed = ParcelamentosData.fromJson(dadosJson);
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

  /// Verifica se há parcelamentos disponíveis
  bool get temParcelamentos {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.parcelamentos.isNotEmpty ?? false;
  }

  /// Quantidade de parcelamentos encontrados
  int get quantidadeParcelamentos {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.parcelamentos.length ?? 0;
  }

  /// Lista de parcelamentos ativos
  List<Parcelamento> get parcelamentosAtivos {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.parcelamentos.where((p) => p.situacao.toLowerCase().contains('ativo')).toList() ?? [];
  }

  /// Lista de parcelamentos encerrados
  List<Parcelamento> get parcelamentosEncerrados {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.parcelamentos.where((p) => p.situacao.toLowerCase().contains('encerrado')).toList() ?? [];
  }

  @override
  String toString() {
    return 'ConsultarPedidosResponse(status: $status, mensagens: ${mensagens.length}, parcelamentos: $quantidadeParcelamentos)';
  }
}

class ParcelamentosData {
  final List<Parcelamento> parcelamentos;

  ParcelamentosData({required this.parcelamentos});

  factory ParcelamentosData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ParcelamentosData(parcelamentos: (json['parcelamentos'] as List).map((e) => Parcelamento.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'parcelamentos': parcelamentos.map((e) => e.toJson()).toList()};
  }
}

class Parcelamento {
  final int numero;
  final int dataDoPedido;
  final String situacao;
  final int dataDaSituacao;

  Parcelamento({required this.numero, required this.dataDoPedido, required this.situacao, required this.dataDaSituacao});

  factory Parcelamento.fromJson(Map<String, dynamic> json) {
    return Parcelamento(
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao'].toString(),
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'dataDoPedido': dataDoPedido, 'situacao': situacao, 'dataDaSituacao': dataDaSituacao};
  }

  /// Data do pedido formatada (DD/MM/AAAA)
  String get dataDoPedidoFormatada {
    final data = dataDoPedido.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Data da situação formatada (DD/MM/AAAA)
  String get dataDaSituacaoFormatada {
    final data = dataDaSituacao.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Verifica se o parcelamento está ativo
  bool get isAtivo => !situacao.toLowerCase().contains('encerrado');

  /// Verifica se o parcelamento está encerrado
  bool get isEncerrado => situacao.toLowerCase().contains('encerrado');

  @override
  String toString() {
    return 'Parcelamento(numero: $numero, situacao: $situacao, dataPedido: $dataDoPedidoFormatada)';
  }
}
