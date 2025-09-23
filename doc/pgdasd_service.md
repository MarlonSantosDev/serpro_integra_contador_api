# Documentação do Serviço PGDASD

## Visão Geral

O serviço PGDASD permite a declaração do Programa Gerador do Documento de Arrecadação do Simples Nacional - Declaratório.

## Métodos

### `declarar(String cnpj, String dados)`

Este método realiza a declaração do PGDASD.

**Parâmetros:**
- `cnpj`: O CNPJ da empresa.
- `dados`: Os dados da declaração em formato JSON.

**Retorno:**
- Um objeto `DeclararResponse` com o resultado da declaração.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final pgdasdService = PgdasdService(apiClient);

  final dadosDeclaracao = ''; // Preencha com os dados da declaração
  final response = await pgdasdService.declarar('00000000000000', dadosDeclaracao);
  print(response);
}
```
