// Domínios centralizados do PGDASD baseados em .cursor/rules/pgdasd/pgdasd_dados_de_dominio.md
// Mapas const e helpers de conversão para descrições descritivas.

class PgdasdDominios {
  PgdasdDominios._();

  // Códigos de Tributo
  static const Map<String, String> codigoTributo = {
    '1001': 'IRPJ',
    '1002': 'CSLL',
    '1004': 'COFINS',
    '1005': 'PIS',
    '1006': 'INSS/CPP',
    '1007': 'ICMS',
    '1008': 'IPI',
    '1010': 'ISS',
  };

  // Tipos de declaração
  static const Map<String, String> tipoDeclaracao = {'1': 'Original', '2': 'Retificadora'};

  // Atividades (1..43)
  static const Map<String, String> idAtividade = {
    '1':
        'Revenda de mercadorias, exceto para o exterior - Sem substituição tributária/tributação monofásica/antecipação com encerramento de tributação (o substituto tributário do ICMS deve utilizar essa opção)',
    '2':
        'Revenda de mercadorias, exceto para o exterior - Com substituição tributária/tributação monofásica/antecipação com encerramento de tributação (o substituído tributário do ICMS deve utilizar essa opção)',
    '3': 'Revenda de mercadorias para o exterior',
    '4':
        'Venda de mercadorias industrializadas pelo contribuinte, exceto para o exterior - Sem substituição tributária/tributação monofásica/antecipação com encerramento de tributação (o substituto tributário do ICMS deve utilizar essa opção)',
    '5':
        'Venda de mercadorias industrializadas pelo contribuinte, exceto para o exterior - Com substituição tributária/tributação monofásica/antecipação com encerramento de tributação (o substituído tributário do ICMS deve utilizar essa opção)',
    '6': 'Venda de mercadorias industrializadas pelo contribuinte para o exterior',
    '7': 'Locação de bens móveis, exceto para o exterior',
    '8': 'Locação de bens móveis para o exterior',
    '9':
        'Prestação de serviços, exceto para o exterior - Escritórios de serviços contábeis autorizados pela legislação municipal a pagar o ISS em valor fixo em guia do Município',
    '10':
        'Prestação de serviços, exceto para o exterior - Sujeitos ao fator “r”, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '11':
        'Prestação de serviços, exceto para o exterior - Sujeitos ao fator “r”, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '12': 'Prestação de serviços, exceto para o exterior - Sujeitos ao fator “r”, com retenção/substituição tributária de ISS',
    '13':
        'Prestação de serviços, exceto para o exterior - Não sujeitos ao fator “r” e tributados pelo Anexo III, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '14':
        'Prestação de serviços, exceto para o exterior - Não sujeitos ao fator “r” e tributados pelo Anexo III, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '15':
        'Prestação de serviços, exceto para o exterior - Não sujeitos ao fator “r” e tributados pelo Anexo III, com retenção/substituição tributária de ISS',
    '16':
        'Prestação de serviços, exceto para o exterior - Sujeitos ao Anexo IV, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '17':
        'Prestação de serviços, exceto para o exterior - Sujeitos ao Anexo IV, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '18': 'Prestação de serviços, exceto para o exterior - Sujeitos ao Anexo IV, com retenção/substituição tributária de ISS',
    '19':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo III, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '20':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo III, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '21':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo IV, com retenção/substituição tributária de ISS',
    '22':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo IV, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '23':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo IV, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '24':
        'Prestação de Serviços relacionados nos subitens 7.02, 7.05 e 16.1 da lista anexa à LC 116/2003, exceto para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo IV, com retenção/substituição tributária de ISS',
    '25':
        'Prestação de Serviços de transporte coletivo municipal rodoviário, metroviário, ferroviário e aquaviário de passageiros, sem retenção/substituição tributária de ISS, com ISS devido a outro(s) Município(s)',
    '26':
        'Prestação de Serviços de transporte coletivo municipal rodoviário, metroviário, ferroviário e aquaviário de passageiros, sem retenção/substituição tributária de ISS, com ISS devido ao próprio Município do estabelecimento',
    '27':
        'Prestação de Serviços de transporte coletivo municipal rodoviário, metroviário, ferroviário e aquaviário de passageiros, com retenção/substituição tributária de ISS',
    '28':
        'Prestação de serviços para o exterior - Escritórios de serviços contábeis autorizados pela legislação municipal a pagar o ISS em valor fixo em guia do Município',
    '29': 'Prestação de serviços para o exterior - Sujeitos ao fator “r”',
    '30': 'Prestação de serviços para o exterior - Não sujeitos ao fator “r” e tributados pelo Anexo III',
    '31': 'Prestação de serviços para o exterior - Sujeitos ao Anexo IV',
    '32':
        'Prestação de Serviços relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003, para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo III',
    '33':
        'Prestação de Serviços relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003, para o exterior - Serviços da área da construção civil relacionados nos subitens 7.02 e 7.05 da lista anexa à LC 116/2003 e tributados pelo Anexo IV',
    '34':
        'Serviços de comunicação; transporte intermunicipal/interestadual de carga; e transporte intermunicipal/interestadual de passageiros - Transporte sem ST de ICMS (substituto)',
    '35':
        'Serviços de comunicação; transporte intermunicipal/interestadual de carga; e transporte intermunicipal/interestadual de passageiros - Transporte com ST de ICMS (substituído)',
    '36':
        'Serviços de comunicação; transporte intermunicipal/interestadual de carga; e transporte intermunicipal/interestadual de passageiros - Comunicação sem ST de ICMS (substituto)',
    '37':
        'Serviços de comunicação; transporte intermunicipal/interestadual de carga; e transporte intermunicipal/interestadual de passageiros - Comunicação com ST de ICMS (substituído)',
    '38': 'Serviços ... para o exterior - Transporte',
    '39': 'Serviços ... para o exterior - Comunicação',
    '40':
        'Atividades com incidência simultânea de IPI e de ISS, exceto para o exterior - Sem retenção/substituição de ISS, com ISS para outro(s) Município(s)',
    '41':
        'Atividades com incidência simultânea de IPI e de ISS, exceto para o exterior - Sem retenção/substituição de ISS, com ISS para o próprio Município',
    '42': 'Atividades com incidência simultânea de IPI e de ISS, exceto para o exterior - Com retenção/substituição tributária de ISS',
    '43': 'Atividades com incidência simultânea de IPI e de ISS para o exterior',
  };

