import 'package:integra_contador_api/integra_contador_api.dart';

/// Exemplo completo de uso da API Integra Contador
void main() async {
  // 1. Configuração do serviço
  final service = IntegraContadorServiceBuilder()
      .withJwtToken('SEU_TOKEN_JWT_AQUI')
      .withProcuradorToken('TOKEN_PROCURADOR_OPCIONAL') // Opcional
      .withTimeout(Duration(seconds: 30))
      .withMaxRetries(3)
      .build();

  print('🚀 Iniciando exemplos da API Integra Contador\n');

  // 2. Teste de conectividade
  await _testarConectividade(service);

  // 3. Consulta de situação fiscal
  await _exemploConsultaSituacaoFiscal(service);

  // 4. Consulta de dados de empresa
  await _exemploConsultaDadosEmpresa(service);

  // 5. Envio de declaração IRPF
  await _exemploDeclaracaoIRPF(service);

  // 6. Emissão de DARF
  await _exemploEmissaoDARF(service);

  // 7. Monitoramento de processamento
  await _exemploMonitoramento(service);

  // 8. Validação de certificado
  await _exemploValidacaoCertificado(service);

  // 9. Tratamento de erros
  await _exemploTratamentoErros(service);

  // 10. Limpeza de recursos
  service.dispose();
  
  print('\n✨ Todos os exemplos foram executados!');
}

