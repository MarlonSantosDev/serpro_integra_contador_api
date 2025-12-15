import 'package:flutter/material.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import '../services/auth_service.dart';
import '../widgets/result_display_widget.dart';
import 'service_list_screen.dart';
import 'dart:convert';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceItem service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Controllers comuns para todos os serviços
    _controllers['contribuinteNumero'] = TextEditingController();
    _controllers['contratanteNumero'] = TextEditingController();
    _controllers['autorPedidoDadosNumero'] = TextEditingController();

    // Controllers específicos por serviço
    switch (widget.service.id) {
      case 'ccmei':
        // CCMEI não precisa de campos adicionais
        break;
      case 'pgmei':
        _controllers['competencia'] = TextEditingController();
        break;
      case 'pgdasd':
        _controllers['periodoApuracao'] = TextEditingController();
        break;
      case 'caixa_postal':
        _controllers['cpfCnpj'] = TextEditingController();
        break;
      case 'dctfweb':
        _controllers['anoPA'] = TextEditingController();
        _controllers['mesPA'] = TextEditingController();
        break;
      case 'sicalc':
        _controllers['codigoReceita'] = TextEditingController();
        break;
      case 'pagtoweb':
        _controllers['dataInicial'] = TextEditingController();
        _controllers['dataFinal'] = TextEditingController();
        break;
      case 'eventos_atualizacao':
        // Pode receber múltiplos CNPJs separados por vírgula
        break;
      case 'procuracoes':
        _controllers['outorgado'] = TextEditingController();
        break;
      case 'autenticaprocurador':
        _controllers['contratanteNome'] = TextEditingController();
        _controllers['autorNome'] = TextEditingController();
        _controllers['certificadoBase64'] = TextEditingController();
        _controllers['senhaCertificado'] = TextEditingController();
        break;
      case 'regime_apuracao':
        _controllers['anoCalendario'] = TextEditingController();
        break;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _executeService() async {
    if (!AuthService.isAuthenticated) {
      setState(() {
        _error = 'Não autenticado. Configure as credenciais primeiro.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final apiClient = AuthService.apiClient!;
      dynamic result;

      switch (widget.service.id) {
        case 'ccmei':
          result = await _executeCcmei(apiClient);
          break;
        case 'pgmei':
          result = await _executePgmei(apiClient);
          break;
        case 'pgdasd':
          result = await _executePgdasd(apiClient);
          break;
        case 'caixa_postal':
          result = await _executeCaixaPostal(apiClient);
          break;
        case 'dctfweb':
          result = await _executeDctfweb(apiClient);
          break;
        case 'defis':
          result = await _executeDefis(apiClient);
          break;
        case 'sitfis':
          result = await _executeSitfis(apiClient);
          break;
        case 'sicalc':
          result = await _executeSicalc(apiClient);
          break;
        case 'parcmei':
          result = await _executeParcmei(apiClient);
          break;
        case 'parcmei_especial':
          result = await _executeParcmeiEspecial(apiClient);
          break;
        case 'pertmei':
          result = await _executePertmei(apiClient);
          break;
        case 'relpmei':
          result = await _executeRelpmei(apiClient);
          break;
        case 'parcsn':
          result = await _executeParcsn(apiClient);
          break;
        case 'parcsn_especial':
          result = await _executeParcsnEspecial(apiClient);
          break;
        case 'pertsn':
          result = await _executePertsn(apiClient);
          break;
        case 'relpsn':
          result = await _executeRelpsn(apiClient);
          break;
        case 'dte':
          result = await _executeDte(apiClient);
          break;
        case 'pagtoweb':
          result = await _executePagtoweb(apiClient);
          break;
        case 'mit':
          result = await _executeMit(apiClient);
          break;
        case 'eventos_atualizacao':
          result = await _executeEventosAtualizacao(apiClient);
          break;
        case 'procuracoes':
          result = await _executeProcuracoes(apiClient);
          break;
        case 'autenticaprocurador':
          result = await _executeAutenticaProcurador(apiClient);
          break;
        case 'regime_apuracao':
          result = await _executeRegimeApuracao(apiClient);
          break;
        default:
          throw Exception('Serviço não implementado: ${widget.service.id}');
      }

      setState(() {
        _result = _formatResult(result);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _result = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatResult(dynamic result) {
    try {
      if (result == null) return 'null';
      if (result is String) return result;
      return const JsonEncoder.withIndent('  ').convert(result);
    } catch (e) {
      return result.toString();
    }
  }

  String? _getValue(String key) {
    final controller = _controllers[key];
    if (controller == null) return null;
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String _getValueOr(String key, String defaultValue) {
    return _getValue(key) ?? defaultValue;
  }

  // Implementações dos serviços
  Future<dynamic> _executeCcmei(ApiClient apiClient) async {
    final service = CcmeiService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');

    // Emitir CCMEI
    final response = await service.emitirCcmei(
      cnpj,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': {'cnpj': response.dados.cnpj, 'pdfGerado': response.dados.pdf.isNotEmpty, 'tamanhoPdf': response.dados.pdf.length},
    };
  }

  Future<dynamic> _executePgmei(ApiClient apiClient) async {
    final service = PgmeiService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');
    final competencia = _getValueOr('competencia', '202401');

    // Gerar DAS com PDF
    final response = await service.gerarDas(
      cnpj: cnpj,
      periodoApuracao: competencia,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    final dasGerados = response.dasGerados ?? [];

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': {
        'totalDas': dasGerados.length,
        'das': dasGerados
            .map(
              (das) => {
                'cnpj': das.cnpjCompleto,
                'razaoSocial': das.razaoSocial,
                'pdfGerado': das.pdf.isNotEmpty,
                'tamanhoPdf': das.pdf.length,
                'detalhamentos': das.detalhamento.length,
              },
            )
            .toList(),
      },
    };
  }

  Future<dynamic> _executePgdasd(ApiClient apiClient) async {
    final service = PgdasdService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');
    final periodoApuracao = _getValue('periodoApuracao') ?? '012024';

    // Consultar última declaração
    final response = await service.consultarUltimaDeclaracao(
      contribuinteNumero: cnpj,
      request: ConsultarUltimaDeclaracaoRequest(periodoApuracao: periodoApuracao),
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': response.dados?.toJson() ?? {},
    };
  }

  Future<dynamic> _executeCaixaPostal(ApiClient apiClient) async {
    final service = CaixaPostalService(apiClient);
    final cpfCnpj = _getValueOr('cpfCnpj', '99999999999');

    // Obter indicador de novas mensagens
    final response = await service.obterIndicadorNovasMensagens(
      cpfCnpj,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': response.dados != null ? (response.dados as Map).map((k, v) => MapEntry(k.toString(), v)) : {},
    };
  }

  Future<dynamic> _executeDctfweb(ApiClient apiClient) async {
    final service = DctfWebService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');
    final anoPA = _getValue('anoPA') ?? '2024';
    final mesPA = _getValue('mesPA') ?? '01';

    // Gerar documento de arrecadação
    final response = await service.gerarDocumentoArrecadacao(
      contribuinteNumero: contribuinte,
      categoria: CategoriaDctf.geralMensal,
      anoPA: anoPA,
      mesPA: mesPA,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => m.toJson()).toList(),
      'dados': {'sucesso': response.sucesso, 'pdfGerado': response.pdfBase64 != null, 'tamanhoPdf': response.tamanhoPdfBytes},
    };
  }

  Future<dynamic> _executeDefis(ApiClient apiClient) async {
    final service = DefisService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');

    // Consultar declarações transmitidas
    final response = await service.consultarDeclaracoesTransmitidas(
      contribuinteNumero: cnpj,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => m.toJson()).toList(),
      'dados': {'totalDeclaracoes': response.dados.length, 'declaracoes': response.dados.map((d) => d.toJson()).toList()},
    };
  }

  Future<dynamic> _executeSitfis(ApiClient apiClient) async {
    final service = SitfisService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');

    // Solicitar protocolo
    final protocoloResponse = await service.solicitarProtocoloRelatorio(
      contribuinte,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': protocoloResponse.status,
      'mensagens': protocoloResponse.mensagens.map((m) => m.toJson()).toList(),
      'dados': {
        'protocoloRelatorio': protocoloResponse.dados?.protocoloRelatorio,
        'tempoEspera': protocoloResponse.dados?.tempoEspera,
        'hasProtocolo': protocoloResponse.hasProtocolo,
        'hasTempoEspera': protocoloResponse.hasTempoEspera,
      },
    };
  }

  Future<dynamic> _executeSicalc(ApiClient apiClient) async {
    final service = SicalcService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');
    final codigoReceita = _getValue('codigoReceita') ?? '1850';

    // Consultar receitas
    final response = await service.consultarReceitas(
      ConsultarReceitasRequest(contribuinteNumero: contribuinte, codigoReceita: codigoReceita),
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens?.map((m) => m.toJson()).toList() ?? [],
      'dados': {
        'receita': response.receita != null
            ? {
                'codigoReceita': response.receita!.codigoReceita,
                'descricaoReceita': response.receita!.descricaoReceita,
                'extensoes': response.receita!.extensoes.length,
              }
            : null,
      },
    };
  }

  Future<dynamic> _executeParcmei(ApiClient apiClient) async {
    final service = ParcmeiService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeParcmeiEspecial(ApiClient apiClient) async {
    final service = ParcmeiEspecialService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executePertmei(ApiClient apiClient) async {
    final service = PertmeiService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos(cnpj);

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeRelpmei(ApiClient apiClient) async {
    final service = RelpmeiService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos(
      contribuinteNumero: cnpj,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => m.toJson()).toList(),
      'dados': {
        'totalParcelamentos': response.parcelamentos?.length ?? 0,
        'parcelamentos': response.parcelamentos?.map((p) => {'numero': p.numero, 'situacao': p.situacao}).toList() ?? [],
      },
    };
  }

  Future<dynamic> _executeParcsn(ApiClient apiClient) async {
    final service = ParcsnService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeParcsnEspecial(ApiClient apiClient) async {
    final service = ParcsnEspecialService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executePertsn(ApiClient apiClient) async {
    final service = PertsnService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeRelpsn(ApiClient apiClient) async {
    final service = RelpsnService(apiClient);

    // Consultar pedidos de parcelamento
    final response = await service.consultarPedidos();

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeDte(ApiClient apiClient) async {
    final service = DteService(apiClient);
    final cnpj = _getValueOr('contribuinteNumero', '00000000000000');

    // Obter indicador DTE
    final response = await service.obterIndicadorDte(
      cnpj,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': {
        'isOptanteDte': response.isOptanteDte,
        'isOptanteSimples': response.isOptanteSimples,
        'statusEnquadramento': response.statusEnquadramentoDescricao,
        'indicadorEnquadramento': response.dados?.indicadorEnquadramento,
      },
    };
  }

  Future<dynamic> _executePagtoweb(ApiClient apiClient) async {
    final service = PagtoWebService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');
    final dataInicial = _getValue('dataInicial');
    final dataFinal = _getValue('dataFinal');

    // Consultar pagamentos
    final response = await service.consultarPagamentos(
      contribuinteNumero: contribuinte,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeMit(ApiClient apiClient) async {
    final service = MitService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');
    final anoApuracao = int.tryParse(_getValue('anoApuracao') ?? '2024') ?? 2024;

    // Listar apurações
    final response = await service.listarApuracaoes(
      contribuinteNumero: contribuinte,
      anoApuracao: anoApuracao,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => m.toJson()).toList(),
      'dados': {
        'totalApuracaoes': response.apuracoes?.length ?? 0,
        'apuracaoes': response.apuracoes?.take(5).map((a) => {'periodoApuracao': a.periodoApuracao, 'situacao': a.situacao}).toList() ?? [],
      },
    };
  }

  Future<dynamic> _executeEventosAtualizacao(ApiClient apiClient) async {
    final service = EventosAtualizacaoService(apiClient);
    final cnpjs = _getValue('contribuinteNumero')?.split(',').where((e) => e.trim().isNotEmpty).toList() ?? ['00000000000000'];

    // Solicitar eventos para PJ
    final response = await service.solicitarEventosPJ(
      cnpjs: cnpjs,
      evento: TipoEvento.dctfWeb,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  Future<dynamic> _executeProcuracoes(ApiClient apiClient) async {
    final service = ProcuracoesService(apiClient);
    final outorgante = _getValueOr('contribuinteNumero', '00000000000000');
    final outorgado = _getValue('outorgado');

    // Consultar procurações
    final response = await service.consultarProcuracao(
      outorgante: outorgante,
      outorgado: outorgado,
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.status,
      'mensagens': response.mensagens.map((m) => {'codigo': m.codigo, 'texto': m.texto}).toList(),
      'dados': {
        'totalProcuracoes': response.dados?.length ?? 0,
        'procuracoes':
            response.dados
                ?.map((p) => {'status': p.status.value, 'dataExpiracao': p.dataExpiracaoFormatada, 'sistemas': p.sistemas.join(', ')})
                .toList() ??
            [],
      },
    };
  }

  Future<dynamic> _executeAutenticaProcurador(ApiClient apiClient) async {
    final service = AutenticaProcuradorService(apiClient);
    final contratanteNome = _getValue('contratanteNome') ?? 'Empresa Contratante';
    final autorNome = _getValue('autorNome') ?? 'Procurador';
    final contribuinte = _getValue('contribuinteNumero');
    final certBase64 = _getValue('certificadoBase64');
    final certPassword = _getValue('senhaCertificado') ?? '';

    if (certBase64 == null || certBase64.isEmpty) {
      return {
        'erro': 'Certificado Base64 é obrigatório para autenticação de procurador',
        'instrucoes': 'Informe o certificado do procurador em Base64 e a senha',
      };
    }

    // Autenticar procurador
    final response = await service.autenticarProcurador(
      contratanteNome: contratanteNome,
      autorNome: autorNome,
      contribuinteNumero: contribuinte,
      certificadoBase64: certBase64,
      certificadoPassword: certPassword,
      contratanteNumero: _getValue('contratanteNumero'),
      autorNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {
      'status': response.sucesso ? '200' : '400',
      'mensagens': [],
      'dados': {
        'sucesso': response.sucesso,
        'token': response.autenticarProcuradorToken,
        'dataExpiracao': response.dataExpiracao,
        'isCacheValido': response.isCacheValido,
      },
    };
  }

  Future<dynamic> _executeRegimeApuracao(ApiClient apiClient) async {
    final service = RegimeApuracaoService(apiClient);
    final contribuinte = _getValueOr('contribuinteNumero', '00000000000000');
    final anoCalendario = int.tryParse(_getValue('anoCalendario') ?? '2024') ?? 2024;

    // Consultar opção de regime
    final response = await service.consultarOpcaoRegime(
      contribuinteNumero: contribuinte,
      request: ConsultarOpcaoRegimeRequest(anoCalendario: anoCalendario),
      contratanteNumero: _getValue('contratanteNumero'),
      autorPedidoDadosNumero: _getValue('autorPedidoDadosNumero'),
    );

    return {'status': response.status, 'mensagens': response.mensagens.map((m) => m.toJson()).toList(), 'dados': response.toJson()};
  }

  List<Widget> _buildInputFields() {
    final fields = <Widget>[];

    // Campos comuns
    fields.add(
      TextField(
        controller: _controllers['contribuinteNumero'],
        decoration: const InputDecoration(
          labelText: 'CPF/CNPJ Contribuinte',
          border: OutlineInputBorder(),
          helperText: 'CPF ou CNPJ do contribuinte',
        ),
        keyboardType: TextInputType.number,
      ),
    );

    fields.add(const SizedBox(height: 16));

    fields.add(
      TextField(
        controller: _controllers['contratanteNumero'],
        decoration: const InputDecoration(
          labelText: 'CNPJ Contratante (Opcional)',
          border: OutlineInputBorder(),
          helperText: 'Deixe vazio para usar o padrão da autenticação',
        ),
        keyboardType: TextInputType.number,
      ),
    );

    fields.add(const SizedBox(height: 16));

    fields.add(
      TextField(
        controller: _controllers['autorPedidoDadosNumero'],
        decoration: const InputDecoration(
          labelText: 'CPF/CNPJ Autor do Pedido (Opcional)',
          border: OutlineInputBorder(),
          helperText: 'Deixe vazio para usar o padrão da autenticação',
        ),
        keyboardType: TextInputType.number,
      ),
    );

    // Campos específicos por serviço
    switch (widget.service.id) {
      case 'pgmei':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['competencia'],
            decoration: const InputDecoration(labelText: 'Competência (AAAAMM)', border: OutlineInputBorder(), helperText: 'Exemplo: 202401'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'caixa_postal':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['cpfCnpj'],
            decoration: const InputDecoration(
              labelText: 'CPF/CNPJ',
              border: OutlineInputBorder(),
              helperText: 'CPF ou CNPJ para consultar mensagens',
            ),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'pgdasd':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['periodoApuracao'],
            decoration: const InputDecoration(labelText: 'Período de Apuração (MMAAAA)', border: OutlineInputBorder(), helperText: 'Exemplo: 012024'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'dctfweb':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['anoPA'],
            decoration: const InputDecoration(labelText: 'Ano PA (AAAA)', border: OutlineInputBorder(), helperText: 'Exemplo: 2024'),
            keyboardType: TextInputType.number,
          ),
        );
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['mesPA'],
            decoration: const InputDecoration(labelText: 'Mês PA (MM)', border: OutlineInputBorder(), helperText: 'Exemplo: 01'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'sicalc':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['codigoReceita'],
            decoration: const InputDecoration(labelText: 'Código da Receita', border: OutlineInputBorder(), helperText: 'Exemplo: 1850'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'pagtoweb':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['dataInicial'],
            decoration: const InputDecoration(
              labelText: 'Data Inicial (AAAA-MM-DD)',
              border: OutlineInputBorder(),
              helperText: 'Exemplo: 2024-01-01',
            ),
          ),
        );
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['dataFinal'],
            decoration: const InputDecoration(labelText: 'Data Final (AAAA-MM-DD)', border: OutlineInputBorder(), helperText: 'Exemplo: 2024-12-31'),
          ),
        );
        break;
      case 'mit':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['anoApuracao'],
            decoration: const InputDecoration(labelText: 'Ano de Apuração', border: OutlineInputBorder(), helperText: 'Exemplo: 2024'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'eventos_atualizacao':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['contribuinteNumero'],
            decoration: const InputDecoration(
              labelText: 'CNPJs (separados por vírgula)',
              border: OutlineInputBorder(),
              helperText: 'Exemplo: 00000000000000,11111111000111',
            ),
          ),
        );
        break;
      case 'procuracoes':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['outorgado'],
            decoration: const InputDecoration(
              labelText: 'CPF/CNPJ Outorgado (Opcional)',
              border: OutlineInputBorder(),
              helperText: 'Deixe vazio para usar o padrão da autenticação',
            ),
            keyboardType: TextInputType.number,
          ),
        );
        break;
      case 'autenticaprocurador':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['contratanteNome'],
            decoration: const InputDecoration(
              labelText: 'Nome do Contratante',
              border: OutlineInputBorder(),
              helperText: 'Razão social da empresa contratante',
            ),
          ),
        );
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['autorNome'],
            decoration: const InputDecoration(
              labelText: 'Nome do Procurador',
              border: OutlineInputBorder(),
              helperText: 'Nome do procurador que assina o termo',
            ),
          ),
        );
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['certificadoBase64'],
            decoration: const InputDecoration(
              labelText: 'Certificado Base64 do Procurador',
              border: OutlineInputBorder(),
              helperText: 'Certificado P12/PFX em Base64',
            ),
            maxLines: 5,
          ),
        );
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['senhaCertificado'],
            decoration: const InputDecoration(
              labelText: 'Senha do Certificado',
              border: OutlineInputBorder(),
              helperText: 'Senha do certificado do procurador',
            ),
            obscureText: true,
          ),
        );
        break;
      case 'regime_apuracao':
        fields.add(const SizedBox(height: 16));
        fields.add(
          TextField(
            controller: _controllers['anoCalendario'],
            decoration: const InputDecoration(labelText: 'Ano Calendário', border: OutlineInputBorder(), helperText: 'Exemplo: 2024'),
            keyboardType: TextInputType.number,
          ),
        );
        break;
    }

    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.service.name), backgroundColor: widget.service.color.withValues(alpha: 0.2)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Descrição do serviço
                  Card(
                    color: widget.service.color.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(widget.service.icon, color: widget.service.color),
                              const SizedBox(width: 8),
                              Text(widget.service.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.service.description),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campos de entrada
                  ..._buildInputFields(),

                  const SizedBox(height: 24),

                  // Botão de execução
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _executeService,
                      style: ElevatedButton.styleFrom(backgroundColor: widget.service.color, foregroundColor: Colors.white),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Executar Serviço', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resultado ou erro
                  if (_error != null) ResultDisplayWidget(title: 'Erro', content: _error!, isError: true),

                  if (_result != null) ResultDisplayWidget(title: 'Resultado', content: _result!, isError: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
