/// Modelo para cache de protocolos do SITFIS
class SitfisCache {
  final String protocoloRelatorio;
  final DateTime dataExpiracao;
  final String? etag;
  final String? cacheControl;

  SitfisCache({required this.protocoloRelatorio, required this.dataExpiracao, this.etag, this.cacheControl});

  factory SitfisCache.fromHeaders({required String protocoloRelatorio, required String etag, required String cacheControl, required String expires}) {
    return SitfisCache(protocoloRelatorio: protocoloRelatorio, dataExpiracao: DateTime.parse(expires), etag: etag, cacheControl: cacheControl);
  }

  /// Verifica se o cache ainda é válido
  bool get isValid => DateTime.now().isBefore(dataExpiracao);

  /// Verifica se o cache expirou
  bool get isExpired => DateTime.now().isAfter(dataExpiracao);

  /// Tempo restante até expirar
  Duration get tempoRestante => dataExpiracao.difference(DateTime.now());

  /// Tempo restante em milissegundos
  int get tempoRestanteEmMs => tempoRestante.inMilliseconds;

  /// Tempo restante em segundos
  int get tempoRestanteEmSegundos => tempoRestante.inSeconds;

  Map<String, dynamic> toJson() {
    return {'protocoloRelatorio': protocoloRelatorio, 'dataExpiracao': dataExpiracao.toIso8601String(), 'etag': etag, 'cacheControl': cacheControl};
  }

  factory SitfisCache.fromJson(Map<String, dynamic> json) {
    return SitfisCache(
      protocoloRelatorio: json['protocoloRelatorio'] as String,
      dataExpiracao: DateTime.parse(json['dataExpiracao'] as String),
      etag: json['etag'] as String?,
      cacheControl: json['cacheControl'] as String?,
    );
  }
}

/// Utilitários para trabalhar com cache do SITFIS
class SitfisCacheUtils {
  /// Extrai o protocolo do header ETag
  static String? extrairProtocoloDoETag(String etag) {
    try {
      // Remove aspas se existirem
      String cleanEtag = etag.trim();
      if (cleanEtag.startsWith('"') && cleanEtag.endsWith('"')) {
        cleanEtag = cleanEtag.substring(1, cleanEtag.length - 1);
      }

      // Procura por "protocoloRelatorio:" no ETag
      if (cleanEtag.contains('protocoloRelatorio:')) {
        final parts = cleanEtag.split('protocoloRelatorio:');
        if (parts.length > 1) {
          return parts[1].trim();
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extrai o tempo de espera do header ETag
  static int? extrairTempoEsperaDoETag(String etag) {
    try {
      // Remove aspas se existirem
      String cleanEtag = etag.trim();
      if (cleanEtag.startsWith('"') && cleanEtag.endsWith('"')) {
        cleanEtag = cleanEtag.substring(1, cleanEtag.length - 1);
      }

      // Procura por "tempoEspera:" no ETag
      if (cleanEtag.contains('tempoEspera:')) {
        final parts = cleanEtag.split('tempoEspera:');
        if (parts.length > 1) {
          return int.tryParse(parts[1].trim());
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cria um cache a partir dos headers HTTP
  static SitfisCache? criarCacheDosHeaders(Map<String, String> headers) {
    try {
      final etag = headers['etag'];
      final cacheControl = headers['cache-control'];
      final expires = headers['expires'];

      if (etag == null || expires == null) {
        return null;
      }

      final protocolo = extrairProtocoloDoETag(etag);
      if (protocolo == null) {
        return null;
      }

      return SitfisCache.fromHeaders(protocoloRelatorio: protocolo, etag: etag, cacheControl: cacheControl ?? '', expires: expires);
    } catch (e) {
      return null;
    }
  }
}
