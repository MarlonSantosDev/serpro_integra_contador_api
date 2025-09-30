/// Modelo de dados para consultar anos calendários com opções de regime
///
/// Representa os dados necessários para consultar todas as opções de regime
/// através do serviço CONSULTARANOSCALENDARIOS102
///
/// Este serviço não requer parâmetros de entrada no campo dados.
/// Serão consultados todos os anos calendários com opções efetivadas.
class ConsultarAnosCalendariosRequest {
  /// Construtor vazio pois este serviço não requer parâmetros
  const ConsultarAnosCalendariosRequest();

  /// Este serviço sempre é válido pois não tem parâmetros obrigatórios
  bool get isValid => true;

  /// Retorna string vazia conforme especificação da documentação
  Map<String, dynamic> toJson() {
    return {};
  }

  factory ConsultarAnosCalendariosRequest.fromJson(Map<String, dynamic> json) {
    return const ConsultarAnosCalendariosRequest();
  }

  /// Instância singleton para reutilização
  static const ConsultarAnosCalendariosRequest instance = ConsultarAnosCalendariosRequest();
}
