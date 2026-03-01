# Entregar Declaração Mensal - Entrada

Serviço que permite a transmissão de uma Declaração do Simples Nacional, original ou retificadora.

## Identificação no Pedido de Dados

- **idSistema**: PGDASD
- **idServico**: TRANSDECLARACAO11
- **versaoSistema**: "1.0"

## Dados de Entrada

**Objeto Dados:**

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| cnpjCompleto | Cnpj completo sem formatação | `String` (14) | SIM |
| pa | Período de apuração da declaração em formato AAAAMM | `Number` | SIM |
| indicadorTransmissao | Indica se a declaração deve ser transmitida. No caso de "false", serão devolvidos os valores devidos sem transmissão | `Boolean` | SIM |
| indicadorComparacao | Indica se há a necessidade de comparação dos valoresParaComparacao enviados na entrada com os valores calculados antes da transmissão. Ver [regra](). | `Boolean` | SIM |
| declaracao | Objeto contendo os dados da declaração. Ver [declaracao](). | `Object` | SIM |
| valoresParaComparacao | Valores para comparação com o valor apurado pelo sistema. Obrigatório, exceto quando não há valor devido. Ver [regra](). | `Array` de `Object` [valorDevido]() | NÃO |

### Objeto [Declaracao:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| tipoDeclaracao | [Tipo da declaração]() | `Number` | SIM |
| receitaPaCompetenciaInterno | Receita do mercado interno no pa de regime de competência | `Number` | SIM |
| receitaPaCompetenciaExterno | Receita do mercado externo no pa de regime de competência | `Number` | SIM |
| receitaPaCaixaInterno | Receita do mercado interno no pa de regime de caixa | `Number` | NÃO |
| receitaPaCaixaExterno | Receita do mercado externo no pa de regime de caixa | `Number` | NÃO |
| valorFixoIcms | Valor fixo de ICMS, deve ser maior que zero e obedecer às regras de negócio | `Number` | NÃO |
| valorFixoIss | valor fixo de ISS, deve ser maior que zero e obedecer às regras de negócio | `Number` | NÃO |
| receitasBrutasAnteriores | Lista de receita bruta anterior. Ver [regra](). | `Array` de `Object` [ReceitaBrutaAnterior]() | NÃO |
| folhasSalario | Valores de folha de salário. | `Array` de `Object` [FolhaSalario]() | NÃO |
| naoOptante | Informações de não optante | `Object` | NÃO |
| estabelecimentos | Estabelecimentos da declaração. Deve conter todos os estabelecimentos vigentes à época do período de apuração da declaração. | `Array` de `Object` [Estabelecimento]() | SIM |

### Objeto [ReceitaBrutaAnterior:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| pa | Período de Apuração em formato AAAAMM | `Number` | SIM |
| valorInterno | Valor no mercado interno | `Number` | SIM |
| valorExterno | Valor no mercado externo | `Number` | SIM |

### Objeto [FolhaSalario:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| pa | Período de Apuração em formato AAAAMM | `Number` | SIM |
| valor | Valor | `Number` | SIM |

### Objeto [NaoOptante:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| esferaAdm | 1 = Federal, 2= Distrital, 3 = Estadual, 4 = Municipal | `String` (1) | SIM |
| uf | Uf do processo | `String` (2) | SIM |
| codMunicipio | Código do município do processo | `String` (4) | SIM |
| processo | Número do processo sem formatação | `String` | SIM |

### Objeto [Estabelecimento:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| cnpjCompleto | Cnpj do estabelecimento sem formatação | `String` (14) | SIM |
| atividades | Atividades do estabelecimento. Se não houve atividade para o estabelecimento, não enviar esta lista. | `Array` de `Object` [Atividade]() | NÃO |

### Objeto [Atividade:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| idAtividade | Id da [atividade]() | `Number` | SIM |
| valorAtividade | Valor da atividade | `Number` | SIM |
| receitasAtividade | Parcela de receita da atividade. | `Array` de `Object` [ReceitaAtividade]() | SIM |

### Objeto [ReceitaAtividade:]()

| Campo | Descrição | Tipo | Obrigatório |
| --- | --- | --- | --- |
| valor | Valor da parcela | `Number` | SIM |
| codigoOutroMunicipio | Código do município no caso de atividade em outro município | `String` | NÃO |
| outraUf | UF no caso de atividade em outro município/UF | `String` | NÃO |
| isencoes | Informações de Isencao. | `Array` de `Object` [Isencao]() | NÃO |
| reducoes | Informações de Reducao. | `Array` de `Object` [Reducao]() | NÃO |
| qualificacoesTributarias | Informações de qualificacao. | `Array` de `Object` [qualificacao]() | NÃO |
| exigibilidadesSuspensas | Informações de Exigibilidade Suspensa. | `Array` de `Object` [Exigibilidade Suspensa]() | NÃO |

## Regras

**a)** Para efeitos de receitas e tipo de declaração, será considerado o que já foi transmitido. Se no momento da chamada do Integra SN, ocorra uma transmissão pela Web, a declaração pelo IntegraSN deverá ser retificadora, mesmo que a transmissão anterior tenha ocorrido segundos antes.

**b)** No caso de qualquer erro encontrado, nenhum dado será salvo.

**c)** As mensagens de negócio do PGDASD 2018 foram preservadas e podem ser apresentadas (estouros de limite, atividades sem preenchimento de qualificação tributária obrigatória, valores possíveis em valores fixos, entre outros). Consulte o [manual]() do PGDASD.

**d)** As [receitas brutas:]() são obrigatórias na primeira declaração em relação aos períodos anteriores ao início de opção ou anteriores ao primeiro PA após decadência (5 anos atrás) e para períodos anteriores onde o contribuinte não foi optante.  
Não serão consideradas as receitas enviadas para API que já foram informadas em outra transmissão ou períodos onde houve transmissão de declaração. Mesmo se enviados, serão ignoradas e serão utilizadas as receitas já armazenadas na base. Receitas brutas para períodos de não optante ou na primeira declaração de PA após decadência (5 anos atrás) poderão ser enviados e os valores serão considerados no cálculo. É o mesmo comportamento do PGDASD WEB. Para períodos habilitados na tela de coleta do RBT, poderá ser enviado o novo valor de RBT. Para períodos desabilitados na tela de coleta do RBT, mesmo que enviados na API, serão ignorados.

**e)** Valores decimais devem ser enviados com o valor mínimo zero.

**f)** Se o indicadorComparacao for enviado como true, serão comparados os valores devidos calculados pelo sistema com os valores enviados na lista valorParaComparacao. A lista de [valoresParaComparacao]() deve ser exatamente igual ao que for calculado pelo sistema. Diferença de 0,01, por exemplo, não permitirá a transmissão.
