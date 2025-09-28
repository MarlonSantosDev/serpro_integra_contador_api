# Caixa Postal - Consulta de Mensagens da RFB

## Visão Geral

O serviço Caixa Postal permite consultar mensagens da Receita Federal do Brasil (RFB) para contribuintes, incluindo lista de mensagens, detalhes de mensagens específicas e indicadores de mensagens novas.

## Funcionalidades

- **Listar Mensagens**: Consulta de mensagens da caixa postal por contribuinte
- **Detalhar Mensagem**: Consulta de detalhes de uma mensagem específica
- **Indicador de Mensagens Novas**: Verificação de mensagens novas disponíveis
- **Filtros Avançados**: Filtros por status de leitura, favoritas e paginação

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

### 2. Listar Todas as Mensagens

```dart
try {
  final response = await caixaPostalService.listarTodasMensagens('00000000000000');
  
  if (response.sucesso) {
    print('Mensagens encontradas: ${response.dadosParsed?.mensagens.length ?? 0}');
    
    for (final mensagem in response.dadosParsed?.mensagens ?? []) {
      print('Assunto: ${mensagem.assunto}');
      print('Data: ${mensagem.dataEnvio}');
      print('Status: ${mensagem.statusLeitura}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao listar mensagens: $e');
}
```

### 3. Listar Apenas Mensagens Não Lidas

```dart
try {
  final response = await caixaPostalService.listarMensagensNaoLidas('00000000000000');
  
  if (response.sucesso) {
    print('Mensagens não lidas: ${response.dadosParsed?.mensagens.length ?? 0}');
  }
} catch (e) {
  print('Erro ao listar mensagens não lidas: $e');
}
```

### 4. Listar Apenas Mensagens Lidas

```dart
try {
  final response = await caixaPostalService.listarMensagensLidas('00000000000000');
  
  if (response.sucesso) {
    print('Mensagens lidas: ${response.dadosParsed?.mensagens.length ?? 0}');
  }
} catch (e) {
  print('Erro ao listar mensagens lidas: $e');
}
```

### 5. Listar Mensagens Favoritas

```dart
try {
  final response = await caixaPostalService.listarMensagensFavoritas('00000000000000');
  
  if (response.sucesso) {
    print('Mensagens favoritas: ${response.dadosParsed?.mensagens.length ?? 0}');
  }
} catch (e) {
  print('Erro ao listar mensagens favoritas: $e');
}
```

### 6. Consultar Detalhes de Mensagem Específica

```dart
try {
  final response = await caixaPostalService.obterDetalhesMensagemEspecifica(
    '00000000000000',
    '123456789', // ISN da mensagem
  );
  
  if (response.sucesso) {
    print('Detalhes da mensagem encontrados!');
    print('Assunto: ${response.dadosParsed?.assunto}');
    print('Conteúdo: ${response.dadosParsed?.conteudo}');
    print('Data de envio: ${response.dadosParsed?.dataEnvio}');
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao obter detalhes: $e');
}
```

### 7. Verificar Indicador de Mensagens Novas

```dart
try {
  final response = await caixaPostalService.obterIndicadorNovasMensagens('00000000000000');
  
  if (response.sucesso) {
    final indicador = response.dadosParsed?.conteudo.first.temMensagensNovas ?? false;
    if (indicador) {
      print('Há mensagens novas disponíveis!');
    } else {
      print('Não há mensagens novas');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao verificar indicador: $e');
}
```

### 8. Listar Mensagens com Paginação

```dart
try {
  final response = await caixaPostalService.listarMensagensComPaginacao(
    '00000000000000',
    ponteiroPagina: '20240101000000', // Ponteiro da página anterior
    statusLeitura: 0, // Todas as mensagens
    indicadorFavorito: null, // Sem filtro de favoritas
  );
  
  if (response.sucesso) {
    print('Página de mensagens carregada: ${response.dadosParsed?.mensagens.length ?? 0}');
  }
} catch (e) {
  print('Erro ao listar com paginação: $e');
}
```

### 9. Verificar se Há Mensagens Novas (Método de Conveniência)

```dart
try {
  final temNovas = await caixaPostalService.temMensagensNovas('00000000000000');
  
  if (temNovas) {
    print('Há mensagens novas!');
  } else {
    print('Não há mensagens novas');
  }
} catch (e) {
  print('Erro ao verificar mensagens novas: $e');
}
```

## Estrutura de Dados

### ListaMensagensResponse

