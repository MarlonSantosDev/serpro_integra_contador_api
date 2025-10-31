# Caixa Postal - Serviço de Mensagens da RFB

## Visão Geral

O serviço Caixa Postal permite consultar mensagens da Receita Federal do Brasil (RFB) para contribuintes. Este serviço disponibiliza **APENAS os 3 serviços oficiais da API SERPRO**, sem funções auxiliares ou wrappers que possam confundir o usuário.

## Serviços Disponíveis

Este package implementa exatamente os 3 serviços da API SERPRO:

1. **MSGCONTRIBUINTE61** - Obter Lista de Mensagens por Contribuintes
2. **MSGDETALHAMENTO62** - Obter Detalhes de uma Mensagem Específica
3. **INNOVAMSG63** - Obter Indicador de Novas Mensagens

## Importante: Processamento de Variáveis

A API SERPRO utiliza um sistema de variáveis nos campos de texto:

### Campo assuntoModelo

O campo `assuntoModelo` pode conter `++VARIAVEL++` que deve ser substituído pelo valor do campo `valorParametroAssunto`.

**Exemplo:**
- **assuntoModelo:** `"[IRPF] Declaração do exercício ++VARIAVEL++ processada"`
- **valorParametroAssunto:** `"2023"`
- **Resultado após processamento:** `"[IRPF] Declaração do exercício 2023 processada"`

### Campo corpoModelo

O campo `corpoModelo` pode conter `++1++`, `++2++`, `++3++`, etc. que devem ser substituídos pelos valores do array `variaveis`.

**Exemplo:**
- **corpoModelo:** `"Atendimento nº ++1++ do dia ++2++ foi direcionado"`
- **variaveis:** `["12345", "01/01/2023"]`
- **Resultado após processamento:** `"Atendimento nº 12345 do dia 01/01/2023 foi direcionado"`

**Nota:** Este package já realiza esse processamento automaticamente através dos getters `assuntoProcessado` e `corpoProcessado` nas classes de modelo.

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço Caixa Postal

### Autenticação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

