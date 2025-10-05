import 'dart:convert';
import '../../core/api_client.dart';
import '../../base/base_request.dart';
import 'model/termo_autorizacao_request.dart';
import 'model/termo_autorizacao_response.dart';
import '../../util/validacoes_utils.dart';

/// Serviço para autenticação de procurador
/// Funcionalidade principal: Envio de XML assinado com o Termo de Autorização
class AutenticaProcuradorService {
  final ApiClient _apiClient;
  final String _endpoint = '/Apoiar';

  AutenticaProcuradorService(this._apiClient);

  /// Método principal: Autentica procurador enviando XML assinado com Termo de Autorização
  /// Este método faz todo o fluxo automaticamente:
  /// 1. Cria o termo de autorização
  /// 2. Valida os dados (transparente)
  /// 3. Cria o XML
  /// 4. Assina digitalmente (simulado para testes)
  /// 5. Envia para a API e obtém o token
  Future<TermoAutorizacaoResponse> autenticarProcurador({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? contribuinteNumero,
    String? certificadoPath,
    String? certificadoPassword,
  }) async {
    try {
      // 1. Criar termo de autorização
      final termo = TermoAutorizacaoRequest.comDataAtual(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
        certificadoPath: certificadoPath,
        certificadoPassword: certificadoPassword,
      );

      // 2. Validar dados (transparente)
      final erros = termo.validarDados();
      if (erros.isNotEmpty) {
        //throw Exception('Dados inválidos: ${erros.join(', ')}');
      }

      // 3. Criar XML do termo
      final xml = termo.criarXmlTermo();

      // 4. Assinar digitalmente (simulado para testes)
      final xmlAssinado = await _assinarXmlSimulado(xml);

      // 5. Enviar para API e obter token
      return await _enviarParaAPI(
        xmlAssinado,
        contratanteNumero,
        autorPedidoDadosNumero,
        contribuinteNumero ?? '11111111111111', // Usar contribuinte informado ou padrão
      );
    } catch (e) {
      throw Exception('Erro na autenticação de procurador: $e');
    }
  }

  /// Assina XML simuladamente (para demonstração/testes)
  Future<String> _assinarXmlSimulado(String xml) async {
    final hash = xml.hashCode.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final serial = 'SIMULADO_${timestamp.substring(8)}';

    final assinatura =
        '''<SignedInfo>
        <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
        <SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
        <Reference URI="">
            <Transforms>
                <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                <Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
            </Transforms>
            <DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
            <DigestValue>${base64.encode(utf8.encode(hash))}</DigestValue>
        </Reference>
    </SignedInfo>
    <SignatureValue>${base64.encode(utf8.encode('SIMULADO_$timestamp'))}</SignatureValue>
    <KeyInfo>
        <X509Data>
            <X509Certificate>${base64.encode(utf8.encode('CERTIFICADO_SIMULADO_$serial'))}</X509Certificate>
        </X509Data>
    </KeyInfo>''';

    return xml.replaceAll('<!-- Assinatura digital será inserida aqui -->', assinatura);
  }

  /// Envia XML assinado para a API
  Future<TermoAutorizacaoResponse> _enviarParaAPI(
    String xmlAssinado,
    String contratanteNumero,
    String autorPedidoDadosNumero,
    String contribuinteNumero,
  ) async {
    try {
      // Converter XML para Base64
      final xmlBase64 = base64.encode(utf8.encode(xmlAssinado));

      // Criar requisição conforme especificação da API
      final requestBody = {
        'contratante': {
          'numero': ValidacoesUtils.cleanDocumentNumber(contratanteNumero),
          'tipo': ValidacoesUtils.detectDocumentType(contratanteNumero),
        },
        'autorPedidoDados': {
          'numero': ValidacoesUtils.cleanDocumentNumber(autorPedidoDadosNumero),
          'tipo': ValidacoesUtils.detectDocumentType(autorPedidoDadosNumero),
        },
        'contribuinte': {
          'numero': ValidacoesUtils.cleanDocumentNumber(contribuinteNumero),
          'tipo': ValidacoesUtils.detectDocumentType(contribuinteNumero),
        },
        'pedidoDados': {
          'idSistema': 'AUTENTICAPROCURADOR',
          'idServico': 'ENVIOXMLASSINADO81',
          'versaoSistema': '1.0',
          'dados': jsonEncode({'xml': xmlBase64}),
        },
      };

      // Fazer requisição HTTP
      final response = await _apiClient.post(
        _endpoint,
        _createBaseRequest(requestBody, contribuinteNumero),
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Processar resposta
      return TermoAutorizacaoResponse.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao enviar para API: $e');
    }
  }

  /// Cria BaseRequest para requisição
  BaseRequest _createBaseRequest(Map<String, dynamic> body, String contribuinteNumero) {
    return BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'AUTENTICAPROCURADOR', idServico: 'ENVIOXMLASSINADO81', versaoSistema: '1.0', dados: jsonEncode(body)),
    );
  }
}
