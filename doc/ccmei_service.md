# CCMEI - Certificado da Condição de Microempreendedor Individual

## Visão Geral

O serviço CCMEI permite emitir e consultar certificados da condição de Microempreendedor Individual (MEI), incluindo consulta de dados do MEI e verificação de situação cadastral.

## Funcionalidades

- **Emitir CCMEI**: Emissão de certificado da condição de MEI em PDF
- **Consultar Dados CCMEI**: Consulta completa de dados do MEI
- **Consultar Situação Cadastral**: Verificação da situação cadastral do MEI por CPF

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço CCMEI

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
final ccmeiService = CcmeiService(apiClient);
```

### 2. Emitir CCMEI

```dart
try {
  final response = await ccmeiService.emitirCcmei(
    '00000000000000',
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );
  
  if (response.sucesso) {
    print('CCMEI emitido com sucesso!');
    print('Número do certificado: ${response.dados.numeroCertificado}');
    print('Data de emissão: ${response.dados.dataEmissao}');
    print('PDF disponível: ${response.dados.pdf.isNotEmpty}');
    
    // Salvar PDF
    if (response.dados.pdf.isNotEmpty) {
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados.pdf,
        'ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao emitir CCMEI: $e');
}
```

### 3. Consultar Dados CCMEI

```dart
try {
  final response = await ccmeiService.consultarDadosCcmei(
    '00000000000000',
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );
  
  if (response.sucesso) {
    print('Dados do MEI encontrados!');
    print('Nome Empresarial: ${response.dados.nomeEmpresarial}');
    print('CNPJ: ${response.dados.cnpj}');
    print('Situação Cadastral: ${response.dados.situacaoCadastralVigente}');
    print('Data Início Atividades: ${response.dados.dataInicioAtividades}');
    print('Capital Social: R\$ ${response.dados.capitalSocial}');
    
    // Dados do Empresário
    print('Empresário: ${response.dados.empresario.nomeCivil}');
    print('CPF Empresário: ${response.dados.empresario.cpf}');
    
    // Endereço Comercial
    print('Endereço: ${response.dados.enderecoComercial.logradouro}, ${response.dados.enderecoComercial.numero}');
    print('Bairro: ${response.dados.enderecoComercial.bairro}');
    print('Município: ${response.dados.enderecoComercial.municipio}/${response.dados.enderecoComercial.uf}');
    print('CEP: ${response.dados.enderecoComercial.cep}');
    
    // Enquadramento MEI
    print('É MEI: ${response.dados.enquadramento.optanteMei ? 'Sim' : 'Não'}');
    print('Situação Enquadramento: ${response.dados.enquadramento.situacao}');
    
    // Períodos MEI
    print('Períodos MEI: ${response.dados.enquadramento.periodosMei.length}');
    for (var periodo in response.dados.enquadramento.periodosMei) {
      print('  - Período ${periodo.indice}: ${periodo.dataInicio} até ${periodo.dataFim ?? 'atual'}');
    }
    
    // Atividades Econômicas
    print('Formas de Atuação: ${response.dados.atividade.formasAtuacao.join(', ')}');
    print('Ocupação Principal: ${response.dados.atividade.ocupacaoPrincipal.descricaoOcupacao}');
    if (response.dados.atividade.ocupacaoPrincipal.codigoCNAE != null) {
      print('CNAE Principal: ${response.dados.atividade.ocupacaoPrincipal.codigoCNAE} - ${response.dados.atividade.ocupacaoPrincipal.descricaoCNAE}');
    }
    
    // Ocupações Secundárias
    print('Ocupações Secundárias: ${response.dados.atividade.ocupacoesSecundarias.length}');
    for (var ocupacao in response.dados.atividade.ocupacoesSecundarias) {
      print('  - ${ocupacao.descricaoOcupacao}');
      if (ocupacao.codigoCNAE != null) {
        print('    CNAE: ${ocupacao.codigoCNAE} - ${ocupacao.descricaoCNAE}');
      }
    }
    
    // QR Code
    if (response.dados.qrcode != null) {
      print('QR Code disponível: Sim');
      final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
        response.dados.qrcode!,
        'qrcode_ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('QR Code salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar dados: $e');
}
```

### 4. Consultar Situação Cadastral

```dart
try {
  final response = await ccmeiService.consultarSituacaoCadastral(
    '00000000000', // CPF do empresário
    contratanteNumero: '00000000000000', // Opcional
    autorPedidoDadosNumero: '00000000000000', // Opcional
  );
  
  if (response.sucesso) {
    print('Situação cadastral encontrada!');
    print('CNPJs encontrados: ${response.dados.length}');
    
    for (var situacao in response.dados) {
      print('CNPJ: ${situacao.cnpj}');
      print('Situação: ${situacao.situacaoCadastral}');
      print('Data de Cadastro: ${situacao.dataCadastro}');
      print('---');
    }
  } else {
    print('Erro: ${response.mensagemErro}');
  }
} catch (e) {
  print('Erro ao consultar situação: $e');
}
```

## Validações Disponíveis

O serviço utiliza validações centralizadas do `ValidacoesUtils`:

```dart
// Validar CNPJ antes de usar
final errorCnpj = ValidacoesUtils.validarCnpjContribuinte('12345678000195');
if (errorCnpj != null) {
  print('CNPJ inválido: $errorCnpj');
}

// Validar CPF antes de usar
final errorCpf = ValidacoesUtils.validarCpf('12345678901');
if (errorCpf != null) {
  print('CPF inválido: $errorCpf');
}
```

## Formatação de Dados

Utilize os utilitários de formatação do `FormatadorUtils`:

```dart
// Formatar CNPJ para exibição
final cnpjFormatado = FormatadorUtils.formatCnpj('12345678000195');
print('CNPJ: $cnpjFormatado'); // 12.345.678/0001-95

// Formatar CPF para exibição
final cpfFormatado = FormatadorUtils.formatCpf('12345678901');
print('CPF: $cpfFormatado'); // 123.456.789-01

// Formatar moeda
final valorFormatado = FormatadorUtils.formatCurrency(1500.00);
print('Capital Social: $valorFormatado'); // R$ 1.500,00

// Formatar data
final dataFormatada = FormatadorUtils.formatDateFromString('20240115');
print('Data: $dataFormatada'); // 15/01/2024
```

## Estrutura de Dados

### EmitirCcmeiResponse

```dart
class EmitirCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final EmitirCcmeiDados? dados;
  final List<MensagemNegocio> mensagens;
}

class EmitirCcmeiDados {
  final String numeroCertificado;
  final String dataEmissao;
  final String pdf; // Base64
  // ... outros campos
}
```

### ConsultarDadosCcmeiResponse

```dart
class ConsultarDadosCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final ConsultarDadosCcmeiDados? dados;
  final List<MensagemNegocio> mensagens;
}

class ConsultarDadosCcmeiDados {
  final String nomeEmpresarial;
  final String cnpj;
  final String situacaoCadastralVigente;
  final String dataInicioAtividades;
  final double capitalSocial;
  final EmpresarioDados empresario;
  final EnderecoComercial enderecoComercial;
  final EnquadramentoMei enquadramento;
  final AtividadeEconomica atividade;
  final String? qrcode; // Base64
  // ... outros campos
}
```

### ConsultarSituacaoCadastralCcmeiResponse

```dart
class ConsultarSituacaoCadastralCcmeiResponse {
  final bool sucesso;
  final String? mensagemErro;
  final List<SituacaoCadastralDados> dados;
  final List<MensagemNegocio> mensagens;
}

class SituacaoCadastralDados {
  final String cnpj;
  final String situacaoCadastral;
  final String dataCadastro;
  // ... outros campos
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | CPF inválido | Verificar formato do CPF |
| 004 | MEI não encontrado | Verificar se MEI está cadastrado |
| 005 | Situação inválida | Verificar situação do MEI |

## Exemplos Práticos

### Exemplo Completo - Fluxo Completo CCMEI

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  // 1. Configurar cliente
  final apiClient = ApiClient();
  await apiClient.authenticate(
    consumerKey: 'seu_consumer_key',
    consumerSecret: 'seu_consumer_secret', 
    certPath: 'caminho/para/certificado.p12',
    certPassword: 'senha_do_certificado',
    ambiente: 'trial',
  );
  
  // 2. Criar serviço
  final ccmeiService = CcmeiService(apiClient);
  
  try {
    const cnpj = '00000000000000';
    
    // 3. Emitir CCMEI
    print('=== Emitindo CCMEI ===');
    final emitirResponse = await ccmeiService.emitirCcmei(cnpj);
    
    if (emitirResponse.sucesso) {
      print('CCMEI emitido com sucesso!');
      print('Número: ${emitirResponse.dados?.numeroCertificado}');
      print('Data: ${emitirResponse.dados?.dataEmissao}');
      
      // Salvar PDF
      if (emitirResponse.dados?.pdf.isNotEmpty == true) {
        final sucessoSalvamento = await ArquivoUtils.salvarArquivo(
          emitirResponse.dados!.pdf,
          'ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        print('PDF salvo: ${sucessoSalvamento ? 'Sim' : 'Não'}');
      }
      
      // 4. Consultar dados completos
      print('\n=== Consultando Dados Completos ===');
      final dadosResponse = await ccmeiService.consultarDadosCcmei(cnpj);
      
      if (dadosResponse.sucesso) {
        print('Nome: ${dadosResponse.dados?.nomeEmpresarial}');
        print('CNPJ: ${FormatadorUtils.formatCnpj(dadosResponse.dados?.cnpj ?? '')}');
        print('Situação: ${dadosResponse.dados?.situacaoCadastralVigente}');
        print('Capital Social: ${FormatadorUtils.formatCurrency(dadosResponse.dados?.capitalSocial ?? 0)}');
        
        // Dados do empresário
        print('Empresário: ${dadosResponse.dados?.empresario.nomeCivil}');
        print('CPF: ${FormatadorUtils.formatCpf(dadosResponse.dados?.empresario.cpf ?? '')}');
        
        // Endereço
        final endereco = dadosResponse.dados?.enderecoComercial;
        print('Endereço: ${endereco?.logradouro}, ${endereco?.numero}');
        print('Bairro: ${endereco?.bairro}');
        print('Cidade: ${endereco?.municipio}/${endereco?.uf}');
        print('CEP: ${endereco?.cep}');
        
        // Atividades
        print('Ocupação Principal: ${dadosResponse.dados?.atividade.ocupacaoPrincipal.descricaoOcupacao}');
        print('CNAE Principal: ${dadosResponse.dados?.atividade.ocupacaoPrincipal.codigoCNAE}');
        
        // QR Code
        if (dadosResponse.dados?.qrcode != null) {
          print('QR Code disponível: Sim');
          final sucessoQR = await ArquivoUtils.salvarArquivo(
            dadosResponse.dados!.qrcode!,
            'qrcode_ccmei_${DateTime.now().millisecondsSinceEpoch}.pdf',
          );
          print('QR Code salvo: ${sucessoQR ? 'Sim' : 'Não'}');
        }
      }
      
      // 5. Consultar situação cadastral por CPF
      print('\n=== Consultando Situação Cadastral ===');
      final situacaoResponse = await ccmeiService.consultarSituacaoCadastral(
        dadosResponse.dados?.empresario.cpf ?? '00000000000',
      );
      
      if (situacaoResponse.sucesso) {
        print('CNPJs vinculados ao CPF: ${situacaoResponse.dados.length}');
        for (var situacao in situacaoResponse.dados) {
          print('CNPJ: ${FormatadorUtils.formatCnpj(situacao.cnpj)}');
          print('Situação: ${situacao.situacaoCadastral}');
          print('Data Cadastro: ${FormatadorUtils.formatDateFromString(situacao.dataCadastro)}');
        }
      }
      
    } else {
      print('Erro ao emitir CCMEI: ${emitirResponse.mensagemErro}');
      
      // Analisar mensagens de erro
      for (final mensagem in emitirResponse.mensagens) {
        if (mensagem.isErro) {
          print('Erro: ${mensagem.codigo} - ${mensagem.texto}');
        }
      }
    }
    
  } catch (e) {
    print('Erro na operação: $e');
  }
}
```

### Exemplo - Validação e Formatação

```dart
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

void main() async {
  final ccmeiService = CcmeiService(apiClient);
  
  // Validar CNPJ antes de usar
  const cnpj = '12345678000195';
  final errorCnpj = ValidacoesUtils.validarCnpjContribuinte(cnpj);
  
  if (errorCnpj != null) {
    print('CNPJ inválido: $errorCnpj');
    return;
  }
  
  // CNPJ válido, prosseguir
  final response = await ccmeiService.consultarDadosCcmei(cnpj);
  
  if (response.sucesso) {
    // Formatar dados para exibição
    print('=== Dados do MEI ===');
    print('CNPJ: ${FormatadorUtils.formatCnpj(response.dados?.cnpj ?? '')}');
    print('Nome: ${response.dados?.nomeEmpresarial}');
    print('Capital Social: ${FormatadorUtils.formatCurrency(response.dados?.capitalSocial ?? 0)}');
    print('Data Início: ${FormatadorUtils.formatDateFromString(response.dados?.dataInicioAtividades ?? '')}');
    
    // Empresário
    print('Empresário: ${response.dados?.empresario.nomeCivil}');
    print('CPF: ${FormatadorUtils.formatCpf(response.dados?.empresario.cpf ?? '')}');
    
    // Endereço formatado
    final endereco = response.dados?.enderecoComercial;
    print('Endereço: ${endereco?.logradouro}, ${endereco?.numero}');
    print('Bairro: ${endereco?.bairro}');
    print('Cidade: ${endereco?.municipio}/${endereco?.uf}');
    print('CEP: ${FormatadorUtils.formatCep(endereco?.cep ?? '')}');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';

// CPFs de teste (sempre usar zeros)
const cpfTeste = '00000000000';

// Dados de teste comuns
const ufTeste = 'SP';
const municipioTeste = 3550308; // São Paulo
```

## Limitações

1. **Certificado Digital**: Requer certificado digital válido para autenticação
2. **Ambiente de Produção**: Requer configuração adicional para uso em produção
3. **Validação**: Todos os dados devem ser validados antes do envio
4. **MEI Ativo**: MEI deve estar ativo para emissão do certificado
5. **Formato de Dados**: CNPJ deve ter 14 dígitos, CPF deve ter 11 dígitos

## Suporte

Para dúvidas sobre o serviço CCMEI:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package