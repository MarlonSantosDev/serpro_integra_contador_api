/// Abstração multiplataforma para operações de I/O de arquivos
///
/// Esta classe permite que o código funcione tanto em Web quanto em Desktop/Mobile,
/// usando imports condicionais para selecionar a implementação correta.
///
/// - Web: Usa implementação stub (apenas certificadoBase64)
/// - Desktop/Mobile: Usa dart:io para leitura de arquivos e execução de processos
library;

export 'file_io_stub.dart' if (dart.library.io) 'file_io_native.dart';
