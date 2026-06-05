# Gestão de Chamados em AdvPL MVC
Um sistema de HelpDesk desenvolvido para o ecossistema TOTVS Protheus utilizando a arquitetura MVC (Model-View-Controller). O projeto consiste em uma rotina de controle de chamados com gestão de acesso e trilha de histórico de comentários.

## 🚀 Funcionalidades e Aprendizados Aplicados
Este projeto foi desenvolvido com foco na exploração aprofundada dos recursos do framework MVC do AdvPL, implementando:

- **Arquitetura MVC (Modelo 3):** Relacionamento nativo entre a tabela de Cabeçalho do Chamado e a tabela de Comentários/Interações.

- **Controle de Acesso Multiusuário:** Validação de edição de campos sensíveis baseada no usuário logado e em um parâmetro customizado de autorização.

- **Gestão de Interface Visual (ViewDef):** Criação de legendas dinâmicas com cores e divisão percentual de tela (60% Cabeçalho / 40% Itens).

- **Gatilhos e Inicializadores Nativos:** Uso de *FwStruTrigger* no código MVC e inicializadores padrão (como a injeção automática de data e usuário logado).

- **Pré-validações de Grid:** Bloqueio de deleção de linhas do grid para proteger a integridade do histórico de comentários na alteração do chamado.

- **Pós-validações do Modelo:** Validação de regras de negócio no momento do "Salvar" (Ex: exigência de descrição detalhada mínima de 15 caracteres).

- **Campos Incrementais e Somente Leitura:** Geração de sequenciais automáticos para as linhas de comentário e bloqueio de edição em campos de controle.


## 🛠️ Tecnologias Utilizadas
- Linguagem: AdvPL (Advanced Protheus Language)
- Framework: TOTVS MVC
- ERP: TOTVS Protheus (Testado na versão 12)

## 👨‍💻 Autor

Diego Santana
🔗 [LinkedIn - Diego Santana](https://www.linkedin.com/in/die-santana/?utm_source=chatgpt.com)
