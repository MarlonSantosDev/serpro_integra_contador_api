import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter detalhes de uma mensagem específica
class DetalhesMensagemResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final DadosDetalhesMensagem? dados;

  DetalhesMensagemResponse({required this.status, required this.mensagens, this.dados});

  factory DetalhesMensagemResponse.fromJson(Map<String, dynamic> json) {
    final dadosJson = jsonDecode(json['dados'].toString());
    final dadosParsed = DadosDetalhesMensagem.fromJson(dadosJson);

    return DetalhesMensagemResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>? ?? []).map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
  }
}

/// Dados parseados do campo 'dados' para detalhes de mensagem
class DadosDetalhesMensagem {
  final String codigo;
  final List<DetalheMensagemCompleta> conteudo;

  DadosDetalhesMensagem({required this.codigo, required this.conteudo});

  factory DadosDetalhesMensagem.fromJson(Map<String, dynamic> json) {
    return DadosDetalhesMensagem(
      codigo: json['codigo'].toString(),
      conteudo: (json['conteudo'] as List<dynamic>? ?? []).map((e) => DetalheMensagemCompleta.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'conteudo': conteudo.map((e) => e.toJson()).toList()};
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
  final bool indFavorito;

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
    required this.indFavorito,
  });

  factory DetalheMensagemCompleta.fromJson(Map<String, dynamic> json) {
    // Processar assuntoModelo substituindo ++VARIAVEL++ por valorParametroAssunto
    final assuntoModeloOriginal = json['assuntoModelo']?.toString() ?? '';
    final valorParametroAssunto = json['valorParametroAssunto']?.toString() ?? '';
    final assuntoModeloProcessado = valorParametroAssunto.isEmpty
        ? assuntoModeloOriginal
        : assuntoModeloOriginal.replaceAll('++VARIAVEL++', valorParametroAssunto);

    // Processar corpoModelo substituindo ++1++, ++2++, etc. pelos valores de variaveis
    final corpoModeloOriginal = json['corpoModelo']?.toString() ?? '';
    final variaveis = (json['variaveis'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    String corpoModeloProcessado = corpoModeloOriginal;
    if (variaveis.isNotEmpty) {
      for (int i = 0; i < variaveis.length; i++) {
        final placeholder = '++${i + 1}++';
        corpoModeloProcessado = corpoModeloProcessado.replaceAll(placeholder, variaveis[i]);
      }
    }

    /// Limpa HTML de uma string
    corpoModeloProcessado = corpoModeloProcessado
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&aacute;', 'á')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&atilde;', 'ã')
        .replaceAll('&otilde;', 'õ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&Atilde;', 'Ã')
        .replaceAll('&Otilde;', 'Õ')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ordm;', 'º')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Converter campos numéricos para valores descritivos
    final origemModeloStr = json['origemModelo']?.toString() ?? '';
    final origemModelo = switch (origemModeloStr) {
      '1' => 'Sistema Remetente',
      '2' => 'RFB',
      _ => origemModeloStr,
    };

    final tipoOrigemStr = json['tipoOrigem']?.toString() ?? '';
    final tipoOrigem = switch (tipoOrigemStr) {
      '1' => 'Receita',
      '2' => 'Estado',
      '3' => 'Município',
      _ => tipoOrigemStr,
    };

    final indFavoritoStr = json['indFavorito']?.toString() ?? '0';

    return DetalheMensagemCompleta(
      codigoSistemaRemetente: json['codigoSistemaRemetente']?.toString() ?? '',
      codigoModelo: json['codigoModelo']?.toString() ?? '',
      assuntoModelo: assuntoModeloProcessado,
      origemModelo: origemModelo,
      dataEnvio: json['dataEnvio']?.toString() ?? '',
      valorParametroAssunto: valorParametroAssunto,
      dataLeitura: json['dataLeitura']?.toString() ?? '',
      horaLeitura: json['horaLeitura']?.toString() ?? '',
      dataExpiracao: json['dataExpiracao']?.toString() ?? '',
      numeroControle: json['numeroControle']?.toString() ?? '',
      dataCiencia: json['dataCiencia']?.toString() ?? '',
      enquadramento: json['enquadramento']?.toString() ?? '',
      dataAcessoExterno: json['dataAcessoExterno']?.toString() ?? '',
      horaAcessoExterno: json['horaAcessoExterno']?.toString() ?? '',
      tipoAutenticacaoUsuario: json['tipoAutenticacaoUsuario']?.toString() ?? '',
      codigoAcesso: json['codigoAcesso']?.toString() ?? '',
      numeroSerieCertificadoDigital: json['numeroSerieCertificadoDigital']?.toString() ?? '',
      emissorCertificadoDigital: json['emissorCertificadoDigital']?.toString() ?? '',
      tipoUsuario: json['tipoUsuario']?.toString() ?? '',
      niUsuario: json['niUsuario']?.toString() ?? '',
      papelUsuario: json['papelUsuario']?.toString() ?? '',
      codigoAplicacao: json['codigoAplicacao']?.toString() ?? '',
      tipoOrigem: tipoOrigem,
      descricaoOrigem: json['descricaoOrigem']?.toString() ?? '',
      corpoModelo: corpoModeloProcessado,
      variaveis: variaveis,
      indFavorito: indFavoritoStr == '1',
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
}
