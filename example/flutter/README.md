# SERPRO Integra Contador - Aplicação de Testes Flutter

Esta aplicação Flutter fornece uma interface simples e completa para testar todos os serviços disponíveis no pacote `serpro_integra_contador_api`.

## 🚀 Características

- ✅ Interface simples e intuitiva
- ✅ Suporte para todos os 23 serviços do pacote
- ✅ Configuração de autenticação (Trial e Produção)
- ✅ Campos de entrada dinâmicos por serviço
- ✅ Exibição formatada de resultados
- ✅ Suporte multiplataforma (Web, Android, iOS, Desktop)

## 📋 Serviços Disponíveis

A aplicação permite testar os seguintes serviços:

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

### 1. Configurar Autenticação

1. Abra a aplicação
2. Toque no ícone de configurações (⚙️) no canto superior direito
3. Configure as credenciais:
   - **Ambiente**: Selecione "Trial" ou "Produção"
   - **Consumer Key**: Chave fornecida pelo SERPRO
   - **Consumer Secret**: Segredo fornecida pelo SERPRO
   - **CNPJ Contratante**: CNPJ da empresa contratante
   - **CPF/CNPJ Autor do Pedido**: CPF ou CNPJ do autor da requisição
   - **Certificado Digital** (apenas Produção): Certificado P12/PFX em Base64
   - **Senha do Certificado** (apenas Produção): Senha do certificado
   - **URL Servidor** (opcional): URL da Cloud Function para uso na Web
4. Toque em "Autenticar"

### 2. Testar um Serviço

1. Na tela principal, selecione o serviço que deseja testar
2. Preencha os campos de entrada:
   - **CPF/CNPJ Contribuinte**: CPF ou CNPJ do contribuinte
   - **CNPJ Contratante** (opcional): Deixe vazio para usar o padrão
   - **CPF/CNPJ Autor do Pedido** (opcional): Deixe vazio para usar o padrão
   - Campos específicos do serviço (ex: Competência para PGMEI)
3. Toque em "Executar Serviço"
4. Visualize o resultado na tela

### 3. Valores Padrão para Trial

Para facilitar os testes em ambiente Trial, a aplicação já vem com valores padrão pré-preenchidos:

- **Consumer Key**: `06aef429-a981-3ec5-a1f8-71d38d86481e`
- **Consumer Secret**: `06aef429-a981-3ec5-a1f8-71d38d86481e`
- **CNPJ Contratante**: `00000000000191`
- **CPF Autor do Pedido**: `00000000191`

## 📱 Executando a Aplicação

### Web
```bash
cd example/example_flutter
flutter run -d chrome
```

### Android
```bash
cd example/example_flutter
flutter run
```

### iOS
```bash
cd example/example_flutter
flutter run
```

### Desktop (Windows/Linux/macOS)
```bash
cd example/example_flutter
flutter run -d windows  # ou linux, macos
```

## 🔧 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── screens/
│   ├── home_screen.dart         # Tela principal com status de autenticação
│   ├── config_screen.dart       # Tela de configuração de autenticação
│   ├── service_list_screen.dart # Lista de serviços disponíveis
│   └── service_detail_screen.dart # Tela de detalhes e execução do serviço
├── services/
│   └── auth_service.dart       # Serviço centralizado de autenticação
└── widgets/
    └── result_display_widget.dart # Widget para exibir resultados
```

## 📝 Notas

- A aplicação mantém o estado de autenticação durante a sessão
- Os resultados podem ser copiados para a área de transferência
- Erros são exibidos de forma clara e detalhada
- Alguns serviços podem ter implementações básicas que podem ser expandidas conforme necessário

## 🐛 Solução de Problemas

### Erro de Autenticação
- Verifique se as credenciais estão corretas
- Para Produção, certifique-se de que o certificado está em Base64 válido
- Verifique se o ambiente selecionado corresponde às credenciais

### Serviço não funciona
- Verifique se está autenticado (ícone verde no topo)
- Verifique se os campos obrigatórios foram preenchidos
- Alguns serviços podem ter implementações básicas que precisam ser expandidas

## 📄 Licença

Este exemplo faz parte do pacote `serpro_integra_contador_api` e segue a mesma licença.
