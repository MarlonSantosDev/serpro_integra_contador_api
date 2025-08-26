import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/identificacao.dart';
import '../models/pedido_dados.dart';
import '../models/dados_entrada.dart';
import '../exceptions/api_exception.dart';

/// Classe helper com métodos utilitários para a API Integra Contador
class IntegraContadorHelper {
  /// Valida se um documento (CPF ou CNPJ) é válido
  static bool isDocumentoValido(String documento) {
    final numeroLimpo = documento.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numeroLimpo.length == 11) {
      return Identificacao.cpf(numeroLimpo).isValid;
    } else if (numeroLimpo.length == 14) {
      return Identificacao.cnpj(numeroLimpo).isValid;
    }
    
    return false;
  }

  /// Detecta o tipo de documento (CPF ou CNPJ)
  static String? detectarTipoDocumento(String documento) {
    final numeroLimpo = documento.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numeroLimpo.length == 11) {
      return 'CPF';
    } else if (numeroLimpo.length == 14) {
      return 'CNPJ';
    }
    
    return null;
  }

  /// Formata um documento (CPF ou CNPJ)
  static String formatarDocumento(String documento) {
    final numeroLimpo = documento.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numeroLimpo.length == 11) {
      return Identificacao.cpf(numeroLimpo).numeroFormatado;
    } else if (numeroLimpo.length == 14) {
      return Identificacao.cnpj(numeroLimpo).numeroFormatado;
    }
    
    return documento;
  }

  /// Remove formatação de um documento
  static String limparDocumento(String documento) {
    return documento.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Cria identificação automaticamente baseada no documento
  static Identificacao criarIdentificacao(String documento) {
    final numeroLimpo = limparDocumento(documento);
    
    if (numeroLimpo.length == 11) {
      return Identificacao.cpf(numeroLimpo);
    } else if (numeroLimpo.length == 14) {
      return Identificacao.cnpj(numeroLimpo);
    }
    
    throw ValidationException('Documento inválido: $documento');
  }

  /// Valida período de apuração (formato MMAAAA)
  static bool isValidPeriodoApuracao(String periodo) {
    if (periodo.length != 6) return false;
    
    final mes = int.tryParse(periodo.substring(0, 2));
    final ano = int.tryParse(periodo.substring(2, 6));
    
    if (mes == null || ano == null) return false;
    if (mes < 1 || mes > 12) return false;
    if (ano < 1900 || ano > 2100) return false;
    
    return true;
  }

  /// Formata período de apuração
  static String formatarPeriodoApuracao(int mes, int ano) {
    if (mes < 1 || mes > 12) {
      throw ValidationException('Mês deve estar entre 1 e 12');
    }
    if (ano < 1900 || ano > 2100) {
      throw ValidationException('Ano deve estar entre 1900 e 2100');
    }
    
    return '${mes.toString().padLeft(2, '0')}$ano';
  }

  /// Valida código de receita
  static bool isValidCodigoReceita(String codigo) {
    // Códigos de receita geralmente têm 4 dígitos
    return RegExp(r'^\d{4}$').hasMatch(codigo);
  }

  /// Valida valor monetário
  static bool isValidValorMonetario(String valor) {
    // Aceita formatos: 1500.00, 1500,00, 1.500,00, 1,500.00
    return RegExp(r'^\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?$').hasMatch(valor);
  }

  /// Normaliza valor monetário para formato padrão (1500.00)
  static String normalizarValorMonetario(String valor) {
    // Remove espaços
    String normalizado = valor.trim();
    
    // Se tem vírgula como separador decimal
    if (normalizado.contains(',') && !normalizado.contains('.')) {
      normalizado = normalizado.replaceAll(',', '.');
    }
    // Se tem ponto como separador de milhares e vírgula como decimal
    else if (normalizado.contains('.') && normalizado.contains(',')) {
      normalizado = normalizado.replaceAll('.', '').replaceAll(',', '.');
    }
    
    // Garante duas casas decimais
    if (!normalizado.contains('.')) {
      normalizado += '.00';
    } else {
      final parts = normalizado.split('.');
      if (parts.length == 2 && parts[1].length == 1) {
        normalizado += '0';
      }
    }
    
    return normalizado;
  }

  /// Calcula hash SHA256 de um arquivo
  static String calcularHashArquivo(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Converte arquivo para base64
  static String arquivoParaBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Converte base64 para bytes
  static Uint8List base64ParaBytes(String base64String) {
    return base64Decode(base64String);
  }

  /// Valida se uma string está em formato base64
  static bool isValidBase64(String input) {
    try {
      base64Decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cria pedido de consulta de situação fiscal
  static PedidoDados criarPedidoConsultaSituacaoFiscal({
    required String documento,
    required String anoBase,
    bool incluirDebitos = false,
    bool incluirCertidoes = false,
  }) {
    final identificacao = criarIdentificacao(documento);
    
    return PedidoDados(
      identificacao: identificacao,
      servico: 'SITFIS.CONSULTAR',
      parametros: {
        'ano_base': anoBase,
        'incluir_debitos': incluirDebitos,
        'incluir_certidoes': incluirCertidoes,
      },
    );
  }

  /// Cria pedido de consulta de dados de empresa
  static PedidoDados criarPedidoConsultaDadosEmpresa({
    required String cnpj,
    bool incluirSocios = false,
    bool incluirAtividades = false,
    bool incluirEndereco = false,
  }) {
    final identificacao = criarIdentificacao(cnpj);
    
    if (identificacao.tipo != 'CNPJ') {
      throw ValidationException('Documento deve ser um CNPJ válido');
    }
    
    return PedidoDados(
      identificacao: identificacao,
      servico: 'EMPRESA.CONSULTAR',
      parametros: {
        'incluir_socios': incluirSocios,
        'incluir_atividades': incluirAtividades,
        'incluir_endereco': incluirEndereco,
      },
    );
  }

  /// Cria pedido de declaração IRPF
  static PedidoDados criarPedidoDeclaracaoIRPF({
    required String cpf,
    required String anoCalendario,
    required String tipoDeclaracao,
    required Uint8List arquivoDeclaracao,
    bool calcularHash = true,
  }) {
    final identificacao = criarIdentificacao(cpf);
    
    if (identificacao.tipo != 'CPF') {
      throw ValidationException('Documento deve ser um CPF válido');
    }
    
    final arquivoBase64 = arquivoParaBase64(arquivoDeclaracao);
    final hashArquivo = calcularHash ? calcularHashArquivo(arquivoDeclaracao) : null;
    
    return PedidoDados(
      identificacao: identificacao,
      servico: 'IRPF.DECLARAR',
      parametros: {
        'ano_calendario': anoCalendario,
        'tipo_declaracao': tipoDeclaracao,
        'arquivo_declaracao': arquivoBase64,
        'hash_arquivo': hashArquivo,
      },
    );
  }

  /// Cria pedido de emissão de DARF
  static PedidoDados criarPedidoEmissaoDARF({
    required String documento,
    required String codigoReceita,
    required int mes,
    required int ano,
    required String valorPrincipal,
    String? valorMulta,
    String? valorJuros,
    required DateTime dataVencimento,
  }) {
    final identificacao = criarIdentificacao(documento);
    
    if (!isValidCodigoReceita(codigoReceita)) {
      throw ValidationException('Código de receita inválido: $codigoReceita');
    }
    
    final periodoApuracao = formatarPeriodoApuracao(mes, ano);
    final valorPrincipalNormalizado = normalizarValorMonetario(valorPrincipal);
    final valorMultaNormalizada = valorMulta != null ? normalizarValorMonetario(valorMulta) : null;
    final valorJurosNormalizado = valorJuros != null ? normalizarValorMonetario(valorJuros) : null;
    
    return PedidoDados(
      identificacao: identificacao,
      servico: 'SICALC.EMITIR_DARF',
      parametros: {
        'codigo_receita': codigoReceita,
        'periodo_apuracao': periodoApuracao,
        'valor_principal': valorPrincipalNormalizado,
        'valor_multa': valorMultaNormalizada,
        'valor_juros': valorJurosNormalizado,
        'data_vencimento': dataVencimento.toIso8601String(),
      },
    );
  }

  /// Cria dados de entrada para validação de certificado
  static DadosEntrada criarDadosValidacaoCertificado({
    required Uint8List certificado,
    required String senha,
    bool validarCadeia = true,
  }) {
    final certificadoBase64 = arquivoParaBase64(certificado);
    
    return DadosEntrada.validacaoCertificado(
      certificadoBase64: certificadoBase64,
      senha: senha,
      validarCadeia: validarCadeia,
    );
  }

  /// Valida dados de entrada antes de enviar para API
  static void validarDadosEntrada(dynamic dados) {
    if (dados is PedidoDados) {
      if (!dados.isValid) {
        throw ValidationException('Dados do pedido são inválidos');
      }
    } else if (dados is DadosEntrada) {
      if (!dados.isValid) {
        throw ValidationException('Dados de entrada são inválidos');
      }
    }
  }

  /// Extrai informações úteis de um erro da API
  static Map<String, dynamic> extrairInformacoesErro(IntegraContadorException error) {
    return {
      'tipo': error.runtimeType.toString(),
      'mensagem': error.message,
      'codigo': error.code,
      'detalhes': error.details,
      'sugestao': _obterSugestaoErro(error),
      'pode_tentar_novamente': _podeTentarNovamente(error),
    };
  }

  /// Obtém sugestão de ação baseada no tipo de erro
  static String _obterSugestaoErro(IntegraContadorException error) {
    if (error is ValidationException) {
      return 'Verifique os dados enviados e corrija os erros indicados.';
    } else if (error is AuthenticationException) {
      return 'Verifique se o token JWT está válido e não expirou.';
    } else if (error is AuthorizationException) {
      return 'Verifique se você tem permissão para esta operação.';
    } else if (error is NetworkException) {
      return 'Verifique sua conexão com a internet.';
    } else if (error is ServerException) {
      return 'Erro interno do servidor. Tente novamente mais tarde.';
    } else if (error is TimeoutException) {
      return 'A requisição demorou muito. Tente novamente.';
    } else if (error is RateLimitException) {
      final rateLimitError = error;
      return 'Muitas requisições. Aguarde ${rateLimitError.retryAfter ?? 60} segundos.';
    }
    
    return 'Consulte a documentação da API para mais detalhes.';
  }

  /// Verifica se vale a pena tentar novamente baseado no tipo de erro
  static bool _podeTentarNovamente(IntegraContadorException error) {
    return error is NetworkException || 
           error is TimeoutException || 
           error is ServerException ||
           error is RateLimitException;
  }

  /// Formata data para o padrão da API (YYYY-MM-DD)
  static String formatarDataParaAPI(DateTime data) {
    return data.toIso8601String().split('T')[0];
  }

  /// Converte string de data da API para DateTime
  static DateTime? parseDataDaAPI(String? dataString) {
    if (dataString == null || dataString.isEmpty) return null;
    
    try {
      return DateTime.parse(dataString);
    } catch (e) {
      return null;
    }
  }

  /// Valida se um ano é válido para operações fiscais
  static bool isValidAnoFiscal(String ano) {
    final anoInt = int.tryParse(ano);
    if (anoInt == null) return false;
    
    final anoAtual = DateTime.now().year;
    return anoInt >= 1990 && anoInt <= anoAtual + 1;
  }

  /// Obtém lista de anos fiscais válidos
  static List<String> obterAnosFiscaisValidos({int anosAnteriores = 10}) {
    final anoAtual = DateTime.now().year;
    final anos = <String>[];
    
    for (int i = anoAtual; i >= anoAtual - anosAnteriores; i--) {
      anos.add(i.toString());
    }
    
    return anos;
  }

  /// Valida se um tipo de declaração é válido
  static bool isValidTipoDeclaracao(String tipo) {
    const tiposValidos = ['completa', 'simplificada', 'retificadora'];
    return tiposValidos.contains(tipo.toLowerCase());
  }

  /// Obtém lista de tipos de declaração válidos
  static List<String> obterTiposDeclaracaoValidos() {
    return ['completa', 'simplificada', 'retificadora'];
  }

  /// Calcula dígito verificador de CPF
  static String calcularDigitoVerificadorCPF(String cpfSemDigito) {
    if (cpfSemDigito.length != 9) {
      throw ValidationException('CPF deve ter 9 dígitos para cálculo do verificador');
    }
    
    // Primeiro dígito
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpfSemDigito[i]) * (10 - i);
    }
    int primeiroDigito = 11 - (soma % 11);
    if (primeiroDigito >= 10) primeiroDigito = 0;
    
    // Segundo dígito
    soma = 0;
    final cpfComPrimeiroDigito = cpfSemDigito + primeiroDigito.toString();
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpfComPrimeiroDigito[i]) * (11 - i);
    }
    int segundoDigito = 11 - (soma % 11);
    if (segundoDigito >= 10) segundoDigito = 0;
    
    return '$primeiroDigito$segundoDigito';
  }

  /// Calcula dígito verificador de CNPJ
  static String calcularDigitoVerificadorCNPJ(String cnpjSemDigito) {
    if (cnpjSemDigito.length != 12) {
      throw ValidationException('CNPJ deve ter 12 dígitos para cálculo do verificador');
    }
    
    // Primeiro dígito
    const pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int soma = 0;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpjSemDigito[i]) * pesos1[i];
    }
    int primeiroDigito = soma % 11;
    primeiroDigito = primeiroDigito < 2 ? 0 : 11 - primeiroDigito;
    
    // Segundo dígito
    const pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    soma = 0;
    final cnpjComPrimeiroDigito = cnpjSemDigito + primeiroDigito.toString();
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpjComPrimeiroDigito[i]) * pesos2[i];
    }
    int segundoDigito = soma % 11;
    segundoDigito = segundoDigito < 2 ? 0 : 11 - segundoDigito;
    
    return '$primeiroDigito$segundoDigito';
  }
}