final apiClient = ApiClient();
await apiClient.authenticate(
  'seu_consumer_key',
  'seu_consumer_secret',
  'caminho/para/certificado.p12',
  'senha_do_certificado',
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final caixaPostalService = CaixaPostalService(apiClient);
```

### 2. Obter Lista de Mensagens por Contribuinte

**Serviço API:** MSGCONTRIBUINTE61
**Endpoint:** /Consultar

```dart
try {
  final response = await caixaPostalService.obterListaMensagensPorContribuinte(
    '12345678000190',
    statusLeitura: 0, // 0=Todas, 1=Lida, 2=Não lida
    indicadorFavorito: null, // 0=Não favorita, 1=Favorita, null=Sem filtro
    indicadorPagina: 0, // 0=Página inicial, 1=Página não-inicial
    ponteiroPagina: null, // Necessário se indicadorPagina=1
  );

  if (response.dadosParsed != null) {
    final conteudo = response.dadosParsed!.conteudo.first;
    print('Quantidade de mensagens: ${conteudo.quantidadeMensagensInt}');
    print('É última página: ${conteudo.isUltimaPagina}');

    for (final mensagem in conteudo.listaMensagens) {
      print('ISN: ${mensagem.isn}');
      print('Assunto: ${mensagem.assuntoProcessado}'); // Já com ++VARIAVEL++ substituído
      print('Data de envio: ${mensagem.dataEnvio}');
      print('Foi lida: ${mensagem.foiLida}');
      print('É favorita: ${mensagem.isFavorita}');
    }
  }
} catch (e) {
  print('Erro: $e');
}
```

#### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| contribuinte | String | Sim | CPF/CNPJ do contribuinte |
| cnpjReferencia | String? | Não | CNPJ para filtro (apenas PJ) |
| statusLeitura | int | Não (padrão: 0) | 0=Todas, 1=Lida, 2=Não lida |
| indicadorFavorito | int? | Não | 0=Não favorita, 1=Favorita, null=Sem filtro |
| indicadorPagina | int | Não (padrão: 0) | 0=Página inicial, 1=Página não-inicial |
| ponteiroPagina | String? | Não | Ponteiro para página (necessário se indicadorPagina=1) |
| contratanteNumero | String? | Não | CNPJ do contratante |
| autorPedidoDadosNumero | String? | Não | CPF/CNPJ do autor do pedido |

### 3. Obter Detalhes de uma Mensagem Específica

**Serviço API:** MSGDETALHAMENTO62
**Endpoint:** /Consultar

```dart
try {
  final response = await caixaPostalService.obterDetalhesMensagemEspecifica(
    '12345678000190',
    '0001626772', // ISN da mensagem
  );

  if (response.dadosParsed != null) {
    final detalhe = response.dadosParsed!.conteudo.first;
    print('Assunto: ${detalhe.assuntoProcessado}'); // Já com ++VARIAVEL++ substituído
    print('Corpo: ${detalhe.corpoProcessado}'); // Já com ++1++, ++2++, etc. substituídos
    print('Data de envio: ${detalhe.dataEnvio}');
    print('Data de expiração: ${detalhe.dataExpiracao}');
    print('É favorita: ${detalhe.isFavorita}');

    // Variáveis usadas no corpo da mensagem
    if (detalhe.variaveis.isNotEmpty) {
      print('Variáveis:');
      for (var i = 0; i < detalhe.variaveis.length; i++) {
        print('  ++${i + 1}++: ${detalhe.variaveis[i]}');
      }
    }
  }
} catch (e) {
  print('Erro: $e');
}
```

#### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| contribuinte | String | Sim | CPF/CNPJ do contribuinte |
| isn | String | Sim | ISN da mensagem (obtido na lista de mensagens) |
| contratanteNumero | String? | Não | CNPJ do contratante |
| autorPedidoDadosNumero | String? | Não | CPF/CNPJ do autor do pedido |

### 4. Obter Indicador de Novas Mensagens

**Serviço API:** INNOVAMSG63
**Endpoint:** /Monitorar

```dart
try {
  final response = await caixaPostalService.obterIndicadorNovasMensagens(
    '12345678000190',
  );

  if (response.dadosParsed != null) {
    final conteudo = response.dadosParsed!.conteudo.first;
    print('Indicador: ${conteudo.indicadorMensagensNovas}');
    print('Status: ${conteudo.statusMensagensNovas}');
    print('Descrição: ${conteudo.descricaoStatus}');
    print('Tem mensagens novas: ${conteudo.temMensagensNovas}');
  }
} catch (e) {
  print('Erro: $e');
}
```

#### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| contribuinte | String | Sim | CPF/CNPJ do contribuinte |
| contratanteNumero | String? | Não | CNPJ do contratante |
| autorPedidoDadosNumero | String? | Não | CPF/CNPJ do autor do pedido |

#### Valores de Retorno

| Indicador | Descrição |
|-----------|-----------|
| 0 | Contribuinte não possui mensagens novas |
| 1 | Contribuinte possui uma mensagem nova |
| 2 | Contribuinte possui mensagens novas (múltiplas) |

## Estrutura de Dados

### ListaMensagensResponse

```dart
class ListaMensagensResponse {
  final int status;
  final String dados; // JSON raw
  final DadosListaMensagens? dadosParsed; // Dados parseados
}

class DadosListaMensagens {
  final String codigo; // Código de retorno (ex: "00")
  final List<ConteudoListaMensagens> conteudo;
}

class ConteudoListaMensagens {
  final String quantidadeMensagens;
  final String indicadorUltimaPagina; // "S" ou "N"
  final String ponteiroPaginaRetornada;
  final String ponteiroProximaPagina;
  final String? cnpjMatriz;
  final List<MensagemCaixaPostal> listaMensagens;

  // Getters úteis
  bool get isUltimaPagina; // true se indicadorUltimaPagina == "S"
  int get quantidadeMensagensInt; // quantidadeMensagens como int
}

class MensagemCaixaPostal {
  final String isn; // Identificador único
  final String assuntoModelo; // Com ++VARIAVEL++
  final String valorParametroAssunto; // Valor para substituir ++VARIAVEL++
  final String dataEnvio; // Formato: AAAAMMDD
  final String horaEnvio; // Formato: HHMMSS
  final String indicadorLeitura; // "0" ou "1"
  final String indicadorFavorito; // "0" ou "1"
  final String relevancia; // "1" ou "2"
  final String descricaoOrigem;
  // ... outros campos

  // Getters úteis
  bool get foiLida; // true se indicadorLeitura == "1"
  bool get isFavorita; // true se indicadorFavorito == "1"
  String get assuntoProcessado; // assuntoModelo com ++VARIAVEL++ substituído
}
```

### DetalhesMensagemResponse

```dart
class DetalhesMensagemResponse {
  final int status;
  final String dados; // JSON raw
  final DadosDetalhesMensagem? dadosParsed; // Dados parseados
}

class DadosDetalhesMensagem {
  final String codigo; // Código de retorno (ex: "00")
  final List<DetalheMensagemCompleta> conteudo;
}

class DetalheMensagemCompleta {
  final String isn;
  final String assuntoModelo; // Com ++VARIAVEL++
  final String valorParametroAssunto; // Valor para substituir ++VARIAVEL++
  final String corpoModelo; // Com ++1++, ++2++, etc.
  final List<String> variaveis; // Valores para substituir ++1++, ++2++, etc.
  final String dataEnvio;
  final String dataExpiracao;
  final String? indFavorito;
  // ... outros campos

  // Getters úteis
  bool get isFavorita; // true se indFavorito == "1"
  String get assuntoProcessado; // assuntoModelo com ++VARIAVEL++ substituído
  String get corpoProcessado; // corpoModelo com ++1++, ++2++, etc. substituídos
}
```

### IndicadorMensagensResponse

```dart
class IndicadorMensagensResponse {
  final int status;
  final String dados; // JSON raw
  final DadosIndicadorMensagens? dadosParsed; // Dados parseados
}

class DadosIndicadorMensagens {
  final String codigo; // Código de retorno (ex: "00")
  final List<ConteudoIndicador> conteudo;
}

class ConteudoIndicador {
  final String indicadorMensagensNovas; // "0", "1" ou "2"
  final String statusMensagensNovas;
  final String descricaoStatus;

  // Getters úteis
  bool get temMensagensNovas; // true se indicadorMensagensNovas != "0"
}
```

## Exemplo Completo - Workflow de Uso

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Autenticar
  final apiClient = ApiClient();
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret',
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );

  // 2. Criar serviço
  final caixaPostalService = CaixaPostalService(apiClient);
  final contribuinte = '12345678000190';

  try {
    // 3. Verificar se há mensagens novas
    final indicadorResponse = await caixaPostalService.obterIndicadorNovasMensagens(contribuinte);

    if (indicadorResponse.dadosParsed != null) {
      final indicador = indicadorResponse.dadosParsed!.conteudo.first;

      if (indicador.temMensagensNovas) {
        print('Há mensagens novas!');

        // 4. Listar mensagens não lidas
        final listaMensagensResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
          contribuinte,
          statusLeitura: 2, // Apenas não lidas
        );

        if (listaMensagensResponse.dadosParsed != null) {
          final conteudo = listaMensagensResponse.dadosParsed!.conteudo.first;
          print('Mensagens não lidas: ${conteudo.quantidadeMensagensInt}');

          // 5. Obter detalhes de cada mensagem
          for (final mensagem in conteudo.listaMensagens) {
            print('\n--- Mensagem ISN: ${mensagem.isn} ---');
            print('Assunto: ${mensagem.assuntoProcessado}');

            final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica(
              contribuinte,
              mensagem.isn,
            );

            if (detalhesResponse.dadosParsed != null) {
              final detalhe = detalhesResponse.dadosParsed!.conteudo.first;
              print('Corpo: ${detalhe.corpoProcessado}');
              print('Data de expiração: ${detalhe.dataExpiracao}');
            }
          }

          // 6. Paginação (se necessário)
          if (!conteudo.isUltimaPagina) {
            print('\nCarregando próxima página...');
            final proximaPaginaResponse = await caixaPostalService.obterListaMensagensPorContribuinte(
              contribuinte,
              statusLeitura: 2,
              indicadorPagina: 1,
              ponteiroPagina: conteudo.ponteiroProximaPagina,
            );
            // ... processar próxima página
          }
        }
      } else {
        print('Não há mensagens novas');
      }
    }
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste
const cnpjTeste = '99999999999999'; // CNPJ
const cpfTeste = '99999999999'; // CPF

// ISN de teste (exemplo da documentação)
const isnTeste = '0001626772';

// Ponteiro de teste
const ponteiroTeste = '20250408092949';
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 00 | Sucesso | - |
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CPF/CNPJ inválido | Verificar formato do documento |
| 003 | ISN inválido | Verificar se ISN existe |
| 004 | Ponteiro inválido | Verificar formato do ponteiro de paginação |
| 005 | Contribuinte não encontrado | Verificar se contribuinte está cadastrado |

## Observações Importantes

1. **Sem Funções Auxiliares**: Este serviço implementa APENAS as 3 funções oficiais da API SERPRO. Não há wrappers como `listarMensagensNaoLidas()` ou `temMensagensNovas()` que possam confundir o usuário.

2. **Processamento de Variáveis**: O processamento de `++VARIAVEL++` e `++N++` é feito automaticamente pelos getters `assuntoProcessado` e `corpoProcessado`. Você não precisa fazer esse processamento manualmente.

3. **Paginação**: Para listar todas as mensagens, use `indicadorPagina=0` na primeira chamada. Se houver mais páginas (`isUltimaPagina=false`), use `indicadorPagina=1` e passe o `ponteiroProximaPagina` retornado.

4. **Filtros**: Os filtros `statusLeitura` e `indicadorFavorito` são parâmetros da própria API SERPRO, não são funcionalidades adicionais do package.

5. **Certificado Digital**: Sempre requer certificado digital válido para autenticação.

## Suporte

Para dúvidas sobre o serviço Caixa Postal:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
