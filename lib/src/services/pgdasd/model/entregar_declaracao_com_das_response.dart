import 'dart:convert';
import 'entregar_declaracao_response.dart';
import 'gerar_das_response.dart' show GerarDasResponse, Das;

/// Modelo de resposta para entrega de declaração com geração automática de DAS
///
/// Combina os resultados de entregarDeclaracao + gerarDas em uma única resposta
class EntregarDeclaracaoComDasResponse {
  /// Status HTTP retornado (200 = ambos sucesso, 500 = algum erro)
  final int status;

  /// Mensagens combinadas de ambas as operações
  final List<Mensagem> mensagens;

  /// Dados da declaração transmitida (null se declaração falhou)
  final DeclaracaoTransmitida? dadosDeclaracao;

  /// Dados do DAS gerado (null se DAS não foi gerado)
  final List<Das>? dadosDas;

  EntregarDeclaracaoComDasResponse({required this.status, required this.mensagens, this.dadosDeclaracao, this.dadosDas});

  /// Indica se ambas operações foram bem-sucedidas
  bool get sucesso => status == 200;

  /// Indica se a declaração foi entregue com sucesso
  bool get declaracaoEntregue => dadosDeclaracao != null;

  /// Indica se o DAS foi gerado com sucesso
  bool get dasGerado => dadosDas != null && dadosDas!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sucesso': sucesso,
      'declaracaoEntregue': declaracaoEntregue,
      'dasGerado': dasGerado,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      'dadosDeclaracao': dadosDeclaracao != null ? jsonEncode(dadosDeclaracao!.toJson()) : null,
      'dadosDas': dadosDas != null ? jsonEncode(dadosDas!.map((d) => d.toJson()).toList()) : null,
    };
  }

  /// Cria resposta quando ambas operações foram bem-sucedidas
  ///
  /// [declaracaoResponse] Resposta de entregarDeclaracao
  /// [dasResponse] Resposta de gerarDas
  factory EntregarDeclaracaoComDasResponse.fromResponses({
    required EntregarDeclaracaoResponse declaracaoResponse,
    required GerarDasResponse dasResponse,
  }) {
    // Combinar mensagens de ambas as respostas
    final mensagensCombinadas = <Mensagem>[
      ...declaracaoResponse.mensagens,
      // Converter mensagens de GerarDasResponse para o tipo Mensagem de EntregarDeclaracaoResponse
      ...dasResponse.mensagens.map((m) => Mensagem(codigo: m.codigo, texto: m.texto)),
    ];

    // Status é 200 apenas se ambos foram 200
    final statusCombinado = declaracaoResponse.status == 200 && dasResponse.status == 200 ? 200 : 500;

    return EntregarDeclaracaoComDasResponse(
      status: statusCombinado,
      mensagens: mensagensCombinadas,
      dadosDeclaracao: declaracaoResponse.dados,
      dadosDas: dasResponse.dados,
    );
  }

  /// Cria resposta de erro quando a declaração falhou
  ///
  /// [declaracaoResponse] Resposta de entregarDeclaracao com erro
  factory EntregarDeclaracaoComDasResponse.fromDeclaracaoError({required EntregarDeclaracaoResponse declaracaoResponse}) {
    return EntregarDeclaracaoComDasResponse(
      status: declaracaoResponse.status,
      mensagens: declaracaoResponse.mensagens,
      dadosDeclaracao: null,
      dadosDas: null,
    );
  }

  /// Cria resposta de erro quando o DAS falhou após declaração bem-sucedida
  ///
  /// [declaracaoResponse] Resposta de entregarDeclaracao (sucesso)
  /// [dasResponse] Resposta de gerarDas (erro)
  factory EntregarDeclaracaoComDasResponse.fromDasError({
    required EntregarDeclaracaoResponse declaracaoResponse,
    required GerarDasResponse dasResponse,
  }) {
    // Combinar mensagens e adicionar explicação do erro
    final mensagensCombinadas = <Mensagem>[
      ...declaracaoResponse.mensagens,
      // Converter mensagens de GerarDasResponse para o tipo Mensagem de EntregarDeclaracaoResponse
      ...dasResponse.mensagens.map((m) => Mensagem(codigo: m.codigo, texto: m.texto)),
      Mensagem(
        codigo: 'ERRO_DAS',
        texto: 'Declaração entregue com sucesso, mas falha ao gerar DAS. Você pode gerar o DAS manualmente usando o ID da declaração.',
      ),
    ];

    return EntregarDeclaracaoComDasResponse(status: 500, mensagens: mensagensCombinadas, dadosDeclaracao: declaracaoResponse.dados, dadosDas: null);
  }
}
