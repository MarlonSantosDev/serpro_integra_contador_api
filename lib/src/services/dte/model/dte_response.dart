import 'dart:convert';
import '../../../base/mensagem_negocio.dart';

/// Resposta do serviço DTE - Domicílio Tributário Eletrônico
class DteResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String dados;
  final DteDados? dadosParsed;

  DteResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  factory DteResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados']?.toString() ?? '';
    DteDados? dadosParsed;

    try {
      if (dados.isNotEmpty) {
        final dadosJson = jsonDecode(dados) as Map<String, dynamic>;
        dadosParsed = DteDados.fromJson(dadosJson);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dadosParsed como null
    }

    return DteResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: dados,
      dadosParsed: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Indica se a requisição foi bem-sucedida
  bool get sucesso => status == 200 && mensagens.any((m) => m.codigo.startsWith('Sucesso-DTE'));

  /// Retorna a mensagem principal (primeira mensagem de sucesso ou erro)
  String get mensagemPrincipal {
    if (mensagens.isEmpty) return 'Sem mensagens';

    final sucessoMsg = mensagens.firstWhere((m) => m.codigo.startsWith('Sucesso-DTE'), orElse: () => mensagens.first);

    return sucessoMsg.texto;
  }

  /// Retorna o código da mensagem principal
  String get codigoMensagem {
    if (mensagens.isEmpty) return 'SEM_CODIGO';
    return mensagens.first.codigo;
  }

  /// Indica se há indicador de enquadramento válido
  bool get temIndicadorValido => dadosParsed?.indicadorEnquadramento != null;

  /// Retorna a descrição do status de enquadramento
  String get statusEnquadramentoDescricao => dadosParsed?.statusEnquadramento ?? 'Não disponível';

  /// Indica se o contribuinte é optante DTE
  bool get isOptanteDte => dadosParsed?.indicadorEnquadramento == 0;

  /// Indica se o contribuinte é optante Simples Nacional
  bool get isOptanteSimples => dadosParsed?.indicadorEnquadramento == 1;

  /// Indica se o contribuinte é optante DTE e Simples Nacional
  bool get isOptanteDteESimples => dadosParsed?.indicadorEnquadramento == 2;

  /// Indica se o contribuinte não é optante
  bool get isNaoOptante => dadosParsed?.indicadorEnquadramento == -1;

  /// Indica se o NI (Número de Identificação) é inválido
  bool get isNiInvalido => dadosParsed?.indicadorEnquadramento == -2;
}

/// Dados específicos do DTE
class DteDados {
  final int indicadorEnquadramento;
  final String statusEnquadramento;

  DteDados({required this.indicadorEnquadramento, required this.statusEnquadramento});

  factory DteDados.fromJson(Map<String, dynamic> json) {
    return DteDados(
      indicadorEnquadramento: int.parse(json['indicadorEnquadramento'].toString()),
      statusEnquadramento: json['statusEnquadramento'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'indicadorEnquadramento': indicadorEnquadramento, 'statusEnquadramento': statusEnquadramento};
  }

  /// Retorna a descrição do indicador de enquadramento
  String get indicadorDescricao {
    switch (indicadorEnquadramento) {
      case -2:
        return 'NI inválido';
      case -1:
        return 'NI Não optante';
      case 0:
        return 'NI Optante DTE';
      case 1:
        return 'NI Optante Simples';
      case 2:
        return 'NI Optante DTE e Simples';
      default:
        return 'Indicador desconhecido ($indicadorEnquadramento)';
    }
  }

  /// Indica se o indicador é válido
  bool get isIndicadorValido => indicadorEnquadramento >= -2 && indicadorEnquadramento <= 2;
}