/// Testa a conectividade com a API
Future<void> _testarConectividade(IntegraContadorService service) async {
  print('=== Teste de Conectividade ===');
  
  final result = await service.testarConectividade();
  
  if (result.isSuccess) {
    print('✅ Conectividade OK');
  } else {
    print('❌ Falha na conectividade: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de situação fiscal
Future<void> _exemploConsultaSituacaoFiscal(IntegraContadorService service) async {
  print('=== Consulta de Situação Fiscal ===');
  
  // Consulta para pessoa física
  final resultPF = await service.consultarSituacaoFiscal(
    documento: '11144477735', // CPF válido para teste
    anoBase: '2024',
    incluirDebitos: true,
    incluirCertidoes: true,
  );
  
  if (resultPF.isSuccess) {
    print('✅ Consulta PF realizada com sucesso!');
    print('Situação Fiscal: ${resultPF.data?.situacaoFiscal}');
    print('Débitos Pendentes: ${resultPF.data?.debitosPendentes}');
  } else {
    print('❌ Erro na consulta PF: ${resultPF.error?.message}');
  }
  
  // Consulta para pessoa jurídica
  final resultPJ = await service.consultarSituacaoFiscal(
    documento: '11222333000181', // CNPJ válido para teste
    anoBase: '2024',
    incluirDebitos: false,
  );
  
  if (resultPJ.isSuccess) {
    print('✅ Consulta PJ realizada com sucesso!');
    print('Situação Fiscal: ${resultPJ.data?.situacaoFiscal}');
  } else {
    print('❌ Erro na consulta PJ: ${resultPJ.error?.message}');
  }
  print('');
}

/// Exemplo de consulta de dados de empresa
Future<void> _exemploConsultaDadosEmpresa(IntegraContadorService service) async {
  print('=== Consulta de Dados de Empresa ===');
  
  final result = await service.consultarDadosEmpresa(
    cnpj: '11222333000181',
    incluirSocios: true,
    incluirAtividades: true,
    incluirEndereco: true,
  );
  
  if (result.isSuccess) {
    print('✅ Consulta de empresa realizada com sucesso!');
    print('Razão Social: ${result.data?.razaoSocial}');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Situação: ${dados['situacao']}');
      print('Data Abertura: ${dados['data_abertura']}');
      print('Atividade Principal: ${dados['atividade_principal']}');
    }
  } else {
    print('❌ Erro na consulta de empresa: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de envio de declaração IRPF
Future<void> _exemploDeclaracaoIRPF(IntegraContadorService service) async {
  print('=== Envio de Declaração IRPF ===');
  
  // Simulando arquivo de declaração em base64
  final arquivoDeclaracao = 'base64_encoded_file_content_here';
  
  final result = await service.enviarDeclaracaoIRPF(
    cpf: '11144477735',
    anoCalendario: '2024',
    tipoDeclaracao: 'completa',
    arquivoDeclaracao: arquivoDeclaracao,
    hashArquivo: 'sha256_hash_do_arquivo',
  );
  
  if (result.isSuccess) {
    print('✅ Declaração IRPF enviada com sucesso!');
    print('Número do Recibo: ${result.data?.numeroRecibo}');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Data/Hora Envio: ${dados['data_hora_envio']}');
      print('Situação: ${dados['situacao']}');
    }
  } else {
    print('❌ Erro no envio da declaração: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de emissão de DARF
Future<void> _exemploEmissaoDARF(IntegraContadorService service) async {
  print('=== Emissão de DARF ===');
  
  final result = await service.emitirDARF(
    documento: '11222333000181',
    codigoReceita: '0220',
    periodoApuracao: '012024',
    valorPrincipal: '1500.00',
    valorMulta: '75.00',
    valorJuros: '25.50',
    dataVencimento: DateTime(2024, 2, 20),
  );
  
  if (result.isSuccess) {
    print('✅ DARF emitido com sucesso!');
    print('Código de Barras: ${result.data?.codigoBarras}');
    print('Linha Digitável: ${result.data?.linhaDigitavel}');
    print('Valor Total: R\$ ${result.data?.valorTotal}');
  } else {
    print('❌ Erro na emissão do DARF: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de monitoramento de processamento
Future<void> _exemploMonitoramento(IntegraContadorService service) async {
  print('=== Monitoramento de Processamento ===');
  
  final result = await service.monitorarProcessamento(
    documento: '11144477735',
    numeroProtocolo: '2024123456789',
    tipoOperacao: 'declaracao_irpf',
  );
  
  if (result.isSuccess) {
    print('✅ Status de processamento obtido com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Status: ${dados['status']}');
      print('Percentual Concluído: ${result.data?.percentualConcluido}%');
      print('Última Atualização: ${dados['ultima_atualizacao']}');
      
      if (dados['status'] == 'concluido') {
        print('Resultado Final: ${result.data?.resultadoFinal}');
      } else if (dados['status'] == 'erro') {
        print('Erro: ${result.data?.mensagemErro}');
      }
    }
  } else {
    print('❌ Erro no monitoramento: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de validação de certificado
Future<void> _exemploValidacaoCertificado(IntegraContadorService service) async {
  print('=== Validação de Certificado Digital ===');
  
  // Simulando certificado em base64
  final certificadoBase64 = 'base64_encoded_certificate_here';
  
  final result = await service.validarCertificado(
    certificadoBase64: certificadoBase64,
    senha: 'senha_do_certificado',
    validarCadeia: true,
  );
  
  if (result.isSuccess) {
    print('✅ Certificado validado com sucesso!');
    
    final dados = result.data?.dados;
    if (dados != null) {
      print('Certificado Válido: ${dados['certificado_valido']}');
      print('Data Expiração: ${dados['data_expiracao']}');
      print('Titular: ${dados['titular']}');
    }
  } else {
    print('❌ Erro na validação do certificado: ${result.error?.message}');
  }
  print('');
}

/// Exemplo de tratamento de diferentes tipos de erro
Future<void> _exemploTratamentoErros(IntegraContadorService service) async {
  print('=== Tratamento de Erros ===');
  
  // Simulando uma consulta com CPF inválido para gerar erro
  final result = await service.consultarSituacaoFiscal(
    documento: '12345678901', // CPF inválido
    anoBase: '2024',
  );
  
  if (result.isFailure) {
    final error = result.error!;
    
    print('❌ Erro capturado:');
    print('Tipo: ${error.runtimeType}');
    print('Mensagem: ${error.message}');
    print('Código: ${error.code}');
    
    // Tratamento específico por tipo de erro
    if (error is ValidationException) {
      print('💡 Dica: Verifique os dados enviados na requisição');
      
      if (error.fieldErrors != null) {
        print('Campos com erro:');
        error.fieldErrors!.forEach((field, errors) {
          print('  $field: ${errors.join(', ')}');
        });
      }
    } else if (error is AuthenticationException) {
      print('💡 Dica: Verifique se o token JWT está válido e não expirou');
    } else if (error is AuthorizationException) {
      print('💡 Dica: Verifique se você tem permissão para esta operação');
    } else if (error is NetworkException) {
      print('💡 Dica: Verifique sua conexão com a internet');
    } else if (error is ServerException) {
      print('💡 Dica: Erro interno do servidor, tente novamente mais tarde');
    } else if (error is TimeoutException) {
      print('💡 Dica: A requisição demorou muito, tente novamente');
    } else if (error is RateLimitException) {
      final rateLimitError = error as RateLimitException;
      print('💡 Dica: Muitas requisições, aguarde ${rateLimitError.retryAfter ?? 60} segundos');
    }
  }
  print('');
}

/// Exemplo de uso com transformação de dados
Future<void> _exemploTransformacaoDados(IntegraContadorService service) async {
  print('=== Transformação de Dados ===');
  
  final result = await service.consultarSituacaoFiscal(
    documento: '11144477735',
    anoBase: '2024',
  );
  
  // Transformando o resultado usando map
  final situacaoResult = result.map((dados) {
    return {
      'documento': '11144477735',
      'situacao': dados.situacaoFiscal ?? 'Desconhecida',
      'regular': dados.situacaoFiscal == 'regular',
      'consultadoEm': DateTime.now().toIso8601String(),
    };
  });
  
  if (situacaoResult.isSuccess) {
    print('✅ Dados transformados:');
    print('Documento: ${situacaoResult.data!['documento']}');
    print('Situação: ${situacaoResult.data!['situacao']}');
    print('Regular: ${situacaoResult.data!['regular']}');
    print('Consultado em: ${situacaoResult.data!['consultadoEm']}');
  }
  print('');
}

/// Exemplo de uso com processamento assíncrono
Future<void> _exemploProcessamentoAssincrono(IntegraContadorService service) async {
  print('=== Processamento Assíncrono ===');
  
  final documentos = ['11144477735', '11222333000181'];
  
  // Processamento paralelo
  final futures = documentos.map((doc) => 
    service.consultarSituacaoFiscal(documento: doc, anoBase: '2024')
  );
  
  final results = await Future.wait(futures);
  
  for (int i = 0; i < documentos.length; i++) {
    final doc = documentos[i];
    final result = results[i];
    
    if (result.isSuccess) {
      print('✅ $doc: ${result.data?.situacaoFiscal}');
    } else {
      print('❌ $doc: ${result.error?.message}');
    }
  }
  print('');
}

