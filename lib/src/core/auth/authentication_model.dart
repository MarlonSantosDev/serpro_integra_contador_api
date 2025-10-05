import '../../util/validations_utils.dart';

class AuthenticationModel {
  final String accessToken;
  final String jwtToken;
  final int expiresIn;

  // Dados do contratante (empresa que contratou o serviço na Loja Serpro)
  final String contratanteNumero;
  final int contratanteTipo;

  // Dados do autor do pedido (quem está fazendo a requisição)
  final String autorPedidoDadosNumero;
  final int autorPedidoDadosTipo;

  AuthenticationModel({
    required this.accessToken,
    required this.jwtToken,
    required this.expiresIn,
    required this.contratanteNumero,
    required this.autorPedidoDadosNumero,
  }) : contratanteTipo = DocumentUtils.detectDocumentType(contratanteNumero),
       autorPedidoDadosTipo = DocumentUtils.detectDocumentType(autorPedidoDadosNumero);

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      accessToken: json['access_token'] as String,
      jwtToken: json['jwt_token'] as String,
      expiresIn: json['expires_in'] as int,
      contratanteNumero: json['contratante_numero'] as String,
      autorPedidoDadosNumero: json['autor_pedido_dados_numero'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'jwt_token': jwtToken,
      'expires_in': expiresIn,
      'contratante_numero': contratanteNumero,
      'contratante_tipo': contratanteTipo,
      'autor_pedido_dados_numero': autorPedidoDadosNumero,
      'autor_pedido_dados_tipo': autorPedidoDadosTipo,
    };
  }
}
