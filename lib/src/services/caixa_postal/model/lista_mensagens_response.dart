import 'dart:convert';
import 'mensagem_negocio.dart';

/// Response para obter lista de mensagens por contribuinte
class ListaMensagensResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String dados;
  final DadosListaMensagens? dadosParsed;

  ListaMensagensResponse({required this.status, required this.mensagens, required this.dados, this.dadosParsed});

  factory ListaMensagensResponse.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'].toString();
    DadosListaMensagens? dadosParsed;

    try {
      final dadosJson = jsonDecode(dados);
      dadosParsed = DadosListaMensagens.fromJson(dadosJson);
    } catch (e) {
      // Se não conseguir parsear, mantém dados como string
    }

    return ListaMensagensResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>? ?? []).map((e) => MensagemNegocio.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dados,
      dadosParsed: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
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
      conteudo: (json['conteudo'] as List<dynamic>? ?? []).map((e) => ConteudoListaMensagens.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'conteudo': conteudo.map((e) => e.toJson()).toList()};
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

  ConteudoListaMensagens({
    required this.quantidadeMensagens,
    required this.indicadorUltimaPagina,
    required this.ponteiroPaginaRetornada,
    required this.ponteiroProximaPagina,
    this.cnpjMatriz,
    required this.listaMensagens,
  });

  factory ConteudoListaMensagens.fromJson(Map<String, dynamic> json) {
    return ConteudoListaMensagens(
      quantidadeMensagens: json['quantidadeMensagens'].toString(),
      indicadorUltimaPagina: json['indicadorUltimaPagina'].toString(),
      ponteiroPaginaRetornada: json['ponteiroPaginaRetornada'].toString(),
      ponteiroProximaPagina: json['ponteiroProximaPagina'].toString(),
      cnpjMatriz: json['cnpjMatriz']?.toString(),
      listaMensagens: (json['listaMensagens'] as List<dynamic>? ?? []).map((e) => MensagemCaixaPostal.fromJson(e as Map<String, dynamic>)).toList(),
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

  /// Verifica se é a última página
  bool get isUltimaPagina => indicadorUltimaPagina.toUpperCase() == 'S';

  /// Quantidade de mensagens como int
  int get quantidadeMensagensInt => int.tryParse(quantidadeMensagens) ?? 0;
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
  });

  factory MensagemCaixaPostal.fromJson(Map<String, dynamic> json) {
    return MensagemCaixaPostal(
      codigoSistemaRemetente: json['codigoSistemaRemetente']?.toString() ?? '',
      codigoModelo: json['codigoModelo']?.toString() ?? '',
      dataEnvio: json['dataEnvio']?.toString() ?? '',
      horaEnvio: json['horaEnvio']?.toString() ?? '',
      numeroControle: json['numeroControle']?.toString() ?? '',
      indicadorLeitura: json['indicadorLeitura']?.toString() ?? '',
      dataLeitura: json['dataLeitura']?.toString() ?? '',
      horaLeitura: json['horaLeitura']?.toString() ?? '',
      dataExclusao: json['dataExclusao']?.toString() ?? '',
      horaExclusao: json['horaExclusao']?.toString() ?? '',
      dataCiencia: json['dataCiencia']?.toString() ?? '',
      assuntoModelo: json['assuntoModelo']?.toString() ?? '',
      dataValidade: json['dataValidade']?.toString() ?? '',
      origemModelo: json['origemModelo']?.toString() ?? '',
      valorParametroAssunto: json['valorParametroAssunto']?.toString() ?? '',
      relevancia: json['relevancia']?.toString() ?? '',
      isn: json['isn']?.toString() ?? '',
      tipoOrigem: json['tipoOrigem']?.toString() ?? '',
      descricaoOrigem: json['descricaoOrigem']?.toString() ?? '',
      indicadorFavorito: json['indicadorFavorito']?.toString() ?? '',
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

  /// Verifica se a mensagem foi lida
  bool get foiLida => indicadorLeitura == '1';

  /// Verifica se a mensagem é favorita
  bool get isFavorita => indicadorFavorito == '1';

  /// Verifica se a mensagem tem alta relevância
  bool get temAltaRelevancia => relevancia == '2';

  /// Obtém o assunto processado com as variáveis substituídas
  String get assuntoProcessado {
    if (valorParametroAssunto.isEmpty) return assuntoModelo;
    return assuntoModelo.replaceAll('++VARIAVEL++', valorParametroAssunto);
  }
}
