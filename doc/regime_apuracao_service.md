# Regime de Apuração - Gestão do Regime de Apuração do Simples Nacional

## Visão Geral

O serviço Regime de Apuração permite que empresas optantes pelo Simples Nacional efetuem e consultem opções pelo regime de apuração de receitas (Competência ou Caixa). Este serviço é fundamental para definir como as receitas serão apuradas para fins tributários.

## Funcionalidades

- **Efetuar Opção pelo Regime**: Realizar opção anual pelo regime de apuração (Competência ou Caixa)
- **Consultar Anos Calendários**: Listar todos os anos com opções de regime efetivadas
- **Consultar Opção Específica**: Consultar detalhes de uma opção de regime para um ano específico
- **Consultar Resolução**: Obter o texto da resolução para o regime de caixa

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço Regime de Apuração

### Autenticação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

final apiClient = ApiClient();
await apiClient.authenticate(
  consumerKey: 'seu_consumer_key',
  consumerSecret: 'seu_consumer_secret', 
  certPath: 'caminho/para/certificado.p12',
  certPassword: 'senha_do_certificado',
  ambiente: 'trial', // ou 'producao'
);
```

## Como Utilizar

### 1. Criar Instância do Serviço

```dart
final regimeService = RegimeApuracaoService(apiClient);
```

### 2. Efetuar Opção pelo Regime de Apuração

```dart
try {
  // Opção pelo regime de Caixa
  final response = await regimeService.efetuarOpcaoRegime(
    contribuinteNumero: '12345678000190',
    anoOpcao: 2024,
    tipoRegime: TipoRegime.caixa,
    deAcordoResolucao: true,
    contratanteNumero: '12345678000190', // Opcional
    autorPedidoDadosNumero: '12345678000190', // Opcional
  );
  
  if (response.isSuccess && !response.hasErrors) {
    print('Opção realizada com sucesso!');
    print('Ano: ${response.dados?.anoCalendario}');
    print('Regime escolhido: ${response.dados?.regimeEscolhido}');
    print('Data da opção: ${response.dados?.dataOpcao}');
    
    // Salvar demonstrativo PDF se disponível
    if (response.dados?.hasDemonstrativoPdf ?? false) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados!.demonstrativoPdf!,
        'demonstrativo_regime_${response.dados!.anoCalendario}.pdf',
      );
      print('Demonstrativo salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
    
    // Salvar texto da resolução se disponível (regime de caixa)
    if (response.dados?.hasTextoResolucao ?? false) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados!.textoResolucao!,
        'resolucao_regime_${response.dados!.anoCalendario}.pdf',
      );
      print('Resolução salva: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro ao efetuar opção:');
    for (var mensagem in response.mensagens) {
      print('  - ${mensagem.codigo}: ${mensagem.descricao}');
    }
  }
} catch (e) {
  print('Erro ao efetuar opção pelo regime: $e');
}
```

#### Usando o método com objeto Request

```dart
try {
  final request = EfetuarOpcaoRegimeRequest.caixa(
    anoOpcao: 2024,
    deAcordoResolucao: true,
  );
  
  final response = await regimeService.efetuarOpcaoRegimeWithRequest(
    contribuinteNumero: '12345678000190',
    request: request,
  );
  
  // Processar resposta...
} catch (e) {
  print('Erro: $e');
}
```

### 3. Consultar Anos Calendários com Opções Efetivadas

```dart
try {
  final response = await regimeService.consultarAnosCalendarios(
    contribuinteNumero: '12345678000190',
    contratanteNumero: '12345678000190', // Opcional
    autorPedidoDadosNumero: '12345678000190', // Opcional
  );
  
  if (response.isSuccess && response.hasData) {
    print('Anos com opções efetivadas: ${response.dados?.length ?? 0}');
    
    for (var anoRegime in response.dados ?? []) {
      print('Ano ${anoRegime.anoCalendario}: ${anoRegime.regimeApurado}');
      print('  - É Competência: ${anoRegime.isCompetencia}');
      print('  - É Caixa: ${anoRegime.isCaixa}');
    }
  } else {
    print('Nenhuma opção encontrada ou erro na consulta');
    for (var mensagem in response.mensagens) {
      print('  - ${mensagem.codigo}: ${mensagem.descricao}');
    }
  }
} catch (e) {
  print('Erro ao consultar anos: $e');
}
```

### 4. Consultar Opção Específica por Ano

```dart
try {
  final request = ConsultarOpcaoRegimeRequest(
    anoCalendario: 2024,
  );
  
  final response = await regimeService.consultarOpcaoRegime(
    contribuinteNumero: '12345678000190',
    request: request,
    contratanteNumero: '12345678000190', // Opcional
    autorPedidoDadosNumero: '12345678000190', // Opcional
  );
  
  if (response.isSuccess && response.hasData) {
    print('Opção encontrada!');
    print('Ano: ${response.dados?.anoCalendario}');
    print('Regime: ${response.dados?.regimeEscolhido}');
    print('Data da opção: ${response.dados?.dataOpcao}');
    print('CNPJ Matriz: ${response.dados?.cnpjMatriz}');
    
    // Verificar tipo de regime
    final tipoRegime = response.dados?.tipoRegime;
    if (tipoRegime == TipoRegime.competencia) {
      print('Regime de Competência ativo');
    } else if (tipoRegime == TipoRegime.caixa) {
      print('Regime de Caixa ativo');
    }
    
    // Salvar demonstrativo se disponível
    if (response.dados?.hasDemonstrativoPdf ?? false) {
      await ArquivoUtils.salvarArquivo(
        response.dados!.demonstrativoPdf!,
        'demonstrativo_${response.dados!.anoCalendario}.pdf',
      );
    }
    
    // Salvar resolução se disponível (regime de caixa)
    if (response.dados?.hasTextoResolucao ?? false) {
      await ArquivoUtils.salvarArquivo(
        response.dados!.textoResolucao!,
        'resolucao_${response.dados!.anoCalendario}.pdf',
      );
    }
  } else {
    print('Opção não encontrada ou erro na consulta');
    for (var mensagem in response.mensagens) {
      print('  - ${mensagem.codigo}: ${mensagem.descricao}');
    }
  }
} catch (e) {
  print('Erro ao consultar opção: $e');
}
```

### 5. Consultar Resolução do Regime de Caixa

```dart
try {
  final request = ConsultarResolucaoRequest(
    anoCalendario: 2024,
  );
  
  final response = await regimeService.consultarResolucao(
    contribuinteNumero: '12345678000190',
    request: request,
    contratanteNumero: '12345678000190', // Opcional
    autorPedidoDadosNumero: '12345678000190', // Opcional
  );
  
  if (response.isSuccess && response.hasData) {
    print('Resolução encontrada!');
    
    // Salvar texto da resolução
    if (response.dados?.hasTextoResolucao ?? false) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados!.textoResolucao,
        'resolucao_regime_caixa_2024.pdf',
      );
      print('Resolução salva: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Resolução não encontrada ou erro na consulta');
    for (var mensagem in response.mensagens) {
      print('  - ${mensagem.codigo}: ${mensagem.descricao}');
    }
  }
} catch (e) {
  print('Erro ao consultar resolução: $e');
}
```

## Modelos de Dados

### EfetuarOpcaoRegimeRequest

Modelo para efetuar opção pelo regime de apuração.

**Campos:**
- `anoOpcao` (int, obrigatório): Ano da opção (YYYY)
- `tipoRegime` (int, obrigatório): Tipo do regime (0 = Competência, 1 = Caixa)
- `descritivoRegime` (String, obrigatório): Descrição do regime ("COMPETENCIA" ou "CAIXA")
- `deAcordoResolucao` (bool, obrigatório): Confirmação obrigatória para efetivar a opção

**Validações:**
- `isAnoOpcaoValido`: Verifica se o ano está entre 2010 e ano atual + 1
- `isTipoRegimeValido`: Verifica se o tipo é 0 ou 1
- `isDescritivoRegimeValido`: Verifica se o descritivo é "COMPETENCIA" ou "CAIXA"
- `isDescritivoCoerenteComTipo`: Verifica se o descritivo está coerente com o tipo
- `isValid`: Valida todos os campos

**Factory Methods:**
```dart
// Criar request para regime de competência
final request = EfetuarOpcaoRegimeRequest.competencia(
  anoOpcao: 2024,
  deAcordoResolucao: true,
);

