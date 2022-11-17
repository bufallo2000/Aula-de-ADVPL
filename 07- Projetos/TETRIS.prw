
#include "protheus.ch"
/* ========================================================
Fun��o U_TETRIS
Autor J�lio Wittwer
Data 03/11/2014
Vers�o 1.150226
Descri�ao R�plica do jogo Tetris, feito em AdvPL
Para jogar, utilize as letras :
A ou J = Move esquerda
D ou L = Move Direita
S ou K = Para baixo
W ou I = Rotaciona sentido horario
Barra de Espa�o = Dropa a pe�a
Pendencias
Fazer um High Score
Cores das pe�as
O = Yellow
I = light Blue
L = Orange
Z = Red
S = Green
J = Blue
T = Purple
======================================================== */
STATIC _aPieces := LoadPieces() // Array de pe�as do jogo 
STATIC _aBlockRes := { "BLACK","YELOW2","LIGHTBLUE2","ORANGE2","RED2","GREEN2","BLUE2","PURPLE2" }
STATIC _nGameClock // Tempo de jogo 
STATIC _nNextPiece // Proxima pe�a a ser usada
STATIC _GlbStatus := 0 // 0 = Running 1 = PAuse 2 == Game Over
STATIC _aBMPGrid := array(20,10) // Array de bitmaps de interface do jogo 
STATIC _aBMPNext := array(4,5) // Array de botmaps da proxima pe�a
STATIC _aNext := {} // Array com a defini��o e posi��o da proxima pe�a
STATIC _aDropping := {} // Array com a defini��o e posi��o da pe�a em jogo
STATIC _nScore := 0 // pontua��o da partida
STATIC _oScore // label para mostrar o score e time e mensagens
STATIC _aMainGrid := {} // Array de strings com os blocos da interface representados em memoria
STATIC _oTimer // Objeto timer de interface para a queda autom�tica da pe�a em jogo
 
// =======================================================
USER Function Tetris()
Local nC , nL
Local oDlg
Local oBackGround , oBackNext
Local oFont , oLabel , oMsg
// Fonte default usada na caixa de di�logo 
// e respectivos componentes filhos
oFont := TFont():New('Courier new',,-16,.T.,.T.)
DEFINE DIALOG oDlg TITLE "Tetris AdvPL" FROM 10,10 TO 450,365 ;
 FONT oFont COLOR CLR_WHITE,CLR_BLACK PIXEL
// Cria um fundo cinza, "esticando" um bitmap
@ 8, 8 BITMAP oBackGround RESOURCE "GRAY" ;
SIZE 104,204 Of oDlg ADJUST NOBORDER PIXEL
// Desenha na tela um grid de 20x10 com Bitmaps
// para ser utilizado para desenhar a tela do jogo
For nL := 1 to 20
 For nC := 1 to 10
 
 @ nL*10, nC*10 BITMAP oBmp RESOURCE "BLACK2" ;
 SIZE 10,10 Of oDlg ADJUST NOBORDER PIXEL
 
 _aBMPGrid[nL][nC] := oBmp
 
 Next
Next
 
// Monta um Grid 4x4 para mostrar a proxima pe�a
// ( Grid deslocado 110 pixels para a direita )
@ 8, 118 BITMAP oBackNext RESOURCE "GRAY" ;
 SIZE 54,44 Of oDlg ADJUST NOBORDER PIXEL
For nL := 1 to 4
 For nC := 1 to 5
 
 @ nL*10, (nC*10)+110 BITMAP oBmp RESOURCE "BLACK" ;
 SIZE 10,10 Of oDlg ADJUST NOBORDER PIXEL
 
 _aBMPNext[nL][nC] := oBmp
 
 Next
Next
// Label fixo, t�tulo do Score.
@ 80,120 SAY oLabel PROMPT "[Score]" SIZE 60,10 OF oDlg PIXEL
 
// Label para Mostrar score, timers e mensagens do jogo
@ 90,120 SAY _oScore PROMPT " " SIZE 60,120 OF oDlg PIXEL
 
