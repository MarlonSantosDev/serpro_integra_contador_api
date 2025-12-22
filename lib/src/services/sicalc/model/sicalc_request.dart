import '../../../base/base_request.dart';
import 'sicalc_enums.dart';

/// Modelo para requisição de consolidação e emissão de DARF
class ConsolidarEmitirDarfRequest extends BaseRequest {
  /// Unidade Federativa
  final String uf;

  /// Código do Município
  final int municipio;

  /// Código da Receita
  final String codigoReceita;

  /// Código da Extensão da Receita
  final String codigoReceitaExtensao;

  /// Tipo do período de apuração
  final String tipoPA;

  /// Data do período de apuração (formato MM/AAAA)
  final String dataPA;

  /// Data de vencimento do tributo (formato ISO 8601)
  final String vencimento;

  /// Valor do Imposto
  final double valorImposto;

  /// Data da Consolidação (Data do Pagamento) - formato ISO 8601
  final String dataConsolidacao;

  /// Número de referência utilizado no preenchimento do DARF
  final String? numeroReferencia;

  /// Número da cota (para os débitos que possuem cotas)
  final int? cota;

  /// Valor da multa - Preenchido somente no caso de DARF manual
  final double? valorMulta;

  /// Valor dos juros - Preenchido somente no caso de DARF manual
  final double? valorJuros;

  /// Indicador de ganho de capital
  final bool? ganhoCapital;

  /// Data da Alienação referente ao Ganho de Capital - formato ISO 8601
  final String? dataAlienacao;

  /// Campo observação do DARF
  final String? observacao;

  /// Número do cadastro nacional de obras
  final int? cno;

  /// Número do Cadastro Nacional Pessoa Jurídica do prestador
  final String? cnpjPrestador;

  ConsolidarEmitirDarfRequest({
    required super.contribuinteNumero,
    required this.uf,
    required this.municipio,
    required this.codigoReceita,
    required this.codigoReceitaExtensao,
    required this.tipoPA,
    required this.dataPA,
    required this.vencimento,
    required this.valorImposto,
    required this.dataConsolidacao,
    this.numeroReferencia,
    this.cota,
    this.valorMulta,
    this.valorJuros,
    this.ganhoCapital,
    this.dataAlienacao,
    this.observacao,
    this.cno,
    this.cnpjPrestador,
  }) : super(
         pedidoDados: PedidoDados(
           idSistema: 'SICALC',
           idServico: ServicoSicalc.consolidarEmitirDarf.idServico,
           versaoSistema: '2.9',
           dados: '{}',
         ),
       );

  /// Valida os dados da requisição
  List<String> validarDados() {
    final erros = <String>[];

    // Validar UF
    if (uf.isEmpty || uf.length != 2) {
      erros.add('UF deve ter 2 caracteres');
    }

    // Validar município
    if (municipio <= 0) {
      erros.add('Código do município deve ser maior que zero');
    }

    // Validar código da receita
    if (codigoReceita.isEmpty) {
      erros.add('Código da receita é obrigatório');
    }

    // Validar código da extensão da receita
    if (codigoReceitaExtensao.isEmpty) {
      erros.add('Código da extensão da receita é obrigatório');
    }

    // Validar tipo PA
    if (tipoPA.isEmpty) {
      erros.add('Tipo do período de apuração é obrigatório');
    }

    // Validar data PA
    if (dataPA.isEmpty) {
      erros.add('Data do período de apuração é obrigatória');
    }

    // Validar vencimento
    if (vencimento.isEmpty) {
      erros.add('Data de vencimento é obrigatória');
    }

    // Validar valor do imposto
    if (valorImposto <= 0) {
      erros.add('Valor do imposto deve ser maior que zero');
    }

    // Validar data de consolidação
    if (dataConsolidacao.isEmpty) {
      erros.add('Data de consolidação é obrigatória');
    }

    return erros;
  }
}

/// Modelo para requisição de consulta de receitas
class ConsultarReceitasRequest extends BaseRequest {
  /// Código da Receita
  final String codigoReceita;

