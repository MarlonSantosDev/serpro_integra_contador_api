# Documentação do Serviço DTE

## Visão Geral

O serviço DTE (Domicílio Tributário Eletrônico) permite a consulta de informações do DTE.

## Métodos

### `declarar(String cnpj, String dados)`

Este método realiza uma declaração no DTE.

**Parâmetros:**
- `cnpj`: O CNPJ da empresa.
- `dados`: Os dados da declaração em formato JSON.

**Retorno:**
- Um objeto `DteResponse` com o resultado da declaração.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final dteService = DteService(apiClient);

  final dadosDeclaracao = ''; // Preencha com os dados da declaração
  final response = await dteService.declarar('00000000000000', dadosDeclaracao);
  print(response);
}
```
