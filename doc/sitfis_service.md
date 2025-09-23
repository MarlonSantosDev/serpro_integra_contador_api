# Documentação do Serviço SITFIS

## Visão Geral

O serviço SITFIS permite a consulta da situação fiscal do contribuinte.

## Métodos

### `solicitarProtocolo(String ni)`

Este método solicita um protocolo para a consulta da situação fiscal.

**Parâmetros:**
- `ni`: O número de identificação do contribuinte (CPF ou CNPJ).

**Retorno:**
- Um objeto com o protocolo e o tempo de espera estimado.

### `emitirRelatorio(String ni, String protocolo)`

Este método emite o relatório da situação fiscal.

**Parâmetros:**
- `ni`: O número de identificação do contribuinte (CPF ou CNPJ).
- `protocolo`: O protocolo obtido no método `solicitarProtocolo`.

**Retorno:**
- Um objeto com o relatório em formato PDF (base64).

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final sitfisService = SitfisService(apiClient);

  // Solicitar Protocolo
  final protocoloResponse = await sitfisService.solicitarProtocolo('00000000000');
  final protocolo = protocoloResponse['dados']['protocoloRelatorio'];

  // Emitir Relatório
  final relatorioResponse = await sitfisService.emitirRelatorio('00000000000', protocolo);
  print(relatorioResponse);
}
```
