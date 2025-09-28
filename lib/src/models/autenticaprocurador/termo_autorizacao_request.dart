import 'dart:convert';
import '../../util/document_utils.dart';

/// Modelo para criação do Termo de Autorização XML
class TermoAutorizacaoRequest {
  final String contratanteNumero;
  final String contratanteNome;
  final String autorPedidoDadosNumero;
  final String autorPedidoDadosNome;
  final String dataAssinatura;
  final String dataVigencia;
  final String? certificadoPath;
  final String? certificadoPassword;

  TermoAutorizacaoRequest({
    required this.contratanteNumero,
    required this.contratanteNome,
    required this.autorPedidoDadosNumero,
    required this.autorPedidoDadosNome,
    required this.dataAssinatura,
    required this.dataVigencia,
    this.certificadoPath,
    this.certificadoPassword,
  });

  /// Cria o XML do termo de autorização conforme especificação
  String criarXmlTermo() {
    final contratanteTipo = DocumentUtils.detectDocumentType(contratanteNumero);
    final autorTipo = DocumentUtils.detectDocumentType(autorPedidoDadosNumero);

    final xml =
        '''<?xml version="1.0" encoding="UTF-8"?>
<termoDeAutorizacao>
    <dados>
        <sistema id="API Integra Contador" />
        <termo texto="Autorizo a empresa CONTRATANTE, identificada neste termo de autorização como DESTINATÁRIO, a executar as requisições dos serviços web disponibilizados pela API INTEGRA CONTADOR, onde terei o papel de AUTOR PEDIDO DE DADOS no corpo da mensagem enviada na requisição do serviço web. Esse termo de autorização está assinado digitalmente com o certificado digital do PROCURADOR ou OUTORGADO DO CONTRIBUINTE responsável, identificado como AUTOR DO PEDIDO DE DADOS." />
        <avisoLegal texto="O acesso a estas informações foi autorizado pelo próprio PROCURADOR ou OUTORGADO DO CONTRIBUINTE, responsável pela informação, via assinatura digital. É dever do destinatário da autorização e consumidor deste acesso observar a adoção de base legal para o tratamento dos dados recebidos conforme artigos 7º ou 11º da LGPD (Lei n.º 13.709, de 14 de agosto de 2018), aos direitos do titular dos dados (art. 9º, 17 e 18, da LGPD) e aos princípios que norteiam todos os tratamentos de dados no Brasil (art. 6º, da LGPD)." />
        <finalidade texto="A finalidade única e exclusiva desse TERMO DE AUTORIZAÇÃO, é garantir que o CONTRATANTE apresente a API INTEGRA CONTADOR esse consentimento do PROCURADOR ou OUTORGADO DO CONTRIBUINTE assinado digitalmente, para que possa realizar as requisições dos serviços web da API INTEGRA CONTADOR em nome do AUTOR DO PEDIDO DE DADOS (PROCURADOR ou OUTORGADO DO CONTRIBUINTE)." />
        <dataAssinatura data="$dataAssinatura" />
        <vigencia data="$dataVigencia" />
        <destinatario numero="${DocumentUtils.cleanDocumentNumber(contratanteNumero)}" nome="$contratanteNome" tipo="${contratanteTipo == 1 ? 'PF' : 'PJ'}" papel="contratante" />
        <assinadoPor numero="${DocumentUtils.cleanDocumentNumber(autorPedidoDadosNumero)}" nome="$autorPedidoDadosNome" tipo="${autorTipo == 1 ? 'PF' : 'PJ'}" papel="autor pedido de dados"/>
    </dados>
    <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
        <!-- Assinatura digital será inserida aqui -->
    </Signature>
</termoDeAutorizacao>''';

    return xml;
  }

  /// Valida os dados do termo de autorização
  List<String> validarDados() {
    final erros = <String>[];

    // Validar CNPJ/CPF do contratante
    if (!DocumentUtils.isValidCnpj(contratanteNumero) &&
        !DocumentUtils.isValidCpf(contratanteNumero)) {
      erros.add('CNPJ/CPF do contratante inválido: $contratanteNumero');
    }

    // Validar CNPJ/CPF do autor do pedido
    if (!DocumentUtils.isValidCnpj(autorPedidoDadosNumero) &&
        !DocumentUtils.isValidCpf(autorPedidoDadosNumero)) {
      erros.add(
        'CNPJ/CPF do autor do pedido inválido: $autorPedidoDadosNumero',
      );
    }

    // Validar nome do contratante
    if (contratanteNome.trim().isEmpty) {
      erros.add('Nome do contratante é obrigatório');
    }

    // Validar nome do autor do pedido
    if (autorPedidoDadosNome.trim().isEmpty) {
      erros.add('Nome do autor do pedido é obrigatório');
    }

    // Validar formato da data de assinatura (AAAAMMDD)
    if (!_isValidDateFormat(dataAssinatura)) {
      erros.add(
        'Data de assinatura deve estar no formato AAAAMMDD: $dataAssinatura',
      );
    }

    // Validar formato da data de vigência (AAAAMMDD)
    if (!_isValidDateFormat(dataVigencia)) {
      erros.add(
        'Data de vigência deve estar no formato AAAAMMDD: $dataVigencia',
      );
    }

    // Validar se data de vigência é posterior à data de assinatura
    if (dataVigencia.compareTo(dataAssinatura) <= 0) {
      erros.add('Data de vigência deve ser posterior à data de assinatura');
    }

    return erros;
  }

  /// Valida formato de data AAAAMMDD
  bool _isValidDateFormat(String date) {
    if (date.length != 8) return false;

    try {
      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));
      final day = int.parse(date.substring(6, 8));

      if (year < 2000 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Validação básica de dias por mês
      final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      if (month == 2 && _isLeapYear(year)) {
        return day <= 29;
      }
      return day <= daysInMonth[month - 1];
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o ano é bissexto
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Cria o JSON para envio da requisição
  Map<String, dynamic> toJson() {
    return {'termoAutorizacao': base64.encode(utf8.encode(criarXmlTermo()))};
  }

  /// Factory para criar termo com data atual
  factory TermoAutorizacaoRequest.comDataAtual({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? certificadoPath,
    String? certificadoPassword,
  }) {
    final now = DateTime.now();
    final vigencia = now.add(const Duration(days: 365));

    return TermoAutorizacaoRequest(
      contratanteNumero: contratanteNumero,
      contratanteNome: contratanteNome,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      autorPedidoDadosNome: autorPedidoDadosNome,
      dataAssinatura: _formatDate(now),
      dataVigencia: _formatDate(vigencia),
      certificadoPath: certificadoPath,
      certificadoPassword: certificadoPassword,
    );
  }

  /// Formata data para AAAAMMDD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
