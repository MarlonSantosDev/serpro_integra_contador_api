import 'dart:convert';
import 'base_response.dart';

/// Modelo de resposta para DIVIDAATIVA24 - Consultar Dívida Ativa
///
/// Representa a resposta do serviço DIVIDAATIVA24 que consulta
/// se o contribuinte está em dívida ativa
class ConsultarDividaAtivaResponse extends PgmeiBaseResponse {
  ConsultarDividaAtivaResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como lista de débitos em dívida ativa
  List<Debito>? get debitosDividaAtiva {
    try {
      if (dados.isEmpty) return [];

      final dadosList = jsonDecode(dados) as List;
      return dadosList.map((d) => Debito.fromJson(d)).toList();
    } catch (e) {
      print('Erro ao parsear débitos dívida ativa: $e');
      return null;
    }
  }

  /// Indica se existem débitos em dívida ativa
  bool get temDebitosDividaAtiva => debitosDividaAtiva != null && debitosDividaAtiva!.isNotEmpty;

  /// Retorna apenas os débitos de um tributo específico
  List<Debito>? getDebitoTributo(String tributo) {
    final debitos = debitosDividaAtiva;
    if (debitos == null) return null;
    return debitos.where((d) => d.tributo.toLowerCase() == tributo.toLowerCase()).toList();
  }

  /// Retorna o valor total em dívida ativa
  double get valorTotalDividaAtiva {
    final debitos = debitosDividaAtiva;
    if (debitos == null) return 0.0;
    return debitos.fold(0.0, (total, debito) => total + debito.valor);
  }

  factory ConsultarDividaAtivaResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDividaAtivaResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((m) => Mensagem.fromJson(m)).toList(),
      dados: json['dados'].toString(),
    );
  }
}

/// Débito em dívida ativa
class Debito {
  /// Período de apuração em formato AAAAMM
  final String periodoApuracao;

  /// Nome do tributo com débito em Dívida Ativa (ex: "INSS")
  final String tributo;

  /// Valor do tributo
  final double valor;

  /// Nome do ente federado onde há o débito (ex: "União")
  final String enteFederado;

  /// Texto descrevendo a situação da dívida do tributo (ex: "Enviado à PFN")
  final String situacaoDebito;

  Debito({required this.periodoApuracao, required this.tributo, required this.valor, required this.enteFederado, required this.situacaoDebito});

  Map<String, dynamic> toJson() {
    return {'periodoApuracao': periodoApuracao, 'tributo': tributo, 'valor': valor, 'enteFederado': enteFederado, 'situacaoDebito': situacaoDebito};
  }

  factory Debito.fromJson(Map<String, dynamic> json) {
    return Debito(
      periodoApuracao: json['periodoApuracao'].toString(),
      tributo: json['tributo'].toString(),
      valor: double.parse(json['valor'].toString()),
      enteFederado: json['enteFederado'].toString(),
      situacaoDebito: json['situacaoDebito'].toString(),
    );
  }
}