// Criar request para regime de caixa
final request = EfetuarOpcaoRegimeRequest.caixa(
  anoOpcao: 2024,
  deAcordoResolucao: true,
);
```

### EfetuarOpcaoRegimeResponse

Resposta da efetuação de opção pelo regime.

**Campos:**
- `status` (int): Status HTTP da resposta
- `mensagens` (List<MensagemNegocio>): Lista de mensagens da operação
- `dados` (RegimeApuracao?): Dados do regime efetivado

**Propriedades:**
- `isSuccess`: Indica se a operação foi bem-sucedida (status == 200)
- `hasErrors`: Indica se há mensagens de erro
- `hasWarnings`: Indica se há mensagens de aviso

**RegimeApuracao:**
- `cnpjMatriz` (int): CNPJ da matriz
- `anoCalendario` (int): Ano calendário da opção
- `regimeEscolhido` (String): Regime escolhido ("COMPETENCIA" ou "CAIXA")
- `dataHoraOpcao` (int): Data e horário da opção (AAAAMMDDHHMMSS)
- `demonstrativoPdf` (String?): Demonstrativo em PDF (base64)
- `textoResolucao` (String?): Texto da resolução (base64, apenas para regime de caixa)

**Propriedades:**
- `tipoRegime`: Converte o regime escolhido para enum TipoRegime
- `dataOpcao`: Converte dataHoraOpcao para DateTime
- `hasDemonstrativoPdf`: Indica se há demonstrativo disponível
- `hasTextoResolucao`: Indica se há texto de resolução disponível

### ConsultarAnosCalendariosResponse

Resposta da consulta de anos calendários.

**Campos:**
- `status` (int): Status HTTP da resposta
- `mensagens` (List<MensagemNegocio>): Lista de mensagens da operação
- `dados` (List<AnoCalendarioRegime>?): Lista de anos com opções efetivadas

**Propriedades:**
- `isSuccess`: Indica se a operação foi bem-sucedida
- `hasErrors`: Indica se há mensagens de erro
- `hasWarnings`: Indica se há mensagens de aviso
- `hasData`: Indica se há dados disponíveis

**AnoCalendarioRegime:**
- `anoCalendario` (int): Ano calendário
- `regimeApurado` (String): Regime apurado ("COMPETENCIA" ou "CAIXA")

**Propriedades:**
- `tipoRegime`: Converte o regime apurado para enum TipoRegime
- `isCompetencia`: Indica se é regime de competência
- `isCaixa`: Indica se é regime de caixa

### ConsultarOpcaoRegimeRequest

Modelo para consultar opção específica por ano.

**Campos:**
- `anoCalendario` (int, obrigatório): Ano calendário a ser consultado

**Validações:**
- `isAnoCalendarioValido`: Verifica se o ano está entre 2010 e ano atual + 1
- `isValid`: Valida todos os campos

### ConsultarOpcaoRegimeResponse

Resposta da consulta de opção específica.

**Campos:**
- `status` (int): Status HTTP da resposta
- `mensagens` (List<MensagemNegocio>): Lista de mensagens da operação
- `dados` (RegimeApuracao?): Dados do regime consultado

**Propriedades:**
- `isSuccess`: Indica se a operação foi bem-sucedida
- `hasErrors`: Indica se há mensagens de erro
- `hasWarnings`: Indica se há mensagens de aviso
- `hasData`: Indica se há dados disponíveis

### ConsultarResolucaoRequest

Modelo para consultar resolução do regime de caixa.

**Campos:**
- `anoCalendario` (int, obrigatório): Ano calendário para consultar a resolução

**Validações:**
- `isAnoCalendarioValido`: Verifica se o ano está entre 2010 e ano atual + 1
- `isValid`: Valida todos os campos

### ConsultarResolucaoResponse

Resposta da consulta de resolução.

**Campos:**
- `status` (int): Status HTTP da resposta
- `mensagens` (List<MensagemNegocio>): Lista de mensagens da operação
- `dados` (ResolucaoRegimeCaixa?): Dados da resolução

**Propriedades:**
- `isSuccess`: Indica se a operação foi bem-sucedida
- `hasErrors`: Indica se há mensagens de erro
- `hasWarnings`: Indica se há mensagens de aviso
- `hasData`: Indica se há dados disponíveis

**ResolucaoRegimeCaixa:**
- `textoResolucao` (String): Texto da resolução em base64

**Propriedades:**
- `hasTextoResolucao`: Indica se há texto de resolução disponível

## Enums

### TipoRegime

Enum que representa os tipos de regime de apuração disponíveis.

**Valores:**
- `competencia` (código: 0, descrição: "COMPETENCIA"): Regime de Competência
- `caixa` (código: 1, descrição: "CAIXA"): Regime de Caixa

**Métodos:**
- `fromCodigo(int codigo)`: Converte código para enum
- `fromDescricao(String descricao)`: Converte descrição para enum

## Validações

O serviço possui validações específicas através da classe `RegimeApuracaoValidations`:

- `isAnoValido(int ano)`: Valida se o ano está entre 2010 e ano atual + 1
- `isAnoFormatoValido(int ano)`: Valida se o ano tem 4 dígitos
- `isTipoRegimeValido(int tipoRegime)`: Valida se o tipo é 0 ou 1
- `isDescritivoRegimeValido(String descritivo)`: Valida se o descritivo é "COMPETENCIA" ou "CAIXA"
- `isDescritivoCoerenteComTipo(int tipoRegime, String descritivo)`: Valida coerência entre tipo e descritivo

## Mensagens de Retorno

### Mensagens de Sucesso

- `Sucesso-REGIME-MSG_ISN_054`: Opção realizada com sucesso
- `Sucesso-REGIME`: Consulta realizada com sucesso

### Mensagens de Erro

- `Erro-REGIME-MSG_ISN_001`: Erro no Integra Contador
- `EntradaIncorreta-REGIME-MSG_ISN_049`: Descritivo do regime incorreto
- `EntradaIncorreta-REGIME-MSG_ISN_050`: Ano anterior não permitido
- `EntradaIncorreta-REGIME-MSG_ISN_051`: Confirmação de acordo com resolução ausente
- `EntradaIncorreta-REGIME-MSG_ISN_053`: Incoerência entre tipo e descritivo do regime
- `EntradaIncorreta-REGIME-MSG_ISN_056`: Ano fora dos limites permitidos
- `EntradaIncorreta-REGIME-MSG_ISN_058`: Parâmetro obrigatório ausente
- `EntradaIncorreta-REGIME-MSG_ISN_059`: Formato de ano inválido
- `EntradaIncorreta-REGIME-MSG_ISN_060`: Tipo de regime inválido

### Mensagens de Aviso

- `Aviso-REGIME-MSG_ISN_052`: Opção já realizada para o ano
- `Aviso-REGIME-MSG_I_055`: Nenhuma opção encontrada
- `Aviso-REGIME-MSG_ISN_057`: Opção não encontrada para o ano informado

## Exemplo Completo

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Autenticar
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret',
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
  );
  
  // 2. Criar serviço
  final regimeService = RegimeApuracaoService(apiClient);
  
  // 3. Consultar anos disponíveis
  final anosResponse = await regimeService.consultarAnosCalendarios(
    contribuinteNumero: '12345678000190',
  );
  
  if (anosResponse.hasData) {
    print('Anos com opções:');
    for (var ano in anosResponse.dados ?? []) {
      print('  - ${ano.anoCalendario}: ${ano.regimeApurado}');
    }
  }
  
  // 4. Consultar opção específica
  final opcaoRequest = ConsultarOpcaoRegimeRequest(anoCalendario: 2024);
  final opcaoResponse = await regimeService.consultarOpcaoRegime(
    contribuinteNumero: '12345678000190',
    request: opcaoRequest,
  );
  
  if (opcaoResponse.hasData) {
    print('Regime atual para 2024: ${opcaoResponse.dados?.regimeEscolhido}');
  }
  
  // 5. Efetuar nova opção (se necessário)
  final efetuarResponse = await regimeService.efetuarOpcaoRegime(
    contribuinteNumero: '12345678000190',
    anoOpcao: 2025,
    tipoRegime: TipoRegime.caixa,
    deAcordoResolucao: true,
  );
  
  if (efetuarResponse.isSuccess && !efetuarResponse.hasErrors) {
    print('Opção realizada com sucesso para 2025!');
    
    // Salvar demonstrativo
    if (efetuarResponse.dados?.hasDemonstrativoPdf ?? false) {
      await ArquivoUtils.salvarArquivo(
        efetuarResponse.dados!.demonstrativoPdf!,
        'demonstrativo_2025.pdf',
      );
    }
  }
  
  // 6. Consultar resolução (para regime de caixa)
  final resolucaoRequest = ConsultarResolucaoRequest(anoCalendario: 2025);
  final resolucaoResponse = await regimeService.consultarResolucao(
    contribuinteNumero: '12345678000190',
    request: resolucaoRequest,
  );
  
  if (resolucaoResponse.hasData) {
    await ArquivoUtils.salvarArquivo(
      resolucaoResponse.dados!.textoResolucao,
      'resolucao_2025.pdf',
    );
    print('Resolução salva com sucesso!');
  }
}
```