  // Tipo de Redução
  static const Map<String, String> tipoReducao = {'1': 'Normal', '2': 'Cesta básica'};

  // Tipo de Isenção
  static const Map<String, String> tipoIsencao = {
    '1': 'Imunidade',
    '3': 'Lançamento de Ofício',
    '8': 'Substituição Tributária',
    '9': 'Tributação Monofásica',
    '10': 'Antecipação com Encerramento de Tributação',
    '11': 'Retenção de ISS',
  };

  // Tipo de Exigibilidade Suspensa (motivo)
  static const Map<String, String> motivoExigibilidadeSuspensa = {
    '1': 'Liminar em Mandado de Segurança',
    '2': 'Depósito Judicial',
    '3': 'Antecipação de Tutela',
    '4': 'Liminar em Medida Cautelar',
    '5': 'Depósito Administrativo',
    '6': 'Outros',
  };

  // Tipo de Prorrogação Especial
  static const Map<String, String> prorrogacaoEspecial = {
    '1': 'Quota 1 - Para períodos 03, 04 e 05/2021',
    '2': 'Quota 2 - Para períodos 03, 04 e 05/2021',
    '3': 'Federal - Para períodos 03, 04 e 05/2020',
    '4': 'Regional - Para períodos 03, 04 e 05/2020',
  };

  // Helpers
  static String descricaoTipoDeclaracao(dynamic codigo) => tipoDeclaracao[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
  static String descricaoCodigoTributo(dynamic codigo) => codigoTributo[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
  static String descricaoAtividade(dynamic id) => idAtividade[id?.toString() ?? ''] ?? (id?.toString() ?? '');
  static String descricaoTipoReducao(dynamic codigo) => tipoReducao[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
  static String descricaoTipoIsencao(dynamic codigo) => tipoIsencao[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
  static String descricaoMotivoExigibilidade(dynamic codigo) => motivoExigibilidadeSuspensa[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
  static String descricaoProrrogacaoEspecial(dynamic codigo) => prorrogacaoEspecial[codigo?.toString() ?? ''] ?? (codigo?.toString() ?? '');
}
