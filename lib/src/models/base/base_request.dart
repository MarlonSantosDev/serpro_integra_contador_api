class BaseRequest {
  final Contratante contratante;
  final AutorPedidoDados autorPedidoDados;
  final Contribuinte contribuinte;
  final PedidoDados pedidoDados;

  BaseRequest({required this.contratante, required this.autorPedidoDados, required this.contribuinte, required this.pedidoDados});

  factory BaseRequest.fromJson(Map<String, dynamic> json) {
    return BaseRequest(contratante: Contratante.fromJson(json['contratante'] as Map<String, dynamic>), autorPedidoDados: AutorPedidoDados.fromJson(json['autorPedidoDados'] as Map<String, dynamic>), contribuinte: Contribuinte.fromJson(json['contribuinte'] as Map<String, dynamic>), pedidoDados: PedidoDados.fromJson(json['pedidoDados'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'contratante': contratante.toJson(), 'autorPedidoDados': autorPedidoDados.toJson(), 'contribuinte': contribuinte.toJson(), 'pedidoDados': pedidoDados.toJson()};
  }
}

class Contratante {
  final String numero;
  final int tipo;

  Contratante({required this.numero, required this.tipo});

  factory Contratante.fromJson(Map<String, dynamic> json) {
    return Contratante(numero: json['numero'] as String, tipo: json['tipo'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}

class AutorPedidoDados {
  final String numero;
  final int tipo;

  AutorPedidoDados({required this.numero, required this.tipo});

  factory AutorPedidoDados.fromJson(Map<String, dynamic> json) {
    return AutorPedidoDados(numero: json['numero'] as String, tipo: json['tipo'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}

class Contribuinte {
  final String numero;
  final int tipo;

  Contribuinte({required this.numero, required this.tipo});

  factory Contribuinte.fromJson(Map<String, dynamic> json) {
    return Contribuinte(numero: json['numero'] as String, tipo: json['tipo'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo};
  }
}

class PedidoDados {
  final String idSistema;
  final String idServico;
  final String dados;

  PedidoDados({required this.idSistema, required this.idServico, required this.dados});

  factory PedidoDados.fromJson(Map<String, dynamic> json) {
    return PedidoDados(idSistema: json['idSistema'] as String, idServico: json['idServico'] as String, dados: json['dados'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'idSistema': idSistema, 'idServico': idServico, 'dados': dados};
  }
}
