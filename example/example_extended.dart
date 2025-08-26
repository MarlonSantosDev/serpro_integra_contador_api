import '../lib/integra_contador_api.dart';

/// Exemplo completo demonstrando o uso das 84 funcionalidades
/// da API Integra Contador do SERPRO
void main() async {
  // Configuração do serviço estendido
  final service = IntegraContadorBuilder().withJwtToken('SEU_TOKEN_JWT_AQUI').withProcuradorToken('TOKEN_PROCURADOR_OPCIONAL').withTimeout(Duration(seconds: 30)).withMaxRetries(3).build();

  print('🚀 Iniciando demonstração das 84 funcionalidades da API Integra Contador\n');

  try {
    // ========================================
    // EXEMPLOS INTEGRA-SN (Simples Nacional)
    // ========================================
    print('📊 === INTEGRA-SN (Simples Nacional) ===');

    await exemploSimplesnacional(service);

    // ========================================
    // EXEMPLOS INTEGRA-MEI
    // ========================================
    print('\n👤 === INTEGRA-MEI ===');

    await exemploMEI(service);

    // ========================================
    // EXEMPLOS DEFIS
    // ========================================
    print('\n📄 === DEFIS ===');

    await exemploDEFIS(service);

    // ========================================
    // EXEMPLOS INTEGRA-DCTFWEB
    // ========================================
    print('\n🏛️ === INTEGRA-DCTFWEB ===');

    await exemploDCTFWeb(service);

    // ========================================
    // EXEMPLOS OUTROS SISTEMAS
    // ========================================
    print('\n🔧 === OUTROS SISTEMAS ===');

    await exemploOutrosSistemas(service);

    // ========================================
    // EXEMPLOS DE MÉTODOS DE CONVENIÊNCIA
    // ========================================
    print('\n🎯 === MÉTODOS DE CONVENIÊNCIA ===');

    await exemploMetodosConveniencia(service);

    print('\n✅ Demonstração concluída com sucesso!');
  } catch (e) {
    print('❌ Erro durante a demonstração: $e');
  } finally {
    // Liberar recursos
    service.dispose();
  }
}

/// Exemplos do Simples Nacional
Future<void> exemploSimplesnacional(IntegraContadorExtendedService service) async {
  final cnpj = '12345678000195';
  final periodo = '012024';

  print('1. Consultando declarações do Simples Nacional...');
  final declaracoes = await service.consultarDeclaracoesSN(documento: cnpj, anoCalendario: '2024');

  if (declaracoes.isSuccess) {
    print('   ✅ Declarações encontradas: ${declaracoes.data?.dados?.length ?? 0}');
  } else {
    print('   ❌ Erro: ${declaracoes.error?.message}');
  }

  print('2. Gerando DAS do Simples Nacional...');
  final das = await service.gerarDASSN(documento: cnpj, periodoApuracao: periodo, valorReceita: '50000.00');

  if (das.isSuccess) {
    print('   ✅ DAS gerado com sucesso');
    print('   📄 Código de barras: ${das.data?.dados?['codigo_barras'] ?? 'N/A'}');
  } else {
    print('   ❌ Erro: ${das.error?.message}');
  }

  print('3. Consultando extrato do DAS...');
  final extrato = await service.consultarExtratoDAS(documento: cnpj, periodoApuracao: periodo);

  if (extrato.isSuccess) {
    print('   ✅ Extrato obtido com sucesso');
  } else {
    print('   ❌ Erro: ${extrato.error?.message}');
  }

  print('4. Consultando opção de regime de apuração...');
  final regime = await service.consultarOpcaoRegimeApuracao(documento: cnpj, anoCalendario: '2024');

  if (regime.isSuccess) {
    print('   ✅ Regime consultado: ${regime.data?.dados?['tipo_regime'] ?? 'N/A'}');
  } else {
    print('   ❌ Erro: ${regime.error?.message}');
  }
}