// Define um timer, para fazer a pe�a em jogo
// descer uma posi��o a cada um segundo
// ( Nao pode ser menor, o menor tempo � 1 segundo )
_oTimer := TTimer():New(1000, ;
 {|| MoveDown(.f.) , PaintScore() }, oDlg )
// Bot�es com atalho de teclado
// para as teclas usadas no jogo
// colocados fora da area visivel da caixa de dialogo
@ 480,10 BUTTON oDummyBtn PROMPT '&A' ;
 ACTION ( DoAction('A'));
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&S' ;
 ACTION ( DoAction('S') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&D' ;
 ACTION ( DoAction('D') ) ;
 SIZE 1, 1 OF oDlg PIXEL
 
@ 480,20 BUTTON oDummyBtn PROMPT '&W' ;
 ACTION ( DoAction('W') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&J' ;
 ACTION ( DoAction('J') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&K' ;
 ACTION ( DoAction('K') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&L' ;
 ACTION ( DoAction('L') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&I' ;
 ACTION ( DoAction('I') ) ;
 SIZE 1, 1 OF oDlg PIXEL
 
@ 480,20 BUTTON oDummyBtn PROMPT '& ' ; // Espa�o = Dropa
 ACTION ( DoAction(' ') ) ;
 SIZE 1, 1 OF oDlg PIXEL
@ 480,20 BUTTON oDummyBtn PROMPT '&P' ; // Pause
 ACTION ( DoPause() ) ;
 SIZE 1, 1 OF oDlg PIXEL
// Na inicializa��o do Dialogo uma partida � iniciada
oDlg:bInit := {|| Start() }
ACTIVATE DIALOG oDlg CENTER
Return
/* ------------------------------------------------------------
Fun��o Start() Inicia o jogo
------------------------------------------------------------ */
STATIC Function Start()
Local aDraw
// Inicializa o grid de imagens do jogo na mem�ria
// Sorteia a pe�a em jogo
// Define a pe�a em queda e a sua posi��o inicial
// [ Peca, direcao, linha, coluna ]
// e Desenha a pe�a em jogo no Grid
// e Atualiza a interface com o Grid
InitGrid()
nPiece := randomize(1,len(_aPieces)+1)
_aDropping := {nPiece,1,1,6}
SetGridPiece(_aDropping,_aMainGrid)
PaintMainGrid()
// Sorteia a proxima pe�a e desenha 
// ela no grid reservado para ela 
InitNext()
_nNextPiece := randomize(1,len(_aPieces)+1)
aDraw := {_nNextPiece,1,1,1}
SetGridPiece(aDraw,_aNext)
PaintNext()
// Inicia o timer de queda autom�tica da pe�a em jogo
_oTimer:Activate()
// Marca timer do inicio de jogo 
_nGameClock := seconds()
Return
/* ----------------------------------------------------------
Inicializa o Grid na memoria
Em memoria, o Grid possui 14 colunas e 22 linhas
Na tela, s�o mostradas apenas 20 linhas e 10 colunas
As 2 colunas da esquerda e direita, e as duas linhas a mais
sao usadas apenas na memoria, para auxiliar no processo
de valida��o de movimenta��o das pe�as.
---------------------------------------------------------- */
STATIC Function InitGrid()
_aMainGrid := array(20,"11000000000011")
aadd(_aMainGrid,"11111111111111")
aadd(_aMainGrid,"11111111111111")
return
STATIC Function InitNext()
_aNext := array(4,"00000")
return
//
// Aplica a pe�a no Grid.
// Retorna .T. se foi possivel aplicar a pe�a na posicao atual
// Caso a pe�a n�o possa ser aplicada devido a haver
// sobreposi��o, a fun��o retorna .F. e o grid n�o � atualizado
//
STATIC Function SetGridPiece(aOnePiece,aGrid)
Local nPiece := aOnePiece[1] // Numero da pe�a
Local nPos := aOnePiece[2] // Posi��o ( para rotacionar ) 
Local nRow := aOnePiece[3] // Linha atual no Grid
Local nCol := aOnePiece[4] // Coluna atual no Grid
Local nL , nC
Local aTecos := {}
Local cTeco, cPeca , cPieceStr
cPieceStr := str(nPiece,1)
For nL := nRow to nRow+3
 cTeco := substr(aGrid[nL],nCol,4)
 cPeca := _aPieces[nPiece][1+nPos][nL-nRow+1]
 For nC := 1 to 4
 If Substr(cPeca,nC,1) == '1'
 If substr(cTeco,nC,1) != '0'
 // Vai haver sobreposi��o,
 // Nao d� para desenhar a pe�a
 Return .F.
 Endif
 cTeco := Stuff(cTeco,nC,1,cPieceStr)
 Endif
 Next
 // Array temporario com a pe�a j� colocada
 aadd(aTecos,cTeco)
Next
// Aplica o array temporario no array do grid
For nL := nRow to nRow+3
 aGrid[nL] := stuff(_aMainGrid[nL],nCol,4,aTecos[nL-nRow+1])
Next
Return .T.
/* ----------------------------------------------------------
Fun��o PaintMainGrid()
Pinta o Grid do jogo da mem�ria para a Interface
Release 20150222 : Optimiza��o na camada de comunica��o, apenas setar
o nome do resource / bitmap caso o resource seja diferente do atual.
---------------------------------------------------------- */
STATIC Function PaintMainGrid()
Local nL, nc , cLine, nPeca
for nL := 1 to 20
 cLine := _aMainGrid[nL]
 For nC := 1 to 10
 nPeca := val(substr(cLine,nC+2,1))
 If _aBMPGrid[nL][nC]:cResName != _aBlockRes[nPeca+1]
 // Somente manda atualizar o bitmap se houve
 // mudan�a na cor / resource desta posi��o
 _aBMPGrid[nL][nC]:SetBmp(_aBlockRes[nPeca+1])
 endif
 Next
Next
Return
// Pinta na interface a pr�xima pe�a 
// a ser usada no jogo 
STATIC Function PaintNext()
Local nL, nC, cLine , nPeca
For nL := 1 to 4
 cLine := _aNext[nL]
 For nC := 1 to 5
 nPeca := val(substr(cLine,nC,1))
 If _aBMPNext[nL][nC]:cResName != _aBlockRes[nPeca+1]
 _aBMPNext[nL][nC]:SetBmp(_aBlockRes[nPeca+1])
 endif
 Next
Next
Return
/* -----------------------------------------------------------------
Carga do array de pe�as do jogo 
Array multi-dimensional, contendo para cada 
linha a string que identifica a pe�a, e um ou mais
arrays de 4 strings, onde cada 4 elementos 
representam uma matriz binaria de caracteres 4x4 
para desenhar cada pe�a
Exemplo - Pe�a "O"
aLPieces[1][1] C "O"
aLPieces[1][2][1] "0000" 
aLPieces[1][2][2] "0110" 
aLPieces[1][2][3] "0110" 
aLPieces[1][2][4] "0000"
----------------------------------------------------------------- */
STATIC Function LoadPieces()
Local aLPieces := {}
// Pe�a "O" , uma posi��o
aadd(aLPieces,{'O', { '0000','0110','0110','0000'}})
// Pe�a "I" , em p� e deitada
aadd(aLPieces,{'I', { '0000','1111','0000','0000'},;
 { '0010','0010','0010','0010'}})
// Pe�a "S", em p� e deitada
aadd(aLPieces,{'S', { '0000','0011','0110','0000'},;
 { '0010','0011','0001','0000'}})
// Pe�a "Z", em p� e deitada
aadd(aLPieces,{'Z', { '0000','0110','0011','0000'},;
 { '0001','0011','0010','0000'}})
// Pe�a "L" , nas 4 posi��es possiveis
aadd(aLPieces,{'L', { '0000','0111','0100','0000'},;
 { '0010','0010','0011','0000'},;
 { '0001','0111','0000','0000'},;
 { '0110','0010','0010','0000'}})
// Pe�a "J" , nas 4 posi��es possiveis
aadd(aLPieces,{'J', { '0000','0111','0001','0000'},;
 { '0011','0010','0010','0000'},;
 { '0100','0111','0000','0000'},;
 { '0010','0010','0110','0000'}})
// Pe�a "T" , nas 4 posi��es possiveis
aadd(aLPieces,{'T', { '0000','0111','0010','0000'},;
 { '0010','0011','0010','0000'},;
 { '0010','0111','0000','0000'},;
 { '0010','0110','0010','0000'}})
Return aLPieces
/* ----------------------------------------------------------
Fun��o MoveDown()
Movimenta a pe�a em jogo uma posi��o para baixo.
Caso a pe�a tenha batido em algum obst�culo no movimento
para baixo, a mesma � fica e incorporada ao grid, e uma nova
pe�a � colocada em jogo. Caso n�o seja possivel colocar uma
nova pe�a, a pilha de pe�as bateu na tampa -- Game Over
---------------------------------------------------------- */
STATIC Function MoveDown(lDrop)
Local aOldPiece
 
If _GlbStatus != 0
 Return
Endif
// Clona a pe�a em queda na posi��o atual
aOldPiece := aClone(_aDropping)
If lDrop
 
 // Dropa a pe�a at� bater embaixo
 // O Drop incrementa o score em 1 ponto 
 // para cada linha percorrida. Quando maior a quantidade
 // de linhas vazias, maior o score acumulado com o Drop
 
 // Guarda a pe�a na posi��o atual
 aOldPiece := aClone(_aDropping)
 
 // Remove a pe�a do Grid atual
 DelPiece(_aDropping,_aMainGrid)
 
 // Desce uma linha pra baixo
 _aDropping[3]++
 
 While SetGridPiece(_aDropping,_aMainGrid)
 
 // Encaixou, remove e tenta de novo
 DelPiece(_aDropping,_aMainGrid)
 
 // Guarda a pe�a na posi��o atual
 aOldPiece := aClone(_aDropping)
 
 // Desce a pe�a mais uma linha pra baixo
 _aDropping[3]++
// Incrementa o Score
 _nScore++
 
 Enddo
 
 // Nao deu mais pra pintar, "bateu"
 // Volta a pe�a anterior, pinta o grid e retorna
 // isto permite ainda movimentos laterais
 // caso tenha espa�o.
 
 _aDropping := aClone(aOldPiece)
 SetGridPiece(_aDropping,_aMainGrid)
 PaintMainGrid()
 
Else
 
 // Move a pe�a apenas uma linha pra baixo
 
 // Primeiro remove a pe�a do Grid atual
 DelPiece(_aDropping,_aMainGrid)
 
 // Agora move a pe�a apenas uma linha pra baixo
 _aDropping[3]++
 
 // Recoloca a pe�a no Grid
 If SetGridPiece(_aDropping,_aMainGrid)
 
 // Se deu pra encaixar, beleza
 // pinta o novo grid e retorna
 PaintMainGrid()
 Return
 
 Endif
 
 // Opa ... Esbarrou em alguma coisa
 // Volta a pe�a pro lugar anterior
 // e recoloca a pe�a no Grid
 _aDropping := aClone(aOldPiece)
 SetGridPiece(_aDropping,_aMainGrid)
// Incrementa o score em 4 pontos 
 // Nao importa a pe�a ou como ela foi encaixada
 _nScore += 4
// Agora verifica se da pra limpar alguma linha
 ChkMainLines()
 
 // Pega a proxima pe�a
 nPiece := _nNextPiece
 _aDropping := {nPiece,1,1,6} // Peca, direcao, linha, coluna
If !SetGridPiece(_aDropping,_aMainGrid)
 
 // Acabou, a pe�a nova nao entra (cabe) no Grid
 // Desativa o Timer e mostra "game over"
 // e fecha o programa
_GlbStatus := 2 // GAme Over
// volta os ultimos 4 pontos ... 
 _nScore -= 4
// Cacula o tempo de opera��o do jogo 
 _nGameClock := round(seconds()-_nGameClock,0)
 If _nGameClock < 0 
 // Ficou negativo, passou da meia noite 
 _nGameClock += 86400
 Endif
// Desliga o timer de queda de pe�a em jogo
 _oTimer:Deactivate() 
 
 Endif
 
 // Se a peca tem onde entrar, beleza
 // -- Repinta o Grid -- 
 PaintMainGrid()
// Sorteia a proxima pe�a
 // e mostra ela no Grid lateral
If _GlbStatus != 2 
 // Mas apenas faz isso caso nao esteja em game over
 InitNext()
 _nNextPiece := randomize(1,len(_aPieces)+1)
 SetGridPiece( {_nNextPiece,1,1,1} , _aNext)
 PaintNext()
 Else
 // Caso esteja em game over, apenas limpa a proxima pe�a
 InitNext()
 PaintNext()
 Endif
 
 
Endif
Return
/* ----------------------------------------------------------
Recebe uma a��o da interface, atrav�s de uma das letras
de movimenta��o de pe�as, e realiza a movimenta��o caso
haja espa�o para tal.
---------------------------------------------------------- */
STATIC Function DoAction(cAct)
Local aOldPiece
// conout("Action = ["+cAct+"]")
If _GlbStatus != 0 
 Return
Endif
// Clona a pe�a em queda
aOldPiece := aClone(_aDropping)
if cAct $ 'AJ'
// Movimento para a Esquerda (uma coluna a menos)
 // Remove a pe�a do grid
 DelPiece(_aDropping,_aMainGrid)
 _aDropping[4]--
 If !SetGridPiece(_aDropping,_aMainGrid)
 // Se nao foi feliz, pinta a pe�a de volta
 _aDropping := aClone(aOldPiece)
 SetGridPiece(_aDropping,_aMainGrid)
 Endif
 // Repinta o Grid
 PaintMainGrid()
 
Elseif cAct $ 'DL'
// Movimento para a Direita ( uma coluna a mais )
 // Remove a pe�a do grid
 DelPiece(_aDropping,_aMainGrid)
 _aDropping[4]++'
 If !SetGridPiece(_aDropping,_aMainGrid)
 // Se nao foi feliz, pinta a pe�a de volta
 _aDropping := aClone(aOldPiece)
 SetGridPiece(_aDropping,_aMainGrid)
 Endif
 // Repinta o Grid
 PaintMainGrid()
 
Elseif cAct $ 'WI'
 
 // Movimento para cima ( Rotaciona sentido horario )
 
 // Remove a pe�a do Grid
 DelPiece(_aDropping,_aMainGrid)
 
 // Rotaciona
 _aDropping[2]--
 If _aDropping[2] < 1
 _aDropping[2] := len(_aPieces[_aDropping[1]])-1
 Endif
 
 If !SetGridPiece(_aDropping,_aMainGrid)
 // Se nao consegue colocar a pe�a no Grid
 // Nao � possivel rotacionar. Pinta a pe�a de volta
 _aDropping := aClone(aOldPiece)
 SetGridPiece(_aDropping,_aMainGrid)
 Endif
 
 // E Repinta o Grid
 PaintMainGrid()
 
ElseIF cAct $ 'SK'
 
 // Desce a pe�a para baixo uma linha intencionalmente 
 MoveDown(.F.)
 
 // se o movimento foi intencional, ganha + 1 ponto 
 _nScore++
 
ElseIF cAct == ' '
 
 // Dropa a pe�a - empurra para baixo at� a �ltima linha
 // antes de baer a pe�a no fundo do Grid
 MoveDown(.T.)
 
Endif
// Antes de retornar, repinta o score
PaintScore()
Return .T.
Static function DoPause()
If _GlbStatus == 0
 // Pausa
 _GlbStatus := 1
 _oTimer:Deactivate()
Else
 // Sai da pausa
 _GlbStatus := 0
 _oTimer:Activate()
Endif
// Antes de retornar, repinta o score
PaintScore()
Return
/* -----------------------------------------------------------------------
Remove uma pe�a do Grid atual
----------------------------------------------------------------------- */
STATIC Function DelPiece(aPiece,aGrid)
Local nPiece := aPiece[1]
Local nPos := aPiece[2]
Local nRow := aPiece[3]
Local nCol := aPiece[4]
Local nL, nC
Local cTeco, cPeca
// Como a matriz da pe�a � 4x4, trabalha em linhas e colunas
// Separa do grid atual apenas a �rea que a pe�a est� ocupando
// e desliga os pontos preenchidos da pe�a no Grid.
For nL := nRow to nRow+3
 cTeco := substr(aGrid[nL],nCol,4)
 cPeca := _aPieces[nPiece][1+nPos][nL-nRow+1]
 For nC := 1 to 4
 If Substr(cPeca,nC,1)=='1'
 cTeco := Stuff(cTeco,nC,1,'0')
 Endif
 Next
 aGrid[nL] := stuff(_aMainGrid[nL],nCol,4,cTeco)
Next
Return
/* -----------------------------------------------------------------------
Verifica se alguma linha esta completa e pode ser eliminada
----------------------------------------------------------------------- */
STATIC Function ChkMainLines()
Local nErased := 0
Local nL := {}

For nL := 20 to 2 step -1
 
 // Sempre varre de baixo para cima
 // Pega uma linha, e remove os espa�os vazios
 cTeco := substr(_aMainGrid[nL],3)
 cNewTeco := strtran(cTeco,'0','')
 
 If len(cNewTeco) == len(cTeco)
 // Se o tamanho da linha se manteve, n�o houve
 // nenhuma redu��o, logo, n�o h� espa�os vazios
 // Elimina esta linha e acrescenta uma nova linha
 // em branco no topo do Grid
 adel(_aMainGrid,nL)
 ains(_aMainGrid,1)
 _aMainGrid[1] := "11000000000011"
 nL++
 nErased++
 Endif
 
Next
// Pontua��o por linhas eliminadas 
// Quanto mais linhas ao mesmo tempo, mais pontos
If nErased == 4
 _nScore += 100
ElseIf nErased == 3
 _nScore += 50
ElseIf nErased == 2
 _nScore += 25
ElseIf nErased == 1
 _nScore += 10
Endif
Return
/* ------------------------------------------------------
Seta o score do jogo na tela
Caso o jogo tenha terminado, acrescenta 
a mensagem de "GAME OVER"
------------------------------------------------------*/
STATIC Function PaintScore()
If _GlbStatus == 0
// JOgo em andamento, apenas atualiza score e timer
 _oScore:SetText(str(_nScore,7)+CRLF+CRLF+;
 '[Time]'+CRLF+str(seconds()-_nGameClock,7,0)+' s.')
ElseIf _GlbStatus == 1
// Pausa, acresenta a mensagem de "GAME OVER"
 _oScore:SetText(str(_nScore,7)+CRLF+CRLF+;
 '[Time]'+CRLF+str(seconds()-_nGameClock,7,0)+' s.'+CRLF+CRLF+;
 "*********"+CRLF+;
 "* PAUSE *"+CRLF+;
 "*********")
ElseIf _GlbStatus == 2
// Terminou, acresenta a mensagem de "GAME OVER"
 _oScore:SetText(str(_nScore,7)+CRLF+CRLF+;
 '[Time]'+CRLF+str(_nGameClock,7,0)+' s.'+CRLF+CRLF+;
 "********"+CRLF+;
 "* GAME *"+CRLF+;
 "********"+CRLF+;
 "* OVER *"+CRLF+;
 "********")
Endif
Return




