# Documentação do Serviço CCMEI

## Visão Geral

O serviço CCMEI permite a emissão e consulta de informações do Certificado da Condição de Microempreendedor Individual.

## Métodos

### `emitirCcmei(String cnpj)`

Este método emite o CCMEI para o CNPJ informado.

**Parâmetros:**
- `cnpj`: O CNPJ do MEI.

**Retorno:**
- Um objeto `EmitirCcmeiResponse` com os dados do CCMEI emitido.

### `consultarDadosCcmei(String cnpj)`

Este método consulta os dados do CCMEI para o CNPJ informado.

**Parâmetros:**
- `cnpj`: O CNPJ do MEI.

**Retorno:**
- Um objeto `ConsultarDadosCcmeiResponse` com os dados do CCMEI.

### `consultarSituacaoCadastral(String cpf)`

Este método consulta a situação cadastral do MEI a partir do CPF informado.

**Parâmetros:**
- `cpf`: O CPF do MEI.

**Retorno:**
- Um objeto com os dados da situação cadastral.

## Exemplo de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final apiClient = ApiClient();
  final ccmeiService = CcmeiService(apiClient);

  // Emitir CCMEI
  final emitirResponse = await ccmeiService.emitirCcmei('00000000000000');
  print(emitirResponse);

  // Consultar Dados CCMEI
  final consultarResponse = await ccmeiService.consultarDadosCcmei('00000000000000');
  print(consultarResponse);

  // Consultar Situação Cadastral
  final situacaoResponse = await ccmeiService.consultarSituacaoCadastral('00000000000');
  print(situacaoResponse);
}
```
