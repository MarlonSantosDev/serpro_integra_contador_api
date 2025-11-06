import 'dart:convert';
import '../../../base/mensagem_negocio.dart';

/// Resposta do serviço DTE - Domicílio Tributário Eletrônico
class DteResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final DteDados? dados;

  DteResponse({required this.status, required this.mensagens, this.dados});

  factory DteResponse.fromJson(Map<String, dynamic> json) {
    final dadosStr = json['dados']?.toString() ?? '';
    DteDados? dadosParsed;

    try {
      if (dadosStr.isNotEmpty) {
        final dadosJson = jsonDecode(dadosStr) as Map<String, dynamic>;
        dadosParsed = DteDados.fromJson(dadosJson);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dadosParsed como null
    }

    return DteResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
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
  bool get temIndicadorValido => dados?.indicadorEnquadramento != null;

  /// Retorna a descrição do status de enquadramento
  String get statusEnquadramentoDescricao => dados?.statusEnquadramento ?? 'Não disponível';

  /// Indica se o contribuinte é optante DTE
  bool get isOptanteDte => dados?.indicadorEnquadramento == 'NI Optante DTE';

  /// Indica se o contribuinte é optante Simples Nacional
  bool get isOptanteSimples => dados?.indicadorEnquadramento == 'NI Optante Simples';

  /// Indica se o contribuinte é optante DTE e Simples Nacional
  bool get isOptanteDteESimples => dados?.indicadorEnquadramento == 'NI Optante DTE e Simples';

  /// Indica se o contribuinte não é optante
  bool get isNaoOptante => dados?.indicadorEnquadramento == 'NI Não optante';

  /// Indica se o NI (Número de Identificação) é inválido
  bool get isNiInvalido => dados?.indicadorEnquadramento == 'NI inválido';
}

/// Dados específicos do DTE
class DteDados {
  final String indicadorEnquadramento;
  final String statusEnquadramento;

  DteDados({required this.indicadorEnquadramento, required this.statusEnquadramento});

  factory DteDados.fromJson(Map<String, dynamic> json) {
    // Converter indicadorEnquadramento numérico para valor descritivo
    final indicadorStr = json['indicadorEnquadramento']?.toString() ?? '';
    final indicadorEnquadramento = switch (indicadorStr) {
      '-2' => 'NI inválido',
      '-1' => 'NI Não optante',
      '0' => 'NI Optante DTE',
      '1' => 'NI Optante Simples',
      '2' => 'NI Optante DTE e Simples',
      _ => 'Indicador desconhecido ($indicadorStr)',
    };

    return DteDados(indicadorEnquadramento: indicadorEnquadramento, statusEnquadramento: json['statusEnquadramento'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'indicadorEnquadramento': indicadorEnquadramento, 'statusEnquadramento': statusEnquadramento};
  }

  /// Retorna a descrição do indicador de enquadramento (mantido para compatibilidade)
  String get indicadorDescricao => indicadorEnquadramento;

  /// Indica se o indicador é válido
  bool get isIndicadorValido {
    return indicadorEnquadramento == 'NI inválido' ||
        indicadorEnquadramento == 'NI Não optante' ||
        indicadorEnquadramento == 'NI Optante DTE' ||
        indicadorEnquadramento == 'NI Optante Simples' ||
        indicadorEnquadramento == 'NI Optante DTE e Simples';
  }
}
