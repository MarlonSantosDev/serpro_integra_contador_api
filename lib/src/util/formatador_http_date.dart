/// Abstração multiplataforma para parse de HTTP date headers
///
/// Esta classe permite que o código funcione tanto em Web quanto em Desktop/Mobile,
/// usando imports condicionais para selecionar a implementação correta.
///
/// - Web: Usa implementação stub (parse manual)
/// - Desktop/Mobile: Usa dart:io HttpDate
library;

export 'formatador_http_date_stub.dart' if (dart.library.io) 'formatador_http_date_native.dart';
