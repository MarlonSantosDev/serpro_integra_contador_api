import 'dart:convert';
import '../core/api_client.dart';
import '../models/base/base_request.dart';
import '../models/autenticaprocurador/termo_autorizacao_request.dart';
import '../models/autenticaprocurador/termo_autorizacao_response.dart';
import '../models/autenticaprocurador/assinatura_digital_model.dart';
import '../models/autenticaprocurador/cache_model.dart';
import '../util/xml_utils.dart';
import '../util/assinatura_digital_utils.dart';
import '../util/cache_utils.dart';

/// Serviço para autenticação de procurador
class AutenticaProcuradorService {
  final ApiClient _apiClient;
  final String _endpoint = '/AutenticarProcurador';

  AutenticaProcuradorService(this._apiClient);

  /// Cria termo de autorização
  Future<TermoAutorizacaoRequest> criarTermoAutorizacao({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? dataAssinatura,
    String? dataVigencia,
    String? certificadoPath,
    String? certificadoPassword,
  }) async {
    final dataAssinaturaFinal = dataAssinatura ?? _formatarData(DateTime.now());
    final dataVigenciaFinal =
        dataVigencia ??
        _formatarData(DateTime.now().add(const Duration(days: 365)));

    final termo = TermoAutorizacaoRequest(
      contratanteNumero: contratanteNumero,
      contratanteNome: contratanteNome,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      autorPedidoDadosNome: autorPedidoDadosNome,
      dataAssinatura: dataAssinaturaFinal,
      dataVigencia: dataVigenciaFinal,
      certificadoPath: certificadoPath,
      certificadoPassword: certificadoPassword,
    );

    // Validar dados do termo
    final erros = termo.validarDados();
    if (erros.isNotEmpty) {
      throw Exception(
        'Dados inválidos do termo de autorização: ${erros.join(', ')}',
      );
    }

    return termo;
  }

  /// Cria termo de autorização com data atual
  Future<TermoAutorizacaoRequest> criarTermoComDataAtual({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? certificadoPath,
    String? certificadoPassword,
  }) async {
    return TermoAutorizacaoRequest.comDataAtual(
      contratanteNumero: contratanteNumero,
      contratanteNome: contratanteNome,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      autorPedidoDadosNome: autorPedidoDadosNome,
      certificadoPath: certificadoPath,
      certificadoPassword: certificadoPassword,
    );
  }

  /// Assina termo de autorização digitalmente
  Future<String> assinarTermoDigital(TermoAutorizacaoRequest termo) async {
    try {
      // Validar certificado se fornecido
      if (termo.certificadoPath != null && termo.certificadoPassword != null) {
        final isValid =
            await AssinaturaDigitalUtils.validarCertificadoICPBrasil(
              certificadoPath: termo.certificadoPath!,
              senha: termo.certificadoPassword!,
            );

        if (!isValid) {
          throw Exception('Certificado digital inválido');
        }
      }

      // Criar XML do termo
      final xml = termo.criarXmlTermo();

      // Validar estrutura do XML
      final errosXml = XmlUtils.validarEstruturaTermoAutorizacao(xml);
      if (errosXml.isNotEmpty) {
        throw Exception('XML do termo inválido: ${errosXml.join(', ')}');
      }

      // Assinar XML
      String xmlAssinado;
      if (termo.certificadoPath != null && termo.certificadoPassword != null) {
        xmlAssinado = await AssinaturaDigitalUtils.assinarXml(
          xml: xml,
          certificadoPath: termo.certificadoPath!,
          senha: termo.certificadoPassword!,
        );
      } else {
        // Assinatura simulada para demonstração
        xmlAssinado = await _assinarXmlSimulado(xml);
      }

      // Validar assinatura
      final errosAssinatura = AssinaturaDigitalUtils.validarEstruturaAssinatura(
        xmlAssinado,
      );
      if (errosAssinatura.isNotEmpty) {
        throw Exception(
          'Assinatura digital inválida: ${errosAssinatura.join(', ')}',
        );
      }

      return xmlAssinado;
    } catch (e) {
      throw Exception('Erro ao assinar termo digitalmente: $e');
    }
  }

  /// Assina XML simuladamente (para demonstração)
  Future<String> _assinarXmlSimulado(String xml) async {
    // Esta é uma implementação simulada - NÃO USE EM PRODUÇÃO
    final assinatura = _gerarAssinaturaSimulada(
      xml,
      ConfiguracaoAssinatura.padraoICPBrasil(
        tipoCertificado: TipoCertificado.ecnpj,
        formatoCertificado: FormatoCertificado.a1,
      ),
    );

    return xml.replaceAll(
      '<!-- Assinatura digital será inserida aqui -->',
      assinatura,
    );
  }

  /// Gera assinatura simulada para demonstração
  String _gerarAssinaturaSimulada(String xml, ConfiguracaoAssinatura config) {
    final hash = xml.hashCode.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final serial = _gerarSerialSimulado();

    return '''<SignedInfo>
        <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
        <SignatureMethod Algorithm="${config.algoritmoAssinatura}"/>
        <Reference URI="">
            <Transforms>
                <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
            </Transforms>
            <DigestMethod Algorithm="${config.algoritmoHash}"/>
            <DigestValue>${base64.encode(utf8.encode(hash))}</DigestValue>
        </Reference>
    </SignedInfo>
    <SignatureValue>${base64.encode(utf8.encode('SIMULADO_$timestamp'))}</SignatureValue>
    <KeyInfo>
        <X509Data>
            <X509Certificate>${base64.encode(utf8.encode('CERTIFICADO_SIMULADO_$serial'))}</X509Certificate>
        </X509Data>
    </KeyInfo>''';
  }

