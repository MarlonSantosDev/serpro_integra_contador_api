# Testes do Package Serpro Integra Contador API

Este diretório contém testes automatizados para o package Serpro Integra Contador API.

## Pré-requisitos

- Dart SDK 3.8.0 ou superior
- Dependências instaladas via `dart pub get`

## Executando os Testes

Para executar todos os testes:

```bash
dart test
```

Para executar um teste específico:

```bash
dart test test/test_trial.dart
dart test test/test_defis_trial.dart
dart test test/test_regimeapuracao_trial.dart
dart test test/test_pgmei_trial.dart
```

## Testes Disponíveis

### 1. Testes do Ambiente de Demonstração (Trial)

- `test_trial.dart`: Testa as funcionalidades básicas do PGDASD no ambiente de demonstração
- `test_defis_trial.dart`: Testa as funcionalidades do DEFIS no ambiente de demonstração
- `test_regimeapuracao_trial.dart`: Testa as funcionalidades do REGIMEAPURACAO no ambiente de demonstração
- `test_pgmei_trial.dart`: Testa as funcionalidades do PGMEI no ambiente de demonstração

### 2. Testes de Unidade

- `integra_contador_service_test.dart`: Testa o serviço principal
- `integra_contador_extended_service_test.dart`: Testa o serviço estendido
- `integra_contador_builder_test.dart`: Testa o builder do serviço

## Observações

- Os testes do ambiente de demonstração utilizam a chave de teste fornecida pelo SERPRO
- Os testes de unidade utilizam mocks para simular as respostas da API
- Todos os testes devem passar antes de fazer um commit ou pull request

