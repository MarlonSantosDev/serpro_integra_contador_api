import 'dart:convert';
import 'dart:io';
import '../models/autenticaprocurador/cache_model.dart';

/// Utilitários para gerenciamento de cache de autenticação
///
/// Esta classe fornece funcionalidades completas para:
/// - Armazenar tokens de procurador em arquivos locais
/// - Gerenciar expiração automática de tokens
/// - Limpar caches expirados
/// - Exportar/importar caches para backup
/// - Obter estatísticas de uso do cache
///
/// O cache é armazenado no diretório temporário do sistema por padrão,
/// mas pode ser customizado para diferentes cenários de uso.
class CacheUtils {
  /// Nome do diretório padrão para armazenar caches
  static const String _diretorioPadrao = '.cache_autenticacao';

  /// Nome do arquivo de configuração do cache
  static const String _arquivoConfig = 'cache_config.json';

  /// Obtém o diretório onde os caches serão armazenados
  ///
  /// [diretorioCustomizado]: Diretório personalizado (opcional)
  ///
  /// Retorna: Caminho do diretório de cache (customizado ou padrão do sistema)
  static String obterDiretorioCache({String? diretorioCustomizado}) {
    if (diretorioCustomizado != null) {
      return diretorioCustomizado;
    }

    // Usar diretório temporário do sistema para evitar problemas de permissão
    final tempDir = Directory.systemTemp;
    return '${tempDir.path}/$_diretorioPadrao';
  }

