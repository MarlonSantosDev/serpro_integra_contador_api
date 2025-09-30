import 'regime_apuracao_enums.dart';

/// Modelo de dados de resposta para efetuar opção pelo regime de apuração
///
/// Representa a resposta do serviço EFETUAROPCAOREGIME101
class EfetuarOpcaoRegimeResponse {
  /// Status HTTP retornado no acionamento do serviço
  final int status;

  /// Mensagens explicativas retornadas no acionamento do serviço
  final List<MensagemNegocio> mensagens;

  /// Dados de retorno contendo informações do regime de apuração
  final RegimeApuracao? dados;

  EfetuarOpcaoRegimeResponse({required this.status, required this.mensagens, this.dados});

  /// Indica se a operação foi bem-sucedida
  bool get isSuccess => status == 200;

  /// Indica se há mensagens de erro
  bool get hasErrors => mensagens.any((m) => m.codigo.contains('Erro'));

  /// Indica se há mensagens de aviso
  bool get hasWarnings => mensagens.any((m) => m.codigo.contains('Aviso'));

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((m) => m.toJson()).toList(), if (dados != null) 'dados': dados!.toJson()};
  }

  factory EfetuarOpcaoRegimeResponse.fromJson(Map<String, dynamic> json) {
    return EfetuarOpcaoRegimeResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List).map((m) => MensagemNegocio.fromJson(m)).toList(),
      dados: json['dados'] != null ? RegimeApuracao.fromJson(json['dados']) : null,
    );
  }
}

/// Modelo de dados do regime de apuração
///
/// Representa as informações do regime de apuração efetivado
class RegimeApuracao {
  /// CNPJ da matriz
  final String cnpjMatriz;

  /// Ano calendário solicitado
  final int anoCalendario;

  /// Texto com o regime escolhido: "COMPETENCIA" ou "CAIXA"
  final String regimeEscolhido;

  /// Data e horário da opção no formato AAAAMMDDHHMMSS
  final int dataHoraOpcao;

  /// Demonstrativo de opção de Regime em formato base 64
  final String? demonstrativoPdf;

  /// Texto da resolução (no caso de regime de CAIXA) em formato base 64
  final String? textoResolucao;

  RegimeApuracao({
    required this.cnpjMatriz,
    required this.anoCalendario,
    required this.regimeEscolhido,
    required this.dataHoraOpcao,
    this.demonstrativoPdf,
    this.textoResolucao,
  });

  /// Converte o regime escolhido para enum
  TipoRegime? get tipoRegime => TipoRegime.fromDescricao(regimeEscolhido);

  /// Converte dataHoraOpcao para DateTime
  DateTime? get dataOpcao {
    try {
      final dataStr = dataHoraOpcao.toString();
      if (dataStr.length == 14) {
        final ano = int.parse(dataStr.substring(0, 4));
        final mes = int.parse(dataStr.substring(4, 6));
        final dia = int.parse(dataStr.substring(6, 8));
        final hora = int.parse(dataStr.substring(8, 10));
        final minuto = int.parse(dataStr.substring(10, 12));
        final segundo = int.parse(dataStr.substring(12, 14));
        return DateTime(ano, mes, dia, hora, minuto, segundo);
      }
    } catch (e) {
      // Ignora erros de conversão
    }
    return null;
  }

  /// Indica se há demonstrativo PDF disponível
  bool get hasDemonstrativoPdf => demonstrativoPdf != null && demonstrativoPdf!.isNotEmpty;

  /// Indica se há texto de resolução disponível
  bool get hasTextoResolucao => textoResolucao != null && textoResolucao!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'cnpjMatriz': cnpjMatriz,
      'anoCalendario': anoCalendario,
      'regimeEscolhido': regimeEscolhido,
      'dataHoraOpcao': dataHoraOpcao,
      if (demonstrativoPdf != null) 'demonstrativoPdf': demonstrativoPdf,
      if (textoResolucao != null) 'textoResolucao': textoResolucao,
    };
  }

  factory RegimeApuracao.fromJson(Map<String, dynamic> json) {
    return RegimeApuracao(
      cnpjMatriz: json['cnpjMatriz'].toString(),
      anoCalendario: int.parse(json['anoCalendario'].toString()),
      regimeEscolhido: json['regimeEscolhido'].toString(),
      dataHoraOpcao: int.parse(json['dataHoraOpcao'].toString()),
      demonstrativoPdf: json['demonstrativoPdf']?.toString(),
      textoResolucao: json['textoResolucao']?.toString(),
    );
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