## Observações Importantes

1. **Opção Anual**: A opção pelo regime de apuração deve ser feita anualmente, dentro do prazo estabelecido pela Receita Federal.

2. **Regime de Competência**: As receitas são apuradas no momento em que são faturadas, independentemente do recebimento.

3. **Regime de Caixa**: As receitas são apuradas no momento do recebimento, independentemente da faturação.

4. **Confirmação Obrigatória**: O campo `deAcordoResolucao` deve ser `true` para efetivar a opção.

5. **Validação de Ano**: O ano da opção deve estar entre 2010 e o ano atual + 1.

6. **Coerência de Dados**: O descritivo do regime deve estar coerente com o tipo informado (0 = COMPETENCIA, 1 = CAIXA).

7. **Arquivos Base64**: Os arquivos PDF retornados (demonstrativo e resolução) estão em formato base64 e podem ser salvos usando `ArquivoUtils.salvarArquivo()`.

8. **Parâmetros Opcionais**: Todos os métodos suportam parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero` para flexibilidade de uso.

## Referências

- Documentação oficial do SERPRO Integra Contador
- Regras específicas do serviço: `.cursor/rules/regime_apuracao.mdc`
- Utilitários de validação: `@validacoes_utils`
- Utilitários de formatação: `@formatador_utils`
- Utilitários de arquivo: `ArquivoUtils`

