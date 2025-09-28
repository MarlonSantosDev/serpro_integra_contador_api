# SERPRO Integra Contador API - Dart Package

Package Dart para integração completa com a API do SERPRO Integra Contador, fornecendo uma interface type-safe para todos os serviços disponíveis.

## 🚀 Características Principais

- **Autenticação automática** com certificados cliente (mTLS)
- **Cache inteligente** de tokens de procurador
- **Validação automática** de documentos (CPF/CNPJ)
- **Tratamento de erros** padronizado
- **Suporte completo** a procurações eletrônicas
- **Modelos de dados** type-safe para todas as operações
- **Flexibilidade de contratante e autor do pedido**: Todos os serviços suportam parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero` para permitir diferentes contextos de uso em uma única requisição

## 📋 Serviços Disponíveis

- **CCMEI**: Cadastro Centralizado de Microempreendedor Individual
- **PGDASD**: Pagamento de DAS por Débito Direto Autorizado
- **PGMEI**: Pagamento de DAS do MEI
- **DCTFWeb**: Declaração de Débitos e Créditos Tributários Federais
- **DEFIS**: Declaração de Informações Socioeconômicas e Fiscais
- **Parcelamentos**: PARCMEI, PARCSN, PERTMEI, PERTSN, RELPMEI, RELPSN
- **SITFIS**: Sistema de Informações Tributárias Fiscais
- **SICALC**: Sistema de Cálculo de Impostos
- **MIT**: Manifesto de Importação de Trânsito
- **Eventos de Atualização**: Consulta de eventos de atualização
- **Procurações**: Gestão de procurações eletrônicas
- **Caixa Postal**: Consulta de mensagens da Receita Federal
- **DTE**: Domicílio Tributário Eletrônico

## 🔧 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  serpro_integra_contador_api: ^1.0.0
```

## 💡 Uso Básico

### Autenticação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // Inicializar cliente da API
  final apiClient = ApiClient();

  // Autenticar com certificados
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    contratanteNumero: '12345678000100',
    autorPedidoDadosNumero: '12345678000100',
  );
}
```

### Usando Serviços com Valores Padrão

```dart
// Usar valores padrão da autenticação
final ccmeiService = CcmeiService(apiClient);
final response = await ccmeiService.emitirCcmei('12345678000100');
print('CCMEI emitido: ${response.dados.pdf.isNotEmpty}');
```

### Usando Serviços com Valores Específicos

```dart
// Usar valores específicos para esta requisição
final sicalcService = SicalcService(apiClient);
final darfResponse = await sicalcService.consolidarEGerarDarf(
  contribuinteNumero: '12345678000100',
  contratanteNumero: '98765432000100', // Valor específico
  autorPedidoDadosNumero: '11122233344', // Valor específico
  uf: 'SP',
  municipio: 3550308,
  codigoReceita: 190,
  codigoReceitaExtensao: 1,
  dataPA: '2024-01',
  vencimento: '2024-02-15',
  valorImposto: 1000.00,
  dataConsolidacao: '2024-01-15',
);
```

## 🔄 Flexibilidade de Contratante e Autor do Pedido

Todos os serviços da biblioteca suportam parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero`. Isso permite:

### Cenários de Uso

1. **Valores Padrão**: Quando não especificados, usa os valores definidos na autenticação
2. **Valores Específicos**: Permite usar diferentes contratantes ou autores para requisições específicas
3. **Contextos Múltiplos**: Ideal para sistemas que atendem múltiplos clientes ou contextos

### Exemplos Práticos

```dart
// Consulta DTE com valores padrão
final dteService = DteService(apiClient);
final dteResponse = await dteService.obterIndicadorDte('12345678000100');

// Consulta DTE com contratante específico
final dteResponse2 = await dteService.obterIndicadorDte(
  '12345678000100',
  contratanteNumero: '98765432000100',
  autorPedidoDadosNumero: '11122233344',
);

// Caixa Postal com autor específico
final caixaPostalService = CaixaPostalService(apiClient);
final mensagens = await caixaPostalService.listarTodasMensagens(
  '12345678000100',
  contratanteNumero: '98765432000100',
);
```

## 📚 Documentação Completa

Para documentação completa de todos os serviços e métodos disponíveis, consulte a documentação da API do SERPRO Integra Contador.

## ⚠️ Importante

- A autenticação real requer certificados cliente (mTLS) que não são suportados nativamente pelo pacote http do Dart
- Para produção, será necessário implementar suporte nativo ou usar pacotes específicos como `flutter_client_ssl`
- Esta implementação inclui valores de exemplo para desenvolvimento e testes

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request para sugerir melhorias.

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.