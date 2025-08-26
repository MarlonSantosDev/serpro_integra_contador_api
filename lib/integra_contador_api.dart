/// Biblioteca Dart para integração com a API Integra Contador do SERPRO
/// 
/// Esta biblioteca fornece uma interface completa e type-safe para interagir
/// com todos os serviços da API Integra Contador, incluindo consultas,
/// declarações, emissões e monitoramento.
/// 
/// Exemplo de uso básico:
/// ```dart
/// import 'package:integra_contador_api/integra_contador_api.dart';
/// 
/// final service = IntegraContadorServiceBuilder()
///     .withJwtToken('seu_token_jwt')
///     .withTimeout(Duration(seconds: 30))
///     .build();
/// 
/// final result = await service.consultarSituacaoFiscal(
///   documento: '12345678901',
///   anoBase: '2024',
/// );
/// 
/// if (result.isSuccess) {
///   print('Situação fiscal: ${result.data?.situacaoFiscal}');
/// } else {
///   print('Erro: ${result.error?.message}');
/// }
/// ```
library integra_contador_api;

// Modelos de dados
export 'models/dados_entrada.dart';
export 'models/dados_saida.dart';
export 'models/identificacao.dart';
export 'models/pedido_dados.dart';
export 'models/problem_details.dart';
export 'models/tipo_ni.dart';

// Serviços
export 'services/integra_contador_service.dart';
export 'services/integra_contador_helper.dart';
export 'services/integra_contador_extended_service.dart';
export 'services/integra_contador_builder.dart';

// Exceções
export 'exceptions/api_exception.dart';

