#include 'protheus.ch'
#include 'parmtype.ch'


User Function RctRecMs()
	Local aArea := SB1->(GetArea())
	
		DbSelectArea('SB1')
		Sb1->(DbSetOrder(1))
		Sb1->(DbGoTop())
	
	// No Protheus o controle de transa��o � iniciado pelo Begin Trensaction e finalizado pelo End Transection
	Begin Transaction
	
		MsgInfo("A descri��o do produto ser� alterada!", "Aten��o")
		
			If SB1->(DbSeek(FWxFilial('SB1') + '000002'))
				RecLock('SB1', .F.) //Trava registro para altera��o
				Replace B1_DESC With "MONITOR DELL 42 PL"
	
					SB1->(MsUnlock())
			EndIf
				MsgAlert("Altera��o efetuada!", "Aten��o") 

	End Transaction
		RestArea(aArea)
Return
