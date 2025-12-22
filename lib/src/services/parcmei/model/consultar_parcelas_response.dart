import 'dart:convert';
import 'mensagem.dart';

class ConsultarParcelasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ListaParcelasData? dados;

  ConsultarParcelasResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

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
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

  /// Quantidade de parcelas disponíveis
  int get quantidadeParcelas {
    return dados?.listaParcelas.length ?? 0;
  }

  /// Valor total das parcelas disponíveis formatado
  String get valorTotalParcelasFormatado {
    final total =
        dados?.listaParcelas.fold<double>(
          0.0,
          (sum, parcela) => sum + parcela.valor,
        ) ??
        0.0;
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Lista de parcelas ordenadas por período
  List<Parcela> get parcelasOrdenadas {
    final parcelas = dados?.listaParcelas ?? [];
    parcelas.sort((a, b) => a.parcela.compareTo(b.parcela));
    return parcelas;
  }

  /// Parcela com menor valor
  Parcela? get parcelaMenorValor {
    if (dados?.listaParcelas.isEmpty ?? true) return null;

    return dados!.listaParcelas.reduce((a, b) => a.valor < b.valor ? a : b);
  }

  /// Parcela com maior valor
  Parcela? get parcelaMaiorValor {
    if (dados?.listaParcelas.isEmpty ?? true) return null;

    return dados!.listaParcelas.reduce((a, b) => a.valor > b.valor ? a : b);
  }

  /// Verifica se todas as parcelas têm o mesmo valor
  bool get todasParcelasMesmoValor {
    final parcelas = dados?.listaParcelas ?? [];
    if (parcelas.length <= 1) return true;

    final primeiroValor = parcelas.first.valor;
    return parcelas.every((parcela) => parcela.valor == primeiroValor);
  }
}

class ListaParcelasData {
  final List<Parcela> listaParcelas;

  ListaParcelasData({required this.listaParcelas});

  factory ListaParcelasData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;

      return ListaParcelasData(
        listaParcelas:
            (json['listaParcelas'] as List?)
                ?.map((e) => Parcela.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      return ListaParcelasData(listaParcelas: []);
    }
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
    return Parcela(
      parcela: int.tryParse(json['parcela']?.toString() ?? '0') ?? 0,
      valor: double.tryParse(json['valor']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'parcela': parcela, 'valor': valor};
  }

  /// Formata o período da parcela (AAAAMM)
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

  /// Ano da parcela
  int get ano {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.tryParse(parcelaStr.substring(0, 4)) ?? 0;
    }
    return 0;
  }

  /// Mês da parcela
  int get mes {
    final parcelaStr = parcela.toString();
    if (parcelaStr.length == 6) {
      return int.tryParse(parcelaStr.substring(4, 6)) ?? 0;
    }
    return 0;
  }

  /// Nome do mês da parcela
  String get nomeMes {
    const meses = [
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
    return mes > 0 && mes <= 12 ? meses[mes] : '';
  }

  /// Descrição completa da parcela
  String get descricaoCompleta {
    return '$parcelaFormatada ($nomeMes $ano) - $valorFormatado';
  }

  /// Verifica se a parcela é do ano atual
  bool get isAnoAtual {
    final anoAtual = DateTime.now().year;
    return ano == anoAtual;
  }

  /// Verifica se a parcela é de um ano passado
  bool get isAnoPassado {
    final anoAtual = DateTime.now().year;
    return ano < anoAtual;
  }

  /// Verifica se a parcela é de um ano futuro
  bool get isAnoFuturo {
    final anoAtual = DateTime.now().year;
    return ano > anoAtual;
  }

  @override
  String toString() {
    return 'Parcela $parcelaFormatada: $valorFormatado';
  }
}
