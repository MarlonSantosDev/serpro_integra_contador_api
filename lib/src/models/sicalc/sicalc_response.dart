import 'consolidar_darf_response.dart';
import 'consultar_receita_response.dart';
import 'gerar_codigo_barras_response.dart';

/// Classe base para respostas do SICALC
class SicalcResponse {
  final int status;
  final List<String> mensagens;

  SicalcResponse({required this.status, required this.mensagens});

  factory SicalcResponse.fromJson(Map<String, dynamic> json) {
    return SicalcResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens};
  }

  /// Indica se a operação foi bem-sucedida
  bool get sucesso => status == 200;

  /// Retorna a mensagem principal (primeira mensagem)
  String get mensagemPrincipal => mensagens.isNotEmpty ? mensagens.first : '';

  @override
  String toString() {
    return 'SicalcResponse(status: $status, sucesso: $sucesso)';
  }
}

/// Tipos de resposta específicos do SICALC
typedef ConsolidarDarfSicalcResponse = ConsolidarDarfResponse;
typedef ConsultarReceitaSicalcResponse = ConsultarReceitaResponse;
typedef GerarCodigoBarrasSicalcResponse = GerarCodigoBarrasResponse;