/// Exemplos do MEI
Future<void> exemploMEI(IntegraContadorExtendedService service) async {
  final cpf = '12345678901';
  final periodo = '012024';

  print('1. Gerando DAS MEI em PDF...');
  final dasPDF = await service.gerarDASMEIPDF(documento: cpf, periodoApuracao: periodo);

  if (dasPDF.isSuccess) {
    print('   ✅ DAS MEI PDF gerado com sucesso');
  } else {
    print('   ❌ Erro: ${dasPDF.error?.message}');
  }

  print('2. Emitindo Certificado de Condição MEI...');
  final certificado = await service.emitirCertificadoCondicaoMEI(cpf: cpf);

  if (certificado.isSuccess) {
    print('   ✅ Certificado emitido com sucesso');
  } else {
    print('   ❌ Erro: ${certificado.error?.message}');
  }

  print('3. Consultando situação cadastral MEI...');
  final situacao = await service.consultarSituacaoCadastralMEI(cpf: cpf);

  if (situacao.isSuccess) {
    print('   ✅ Situação: ${situacao.data?.dados?['situacao'] ?? 'N/A'}');
  } else {
    print('   ❌ Erro: ${situacao.error?.message}');
  }

  print('4. Consultando dívida ativa MEI...');
  final dividaAtiva = await service.consultarDividaAtivaMEI(documento: cpf);

  if (dividaAtiva.isSuccess) {
    print('   ✅ Dívida ativa consultada');
    final temDivida = dividaAtiva.data?.dados?['possui_divida'] ?? false;
    print('   📊 Possui dívida: ${temDivida ? 'Sim' : 'Não'}');
  } else {
    print('   ❌ Erro: ${dividaAtiva.error?.message}');
  }
}

/// Exemplos do DEFIS
Future<void> exemploDEFIS(IntegraContadorExtendedService service) async {
  final cnpj = '12345678000195';

  print('1. Consultando declarações DEFIS...');
  final declaracoes = await service.consultarDeclaracoesDEFIS(documento: cnpj, anoCalendario: '2024');

  if (declaracoes.isSuccess) {
    print('   ✅ Declarações DEFIS: ${declaracoes.data?.dados?.length ?? 0}');
  } else {
    print('   ❌ Erro: ${declaracoes.error?.message}');
  }

  print('2. Consultando última declaração DEFIS...');
  final ultima = await service.consultarUltimaDeclaracaoDEFIS(documento: cnpj, anoCalendario: '2024');

  if (ultima.isSuccess) {
    print('   ✅ Última declaração obtida');
    print('   📄 Número: ${ultima.data?.dados?['numero_declaracao'] ?? 'N/A'}');
  } else {
    print('   ❌ Erro: ${ultima.error?.message}');
  }
}

/// Exemplos do DCTFWeb
Future<void> exemploDCTFWeb(IntegraContadorExtendedService service) async {
  final cnpj = '12345678000195';
  final periodo = '012024';

  print('1. Consultando declaração completa DCTFWeb...');
  final completa = await service.consultarDeclaracaoCompletaDCTF(documento: cnpj, periodoApuracao: periodo);

  if (completa.isSuccess) {
    print('   ✅ Declaração completa obtida');
  } else {
    print('   ❌ Erro: ${completa.error?.message}');
  }

  print('2. Gerando guia de declaração DCTFWeb...');
  final guia = await service.gerarGuiaDeclaracaoDCTF(documento: cnpj, periodoApuracao: periodo, parametrosAdicionais: {'tipo_declaracao': 'normal', 'situacao_especial': false});

  if (guia.isSuccess) {
    print('   ✅ Guia gerada com sucesso');
  } else {
    print('   ❌ Erro: ${guia.error?.message}');
  }
}

/// Exemplos de outros sistemas
Future<void> exemploOutrosSistemas(IntegraContadorExtendedService service) async {
  final cnpj = '12345678000195';

  print('1. Consultando situação fiscal (SITFIS)...');
  final sitfis = await service.consultarSituacaoFiscalSITFIS(documento: cnpj, anoBase: '2024');

  if (sitfis.isSuccess) {
    print('   ✅ Situação: ${sitfis.data?.dados?['situacao'] ?? 'N/A'}');
  } else {
    print('   ❌ Erro: ${sitfis.error?.message}');
  }

  print('2. Consultando débitos...');
  final debitos = await service.consultarDebitos(documento: cnpj, situacao: 'pendente');

  if (debitos.isSuccess) {
    print('   ✅ Débitos consultados');
    final qtdDebitos = debitos.data?.dados?.length ?? 0;
    print('   📊 Quantidade de débitos: $qtdDebitos');
  } else {
    print('   ❌ Erro: ${debitos.error?.message}');
  }

  print('3. Consultando parcelamentos...');
  final parcelamentos = await service.consultarParcelamentos(documento: cnpj, situacao: 'ativo');

  if (parcelamentos.isSuccess) {
    print('   ✅ Parcelamentos consultados');
  } else {
    print('   ❌ Erro: ${parcelamentos.error?.message}');
  }

  print('4. Consultando mensagens do caixa postal...');
  final mensagens = await service.consultarMensagensContribuinte(documento: cnpj, dataInicio: DateTime(2024, 1, 1), dataFim: DateTime(2024, 12, 31));

  if (mensagens.isSuccess) {
    print('   ✅ Mensagens consultadas');
    final qtdMensagens = mensagens.data?.dados?.length ?? 0;
    print('   📬 Quantidade de mensagens: $qtdMensagens');
  } else {
    print('   ❌ Erro: ${mensagens.error?.message}');
  }

  print('5. Consolidando e gerando DARF...');
  final darf = await service.consolidarGerarDARFPDF(documento: cnpj, dadosCalculo: {'codigo_receita': '0220', 'periodo_apuracao': '012024', 'valor_principal': '1500.00', 'multa': '75.00', 'juros': '25.50'});

  if (darf.isSuccess) {
    print('   ✅ DARF gerado com sucesso');
  } else {
    print('   ❌ Erro: ${darf.error?.message}');
  }

  print('6. Obtendo procuração...');
  final procuracao = await service.obterProcuracao(documento: cnpj, tipoProcuracao: 'eletronica');

  if (procuracao.isSuccess) {
    print('   ✅ Procuração obtida');
  } else {
    print('   ❌ Erro: ${procuracao.error?.message}');
  }
}