  /// Cria o diretório de cache se não existir
  ///
  /// [diretorioCustomizado]: Diretório personalizado (opcional)
  ///
  /// Cria recursivamente todos os diretórios necessários
  static Future<void> criarDiretorioCache({String? diretorioCustomizado}) async {
    final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
    final dir = Directory(diretorio);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Salva um cache em arquivo JSON
  ///
  /// [chave]: Identificador único do cache (geralmente baseado em contratante + autor)
  /// [cache]: Objeto CacheModel com os dados do token
  /// [diretorioCustomizado]: Diretório personalizado (opcional)
  ///
  /// Lança exceção se houver erro ao salvar
  static Future<void> salvarCache(String chave, CacheModel cache, {String? diretorioCustomizado}) async {
    try {
      await criarDiretorioCache(diretorioCustomizado: diretorioCustomizado);

      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final arquivo = File('$diretorio/${_sanitizarChave(chave)}.json');

      final json = cache.toJson();
      await arquivo.writeAsString(jsonEncode(json));
    } catch (e) {
      throw Exception('Erro ao salvar cache: $e');
    }
  }

  /// Carrega um cache de arquivo JSON
  ///
  /// [chave]: Identificador único do cache
  /// [diretorioCustomizado]: Diretório personalizado (opcional)
  ///
  /// Retorna: CacheModel se encontrado e válido, null caso contrário
  /// Remove automaticamente caches expirados
  static Future<CacheModel?> carregarCache(String chave, {String? diretorioCustomizado}) async {
    try {
      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final arquivo = File('$diretorio/${_sanitizarChave(chave)}.json');

      if (!await arquivo.exists()) {
        return null;
      }

      final json = jsonDecode(await arquivo.readAsString());
      final cache = CacheModel.fromJson(json);

      // Verificar se o cache ainda é válido (não expirado)
      if (!cache.isTokenValido) {
        await removerCache(chave, diretorioCustomizado: diretorioCustomizado);
        return null;
      }

      return cache;
    } catch (e) {
      // Retornar null em caso de erro (arquivo corrompido, etc.)
      return null;
    }
  }

  /// Remove cache
  static Future<void> removerCache(String chave, {String? diretorioCustomizado}) async {
    try {
      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final arquivo = File('$diretorio/${_sanitizarChave(chave)}.json');

      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } catch (e) {
      // Ignorar erro ao remover arquivo
    }
  }

  /// Lista todos os caches
  static Future<List<String>> listarCaches({String? diretorioCustomizado}) async {
    try {
      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final dir = Directory(diretorio);

      if (!await dir.exists()) {
        return [];
      }

      final arquivos = await dir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .map((entity) => entity.path.split('/').last.replaceAll('.json', ''))
          .toList();

      return arquivos;
    } catch (e) {
      return [];
    }
  }

  /// Limpa todos os caches
  static Future<void> limparTodosCaches({String? diretorioCustomizado}) async {
    try {
      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final dir = Directory(diretorio);

      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Erro ao limpar caches: $e');
    }
  }

  /// Remove caches expirados
  static Future<int> removerCachesExpirados({String? diretorioCustomizado}) async {
    int removidos = 0;

    try {
      final caches = await listarCaches(diretorioCustomizado: diretorioCustomizado);

      for (final chave in caches) {
        final cache = await carregarCache(chave, diretorioCustomizado: diretorioCustomizado);
        if (cache == null || !cache.isTokenValido) {
          await removerCache(chave, diretorioCustomizado: diretorioCustomizado);
          removidos++;
        }
      }
    } catch (e) {
      // Ignorar erros
    }

    return removidos;
  }

  /// Obtém estatísticas do cache
  static Future<Map<String, dynamic>> obterEstatisticas({String? diretorioCustomizado}) async {
    try {
      final caches = await listarCaches(diretorioCustomizado: diretorioCustomizado);
      int validos = 0;
      int expirados = 0;
      int totalBytes = 0;

      for (final chave in caches) {
        final cache = await carregarCache(chave, diretorioCustomizado: diretorioCustomizado);
        if (cache != null) {
          if (cache.isTokenValido) {
            validos++;
          } else {
            expirados++;
          }

          // Calcular tamanho aproximado
          totalBytes += jsonEncode(cache.toJson()).length;
        } else {
          expirados++;
        }
      }

      return {
        'total_caches': caches.length,
        'caches_validos': validos,
        'caches_expirados': expirados,
        'taxa_validos': caches.isNotEmpty ? (validos / caches.length * 100).toStringAsFixed(1) : '0.0',
        'tamanho_total_bytes': totalBytes,
        'tamanho_total_kb': (totalBytes / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      return {
        'erro': e.toString(),
        'total_caches': 0,
        'caches_validos': 0,
        'caches_expirados': 0,
        'taxa_validos': '0.0',
        'tamanho_total_bytes': 0,
        'tamanho_total_kb': '0.0',
      };
    }
  }

  /// Sanitiza chave para nome de arquivo
  static String _sanitizarChave(String chave) {
    return chave.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  /// Gera uma chave única para cache baseada nos dados de autenticação
  ///
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor da requisição
  ///
  /// Retorna: Chave única no formato "contratante_autor"
  static String gerarChaveCache({required String contratanteNumero, required String autorPedidoDadosNumero}) {
    return '${contratanteNumero}_$autorPedidoDadosNumero';
  }

  /// Valida se uma chave de cache tem formato válido
  ///
  /// [chave]: Chave a ser validada
  ///
  /// Retorna: true se a chave é válida (não vazia, tamanho adequado, sem espaços, com separador)
  static bool isChaveValida(String chave) {
    return chave.isNotEmpty && chave.length > 5 && !chave.contains(' ') && chave.contains('_');
  }

  /// Obtém informações de um arquivo de cache
  static Future<Map<String, dynamic>?> obterInfoCache(String chave, {String? diretorioCustomizado}) async {
    try {
      final cache = await carregarCache(chave, diretorioCustomizado: diretorioCustomizado);
      if (cache == null) return null;

      return {
        'chave': chave,
        'token': cache.token.substring(0, 8) + '...',
        'data_criacao': cache.dataCriacao.toIso8601String(),
        'data_expiracao': cache.dataExpiracao.toIso8601String(),
        'is_valido': cache.isTokenValido,
        'expira_em_breve': cache.expiraEmBreve,
        'tempo_restante_horas': cache.tempoRestante.inHours,
        'contratante_numero': cache.contratanteNumero,
        'autor_pedido_dados_numero': cache.autorPedidoDadosNumero,
      };
    } catch (e) {
      return null;
    }
  }

  /// Exporta cache para backup
  static Future<String> exportarCache(String chave, {String? diretorioCustomizado}) async {
    try {
      final cache = await carregarCache(chave, diretorioCustomizado: diretorioCustomizado);
      if (cache == null) {
        throw Exception('Cache não encontrado');
      }

      final backup = {'chave': chave, 'data_exportacao': DateTime.now().toIso8601String(), 'cache': cache.toJson()};

      return jsonEncode(backup);
    } catch (e) {
      throw Exception('Erro ao exportar cache: $e');
    }
  }

  /// Importa cache de backup
  static Future<CacheModel> importarCache(String backupJson) async {
    try {
      final backup = jsonDecode(backupJson);
      final cache = CacheModel.fromJson(backup['cache']);

      return cache;
    } catch (e) {
      throw Exception('Erro ao importar cache: $e');
    }
  }

  /// Verifica integridade do cache
  static Future<bool> verificarIntegridade(String chave, {String? diretorioCustomizado}) async {
    try {
      final cache = await carregarCache(chave, diretorioCustomizado: diretorioCustomizado);
      if (cache == null) return false;

      // Verificar se os dados essenciais estão presentes
      if (cache.token.isEmpty) return false;
      if (cache.contratanteNumero.isEmpty) return false;
      if (cache.autorPedidoDadosNumero.isEmpty) return false;

      // Verificar se as datas são válidas
      if (cache.dataCriacao.isAfter(DateTime.now())) return false;
      if (cache.dataExpiracao.isBefore(cache.dataCriacao)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém configurações do cache
  static Future<Map<String, dynamic>> obterConfiguracoes({String? diretorioCustomizado}) async {
    try {
      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final arquivo = File('$diretorio/$_arquivoConfig');

      if (await arquivo.exists()) {
        final json = jsonDecode(await arquivo.readAsString());
        return json;
      }

      return {'diretorio_cache': diretorio, 'versao': '1.0.0', 'criado_em': DateTime.now().toIso8601String()};
    } catch (e) {
      return {'erro': e.toString(), 'diretorio_cache': obterDiretorioCache(diretorioCustomizado: diretorioCustomizado), 'versao': '1.0.0'};
    }
  }

  /// Salva configurações do cache
  static Future<void> salvarConfiguracoes(Map<String, dynamic> configuracoes, {String? diretorioCustomizado}) async {
    try {
      await criarDiretorioCache(diretorioCustomizado: diretorioCustomizado);

      final diretorio = obterDiretorioCache(diretorioCustomizado: diretorioCustomizado);
      final arquivo = File('$diretorio/$_arquivoConfig');

      await arquivo.writeAsString(jsonEncode(configuracoes));
    } catch (e) {
      throw Exception('Erro ao salvar configurações: $e');
    }
  }
}
