# SERPRO Integra Contador - Exemplos Dart

Este diretório contém exemplos completos em Dart puro demonstrando como usar todos os serviços disponíveis no pacote `serpro_integra_contador_api`.

## 🚀 Características

- ✅ Exemplos de todos os 23 serviços disponíveis
- ✅ Arquivos separados por serviço para fácil navegação
- ✅ Exemplos de autenticação (Trial e Produção)
- ✅ Testes adicionais em `my_test/`
- ✅ Suporte completo para certificados digitais
- ✅ Ideal para aplicações CLI, scripts e integrações backend

## 📋 Serviços Disponíveis

Todos os exemplos estão organizados no diretório `src/`:

### Serviços MEI
- **CCMEI**: Certificado da Condição de Microempreendedor Individual
- **PGMEI**: Pagamento de DAS do MEI
- **PARCMEI**: Parcelamento do MEI
- **PARCMEI Especial**: Parcelamento Especial do MEI
- **PERTMEI**: Pertinência do MEI
- **RELPMEI**: Relatório de Pagamentos do MEI

### Serviços Simples Nacional
- **PARCSN**: Parcelamento do Simples Nacional
- **PARCSN Especial**: Parcelamento Especial do Simples Nacional
- **PERTSN**: Pertinência do Simples Nacional
- **RELPSN**: Relatório de Pagamentos do Simples Nacional

### Serviços Tributários
- **DCTFWeb**: Declaração de Débitos e Créditos Tributários Federais
- **DEFIS**: Declaração de Informações Socioeconômicas e Fiscais
- **SITFIS**: Sistema de Informações Tributárias Fiscais
- **SICALC**: Sistema de Cálculo de Impostos
- **PGDASD**: Pagamento de DAS por Débito Direto Autorizado
- **MIT**: Módulo de Inclusão de Tributos

### Serviços de Comunicação
- **Caixa Postal**: Consulta de mensagens da Receita Federal
- **Eventos de Atualização**: Monitoramento de atualizações em sistemas

### Serviços Especiais
- **DTE**: Domicílio Tributário Eletrônico
- **PagtoWeb**: Consulta de pagamentos e emissão de comprovantes
- **Procurações**: Gestão de procurações eletrônicas
- **Autentica Procurador**: Gestão de autenticação de procuradores
- **Regime Apuração**: Gestão do regime de apuração do Simples Nacional

## 🛠️ Como Usar

### 1. Executar o Exemplo Principal

O arquivo `main.dart` executa todos os serviços em sequência:

```bash
cd example/dart
dart run main.dart
```

### 2. Executar um Serviço Específico

Para executar um exemplo de um serviço específico:

```bash
cd example/dart
dart run src/ccmei.dart
dart run src/pgmei.dart
# etc...
```

### 3. Configurar Credenciais

Antes de executar, edite o arquivo `main.dart` e configure suas credenciais:

```dart
await apiClient.authenticate(
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret',
  certificadoDigitalPath: 'caminho/para/certificado.pfx',
  senhaCertificado: 'senha_do_certificado',
  contratanteNumero: '99999999999999', // CNPJ da empresa contratante
  autorPedidoDadosNumero: '99999999999999', // CPF/CNPJ do autor
);
```

### 4. Valores Padrão para Trial

Para facilitar os testes em ambiente Trial, você pode usar:

- **Consumer Key**: `06aef429-a981-3ec5-a1f8-71d38d86481e`
- **Consumer Secret**: `06aef429-a981-3ec5-a1f8-71d38d86481e`
- **CNPJ Contratante**: `00000000000191`
- **CPF Autor do Pedido**: `00000000191`

## 📁 Estrutura do Projeto

```
example/dart/
├── main.dart                    # Exemplo principal executando todos os serviços
├── src/                         # Exemplos individuais por serviço
│   ├── authenticate.dart        # Exemplo de autenticação
│   ├── autentica_procurador.dart
│   ├── caixa_postal.dart
│   ├── ccmei.dart
│   ├── dctf_web.dart
│   ├── defis.dart
│   ├── dte.dart
│   ├── eventos_atualizacao.dart
│   ├── mit.dart
│   ├── pagto_web.dart
│   ├── parcmei.dart
│   ├── parcmei_especial.dart
│   ├── parcsn.dart
│   ├── parcsn_especial.dart
│   ├── pertmei.dart
│   ├── pertsn.dart
│   ├── pgdasd.dart
│   ├── pgmei.dart
│   ├── procuracoes.dart
│   ├── regime.dart
│   ├── relpmei.dart
│   ├── relpsn.dart
│   ├── sicalc.dart
│   ├── sitfis.dart
│   └── import.dart              # Exportações de todos os exemplos
├── my_test/                     # Testes e exemplos adicionais
│   ├── pgdas.dart
│   ├── pgdas2.dart
│   ├── teste.dart
│   └── teste2.dart
└── arquivos/                    # Arquivos gerados (PDFs, etc.)
    └── pdf/
```

## 📝 Notas

- Os exemplos são executáveis independentemente
- Cada arquivo em `src/` demonstra o uso de um serviço específico
- Os arquivos em `my_test/` contêm testes e variações adicionais
- Certifique-se de ter o certificado digital configurado para ambiente de produção
- Para ambiente Trial, o certificado pode não ser necessário dependendo do serviço

## 🔗 Referências

- [Exemplo Flutter](../flutter/README.md) - Aplicação Flutter com interface gráfica
- [Documentação Principal](../../README.md) - Documentação completa do pacote

## 📄 Licença

Este exemplo faz parte do pacote `serpro_integra_contador_api` e segue a mesma licença.

