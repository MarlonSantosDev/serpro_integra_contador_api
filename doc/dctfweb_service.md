# Documentação do Serviço DCTFWeb

## Visão Geral

O serviço DCTFWeb permite a geração do Documento de Arrecadação de Receitas Federais (DARF) a partir da Declaração de Débitos e Créditos Tributários Federais Previdenciários e de Outras Entidades e Fundos (DCTFWeb).

## Métodos

### `gerarDarf(String cnpj, String periodoApuracao)`

Este método gera o DARF a partir da DCTFWeb.

**Parâmetros:**
- `cnpj`: O CNPJ da empresa.
- `periodoApuracao`: O período de apuração no formato YYYY-MM.

**Retorno:**
- Um objeto `DctfWebResponse` com o resultado da geração do DARF.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final dctfWebService = DctfWebService(apiClient);

  final response = await dctfWebService.gerarDarf('00000000000000', '2023-10');
  print(response);
}
```
