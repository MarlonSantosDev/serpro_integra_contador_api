import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter lista de mensagens por contribuinte
class ListaMensagensResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final DadosListaMensagens? dados;

  ListaMensagensResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory ListaMensagensResponse.fromJson(Map<String, dynamic> json) {
    final dadosStr = json['dados']?.toString() ?? '';
    DadosListaMensagens? dadosParsed;
    final dadosJson = jsonDecode(dadosStr);
    dadosParsed = DadosListaMensagens.fromJson(dadosJson);

    return ListaMensagensResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>? ?? [])
          .map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
  }
}

/// Dados parseados do campo 'dados' para lista de mensagens
class DadosListaMensagens {
  final String codigo;
  final List<ConteudoListaMensagens> conteudo;

  DadosListaMensagens({required this.codigo, required this.conteudo});

  factory DadosListaMensagens.fromJson(Map<String, dynamic> json) {
    return DadosListaMensagens(
      codigo: json['codigo'].toString(),
      conteudo: (json['conteudo'] as List<dynamic>? ?? [])
          .map(
            (e) => ConteudoListaMensagens.fromJson(e as Map<String, dynamic>),
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

/// Conteúdo da resposta de lista de mensagens
class ConteudoListaMensagens {
  final String quantidadeMensagens;
  final String indicadorUltimaPagina;
  final String ponteiroPaginaRetornada;
  final String ponteiroProximaPagina;
  final String? cnpjMatriz;
  final List<MensagemCaixaPostal> listaMensagens;
  final bool isUltimaPagina;
  final int quantidadeMensagensInt;

  ConteudoListaMensagens({
    required this.quantidadeMensagens,
    required this.indicadorUltimaPagina,
    required this.ponteiroPaginaRetornada,
    required this.ponteiroProximaPagina,
    this.cnpjMatriz,
    required this.listaMensagens,
    required this.isUltimaPagina,
    required this.quantidadeMensagensInt,
  });

  factory ConteudoListaMensagens.fromJson(Map<String, dynamic> json) {
    final indicadorUltimaPaginaStr = json['indicadorUltimaPagina'].toString();
    final quantidadeMensagensStr = json['quantidadeMensagens'].toString();

    return ConteudoListaMensagens(
      quantidadeMensagens: quantidadeMensagensStr,
      indicadorUltimaPagina: indicadorUltimaPaginaStr,
      ponteiroPaginaRetornada: json['ponteiroPaginaRetornada'].toString(),
      ponteiroProximaPagina: json['ponteiroProximaPagina'].toString(),
      cnpjMatriz: json['cnpjMatriz']?.toString(),
      listaMensagens: (json['listaMensagens'] as List<dynamic>? ?? [])
          .map((e) => MensagemCaixaPostal.fromJson(e as Map<String, dynamic>))
          .toList(),
      isUltimaPagina: indicadorUltimaPaginaStr.toUpperCase() == 'S',
      quantidadeMensagensInt: int.tryParse(quantidadeMensagensStr) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantidadeMensagens': quantidadeMensagens,
      'indicadorUltimaPagina': indicadorUltimaPagina,
      'ponteiroPaginaRetornada': ponteiroPaginaRetornada,
      'ponteiroProximaPagina': ponteiroProximaPagina,
      'cnpjMatriz': cnpjMatriz,
      'listaMensagens': listaMensagens.map((e) => e.toJson()).toList(),
    };
  }
}

/// Mensagem individual da Caixa Postal
class MensagemCaixaPostal {
  final String codigoSistemaRemetente;
  final String codigoModelo;
  final String dataEnvio;
  final String horaEnvio;
  final String numeroControle;
  final String indicadorLeitura;
  final String dataLeitura;
  final String horaLeitura;
  final String dataExclusao;
  final String horaExclusao;
  final String dataCiencia;
  final String assuntoModelo;
  final String dataValidade;
  final String origemModelo;
  final String valorParametroAssunto;
  final String relevancia;
  final String isn;
  final String tipoOrigem;
  final String descricaoOrigem;
  final String indicadorFavorito;
  final bool foiLida;
  final bool isFavorita;
  final bool temAltaRelevancia;

  MensagemCaixaPostal({
    required this.codigoSistemaRemetente,
    required this.codigoModelo,
    required this.dataEnvio,
    required this.horaEnvio,
    required this.numeroControle,
    required this.indicadorLeitura,
    required this.dataLeitura,
    required this.horaLeitura,
    required this.dataExclusao,
    required this.horaExclusao,
    required this.dataCiencia,
    required this.assuntoModelo,
    required this.dataValidade,
    required this.origemModelo,
    required this.valorParametroAssunto,
    required this.relevancia,
    required this.isn,
    required this.tipoOrigem,
    required this.descricaoOrigem,
    required this.indicadorFavorito,
    required this.foiLida,
    required this.isFavorita,
    required this.temAltaRelevancia,
  });

  factory MensagemCaixaPostal.fromJson(Map<String, dynamic> json) {
    // Processar assuntoModelo substituindo ++VARIAVEL++ por valorParametroAssunto
    final assuntoModeloOriginal = json['assuntoModelo']?.toString() ?? '';
    final valorParametroAssunto =
        json['valorParametroAssunto']?.toString() ?? '';
    final assuntoModeloProcessado = valorParametroAssunto.isEmpty
        ? assuntoModeloOriginal
        : assuntoModeloOriginal.replaceAll(
            '++VARIAVEL++',
            valorParametroAssunto,
          );

    // Converter campos numéricos para valores descritivos
    final indicadorLeituraStr = json['indicadorLeitura']?.toString() ?? '';
    final indicadorLeitura = switch (indicadorLeituraStr) {
      '0' => 'Não lida',
      '1' => 'Lida',
      '2' => 'Não se aplica',
      _ => indicadorLeituraStr,
    };

    final indicadorFavoritoStr = json['indicadorFavorito']?.toString() ?? '';
    final indicadorFavorito = switch (indicadorFavoritoStr) {
      '0' => 'Não lida',
      '1' => 'Lida',
      _ => indicadorFavoritoStr,
    };

    final origemModeloStr = json['origemModelo']?.toString() ?? '';
    final origemModelo = switch (origemModeloStr) {
      '1' => 'Sistema Remetente',
      '2' => 'RFB',
      _ => origemModeloStr,
    };

    final relevanciaStr = json['relevancia']?.toString() ?? '';
    final relevancia = switch (relevanciaStr) {
      '1' => 'Sem relevância',
      '2' => 'Com relevância',
      _ => relevanciaStr,
    };

    final tipoOrigemStr = json['tipoOrigem']?.toString() ?? '';
    final tipoOrigem = switch (tipoOrigemStr) {
      '1' => 'Receita',
      '2' => 'Estado',
      '3' => 'Município',
      _ => tipoOrigemStr,
    };

    return MensagemCaixaPostal(
      codigoSistemaRemetente: json['codigoSistemaRemetente']?.toString() ?? '',
      codigoModelo: json['codigoModelo']?.toString() ?? '',
      dataEnvio: json['dataEnvio']?.toString() ?? '',
      horaEnvio: json['horaEnvio']?.toString() ?? '',
      numeroControle: json['numeroControle']?.toString() ?? '',
      indicadorLeitura: indicadorLeitura,
      dataLeitura: json['dataLeitura']?.toString() ?? '',
      horaLeitura: json['horaLeitura']?.toString() ?? '',
      dataExclusao: json['dataExclusao']?.toString() ?? '',
      horaExclusao: json['horaExclusao']?.toString() ?? '',
      dataCiencia: json['dataCiencia']?.toString() ?? '',
      assuntoModelo: assuntoModeloProcessado,
      dataValidade: json['dataValidade']?.toString() ?? '',
      origemModelo: origemModelo,
      valorParametroAssunto: valorParametroAssunto,
      relevancia: relevancia,
      isn: json['isn']?.toString() ?? '',
      tipoOrigem: tipoOrigem,
      descricaoOrigem: json['descricaoOrigem']?.toString() ?? '',
      indicadorFavorito: indicadorFavorito,
      foiLida: indicadorLeituraStr == '1',
      isFavorita: indicadorFavoritoStr == '1',
      temAltaRelevancia: relevanciaStr == '2',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigoSistemaRemetente': codigoSistemaRemetente,
      'codigoModelo': codigoModelo,
      'dataEnvio': dataEnvio,
      'horaEnvio': horaEnvio,
      'numeroControle': numeroControle,
      'indicadorLeitura': indicadorLeitura,
      'dataLeitura': dataLeitura,
      'horaLeitura': horaLeitura,
      'dataExclusao': dataExclusao,
      'horaExclusao': horaExclusao,
      'dataCiencia': dataCiencia,
      'assuntoModelo': assuntoModelo,
      'dataValidade': dataValidade,
      'origemModelo': origemModelo,
      'valorParametroAssunto': valorParametroAssunto,
      'relevancia': relevancia,
      'isn': isn,
      'tipoOrigem': tipoOrigem,
      'descricaoOrigem': descricaoOrigem,
      'indicadorFavorito': indicadorFavorito,
    };
  }
}
