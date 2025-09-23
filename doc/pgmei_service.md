# Documentação do Serviço PGMEI

## Visão Geral

O serviço PGMEI permite a geração do Documento de Arrecadação do Simples Nacional (DAS) para o Microempreendedor Individual (MEI).

## Métodos

### `gerarDas(String cnpj, String periodoApuracao)`

Este método gera o DAS para o MEI.

**Parâmetros:**
- `cnpj`: O CNPJ do MEI.
- `periodoApuracao`: O período de apuração no formato YYYY-MM.

**Retorno:**
- Um objeto `GerarDasResponse` com os dados do DAS gerado.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final pgmeiService = PgmeiService(apiClient);

  final response = await pgmeiService.gerarDas('00000000000000', '2023-10');
  print(response);
}
```
