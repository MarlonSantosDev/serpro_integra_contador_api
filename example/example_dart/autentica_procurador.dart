import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║   SERPRO Integra Contador API - AutenticaProcurador           ║');
  print('╚═══════════════════════════════════════════════════════════════╝\n');

  await testeTrialSemCertificado();
  //await testeProducaoComCertificado();

  print('\n═══════════════════════════════════════════════════════════════');
  print('  ✅ TESTE CONCLUÍDO!');
  print('═══════════════════════════════════════════════════════════════\n');
}

Future<void> testeTrialSemCertificado() async {
  print('┌─────────────────────────────────────────────────────────────┐');
  print('│ MODO TRIAL - Ambiente de Demonstração                       │');
  print('│ (Sem certificado digital real)                              │');
  print('└─────────────────────────────────────────────────────────────┘\n');

  print('⚠️  ATENÇÃO: O ambiente trial do SERPRO requer assinatura');
  print('   digital real para o serviço AutenticaProcurador.');
  print('   Este teste demonstra a estrutura do código apenas.\n');

  try {
    final apiClient = ApiClient();

    // Credenciais de Trial do SERPRO
    const consumerKey = '06aef429-a981-3ec5-a1f8-71d38d86481e';
    const consumerSecret = '06aef429-a981-3ec5-a1f8-71d38d86481e';

    // Dados fictícios para trial
    const contratanteCNPJ = '00000000000191';
    const contratanteNome = 'EMPRESA TRIAL LTDA';
    const procuradorCPF = '00000000191';
    const procuradorNome = 'PROCURADOR TRIAL';

    print('┌─────────────────────────────────────────────────────────────┐');
    print('│ CONFIGURAÇÃO TRIAL                                          │');
    print('├─────────────────────────────────────────────────────────────┤');
    print('│ Ambiente: trial                                             │');
    print('│ Contratante: $contratanteCNPJ                         │');
    print('│ Procurador: $procuradorCPF                              │');
    print('└─────────────────────────────────────────────────────────────┘\n');

    // 1. Autenticar com a API (OAuth2)
    print('1️⃣  Autenticando com API SERPRO (OAuth2)...');
    await apiClient.authenticate(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      contratanteNumero: contratanteCNPJ,
      autorPedidoDadosNumero: procuradorCPF,
      ambiente: 'trial',
    );
    print('✅ Autenticação OAuth2 concluída!\n');

    // 2. Informar sobre necessidade de certificado
    print('2️⃣  Para autenticar procurador em TRIAL:');
    print('   O serviço AutenticaProcurador requer certificado digital');
    print('   mesmo em ambiente trial. Use testeProducaoComCertificado()');
    print('   com um certificado .pfx válido.\n');

    print('📋 Exemplo de chamada com certificado Base64 (Web):');
    print('''
    final autenticaService = AutenticaProcuradorService(apiClient);
    final response = await autenticaService.autenticarProcurador(
      contratanteNome: '$contratanteNome',
      autorNome: '$procuradorNome',
      certificadoBase64: '<BASE64_DO_PFX>',  // Conteúdo do .pfx em Base64
      certificadoPassword: '<SENHA>',
    );
    ''');

    print('📋 Exemplo de chamada com arquivo (Desktop/Mobile):');
    print('''
    final autenticaService = AutenticaProcuradorService(apiClient);
    final response = await autenticaService.autenticarProcurador(
      contratanteNome: '$contratanteNome',
      autorNome: '$procuradorNome',
      certificadoPath: 'certificado.pfx',
      certificadoPassword: '<SENHA>',
    );
    ''');

    print('✅ TESTE TRIAL: Estrutura demonstrada com sucesso\n');
  } catch (e) {
    print('❌ ERRO: $e\n');
  }
}

