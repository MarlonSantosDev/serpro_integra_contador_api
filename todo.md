# Correções e Melhorias para o Package Serpro Integra Contador API

## Problemas Identificados

1. [x] **URL Base Incorreta**: A URL base padrão está configurada para produção (`https://gateway.apiserpro.serpro.gov.br/integra-contador/v1`), mas para o ambiente de demonstração deveria ser `https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1`.

2. [x] **Falta de Método para Ambiente Trial**: Não existe um método específico no builder para configurar o ambiente de demonstração (trial).

3. [x] **Exemplos Incompletos**: Os exemplos existentes não cobrem todos os cenários possíveis com a chave de teste fornecida.

4. [x] **Possíveis Problemas de Importação**: Verificar se há problemas com as importações nos arquivos principais.

5. [x] **Tratamento de Erros**: Verificar se o tratamento de erros está adequado para todos os cenários.

## Correções Necessárias

1. [x] Adicionar método `createTrialService` ao `IntegraContadorFactory` para facilitar a criação de serviços para o ambiente de demonstração.

2. [x] Modificar o builder para permitir a configuração fácil do ambiente de demonstração.

3. [x] Atualizar os exemplos para usar a URL correta do ambiente de demonstração.

4. [x] Criar exemplos completos para todos os serviços disponíveis no ambiente de demonstração.

5. [x] Verificar e corrigir possíveis problemas de importação.

6. [x] Melhorar o tratamento de erros para lidar com todos os cenários possíveis.

7. [x] Adicionar documentação clara sobre como usar o ambiente de demonstração.

## Novos Exemplos a Serem Criados

1. [x] Exemplo para PGDASD (Simples Nacional)
2. [x] Exemplo para DEFIS
3. [x] Exemplo para REGIMEAPURACAO
4. [x] Exemplo para PGMEI
5. [ ] Exemplo para CCMEI
6. [ ] Exemplo para DCTFWEB
7. [ ] Exemplo para MIT
8. [ ] Exemplo para PROCURACOES
9. [ ] Exemplo para SICALC
10. [ ] Exemplo para CAIXAPOSTAL
11. [ ] Exemplo para DTE
12. [ ] Exemplo para PAGTOWEB
13. [ ] Exemplo para AUTENTICAPROCURADOR
14. [ ] Exemplo para EVENTOSATUALIZACAO
15. [ ] Exemplo para SITFIS
16. [ ] Exemplo para PARCSN
17. [ ] Exemplo para PARCSN-ESP
18. [ ] Exemplo para PERTSN
19. [ ] Exemplo para RELPSN
20. [ ] Exemplo para PARCMEI
21. [ ] Exemplo para PARCMEI-ESP
22. [ ] Exemplo para PERTMEI
23. [ ] Exemplo para RELPMEI

