#Include 'Protheus.ch'
User Function FOP1()
Local nNumero1
Local nNumero2

Local nResult
Local nResult1
Local nResult2
Local nResult3
Local nResult4
Local nResult5

nNumero1 := 4 //Utilizando o operador de atribui��o
nNumero2 := 2 //Utilizando o operador de atribui��o

nResult  := nNumero1 + nNumero2
nResult1 := nNumero1 - nNumero2
nResult2 := nNumero1 * nNumero2
nResult3 := nNumero1 / nNumero2
nResult4 := nNumero1 ** nNumero2
nResult5 := nNumero1 % nNumero2

MsgInfo(nResult,"Soma")
MsgInfo(nResult1,"Subtra��o")
MsgInfo(nResult2,"Multiplica��o")
MsgInfo(nResult3,"Divis�o")
MsgInfo(nResult4,"Exponencia��o")
MsgInfo(nResult5,"Resto/Mod")

Return

