// import 'dart:convert';
// import 'dart:io';

// /// Modelo para gerenciamento de cache de tokens de autenticação
// class CacheModel {
//   final String token;
//   final DateTime dataCriacao;
//   final DateTime dataExpiracao;
//   final String contratanteNumero;
//   final String autorPedidoDadosNumero;
//   final Map<String, String> headers;
//   final bool isValido;

//   CacheModel({
//     required this.token,
//     required this.dataCriacao,
//     required this.dataExpiracao,
//     required this.contratanteNumero,
//     required this.autorPedidoDadosNumero,
//     this.headers = const {},
//     this.isValido = true,
//   });

//   /// Cria cache a partir de headers HTTP
//   factory CacheModel.fromHeaders({
//     required Map<String, String> headers,
//     required String contratanteNumero,
//     required String autorPedidoDadosNumero,
//   }) {
//     final etag = headers['etag'] ?? '';
//     final expires = headers['expires'] ?? '';

//     // Extrair token do ETag
//     String token = '';
//     if (etag.contains('autenticar_procurador_token:')) {
//       final startIndex = etag.indexOf('autenticar_procurador_token:') + 28;
//       final endIndex = etag.indexOf('"', startIndex);
//       if (endIndex > startIndex) {
//         token = etag.substring(startIndex, endIndex);
//       }
//     }

//     // Parsear data de expiração
//     DateTime dataExpiracao = DateTime.now().add(const Duration(hours: 24));
//     if (expires.isNotEmpty) {
//       try {
//         dataExpiracao = DateTime.parse(expires);
//       } catch (e) {
//         // Se não conseguir parsear, usar 24h a partir de agora
//         dataExpiracao = DateTime.now().add(const Duration(hours: 24));
//       }
//     }

//     return CacheModel(
//       token: token,
//       dataCriacao: DateTime.now(),
//       dataExpiracao: dataExpiracao,
//       contratanteNumero: contratanteNumero,
//       autorPedidoDadosNumero: autorPedidoDadosNumero,
//       headers: headers,
//     );
//   }

//   /// Cria cache a partir de resposta da API
//   factory CacheModel.fromResponse({
//     required String token,
//     required Map<String, String> headers,
//     required String contratanteNumero,
//     required String autorPedidoDadosNumero,
//   }) {
//     DateTime dataExpiracao = DateTime.now().add(const Duration(hours: 24));

//     // Tentar extrair data de expiração dos headers
//     final expires = headers['expires'];
//     if (expires != null && expires.isNotEmpty) {
//       try {
//         dataExpiracao = DateTime.parse(expires);
//       } catch (e) {
//         // Usar meia-noite do dia seguinte se não conseguir parsear
//         final tomorrow = DateTime.now().add(const Duration(days: 1));
//         dataExpiracao = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
//       }
//     }

//     return CacheModel(
//       token: token,
//       dataCriacao: DateTime.now(),
//       dataExpiracao: dataExpiracao,
//       contratanteNumero: contratanteNumero,
//       autorPedidoDadosNumero: autorPedidoDadosNumero,
//       headers: headers,
//     );
//   }

//   /// Verifica se o token ainda é válido
//   bool get isTokenValido {
//     if (!isValido) return false;
//     return DateTime.now().isBefore(dataExpiracao);
//   }

//   /// Verifica se o token expira em breve (menos de 1 hora)
//   bool get expiraEmBreve {
//     if (!isTokenValido) return true;
//     return dataExpiracao.difference(DateTime.now()).inHours < 1;
//   }

//   /// Tempo restante até expiração
//   Duration get tempoRestante {
//     if (!isTokenValido) return Duration.zero;
//     return dataExpiracao.difference(DateTime.now());
//   }

//   /// Indica se deve renovar o token
//   bool get deveRenovar {
//     return !isTokenValido || expiraEmBreve;
//   }

//   /// Obtém headers para requisições
//   Map<String, String> get headersParaRequisicao {
//     return {
//       'autenticar_procurador_token': token,
//       'cache-control': 'termo_autorizacao',
//       'etag': '"autenticar_procurador_token:$token"',
//     };
//   }

//   /// Salva cache em arquivo
//   Future<void> salvarEmArquivo(String caminhoArquivo) async {
//     try {
//       final file = File(caminhoArquivo);
//       final json = toJson();
//       await file.writeAsString(jsonEncode(json));
//     } catch (e) {
//       throw Exception('Erro ao salvar cache: $e');
//     }
//   }

//   /// Carrega cache de arquivo
//   static Future<CacheModel?> carregarDeArquivo(String caminhoArquivo) async {
//     try {
//       final file = File(caminhoArquivo);
//       if (!await file.exists()) return null;

//       final json = jsonDecode(await file.readAsString());
//       return CacheModel.fromJson(json);
//     } catch (e) {
//       return null;
//     }
//   }

