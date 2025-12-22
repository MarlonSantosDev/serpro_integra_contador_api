/// Exceção base para o serviço Autentica Procurador
class ExcecaoAutenticaProcurador implements Exception {
  final String mensagem;
  final String? codigo;
  final int? statusHttp;

  ExcecaoAutenticaProcurador(this.mensagem, {this.codigo, this.statusHttp});

  @override
  String toString() =>
      'ExcecaoAutenticaProcurador: $mensagem${codigo != null ? " (código: $codigo)" : ""}';
}

/// Exceções relacionadas ao certificado digital
class ExcecaoAssinaturaCertificado extends ExcecaoAutenticaProcurador {
  ExcecaoAssinaturaCertificado(String mensagem, {String? codigo})
    : super(mensagem, codigo: codigo ?? 'ERRO_CERTIFICADO', statusHttp: 400);
}

/// Exceções relacionadas à assinatura XML
class ExcecaoAssinaturaXml extends ExcecaoAutenticaProcurador {
  ExcecaoAssinaturaXml(String mensagem, {String? codigo})
    : super(mensagem, codigo: codigo ?? 'ERRO_ASSINATURA_XML', statusHttp: 400);
}

/// Exceções relacionadas à validação ICP-Brasil
class ExcecaoValidacaoICPBrasil extends ExcecaoAutenticaProcurador {
  ExcecaoValidacaoICPBrasil(String mensagem, {String? codigo})
    : super(mensagem, codigo: codigo ?? 'ERRO_VALIDACAO_ICP', statusHttp: 403);
}

/// Mapeia erros específicos da API SERPRO
class ExcecaoErroSerpro extends ExcecaoAutenticaProcurador {
  ExcecaoErroSerpro(String mensagem, {required String codigo, int? statusHttp})
    : super(mensagem, codigo: codigo, statusHttp: statusHttp);

  /// Cria exceção a partir do código de erro SERPRO
  factory ExcecaoErroSerpro.doCodigo(String codigo) {
    switch (codigo) {
      // Erros de acesso negado
      case 'AcessoNegado-AUTENTICAPROCURADOR-009':
        return ExcecaoErroSerpro(
          'Certificado Digital deve ser e-PF, e-CPF, e-PJ ou e-CNPJ',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-010':
        return ExcecaoErroSerpro(
          'Certificado Digital está expirado',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-011':
        return ExcecaoErroSerpro(
          'NI do procurador difere do NI no certificado',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-012':
        return ExcecaoErroSerpro(
          'NI do contratante difere do NI do assinante do XML',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-013':
        return ExcecaoErroSerpro(
          'XML assinado inválido',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-021':
        return ExcecaoErroSerpro(
          'Certificado fornecido não possui extensões da ICP-Brasil',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-023':
        return ExcecaoErroSerpro(
          'O certificado informado não está autorizado',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-037':
        return ExcecaoErroSerpro(
          'Certificado revogado',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-039':
        return ExcecaoErroSerpro(
          'Certificado inválido conforme padrão X509Certificate2',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-040':
        return ExcecaoErroSerpro(
          'Cadeia de certificados não é confiável',
          codigo: codigo,
          statusHttp: 403,
        );
      case 'AcessoNegado-AUTENTICAPROCURADOR-041':
        return ExcecaoErroSerpro(
          'O certificado não pode ser do tipo autoassinado',
          codigo: codigo,
          statusHttp: 403,
        );

      // Erros de entrada incorreta
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-002':
        return ExcecaoErroSerpro(
          'Parâmetros de entrada inválidos. Campo xml nulo, vazio ou não encontrado',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-015':
        return ExcecaoErroSerpro(
          'Estrutura XML inválida: tag obrigatória ausente',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-016':
        return ExcecaoErroSerpro(
          'Estrutura XML inválida: atributo de tag incorreto',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-017':
        return ExcecaoErroSerpro(
          'Data de vigência deve ser maior ou igual que a data corrente',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-018':
        return ExcecaoErroSerpro(
          'Data de assinatura não deve ser posterior à data atual',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-019':
        return ExcecaoErroSerpro(
          'Tag raiz deve ser termoDeAutorizacao',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-020':
        return ExcecaoErroSerpro(
          'String XML não é base64 válido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-025':
        return ExcecaoErroSerpro(
          'XML sem assinatura',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-026':
        return ExcecaoErroSerpro(
          'Elemento CanonicalizationMethod inválido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-027':
        return ExcecaoErroSerpro(
          'Elemento SignatureMethod inválido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-028':
        return ExcecaoErroSerpro(
          'Apenas um elemento Reference é requerido/permitido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-029':
        return ExcecaoErroSerpro(
          'Assinatura deve cobrir todo o documento',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-030':
        return ExcecaoErroSerpro(
          'Elemento DigestMethod inválido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-031':
        return ExcecaoErroSerpro(
          'Métodos de transformação obrigatórios ausentes',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-032':
        return ExcecaoErroSerpro(
          'Apenas um elemento KeyInfo/X509Data é requerido/permitido',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-033':
        return ExcecaoErroSerpro(
          'Documento alterado pós-assinatura ou validade da assinatura comprometida',
          codigo: codigo,
          statusHttp: 400,
        );
      case 'EntradaIncorreta-AUTENTICAPROCURADOR-038':
        return ExcecaoErroSerpro(
          'XML malformado com caracteres inválidos detectados',
          codigo: codigo,
          statusHttp: 403,
        );

      // Erros do sistema
      case 'Erro-AUTENTICAPROCURADOR-003':
        return ExcecaoErroSerpro(
          'Falha no login',
          codigo: codigo,
          statusHttp: 500,
        );
      case 'Erro-AUTENTICAPROCURADOR-008':
        return ExcecaoErroSerpro(
          'Erro na validação do certificado digital',
          codigo: codigo,
          statusHttp: 500,
        );
      case 'Erro-AUTENTICAPROCURADOR-014':
        return ExcecaoErroSerpro(
          'Falha na extração de CNPJ do certificado',
          codigo: codigo,
          statusHttp: 500,
        );
      case 'Erro-AUTENTICAPROCURADOR-034':
        return ExcecaoErroSerpro(
          'Padrão de assinatura não reconhecido',
          codigo: codigo,
          statusHttp: 500,
        );

      default:
        return ExcecaoErroSerpro(
          'Erro desconhecido: $codigo',
          codigo: codigo,
          statusHttp: 500,
        );
    }
  }
}
