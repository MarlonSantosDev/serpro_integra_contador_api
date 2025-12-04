import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'import.dart';

/// Exemplo Simplificado - SERPRO Integra Contador API
///
/// Este arquivo demonstra o uso mais simples possível da API.
void main() async {
  print('=== Exemplo Simples - SERPRO Integra Contador API ===\n');

  // ========================================
  // EXEMPLO 1: Modo Trial (Desenvolvimento)
  // ========================================
  print('📋 EXEMPLO 1: Trial (sem certificado)\n');

  try {
    final apiClient = ApiClient();

    await apiClient.authenticate(
      consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      contratanteNumero: '00000000000191',
      autorPedidoDadosNumero: '00000000191',
      ambiente: 'trial',
    );

    print('✅ Autenticado com sucesso!\n');

    // Usar o serviço
    //await CaixaPostal(apiClient);

    print('\n✅ Exemplo 1 concluído!\n');
  } catch (e) {
    print('❌ Erro: ${e}\n');
  }
  // ========================================
  // EXEMPLO 2: Modo Produção (com certificado Base64)
  // ========================================
  print('\n📋 EXEMPLO 2: Produção (com certificado Base64)\n');

  try {
    final apiClient = ApiClient();

    // Certificado em Base64 (exemplo)
    const certificadoBase64 = 'MIIJqQIBAzCCCW8GCSqGSIb3...'; // Seu certificado aqui

    await apiClient.authenticate(
      consumerKey: 'sua_consumer_key',
      consumerSecret: 'sua_consumer_secret',
      contratanteNumero: '12345678000100',
      autorPedidoDadosNumero: '11122233344',
      certificadoDigitalBase64: certificadoBase64,
      senhaCertificado: 'senha123',
      ambiente: 'producao',
    );

    print('✅ Autenticado com sucesso!\n');

    // Usar o serviço
    // await CaixaPostal(apiClient);

    print('\n✅ Exemplo 2 concluído!\n');
  } catch (e) {
    print('❌ Erro: ${e}\n');
  }

  // ========================================
  // EXEMPLO 3: Modo Produção (com certificado arquivo)
  // ========================================
  print('\n📋 EXEMPLO 3: Produção (com certificado arquivo)\n');

  try {
    final apiClient = ApiClient();

    await apiClient.authenticate(
      consumerKey: 'sua_consumer_key',
      consumerSecret: 'sua_consumer_secret',
      contratanteNumero: '12345678000100',
      autorPedidoDadosNumero: '11122233344',
      certificadoDigitalPath: '/caminho/certificado.pfx',
      senhaCertificado: 'senha123',
      ambiente: 'producao',
    );

    print('✅ Autenticado com sucesso!\n');
  } catch (e) {
    print('❌ Erro: ${e}\n');
  }

  // ========================================
  // EXEMPLO 4: Erro - Sem Autenticação
  // ========================================
  print('\n📋 EXEMPLO 5: Tentando usar sem autenticar\n');

  try {
    final apiClient = ApiClient();

    // Tentar usar sem autenticar
    await CaixaPostal(apiClient);
  } catch (e) {
    print('❌ Erro esperado: ${e}\n');
  }

  // ========================================
  // EXEMPLO 5: Erro - Consumer Secret Vazio
  // ========================================
  print('\n📋 EXEMPLO 5: Tentando autenticar com credenciais vazias\n');

  try {
    final apiClient = ApiClient();

    await apiClient.authenticate(
      consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      consumerSecret: '', // Vazio!
      contratanteNumero: '00000000000191',
      autorPedidoDadosNumero: '00000000191',
      ambiente: 'trial',
    );
  } catch (e) {
    print('❌ Erro esperado: ${e}\n');
  }

  // ========================================
  // EXEMPLO 6: Erro - Produção sem Certificado
  // ========================================
  print('\n📋 EXEMPLO 6: Tentando produção sem certificado\n');

  try {
    final apiClient = ApiClient();

    await apiClient.authenticate(
      consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
      contratanteNumero: '00000000000191',
      autorPedidoDadosNumero: '00000000191',
      ambiente: 'producao', // Produção requer certificado!
    );
  } catch (e) {
    print('❌ Erro esperado: ${e}\n');
  }
  print('\n=== Exemplos Concluídos ===');
}
