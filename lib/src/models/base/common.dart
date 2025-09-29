/// Classes comuns utilizadas em todos os módulos da API SERPRO Integra Contador
///
/// Este diretório contém classes base que foram consolidadas para resolver
/// conflitos de nomes entre diferentes módulos, mantendo compatibilidade
/// através de extensões específicas para cada módulo.

// Classes base para mensagens
export 'mensagem_negocio.dart';
export 'mensagem.dart';

// Classes base para responses de parcelamento
export 'parcelamento_responses.dart';

// Classes base para erros e validações
export 'error_models.dart';

// Classes específicas para tipos de documento
export 'tipo_documento.dart';
