import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Exemplos de uso do Serviço AUTENTICA PROCURADOR
///
/// ## Fluxo de Autenticação:
/// ```
/// ┌──────────────────────┐     assina     ┌──────────────────────┐
/// │     PROCURADOR       │ ─────────────► │     CONTRATANTE      │
/// │  (certificado dele)  │    o termo     │  (certificado mTLS)  │
/// └──────────────────────┘                └──────────────────────┘
///           │                                       │
///           │ autoriza em nome de                   │ faz requisições
///           ▼                                       ▼
/// ┌──────────────────────┐                ┌──────────────────────┐
/// │    CONTRIBUINTE      │ ◄───────────── │     API SERPRO       │
/// │  (CNPJ do cliente)   │   dados        │                      │
/// └──────────────────────┘                └──────────────────────┘
/// ```
Future<void> AutenticaProcurador(
  ApiClient apiClient, {
  // Dados do CONTRATANTE (quem contratou a API)
  required String contratanteNome,
  String? contratanteNumero,

  // Dados do PROCURADOR (quem assina o termo)
  required String procuradorNome,
  String? procuradorNumero,
  required String certProcuradorPath,
  required String certProcuradorSenha,

  // Dados do CONTRIBUINTE (em nome de quem)
  required String contribuinteNumero,
}) async {
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║       SERVIÇO AUTENTICA PROCURADOR - API SERPRO               ║');
  print('╚═══════════════════════════════════════════════════════════════╝\n');

  final autenticaProcuradorService = AutenticaProcuradorService(apiClient);

  // Usar dados do ApiClient se não fornecidos
  final finalContratanteNumero =
      contratanteNumero ?? apiClient.contratanteNumero!;
  final finalProcuradorNumero =
      procuradorNumero ?? apiClient.autorPedidoDadosNumero!;

  print('┌─────────────────────────────────────────────────────────────┐');
  print('│ CONFIGURAÇÃO                                                │');
  print('╠═════════════════════════════════════════════════════════════╣');
  print('│ 🏢 CONTRATANTE: $finalContratanteNumero');
  print('│    Nome: $contratanteNome');
  print('╠═════════════════════════════════════════════════════════════╣');
  print('│ ✍️  PROCURADOR: $finalProcuradorNumero');
  print('│    Nome: $procuradorNome');
  print('│    Cert: $certProcuradorPath');
  print('╠═════════════════════════════════════════════════════════════╣');
  print('│ 🎯 CONTRIBUINTE: $contribuinteNumero');
  print('└─────────────────────────────────────────────────────────────┘\n');

  try {
    print('🔐 Assinando termo de autorização...\n');

    final response = await autenticaProcuradorService.autenticarProcurador(
      // Dados do CONTRATANTE
      contratanteNome: contratanteNome,
      contratanteNumero: finalContratanteNumero,

      // Dados do PROCURADOR
      autorNome: procuradorNome,
      autorNumero: finalProcuradorNumero,

      // Dados do CONTRIBUINTE
      contribuinteNumero: contribuinteNumero,

      // Certificado do PROCURADOR
      certificadoPath: certProcuradorPath,
      certificadoPassword: certProcuradorSenha,
    );

    print('📤 RESPOSTA:');
    print('   Status HTTP: ${response.status}');
    print('   Sucesso: ${response.sucesso}');

    if (response.sucesso) {
      print(
        '\n┌─────────────────────────────────────────────────────────────┐',
      );
      print('│ ✅ AUTENTICAÇÃO REALIZADA COM SUCESSO                        │');
      print('├─────────────────────────────────────────────────────────────┤');

      if (response.isCacheValido) {
        print(
          '│ 📦 Status: Token já existe no servidor (Cache)              │',
        );
        if (response.autenticarProcuradorToken != null) {
          print(
            '│ Token: ${_truncate(response.autenticarProcuradorToken!, 45)}',
          );
        }
      } else {
        print(
          '│ 🆕 Status: Novo token gerado                                │',
        );
        print(
          '│ Token: ${_truncate(response.autenticarProcuradorToken ?? 'N/A', 45)}',
        );
      }

      if (response.dataExpiracao != null) {
        print('│ Expira: ${response.dataExpiracao}');
      }
      print('│ Em Cache: ${response.isCacheValido}');
      print(
        '└─────────────────────────────────────────────────────────────┘\n',
      );

      // Salvar token para uso posterior
      if (response.autenticarProcuradorToken != null) {
        print(
          '💡 Use este token nas requisições para o contribuinte $contribuinteNumero',
        );
      }
    } else {
      print(
        '\n┌─────────────────────────────────────────────────────────────┐',
      );
      print('│ ❌ ERRO NA AUTENTICAÇÃO                                      │');
      print('├─────────────────────────────────────────────────────────────┤');
      print('│ Código: ${response.codigoMensagem}');
      print('│ Mensagem: ${response.mensagemPrincipal}');
      print(
        '└─────────────────────────────────────────────────────────────┘\n',
      );
    }

    return;
  } on ExcecaoAssinaturaCertificado catch (e) {
    print('❌ ERRO DE CERTIFICADO:');
    print('   ${e.mensagem}\n');
  } on ExcecaoAssinaturaXml catch (e) {
    print('❌ ERRO DE ASSINATURA XML:');
    print('   ${e.mensagem}\n');
  } on ExcecaoErroSerpro catch (e) {
    print('❌ ERRO DA API SERPRO:');
    print('   Código: ${e.codigo}');
    print('   Mensagem: ${e.mensagem}\n');
  } catch (e) {
    print('❌ ERRO INESPERADO: $e\n');
  }
}

/// Trunca uma string para o tamanho máximo especificado
String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}