/// Exemplos de métodos de conveniência
Future<void> exemploMetodosConveniencia(IntegraContadorExtendedService service) async {
  final cnpj = '12345678000195';
  final cpf = '12345678901';

  print('1. Consultando informações completas (múltiplas consultas em paralelo)...');
  final informacoes = await service.consultarInformacoesCompletas(documento: cnpj, anoBase: '2024');

  print('   📊 Resultados obtidos:');
  informacoes.forEach((tipo, result) {
    if (result.isSuccess) {
      print('   ✅ $tipo: Sucesso');
    } else {
      print('   ❌ $tipo: ${result.error?.message}');
    }
  });

  print('\n2. Gerando todos os tipos de DAS para CNPJ...');
  final todosDASCNPJ = await service.gerarTodosDAS(documento: cnpj, periodoApuracao: '012024');

  print('   📄 DAS gerados para CNPJ:');
  todosDASCNPJ.forEach((tipo, result) {
    if (result.isSuccess) {
      print('   ✅ $tipo: Gerado com sucesso');
    } else {
      print('   ❌ $tipo: ${result.error?.message}');
    }
  });

  print('\n3. Gerando todos os tipos de DAS para CPF (MEI)...');
  final todosDASCPF = await service.gerarTodosDAS(documento: cpf, periodoApuracao: '012024');

  print('   📄 DAS gerados para CPF:');
  todosDASCPF.forEach((tipo, result) {
    if (result.isSuccess) {
      print('   ✅ $tipo: Gerado com sucesso');
    } else {
      print('   ❌ $tipo: ${result.error?.message}');
    }
  });

  print('\n4. Consultando todas as declarações...');
  final declaracoes = await service.consultarTodasDeclaracoes(documento: cnpj, anoCalendario: '2024');

  print('   📋 Declarações consultadas:');
  declaracoes.forEach((tipo, result) {
    if (result.isSuccess) {
      final qtd = result.data?.dados?.length ?? 0;
      print('   ✅ $tipo: $qtd declarações encontradas');
    } else {
      print('   ❌ $tipo: ${result.error?.message}');
    }
  });
}

/// Exemplo de uso com tratamento de erros avançado
Future<void> exemploTratamentoErros() async {
  final service = IntegraContadorBuilder().withJwtToken('token_invalido').build();

  print('\n🛡️ === EXEMPLO DE TRATAMENTO DE ERROS ===');

  final result = await service.consultarSituacaoFiscalSITFIS(documento: 'documento_invalido', anoBase: '2024');

  if (result.isFailure) {
    final error = result.error!;

    print('❌ Erro detectado:');
    print('   Tipo: ${error.runtimeType}');
    print('   Mensagem: ${error.message}');

    // Tratamento específico por tipo de erro
    if (error is ValidationException) {
      print('   🔍 Erro de validação detectado');
      error.fieldErrors?.forEach((field, errors) {
        print('   📝 $field: ${errors.join(', ')}');
      });
    } else if (error is AuthenticationException) {
      print('   🔐 Erro de autenticação - token inválido ou expirado');
    } else if (error is NetworkException) {
      print('   🌐 Erro de rede - verificar conectividade');
    } else if (error is RateLimitException) {
      print('   ⏱️ Limite de requisições atingido');
      print('   ⏳ Tentar novamente em: ${error.retryAfter} segundos');
    }

    // Extrair informações adicionais usando helper
    final infoErro = IntegraContadorHelper.extrairInformacoesErro(error);
    print('   💡 Sugestão: ${infoErro['sugestao']}');
    print('   🔄 Pode tentar novamente: ${infoErro['pode_tentar_novamente']}');
  }

  service.dispose();
}