//   /// Remove arquivo de cache
//   static Future<void> removerArquivo(String caminhoArquivo) async {
//     try {
//       final file = File(caminhoArquivo);
//       if (await file.exists()) {
//         await file.delete();
//       }
//     } catch (e) {
//       // Ignorar erro ao remover arquivo
//     }
//   }

//   factory CacheModel.fromJson(Map<String, dynamic> json) {
//     return CacheModel(
//       token: json['token'].toString(),
//       dataCriacao: DateTime.parse(json['data_criacao'].toString()),
//       dataExpiracao: DateTime.parse(json['data_expiracao'].toString()),
//       contratanteNumero: json['contratante_numero'].toString(),
//       autorPedidoDadosNumero: json['autor_pedido_dados_numero'].toString(),
//       headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
//       isValido: json['is_valido'] as bool? ?? true,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'token': token,
//       'data_criacao': dataCriacao.toIso8601String(),
//       'data_expiracao': dataExpiracao.toIso8601String(),
//       'contratante_numero': contratanteNumero,
//       'autor_pedido_dados_numero': autorPedidoDadosNumero,
//       'headers': headers,
//       'is_valido': isValido,
//     };
//   }

//   @override
//   String toString() {
//     return 'CacheModel(token: ${token.substring(0, 8)}..., '
//         'valido: $isTokenValido, expira: $dataExpiracao)';
//   }
// }

// /// Gerenciador de cache para múltiplos tokens
// class CacheManager {
//   final Map<String, CacheModel> _cache = {};
//   final String? _diretorioCache;

//   CacheManager({String? diretorioCache}) : _diretorioCache = diretorioCache;

//   /// Adiciona ou atualiza cache
//   void adicionarCache(String chave, CacheModel cache) {
//     _cache[chave] = cache;
//   }

//   /// Obtém cache por chave
//   CacheModel? obterCache(String chave) {
//     final cache = _cache[chave];
//     if (cache != null && !cache.isTokenValido) {
//       _cache.remove(chave);
//       return null;
//     }
//     return cache;
//   }

//   /// Remove cache expirado
//   void removerCacheExpirado() {
//     _cache.removeWhere((chave, cache) => !cache.isTokenValido);
//   }

//   /// Obtém todos os caches válidos
//   Map<String, CacheModel> get cachesValidos {
//     final validos = <String, CacheModel>{};
//     for (final entry in _cache.entries) {
//       if (entry.value.isTokenValido) {
//         validos[entry.key] = entry.value;
//       }
//     }
//     return validos;
//   }

//   /// Limpa todos os caches
//   void limparTodos() {
//     _cache.clear();
//   }

//   /// Salva todos os caches em arquivos
//   Future<void> salvarTodos() async {
//     if (_diretorioCache == null) return;

//     try {
//       final diretorio = Directory(_diretorioCache);
//       if (!await diretorio.exists()) {
//         await diretorio.create(recursive: true);
//       }

//       for (final entry in _cache.entries) {
//         final arquivo = File('${_diretorioCache}/${entry.key}.json');
//         await entry.value.salvarEmArquivo(arquivo.path);
//       }
//     } catch (e) {
//       throw Exception('Erro ao salvar caches: $e');
//     }
//   }

//   /// Carrega todos os caches de arquivos
//   Future<void> carregarTodos() async {
//     if (_diretorioCache == null) return;

//     try {
//       final diretorio = Directory(_diretorioCache);
//       if (!await diretorio.exists()) return;

//       final arquivos = await diretorio
//           .list()
//           .where((entity) => entity is File && entity.path.endsWith('.json'))
//           .toList();

//       for (final arquivo in arquivos) {
//         final cache = await CacheModel.carregarDeArquivo(arquivo.path);
//         if (cache != null && cache.isTokenValido) {
//           final chave = arquivo.path.split('/').last.replaceAll('.json', '');
//           _cache[chave] = cache;
//         }
//       }
//     } catch (e) {
//       // Ignorar erros ao carregar cache
//     }
//   }

//   /// Gera chave única para cache
//   static String gerarChaveCache({
//     required String contratanteNumero,
//     required String autorPedidoDadosNumero,
//   }) {
//     return '${contratanteNumero}_$autorPedidoDadosNumero';
//   }

//   /// Obtém estatísticas do cache
//   Map<String, dynamic> get estatisticas {
//     final total = _cache.length;
//     final validos = cachesValidos.length;
//     final expirados = total - validos;

//     return {
//       'total_caches': total,
//       'caches_validos': validos,
//       'caches_expirados': expirados,
//       'taxa_validos': total > 0
//           ? (validos / total * 100).toStringAsFixed(1)
//           : '0.0',
//     };
//   }
// }
