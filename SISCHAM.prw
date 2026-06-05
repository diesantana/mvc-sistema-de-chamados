#include 'totvs.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} SISCHAM
Sistema para gestão de Chamados em MVC Modelo 3.
- SZ2 = Cabeçalho dos chamados
- SZ3 = Comentários/Detalhes do chamado 
@type function
@author Diego Santana
@since 03/06/2026
@version 1.0
/*/
User Function SISCHAM()
	// Instancia a classe FWMbrowse para gerenciar a interface do Browse
	Local oBrowse := FWMbrowse():New()

	// Define a tabela a ser lida
	oBrowse:SetAlias("SZ2") // Cabeçalho dos chamados
	// Define o título da rotina
	oBrowse:SetDescription("Gestão de Chamados")

	// Legendas
	// 1=Aberto;2=Em Andamento;3=Fechado
	oBrowse:AddLegend("Z2_STATUS == '1'", "RED", "Aberto")
	oBrowse:AddLegend("Z2_STATUS == '2'", "BLUE", "Em Andamento")
	oBrowse:AddLegend("Z2_STATUS == '3'", "GREEN", "Fechado")

	// Ativa a tela
	oBrowse:Activate()
Return

/*/{Protheus.doc} ModelDef
Define a estrutuera de dados
@type function
@author Diego
@since 03/06/2026
@return Object, Modelo de dados
/*/
Static Function ModelDef()
	// Instancia o modelo
	// O segundo parâmetro é a Pós validação
	Local oModel     := MPFormModel():New('SISCHAMM',,{|oModel| VldPos(oModel)})

	// Cria as estruturas baseadas no Dicionário
	Local oStPaiZ2   := FWFormStruct(1, 'SZ2') // SZ2 - Cabeçalho do chamado
	Local oStFilhoZ3 := FWFormStruct(1, 'SZ3') // SZ3 -Comentários do chamado
	Local aTrigger := {}

	// Gatilho para carregar o nome do usuário
	aTrigger := FwStruTrigger("Z2_USUARIO", "Z2_USERNAM","USRRETNAME(M->Z2_USUARIO)",.F.)
	oStPaiZ2:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

	// Lógica para bloquear ou não o campo Cód. do Usuário
	oStPaiZ2:SetProperty('Z2_USUARIO', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, 'U_BlockCp()'))

	// Bloqueia o campo Nome do Usuário para edição
	oStPaiZ2:SetProperty('Z2_USERNAM', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))

	// Inc. Padrão para o Z3_CODCHAM
	// O campo Z3_CODCHAM (Cód do chamado na tabela filho) vai ser preenchido com o valor 'SZ2->Z2_COD' (Cód. chamado da tabela pai)
	oStFilhoZ3:SetProperty( 'Z3_CODCHAM', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "FwFldGet('Z2_COD')" ))
	// Bloqueia a edição do campo Z3_CODCHAM
	oStFilhoZ3:SetProperty('Z3_CODCHAM', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

	// Inc. Padrão para o Z3_AUTOR (Recebe o nome do usuário logado)
	oStFilhoZ3:SetProperty( 'Z3_AUTOR', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "UsrRetName(RetCodUsr())" ))
	// Bloqueia a edição do campo Z3_AUTOR
	oStFilhoZ3:SetProperty('Z3_AUTOR', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

	// Inc. Padrão para o campo Data do Comentário Z3_DATA
	oStFilhoZ3:SetProperty( 'Z3_DATA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Date()" ))
	// Bloqueia a edição do campo Z3_DATA
	oStFilhoZ3:SetProperty('Z3_DATA', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

	// Bloqueia a edição do Código do Comentário
	oStFilhoZ3:SetProperty('Z3_CODIGO', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

	// Adiciona os componentes de Cabeçalho e Grid
	oModel:AddFields('SZ2MASTER', /*cOwner*/, oStPaiZ2)
	// VldPre é a função que executa a pré validação
	oModel:AddGrid('SZ3DETAIL', 'SZ2MASTER', oStFilhoZ3, { |oModelGrid, nLine, cAction, cField| VldPre(oModelGrid, nLine, cAction, cField) })

	// Cria o relacionamento entre Filho (SZ3) e Pai (SZ2)
	// Z3_COD 		= Código dos comentários
	// Z3_CODCHAM 	= Código do chamado no FILHO
	// Z2_COD 		= Código do chamado no PAI
	oModel:SetRelation('SZ3DETAIL', { {'Z3_FILIAL', 'xFilial("SZ3")'}, {'Z3_CODCHAM', 'Z2_COD'} }, SZ3->(IndexKey(1)))

	// Define a chave primária da entidade principal (Cabeçalho)
	oModel:SetPrimaryKey({'Z2_FILIAL', 'Z2_COD'})
	// Bloqueia a repetição do código do item na mesma tela
	oModel:GetModel('SZ3DETAIL'):SetUniqueLine({'Z3_CODCHAM','Z3_CODIGO'})

	// Define as descrições dos componentes
	oModel:SetDescription('Modelo 3 Sistema de Chamados')
	oModel:GetModel('SZ2MASTER'):SetDescription('Cabeçalho do Chamado')
	oModel:GetModel('SZ3DETAIL'):SetDescription('Comentários do Chamado')

