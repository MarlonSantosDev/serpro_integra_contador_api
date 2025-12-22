/// Informações extraídas do certificado digital X509
class InformacoesCertificado {
  final String numeroSerie;
  final String assunto;
  final String emissor;
  final DateTime validoDe;
  final DateTime validoAte;
  final bool isICPBrasil;
  final TipoCertificado tipo;
  final String cpfCnpj;

  InformacoesCertificado({
    required this.numeroSerie,
    required this.assunto,
    required this.emissor,
    required this.validoDe,
    required this.validoAte,
    required this.isICPBrasil,
    required this.tipo,
    required this.cpfCnpj,
  });

  /// Verifica se o certificado está dentro do período de validade
  bool get isValido {
    final agora = DateTime.now();
    return agora.isAfter(validoDe) && agora.isBefore(validoAte);
  }

  /// Retorna o nome de exibição do certificado
  String get nomeExibicao =>
      tipo == TipoCertificado.eCPF ? 'e-CPF $cpfCnpj' : 'e-CNPJ $cpfCnpj';

  /// Dias restantes até expiração
  int get diasRestantes {
    if (!isValido) return 0;
    return validoAte.difference(DateTime.now()).inDays;
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'numero_serie': numeroSerie,
    'assunto': assunto,
    'emissor': emissor,
    'valido_de': validoDe.toIso8601String(),
    'valido_ate': validoAte.toIso8601String(),
    'is_icp_brasil': isICPBrasil,
    'tipo': tipo.toString(),
    'cpf_cnpj': cpfCnpj,
    'is_valido': isValido,
    'dias_restantes': diasRestantes,
  };

  @override
  String toString() {
    return 'InformacoesCertificado(tipo: $nomeExibicao, serial: $numeroSerie, '
        'valido: $isValido, ICP-Brasil: $isICPBrasil, dias restantes: $diasRestantes)';
  }
}

/// Tipos de certificado ICP-Brasil
enum TipoCertificado { eCPF, eCNPJ, desconhecido }
