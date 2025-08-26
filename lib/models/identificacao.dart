import 'package:json_annotation/json_annotation.dart';
import 'tipo_ni.dart';

part 'identificacao.g.dart';

/// Modelo para identificação de contribuintes
@JsonSerializable()
class Identificacao {
  /// CPF do contribuinte (apenas números)
  final String? cpf;
  
  /// CNPJ do contribuinte (apenas números)
  final String? cnpj;
  
  /// Tipo de número de identificação
  final TipoNi? tipoNi;
  
  /// Número de identificação genérico
  final String? numero;

  const Identificacao({
    this.cpf,
    this.cnpj,
    this.tipoNi,
    this.numero,
  });

  /// Cria uma instância a partir de JSON
  factory Identificacao.fromJson(Map<String, dynamic> json) =>
      _$IdentificacaoFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$IdentificacaoToJson(this);

  /// Cria identificação para pessoa física
  factory Identificacao.cpf(String cpf, {TipoNi? tipoNi}) {
    return Identificacao(
      cpf: cpf.replaceAll(RegExp(r'[^0-9]'), ''),
      tipoNi: tipoNi ?? TipoNi.cpf(),
    );
  }

  /// Cria identificação para pessoa jurídica
  factory Identificacao.cnpj(String cnpj, {TipoNi? tipoNi}) {
    return Identificacao(
      cnpj: cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
      tipoNi: tipoNi ?? TipoNi.cnpj(),
    );
  }

  /// Valida se a identificação está completa
  bool get isValid {
    if (cpf != null && cpf!.isNotEmpty) {
      return _isValidCpf(cpf!);
    }
    if (cnpj != null && cnpj!.isNotEmpty) {
      return _isValidCnpj(cnpj!);
    }
    return numero != null && numero!.isNotEmpty;
  }

  /// Retorna o tipo de identificação
  String get tipo {
    if (cpf != null && cpf!.isNotEmpty) return 'CPF';
    if (cnpj != null && cnpj!.isNotEmpty) return 'CNPJ';
    return 'OUTRO';
  }

  /// Retorna o número formatado
  String get numeroFormatado {
    if (cpf != null && cpf!.isNotEmpty) {
      return _formatCpf(cpf!);
    }
    if (cnpj != null && cnpj!.isNotEmpty) {
      return _formatCnpj(cnpj!);
    }
    return numero ?? '';
  }

  /// Valida CPF
  bool _isValidCpf(String cpf) {
    if (cpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    
    // Calcula primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;
    
    // Calcula segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;
    
    return int.parse(cpf[9]) == firstDigit && int.parse(cpf[10]) == secondDigit;
  }

  /// Valida CNPJ
  bool _isValidCnpj(String cnpj) {
    if (cnpj.length != 14) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;
    
    // Calcula primeiro dígito verificador
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;
    
    // Calcula segundo dígito verificador
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;
    
    return int.parse(cnpj[12]) == firstDigit && int.parse(cnpj[13]) == secondDigit;
  }

  /// Formata CPF
  String _formatCpf(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  /// Formata CNPJ
  String _formatCnpj(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }

  @override
  String toString() {
    return 'Identificacao(tipo: $tipo, numero: $numeroFormatado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Identificacao &&
        other.cpf == cpf &&
        other.cnpj == cnpj &&
        other.tipoNi == tipoNi &&
        other.numero == numero;
  }

  @override
  int get hashCode {
    return Object.hash(cpf, cnpj, tipoNi, numero);
  }
}

