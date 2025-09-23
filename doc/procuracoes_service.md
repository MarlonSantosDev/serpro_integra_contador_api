# Documentação do Serviço de Procurações

## Visão Geral

O serviço de Procurações permite a consulta de procurações eletrônicas.

## Métodos

### `obterProcuracao(String cnpj)`

Este método obtém as procurações para o CNPJ informado.

**Parâmetros:**
- `cnpj`: O CNPJ do outorgante ou outorgado.

**Retorno:**
- Um objeto `ProcuracoesResponse` com a lista de procurações.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final procuracoesService = ProcuracoesService(apiClient);

  final response = await procuracoesService.obterProcuracao('00000000000000');
  print(response);
}
```
