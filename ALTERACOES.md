# Alterações Realizadas no Package Serpro Integra Contador API

## Correções Principais

1. **Adição de Suporte ao Ambiente de Demonstração (Trial)**
   - Adicionado método `createTrialService` ao `IntegraContadorFactory` para facilitar a criação de serviços para o ambiente de demonstração.
   - Adicionado método `forTrialEnvironment()` ao builder para configurar facilmente o ambiente de demonstração.
   - Configurada a URL correta para o ambiente de demonstração: `https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1`.

2. **Criação de Exemplos para o Ambiente de Demonstração**
   - Criado arquivo `example_trial.dart` com exemplos específicos para o ambiente de demonstração.
   - Criado arquivo `example_defis_trial.dart` com exemplos para o DEFIS.
   - Criado arquivo `example_regimeapuracao_trial.dart` com exemplos para o REGIMEAPURACAO.
   - Criado arquivo `example_pgmei_trial.dart` com exemplos para o PGMEI.
   - Adaptados os exemplos para usar os métodos existentes no serviço estendido.

3. **Melhorias no Código**
   - Removidas instruções de debug (print) do método `_executeRequest`.
   - Adicionado método `testarConectividade()` ao serviço estendido.
   - Adicionado método `dispose()` para liberar recursos quando o serviço não for mais necessário.
   - Corrigido o tratamento de erros para lidar com todos os cenários possíveis.

4. **Adição de Testes**
   - Criados scripts de teste para o ambiente de demonstração.
   - Adicionados testes para PGDASD, DEFIS, REGIMEAPURACAO e PGMEI.
   - Criado arquivo README.md com instruções sobre como executar os testes.

5. **Documentação Aprimorada**
   - Adicionada seção específica no README.md sobre como usar o ambiente de demonstração.
   - Documentados os três métodos diferentes para configurar o ambiente de demonstração.
   - Incluídos exemplos de código para facilitar o uso.

## Arquivos Modificados

1. **lib/services/integra_contador_builder.dart**
   - Adicionado método `forTrialEnvironment()` ao builder.
   - Adicionado método `createTrialService()` ao factory.

2. **lib/services/integra_contador_service.dart**
   - Removidas instruções de debug (print) do método `_executeRequest`.
   - Corrigido o método `testarConectividade()`.
   - Adicionado método `dispose()` para liberar recursos.

3. **lib/services/integra_contador_extended_service.dart**
   - Adicionado método `testarConectividade()`.
   - Adicionado método `dispose()` para liberar recursos.

4. **Novos Arquivos de Exemplo**
   - `example/example_trial.dart`: Exemplos para o PGDASD no ambiente de demonstração.
   - `example/example_defis_trial.dart`: Exemplos para o DEFIS no ambiente de demonstração.
   - `example/example_regimeapuracao_trial.dart`: Exemplos para o REGIMEAPURACAO no ambiente de demonstração.
   - `example/example_pgmei_trial.dart`: Exemplos para o PGMEI no ambiente de demonstração.

5. **Novos Arquivos de Teste**
   - `test/test_trial.dart`: Testes para o PGDASD no ambiente de demonstração.
   - `test/test_defis_trial.dart`: Testes para o DEFIS no ambiente de demonstração.
   - `test/test_regimeapuracao_trial.dart`: Testes para o REGIMEAPURACAO no ambiente de demonstração.
   - `test/test_pgmei_trial.dart`: Testes para o PGMEI no ambiente de demonstração.
   - `test/README.md`: Instruções sobre como executar os testes.

6. **README.md**
   - Adicionada seção sobre o ambiente de demonstração.
   - Documentados os métodos para configurar o ambiente de demonstração.
   - Incluídos exemplos de código.

## Próximos Passos Recomendados

1. **Expandir Exemplos**
   - Implementar exemplos para os demais serviços disponíveis no ambiente de demonstração (CCMEI, DCTFWEB, MIT, etc.).
   - Organizar os exemplos por categoria de serviço para facilitar a navegação.

2. **Implementar Testes Automatizados**
   - Executar os testes criados em um ambiente com Dart SDK instalado.
   - Implementar testes de integração para garantir que todos os serviços funcionam corretamente.
   - Configurar CI/CD para executar os testes automaticamente.

3. **Melhorar a Documentação**
   - Adicionar documentação específica para cada serviço disponível no ambiente de demonstração.
   - Criar um guia de uso completo com exemplos para todos os serviços.
   - Documentar os possíveis erros e como tratá-los.

4. **Implementar Recursos Adicionais**
   - Adicionar suporte para download de arquivos PDF (DAS, recibos, etc.).
   - Implementar cache de respostas para melhorar a performance.
   - Adicionar suporte para logs detalhados para facilitar o debug.

## Como Usar o Ambiente de Demonstração

### Método 1: Usando o Factory (Recomendado)

```dart
// Cria um serviço configurado para o ambiente de demonstração
final service = IntegraContadorFactory.createTrialService();

// A chave de teste padrão já está configurada, mas você pode especificar outra se necessário
final serviceCustom = IntegraContadorFactory.createTrialService(
  jwtToken: '06aef429-a981-3ec5-a1f8-71d38d86481e',
);
```

### Método 2: Usando o Builder com método específico

```dart
final service = IntegraContadorBuilder()
    .withJwtToken('06aef429-a981-3ec5-a1f8-71d38d86481e')
    .forTrialEnvironment() // Configura automaticamente a URL e headers para o ambiente de demonstração
    .build();
```

### Método 3: Configuração manual

```dart
final service = IntegraContadorBuilder()
    .withJwtToken('06aef429-a981-3ec5-a1f8-71d38d86481e')
    .withBaseUrl('https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1')
    .withCustomHeaders({'X-Environment': 'trial'})
    .build();
```

Para exemplos completos, consulte o arquivo `example/example_trial.dart`.

