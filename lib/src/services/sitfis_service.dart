import 'dart:convert';
import 'dart:io';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/solicitar_protocolo_request.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/solicitar_protocolo_response.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/emitir_relatorio_request.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/emitir_relatorio_response.dart';
import 'package:serpro_integra_contador_api/src/models/sitfis/sitfis_cache.dart';

/// Serviço para integração com o SITFIS (Situação Fiscal)
///
/// O SITFIS é um sistema que fornece relatórios de situação fiscal
/// de contribuintes Pessoa Jurídica e Pessoa Física no âmbito da
/// Receita Federal do Brasil e Procuradoria-Geral da Fazenda Nacional.
class SitfisService {
  final ApiClient _apiClient;

  SitfisService(this._apiClient);

  /// Solicita protocolo para emissão do relatório de situação fiscal
  ///
  /// Este método faz uma chamada ao endpoint `/Apoiar` para solicitar
  /// um protocolo que será usado posteriormente para emitir o relatório.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte (apenas números)
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [SolicitarProtocoloResponse] com o protocolo e tempo de espera
  Future<SolicitarProtocoloResponse> solicitarProtocoloRelatorio(
    String contribuinteNumero, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = SolicitarProtocoloRequest(contribuinteNumero: contribuinteNumero);

    final response = await _apiClient.post('/Apoiar', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return SolicitarProtocoloResponse.fromJson(response);
  }

  /// Emite o relatório de situação fiscal usando o protocolo obtido
  ///
  /// Este método faz uma chamada ao endpoint `/Emitir` para gerar
  /// o relatório de situação fiscal em formato PDF.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte (apenas números)
  /// [protocoloRelatorio] - Protocolo obtido na solicitação anterior
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [EmitirRelatorioResponse] com o PDF do relatório ou tempo de espera
  Future<EmitirRelatorioResponse> emitirRelatorioSituacaoFiscal(
    String contribuinteNumero,
    String protocoloRelatorio, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EmitirRelatorioRequest(contribuinteNumero: contribuinteNumero, protocoloRelatorio: protocoloRelatorio);

    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return EmitirRelatorioResponse.fromJson(response);
  }

  /// Solicita protocolo com suporte a cache
  ///
  /// Este método verifica se já existe um protocolo válido em cache
  /// antes de fazer uma nova solicitação.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte
  /// [cache] - Cache existente (opcional)
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [SolicitarProtocoloResponse] ou null se usar cache válido
  Future<SolicitarProtocoloResponse?> solicitarProtocoloComCache(
    String contribuinteNumero, {
    SitfisCache? cache,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Se há cache válido, retorna null para indicar que deve usar o cache
    if (cache != null && cache.isValid) {
      return null;
    }

    return await solicitarProtocoloRelatorio(
      contribuinteNumero,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Emite relatório com retry automático baseado no tempo de espera
  ///
  /// Este método tenta emitir o relatório e, se necessário, aguarda
  /// o tempo especificado antes de tentar novamente.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte
  /// [protocoloRelatorio] - Protocolo obtido na solicitação anterior
  /// [maxTentativas] - Número máximo de tentativas (padrão: 5)
  /// [callbackProgresso] - Callback chamado a cada tentativa
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [EmitirRelatorioResponse] com o PDF do relatório
  Future<EmitirRelatorioResponse> emitirRelatorioComRetry(
    String contribuinteNumero,
    String protocoloRelatorio, {
    int maxTentativas = 5,
    Function(int tentativa, int? tempoEspera)? callbackProgresso,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    int tentativa = 0;

    while (tentativa < maxTentativas) {
      tentativa++;

      final response = await emitirRelatorioSituacaoFiscal(
        contribuinteNumero,
        protocoloRelatorio,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Se obteve sucesso, retorna
      if (response.isSuccess && response.hasPdf) {
        return response;
      }

      // Se está em processamento e há tempo de espera
      if (response.isProcessing && response.hasTempoEspera) {
        final tempoEspera = response.dados!.tempoEspera!;

        // Chama callback de progresso se fornecido
        if (callbackProgresso != null) {
          callbackProgresso(tentativa, tempoEspera);
        }

        // Aguarda o tempo especificado
        await Future.delayed(Duration(milliseconds: tempoEspera));
        continue;
      }

      // Se não há tempo de espera ou erro, retorna a resposta
      return response;
    }

    // Se esgotou as tentativas, retorna a última resposta
    return await emitirRelatorioSituacaoFiscal(
      contribuinteNumero,
      protocoloRelatorio,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Fluxo completo: solicita protocolo e emite relatório
  ///
  /// Este método executa todo o fluxo do SITFIS: solicita o protocolo,
  /// aguarda se necessário, e emite o relatório final.
  ///
  /// [contribuinteNumero] - CPF ou CNPJ do contribuinte
  /// [maxTentativas] - Número máximo de tentativas para emissão
  /// [callbackProgresso] - Callback chamado durante o progresso
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [EmitirRelatorioResponse] com o PDF do relatório
  Future<EmitirRelatorioResponse> obterRelatorioCompleto(
    String contribuinteNumero, {
    int maxTentativas = 5,
    Function(String etapa, int? tempoEspera)? callbackProgresso,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // 1. Solicitar protocolo
    callbackProgresso?.call('Solicitando protocolo...', null);
    final protocoloResponse = await solicitarProtocoloRelatorio(
      contribuinteNumero,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    if (!protocoloResponse.isSuccess || !protocoloResponse.hasProtocolo) {
      throw Exception('Falha ao obter protocolo: ${protocoloResponse.mensagens.map((m) => m.texto).join(', ')}');
    }

    final protocolo = protocoloResponse.dados!.protocoloRelatorio!;

    // 2. Se há tempo de espera, aguarda
    if (protocoloResponse.hasTempoEspera) {
      final tempoEspera = protocoloResponse.dados!.tempoEspera!;
      callbackProgresso?.call('Aguardando processamento...', tempoEspera);
      await Future.delayed(Duration(milliseconds: tempoEspera));
    }

    // 3. Emitir relatório com retry
    callbackProgresso?.call('Emitindo relatório...', null);
    return await emitirRelatorioComRetry(
      contribuinteNumero,
      protocolo,
      maxTentativas: maxTentativas,
      callbackProgresso: (tentativa, tempoEspera) {
        callbackProgresso?.call('Tentativa $tentativa - Aguardando...', tempoEspera);
      },
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Salva PDF do relatório em arquivo
  ///
  /// [response] - Response com o PDF
  /// [caminhoArquivo] - Caminho onde salvar o arquivo
  ///
  /// Retorna true se salvou com sucesso
  Future<bool> salvarPdfEmArquivo(EmitirRelatorioResponse response, String caminhoArquivo) async {
    if (!response.hasPdf) {
      return false;
    }

    try {
      final bytes = base64Decode(response.dados!.pdf!);
      final arquivo = File(caminhoArquivo);
      await arquivo.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações sobre o PDF do relatório
  ///
  /// [response] - Response com o PDF
  ///
  /// Retorna mapa com informações do PDF
  Map<String, dynamic> obterInformacoesPdf(EmitirRelatorioResponse response) {
    if (!response.hasPdf) {
      return {'disponivel': false};
    }

    final pdf = response.dados!.pdf!;
    final tamanhoBytes = response.dados!.pdfSizeInBytes ?? 0;

    return {
      'disponivel': true,
      'tamanhoBytes': tamanhoBytes,
      'tamanhoKB': (tamanhoBytes / 1024).round(),
      'tamanhoMB': (tamanhoBytes / (1024 * 1024)).toStringAsFixed(2),
      'tamanhoBase64': pdf.length,
    };
  }
}
