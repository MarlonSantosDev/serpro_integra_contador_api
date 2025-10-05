import 'validacoes_utils.dart';
import 'catalogo_servicos_utils.dart';

/// Gerador do identificador de requisições (X-Request-Tag)
///
/// Este utilitário gera automaticamente o identificador de requisições seguindo
/// o formato especificado na documentação do SERPRO Integra Contador:
/// TAAAAAAAAAAAAAATCCCCCCCCCCCCCCFF
///
/// Onde:
/// - T = Tipo do autor do pedido de dados (1-CPF ou 2-CNPJ)
/// - AAAAAAAAAAAAAA = autor do pedido de dados (14 posições)
/// - T = Tipo do contribuinte (1-CPF ou 2-CNPJ)
/// - CCCCCCCCCCCCCC = contribuinte (14 posições)
/// - FF = Sequencial da Funcionalidade conforme Catálogo de Serviços (2 posições)
class RequestTagGenerator {
  /// Gera o identificador de requisição (X-Request-Tag)
  ///
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido
  /// [contribuinteNumero] - CPF/CNPJ do contribuinte
  /// [idServico] - Código do serviço (ex: 'TRANSDECLARACAO11')
  ///
  /// Retorna o identificador no formato: TAAAAAAAAAAAAAATCCCCCCCCCCCCCCFF
  static String generateRequestTag({required String autorPedidoDadosNumero, required String contribuinteNumero, required String idServico}) {
    // Limpar e padronizar os números de documento
    final autorLimpo = ValidacoesUtils.cleanDocumentNumber(autorPedidoDadosNumero);
    final contribuinteLimpo = ValidacoesUtils.cleanDocumentNumber(contribuinteNumero);

    // Detectar tipos de documento
    final autorTipo = ValidacoesUtils.detectDocumentType(autorLimpo);
    final contribuinteTipo = ValidacoesUtils.detectDocumentType(contribuinteLimpo);

    // Obter código da funcionalidade
    final codigoFuncionalidade = CatalogoServicosUtils.getFunctionCode(idServico);

    // Padronizar documentos para 14 posições (completar com zeros à esquerda)
    final autorPadronizado = autorLimpo.padLeft(14, '0');
    final contribuintePadronizado = contribuinteLimpo.padLeft(14, '0');

    // Montar o identificador
    final requestTag = '$autorTipo$autorPadronizado$contribuinteTipo$contribuintePadronizado$codigoFuncionalidade';

    return requestTag;
  }

  /// Valida se o identificador gerado está no formato correto
  ///
  /// [requestTag] - Identificador a ser validado
  ///
  /// Retorna true se o formato está correto (32 caracteres)
  static bool isValidRequestTag(String requestTag) {
    return requestTag.length == 32;
  }

  /// Decodifica um identificador de requisição para análise
  ///
  /// [requestTag] - Identificador a ser decodificado
  ///
  /// Retorna um Map com os componentes do identificador
  static Map<String, dynamic> decodeRequestTag(String requestTag) {
    if (!isValidRequestTag(requestTag)) {
      throw ArgumentError('Identificador inválido. Deve ter 32 caracteres.');
    }

    return {
      'autorTipo': requestTag.substring(0, 1),
      'autorNumero': requestTag.substring(1, 15),
      'contribuinteTipo': requestTag.substring(15, 16),
      'contribuinteNumero': requestTag.substring(16, 30),
      'codigoFuncionalidade': requestTag.substring(30, 32),
    };
  }
}
