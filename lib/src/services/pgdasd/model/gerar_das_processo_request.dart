/// Modelo de dados para gerar DAS de Processo PGDASD
///
/// Representa os dados necessários para gerar um DAS de Processo através do serviço GERARDASPROCESSO18
class GerarDasProcessoRequest {
  /// Número do processo
  final String numeroProcesso;

  GerarDasProcessoRequest({required this.numeroProcesso});

  /// Valida se o número do processo está no formato correto (17 dígitos)
  bool get isNumeroProcessoValido {
    if (numeroProcesso.length != 17) return false;
    if (!RegExp(r'^\d{17}$').hasMatch(numeroProcesso)) return false;
    return true;
  }

  /// Valida se todos os campos estão corretos
  bool get isValid => isNumeroProcessoValido;

  Map<String, dynamic> toJson() {
    return {'numeroProcesso': numeroProcesso};
  }

  factory GerarDasProcessoRequest.fromJson(Map<String, dynamic> json) {
    return GerarDasProcessoRequest(
      numeroProcesso: json['numeroProcesso'].toString(),
    );
  }
}
