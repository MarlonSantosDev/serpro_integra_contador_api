# DCTFWeb - Declaração de Débitos e Créditos Tributários Federais

## Visão Geral

O serviço DCTFWeb permite gerenciar declarações de débitos e créditos tributários federais, incluindo geração de documentos de arrecadação (DARF/DAE), consulta de declarações e transmissão de declarações.

## Funcionalidades

- **Gerar Documento de Arrecadação**: Geração de DARF/DAE para declarações ativas
- **Consultar Recibo de Transmissão**: Consulta de recibos de declarações transmitidas
- **Consultar Declaração Completa**: Consulta de declarações completas
- **Consultar/Gerar XML**: Consulta ou geração de XML de declarações
- **Transmitir Declaração**: Transmissão de declarações com XML assinado
- **Gerar Documento para Declaração em Andamento**: Geração de DARF para declarações em andamento

## Configuração

### Pré-requisitos

- Certificado digital e-CNPJ (padrão ICP-Brasil)
- Consumer Key e Consumer Secret do SERPRO
- Contrato ativo com o SERPRO para o serviço DCTFWeb

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
final dctfWebService = DctfWebService(apiClient);
```

### 2. Gerar Documento de Arrecadação (DARF/DAE)

```dart
try {
  final response = await dctfWebService.gerarDocumentoArrecadacao(
    contribuinteNumero: '00000000000000',
    categoria: CategoriaDctf.geralMensal,
    anoPA: '2024',
    mesPA: '01',
    numeroReciboEntrega: 123456,
    dataAcolhimentoProposta: 20240115,
  );
  
  if (response.sucesso) {
    print('DARF gerado com sucesso!');
    print('Número do documento: ${response.dados.numeroDocumento}');
  }
} catch (e) {
  print('Erro ao gerar DARF: $e');
}
```

### 3. Consultar Recibo de Transmissão

```dart
try {
  final response = await dctfWebService.consultarReciboTransmissao(
    contribuinteNumero: '00000000000000',
    categoria: CategoriaDctf.geralMensal,
    anoPA: '2024',
    mesPA: '01',
  );
  
  if (response.sucesso) {
    print('Recibo encontrado!');
    print('Número do recibo: ${response.dados.numeroRecibo}');
  }
} catch (e) {
  print('Erro ao consultar recibo: $e');
}
```

### 4. Consultar XML de Declaração

```dart
try {
  final response = await dctfWebService.consultarXmlDeclaracao(
    contribuinteNumero: '00000000000000',
    categoria: CategoriaDctf.geralMensal,
    anoPA: '2024',
    mesPA: '01',
  );
  
  if (response.sucesso && response.xmlBase64 != null) {
    print('XML obtido com sucesso!');
    // O XML está em Base64 e precisa ser assinado digitalmente
    final xmlBase64 = response.xmlBase64!;
  }
} catch (e) {
  print('Erro ao consultar XML: $e');
}
```

### 5. Transmitir Declaração

```dart
try {
  // Primeiro, obter o XML
  final xmlResponse = await dctfWebService.consultarXmlDeclaracao(
    contribuinteNumero: '00000000000000',
    categoria: CategoriaDctf.geralMensal,
    anoPA: '2024',
    mesPA: '01',
  );
  
  if (xmlResponse.sucesso && xmlResponse.xmlBase64 != null) {
    // Assinar XML digitalmente (implementação externa necessária)
    final xmlAssinado = await assinarXmlDigitalmente(xmlResponse.xmlBase64!);
    
    // Transmitir declaração
    final response = await dctfWebService.transmitirDeclaracao(
      contribuinteNumero: '00000000000000',
      categoria: CategoriaDctf.geralMensal,
      anoPA: '2024',
      mesPA: '01',
      xmlAssinadoBase64: xmlAssinado,
    );
    
    if (response.sucesso) {
      print('Declaração transmitida com sucesso!');
    }
  }
} catch (e) {
  print('Erro na transmissão: $e');
}
```

## Categorias Disponíveis

### CategoriaDctf Enum

```dart
enum CategoriaDctf {
  geralMensal(40),           // Declaração Geral Mensal
  geral13Salario(41),        // Declaração Geral 13º Salário
  pfMensal(50),              // Pessoa Física Mensal
  pf13Salario(51),           // Pessoa Física 13º Salário
  espetaculoDesportivo(60),  // Espetáculo Desportivo
  afericao(70),              // Aferição
  reclamatoriaTrabalhista(80), // Reclamatória Trabalhista
}
```

## Métodos de Conveniência

### Gerar DARF para Declaração Geral Mensal

```dart
final response = await dctfWebService.gerarDarfGeralMensal(
  contribuinteNumero: '00000000000000',
  anoPA: '2024',
  mesPA: '01',
  numeroReciboEntrega: 123456,
  dataAcolhimentoProposta: 20240115,
);
```

### Gerar DARF para Pessoa Física Mensal

```dart
final response = await dctfWebService.gerarDarfPfMensal(
  contribuinteNumero: '00000000000000',
  anoPA: '2024',
  mesPA: '01',
  numeroReciboEntrega: 123456,
  dataAcolhimentoProposta: 20240115,
);
```

### Gerar DARF para 13º Salário

```dart
final response = await dctfWebService.gerarDarf13Salario(
  contribuinteNumero: '00000000000000',
  anoPA: '2024',
  isPessoaFisica: false, // true para PF, false para PJ
  numeroReciboEntrega: 123456,
  dataAcolhimentoProposta: 20240115,
);
```

## Fluxo Completo de Transmissão

```dart
// Método que executa o fluxo completo
final response = await dctfWebService.consultarXmlETransmitir(
  contribuinteNumero: '00000000000000',
  categoria: CategoriaDctf.geralMensal,
  anoPA: '2024',
  mesPA: '01',
  assinadorXml: (xmlBase64) async {
    // Implementar assinatura digital externa
    return await assinarXmlDigitalmente(xmlBase64);
  },
);
```

## Estrutura de Dados

### GerarGuiaResponse

```dart
class GerarGuiaResponse {
  final bool sucesso;
  final String? mensagemErro;
  final GerarGuiaDados? dados;
}

