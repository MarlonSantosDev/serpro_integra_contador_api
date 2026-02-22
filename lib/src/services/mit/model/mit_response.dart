import 'dart:convert';
import 'mit_enums.dart';

/// Response base para serviços MIT
class MitResponse {
  /// Código de status da resposta (ex.: "200").
  final String status;

  /// Identificador da resposta.
  final String? responseId;

  /// Data/hora da resposta.
  final String? responseDateTime;

  /// Lista de mensagens retornadas pelo serviço.
  final List<MensagemMit> mensagens;

  /// Construtor para [MitResponse].
  MitResponse({
    required this.status,
    this.responseId,
    this.responseDateTime,
    required this.mensagens,
  });

  /// Cria uma instância de [MitResponse] a partir de um mapa JSON.
  factory MitResponse.fromJson(Map<String, dynamic> json) {
    final mensagens = <MensagemMit>[];
    if (json['mensagens'] != null) {
      for (final msg in json['mensagens']) {
        mensagens.add(MensagemMit.fromJson(msg));
      }
    }

    return MitResponse._internal(
      status: json['status']?.toString() ?? '',
      responseId: json['responseId']?.toString(),
      responseDateTime: json['responseDateTime']?.toString(),
      mensagens: mensagens,
    );
  }

  MitResponse._internal({
    required this.status,
    this.responseId,
    this.responseDateTime,
    required this.mensagens,
  });

  /// Indica se a requisição foi bem-sucedida (status 200).
  bool get sucesso => status == '200';

  /// Texto da primeira mensagem de erro, se houver.
  String? get mensagemErro =>
      mensagens.isNotEmpty ? mensagens.first.texto : null;

  /// Obtém todas as mensagens de sucesso
  List<MensagemMit> get mensagensSucesso =>
      mensagens.where((m) => m.isSucesso).toList();

  /// Obtém todas as mensagens de erro
  List<MensagemMit> get mensagensErro =>
      mensagens.where((m) => m.isErro).toList();

  /// Obtém todas as mensagens de aviso
  List<MensagemMit> get mensagensAviso =>
      mensagens.where((m) => m.isAviso).toList();
}

/// Response para encerrar apuração MIT
class EncerrarApuracaoResponse extends MitResponse {
  /// Protocolo do encerramento.
  final String? protocoloEncerramento;

  /// Identificador da apuração encerrada.
  final int? idApuracao;

  /// Construtor para [EncerrarApuracaoResponse].
  EncerrarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.protocoloEncerramento,
    this.idApuracao,
  });

  /// Cria uma instância a partir de um mapa JSON.
  factory EncerrarApuracaoResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    String? protocoloEncerramento;
    int? idApuracao;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;
        protocoloEncerramento = dados['protocoloEncerramento'] as String?;
        idApuracao = dados['idApuracao'] as int?;
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return EncerrarApuracaoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      protocoloEncerramento: protocoloEncerramento,
      idApuracao: idApuracao,
    );
  }
}

/// Response para consultar situação de encerramento
class ConsultarSituacaoEncerramentoResponse extends MitResponse {
  /// Código da situação do encerramento (1=Em Processamento, 2=Sucesso, 3=Erro, 4=Em andamento).
  final int? situacaoEncerramento;

  /// Construtor para [ConsultarSituacaoEncerramentoResponse].
  ConsultarSituacaoEncerramentoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.situacaoEncerramento,
  });

  /// Cria uma instância a partir de um mapa JSON.
  factory ConsultarSituacaoEncerramentoResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final baseResponse = MitResponse.fromJson(json);

    int? situacaoEncerramento;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;
        situacaoEncerramento = dados['situacaoEncerramento'] as int?;
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ConsultarSituacaoEncerramentoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      situacaoEncerramento: situacaoEncerramento,
    );
  }

  /// Obtém a situação do encerramento como enum
  SituacaoEncerramento? get situacaoEnum => situacaoEncerramento != null
      ? SituacaoEncerramento.fromCodigo(situacaoEncerramento!)
      : null;

  /// Verifica se o encerramento foi concluído
  bool get encerramentoConcluido => situacaoEncerramento == 3;

  /// Verifica se o encerramento está em andamento
  bool get encerramentoEmAndamento => situacaoEncerramento == 4;
}

/// Response para consultar apuração
class ConsultarApuracaoResponse extends MitResponse {
  /// Dados detalhados da apuração, se disponível.
  final ApuracaoDetalhada? apuracao;

  /// Lista de pendências associadas à apuração.
  final List<Pendencia>? pendencias;

