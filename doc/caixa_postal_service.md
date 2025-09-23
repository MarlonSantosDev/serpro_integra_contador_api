# Documentação do Serviço da Caixa Postal

## Visão Geral

O serviço da Caixa Postal permite a consulta de mensagens na caixa postal do contribuinte.

## Métodos

### `consultarMensagens(String ni)`

Este método consulta as mensagens na caixa postal.

**Parâmetros:**
- `ni`: O número de identificação do contribuinte (CPF ou CNPJ).

**Retorno:**
- Um objeto `CaixaPostalResponse` com a lista de mensagens.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final caixaPostalService = CaixaPostalService(apiClient);

  final response = await caixaPostalService.consultarMensagens('00000000000');
  print(response);
}
```