/// Exemplo de uso com cache
Future<void> exemploComCache() async {
  print('\n💾 === EXEMPLO COM CACHE ===');

  // Criar serviço base
  final baseService = IntegraContadorBuilder().withJwtToken('SEU_TOKEN_JWT_AQUI').buildBaseService();

  // Envolver com cache
  final cachedService = CachedIntegraContadorService(baseService, cacheDuration: Duration(minutes: 5));

  final documento = '12345678000195';

  print('1. Primeira consulta (cache miss)...');
  final inicio1 = DateTime.now();
  final result1 = await cachedService.consultarSituacaoFiscalSITFIS(documento: documento, anoBase: '2024');
  final duracao1 = DateTime.now().difference(inicio1);
  print('   ⏱️ Duração: ${duracao1.inMilliseconds}ms');
  print('   ✅ Resultado: ${result1.isSuccess ? 'Sucesso' : 'Erro'}');

  print('2. Segunda consulta (cache hit)...');
  final inicio2 = DateTime.now();
  final result2 = await cachedService.consultarSituacaoFiscalSITFIS(documento: documento, anoBase: '2024');
  final duracao2 = DateTime.now().difference(inicio2);
  print('   ⏱️ Duração: ${duracao2.inMilliseconds}ms');
  print('   ✅ Resultado: ${result2.isSuccess ? 'Sucesso' : 'Erro'}');
  print('   🚀 Speedup: ${(duracao1.inMilliseconds / duracao2.inMilliseconds).toStringAsFixed(2)}x');

  // Limpar cache
  cachedService.clearCache();
  print('3. Cache limpo');

  cachedService.dispose();
}

/// Exemplo de validação usando helpers
void exemploValidacoes() {
  print('\n✅ === EXEMPLO DE VALIDAÇÕES ===');

  // Validação de documentos
  final documentos = ['12345678901', '12345678000195', 'documento_invalido'];

  for (final doc in documentos) {
    final isValid = IntegraContadorHelper.isDocumentoValido(doc);
    final tipo = IntegraContadorHelper.detectarTipoDocumento(doc);
    final formatado = IntegraContadorHelper.formatarDocumento(doc);

    print('📄 Documento: $doc');
    print('   ✅ Válido: $isValid');
    print('   🏷️ Tipo: $tipo');
    print('   📝 Formatado: $formatado');
    print('');
  }

  // Validação de períodos
  final periodos = ['012024', '132024', 'periodo_invalido'];

  for (final periodo in periodos) {
    final isValid = IntegraContadorHelper.isValidPeriodoApuracao(periodo);
    print('📅 Período: $periodo - Válido: $isValid');
  }

  // Validação de códigos de receita
  final codigos = ['0220', '1234', 'codigo_invalido'];

  for (final codigo in codigos) {
    final isValid = IntegraContadorHelper.isValidCodigoReceita(codigo);
    print('💰 Código: $codigo - Válido: $isValid');
  }

  // Normalização de valores
  final valores = ['1.500,00', '1500.00', '1,500.00', 'valor_invalido'];

  for (final valor in valores) {
    try {
      final normalizado = IntegraContadorHelper.normalizarValorMonetario(valor);
      print('💵 Valor: $valor → $normalizado');
    } catch (e) {
      print('💵 Valor: $valor → Erro: $e');
    }
  }
}

/// Classe de exemplo para cache
class CachedIntegraContadorService extends IntegraContadorExtendedService {
  final Map<String, ApiResult<DadosSaida>> _cache = {};
  final Duration _cacheDuration;
  final Map<String, DateTime> _cacheTimestamps = {};

  CachedIntegraContadorService(super.baseService, {Duration? cacheDuration}) : _cacheDuration = cacheDuration ?? const Duration(minutes: 5);

  @override
  Future<ApiResult<DadosSaida>> consultarSituacaoFiscalSITFIS({required String documento, String? anoBase}) async {
    final key = 'situacao_fiscal_${documento}_${anoBase ?? ''}';

    // Verificar cache
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key]!;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        print('📋 Cache hit para $key');
        return _cache[key]!;
      } else {
        // Cache expirado
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }

    // Buscar dados
    print('🌐 Cache miss para $key - buscando dados');
    final result = await super.consultarSituacaoFiscalSITFIS(documento: documento, anoBase: anoBase);

    // Armazenar no cache apenas se sucesso
    if (result.isSuccess) {
      _cache[key] = result;
      _cacheTimestamps[key] = DateTime.now();
    }

    return result;
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('🗑️ Cache limpo');
  }
}
