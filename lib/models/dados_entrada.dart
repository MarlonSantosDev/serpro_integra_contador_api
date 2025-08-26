import 'package:json_annotation/json_annotation.dart';

part 'dados_entrada.g.dart';

/// Modelo para dados de entrada das operações da API
@JsonSerializable()
class DadosEntrada {
  /// Identificação do sistema ou operação
  final String? identificacao;
  
  /// Dados específicos da operação
  final Map<String, dynamic>? dados;
  
  /// Tipo da operação sendo executada
  final String? tipoOperacao;
  
  /// Versão do protocolo ou API
  final String? versao;
  
  /// Timestamp da requisição
  @JsonKey(name: 'timestamp')
  final DateTime? timestamp;

  const DadosEntrada({
    this.identificacao,
    this.dados,
    this.tipoOperacao,
    this.versao,
    this.timestamp,
  });

  /// Cria uma instância a partir de JSON
  factory DadosEntrada.fromJson(Map<String, dynamic> json) =>
      _$DadosEntradaFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$DadosEntradaToJson(this);

  /// Cria dados de entrada para validação de certificado
  factory DadosEntrada.validacaoCertificado({
    required String certificadoBase64,
    required String senha,
    bool validarCadeia = true,
  }) {
    return DadosEntrada(
      identificacao: 'validacao_certificado',
      tipoOperacao: 'validacao_certificado',
      versao: '1.0',
      timestamp: DateTime.now(),
      dados: {
        'certificado_digital': certificadoBase64,
        'senha_certificado': senha,
        'validar_cadeia': validarCadeia,
      },
    );
  }

  /// Cria dados de entrada para operação de apoio genérica
  factory DadosEntrada.apoioGenerico({
    required String identificacao,
    required String tipoOperacao,
    Map<String, dynamic>? dados,
  }) {
    return DadosEntrada(
      identificacao: identificacao,
      tipoOperacao: tipoOperacao,
      versao: '1.0',
      timestamp: DateTime.now(),
      dados: dados,
    );
  }

  /// Valida se os dados de entrada estão completos
  bool get isValid {
    return identificacao != null && 
           identificacao!.isNotEmpty &&
           tipoOperacao != null && 
           tipoOperacao!.isNotEmpty;
  }

  /// Cria uma cópia com novos valores
  DadosEntrada copyWith({
    String? identificacao,
    Map<String, dynamic>? dados,
    String? tipoOperacao,
    String? versao,
    DateTime? timestamp,
  }) {
    return DadosEntrada(
      identificacao: identificacao ?? this.identificacao,
      dados: dados ?? this.dados,
      tipoOperacao: tipoOperacao ?? this.tipoOperacao,
      versao: versao ?? this.versao,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'DadosEntrada(identificacao: $identificacao, tipoOperacao: $tipoOperacao, versao: $versao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DadosEntrada &&
        other.identificacao == identificacao &&
        other.tipoOperacao == tipoOperacao &&
        other.versao == versao &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(identificacao, tipoOperacao, versao, timestamp);
  }
}

