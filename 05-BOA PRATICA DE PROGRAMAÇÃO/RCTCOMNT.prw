#include 'protheus.ch'
#include 'parmtype.ch'


User Function RCTCOMNT()
	Local lLogico := .T.
	
	//exemplo de coment�rio simples
	If lLogico
		MsgInfo("Verdadeiro!") //Linha de c�digo que faz alguma coisa
	Else
		MsgInfo("Falso!")	//Linha de c�digo que faz alguma coisa
	EndIf
	
	//exemplo de coment�rio em m�ltiplas linhas
	
	//-----------------------------------------
	// Faz algo mais complexo que necessita
	// de uma explica��o em multiplas linhas
	//-----------------------------------------
	
	If lLogico
	
	EndIf
	
Return