  /// Construtor para [ConsultarApuracaoResponse].
  ConsultarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.apuracao,
    this.pendencias,
  });

  /// Cria uma instância a partir de um mapa JSON.
  factory ConsultarApuracaoResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    ApuracaoDetalhada? apuracao;
    List<Pendencia>? pendencias;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;

        if (dados['apuracao'] != null) {
          apuracao = ApuracaoDetalhada.fromJson(dados['apuracao']);
        }

        if (dados['pendencias'] != null) {
          pendencias = (dados['pendencias'] as List)
              .map((item) => Pendencia.fromJson(item))
              .toList();
        }
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ConsultarApuracaoResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      apuracao: apuracao,
      pendencias: pendencias,
    );
  }

  /// Verifica se há pendências
  bool get temPendencias => pendencias != null && pendencias!.isNotEmpty;
}

/// Response para listar apurações
class ListarApuracaoesResponse extends MitResponse {
  /// Lista de resumos das apurações.
  final List<ApuracaoResumo>? apuracoes;

  /// Construtor para [ListarApuracaoesResponse].
  ListarApuracaoesResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.apuracoes,
  });

  /// Cria uma instância a partir de um mapa JSON.
  factory ListarApuracaoesResponse.fromJson(Map<String, dynamic> json) {
    final baseResponse = MitResponse.fromJson(json);

    List<ApuracaoResumo>? apuracoes;

    if (json['dados'] != null) {
      final dadosStr = json['dados'].toString();
      try {
        final dados = jsonDecode(dadosStr) as Map<String, dynamic>;

        if (dados['Apuracoes'] != null) {
          apuracoes = (dados['Apuracoes'] as List)
              .map((item) => ApuracaoResumo.fromJson(item))
              .toList();
        }
      } catch (e) {
        // Se não conseguir decodificar, mantém null
      }
    }

    return ListarApuracaoesResponse(
      status: baseResponse.status,
      responseId: baseResponse.responseId,
      responseDateTime: baseResponse.responseDateTime,
      mensagens: baseResponse.mensagens,
      apuracoes: apuracoes,
    );
  }

  /// Obtém apurações encerradas
  List<ApuracaoResumo> get apuracoesEncerradas =>
      apuracoes
          ?.where((a) => a.situacaoApuracaoEnum == SituacaoApuracao.encerrada)
          .toList() ??
      [];

  /// Obtém apurações em edição
  List<ApuracaoResumo> get apuracoesEmEdicao =>
      apuracoes
          ?.where((a) => a.situacaoApuracaoEnum == SituacaoApuracao.emEdicao)
          .toList() ??
      [];
}

/// Mensagem MIT
class MensagemMit {
  /// Código da mensagem (ex.: [Sucesso-MIT], [Erro-MIT]).
  final String codigo;

  /// Texto da mensagem.
  final String texto;

  /// Construtor para [MensagemMit].
  MensagemMit({required this.codigo, required this.texto});

