import 'dart:convert';

/// Modelo de dados de resposta para consultar resolução do regime de caixa
///
/// Representa a resposta do serviço CONSULTARRESOLUCAO104
class ConsultarResolucaoResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio> mensagens;

  /// Dados de retorno contendo o texto da resolução
  final ResolucaoRegimeCaixa? dados;

  ConsultarResolucaoResponse({required this.status, required this.mensagens, this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get isSuccess => status == 200;

  /// Indica se há mensagens de erro
  bool get hasErrors => mensagens.any((m) => m.codigo.contains('Erro'));

  /// Indica se há mensagens de aviso
  bool get hasWarnings => mensagens.any((m) => m.codigo.contains('Aviso'));

  /// Indica se há dados disponíveis
  bool get hasData => dados != null;

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((m) => m.toJson()).toList(), if (dados != null) 'dados': dados!.toJson()};
  }

  factory ConsultarResolucaoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarResolucaoResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList(),
      dados: json['dados'] != null ? ResolucaoRegimeCaixa.fromJson(jsonDecode(json['dados'])) : null,
    );
  }
}

/// Modelo de dados da resolução do regime de caixa
///
/// Representa o texto da resolução específica para regime de caixa
class ResolucaoRegimeCaixa {
  /// Texto fixo da resolução pelo Regime de Caixa em base 64
  final String textoResolucao;

  ResolucaoRegimeCaixa({required this.textoResolucao});

  /// Indica se há texto de resolução disponível
  bool get hasTextoResolucao => textoResolucao.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {'textoResolucao': textoResolucao};
  }

  factory ResolucaoRegimeCaixa.fromJson(Map<String, dynamic> json) {
    return ResolucaoRegimeCaixa(textoResolucao: json['textoResolucao'].toString());
  }
}

/// Modelo de mensagem de negócio específica para regime de apuração
class MensagemNegocio {
  /// Código da mensagem
  final String codigo;

  /// Texto da mensagem
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }
}