```dart
class ListaMensagensResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ListaMensagensDados? dadosParsed;
}

class ListaMensagensDados {
  final List<MensagemNegocio> mensagens;
  final String? ponteiroProximaPagina;
  // ... outros campos
}

class MensagemNegocio {
  final String isn;
  final String assunto;
  final String dataEnvio;
  final String statusLeitura;
  final bool favorita;
  // ... outros campos
}
```

### DetalhesMensagemResponse

```dart
class DetalhesMensagemResponse {
  final bool sucesso;
  final String? mensagemErro;
  final DetalhesMensagemDados? dadosParsed;
}

class DetalhesMensagemDados {
  final String isn;
  final String assunto;
  final String conteudo;
  final String dataEnvio;
  final String statusLeitura;
  // ... outros campos
}
```

### IndicadorMensagensResponse

```dart
class IndicadorMensagensResponse {
  final bool sucesso;
  final String? mensagemErro;
  final IndicadorMensagensDados? dadosParsed;
}

class IndicadorMensagensDados {
  final List<IndicadorConteudo> conteudo;
}

class IndicadorConteudo {
  final bool temMensagensNovas;
  // ... outros campos
}
```

## Parâmetros de Filtro

### Status de Leitura

- `0`: Não se aplica (todas as mensagens)
- `1`: Lida
- `2`: Não lida

### Indicador de Favorita

- `0`: Não favorita
- `1`: Favorita
- `null`: Sem filtro

### Indicador de Página

- `0`: Página inicial (mais recentes)
- `1`: Página não-inicial (requer ponteiro)

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ/CPF inválido | Verificar formato do documento |
| 003 | ISN inválido | Verificar se ISN existe |
| 004 | Ponteiro inválido | Verificar formato do ponteiro de paginação |
| 005 | Contribuinte não encontrado | Verificar se contribuinte está cadastrado |

## Exemplos Práticos

### Exemplo Completo - Consultar Mensagens

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret', 
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );
  
  // 2. Criar serviço
  final caixaPostalService = CaixaPostalService(apiClient);
  
  // 3. Verificar se há mensagens novas
  try {
    final temNovas = await caixaPostalService.temMensagensNovas('00000000000000');
    
    if (temNovas) {
      print('Há mensagens novas!');
      
      // 4. Listar mensagens não lidas
      final mensagensResponse = await caixaPostalService.listarMensagensNaoLidas('00000000000000');
      
      if (mensagensResponse.sucesso) {
        print('Mensagens não lidas: ${mensagensResponse.dadosParsed?.mensagens.length ?? 0}');
        
        // 5. Obter detalhes da primeira mensagem
        final mensagens = mensagensResponse.dadosParsed?.mensagens ?? [];
        if (mensagens.isNotEmpty) {
          final primeiraMensagem = mensagens.first;
          final detalhesResponse = await caixaPostalService.obterDetalhesMensagemEspecifica(
            '00000000000000',
            primeiraMensagem.isn,
          );
          
          if (detalhesResponse.sucesso) {
            print('Detalhes da mensagem:');
            print('Assunto: ${detalhesResponse.dadosParsed?.assunto}');
            print('Conteúdo: ${detalhesResponse.dadosParsed?.conteudo}');
            print('Data: ${detalhesResponse.dadosParsed?.dataEnvio}');
          }
        }
      }
    } else {
      print('Não há mensagens novas');
    }
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Listar Mensagens com Filtros

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    'seu_consumer_key',
    'seu_consumer_secret', 
    'caminho/para/certificado.p12',
    'senha_do_certificado',
  );
  
  // 2. Criar serviço
  final caixaPostalService = CaixaPostalService(apiClient);
  
  // 3. Listar mensagens com filtros específicos
  try {
    final response = await caixaPostalService.obterListaMensagensPorContribuinte(
      '00000000000000',
      cnpjReferencia: '00000000000000', // Filtro por CNPJ
      statusLeitura: 2, // Apenas não lidas
      indicadorFavorito: 1, // Apenas favoritas
      indicadorPagina: 0, // Página inicial
    );
    
    if (response.sucesso) {
      print('Mensagens filtradas: ${response.dadosParsed?.mensagens.length ?? 0}');
      
      for (final mensagem in response.dadosParsed?.mensagens ?? []) {
        print('Assunto: ${mensagem.assunto}');
        print('Data: ${mensagem.dataEnvio}');
        print('Favorita: ${mensagem.favorita}');
      }
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro ao listar mensagens: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// ISN de teste
const isnTeste = '123456789';

// Ponteiro de teste
const ponteiroTeste = '20240101000000';
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **Paginação**: Limite de mensagens por página

## Suporte

Para dúvidas sobre o serviço Caixa Postal:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
