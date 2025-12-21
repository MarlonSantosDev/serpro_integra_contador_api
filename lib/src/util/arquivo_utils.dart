/// Abstração multiplataforma para operações de arquivo
///
/// Esta classe permite que o código funcione tanto em Web quanto em Desktop/Mobile,
/// usando imports condicionais para selecionar a implementação correta.
///
/// - Web: Usa implementação stub (não suporta operações de arquivo)
/// - Desktop/Mobile: Usa dart:io para salvar arquivos no sistema de arquivos
library;

export 'arquivo_utils_stub.dart' if (dart.library.io) 'arquivo_utils_native.dart';
