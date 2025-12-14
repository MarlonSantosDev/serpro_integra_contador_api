/// Platform-specific HTTP Client Adapter with mTLS support
///
/// Este arquivo usa conditional exports para selecionar automaticamente
/// a implementação correta baseada na plataforma em compile-time:
///
/// - **Desktop/Mobile** (dart:io disponível) → http_client_adapter_io.dart
///   Usa SecurityContext nativo para mTLS
///
/// - **Web** (dart:html disponível) → http_client_adapter_web.dart
///   Usa package:http, requer Cloud Function para mTLS
///
/// O compilador escolhe automaticamente - sem if/else em runtime.

export 'http_client_adapter_stub.dart'
    if (dart.library.io) 'http_client_adapter_io.dart'
    if (dart.library.html) 'http_client_adapter_web.dart';
