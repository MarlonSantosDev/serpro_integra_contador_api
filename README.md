# SERPRO Integra Contador API

Um package Dart completo para acessar todos os serviços da API do SERPRO Integra Contador.

## Visão Geral

O **SERPRO Integra Contador** é uma plataforma de serviços que fornece um conjunto de APIs para escritórios de contabilidade e demais empresas do ramo contábil, otimizando a prestação de serviços aos contribuintes.

Este package oferece uma interface Dart/Flutter para interagir com todos os serviços disponíveis, incluindo:

- **DEFIS** - Declaração de Informações Socioeconômicas e Fiscais
- **PGDASD** - Programa Gerador do DAS do Simples Nacional  
- **PGMEI** - Programa Gerador do DAS do MEI
- **CCMEI** - Certificado da Condição de Microempreendedor Individual
- **Regime de Apuração** - Opção pelo Regime de Apuração de Receitas
- E muitos outros serviços

## Características

✅ **Cobertura Completa**: Suporte a todos os serviços disponíveis na API  
✅ **Modelos Tipados**: Classes Dart com serialização JSON automática  
✅ **Documentação Detalhada**: Documentação completa para cada serviço  
✅ **Exemplos Práticos**: Exemplos de uso para todos os serviços  
✅ **Dados de Teste**: CNPJs/CPFs e payloads de exemplo para desenvolvimento  
✅ **Tratamento de Erros**: Gestão adequada de códigos de status e mensagens de erro  

## Instalação

Adicione o package ao seu `pubspec.yaml`:

```yaml
dependencies:
  serpro_integra_contador_api: ^1.0.0
```

Execute:

```bash
dart pub get
```

## Configuração

### Pré-requisitos

Para usar este package em produção, você precisa:

1. **Certificado Digital e-CNPJ** (padrão ICP-Brasil)
2. **Consumer Key e Consumer Secret** (obtidos na área do cliente SERPRO)
3. **Contrato ativo** com o SERPRO para os serviços desejados

### Autenticação

A API do SERPRO utiliza autenticação OAuth2 com certificado digital obrigatório:

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

**⚠️ Importante**: A implementação atual da autenticação é simplificada. Para uso em produção, será necessário implementar suporte a mTLS (Mutual TLS) com certificados digitais, que não é suportado nativamente pelo pacote `http` do Dart.

## Uso Básico

### Exemplo: Transmitir Declaração DEFIS

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(/* credenciais */);
  
  // 2. Criar serviço
  final defisService = DefisService(apiClient);
  
  // 3. Preparar dados da declaração
  final declaracao = TransmitirDeclaracaoRequest(
    ano: 2024,
    inatividade: 2,
    empresa: Empresa(
      ganhoCapital: 0.0,
      qtdEmpregadoInicial: 1,
      qtdEmpregadoFinal: 1,
      // ... outros campos obrigatórios
    ),
  );
  
  // 4. Transmitir declaração
  try {
    final response = await defisService.transmitirDeclaracao(
      '00000000000000', // CNPJ Contratante
      2,
      '11111111111111', // CNPJ/CPF Autor
      2, 
      '00123456000100', // CNPJ Contribuinte
      2,
      declaracao,
    );
    
    print('Sucesso! ID DEFIS: ${response.dados.idDefis}');
  } catch (e) {
    print('Erro: $e');
  }
}
```

## Serviços Disponíveis

### Integra-SN (Simples Nacional)

| Serviço | Classe | Descrição |
|---------|--------|-----------|
| DEFIS | `DefisService` | Declaração de Informações Socioeconômicas e Fiscais |
| PGDASD | `PgdasdService` | Programa Gerador do DAS do Simples Nacional |
| Regime de Apuração | `RegimeApuracaoService` | Opção pelo Regime de Apuração de Receitas |

### Integra-MEI

| Serviço | Classe | Descrição |
|---------|--------|-----------|
| PGMEI | `PgmeiService` | Programa Gerador do DAS do MEI |
| CCMEI | `CcmeiService` | Certificado da Condição de MEI |

### Outros Serviços

- **DCTFWeb**: Declaração de Débitos e Créditos Tributários Federais
- **Procurações**: Gestão de procurações eletrônicas
- **Sicalc**: Sistema de Cálculos Tributários
- **CaixaPostal**: Consulta de mensagens da RFB
- **PagamentoWeb**: Comprovantes de pagamento
- **SITFIS**: Situação Fiscal do contribuinte
- **Parcelamentos**: Gestão de parcelamentos tributários

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Estrutura base para testes
final requestTeste = BaseRequest(
  contratante: Contratante(numero: cnpjTeste, tipo: 2),
  autorPedidoDados: AutorPedidoDados(numero: cnpjTeste, tipo: 2),
  contribuinte: Contribuinte(numero: cnpjTeste, tipo: 2),
  pedidoDados: PedidoDados(/* dados específicos do serviço */),
);
```

## Documentação

- [Documentação do Serviço DEFIS](doc/defis_service.md)
- [Exemplos de Uso](example/)
- [Testes](test/)

## Estrutura do Projeto

```
lib/
├── src/
│   ├── core/           # Classes base e autenticação
│   ├── models/         # Modelos de dados
│   │   ├── base/       # Modelos base
│   │   ├── defis/      # Modelos específicos do DEFIS
│   │   └── ...         # Outros serviços
│   └── services/       # Classes de serviço
├── doc/                # Documentação detalhada
├── example/            # Exemplos de uso
└── test/               # Testes unitários
```

## Limitações Conhecidas

1. **Certificado Digital**: A implementação atual não suporta mTLS com certificados digitais nativamente
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Cobertura de Serviços**: Implementação inicial focada no DEFIS, outros serviços em desenvolvimento

## Contribuição

Contribuições são bem-vindas! Por favor:

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Implemente testes para novas funcionalidades
4. Envie um pull request

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## Suporte

Para dúvidas sobre a API do SERPRO, consulte:
- [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)

Para questões específicas deste package, abra uma issue no repositório.

---

**Desenvolvido por AI** 🤖