  ConsultarReceitasRequest({
    required super.contribuinteNumero,
    required this.codigoReceita,
  }) : super(
         pedidoDados: PedidoDados(
           idSistema: 'SICALC',
           idServico: ServicoSicalc.consultarReceitas.idServico,
           versaoSistema: '2.9',
           dados: {'codigoReceita': codigoReceita}.toString(),
         ),
       );

  /// Valida os dados da requisição
  List<String> validarDados() {
    final erros = <String>[];

    if (codigoReceita.isEmpty) {
      erros.add('Código da receita é obrigatório');
    }

    return erros;
  }
}

/// Modelo para requisição de geração de código de barras
class GerarCodigoBarrasRequest extends BaseRequest {
  /// Unidade Federativa
  final String uf;

  /// Código do Município
  final int municipio;

  /// Código da Receita
  final String codigoReceita;

  /// Código da Extensão da Receita
  final String codigoReceitaExtensao;

  /// Tipo do período de apuração
  final String tipoPA;

  /// Data do período de apuração (formato MM/AAAA)
  final String dataPA;

  /// Data de vencimento do tributo (formato ISO 8601)
  final String vencimento;

  /// Valor do Imposto
  final double valorImposto;

  /// Data da Consolidação (Data do Pagamento) - formato ISO 8601
  final String dataConsolidacao;

  /// Número de referência utilizado no preenchimento do DARF
  final String? numeroReferencia;

  /// Número da cota (para os débitos que possuem cotas)
  final int? cota;

  /// Valor da multa - Preenchido somente no caso de DARF manual
  final double? valorMulta;

  /// Valor dos juros - Preenchido somente no caso de DARF manual
  final double? valorJuros;

  /// Indicador de ganho de capital
  final bool? ganhoCapital;

  /// Data da Alienação referente ao Ganho de Capital - formato ISO 8601
  final String? dataAlienacao;

  /// Campo observação do DARF
  final String? observacao;

  /// Número do cadastro nacional de obras
  final int? cno;

  /// Número do Cadastro Nacional Pessoa Jurídica do prestador
  final String? cnpjPrestador;

  GerarCodigoBarrasRequest({
    required super.contribuinteNumero,
    required this.uf,
    required this.municipio,
    required this.codigoReceita,
    required this.codigoReceitaExtensao,
    required this.tipoPA,
    required this.dataPA,
    required this.vencimento,
    required this.valorImposto,
    required this.dataConsolidacao,
    this.numeroReferencia,
    this.cota,
    this.valorMulta,
    this.valorJuros,
    this.ganhoCapital,
    this.dataAlienacao,
    this.observacao,
    this.cno,
    this.cnpjPrestador,
  }) : super(
         pedidoDados: PedidoDados(
           idSistema: 'SICALC',
           idServico: ServicoSicalc.gerarCodigoBarras.idServico,
           versaoSistema: '2.9',
           dados: '{}',
         ),
       );

  /// Valida os dados da requisição
  List<String> validarDados() {
    final erros = <String>[];

    // Validar UF
    if (uf.isEmpty || uf.length != 2) {
      erros.add('UF deve ter 2 caracteres');
    }

    // Validar município
    if (municipio <= 0) {
      erros.add('Código do município deve ser maior que zero');
    }

    // Validar código da receita
    if (codigoReceita.isEmpty) {
      erros.add('Código da receita é obrigatório');
    }

    // Validar código da extensão da receita
    if (codigoReceitaExtensao.isEmpty) {
      erros.add('Código da extensão da receita é obrigatório');
    }

    // Validar tipo PA
    if (tipoPA.isEmpty) {
      erros.add('Tipo do período de apuração é obrigatório');
    }

    // Validar data PA
    if (dataPA.isEmpty) {
      erros.add('Data do período de apuração é obrigatória');
    }

    // Validar vencimento
    if (vencimento.isEmpty) {
      erros.add('Data de vencimento é obrigatória');
    }

    // Validar valor do imposto
    if (valorImposto <= 0) {
      erros.add('Valor do imposto deve ser maior que zero');
    }

    // Validar data de consolidação
    if (dataConsolidacao.isEmpty) {
      erros.add('Data de consolidação é obrigatória');
    }

    return erros;
  }
}
