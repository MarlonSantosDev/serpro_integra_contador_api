import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter detalhes de uma mensagem específica
class DetalhesMensagemResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String dados;
  final DadosDetalhesMensagem? dadosParsed;

  DetalhesMensagemResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
    this.dadosParsed,
  });

  factory DetalhesMensagemResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'].toString();
    DadosDetalhesMensagem? dadosParsed;

    try {
      final dadosJson = jsonDecode(dados);
      dadosParsed = DadosDetalhesMensagem.fromJson(dadosJson);
    } catch (e) {
      // Se não conseguir parsear, mantém dados como string
    }

    return DetalhesMensagemResponse(
      status: int.parse(json['status']),
      mensagens: (json['mensagens'] as List<dynamic>? ?? [])
          .map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: dados,
      dadosParsed: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados,
    };
  }
}

/// Dados parseados do campo 'dados' para detalhes de mensagem
class DadosDetalhesMensagem {
  final String codigo;
  final List<DetalheMensagemCompleta> conteudo;

  DadosDetalhesMensagem({required this.codigo, required this.conteudo});

  factory DadosDetalhesMensagem.fromJson(Map<String, dynamic> json) {
    return DadosDetalhesMensagem(
      codigo: json['codigo'] as String,
      conteudo: (json['conteudo'] as List<dynamic>? ?? [])
          .map(
            (e) => DetalheMensagemCompleta.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'conteudo': conteudo.map((e) => e.toJson()).toList(),
    };
  }
}

/// Detalhes completos de uma mensagem
class DetalheMensagemCompleta {
  final String codigoSistemaRemetente;
  final String codigoModelo;
  final String assuntoModelo;
  final String origemModelo;
  final String dataEnvio;
  final String valorParametroAssunto;
  final String dataLeitura;
  final String horaLeitura;
  final String dataExpiracao;
  final String numeroControle;
  final String dataCiencia;
  final String enquadramento;
  final String dataAcessoExterno;
  final String horaAcessoExterno;
  final String tipoAutenticacaoUsuario;
  final String codigoAcesso;
  final String numeroSerieCertificadoDigital;
  final String emissorCertificadoDigital;
  final String tipoUsuario;
  final String niUsuario;
  final String papelUsuario;
  final String codigoAplicacao;
  final String tipoOrigem;
  final String descricaoOrigem;
  final String corpoModelo;
  final List<String> variaveis;
  final String? indFavorito;

  DetalheMensagemCompleta({
    required this.codigoSistemaRemetente,
    required this.codigoModelo,
    required this.assuntoModelo,
    required this.origemModelo,
    required this.dataEnvio,
    required this.valorParametroAssunto,
    required this.dataLeitura,
    required this.horaLeitura,
    required this.dataExpiracao,
    required this.numeroControle,
    required this.dataCiencia,
    required this.enquadramento,
    required this.dataAcessoExterno,
    required this.horaAcessoExterno,
    required this.tipoAutenticacaoUsuario,
    required this.codigoAcesso,
    required this.numeroSerieCertificadoDigital,
    required this.emissorCertificadoDigital,
    required this.tipoUsuario,
    required this.niUsuario,
    required this.papelUsuario,
    required this.codigoAplicacao,
    required this.tipoOrigem,
    required this.descricaoOrigem,
    required this.corpoModelo,
    required this.variaveis,
    this.indFavorito,
  });

  factory DetalheMensagemCompleta.fromJson(Map<String, dynamic> json) {
    return DetalheMensagemCompleta(
      codigoSistemaRemetente: json['codigoSistemaRemetente'] as String? ?? '',
      codigoModelo: json['codigoModelo'] as String? ?? '',
      assuntoModelo: json['assuntoModelo'] as String? ?? '',
      origemModelo: json['origemModelo'] as String? ?? '',
      dataEnvio: json['dataEnvio'] as String? ?? '',
      valorParametroAssunto: json['valorParametroAssunto'] as String? ?? '',
      dataLeitura: json['dataLeitura'] as String? ?? '',
      horaLeitura: json['horaLeitura'] as String? ?? '',
      dataExpiracao: json['dataExpiracao'] as String? ?? '',
      numeroControle: json['numeroControle'] as String? ?? '',
      dataCiencia: json['dataCiencia'] as String? ?? '',
      enquadramento: json['enquadramento'] as String? ?? '',
      dataAcessoExterno: json['dataAcessoExterno'] as String? ?? '',
      horaAcessoExterno: json['horaAcessoExterno'] as String? ?? '',
      tipoAutenticacaoUsuario: json['tipoAutenticacaoUsuario'] as String? ?? '',
      codigoAcesso: json['codigoAcesso'] as String? ?? '',
      numeroSerieCertificadoDigital:
          json['numeroSerieCertificadoDigital'] as String? ?? '',
      emissorCertificadoDigital:
          json['emissorCertificadoDigital'] as String? ?? '',
      tipoUsuario: json['tipoUsuario'] as String? ?? '',
      niUsuario: json['niUsuario'] as String? ?? '',
      papelUsuario: json['papelUsuario'] as String? ?? '',
      codigoAplicacao: json['codigoAplicacao'] as String? ?? '',
      tipoOrigem: json['tipoOrigem'] as String? ?? '',
      descricaoOrigem: json['descricaoOrigem'] as String? ?? '',
      corpoModelo: json['corpoModelo'] as String? ?? '',
      variaveis: (json['variaveis'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      indFavorito: json['indFavorito'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigoSistemaRemetente': codigoSistemaRemetente,
      'codigoModelo': codigoModelo,
      'assuntoModelo': assuntoModelo,
      'origemModelo': origemModelo,
      'dataEnvio': dataEnvio,
      'valorParametroAssunto': valorParametroAssunto,
      'dataLeitura': dataLeitura,
      'horaLeitura': horaLeitura,
      'dataExpiracao': dataExpiracao,
      'numeroControle': numeroControle,
      'dataCiencia': dataCiencia,
      'enquadramento': enquadramento,
      'dataAcessoExterno': dataAcessoExterno,
      'horaAcessoExterno': horaAcessoExterno,
      'tipoAutenticacaoUsuario': tipoAutenticacaoUsuario,
      'codigoAcesso': codigoAcesso,
      'numeroSerieCertificadoDigital': numeroSerieCertificadoDigital,
      'emissorCertificadoDigital': emissorCertificadoDigital,
      'tipoUsuario': tipoUsuario,
      'niUsuario': niUsuario,
      'papelUsuario': papelUsuario,
      'codigoAplicacao': codigoAplicacao,
      'tipoOrigem': tipoOrigem,
      'descricaoOrigem': descricaoOrigem,
      'corpoModelo': corpoModelo,
      'variaveis': variaveis,
      'indFavorito': indFavorito,
    };
  }

  /// Verifica se a mensagem é favorita
  bool get isFavorita => indFavorito == '1';

  /// Obtém o assunto processado com as variáveis substituídas
  String get assuntoProcessado {
    if (valorParametroAssunto.isEmpty) return assuntoModelo;
    return assuntoModelo.replaceAll('++VARIAVEL++', valorParametroAssunto);
  }

  /// Obtém o corpo da mensagem com as variáveis substituídas
  String get corpoProcessado {
    if (variaveis.isEmpty) return corpoModelo;

    String corpo = corpoModelo;
    for (int i = 0; i < variaveis.length; i++) {
      final placeholder = '++${i + 1}++';
      corpo = corpo.replaceAll(placeholder, variaveis[i]);
    }
    return corpo;
  }
}
