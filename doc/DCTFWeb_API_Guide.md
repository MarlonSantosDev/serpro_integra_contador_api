# Guia da API DCTFWeb - SERPRO Integra Contador

## Visão Geral

A API DCTFWeb permite integração com os serviços da Declaração de Débitos e Créditos Tributários Federais Previdenciários e de Outras Entidades e Fundos (DCTFWeb) do SERPRO.

## Serviços Disponíveis

### 1. Consultar XML da Declaração (`CONSXMLDECLARACAO38`)
- **Endpoint**: `/Consultar`
- **Descrição**: Consulta o XML de uma declaração ATIVA ou gera XML de uma declaração EM ANDAMENTO
- **Uso**: Para obter XML para posterior assinatura e transmissão

### 2. Transmitir Declaração (`TRANSDECLARACAO310`)
- **Endpoint**: `/Declarar`
- **Descrição**: Transmite uma declaração EM ANDAMENTO usando XML assinado digitalmente
- **Requisito**: XML deve ser assinado digitalmente pelo contribuinte

### 3. Gerar Documento de Arrecadação (`GERARGUIA31`)
- **Endpoint**: `/Emitir`
- **Descrição**: Gera DARF/DAE para declaração ATIVA
- **Retorno**: PDF em Base64

### 4. Gerar Documento de Arrecadação em Andamento (`GERARGUIAANDAMENTO313`)
- **Endpoint**: `/Emitir`
- **Descrição**: Gera DARF/DAE para declaração EM ANDAMENTO
- **Retorno**: PDF em Base64

### 5. Consultar Recibo de Transmissão (`CONSRECIBO32`)
- **Endpoint**: `/Consultar`
- **Descrição**: Consulta o recibo de transmissão de uma declaração
- **Retorno**: PDF em Base64

### 6. Consultar Declaração Completa (`CONSDECCOMPLETA33`)
- **Endpoint**: `/Consultar`
- **Descrição**: Consulta relatório completo de declaração transmitida
- **Retorno**: PDF em Base64

## Categorias de Declaração

| Categoria | Código | Nome | Requer Mês | Requer Dia | Campos Especiais |
|-----------|---------|------|------------|------------|------------------|
| Geral Mensal | 40 | GERAL_MENSAL | ✅ | ❌ | - |
| Geral 13º Salário | 41 | GERAL_13o_SALARIO | ❌ | ❌ | - |
| Aferição | 44 | AFERICAO | ✅ | ❌ | cnoAfericao |
| Espetáculo Desportivo | 45 | ESPETACULO_DESPORTIVO | ✅ | ✅ | diaPA |
| Reclamatória Trabalhista | 46 | RECLAMATORIA_TRABALHISTA | ✅ | ❌ | numProcReclamatoria |
| PF Mensal | 50 | PF_MENSAL | ✅ | ❌ | - |
| PF 13º Salário | 51 | PF_13o_SALARIO | ❌ | ❌ | - |

## Sistemas de Origem

| Sistema | ID | Descrição |
|---------|----|-----------| 
| eSocial | 1 | Sistema de Escrituração Digital |
| Sero | 5 | Sistema de Retenções |
| Reinf CP | 6 | EFD-Reinf Contribuição Previdenciária |
| Reinf RET | 7 | EFD-Reinf Retenções |
| MIT | 8 | Movimentação de Informações Tributárias |

## Exemplos de Uso

### Consultar XML
```dart
final xmlResponse = await dctfWebService.consultarXmlDeclaracao(
  contribuinteNumero: '00000000000',
  categoria: CategoriaDctf.pfMensal,
  anoPA: '2022',
  mesPA: '06',
);

if (xmlResponse.sucesso) {
  final xmlBase64 = xmlResponse.xmlBase64;
  // Processar XML...
}
```

### Gerar DARF
```dart
final darfResponse = await dctfWebService.gerarDocumentoArrecadacao(
  contribuinteNumero: '00000000000000',
  categoria: CategoriaDctf.geralMensal,
  anoPA: '2027',
  mesPA: '11',
  idsSistemaOrigem: [SistemaOrigem.esocial, SistemaOrigem.mit],
);

if (darfResponse.sucesso) {
  final pdfBase64 = darfResponse.pdfBase64;
  // Salvar ou exibir PDF...
}
```

### Transmitir Declaração
```dart
// 1. Obter XML
final xmlResponse = await dctfWebService.consultarXmlDeclaracao(...);

// 2. Assinar XML (implementar externamente)
final xmlAssinado = await assinarXmlDigitalmente(xmlResponse.xmlBase64!);

// 3. Transmitir
final transmissaoResponse = await dctfWebService.transmitirDeclaracao(
  contribuinteNumero: '00000000000',
  categoria: CategoriaDctf.pfMensal,
  anoPA: '2022',
  mesPA: '06',
  xmlAssinadoBase64: xmlAssinado,
);

if (transmissaoResponse.sucesso) {
  print('Declaração transmitida com sucesso!');
  if (transmissaoResponse.temMaed) {
    print('ATENÇÃO: Aplicada MAED por atraso na entrega');
  }
}
```

### Métodos de Conveniência
```dart
// DARF Geral Mensal
final darfGeral = await dctfWebService.gerarDarfGeralMensal(
  contribuinteNumero: '00000000000000',
  anoPA: '2027',
  mesPA: '11',
);

// DARF Pessoa Física
final darfPf = await dctfWebService.gerarDarfPfMensal(
  contribuinteNumero: '00000000000',
  anoPA: '2022',
  mesPA: '06',
);

// DARF 13º Salário
final darf13 = await dctfWebService.gerarDarf13Salario(
  contribuinteNumero: '00000000000000',
  anoPA: '2022',
  isPessoaFisica: false,
);
```

## Tratamento de Erros

As respostas incluem mensagens detalhadas sobre o status da operação:

```dart
if (!response.sucesso) {
  print('Erro: ${response.mensagemErro}');
  
  // Exibir todas as mensagens de erro
  for (final erro in response.mensagensErro) {
    print('${erro.tipo}: ${erro.texto}');
  }
}
```

## Validações Automáticas

A API inclui validações automáticas para:
- ✅ Formato de datas (AAAA, MM, DD)
- ✅ Campos obrigatórios por categoria
- ✅ Validação de XML Base64
- ✅ Tipos de documento (CPF/CNPJ)

## Notas Importantes

1. **Assinatura Digital**: A transmissão requer assinatura digital real. O exemplo no código é apenas simulação.
2. **Certificado**: O certificado usado na assinatura deve ser do autor do pedido de dados.
3. **Element Assinado**: O elemento XML a ser assinado é 'ConteudoDeclaracao'.
4. **MAED**: Declarações enviadas após o prazo podem gerar Multa por Atraso (MAED).
5. **Situações**: Declarações ATIVAS são transmitidas, EM ANDAMENTO são rascunhos.

## Códigos de Retorno Comuns

| Código | Descrição |
|--------|-----------|
| 200 | Sucesso |
| 400 | Requisição inválida |
| 401 | Não autorizado |
| 403 | Acesso proibido |
| 500 | Erro interno do servidor |

Para mais detalhes sobre códigos de erro específicos, consulte a documentação oficial do SERPRO.