Return oModel


/*/{Protheus.doc} ViewDef
Define a apresentação dos dados
@type function
@author Diego
@since 03/06/2026
@return Object, Objeto FWFormView.
/*/
Static Function ViewDef()
	// Carrega o modelo de dados que criamos na ModelDef
	Local oModel     := FWLoadModel('SISCHAM') //  'SISCHAM' é o nome do fonte

	// Cria as estruturas visuais baseadas no Dicionário (parâmetro 2 = View)
	Local oStPaiZ2   := FWFormStruct(2, 'SZ2') // SZ2 - Cabeçalho do chamado
	Local oStFilhoZ3 := FWFormStruct(2, 'SZ3') // SZ3 - Comentários do chamado
	// Instancia a View e amarra o Modelo a ela
	Local oView      := FWFormView():New()
	oView:SetModel(oModel)

	// Remove o campo da estrutura de dados, pois o seu valor é apresentado no Cabeçalho.
	oStFilhoZ3:RemoveField('Z3_CODCHAM');

	// Atribui a consulta padrão "USR" (Usuários) ao campo Z2_USUARIO
	oStPaiZ2:SetProperty('Z2_USUARIO', MVC_VIEW_LOOKUP, 'USR')

	// Adiciona o Cabeçalho e o Grid (itens) a view.
	oView:AddField('VIEW_SZ2', oStPaiZ2, 'SZ2MASTER')
	oView:AddGrid('VIEW_SZ3', oStFilhoZ3, 'SZ3DETAIL')

	// Código do Comentário incremental
	oView:AddIncrementField('VIEW_SZ3', 'Z3_CODIGO')

	// Divide a tela: 60% para o cabeçalho e 40% para os itens
	oView:CreateHorizontalBox('CABECALHO', 70)
	oView:CreateHorizontalBox('ITENS', 30)

	// Amarra os componentes visuais dentro de cada divisão da tela
	oView:SetOwnerView('VIEW_SZ2', 'CABECALHO')
	oView:SetOwnerView('VIEW_SZ3', 'ITENS')

	// Adiciona títulos descritivos
	oView:EnableTitleView('VIEW_SZ2', 'Cabeçalho do Chamado')
	oView:EnableTitleView('VIEW_SZ3', 'Comentários do Chamado')

Return oView


/*/{Protheus.doc} MenuDef
Define as operações da tela
@type function
@author Diego
@since 03/06/2026
@return array, Operações disponíveis no menu
/*/
Static Function MenuDef()
	// Carrega os botões padrão (Visualizar, Incluir, Alterar, etc.)
	Local aRotina := FWMVCMenu('SISCHAM') // 'SISCHAM' é nome do código fonte

	// Adiciona botão Legendas
	ADD OPTION aRotina TITLE 'Legendas' ACTION 'U_XLEGEND' OPERATION 6 ACCESS 0