  /// Gera serial simulado
  String _gerarSerialSimulado() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SIMULADO_${timestamp.toString().substring(8)}';
  }

  /// Autentica procurador enviando termo assinado
  Future<TermoAutorizacaoResponse> autenticarProcurador({
    required String xmlAssinado,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    try {
      // Converter XML para Base64
      final xmlBase64 = XmlUtils.xmlToBase64(xmlAssinado);

      // Criar requisição
      final requestBody = {'termoAutorizacao': xmlBase64};

      // Fazer requisição HTTP
      final response = await _apiClient.post(
        _endpoint,
        _createBaseRequest(requestBody),
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Processar resposta
      final termoResponse = TermoAutorizacaoResponse.fromJson(response);

      // Salvar cache se autenticação foi bem-sucedida
      if (termoResponse.sucesso &&
          termoResponse.autenticarProcuradorToken != null) {
        await _salvarCache(
          termoResponse.autenticarProcuradorToken!,
          contratanteNumero,
          autorPedidoDadosNumero,
          response,
        );
      }

      return termoResponse;
    } catch (e) {
      throw Exception('Erro ao autenticar procurador: $e');
    }
  }

  /// Verifica se existe token válido em cache
  Future<CacheModel?> verificarCacheToken({
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    try {
      final chave = CacheUtils.gerarChaveCache(
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      final cache = await CacheUtils.carregarCache(chave);
      if (cache != null && cache.isTokenValido) {
        return cache;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Renova token de autenticação
  Future<TermoAutorizacaoResponse> renovarToken({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? certificadoPath,
    String? certificadoPassword,
  }) async {
    try {
      // Criar novo termo
      final termo = await criarTermoComDataAtual(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
        certificadoPath: certificadoPath,
        certificadoPassword: certificadoPassword,
      );

      // Assinar termo
      final xmlAssinado = await assinarTermoDigital(termo);

      // Autenticar
      final response = await autenticarProcurador(
        xmlAssinado: xmlAssinado,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      return response;
    } catch (e) {
      throw Exception('Erro ao renovar token: $e');
    }
  }

  /// Obtém token válido (do cache ou renova se necessário)
  Future<String> obterTokenValido({
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorPedidoDadosNome,
    String? certificadoPath,
    String? certificadoPassword,
  }) async {
    try {
      // Verificar cache primeiro
      final cache = await verificarCacheToken(
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      if (cache != null && cache.isTokenValido) {
        return cache.token;
      }

      // Renovar token se necessário
      final response = await renovarToken(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
        autorPedidoDadosNome: autorPedidoDadosNome,
        certificadoPath: certificadoPath,
        certificadoPassword: certificadoPassword,
      );

      if (response.autenticarProcuradorToken == null) {
        throw Exception('Falha ao obter token de autenticação');
      }

      return response.autenticarProcuradorToken!;
    } catch (e) {
      throw Exception('Erro ao obter token válido: $e');
    }
  }

  /// Limpa cache de tokens
  Future<void> limparCache() async {
    try {
      await CacheUtils.limparTodosCaches();
    } catch (e) {
      throw Exception('Erro ao limpar cache: $e');
    }
  }

  /// Remove caches expirados
  Future<int> removerCachesExpirados() async {
    try {
      return await CacheUtils.removerCachesExpirados();
    } catch (e) {
      throw Exception('Erro ao remover caches expirados: $e');
    }
  }

  /// Obtém estatísticas do cache
  Future<Map<String, dynamic>> obterEstatisticasCache() async {
    try {
      return await CacheUtils.obterEstatisticas();
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  /// Valida termo de autorização
  Future<List<String>> validarTermoAutorizacao(String xml) async {
    try {
      return XmlUtils.validarEstruturaTermoAutorizacao(xml);
    } catch (e) {
      return ['Erro ao validar termo: $e'];
    }
  }

  /// Valida assinatura digital
  Future<Map<String, dynamic>> validarAssinaturaDigital(
    String xmlAssinado,
  ) async {
    try {
      return AssinaturaDigitalUtils.gerarRelatorioValidacao(xmlAssinado);
    } catch (e) {
      return {'erro': e.toString(), 'assinatura_valida': false};
    }
  }

  /// Obtém informações do certificado
  Future<Map<String, dynamic>> obterInfoCertificado({
    required String certificadoPath,
    required String senha,
  }) async {
    try {
      return await AssinaturaDigitalUtils.extrairInfoCertificado(
        certificadoPath: certificadoPath,
        senha: senha,
      );
    } catch (e) {
      throw Exception('Erro ao obter informações do certificado: $e');
    }
  }

  /// Salva cache do token
  Future<void> _salvarCache(
    String token,
    String contratanteNumero,
    String autorPedidoDadosNumero,
    Map<String, dynamic> response,
  ) async {
    try {
      final chave = CacheUtils.gerarChaveCache(
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Extrair headers da resposta
      final headers = <String, String>{};
      if (response.containsKey('headers')) {
        headers.addAll(Map<String, String>.from(response['headers']));
      }

      // Criar cache
      final cache = CacheModel.fromResponse(
        token: token,
        headers: headers,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Salvar cache
      await CacheUtils.salvarCache(chave, cache);
    } catch (e) {
      // Ignorar erro ao salvar cache
    }
  }

  /// Cria BaseRequest para requisição
  BaseRequest _createBaseRequest(Map<String, dynamic> body) {
    return BaseRequest(
      contribuinteNumero: '00000000000100',
      pedidoDados: PedidoDados(
        idSistema: 'AUTENTICAPROCURADOR',
        idServico: 'AUTENTICAR',
        versaoSistema: '1.0',
        dados: jsonEncode(body),
      ),
    );
  }

  /// Formata data para AAAAMMDD
  String _formatarData(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