class GerarGuiaDados {
  final int numeroDocumento;
  final String? pdfBase64;
  final double valorTotal;
  // ... outros campos
}
```

### ConsultarXmlResponse

```dart
class ConsultarXmlResponse {
  final bool sucesso;
  final String? mensagemErro;
  final String? xmlBase64;
  final ConsultarXmlDados? dados;
}
```

## Códigos de Erro Comuns

| Código | Descrição | Solução |
|--------|-----------|---------|
| 001 | Dados inválidos | Verificar estrutura dos dados enviados |
| 002 | CNPJ inválido | Verificar formato do CNPJ |
| 003 | Categoria inválida | Usar categoria válida |
| 004 | Período inválido | Verificar formato do período de apuração |
| 005 | XML inválido | Verificar formato do XML Base64 |

## Exemplos Práticos

### Exemplo Completo - Gerar DARF

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
  final dctfWebService = DctfWebService(apiClient);
  
  // 3. Gerar DARF
  try {
    final response = await dctfWebService.gerarDarfGeralMensal(
      contribuinteNumero: '00000000000000',
      anoPA: '2024',
      mesPA: '01',
      numeroReciboEntrega: 123456,
      dataAcolhimentoProposta: 20240115,
    );
    
    if (response.sucesso) {
      print('DARF gerado com sucesso!');
      print('Número do documento: ${response.dados?.numeroDocumento}');
      print('Valor total: ${response.dados?.valorTotal}');
    } else {
      print('Erro: ${response.mensagemErro}');
    }
  } catch (e) {
    print('Erro ao gerar DARF: $e');
  }
}
```

## Dados de Teste

Para desenvolvimento e testes, utilize os seguintes dados:

```dart
// CNPJs/CPFs de teste (sempre usar zeros)
const cnpjTeste = '00000000000000';
const cpfTeste = '00000000000';

// Períodos de teste
const anoPA = '2024';
const mesPA = '01';
const diaPA = '01';
```

## Limitações

1. **Assinatura Digital**: XML deve ser assinado digitalmente antes da transmissão
2. **Certificado Digital**: Requer certificado digital válido para autenticação
3. **Ambiente de Produção**: Requer configuração adicional para uso em produção

## Suporte

Para dúvidas sobre o serviço DCTFWeb:
- Consulte a [Documentação Oficial](https://apicenter.estaleiro.serpro.gov.br/documentacao/api-integra-contador/)
- Acesse o [Portal do Cliente SERPRO](https://cliente.serpro.gov.br)
- Abra uma issue no repositório para questões específicas do package
