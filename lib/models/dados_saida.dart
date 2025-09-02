import 'package:json_annotation/json_annotation.dart';

part 'dados_saida.g.dart';

/// Converte o código para String, independente do tipo original
String? _stringFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

/// Modelo para dados de saída das operações da API
@JsonSerializable()
class DadosSaida {
  /// Resultado da operação
  @JsonKey(fromJson: _stringFromJson)
  final String? resultado;
  
  /// Dados específicos retornados pela operação
  final Map<String, dynamic>? dados;
  
  /// Status da operação
  @JsonKey(fromJson: _stringFromJson)
  final String? status;
  
  /// Código de retorno
  @JsonKey(fromJson: _stringFromJson)
  final String? codigo;
  
  /// Mensagem descritiva
  @JsonKey(fromJson: _stringFromJson)
  final String? mensagem;
  
  /// Timestamp da resposta
  @JsonKey(name: 'timestamp')
  final DateTime? timestamp;
  
  /// Número do protocolo (quando aplicável)
  @JsonKey(name: 'numero_protocolo', fromJson: _stringFromJson)
  final String? numeroProtocolo;

  const DadosSaida({
    this.resultado,
    this.dados,
    this.status,
    this.codigo,
    this.mensagem,
    this.timestamp,
    this.numeroProtocolo,
  });

  /// Cria uma instância a partir de JSON
  factory DadosSaida.fromJson(Map<String, dynamic> json) =>
      _$DadosSaidaFromJson(json);

  /// Converte para JSON
  Map<String, dynamic> toJson() => _$DadosSaidaToJson(this);

  /// Verifica se a operação foi bem-sucedida
  bool get isSuccess {
    return status?.toLowerCase() == 'sucesso' || 
           status?.toLowerCase() == 'ok' ||
           codigo == '200' ||
           resultado?.toLowerCase() == 'sucesso';
  }

  /// Verifica se a operação está em processamento
  bool get isProcessing {
    return status?.toLowerCase() == 'processando' ||
           status?.toLowerCase() == 'em_andamento' ||
           codigo == '202';
  }

  /// Verifica se houve erro
  bool get hasError {
    return status?.toLowerCase() == 'erro' ||
           status?.toLowerCase() == 'falha' ||
           (codigo != null && !['200', '202'].contains(codigo));
  }

  /// Obtém dados específicos por chave
  T? getDado<T>(String chave) {
    return dados?[chave] as T?;
  }

  /// Obtém situação fiscal (para consultas)
  String? get situacaoFiscal => getDado<String>('situacao_fiscal');

  /// Obtém débitos pendentes (para consultas)
  bool? get debitosPendentes => getDado<bool>('debitos_pendentes');

  /// Obtém razão social (para consultas de empresa)
  String? get razaoSocial => getDado<String>('razao_social');

  /// Obtém número do recibo (para declarações)
  String? get numeroRecibo => getDado<String>('numero_recibo');

  /// Obtém código de barras (para DARF)
  String? get codigoBarras => getDado<String>('codigo_barras');

  /// Obtém linha digitável (para DARF)
  String? get linhaDigitavel => getDado<String>('linha_digitavel');

  /// Obtém valor total (para DARF)
  String? get valorTotal => getDado<String>('valor_total');

  /// Obtém percentual de conclusão (para monitoramento)
  int? get percentualConcluido => getDado<int>('percentual_concluido');

  /// Obtém resultado final (para monitoramento)
  String? get resultadoFinal => getDado<String>('resultado_final');

  /// Obtém mensagem de erro (para monitoramento)
  String? get mensagemErro => getDado<String>('mensagem_erro');

  /// Cria uma cópia com novos valores
  DadosSaida copyWith({
    String? resultado,
    Map<String, dynamic>? dados,
    String? status,
    String? codigo,
    String? mensagem,
    DateTime? timestamp,
    String? numeroProtocolo,
  }) {
    return DadosSaida(
      resultado: resultado ?? this.resultado,
      dados: dados ?? this.dados,
      status: status ?? this.status,
      codigo: codigo ?? this.codigo,
      mensagem: mensagem ?? this.mensagem,
      timestamp: timestamp ?? this.timestamp,
      numeroProtocolo: numeroProtocolo ?? this.numeroProtocolo,
    );
  }

  @override
  String toString() {
    return 'DadosSaida(status: $status, codigo: $codigo, resultado: $resultado, protocolo: $numeroProtocolo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DadosSaida &&
        other.resultado == resultado &&
        other.status == status &&
        other.codigo == codigo &&
        other.numeroProtocolo == numeroProtocolo;
  }

  @override
  int get hashCode {
    return Object.hash(resultado, status, codigo, numeroProtocolo);
  }
}

