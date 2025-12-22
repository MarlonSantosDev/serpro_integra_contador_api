import 'dart:convert';
import 'mit_enums.dart';

/// Response base para serviços MIT
class MitResponse {
  final String status;
  final String? responseId;
  final String? responseDateTime;
  final List<MensagemMit> mensagens;

  MitResponse({
    required this.status,
    this.responseId,
    this.responseDateTime,
    required this.mensagens,
  });

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

  bool get sucesso => status == '200';
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
  final String? protocoloEncerramento;
  final int? idApuracao;

  EncerrarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.protocoloEncerramento,
    this.idApuracao,
  });

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
  final int? situacaoEncerramento;

  ConsultarSituacaoEncerramentoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.situacaoEncerramento,
  });

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
  final ApuracaoDetalhada? apuracao;
  final List<Pendencia>? pendencias;

  ConsultarApuracaoResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.apuracao,
    this.pendencias,
  });

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
  final List<ApuracaoResumo>? apuracoes;

  ListarApuracaoesResponse({
    required super.status,
    super.responseId,
    super.responseDateTime,
    required super.mensagens,
    this.apuracoes,
  });

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
  final String codigo;
  final String texto;

  MensagemMit({required this.codigo, required this.texto});

  factory MensagemMit.fromJson(Map<String, dynamic> json) {
    return MensagemMit(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

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
  final String? periodoApuracao;
  final int? idApuracao;
  final int? situacao;
  final String? dataEncerramento;
  final bool? eventoEspecial;
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

  SituacaoApuracao? get situacaoEnum =>
      situacao != null ? SituacaoApuracao.fromCodigo(situacao!) : null;
}

/// Pendência da apuração
class Pendencia {
  final String? codigo;
  final String? texto;

  Pendencia({this.codigo, this.texto});

  factory Pendencia.fromJson(Map<String, dynamic> json) {
    return Pendencia(
      codigo: json['codigo']?.toString(),
      texto: json['texto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}

/// Resumo da apuração para listagem
class ApuracaoResumo {
  final String? periodoApuracao;
  final int? idApuracao;
  final String? situacao;
  final int? situacaoInt;
  final String? dataEncerramento;
  final bool? eventoEspecial;
  final double? valorTotalApurado;

  ApuracaoResumo({
    this.periodoApuracao,
    this.idApuracao,
    this.situacao,
    this.situacaoInt,
    this.dataEncerramento,
    this.eventoEspecial,
    this.valorTotalApurado,
  });

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

  SituacaoEncerramento? get situacaoEnum {
    if (situacao == null) return null;
    return switch (situacao) {
      'Em Processamento' => SituacaoEncerramento.emProcessamento,
      'Processado com Sucesso' => SituacaoEncerramento.processadoComSucesso,
      'Processado com Erro' => SituacaoEncerramento.processadoComErro,
      _ => null,
    };
  }

  /// Obtém a situação da apuração como enum SituacaoApuracao
  SituacaoApuracao? get situacaoApuracaoEnum =>
      situacaoInt != null ? SituacaoApuracao.fromCodigo(situacaoInt!) : null;
}

/// Enum para situação de encerramento
enum SituacaoEncerramento {
  emProcessamento(1, 'Em Processamento'),
  processadoComSucesso(2, 'Processado com Sucesso'),
  processadoComErro(3, 'Processado com Erro');

  const SituacaoEncerramento(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static SituacaoEncerramento? fromCodigo(int codigo) {
    for (final situacao in SituacaoEncerramento.values) {
      if (situacao.codigo == codigo) return situacao;
    }
    return null;
  }
}