  /// Cria uma instância a partir de um mapa JSON.
  factory MensagemMit.fromJson(Map<String, dynamic> json) {
    return MensagemMit(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  /// Serializa a mensagem para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSucesso =>
      codigo.contains('[Sucesso-MIT]') || codigo.contains('Sucesso');

  /// Verifica se é uma mensagem de erro
  bool get isErro =>
      codigo.contains('[Erro-MIT]') ||
      codigo.contains('[EntradaIncorreta-MIT]');

  /// Verifica se é uma mensagem de aviso
  bool get isAviso => codigo.contains('[Aviso-MIT]');

  /// Obtém o tipo da mensagem
  String get tipo {
    if (isSucesso) return 'Sucesso';
    if (isErro) return 'Erro';
    if (isAviso) return 'Aviso';
    return 'Informação';
  }
}

/// Apuração detalhada
class ApuracaoDetalhada {
  /// Período de apuração
  final String? periodoApuracao;

  /// Identificador da apuração
  final int? idApuracao;

  /// Situação da apuração
  final int? situacao;

  /// Data de encerramento
  final String? dataEncerramento;

  /// Indica se há evento especial
  final bool? eventoEspecial;

  /// Valor total apurado na apuração.
  final double? valorTotalApurado;

  /// Construtor para criar uma instância de ApuracaoDetalhada
  ///
  /// [periodoApuracao] Período de apuração
  /// [idApuracao] Identificador da apuração
  /// [situacao] Situação da apuração
  /// [dataEncerramento] Data de encerramento
  /// [eventoEspecial] Indica se há evento especial
  /// [valorTotalApurado] Valor total apurado
  ApuracaoDetalhada({
    this.periodoApuracao,
    this.idApuracao,
    this.situacao,
    this.dataEncerramento,
    this.eventoEspecial,
    this.valorTotalApurado,
  });

  /// Cria uma instância de ApuracaoDetalhada a partir de um mapa JSON
  ///
  /// [json] Mapa contendo os dados da apuração detalhada
  /// Retorna uma nova instância de [ApuracaoDetalhada]
  factory ApuracaoDetalhada.fromJson(Map<String, dynamic> json) {
    return ApuracaoDetalhada(
      periodoApuracao: json['periodoApuracao']?.toString(),
      idApuracao: json['idApuracao'] as int?,
      situacao: json['situacao'] as int?,
      dataEncerramento: json['dataEncerramento']?.toString(),
      eventoEspecial: json['eventoEspecial'] as bool?,
      valorTotalApurado: json['valorTotalApurado'] != null
          ? (json['valorTotalApurado'] as num).toDouble()
          : null,
    );
  }

  /// Situação da apuração como enum [SituacaoApuracao].
  SituacaoApuracao? get situacaoEnum =>
      situacao != null ? SituacaoApuracao.fromCodigo(situacao!) : null;
}

/// Pendência da apuração
class Pendencia {
  /// Código da pendência.
  final String? codigo;

  /// Texto descritivo da pendência.
  final String? texto;

  /// Construtor para [Pendencia].
  Pendencia({this.codigo, this.texto});

  /// Cria uma instância a partir de um mapa JSON.
  factory Pendencia.fromJson(Map<String, dynamic> json) {
    return Pendencia(
      codigo: json['codigo']?.toString(),
      texto: json['texto']?.toString(),
    );
  }

  /// Serializa a pendência para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}

/// Resumo da apuração para listagem
class ApuracaoResumo {
  /// Período de apuração.
  final String? periodoApuracao;

  /// Identificador da apuração.
  final int? idApuracao;

  /// Situação descritiva (ex.: "Em Processamento", "Processado com Sucesso").
  final String? situacao;

  /// Código numérico da situação.
  final int? situacaoInt;

  /// Data de encerramento da apuração.
  final String? dataEncerramento;

  /// Indica se há evento especial.
  final bool? eventoEspecial;

  /// Valor total apurado.
  final double? valorTotalApurado;

  /// Construtor para criar uma instância de [ApuracaoResumo].
  ApuracaoResumo({
    this.periodoApuracao,
    this.idApuracao,
    this.situacao,
    this.situacaoInt,
    this.dataEncerramento,
    this.eventoEspecial,
    this.valorTotalApurado,
  });

  /// Cria uma instância de [ApuracaoResumo] a partir de um mapa JSON.
  ///
  /// [json] Mapa contendo os dados do resumo da apuração.
  factory ApuracaoResumo.fromJson(Map<String, dynamic> json) {
    // Converter situacao numérica para valor descritivo
    final situacaoInt = json['situacao'] as int?;
    final situacao = situacaoInt != null
        ? switch (situacaoInt) {
            1 => 'Em Processamento',
            2 => 'Processado com Sucesso',
            3 => 'Processado com Erro',
            _ => situacaoInt.toString(),
          }
        : null;

    return ApuracaoResumo(
      periodoApuracao: json['periodoApuracao']?.toString(),
      idApuracao: json['idApuracao'] as int?,
      situacao: situacao,
      situacaoInt: situacaoInt,
      dataEncerramento: json['dataEncerramento']?.toString(),
      eventoEspecial: json['eventoEspecial'] as bool?,
      valorTotalApurado: json['valorTotalApurado'] != null
          ? (json['valorTotalApurado'] as num).toDouble()
          : null,
    );
  }

  /// Situação do encerramento como enum [SituacaoEncerramento].
  SituacaoEncerramento? get situacaoEnum {
    if (situacao == null) return null;
    return switch (situacao) {
      'Em Processamento' => SituacaoEncerramento.emProcessamento,
      'Processado com Sucesso' => SituacaoEncerramento.processadoComSucesso,
      'Processado com Erro' => SituacaoEncerramento.processadoComErro,
      _ => null,
    };
  }

  /// Obtém a situação da apuração como enum [SituacaoApuracao].
  SituacaoApuracao? get situacaoApuracaoEnum =>
      situacaoInt != null ? SituacaoApuracao.fromCodigo(situacaoInt!) : null;
}

/// Enum para situação de encerramento
enum SituacaoEncerramento {
  /// Em processamento
  emProcessamento(1, 'Em Processamento'),

  /// Processado com sucesso
  processadoComSucesso(2, 'Processado com Sucesso'),

  /// Processado com erro
  processadoComErro(3, 'Processado com Erro');

  const SituacaoEncerramento(this.codigo, this.descricao);

  /// Código numérico da situação.
  final int codigo;

  /// Descrição da situação.
  final String descricao;

  /// Obtém o enum a partir do código numérico.
  static SituacaoEncerramento? fromCodigo(int codigo) {
    for (final situacao in SituacaoEncerramento.values) {
      if (situacao.codigo == codigo) return situacao;
    }
    return null;
  }
}
