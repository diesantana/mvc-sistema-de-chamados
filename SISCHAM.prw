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
	Local oModel     := MPFormModel():New('SISCHAMM')

	// Cria as estruturas baseadas no Dicionário
	Local oStPaiZ2   := FWFormStruct(1, 'SZ2') // SZ2 - Cabeçalho do chamado
	Local oStFilhoZ3 := FWFormStruct(1, 'SZ3') // SZ3 -Comentários do chamado

	// Adiciona os componentes de Cabeçalho e Grid
	oModel:AddFields('SZ2MASTER', /*cOwner*/, oStPaiZ2)
	oModel:AddGrid('SZ3DETAIL', 'SZ2MASTER', oStFilhoZ3)

	// Cria o relacionamento entre Filho (SZ3) e Pai (SZ2)
	// Z3_COD 		= Código dos comentários
	// Z3_CODCHAM 	= Código do chamado no FILHO
	// Z2_COD 		= Código do chamado no PAI
	oModel:SetRelation('SZ3DETAIL', { {'Z3_FILIAL', 'xFilial("SZ3")'}, {'Z3_CODCHAM', 'Z2_COD'} }, SZ3->(IndexKey(1)))

	// Define a chave primária da entidade principal (Cabeçalho)
	oModel:SetPrimaryKey({'Z2_FILIAL', 'Z2_COD'})
	// Bloqueia a repetição do código do item na mesma tela
	// Impede linhas duplicadas com os valores: CÓDIGO DO CHAMADO + CÓDIGO DO COMENTÁRIO
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

	// Adiciona o Cabeçalho e o Grid (itens) a view.
	oView:AddField('VIEW_SZ2', oStPaiZ2, 'SZ2MASTER')
	oView:AddGrid('VIEW_SZ3', oStFilhoZ3, 'SZ3DETAIL')

	// 5. Divide a tela: 60% para o cabeçalho e 40% para os itens
	oView:CreateHorizontalBox('CABECALHO', 70)
	oView:CreateHorizontalBox('ITENS', 30)

	// 6. Amarra os componentes visuais dentro de cada divisão da tela
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

	AADD(aLegenda, {"BR_RED", 	"Chamado Aberto"})
	AADD(aLegenda, {"BR_BLUE", 	"Chamado em Andamento"})
	AADD(aLegenda, {"BR_GREEN", "Chamado Finalizado"})

	// BrwLegenda("Título", "Sub Título", aLegenda)
	BrwLegenda("Status do Chamado",, aLegenda)
Return aLegenda

