import 'mensagem.dart';

/// Classe base genérica para responses de consulta de pedidos de parcelamento
///
/// Esta classe unifica todas as implementações de ConsultarPedidosResponse
/// que estavam espalhadas pelos diferentes módulos de parcelamento.
class ConsultarPedidosResponse<T> {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;
  final T? dadosParsed;

  ConsultarPedidosResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Factory constructor para criar a partir de JSON
  factory ConsultarPedidosResponse.fromJson(Map<String, dynamic> json, T Function(String)? parser) {
    T? dadosParsed;

    if (parser != null) {
      try {
        dadosParsed = parser(json['dados'].toString());
      } catch (e) {
        // Se não conseguir fazer parse, mantém dadosParsed como null
      }
    }

    return ConsultarPedidosResponse<T>(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
      dadosParsed: dadosParsed,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Verifica se há dados parseados disponíveis
  bool get temDadosParsed => dadosParsed != null;

  @override
  String toString() {
    return 'ConsultarPedidosResponse(status: $status, sucesso: $sucesso, '
        'mensagens: ${mensagens.length}, temDadosParsed: $temDadosParsed)';
  }
}

/// Classe base genérica para responses de consulta de parcelamento
class ConsultarParcelamentoResponse<T> {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;
  final T? dadosParsed;

  ConsultarParcelamentoResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Factory constructor para criar a partir de JSON
  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json, T Function(String)? parser) {
    T? dadosParsed;

    if (parser != null) {
      try {
        dadosParsed = parser(json['dados'].toString());
      } catch (e) {
        // Se não conseguir fazer parse, mantém dadosParsed como null
      }
    }

    return ConsultarParcelamentoResponse<T>(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
      dadosParsed: dadosParsed,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Verifica se há dados parseados disponíveis
  bool get temDadosParsed => dadosParsed != null;

  @override
  String toString() {
    return 'ConsultarParcelamentoResponse(status: $status, sucesso: $sucesso, '
        'mensagens: ${mensagens.length}, temDadosParsed: $temDadosParsed)';
  }
}

/// Classe base genérica para responses de consulta de parcelas
class ConsultarParcelasResponse<T> {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;
  final T? dadosParsed;

  ConsultarParcelasResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Factory constructor para criar a partir de JSON
  factory ConsultarParcelasResponse.fromJson(Map<String, dynamic> json, T Function(String)? parser) {
    T? dadosParsed;

    if (parser != null) {
      try {
        dadosParsed = parser(json['dados'].toString());
      } catch (e) {
        // Se não conseguir fazer parse, mantém dadosParsed como null
      }
    }

    return ConsultarParcelasResponse<T>(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
      dadosParsed: dadosParsed,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Verifica se há dados parseados disponíveis
  bool get temDadosParsed => dadosParsed != null;

  @override
  String toString() {
    return 'ConsultarParcelasResponse(status: $status, sucesso: $sucesso, '
        'mensagens: ${mensagens.length}, temDadosParsed: $temDadosParsed)';
  }
}

/// Classe base genérica para responses de consulta de detalhes de pagamento
class ConsultarDetalhesPagamentoResponse<T> {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;
  final T? dadosParsed;

  ConsultarDetalhesPagamentoResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Factory constructor para criar a partir de JSON
  factory ConsultarDetalhesPagamentoResponse.fromJson(Map<String, dynamic> json, T Function(String)? parser) {
    T? dadosParsed;

    if (parser != null) {
      try {
        dadosParsed = parser(json['dados'].toString());
      } catch (e) {
        // Se não conseguir fazer parse, mantém dadosParsed como null
      }
    }

    return ConsultarDetalhesPagamentoResponse<T>(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
      dadosParsed: dadosParsed,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Verifica se há dados parseados disponíveis
  bool get temDadosParsed => dadosParsed != null;

  @override
  String toString() {
    return 'ConsultarDetalhesPagamentoResponse(status: $status, sucesso: $sucesso, '
        'mensagens: ${mensagens.length}, temDadosParsed: $temDadosParsed)';
  }
}

/// Classe base genérica para responses de emissão de DAS
class EmitirDasResponse<T> {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;
  final T? dadosParsed;

  EmitirDasResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  /// Factory constructor para criar a partir de JSON
  factory EmitirDasResponse.fromJson(Map<String, dynamic> json, T Function(String)? parser) {
    T? dadosParsed;

    if (parser != null) {
      try {
        dadosParsed = parser(json['dados'].toString());
      } catch (e) {
        // Se não conseguir fazer parse, mantém dadosParsed como null
      }
    }

    return EmitirDasResponse<T>(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
      dadosParsed: dadosParsed,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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

  /// Verifica se há dados parseados disponíveis
  bool get temDadosParsed => dadosParsed != null;

  @override
  String toString() {
    return 'EmitirDasResponse(status: $status, sucesso: $sucesso, '
        'mensagens: ${mensagens.length}, temDadosParsed: $temDadosParsed)';
  }
}