/// Teste em ambiente de PRODUÇÃO com certificado digital real
///
/// Este teste demonstra o fluxo completo de autenticação de procurador
/// usando certificado digital ICP-Brasil.
///
/// **Requisitos:**
/// - Certificado digital .pfx válido (ICP-Brasil)
/// - Credenciais de produção (Consumer Key/Secret)
/// - CNPJ/CPF reais e válidos
Future<void> testeProducaoComCertificado() async {
  print('┌─────────────────────────────────────────────────────────────┐');
  print('│ MODO PRODUÇÃO - Com Certificado Digital                     │');
  print('└─────────────────────────────────────────────────────────────┘\n');

  try {
    final apiClient = ApiClient();

    // ═══════════════════════════════════════════════════════════════
    // CONFIGURAÇÕES - ALTERE PARA SEUS DADOS REAIS
    // ═══════════════════════════════════════════════════════════════
    const consumerKey = '';
    const consumerSecret = '';

    // ═══════════════════════════════════════════════════════════════
    // CONTRATANTE - Quem contratou a API SERPRO (faz autenticação OAuth2)
    // ═══════════════════════════════════════════════════════════════
    const contratanteCNPJ = '';
    const contratanteNome = '';

    // Certificado do CONTRATANTE (para mTLS OAuth2)
    final certContratantePath = 'certificado.pfx';
    const certContratanteSenha = '';

    // ═══════════════════════════════════════════════════════════════
    // PROCURADOR - Quem assina o termo de autorização (pode ser diferente!)
    // ═══════════════════════════════════════════════════════════════
    const procuradorCNPJ = '';
    const procuradorNome = ' ';

    // Certificado do PROCURADOR (para assinar o termo)
    final certProcuradorPath = '.pfx';
    const certProcuradorSenha = '';

    // ═══════════════════════════════════════════════════════════════
    // CONTRIBUINTE - Em nome de quem serão feitas as requisições
    // ═══════════════════════════════════════════════════════════════
    const contribuinteCNPJ = ''; // Mesmo CNPJ do procurador neste caso

    // ═══════════════════════════════════════════════════════════════
    // ETAPA 1: AUTENTICAÇÃO OAUTH2 (com certificado do CONTRATANTE)
    // ═══════════════════════════════════════════════════════════════

    await apiClient.authenticate(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      contratanteNumero: contratanteCNPJ,
      autorPedidoDadosNumero: procuradorCNPJ,
      certificadoDigitalPath: certContratantePath,
      senhaCertificado: certContratanteSenha,
      ambiente: 'producao',
    );
    print('✅ Autenticação OAuth2 do CONTRATANTE concluída!\n');

    // ═══════════════════════════════════════════════════════════════
    // ETAPA 2: PROCURADOR ASSINA O TERMO (com certificado do PROCURADOR)
    // ═══════════════════════════════════════════════════════════════
    print('2️⃣  PROCURADOR assinando termo de autorização...');
    print('   ✍️  Assinante: $procuradorNome ($procuradorCNPJ)');
    print('   📜 Certificado: $certProcuradorPath');
    print('   🎯 Autoriza requisições em nome de: $contribuinteCNPJ\n');

    final autenticaService = AutenticaProcuradorService(apiClient);

    final response = await autenticaService.autenticarProcurador(
      // Dados do CONTRATANTE
      contratanteNome: contratanteNome,
      contratanteNumero: contratanteCNPJ,

      // Dados do PROCURADOR
      autorNome: procuradorNome,
      autorNumero: procuradorCNPJ,

      // Dados do CONTRIBUINTE
      contribuinteNumero: contribuinteCNPJ,

      // Certificado do PROCURADOR (para assinar o termo)
      certificadoPath: certProcuradorPath,
      certificadoPassword: certProcuradorSenha,
    );

    // ═══════════════════════════════════════════════════════════════
    // RESULTADO
    // ═══════════════════════════════════════════════════════════════
    if (response.sucesso) {
      print('┌─────────────────────────────────────────────────────────────┐');
      print('│ ✅ AUTENTICAÇÃO REALIZADA COM SUCESSO                        │');
      print('├─────────────────────────────────────────────────────────────┤');

      if (response.isCacheValido) {
        print('│ 📦 Status: Token já existe no servidor (Cache - HTTP 304)   │');
        if (response.autenticarProcuradorToken != null) {
          print('│ Token: ${_truncate(response.autenticarProcuradorToken!, 45)}');
        } else {
          print('│ Token: (mantido no servidor - não retornado)               │');
        }
      } else {
        print('│ 🆕 Status: Novo token gerado                                │');
        print('│ Token: ${_truncate(response.autenticarProcuradorToken ?? 'N/A', 45)}');
      }

      if (response.dataExpiracao != null) {
        print('│ Expira: ${response.dataExpiracao}');
      }
      print('│ Em Cache: ${response.isCacheValido}');
      print('└─────────────────────────────────────────────────────────────┘\n');

      print('✅ TESTE PRODUÇÃO: PASSOU\n');
    } else {
      print('┌─────────────────────────────────────────────────────────────┐');
      print('│ ❌ ERRO NA AUTENTICAÇÃO                                      │');
      print('├─────────────────────────────────────────────────────────────┤');
      print('│ Código: ${response.codigoMensagem}');
      print('│ Mensagem: ${response.mensagemPrincipal}');
      print('└─────────────────────────────────────────────────────────────┘\n');
      print('❌ TESTE PRODUÇÃO: FALHOU\n');
    }
  } on ExcecaoAssinaturaCertificado catch (e) {
    print('❌ ERRO DE CERTIFICADO:');
    print('   $e\n');
    print('❌ TESTE PRODUÇÃO: FALHOU\n');
  } on ExcecaoAssinaturaXml catch (e) {
    print('❌ ERRO DE ASSINATURA XML:');
    print('   $e\n');
    print('❌ TESTE PRODUÇÃO: FALHOU\n');
  } on ExcecaoErroSerpro catch (e) {
    print('❌ ERRO DA API SERPRO:');
    print('   Código: ${e.codigo}');
    print('   Mensagem: ${e.mensagem}\n');
    print('❌ TESTE PRODUÇÃO: FALHOU\n');
  } on ExcecaoAutenticaProcurador catch (e) {
    print('❌ ERRO DE AUTENTICAÇÃO:');
    print('   $e\n');
    print('❌ TESTE PRODUÇÃO: FALHOU\n');
  } catch (e, stackTrace) {
    print('❌ ERRO INESPERADO:');
    print('   Tipo: ${e.runtimeType}');
    print('   Mensagem: $e');
    print('   Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}\n');
    print('❌ TESTE PRODUÇÃO: FALHOU\n');
  }
}

/// Trunca uma string para o tamanho máximo especificado
String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

/// Exemplo de uso com certificado em Base64 (para Web)
///
/// Este exemplo mostra como usar o serviço quando o certificado
/// é fornecido como string Base64 (comum em aplicações Web).
Future<void> exemploWebComBase64(ApiClient apiClient) async {
  print('📱 Exemplo para Web (certificado Base64):\n');

  // Em Web, o certificado deve ser carregado como Base64
  // Isso pode ser feito via file picker ou input
  const certificadoBase64 = '''
    MIIJqQIBAzCCCW8GCSqGSIb3DQEHAaCCCWAEgglcMIIJWDCCA88GCSqGSIb3...
    (conteúdo do .pfx em Base64)
  ''';
  const certificadoSenha = 'minhasenha';

  final autenticaService = AutenticaProcuradorService(apiClient);

  try {
    final response = await autenticaService.autenticarProcurador(
      contratanteNome: 'EMPRESA EXEMPLO LTDA',
      autorNome: 'PROCURADOR EXEMPLO',
      certificadoBase64: certificadoBase64,
      certificadoPassword: certificadoSenha,
    );

    if (response.sucesso) {
      print('✅ Token obtido: ${response.autenticarProcuradorToken}');
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}