Return aRotina

/*/{Protheus.doc} BLegenda
Exibe os detalhes das legendas.
@type function
@author Diego
@since 03/06/2026
@return array, Detalhes da legenda.
/*/
User Function XLEGEND()
	Local aLegenda := {}

	AADD(aLegenda, {"BR_VERMELHO", 	"Chamado Aberto"})
	AADD(aLegenda, {"BR_AZUL", 	"Chamado em Andamento"})
	AADD(aLegenda, {"BR_VERDE", "Chamado Finalizado"})

	// BrwLegenda("Título", "Sub Título", aLegenda)
	BrwLegenda("Status do Chamado",, aLegenda)
Return aLegenda

/*/{Protheus.doc} BlockCp
Valida se o campo poderá ser editado com base nos códigos cadastrados no parâmetro MV_SZ2USER.
@type function
@author Diego
@since 04/06/2026
@return Logical, Valor lógico, indicando se o campo será liberado ou não.
/*/
User Function BlockCp()
	Local lLibera := .T. // Variável de controle

	// Conteúdo do parâmetro com usuários autorizados
	// MV_SZ2USER é o parâmetro customziado que armazena os users com super permissões na gestão de chamados
	Local cUsersAuth := SUPERGETMV("MV_SZ2USER")
	// Pega o código do usuário logado
	Local cUserAtual := RetCodUsr()

	// Se o usuário atual NÃO estiver na lista de autorizados
	If !(cUserAtual $ cUsersAuth)
		// Bloqueia a edição do campo código e nome de usuário
		lLibera := .F.
	EndIf
Return lLibera

/*/{Protheus.doc} vldPre
	Função de Pré-validação.
	Impede a exclusão de comentários do chamado.
	@type  Function
	@author Diego Santana
	@since 04/06/2026
	@param oModelGrid, Object, O objeto que representa o Grid.
	@param nLine, Numeric, O número da linha que está sendo manipulada.
	@param cAction, character, A ação tentada ('SETVALUE' ou 'DELETE'). 
	SETVALUE ocorre quando o usuário tenta alterar ou inserir uma linha no GRID.
	@param cField, character, O campo afetado (só é preenchido se a ação for 'SETVALUE').
	@return Logical, Se retornar .T. a ação ocorre normalmente
/*/
Static Function VldPre(oModelGrid, nLine, cAction, cField)
	Local lRet := .T.
	// Número da operação (3=Incluir, 4=Alterar)
	Local nOper := oModelGrid:GetModel():GetOperation()

	// Ao Atualizar um registro (nOper == 4) se o usuário tentar apagar uma linha ('DELETE')
	If cAction == 'DELETE' .AND. nOper == 4
		Help(,, 'Pré-Validação',, 'Não é permitido apagar os comentários de um chamado!', 1, 0)
		lRet := .F. // Bloqueia a exclusão da linha
	EndIf
Return lRet // Se retornar .T., a ação ocorre normalmente

/*/{Protheus.doc} VldPos
	Validação aplicada ao Confirmar o formulário de cadastro ou atualização.
	@type  Static Function
	@author Diego Santana
	@since 05/06/2026
	@param oModel, object, Modelo de dados em que a validação será aplicada.
	@return Logical, Se .T. a operação será permitida.
/*/
Static Function VldPos(oModel)
	Local lRet := .T.
	// Pega o valor do campo Z2_DESC (Descrição do Chamado)
	Local cDesc := oModel:GetValue("SZ2MASTER", "Z2_DESC")
	// Pega a quantidade de caracteres digitada no campo, removendo espaços em branco
	Local nLen := Len(AllTrim(cDesc))

	// Verifica se a quantidade digitada é maior que 15 caracteres
	If nLen < 15
		// Exbibe uma mensagem de erro
		ExibeHelp("Help", "A Descrição deve ser mais detalhada.", "O campo descrição não pode ser menor que 15 caracteres.")
		lRet := .F. // Bloqueia a operação (Seja de cadastro ou atualização)
	EndIF

Return lRet
