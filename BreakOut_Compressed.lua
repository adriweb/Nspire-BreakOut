gameVersion="v1.8b"BlockWidth=20
BlockHeight=12
touchEnabled=false
totalBlocksToDestroy=0
device={api,hasColor,isCalc,theType,lang}device.api=platform.apilevel
device.hasColor=platform.isColorDisplay()device.lang=locale.name()currentLevel={numberOfBlocks,xPositions={},yPositions={},blocksStates={}}possibleStates={"breakable","solid","unbreakable"}bonusTypes={"PaddleGrow","PaddleShrink","BallClone","BallGrow","BallShrink"}level={{1,1,1},{3,5,2},{10,4,3}}function reset()win=false
gameover=false
pause=false
waitContinue=false
tmpCount=0
lives=3
score=-1
secureNbr=0
BonusTable={Bonus(-1,-1,"PaddleGrow"),Bonus(-1,-1,"PaddleShrink"),Bonus(-1,-1,"BallClone"),Bonus(-1,-1,"BallGrow"),Bonus(-1,-1,"BallShrink")}BlocksTable={}BallsTable={}FallingBonusTable={}totalBlocksToDestroy=0
level={{1,1,1},{3,5,2},{10,4,3}}for a=1,20 do
table.insert(level,{math.random(0,12),math.random(0,10),randomAndCount()})end
for l,a in pairs(level)do
table.insert(BlocksTable,Block(20*a[1]*XRatio,12*a[2]*YRatio,BlockWidth*XRatio,BlockHeight*YRatio,a[3],#BlocksTable+1))end
totalBlocksToDestroy=#BlocksTable-totalBlocksToDestroy
end
function randomAndCount()theRand=math.random(1,3)if theRand==3 then totalBlocksToDestroy=totalBlocksToDestroy+1 end
if theRand==2 then totalBlocksToDestroy=totalBlocksToDestroy-1 end
return theRand
end
function fillRoundRect(d,e,l,t,n,a)if a>n/2 then a=n/2 end
d:fillPolygon({(e-t/2),(l-n/2+a),(e+t/2),(l-n/2+a),(e+t/2),(l+n/2-a),(e-t/2),(l+n/2-a),(e-t/2),(l-n/2+a)})d:fillPolygon({(e-t/2-a+1),(l-n/2),(e+t/2-a+1),(l-n/2),(e+t/2-a+1),(l+n/2),(e-t/2+a),(l+n/2),(e-t/2+a),(l-n/2)})e=e-t/2
l=l-n/2
d:fillArc(e+t-(a*2),l+n-(a*2),a*2,a*2,1,-91);d:fillArc(e+t-(a*2),l,a*2,a*2,-2,91);d:fillArc(e,l,a*2,a*2,85,95);d:fillArc(e,l+n-(a*2),a*2,a*2,180,95);end
function clearWindow(a)a:setColorRGB(255,255,255)a:fillRect(0,0,platform.window:width(),platform.window:height())end
function test(a)return a and 1 or 0
end
function screenRefresh()return platform.window:invalidate()end
function pww()return platform.window:width()end
function pwh()return platform.window:height()end
function drawPoint(a,e,l)a:fillRect(x,l,1,1)end
function drawCenteredString(l,a)l:drawString(a,(pww()-l:getStringWidth(a))/2,pwh()/2,"middle")end
function drawXCenteredString(a,l,e)a:drawString(l,(pww()-a:getStringWidth(l))/2,e,"top")end
function on.create()reset()pause=false
gameover=false
needHelp=true
on.resize()newPaddleY=0
while(math.floor(.5*platform.window:width()-29)+newPaddleY)%4~=0 do
newPaddleY=newPaddleY+1
end
paddle=Paddle(.5*platform.window:width()-29+newPaddleY,40*XRatio,0,"")aBall=Ball(math.random(10,platform.window:width()-10-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1)table.insert(BallsTable,aBall)timer.start(.01)end
function on.timer()platform.window:invalidate()end
function on.resize()if device.api=="1.1"then platform.window:setPreferredSize(0,0)end
device.isCalc=(platform.window:width()<320)device.theType=platform.isDeviceModeRendering()and"handheld"or"software"if not device.isCalc or device.theType=="software"then touchEnabled=true end
XLimit=device.isCalc and 58 or math.ceil(58*pww()/320)fixedX1=4+.5*(pww()-XLimit+pww()-platform:gc():getStringWidth("Nspire"))fixedX2=6+.5*(pww()-XLimit+pww()-platform.gc():getStringWidth("BreakOut"))XRatio=platform.window:width()/318
YRatio=platform.window:height()/212
BlocksTable={}for l,a in pairs(level)do
table.insert(BlocksTable,Block(20*a[1]*XRatio,12*a[2]*YRatio,BlockWidth*XRatio,BlockHeight*YRatio,a[3],#BlocksTable+1))end
totalBlocksToDestroy=#BlocksTable-totalBlocksToDestroy
end
function on.charIn(a)if a=="p"then pause=not pause
elseif a=="r"then
on.create()elseif a=="h"then
needHelp=not needHelp
elseif a=="t"then
touchEnabled=not touchEnabled
elseif a=="8"then
on.arrowKey("right")elseif a=="6"then
on.arrowKey("left")end
end
function on.mouseMove(a,l)if touchEnabled and not pause and a+paddle.size*.5<platform.window:width()-XLimit+5*test(not device.isCalc)and a>paddle.size*.5 then paddle.x=a end
end
function on.paint(a)a:setColorRGB(0,0,0)if#BallsTable<1 or secureNbr>10 then
lives=lives-1
if lives<1 then
gameover=true
else
paddle.x=.5*platform.window:width()-29+newPaddleY
aBall=Ball(paddle.x,platform.window:height()-26,-1,-1,#BallsTable+1)table.insert(BallsTable,aBall)pause=true
waitContinue=true
end
end
if lives<1 then gameover=true end
if tmpCount>=totalBlocksToDestroy and tmpCount>0 and totalBlocksToDestroy>0 then win=true end
if not gameover and not needHelp and not win then
sideBarStuff(a)if score==-1 then score=0 end
if not pause then score=score+.2 end
ballStuff(a)bonusStuff(a)elseif gameover then
drawCenteredString(a,"Game Over ! Score = "..tostring(math.floor(score)))elseif win then
drawCenteredString(a,"You won ! Score = "..tostring(math.floor(score)))elseif needHelp then
helpScreen(a)end
end
function on.arrowKey(a)if a=="right"and paddle.x<platform.window:width()-20-XLimit then
paddle.dx=8
elseif a=="left"and paddle.x>=25 then
paddle.dx=-8
end
end
function on.enterKey()if needHelp then needHelp=not needHelp end
print("------------------")print("tmpCount = "..tmpCount)print("totalBlocksToDestroy = "..totalBlocksToDestroy)end
function on.help()needHelp=not needHelp
end
function sideBarStuff(a)a:drawLine(platform.window:width()-XLimit,0,platform.window:width()-XLimit,platform.window:height())a:setFont("serif","r",10)a:drawString("______",fixedX1-2,pwh()-89,"top")a:drawString("Nspire",fixedX1,pwh()-68,"top")a:drawString("BreakOut",fixedX2,pwh()-54,"top")a:drawString("______",fixedX1-2,pwh()-43,"top")a:drawString("Adriweb",4+fixedX2,pwh()-22,"top")a:drawString("Balls Left :",fixedX1-9,pwh()*.5-22,"top")a:drawString(lives,fixedX1+14,pwh()*.5-22+14,"top")end
function ballStuff(l)for e,a in pairs(BallsTable)do
if 2*a.radius-2<0 then a.radius=5 end
if a.y+a.radius>platform.window:height()-15 then
if not a:intersectsPaddle()then
table.remove(BallsTable,a.id)else
a:PaddleChock()if not a:touchedEdgesOfPaddle()then paddle.glow=12 end
local l=.7*(-1+test(a.speedX>0))*math.abs(a:howFarAwayFromTheCenterOfThePaddle())if a.x>10 and a.x<pww()-10 then a.x=a.x+l end
end
end
for n,e in pairs(BlocksTable)do
if e~=0 then
if a:intersectsBlock(e)then
a:BlockChock(e)e:destroy()end
if pause then
l:setAlpha(127)end
e:paint(l)if pause then
l:setAlpha(255)end
end
end
if not pause then
a:update()paddleStuff(l)end
if pause then
l:setAlpha(127)end
a:paint(l)paddle:paint(l)if pause then
l:setAlpha(255)if waitContinue then
l:drawString(lives.." ball(s) left... (Press 'P')",.5*(pww()-l:getStringWidth(lives.." ball(s) left... (Press 'P')")-32),pwh()/2+25,"top")else
drawCenteredString(l,"... Pause ...")end
end
if not pause and math.random(1,450)==100 then table.insert(FallingBonusTable,Bonus(math.random(5,pww()-65),0,bonusTypes[math.random(1,#bonusTypes)]))end
end
end
function paddleStuff(a)if paddle.dx>0 then
paddle.x=paddle.x+paddle.dx
paddle.dx=paddle.dx-1
elseif paddle.dx<0 then
paddle.x=paddle.x+paddle.dx
paddle.dx=paddle.dx+1
end
end
function bonusStuff(l)for e,a in pairs(FallingBonusTable)do
if pause then l:setAlpha(127)end
a:paint(l)if pause then l:setAlpha(255)end
if not pause then a:update()end
if a:fallsOnPaddle()then paddle:grabBonus(a);a:destroy()end
if a.y>platform.window:height()-16 and not a:fallsOnPaddle()then a:destroy()end
end
for e,a in pairs(BonusTable)do
l:setColorRGB(0,0,255)if a.timeLeft<666 then l:setColorRGB(0,0,0)end
if a.timeLeft<333 then l:setColorRGB(255,0,0)end
if a.timeLeft>2 then l:drawString(a.bonusType.." : "..tostring(a.timeLeft),0,e*12,"top")end
if not pause and not(a.timeLeft<1)then a.timeLeft=a.timeLeft-1 end
if a.timeLeft<2 and a.timeLeft~=-10 then resetBonus(a)end
end
end
function helpScreen(a)a:setColorRGB(175,175,175)a:fillRect(pww()*.1,pwh()*.15,pww()*.8,pwh()*.7)a:setColorRGB(0,0,0)a:drawRect(pww()*.1,pwh()*.15,pww()*.8,pwh()*.7)a:drawImage(gameLogo,.5*(pww()-image.width(gameLogo)),pwh()*.19)drawXCenteredString(a,"Paddle Control : Arrows or 4/6",pwh()*.52)drawXCenteredString(a,"'T' to enable touch-controls",pwh()*.6)playResume=(score>10)and"resume"or"play"a:setFont("serif","b",12)drawXCenteredString(a,"Press enter to "..playResume,pwh()*.72)a:setFont("serif","r",12)drawXCenteredString(a,"Nspire BreakOut "..gameVersion.." | Adriweb 2011",pwh()*.03*YRatio)a:setFont("serif","i",12)drawXCenteredString(a,"Thanks to Levak, Jim Bauwens, Omnimaga...",pwh()*.87)end
Ball=class()function Ball:init(n,t,e,a,l)self.x=n
self.y=t
self.speedX=e
self.speedY=a
self.radius=5
self.id=l
end
function Ball:paint(a)a:setColorRGB(0,0,0)a:drawArc(self.x-self.radius,self.y-self.radius,2*self.radius,2*self.radius,0,360)a:setColorRGB(127,127,0)a:fillArc(self.x-self.radius+1,self.y-self.radius+1,2*self.radius-2,2*self.radius-2,0,360)end
function Ball:intersectsBlock(a)return(self.x>a.x-self.radius-2 and self.x<(a.x+a.w+self.radius+2))and(self.y>a.y+self.radius+2 and self.y<(a.y+a.h+self.radius+2))end
function Ball:intersectsBall(a)return math.sqrt((a.x-self.x)*(a.x-self.x)+(a.y-self.y)*(a.y-self.y))<self.radius+a.radius
end
function Ball:intersectsPaddle()return(self.y+self.radius>platform.window:height()-16)and(self.y+self.radius<platform.window:height()+10)and(self.x>=paddle.x-paddle.size*.5-4 and(self.x<=paddle.x+paddle.size*.5+4))end
function Ball:BlockChock(a)if self.y>a.y+a.h or self.y<a.y then
self.speedY=-self.speedY
end
if self.x>a.x+a.w or self.x<a.x then
self.speedX=-self.speedX
end
if a.state==3 then
if self.speedY>0 then
if self.speedX>0 then
self.x=self.x+1*math.random(0,1)end
self.y=self.y+1*math.random(0,1)else
if self.speedX>0 then
self.x=self.x+1*math.random(0,1)end
self.y=self.y+1*math.random(0,1)end
end
end
function Ball:touchedEdgesOfPaddle()return(self.x>=paddle.x-paddle.size*.5-4 and self.x<=paddle.x-paddle.size*.5+4)or(self.x>=paddle.x+paddle.size*.5-4 and self.x<=paddle.x+paddle.size*.5+4)end
function Ball:howFarAwayFromTheCenterOfThePaddle()return self.x-paddle.x
end
function Ball:PaddleChock()self.speedY=-self.speedY
if self:touchedEdgesOfPaddle()then
self.speedX=self.speedX*1.1
end
end
function Ball:update()if self.x-self.radius<0 or self.x+self.radius>platform.window:width()-XLimit then
self.speedX=-self.speedX
end
if self.y-self.radius<0 then
self.speedY=-self.speedY
end
self.x=self.x+self.speedX
self.y=self.y+self.speedY
if self.y>pwh()+5 or self.y<-1 or self.x<-5 or self.x>platform.window:width()-XLimit+2 then secureNbr=secureNbr+1;table.remove(BallsTable,self.id)end
end
Paddle=class()function Paddle:init(a,l,n,e)self.x=a
self.size=l
self.dx=n
self.bonus=e
self.glow=0
end
function Paddle:grabBonus(a)a.timeLeft=1e3
for e,l in pairs(BonusTable)do
if l.bonusType==a.bonusType then
l.timeLeft=l.timeLeft+1e3
end
end
if a.bonusType=="PaddleGrow"then
self.size=60*XRatio
elseif a.bonusType=="PaddleShrink"then
self.size=20*XRatio
elseif a.bonusType=="BallClone"then
table.insert(BallsTable,Ball(math.random(1,platform.window:width()-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1))elseif a.bonusType=="BallGrow"then
for l,a in pairs(BallsTable)do
if a.y-a.radius<5*XRatio then
a.y=a.y+6*XRatio
end
a.radius=a.radius+5
end
elseif a.bonusType=="BallShrink"then
for l,a in pairs(BallsTable)do
if a.y-a.radius<5*XRatio then a.y=a.y+6 end
if a.radius>4*XRatio then a.radius=a.radius-4 end
end
end
end
function Paddle:paint(a)a:setColorRGB(0,0,200)a:drawImage(image.copy(paddleImg,math.abs((self.size/image.width(paddleImg))*image.width(paddleImg)-2),math.abs(image.height(paddleImg))),self.x-.5*self.size,platform.window:height()-14)if self.glow>0 then
a:setColorRGB(255,100,0)fillRoundRect(a,self.x-1,platform.window:height()-13,self.size-.5*self.size,3,1)self.glow=self.glow-1
end
end
Block=class()function Block:init(a,l,e,n,d,t)self.x=a
self.y=l
self.w=e
self.h=n
self.state=d
self.id=t
end
function Block:paint(a)a:setColorRGB(0,0,0)a:fillRect(self.x,self.y,self.w,self.h)if self.state==1 then
a:setColorRGB(0,255,0)elseif self.state==2 then
a:setColorRGB(0,0,255)elseif self.state==3 then
a:setColorRGB(200,200,200)end
a:fillRect(self.x+1,self.y+1,self.w-2,self.h-2)end
function Block:destroy()if self.state==2 then
self.state=1
table.remove(BlocksTable,self.id)table.insert(BlocksTable,self.id,self)elseif self.state==1 then
table.remove(BlocksTable,self.id)table.insert(BlocksTable,self.id,0)end
if self.state<=2 then
tmpCount=tmpCount+1
end
end
Bonus=class()function Bonus:init(l,e,a)self.x=l
self.y=e
self.bonusType=a
self.timeLeft=-10
end
function Bonus:paint(a)a:setColorRGB(0,0,0)a:fillRect(self.x,self.y,15,15)a:setColorRGB(200,0,200)a:fillRect(self.x+1,self.y+1,13,13)a:setColorRGB(255,0,0)a:fillRect(self.x+2,self.y+2,11,11)end
function Bonus:update()self.y=self.y+1
end
function Bonus:fallsOnPaddle()return(self.y+4>platform.window:height()-16)and(self.x>=paddle.x-paddle.size*.5-4 and(self.x<=paddle.x+paddle.size*.5+4))end
function Bonus:destroy()self.y=self.y+pwh()table.remove(FallingBonusTable,1)end
function resetBonus(a)if a.bonusType=="PaddleGrow"then
paddle.size=40*XRatio
elseif a.bonusType=="PaddleShrink"then
paddle.size=40*XRatio
elseif a.bonusType=="BallClone"then
elseif a.bonusType=="BallGrow"then
for l,a in pairs(BallsTable)do
if a.radius>4*XRatio then a.radius=a.radius-5*XRatio end
end
elseif a.bonusType=="BallShrink"then
for l,a in pairs(BallsTable)do
if not a.radius==4*XRatio then a.radius=a.radius+5*XRatio end
end
end
end
gameLogo=image.new("œ\0\0\0D\0\0\0\0\0\0\08\1\0\0\16\0\1\0alalalalalalalalalalalalalalalÿÿ÷^ÖZ÷^µVÖZöŞ÷ŞÕÚsÎÖÚ\23ãÖÚÖZÿÿalalalalalalalalalalalalalalalalalalalalalalalalalÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿ\16BÿÿalÕÚÖÚ÷Ş\23ã´Ö0ÆÕÚ\24ãöŞÕÚal\0\0ÿalalalÿalalalÿalalalalÿalalalalalalalalalalalalÿalalalalalalalalalalalalalalalalalalalalalalalalalµV\16BÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿalalalalalalalÿÿalalµVÖÚÖÚÖÚöŞöŞ\24ã´Ú\14ÆÕÚ\23ãöŞÖÚal\16Bÿÿalalÿÿÿÿÿÿÿÿÿÿalalalalÿÿalalalalalalalÿalalalalalalalalalÿÿalalÿÿalalalalalalalÿÿalalal\16Bÿalalalalalalalÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿÿalÿalalÿalalalalalalalalalalalalalalalalalalalalÿÿÿalalalalalalÿÿÿ\16BÖZÖÚ÷Ş÷ŞÖÚÖÚ÷Ş\24ãÔÚ.ÆÕÚ\24ã\24ãÖÚµÖalµVÿalalalÿalalalalalalÿÿÿalalalalalalalalalalalalalÿalÿalalalÿÿÿalÿÿalalÿalalalalalalÿÿalÖÚÖÚÖÚal\16Bÿalalalalalÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿÿalalÿalalÿÿÿalalÿalÿalÿÿÿalalalalalalalalalalalalalalÿÿalalalalalalalalal\0\0ÿalÖÚÖÚ÷ŞÖÚµÖÖÚÖÚ÷Ş8ãÔÚ.ÆÕŞ8ç÷ŞöŞÖÚ÷ŞalµVÿalalalalalalalalalalalalalÿ\0\0alalalalalalalalalalÿÿalalalalalÿÿÿÿÿÿÿÿalalalalÿÿÿ\0\0ÖÚÖÚÖÚÖÚµÖalÿalalalÿÿÿalÿalalÿalalalalalalalalalalalalalalalalalÿalÿalalÿalÿalalÿÿalalalÿÿalalalalalalÿalalalalalalalalalalalalalalÿÿalalalalalalalalalÿµValÖÚÖÚöŞÖÚµÖµÚÖÚöŞ÷Ş8çÔŞ/ÊöŞ8ç\23ãöŞÖÚÖÚ÷ŞalµVÿalalalalalalalalalÿÿàÿÿÿ\0\0ÿalalalalalalÿÿalalalalalÿÿalalalalÿalalalalalalÿalalÖÚ÷ŞÖÚÕÖ÷ŞÖÚalÿÿalalÿÿalalÿalalalalalÿalalalÿalalalÿalalalÿÿÿalÿÿalalÿÿalalalÿÿalÿÿalÿalalalalalÿÿalalalalalalalalalalalalalalÿalalalalalalalalalÿµValÖÚÖÚ÷ŞöŞÖÚ´ÖÕÚ÷Ş÷Ş÷Ş8çõŞ.ÊÕŞ8ç8ç÷ŞÖÚÖÚÖÚÖÚalµVÿalalalalalalalal\0\0alÿÿÿalalÿÿalalalalalalalalalalalalÿÿÿÿalalÿalalalalalÿÿalÖÚÖÚ÷Ş”Ò”Ò÷ŞöŞÖÚalÿalalÿÿÿ\0\0ÿÿÿalalalalÿÿalalalalalalalalalÿalalÿalalÿÿalalalalalÿÿalalÿÿÿalalalÿÿalalalalalalalalalalalalalalalalalalalalalalalalalÿµValÖÚÖÚ÷ŞÖÚ÷ŞÖÚ”ÖÕÚ\23ã÷Ş÷Ş8ç\22ã.ÊrÎ\23ã8ç\23ãÕÚÕÚ÷ŞÖÚÕÚalÿalalalalalalÿÿÿµVÖÚÖÚÖÚÖÚµÖal\16Balalalalalalalalalalalÿalalÿalÿÿalalalalalal\0\0ÿalÖÚ÷Ş÷Ş“Î“ÎöŞ\24ãÖÚalğ^alÿalÿÿÿÿalÿÿalalalalalÿÿÿalalalalÿÿÿÿalÿÿÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿµValµÖÖÚöŞÖÚÖÚ\23ãöŞ“ÒÖÚ\23ã\23ã÷Ş8ç7çNÎî½´Ö8çYëÕÚµÖöŞ\23ãÖÚÖÚal\16BÿalalalalÿalÖÚÖÚöŞ÷Ş÷ŞÖÚÖÚµÖÿÿalalalalalalalalalalÿalÿalÿalalalalalalalalÿalalÖÚ\24ãöŞ“Î”Ò÷Ş\24çÖÚalÿalÿÿÿÿalalalalalÿÿalalalalalÿÿÿÿÿÿÿÿÿÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\16BÿalµÖÖÚÖÚöŞöŞöŞ8çöŞrÒÕÚ8ç\23ã\23ã8ç7çOÎÍ¹\15Â\23ãzïõŞÕÚ÷Ş\23ã÷ŞÖÚÖÚal\16Balalalÿal\31~ÖÚ8ç÷ŞÕÚÕÚ÷Ş÷ŞÖÚal÷^alalalalalalalalalalalÿalalalalalalalalalalalÿalµÖöŞ8çöÚrÎ”Ò\23ß\24ãÖÚµÖal\16BÿÿalalÖÚµÖ”ÒÖÚµÖal\16BalalÿµVµVÿÿalalÿÿÿÿalalalalalalalalalalalalalalalalalalalalalalalÿÿÿ\16B÷^µVÿalÿÿalalalalalalalalalalalalÿÿalalÖÚÖÚÖÚÖÚ÷Ş\23ãöŞÕÚ³Ö0ÊÕÚXë\23ã\23ã8ç7ëOÎÍ¹î½´ÖöŞ“Ò´Ö\23ã8çÖÚöŞÖÚÖÚÿÿalalÿalÖÚöŞ\24ãÕÚ\14ÂrÎ\23ã\24ãÖÚalal÷^alalalalalalalalalalalalalalalalalalalalalÿ\0\0alÖÚöŞ\24ãöŞQÆrÊ\23ß\23ãÖÚµÖalµValµValÖÚÖÚÖÚ´ÒÖÚÖÚalÿ÷^\16Bÿalalalal÷ŞµÖalalÿÿÿalalalalalalalalalalalalalalalalalalalalÿ\0\0ÿalÿalalalÿµVÿÿalalalalalalÿalalalalalÿalÖZÖÚÖÚ÷ŞÖÚÖÚ\23ã8çöŞ0Æî½\14ÂÕŞXëöŞ7ç8çWëOÒí½\14Â\14Âî½î½“Ò8çYëöŞµÖ÷ŞÖÚÖÚalÿÿÿalÖÚ÷Ş\24ãÕÚ\rÂ’Î\24ã÷ŞÖÚÖÚalalµVÿalalalalalalalalalalalalalalalalalalalÿÿalÖÚöŞ\23ã\23ãQÆQÆ\23ã\23ã÷ŞÖÚal÷^\16BÿµÖÖÚ\23ãµÖ´ÖÖÚÖÚÖÚalalalsNÖÚÖÚÖÚÖÚÖÚÖÚÖÚõÖalÿÿÿalalalalalalalalalalalalalalalalalalalÿalsNÿalÖÚÖÚÖÚ\16Bal\16B\0\0ÿalalalalal\0\0ÿalalalÿÿalÖÚöŞöŞöŞ÷ŞöŞ\23ãYëõŞ\15Âî½\14ÆõŞ7ç³Ö8ç\23ã7ëoÒí½\14Â\14Âî½í½QÊ\23ãYëöŞ”ÒÖÚ÷ŞÖÚalÿ\16BalalÖÚ8ç8çÔÚ\rÂ’Ò8ç\23ã÷ŞÖÚÖÚÖÚalÿ\0\0alalalalalalalalalalalalalalalalalÿÿalµÖÖÚ\24ã\24ã\23ãQÆqÆ\23ã\23ã\23ãÖÚal÷^µValÖÚ÷ŞöŞµÖÕÖöŞ÷ŞÖÚÖÚÖÚÖÚÖÚÖÚ÷Ş÷ŞÖÚöŞ÷Ş\24ãÖÚÖÚalµVÿalalalalalalalalalalalalalalalalalal\0\0alÖÚÖÚalµÖÖÚöŞÖÚÖÚÖÚÿÿÿÿÿalalal\0\0ÿalalÿµValµÖÖÚ\23ã÷ŞÖŞÕÚöŞ8çyï´ÖîÁ\14Â\14Êöâ\23ãÔÚ7ç´ÖõŞOÒíÁ\14Â\14Âî½\rÂ\14ÂÕÚzïöŞrÎÕÚ\24ãÖÚÖÚal÷^alÕÚöŞ8ç\23ã³Ö\fÂ³Ò8ç\23ãöŞöŞ÷ŞÖÚÖÚal\0\0\0\0alalalalalalalalalalalalalalalÿµValalÖÚÖÚ÷Ş8ç\23ãQÆrÆ\23ã\24ã\23ãÖÚal÷^alalÖÚ\24ã÷Ş´Ò´Ö÷Ş÷ŞöŞ÷Ş÷Ş÷ŞöŞÕÚöŞ÷ŞÖÚöŞ\23ãöŞ\23ãÖÚÖÚÿµVÿalalalalalalalalalalalalalalalal\16Bal÷ŞÖÚÖÚõŞÕÚ\24ã÷ŞÖÚöŞÖÚÖÚalÿÿÿÿalal\0\0ÿalalÿalµÖÖÚ÷Ş÷Ş\24ãÕÚ0Æ´Özïyï’ÒîÁ\14Æ.Ê´ÚÔÚÔŞXç0Â/ÊMÎ\14Â.Æ\14Â\14Â\14Â\14Â³Özï\22ãrÎÕÚ\23ã\23ãÖÚalal\16BÖÚ\24ã8ç\23ãQÎ\f¾³Ö8ç\23ã÷ŞöŞÖÚöŞÖÚÖÚalÿÿalalalÿÿÿÿÿÿÿÿÿÿÿÿalalÖÚÖÚÖÚöŞ8ç\23ãQÆrÆ\23ã\24ã\23ãÖÚal9galÖÚÖÚ\23ã\23ß“ÎsÎ\23ã\23ãöŞöŞÖÚÕÚÖÚÕÚ÷Ş8çÕÚÕÚöŞöŞ÷Ş\24ãÖÚÖÚÿÿalalalalalalalalalalalalÿ\0\0ÿÿalalÖÚ÷Ş\23ãöÚÕÚ8ç\23ãöŞÕÚöŞÖÚÖÚÿÿ\0\0ÿÿÿ\0\0ÿÿ\16BalµÖÖÚÖÚöŞ\23ã8ç´Ö\14¾³Öyïyï’Ö\rÂ.Ê.Î0Î\14ÆõâXë\15Â\rÆMÒ.Æ.Æ.Æ\14Â\14Æ\14Æ“Òzï7çrÎöŞ\23ã÷ŞÖÚÖÚÖÚÖÚÖÚ\23ãYë8çQÊ\v¾ÓÖ8ç8ç\23ã\23ãÕÚ“Ò÷ŞöŞÖÚal\16BalÿÿÿalalalalalalalalalalalÖÚÖÚÖÚöÚÕÖ\23ãYë\23ß0ÂrÆ\23ã\24ã\23ãÖÚalµValÖÚÖÚ\23ã\23ã“ÎrÊ\23ã\23ãÖÚ÷ŞöŞÖÚöŞöŞ\24ãYëÕÚQÊ0Æ“Ò\23ã\23ã÷ŞÖÚalÿ\16Bÿÿ\0\0ÿÿalalalalalÿÿalalalalÖÚöŞ÷Ş\24ãÕÚ´Ö8ç8çöŞÖÚ÷Ş\23ãöŞÖÚÿ\16B\0\0ÿÿÿÿ\16BalalÖÚÖÚÖÚ÷Ş8çöŞQÊ\14Â0Æ\22ãyï³Ö\rÆ.ÎNÖ\14ÊíÁÔâ\23ã/Â.ÆMÒ.Ê.Æ.Æ.Æ.Ê\rÆ’ÒyïöŞ0ÆÕÚ8ç\23ã÷ŞÖÚÖÚÖÚ\23ã\23ã8ç8çrÎ+ÂÓÖYë8ç8ç8ç´Ö“ÒöŞ\24ãÖÚÖÚÿÿÿalalalÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚ\24ã÷ŞöÚÖÚ\23ßYë\23ã0¾’Ê8ã8ç\24ãÖÚalÖZalÖÚÖÚ\23ã\23ã“ÎQÆ\23ã\23ãµÖ÷ŞöŞÕÚ÷ŞöÚYëyï³Öî½ÍµQÊ\23ã8ç\23ãÖÚÖÚalalalalalalÿÿ\0\0ÿalalÿalal”RµÖÖÚÖÚ÷Ş\23ã\23ã´Ö´ÖYëYë“Ò“Ò\23ã\23ã\23ãÖÚÖÚÿÿÿalÿµVÿÿÖÚÖÚÖÚÖÚ\23ã8çöŞ/ÆîÁî½´ÖXë³Ö-ÊNÎOÚ/Ò.ÎpÚQÊ/Â.ÊmÖNÊOÊ.Ê.ÊNÊ.ÆPÆ\23ãÔÚ\14ÂöŞYë8ç\23ãÖÚ÷Ş÷Ş\23ã\23ã\22ãsÎ\15Â+ÂÓÚYïyï8çöŞrÎ“Ò\23ã\23ã\24ãÖÚÿalÖÚÖÚÖÚalÖÚÖÚÖÚµÖÕÖÖÚÖÚÖÚ÷Ş\23ã÷Ş÷Ş\24ã\23ãrÎ´ÖšóXçPÂ’Ê8ç8ç\23ãÕÚalalalÖÚ÷Ş\23ã8ç“ÎQÆ7ç8çÕÖ\23ã\23ãöŞ8çÕÚYëyïrÎî½î½QÊ\23ãYë8ç\23ãÖÚÖÚalal÷ŞÖÚµÖµÖalalalÿ\16BalÖÚöŞÕÚÕÚ÷Ş\23ã\23ã8ç8ç´Ö´ÖYëYëqÎ\14Â´Ö8ç8ç\23ãÖÚÖÚÿÿÿÿÿ\16BÖÚÖÚ÷ŞÖÚÖÚ\24ãYëÕŞ/Ê\14Â\14Â0ÊrÎPÊNÎNÒoŞOÚOÒNÖ\14¾/ÆNÎmÚoÎoÊOÊNÎNÎNÊ/ÂQÊPÊ.ÆöŞšó8çÕÚÕÚ÷Ş8ç8çöŞqÎÎ¹í¹KÆôÚšó›ó\23ãQÊ\14¾rÎ8ç8ç\24ãÖÚ\16BalÖÚ÷ŞÖÚalÖÚ\24ãÖÚµÖÕÚ÷Ş÷ŞÖÚµÖµÖöŞ\23ã\24ã\23ãPÆ´Öšó\23ã0º’Ê8ç9ç÷ŞÕÚÖÚöŞÖÚÖÚ÷Ş\23ã8ç³Î0Â8ç8ã“Î\23ã8ç\22ã\23ã“ÒrÊ’Î/Æî½î½0ÂÔÚXë8çöŞ÷ŞÖÚÖÚÖÚÖÚµÖµÖÖÚÖÚalµVÿalµÖÖÚ÷Ş\23ã\23ã8ç8ç8çyïYë’Ò0ÆrÎrÎ/Æî½³Òzï8ç\23ã\24ãÖÚÕÚalÿ\0\0ÖZÖÚÖÚ÷Ş÷ŞöÚÕÚ8çyïÕŞ/Ê.Æ.Æ\14Âî½.ÆOÒoÖæoŞoÖnŞ/ÆPÊnÒŞÒÎoÎnÒnÒnÎOÆ\15Â\14Â\rÂÔÚšó\23ãQÊÕÚXëYëyïõŞ\14ÂÎ¹\r¾KÆ\21ã7çyï7ç\14Âí½qÎ8ç8ç\23ãöŞµÖalÖÚYëöŞrÊÕÚ\24ãöŞµÖÕÖ÷Ş÷ŞöŞÕÚÕÚ÷Ş8ç\23ã“Ò\15ÂQÊ“ÒRÊ/¶’Æ7ãYë\23ãöŞÖÚÖÚÖÚöŞöŞ\23ã8ç´Ò/º\22ß7ãQÂ7çzïÔÚqÊ0Âï¹Î¹\14Â\14Âï½\15¾PÆrÎÕÚ\23ã\23ã÷Ş÷Ş÷Ş÷ŞÕÚµÖ\23ãÖÚÖÚalalÖÚÖÚ\23ã\23ãöŞ\23ãYëzï\23ã´Ö’Ò/Æ\15Âï½î½\14Â\14ÂPÆ“ÒÕÚ8ç\23ã\23ãÖÚµÖalµVÖÚÖÚ÷Ş÷Ş\23ãÕÚÔÖYëšóÔŞ.Ê.Æ.Æ\14Æ\14ÂNÊoÒÚ°êâŞæPÊÎ¯ÚÍŞ¯Ö°ÒÖ®ÚÖÒoÊ/Æ.Æ-ÆQÊ´ÖqÊ\15ÂöŞšóYëXëÔÚ\14ÂÎ¹\r¾kÊ‘Ò0Æ\22ã\22ã\14¾\r¾/ÆöŞ8ç\24ã÷ŞµÖ´ÖöŞ9ç÷Ş”ÒÕÚ\24ã\23ãµÖ´Ò÷Ş\24ã÷ŞµÖÖÚ\24ãYëöŞ0Æ\14¾\14¾Î¹Î¹/¶’Æ8çšó8çÕÚÖÚ÷Ş÷ŞÖÚ÷Ş÷Ş8çÕÖ/ºÕÚ\23ß0Â8çšórÎî½\16¾ï¹î½\14Â\14Â\15¾/Â\15Âî¹“ÒYë8ç÷ŞöŞ÷ŞöŞÕÚÕÚöŞ÷ŞÖÚalÖÚÖÚ÷Ş\23ã8çöŞ’Î³Ò´ÖrÎ\15Â\14¾.Â0Æ\16Æ\15Â.Â.Â\14¾î¹0Æ´Ö\23ã\24ã\23ãÖÚalÿ÷ŞöŞ\23ã8çYëÔÖ’ÎyïyïrÒ\14Î.Ê.Ê.Ê/ÂoÎÚŞĞîĞæ¯â¯ê±ÎÑÒÏŞîâĞÚĞÚÏŞîâÎŞ¯ÖÎpÊNÊNÎ.Æ\15¾\14¾\14Â´Öyï\22ßrÎQÎ\14Æî½-¾kÊ-Â­µqÎqÎ\14Â\rÂ.ÂÔÚYë9ç\23ãÕÖÕÚ÷Ş\24ã÷ŞÕÖÕÖ\24ã8ç´ÖqÊ\23ß8ç\23ã“ÒÕÚ8çYëõŞ/Â\14¾\14¾Î¹Î¹/¶‘Â7ã»÷\23ãrÎÕÚ\23ã÷ŞöŞöŞöÚ8çöÖ/ºqÊ“Î/ºÕÚYë0Ê\14¾0¾\15ºî½.Æ\14Â\15¾/Â/Â\14¾“ÒYëYë\23ã\23ã\23ã\23ãÕÚÕÖöŞ\23ãÖÚÖÚÖÚ÷Ş\23ã8ç\23ãrÎ\14¾\14¾\15Â\15Â\15Â/ÂOÆPÊ\17Æ\15Â.Æ.Æ\14Âî½î½QÊ\22ã8ç\23ã÷ŞÖÚalÖÚöŞ\23ã8ç7ã“Ò/Æ´Ö³Ò/Ê.Î.ÎNÎNÒOÊoÖ°Ş°âñòñîğêğòóÖ\18Û\16ã\15ç\18ß\18ß\15ã-ë\rëğŞ²Ò‘ÊÒÖoÊ/¾/¾-ÆPÊ´ÒrÎ\r¾\14Â\rÆî½-Â‹Î-ÂÎ¹\r¾\14¾\rÂ-Â.ÆõÚšózï\23ã´ÖÕÚ\23ã\24ã\23ãÕÚ´Ö8ç8ç“ÒPÆ8çzï8ç“Ò³ÖYëyï³Ö/Â\14¾\14ÂÎ½Î¹Pºq¾’ÎöŞ³Ò0ÆöŞ8ç\23ã÷ŞÖÚÕÚXç\22ÛPº\14¾\15¾0ºQÆ³Ò\14Æ\14Â0¾\15¾\14¾/Æ/Â\15¾0Â/Â\14ÂQÊ´ÖöŞ8ç8çYë\23ã´Ö³Ò\23ß\24ã÷ŞöŞ÷Ş\23ã8ç8ç´Ö\14¾\14Â\14Â\15Â0Æ0ÆOÆoÊqÎ2Ê0ÆOÆ/Æ\15Â\14¾\14¾0Æ´Ö\23ã8ç\23ãÖÚÖÚµÖÖÚµÖrÎQÊPÆ\14Â\14¾\14Â\14Ê.Ò.ÎOÒoÖoÎÖĞæÑê\17÷\18÷\16ó\16÷\17ç\17ç\14ï.ï0ç0ë.ïLó,ó\15çñÚÑÖĞÚÎŞ®ÖoÎnÎmÒNÎ.Æ.Æ-Ê-Æ-Æ\14Â,Æ‹ÎMÆí½\fÂ\rÂ.Â-ÂNÆÔÖyï»÷XërÎ“Ò\23ã8ç\24ãÔÖ´ÖYëXërÊ/Â7çšóXë’Ò³ÒzïyïqÊ\14¾.Â\14Âî½î¹pºº\15¾î½î½PÆöŞ8ç\24ã\23ãöŞÕÖXë\22ÛPº\14¾/¾Q¾\15¾\15Â\14Æ/ÂQÂ\16¾\14ÂOÆ/Æ0¾PÂ/Â/Â.Âî½0ÆöŞyïšó8çrÎ“Ò\23ã8ç8ç\24ã\24ãYëYëõŞPÆ\14¾\14Â\14Â/ÆQÊPÊpÊÎ“ÖsÒQÊoÊOÊ/Â\14Â\14Â\14¾PÆ\23ãYë\23ãöŞÖÚÖÚöŞ“Ò0Æ\15Âî½\14Â\14Æ\14Æ.Ê.ÖNÖOÚoâŞ°êĞöñúñşñş\17ÿÎş«ú‰şˆş¨şÉş\tÿ)ÿHÿHû*÷+ó,ë\rçíæÌâÌŞ¬ŞŒÚŒÚlÖlÒLÒLÎLÎ,ÊlÊªÒKÊìÁ\fÆ\rÂ.ÂNÆNÆPÊ´Ö\23ãõŞ/ÂrÎ8çYë8çÕÖ´ÖšóyïqÊ.¾öŞ»÷XëPÊ³ÒšóXçPÆ\14Â.Â.Âî½î¹pºº/¾î½\14¾/ÆõÚYë9ç8ç\23ã´ÖXë7ßPº.¾/¾q¾/¾/Â.Æ/ÆrÂ0¾\14ÂoÊOÊPÂQÂPÂ/Â.Â\14Âî½QÊõŞ\23ãÔÚ/ÂqÊXëšóyïYëYë\23ãõÚrÎ\14Â\14Â.Â.ÆPÊrÎ‘Ò°Ò°ÖSÒTÒrÎpÎoÊ/Â\15Â\14Â\14Â/Æ´ÖõÚöŞ\23ãöŞ÷Ş÷â\23ã\23ã“Ò\15Æ\14Æ\14Ê\14Ê.ÒNÖNÚoâoæî°òğú\17û¯şmş®şJş¤ı í å@á åáåCî¤ú\4ÿDÿBÿ#û&ó\nëëæËâÊŞ‰ÚjÖkÖlÒKÒKÒ,Î,ÊlÎªÒLÊíÁ\rÂ\rÂNÆnÆNÆ\14Âî½î½\14Â\14ÂrÎ8çyïYëÔÖqÊöŞõŞPÆ.Â³Ò\23ãõŞ.ÂPÊõŞ´Ö/Æ.Â.Â.Â\14Âî½pº±º/¾\14Â\14Â.Â³ÒYëzïYëöŞ³ÒXë\23ßqº/ÂPÂ’¾PÂOÆOÊPÆ“ÂQÂ/ÆpÊoÊPÆqÂPÆOÆ/Æ\14Â\14¾\14¾\15¾\15¾\14Â\14¾/ÂÕÚ7ãöŞöŞõŞqÊ\14Â\15Â\15Â/Â.ÆNÆPÎrÒ±Ö³ÖSÎ3½ÕÉtÒpÎoÊOÆ/Â.Â\14Â\14Â\14ÂQÊÕÚÕÚÕÚ÷Ş\23ãYëzï\23ãQÎ\14Â\14Â\14Æ.Ê.Î.ÒoŞoââ°âñâ\17ëLú§ıèı#ı`à\0´\0”\0”\0˜\0œ@´\0Ù\0îÁú\"ÿAÿ ûæêÊŞ«Ú©Ú‰ÖjÒKÒKÒKÎ+Î,ÊMÆŒÎÊÒLÊÎ¹î½\14ÂNÆÊnÊ\14Âî½î½\14Â\14ÂPÊ\23ãšóyï´Ö\14¾\15Â\15Â.ÂNÂ\15Â\15Â\15Â.Â\14Â\15Â\15Â.Â.ÂNÂOÆ\14Â\14Â¾ÑºpÂ\15Æ/Æ.ÂqÎXë»÷šóÔÖPÆÕÚÕÒ‘¾OÂPÂ³¾QÂpÆoÎ‘Ê³ÆqÆOÊÎÎ‘Æ‘ÆpÆPÆOÆ.Â\15Â\15¾\14¾\14¾\14¾.Â\14¾\15Â\15¾\15¾\15Â\15Â\14¾\14¾\15Â\15Â/Æ/ÆOÊRÎ“Ö³ÚWÚWÁ\18¨¶ÉVÖQÎnÊoÊ/Æ.Â\14Â\14¾0ÆÕÚöŞµÖµÖöŞ\23ãYë›óšó´Ö\14Â\14¾\14¾.Æ.ÊOÎOÚoÚÚÑÖ\18×îæçùâüâø`àÂ¼\3µ#±#­\"±CµCµBµ!ÁÀáÁúAÿ û‚âgÎ‰ÖiÒJÎKÊKÎKÎLÊ\rÆ\rÆmÊ«ÎÊÒMÆÏ¹î½.ÂnÊÊÊ.Âî½\14¾\14Â.ÆOÆ\22ã›óšó³Ò\14¾î½î½.ÂNÂ\14¾î½î½/Â\14Âî½\14¾.ÂNÆNÆoÆ/Æ/ÂÑ¾\18»‘Â/Æ/Æ/ÆPÊöŞXç\23ãrÎ\14¾\15ÂQÂ’ÂPÂqÂÓÂ‘Æ‘ÊÒÒÎõÊ³ÊÎ±ÒÑÒÓÊ³Æ‘ÊpÊpÊOÆ/Â/Â/Â.Â.Â.Â.Âî½Î¹Î¹Î¹î½\14¾\14Â\15Â/Æ0Æ1ÊRÎ”ÖµÚ—Ş\26Ö\23Á\17 ¶ÉVÚ0ÎmÊNÆ.Æ.Â\14Â\14¾0Æ\22ã8ç÷ŞÖÚöŞöŞ\23ã8çXë´Ö\14Â\14¾\14¾.ÆNÊOÎOÖoÚÚÑÖ\17ÛÍæ…ù ü@äa¤#±„Å„Å„½£ÁÃÍåÉÄ½£¹¢ÅAæ\0ÿàúàÑ¤¹HÊ(Ê\nÂ\vÂ+Æ+Ê-Æ\14Â.ÂŒÎËÒËÖMÆÏ¹î½.ÂÊ®Î®ÊOÆ\14¾\14¾/Â.ÆOÆ\22ã»÷šó³Ò.¾\14¾îÁ.ÂnÂ.Â\14¾\14Â/Æ.Â\14Â\14ÂNÆNÆOÆoÊ/ÆOÆòÂ3¿²ÊPÎPÊOÊOÆPÆQÆ0Æ/Â/Âî½QÂ²ÂpÆ’ÆôÂÓÊÒÎĞÖóÖ6ÓóÚÏŞñŞ\19Û\20ÓóÎ±Ò°ÎÎoÎOÆOÂOÆ.Â.Â.Â.Â\14¾î½î½î½\14¾\14Â\14Â\15Â/ÆOÊQÎrÒÒÚÔŞ˜Ş\26Ö\23½\17œ”Å4Ò.ÆLÆ,Â\rÂ\r¾\14¾í¹\14ÂöŞYë\23ãöŞÕÚrÎPÊQÊqÊPÊ.Æ.Â.ÆNÆNÊOÎOÒoÖÖÑÚ\17ÛîŞ¦ñ\0ü Ôa€\3­d¹d¹C±c±ƒÁ¤Á¤¹Ã¹£µÂÉÀöÀò@¹âœÆ¹ç½É¹Ë¹\fÂ-Æ.Æ/ÂNÆ¬ÒëÖËÖMÊï½\14¾NÂ®ÎÎÎÎÎoÊ/Â.ÂOÆOÆOÆõÚYë\23ã‘Î.¾\14Â\14ÂNÂoÂ/Â\15Â/ÂOÆ/Æ\14Â/ÂOÆOÊoÊpÊOÎoÎ\18ÇT¿òÊpÒpÎpÊPÆ/Â\14Â\14Â/Â/Â.ÂqÂ³Æ‘ÊÓÊ\22Ç\20Ï\20×\17ß5×xÓ5×\17ß4Û6Ó7Ï5Ó\18×òÎ±ÎÒÊpÆoÆNÆNÆNÂ.Â.Â\14Â\14¾\14¾\14Â\14Â\14Â.ÆOÊoÊpÎ±Ö\17ß\18ã¶ŞúÕ\22¹\15˜½\16ÊìÁ\v¾\v¾ì½\r¾í½î½QÊ\23ã8ç÷ŞÖÚöŞQÊî½î½î½\14Â\14Â.ÆNÆ.ÆNÆOÊoÒoÒÖĞÚ\17ÛïÖ§í\0ü Ø`€ã #©#©ã \2¥Bµcµd­„±ƒ±£µ¡î`êÀ¤A€D©¦µˆ±ª±ì¹-ÂNÊOÊnÊËÖ\nÛëÚnÊ\16Â\15ÂnÆÏÎïÒïÒ¯ÎoÊnÆoÊOÊOÆqÊrÊPÊOÆNÂ.Â\14ÂOÆÆoÆ/ÆOÆoÊOÊOÆOÆOÊOÊpÊÎoÒÖ4Ç•«2«¯ÂÎÎpÆOÆ/Â.Â/ÂOÂNÆ²ÆÔÆ²ÎôÎ7ËWÏXÓWÓœÃ~³\28¯Û®»®›ªº®\24¿7Ç\23ÇôÊÒÊ²Æ‘ÆpÆoÆoÆOÆOÂ.Æ.Â.Â.Â.Â.Â.ÆNÆoÊoÎ°ÒĞÚ\17ßòŞuÖ™ÍÖ´\r”L±­½ŠµÊµë¹Ì¹í½Í¹QÊ7ã8ç\23ã÷ŞÖÚ8çrÎî½Î¹î½î½î½\14Â.Æ\14Â\14Â/ÆOÎoÎÖÑÖ\17Û­Şdñ ü`ä` â #©\3¥ã \3¥D±„¹…µ¥µ¤µäÁÁî@Ş\0ˆa„\3¡e©G©ˆ­ë¹MÆoÎÎ®Î\vÛ*ß\nÛÒ0Æ/ÆÊïÒ\15×\15×ÏÒ¯Î¯ÎÎpÎoÊ/Âî½\14ÂNÆNÂ.Â.ÆoÆ¯ÊÊOÊpÎÎÎoÊoÊoÎoÎÎ°ÒÑÒòÒU¿”›/ƒÎ®ÎÎpÆOÆOÆ.ÆOÆpÆoÊ²ÊõÊóÎ\21ÏxÏzË½»~«>—‚ü›{zšÚ‘9·²õÂÓÆ²Æ‘ÆpÆpÆOÆOÆOÆOÆ/Æ.Â.Â/ÂOÆOÊoÊoÎÎĞÖÑÖ2Ê²¹t¹\22¹“¨\nf”†˜†˜H©Êµ¬µÌ¹ÌµrÎyïzï\23ã÷ŞÖÚYërÎÎ¹Î¹Î½î½î½\14¾.Â\14Â\14Â\15ÂOÊoÎÒÑÖ\17Û¬âdõü¡ø`Øâ¨#©#¥\3¥E©†µÅ½\6Â\6¾\5ÆdÖ\"÷ Ö\0€¡”D¥%¥&¥h­\nºmÊ¯Ò°ÒÎÖ+ßJã*ßÎÖpÊOÊ¯Î\15×0Û0ÛğÖïÒïÒ°ÒÎÊoÊ/Â/ÆoÆoÊOÆOÆÊĞÎ°ÎÎ°Ò°Ò°ÒÎÎÒÎ°ÒĞÖñÒ3×uÃr—\rƒÎªÊnÎoÆOÂpÆpÆ‘Æ²Ê±ÊÓÊ\22Ë6ÓxÏ¼Ã¾¯Ÿ“¼‚r1…’‘q•0°„t€w€·€”•Q¶¯Ê°ÊÊoÊoÆOÆOÆOÆOÆ/Æ/Æ\15Â/ÆOÊoÊoÎÎÎñÚ±Ò1­\16Œ1˜r .˜\6ˆ\0€\0€\0€åœ‰±‹±¬µÌµ0Æ8çyï\23ã÷ŞÖÚ\24ãrÎî½î½î½î½\14¾\14Â.Â\14Â\15Â/ÆOÊoÎÒÑÖ\17ÛÍâ¦õ¢üãü ì\3­C¥D¥D¡†µ\aÊIÊiÊiÊˆÖ'ïdÿ Ò\0€â˜E¥\5¡\5¡g©\t¾ÎïÚğÚ\14ßjçjëKçïÚ‘ÎÎÏÒ/ÛPßPß0Û0Û\16ÛÑÚ±Ö°ÒÎOÊOÆoÊÊoÊpÊ°ÎğÎÑÒ±ÖÑÚÑÚÑÚ±Ö±Ö°Ö°ÒĞÖÑÖñÚ\18ãSËPƒë‚Œ®mÆmÊNÂoÂÆ‘ÊÒÎóÎôÎ\21Ï6ÏXÓ›Çß«Ÿ‡Y‚ô‘s“’¦q¦Pîn•Ñ„u€4€.•L¾ÊnÊnÊoÊoÊoÎoÎPÊOÊOÆ/ÂOÊoÊÎ¯Ò°ÖĞÖ\17ß±Òœ\v€\v€\nŒ\aˆ\2„\0€\0€\0€Ä˜H­I­j±«±î½rÊ“Ò\23ã÷ŞÖÚöŞ´Ö´Ö´ÖrÎPÆ\14Â\14Â\14Â/Â/ÆOÆOÊoÎÒÑÖ\17Û¬æ…õÃü$ıâì#µc©d¥†¡\aÂ©ŞÌÚíÚ\14ãMï‰ÿCÿÀÍ\1€C©D©äœåœg©\n¾ÍÖ/ã0ãNçŠïªïkë\15ßÑÖ±Ö\16ÛpãpãqãqãpãQãòŞÓŞñÚğÖÎpÎ°ÎĞÎ°ÎÒğÒ\17×òŞòŞòâ\18ã\18ãòŞòŞòŞÑÚñÚñÚñŞ\17ë1Ë.ƒ©‚JªLÂLÆLÂnÆoÊÒÑÖóÒ\20Ó\20Ó6×yÏŞ³Ÿ‹Ú‚3–Ö¦Y¯\23§³¦q¦q¢O¦\v¦j™Ñ„T€\16€Š¥kÆlÆMÆnÊÎ¯Ò°ÒÒÒoÎoÊoÎÎ°ÒĞÚğÚñÚ1ßñÚPÊí½ê¤\6„\1€\1„ƒ¤”ƒ”Åœ\6¥(¥I©‹­‹±‹­ï½\23ã\23ãÖÚÖÚ\23ã8çyï7ç’Ò\14¾î½\14Â\14Â/Â/ÆOÊoÊÒÑÖ\17ÛÎâ¦õ¢ü$ıâøáä\2İ\"å¤ágî\t÷,óM÷û«ÿ†ÿÀò¢Å„±Ä¹d­\4¡%¥‡­jÆNç°óïïÈóæïÇçŠß\16ÛÒÖ0ßç‘ç‘ç°ã®ß×MÏ-ÏN×OÛ\16ÛĞÖğÒğÎğÒğÖ\18ÛRÛR×2ÏQËQË0Ç\15Ã\15ÃğÒ\18ßòŞ\18Û\18ã\18ç0Ç,ƒÉ‚j¦*º*¾*ÂLÆÑ¾5»5»\21Ã\19Ó\18ß3ßšÃÿ<ƒñ‘\23«8«³¦.íË™«™«È¥Ç¥L‘q€\16€ÊéµJÂKÆmÊQÆ\18º\17ºpÎÎÎÒ°Ò°Ò‘ÒSÊ2Æ‘ÎòŞ\18ßRãğŞŒµ\5€\1€\1„Åœ\6¡äœåœåœçœ(¥J©‹±Œ±\15Â\23ã8çöŞöŞ÷Ş\24ãYëyï´Öî½î½î½\14Â\14Â/ÆOÆoÊÒÑÖ\17Û\16ÛÈí@üÂü€ô@Ü@Ô€Ü éÃùEş¦şÇş\6ÿ#ÿàú\0Ş£½\5ÆÄÁƒµC­d­ÆµªÒ­óïÿÍ÷Éóãï€×`Ç ÓLßñÚPßç°çÎãË×¨Ç¥·ƒ«c§F³JÃM×/×\15Ó\16Ó\17×1ÛQÓO¿N³,£+“++‡\nƒè‚ª¢ÎÂğÖñÚ\17ß\17ç0ÇNƒ\rƒ‹¢\t¶È¹\tº¯¶w›¸ƒWƒ\21·\18×\16ß3×œ¯ƒV‚\147¯Ô¢ìh™i•I•i•i™g¥§¥¨¡îŒ1€+€'™\bºIÆmÆó±õ‘„0ÂQÂpÊ¯Ò°ÒĞÖsÊ5©\18ŒĞµÒÖÑÚ\17ßÏÖk±\5„\1€\1„Ã˜\4¡ä˜Ä”Å˜Æ˜\a¡I©j­Œ±ï½\23ã8çöŞÖÚÖÚ÷Ş8çyïÕÚî½î½î½îÁ\14Â\15Æ/ÆoÊÒÑÖ\17ÛÎÚ†í\0ü`ô Ì\0”\0Œ\0\0¤ À`ĞÀØ\0Ù@Õ Ù€Õ Á!±ƒµ„µ„±„±„µ\aÂêÚË÷êÿç÷¢ç Óa¶ \"Ëiã-ßnß®çíçÊÛ¦Ë„»e·e¯C£ ‹\1—\b»íÒÏÖĞÖ\17Û0Ó+³\a‹Æ‚Å‚ÆÇ’é–\t“ÇŠb‚F­ÆÎÖïÚğâ\16Çr‡Q“¬¦È±¦±Œ¦t“uƒÒ‚Ğ¦ñÊĞÖÎÚ5Ç¾—Ú‚¯Ô¢Ó¢/š‰™'•(•(•j•Šh©¨©è©M™1€\r€Ç”Ç±'¾+¾²©”ˆ\14€\14º0¾nÊ¯ÒÒĞÖSÆÔœ\15€n­pÆÎÏÖ®ÒK­\a„\3€\1„Ã”\4Ã”£”¤”Æ˜ç I¥j­Œ±0Æ\23ã8çöŞÖÚÖÚöŞ\24ãYëÔÚî½î½î½îÁ\14Â\15Æ/ÆoÊÒÑÖ\17Û¬ÚCí\0ü@à €a€ŒŒ€‚€ÂÃœãœÂœa”\0Œ€ à¨\0©B©„­¤­\5º‡Î(ãÇ÷äû ë€¾\4ºfÆ%º¦Ê(Û*×‹ßìçÊß§ÓgË&Ã\aÃ\a¿æ²\3Ÿà‚b’jÂÖ¯ÖğÚìºÃ‚£††š©®ª²©®‰®©¦¨’D‚€)¶ŒÎ­Ò®Ú\15Ã”“t›ª†±*¦0‡\17ƒ+‚è‘ŒÂ¯Ò®Î¬Ö5»¾ƒ·‚¬‘\21§pÌ™H•\6•(•I•‹•¬¡©±Éµ\b¶Œ¥€\14€È†­æµ\nºp¥q„\v€ìµ.¾MÆnÎÎÏÖ2Â’”\f€L©\14¾NÆÎÒÎl±\nŒ\5€\1„Ã˜\4Ã”£”¤”Æ˜\a¡)¥j©­µ´Ö8ç\23ãöŞµÖÖÚ÷Ş\23ã8ç³ÖÎ¹î½\14Â\14Â\14Â\14ÂOÆoÊÎÑÖ\17Û¬ÚCñ\0ü Ğ@€â \3¡#©#©D©¥¹åÁ\5Æ%Æ¤µâ˜À¤ ÉÀÍ`µc©¥±FÂÇÒHçÅ÷À÷ ÊãµÆÒçÖ§Ê‡Æ‡ÂçÎ¨ßÉß¨×H×\tÓÈÊˆÂˆÂH¾eªa Æ©kÊÒÌÊÈ¦¢‚†–«¾¬Ê‹ÂIº)ºI¶gšäÀ€§­J¾kÆkÒî¾”“tŸª)¦îÍ‚¨…f•jŒºlÆlÆjÎ\21·¿ƒ¸‚‹²-šŠ•'•\a•I•j•­•î¥ì¹\nÂ)ÆÌ±Ñ€\15€¨…©Æ±É±..€\b€Ë±\fº+¾MÆmÎÎÖ\16¾\15ˆ\t€*¥í¹\r¾ŒÎŒÎlµ\r”\b„\1„Ã˜\4Ã”¤”Å˜æœ\b¥J©k­Î¹öŞYë\23ãÖÚµÖÕÚöŞöŞöŞ“Ò0Æ/Æ\14Â\14Â/Æ/ÆOÊoÎÒÑÖ\17Û¬ÚCñ\0ø Ì@€Âœ\3¡\3¡\2¡\2¡D­d±„µ¤¹¤±c©a¹€êÀòÀÉ\"©…­\6º¨ÎHçÄ÷€ë€©DÆæÖeÂ&º&º\6¶åÆÆÛÆ×†Ï'ËçÆ†¾f¶f²&¶æ­‚‘À€#•\a²JÆ‹Æª¶¨¦©²‹Ê*Æ\t¾è±è±\aª&–ƒ`€f¥\b®)ºJÊÌ¶rSŸï¢.“Ì‚f%•\tª)®)²\nº*¾(Êõ²¿ƒÙ‚‹ì™‰•'•'•j•‹Í©/ºNÆmÎ¬Ò\14ºò„\15€§e¥¦­ˆ­ì”\v€&„‰­Ê±ê¹+ÂlÊ­Òï¹\r€\a€)¡«±ËµKÆkÊŒµ.˜\tˆ\2ˆã˜\4Ã”Ä”Æœç )¥k­k­Î¹ÕÚ8ç÷ŞÖÚalµÖÕÚÕÚöŞöŞöŞöŞÔÚqÎ/Æ/ÆOÊoÎÒÑÖ\17Û‹âBõ\0ø Ì@€Âœ\3¡âœÂ˜Âœ\3¥#¥C©d±ƒ±b­¹àê@ÿ\0Òá d©æ¹‡Ê'ã£ó ÛA¡$¾…ÊåµÅ±å±\5¶$ÇÄ×ÄÏƒ¿âª!á™Bšbš\"šÂ•\1‰@€Áˆ¥©\b¾JÂ‹Æ‹ÆjÂj¾(º\a²\a¦'f–EŠb\0€EÇ©è­\t¾«®O‡pOì‚¦ƒ„‡è©§±Ç±é±é¹\aÂô®¿ƒÙ‚¬nšë™‰•G™'‹™Ì¥ìÁNÎÎ°ÒÏÚP¾\19‰\14€¦f¥†­‡©Ê\n€%„h©©­È±ê¹KÆŒÎÍµ\f€\6€\bŠ­©±)¾JÆlµN˜\tˆ\2ˆäœ%¡ä˜Å˜æœ\b¡J©k­Í¹1ÆÕÚ\24ã÷ŞÖÚalÕÚöŞöŞ÷Ş\24ãYëzï›ó\22ã0Æ\14Â/ÆOÊÎÑÖ\17Û‹æBù\0ü Ü@€âœ\3¡ãœÂ˜Âœ\3¥D©D­„µ£¹¢µµáê@ûÀÉ`ˆC¥ÄµgÆ\aß£ï ß@¥äµ$¾¤­¤©Ä­\5²$ÇâËÁ»\0Ÿ`…`€ € …`…@À€`€\0€€„c¡æ±\bº*ÂjÂ©²§še…Š…Š…Š¥†D‚B\0€\4…¥¦©Èµi¦\vƒ\nƒˆ‚e\2€A€\4‘†¡†©‡©¨­Èµ\aÂÓªƒ\28ƒğ‰,šë™‰™GH©«©\r²NÊÒ°ÒğÚ\16ßsÂ\19\r€¤g¥†©f©Ê\n€%€G¥ˆ©¨±é¹*Â‹ÊÎµ\r€\6€æœh©ˆ­\bº)¾lµNœ\nˆ\3ˆäœ%¡ä˜Å˜çœ(¥j©k­0Æ\23ã8ç÷ŞöŞÖÚalÖÚÖÚÖÚ÷Ş\23ã8çzïzïÕÚ\15Â\14Â/ÆOÆpÎÑÖ\17Û¬ædõ@ü`ä`¤ã $¡\3Â˜\3$©d±¥¹åÁ\4ÂÃ¹âÁ\2ï\1ó ±\0€\"¡¤±&¾ÆÖ£ó€ë ­¤­\4º„©„©¥©æ±$¿à¿`¯\0š¡ŒaŒˆ¡ˆáŒÁˆ€ˆ`ˆ@„ÁŒc¥­§µI¶êª\b—¥†c‚C‚C‚D‚D†\3†\2\0€\3™D¡…¥§±h¢¨‚ÅÂ„£Œb„\0€b„$™†¥f¥§©Èµ\bÂ°®|ƒƒ–Šê™ê©ˆ©©±ë½MÆÎ°ÒÑÖñŞ1ãU¾²€\a€Äh¥†©f¥Ê\f€'€&¡‡©§­èµ*Â‹Êî¹.Œ\a€\6‡©‡­çµ\bºl±oœ\fŒ\5ˆäœ%¡äœåœ\a¡(¥j­k­1Æ8çYë÷ŞÖÚÖÚalÖÚÖÚ÷ŞöŞ\23ã8ç8çÔÚ0Æ\14Â\15Â/ÆOÆpÎÑÖ\17ÛÍâ¥õü¡ø€Ø\3¡D¥$¥#¡C©…µåÁFÎ‡ÖeÒDÊ£Úbû€Ş\0ˆa„C¥„­åµ¥Î£ó ïàµ„©äµd¥„¥¥­æµ$¿À³\1§\"ªã©„¥##„¡ƒ¥CC¡d¥d¡d¡e©¦­©ªI›\a“dŠ\4å•Å¡Æ©Æ¥Ä‘\"\0€ã˜$E¡†­G¢F‚ã€äeä”\1€b€\5‰Ef¥§­é¹)ÂŒº8›Ÿƒ\27ƒ\14’ÈÉ¡¨­Éµ\fÂnÊ°ÒÑÖñÚ1ã3Ûõ­\15€ „\5™g¥e¥e¥Ë.€J€%¡‡©§­èµ*ÂŠÊï½o\a€\6‡­‡­Ç±è¹k±pœ\14\aŒäœ%¡\5\6\a¡I©k­‹±0Æ8çYë÷ŞÖÚÖÚ÷^alÖÚ÷ŞÖÚöŞ\23ãÔÚ0ÆîÁ\14Â/Â/ÆOÊpÎÑÖ\17ÛÎŞ¦ñ€üÂü¡è#¡E¡d¥ƒ­Åµ\aÂgÒÉâ\tçææäâD÷BÿÀÉ\0€¡”c¥d©¤±…Ê‚ï€ëÀ±d¥Ä±d¥…©¦­\a¾\5¿ «€\2¦\3®¥©D¡D¡¤©Ä©d¥c¡„¡„¥d¥e©æ¥çš\a“†\a®æ¥Æ©§­Ç±Ç­Ä‘\1\0€ã”$$¡†­\6¤‚€%•†¥$A„Ä€gf•e¥§­\tºJÂkÊ²®\27ƒ>ƒ¸ŠÈ™Ç¥É­ê¹,ÂnÊĞÖñÚ\17ãRç–Æ\18\6€Â”¨­‡©e©f¥Ë/€L„F¥†­§­Èµ*ÂŠÊï¹\15ˆ\4€åœg©g©Ç±ÇµJ­N˜\14”\bäœE¥%¡\6¡'¥I©‹±¬±QÊ8ç8ç÷ŞÖÚµÖ÷^alÖÚ÷ŞöŞ\24ãÕÚ0Æî½\14Â\14Â\15Â/ÂOÆpÎ±Ö\18Û\16Û¨í\0üü¡ì$©e¥e¥¦­\bºjÊëÚ+ëKóJïg÷ƒÿ@Ş\0 „\2¡c©d¥„©dÊaçàÒ d©¥±d¥e©§±)¾¦¾`¦ ‘A•ƒ¥d¥\4¡\4d¥¤©ƒ!Àˆ\"•d¡e©\5¢ƒŠƒ‚Eè¹Çµ¦­¦­Æ­Æ¡c‰€\0€ã”#$¡†©¦\3b€%•f¡$Â”Ä„hˆ…f¡Ç±\tºJÂŒÊºRy‚ı‚·éÆ±\b¾kÆ­ÒğÚ1ãRçÖÎ•™\v€\0€&¡éµ§­‡©g¥ªŒ\r€,€G¡†©§­èµIÂ,Â/¥\v€\0€å˜g©g©§±Çµ\t©\f\fŒ\bŒåœE¥E¡&¡G¥i­‹±¬µQÊ\23ã\23ãöŞÖÚÕÚsNalÖÚ÷Ş\23ãYëÕÚî½î½\14¾\14¾\14Â\14Â/ÆpÎ±Ö\18Û\16Û¨é\0ø`ô€äÂÌ\2ÕCáÅágæêî+ókûŠÿ‡ÿDÿ@â`\0€á b±C©#¡d©dÆáÖàµA„d©¥­E¥f¥¨±\n¾iÂ\4ª\0…\0•£$¡\5¡¤¥\3¢¢‘À€\0€\2•…¥†­¤Á¡£¦¥§µ¦­¦¥¤™c‰¡€ €\0€Ã”\3$¡†©e‚€A€$•f¡D¡ã˜ÃŒå€\6&‘§©\tº)¾lÆÂ-¢\22‚¼‚¹P¢K¶kÎÎÚ\17ß4×¸¾–•,€\0€Åh¡g¥f¥†©g¥è”\n€\v€ŠŒ'¦±è¹Ëµ\r¡\v€\4€\0€å˜F¥F©¦­ÇµH­(Œ\b„\6ˆd¤˜¤˜\6¡g©i­«±¬µQÊ\23ã8ç÷ŞÖÚÖÚ÷^alÖÚ\23ãöŞ8çÕÚ\15Âî½\14Â\14Â/Â/ÆoÊÎ±Ö\17ÛïÚ‡Ù\0Ì@¸@° °@¼ ÔAõÂıDú„ú„şdò\0Ö`½\0\0€\1¥b±C©\3ãœd©DÂAÆ ¡\1€d¥…©%¡&¡ˆ­ê¹KÆ\a¶@• €@á•Bš‚šbšÁ‘à„\0€ŒE¡†©¦­¥©\" €À€âˆ\3•#•#\2€€ € €\0€¢Œã˜$¡†©EA€A€$•†¡E¡\4\3™Ä„„€ƒ€f¡Èµé¹+¾m¾L²¨¡\t…pö9‚z–™ª™²z®\25¦3\t€\0€å˜ˆ©g¡\5%¡E¡†©G¡&€\6€\a€GˆÇ”è˜‰\b€\5€\1€\0€Ä˜F¥%¡f©Çµ¨µe\3€\3„\2„\2„\2„Å˜h©‰­«±¬µQÊXëYë÷ŞÖÚÖÚ÷^alÕÚöŞ÷Ş8çÔÖ\14¾\14¾\14Â.Â/ÆOÊoÎÎ°ÒñÚÍÚe½\0€\0€\0€\0€\0€\0”\0¸`Ä Ä À ¼\0¬\0€\0€á a±‚µC­ä˜Ã˜ä˜e©\4º¡± „\0€$¡e©\5¡\6¡h©Êµ\v¾)¾å­@™€€à€€…À…` €\0€¢D¡e¥F¥†©Ç±…¡¢„\0€\0€\0€ €\0€\0€¢Œã”aˆ\0€A€Ã”$¡†©$™\0€ €\4•f¡E\4¡\4äb€\0€ƒˆf¥¨±êµLº+ºÈµf¥â”g€ï€RR1°€\r€\4€†€*•Ê­¨±%¡\5\5\5f©ˆ©\6™\2€\0€\2€\3€\3€\2€Ä”Ä˜\0€\0€¤\5\5¡%¥¦±Èµæœ\1€\0€\0€\0€\0€c'¥H©j­‹±\15Â\22ãYë\23ãöŞÖÚµValµÖÖÚ÷Ş\23ãÕÚ0Æ\14¾\14Â.Â/ÆOÆoÊÎ°ÒĞÖkÖBµ¢”\3¡Á Â˜¢”¢Âˆa€A€¡˜à¨â \3¡c±ÃÁâÅb±Ã˜£”Ã”Ä˜E©\4¾ã¹!¡\2%¡%¡\5\aG©©±ë¹\n¾\bº¥©\3Â”AŒ\1ˆAŒ¢”Ä˜%¡e¥e¡\6¡F¥‡­§­…¡\3•‚ŒaˆˆÂ”ã”E¡F¥ä˜¢Œ¢Ã”\4E¥EÃ”£”\5™F%åœ\5%Ä”ƒ¤%¡g©©­\v²\n¶ÈµÈ±‡©\3™ ”€@ŒA„`ˆ\1¡$¥J•®Ë­E©äœå˜å˜\5F¥ˆ©ˆ©&¡£”bŒAˆ‚äœf©f©Ã˜Ä”Ä”å˜åœ\5¡f©¨±‡±%¡£”BŒBˆBˆƒåœ\a¡(¥i­¬µQÊ\23ã8ç÷ŞÖÚ\16BalµÖÖÚ÷Ş÷ŞöŞÕÚ’Ò/Æ\14¾.ÂOÆOÆoÊÎ°ÒLÎÈÁ§µÇµd±C­\4¥$¡$¥\3\3™c±ƒ½e±†±¤¹£½b±âœ£”£”¤”Å˜e©DÂFÆ¦±f©&¥\5¡åœçœH¥‰±Ë¹ë¹Êµˆ±†©e¥åœä˜$E¡&¥&¡%%\6\6¡F¥‡©Ç©§©%¡ä˜\4™E¡e¥f¥&¥\5¡$\4™Ä˜Ä˜\5F¡F¥\6¡\6&™&™æœåœ&&¡&¡&¡F¡&¡H©Ê­Ê±¨±¨±§­f¥F¥%¥%\6™&¨±Èµ‡©HH\5Ä˜¥”Å˜\6(¥i©©±¨±g©\5ä˜%¡f©†©F¥f©F¥å˜Ä”Å˜\5&¥‡­ÈµÈ±g©åœÃ˜Ä”Ä˜å˜æœ\a¡I©j­Í¹ÕÚ8ç\23ãÖÚÿÿalÖÚ÷Ş÷Ş÷Ş\23ã8çõŞrÎ/Æ.ÆOÆOÆoÊoÊMÆ+Âê¹¨­E©#©äœäœã \4\4$¡%¡&¡%¡#¥\2¥â ¢”ƒ¤¥”Æ˜e­EÆGÆi©\b¡&¡\5æœ\a(¥‰­ËµË¹«µi­g©F¥&¡&¡E¡%¡åœå˜ä˜ä˜æœ\6'¡H¥h©h©'¥\6¡\5¡\5$%æœå˜ä˜ä˜Ä”Ä”å˜&¡&¡\a¡\6\6™\6™æœæœ\6¡'¥'¥&¡&¡\6'¡‰­ª±©±©±ˆ­G¥&¡F¥F¥&¡&¡G©g©%¥äœå˜Å˜¥”Å˜æ˜\a¡I©j­Š­‰­g­F¥&¡%¡%¡\5åœ\5¡\5Ä˜¤”Å˜åœ&¡g©ˆ­ˆ­h©&¡äœÄ˜Ä”Ä”Å˜çœ(¥j­Œ±QÊ\23ã\23ãöŞalÿalµÖÖÚÖÚöŞ\23ãYëzï\23ãPÊ.Â.ÆOÆoÊOÊ\rÂì¹Êµg©\5¡ä Ä˜¤˜Ã˜Ã”¤”¤”¤Å”Ä˜Ã˜â Áœ£”„¥”Æ˜èœh­FÆGÆJ©\t¡'¡çœçœ\b¡I¥j­ËµÌ¹¬µŠ­H©'¡\a¡\6åœÅ˜Å”Å”Ä”Ä˜æœçœ(¡H©I©(¥\a¡\6æœÅ˜ä˜å˜Å˜Å˜Å”Ä”¤”Å˜æœ\6\6\a¡\aæœæœ\a¡\a¡'¥(¥(¥\a¡\6¡\6'¡‰©‰­‰±©±¨­G¥\a¡\6¡\6åœåœæœæœÅ˜Ä˜Å˜Æ˜Å˜æ˜\a(¥j­‹±‹±j­H©'¡\6åœå˜Å˜Å˜Å˜Å˜¥”¥”Å˜æœ\6¡g©i­I©(¥\a¡å˜Ä”¤”¤”Å˜çœ\b¡J©k­î½\23ã\23ãöŞalÿÿal÷ŞÖÚÖÚ÷Ş\23ãYë8çPÊ\14Â.Â.ÂOÆOÆî½Ìµª±g©\a¡æœÅ˜Å˜Ä˜¤”¤”¤”Ä”Å˜Å˜Ãœâ Ãœ¤”¥”çœ\b¡\n¥j­GÆgÊj­*¥(¥\b¡\b¡)¥J©k­‹±¬µŒ±k­i©(¥\a¡æœæ˜Å˜Å”Å”Ä”Å˜çœ\b¡)¥I©J­I©(¥\aæœæ˜å˜å˜Æ˜Æ˜Å˜Å”Å˜æœ\a¡\a¡'¡\b¡\b¡\a¡\b¡\b¡(¡I¥I©I©(¥'¥\a¡(¡‰©Š­Š±ª±©±I©(¥\a¡\6æœÆ˜æœæ˜Å˜Å˜æ˜æ˜çœ\b¡)¥J©‹±¬µ¬µ‹±i©(¥\aæœæœÅ˜Å˜å˜æœÆ˜Æ˜æœ\a¡\a¡H©j­j­I©\a¡æœÅ˜Å˜Å˜Æ˜çœ)¥J©k­î½\23ã8ç÷ŞalalÿµValsNÖÚ÷Ş÷Ş8ç8ç’Ò\14Â\14Â\14ÂNÆ.ÂÍ¹¬µª±i­(¥\b¡çœæœæœÆ˜Æ˜Å˜Å˜Æ˜Æ˜åœäœÅ˜Æ˜çœ\b¡)¥+¥‹±gÊ‡ÎŒ±K©J©)¥)¥J©J©Î¹1ÆQÊQÊî½j­I©)¥\a¡æœæ˜Æ˜Æ˜Æ˜çœ\b¡)¥J©k­k­j­I©(¡\a¡çœæ˜æœçœçœæœæ˜çœ\b¡(¥(¥(¥)¥)¥)¥)¥I©I©J©k­k­J©H©H¥I¥ª­‹±‹±ª±©­J©I©(¥\b¡\a¡çœ\a\aæ˜æ˜\a\b¡\b¥)¥J©k­Œ±¬µŒµ‹±j©(¥\b¡\b¡\açœæ˜æœ\a¡çœçœ\b¡)¥(¥i©Š­k­j­I©\b¡çœæœæœçœ\b¡J©k­Œ±\15ÂöŞ÷ŞöŞalÿalÿµVÿÖÚÖÚ÷â\24ã8ç³Ö\14Â\14Â\14Â.ÆpÊQÊ0ÆÍ¹j­I©)¥(¥\a¡çœ\a¡èœçœÆ˜çœçœçœçœçœèœ\b¡k­ï½\17Â\15ÂˆÎ‡ÎŒ±L©k­J©J©k­Œ±ÕÚyïYëyïöŞï½J©J©)¥\b¡\b¡\a¡\a¡çœ\b¡)¥J©k­‹±Œ±k­J©)¥)¥\b¡\b¡\b¡\b¡(¥\b¡çœ\b¡)¥I©I¥I©J©J©J©J©J©J©k­Œ±k­k­i­i©j©ª­Š±¬µOÆ/Â0ÂÎ¹J©)¥\b¡\b¡(¡(¡\a¡\b¡\b¡)¥*©Œ±\16Â0Æ0Æ1Æ0Æ0Æ\16Âï½j­\b¡\b¡\b¡\b¡\a¡'¡\b¡\b¡)¥J©J©j­k­k­k­J©)¥\b¡\b¡çœ\b¡J©J©k­Œ±Î¹ÖÚ÷ŞöŞalÿalalalÿalÕÚÖÚ\24ã8ç´Ö/Â\14Â\14ÂOÆõŞyïXëµÖï½ï½ï½î½Î¹Œ±J©)¥)¥Œ±Î¹Í¹­µÎ¹Î¹Î¹Î¹“Ò8çYëõŞ«Ò‡Î\16ÂğÁ\15Â\16Â\15Âï½´ÖYëyïYëYëYëÖÚ\16Â\15ÂÎ¹)¥)¥)¥)¥)¥‹±ï½ï½\15Â\16Â\16Â\16Â\15Âï½Î¹J©)¥)¥J©J©)¥‹±Î¹ï½ï½î½î½ï½ï½î½\15Â\15Âï½\16Â\16Â\16Â\16Â\14Â\14¾\15¾.Â\14ÂrÎXë8çXëöŞ1Æî½Î¹k­J¥I¥)¥)¥k­î½ï½rÎ8ç8ç\24ã7ç7ç8ç8ç8çQÊÎ¹Î¹‹±)¥j­í½Î¹Î¹ï½Í¹k­Î¹\16Â\16Â\16Â\15Âï½Î¹Î¹Î¹Œ±J©Œ±ï½\16Â1ÆöŞ\23ãöŞalalÿalalÿalalÖÚ\23ã8ç\23ãQÊî½î½/Æ\22ãzïzï8çöŞöŞöŞ÷Ş\23ãÕÚ\16ÂÍ¹\15ÂÕÚ\23ãöŞöŞöŞöŞöŞöŞ8çzï›ó7ç¬Ò©Ò\22ã8ç\23ã\23ãöŞöŞ\24ã8ç8ç\24ã8ç8ç8çöŞ\23ãöŞ\16ÂÎ¹Î¹Î¹Î¹´Ö8ç\23ã\23ã\23ã\23ã\23ã\23ã\23ãöŞ\16ÂÎ¹Î¹ï½ï½Î¹”Ò\23ã\23ã\23ãöŞöŞ÷Ş÷ŞöŞ\23ã\23ã\23ã\23ã\23ã\23ã\23ã\22ãöŞ\22ß\22ßöŞ\23ãYëYëYëYë\23ã\23ã\23ãQÊÎ¹î¹Î¹Î½sÎ\23ã÷Ş\23ãYë9ç8ç8ç8ç8ç9çYë\23ãöŞ\23ã“ÒÎ¹RÊ\23ã\23ã\23ã\23ãÕÚ0ÆÕÚ\23ã\23ã\23ã\23ãöŞöŞ\23ã\23ã”ÒÎ¹RÊ÷Ş\23ãöŞ\23ã\24ã÷ŞalalÿÿalÿÿalÖÚöŞ8ç\23ãrÎ\15Â\16ÆPÊõŞ8ç8ç\24ã\24ã8ç8ç8çYëYë÷ŞÕÚöŞYëYë8ç8ç8ç8ç8ç8ç8ç8çYë\22ã«Ò«ÒxïšóYë8ç8ç8ç8ç÷ŞöŞÖÚÖÚöŞ8ç9ç8ç8çöŞÕÚöŞÖÚöŞ8çYëYë8ç8ç8ç8ç8çYëYëöŞöŞöŞöŞöŞÖÚ8çYë8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç\24ã\23ã\23ã\23ã\23ã8ç8çYë\23ãöÚöŞöŞöŞ8çYë8ç\24ã\23ã÷Ş÷Ş÷Ş÷Ş÷Ş÷Ş\23ã\24ã8çYë8çÕÚ\23ãYëYëYëYë8çöŞ8çYë8ç8ç8ç8ç8çYëYë8çÕÚ\23ãYë9ç9ç÷ŞÖÚÖÚalÿÿÿÿalÿalalÖÚ\24ã\23ãöŞÕÚÕÚöÚ÷Ş\23ã÷ŞöŞöŞ÷Ş\23ã\24ã\24ã8çYëYëYë9ç8ç8ç8ç8ç\24ã\24ã\24ã÷Ş\23ã8çöŞ«ÒªÒ7çYë\23ã÷Ş\24ãöŞÖÚÖÚÖÚalÖÚÖÚÖÚ÷Ş÷Ş9çYëZëZëYëYë9ç8ç\24ã\24ã\24ã\24ã\24ã\24ã8ç9çYëYëzïzïZëYëYë9ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç8ç\24ã\24ã\24ã\24ã\24ã\24ã\24ã\24ã8ç9çYëZëzïzïZëYë9ç8ç\24ã\24ã\24ã\23ã÷Ş÷Ş\23ã\24ã\24ã\24ã8ç9çYëYëYë9ç9ç9ç9ç9ç9ç9ç9ç8ç8ç8ç8ç8ç9ç9ç8ç\24ã\23ã\23ã÷ŞöŞÖÚµÖµValÿÿÿÿalal\16BalÖÚÖÚ9ç8ç8ç8ç\24ã\23ã\23ã\24ã\23ãÖÚÖÚÖÚÖÚÖÚÖÚöŞ÷ŞöŞöŞÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚ÷Ş8çöŞ‹ÎªÒ7ç8ç÷ŞöŞÖÚÖÚalalalalalalalµÖÖÚöŞ÷Ş÷Ş÷Ş÷Ş÷ŞöŞÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚ÷Ş÷Ş÷Ş÷Ş÷Ş÷ŞöŞÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚöŞöŞ÷Ş÷Ş÷Ş÷ŞöŞÖÚÖÚÖÚÖÚÖÚÖÚµÖÕÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚöŞöŞÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚÖÚöŞöŞÖÚÖÚÖÚµÖalalsNalalÿÿÿalalÿÿalÖÚÖÚöŞöŞ÷ŞÖÚÖÚÖÚÖÚÕÚÖÚµÖÖÚÖÚµÖµVµVsNµVµV\16B\0\0alalalalµÖÖÚ\23ã8çõŞ‹ÎŠÎ\23ã8çöŞÖÚsNalal\0\0ÿÿÿ\0\0ÿÿÿalalÿ\0\0sNsNµVµV”R”RµVµVµV”RµVµV\21BU)\0\0ÿÿÿÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿÿÿÿÿalÿ\16BalalÿÿÿÿÿalÿÿÿalÖÚÖÚÖÚÖÚÖÚ”RÿalalalalalalalÿalÿalalÿÿalÿalµÖÖÚ÷Ş\24ãÕŞlÊkÎ\22ã9çöŞ÷Şal÷^\0\0ÿalalalalÿÿÿ\16Bÿÿÿalalalalalalalalÿÿalalalalalalalalalÿ\0\0ÿÿÿÿÿÿÿÿÿ\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16Bÿÿÿÿ\0\0ÿÿalalÿÿÿÿÿÿÿÿ\16B\0\0ÿÿalalalal\16BµVµVÿ\16Bÿÿÿÿÿÿÿ\0\0\0\0\0\0\0\0\0\0ÿalÖÚ÷Ş\23ãÕÚMÊKÊöŞ8çÖÚ÷Şal\16Balalalalalalÿÿÿÿÿ\0\0\0\0ÿÿÿÿÿÿÿÿÿÿÿÿÿ\0\0\0\0\0\0\0\0\0\0ÿÿalalalalÿÿÿÿÿÿÿÿÿÿalalalalalalalalalalalalalalalalalÿalÿalÿÿÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿÿÿÿÿÿ\16BµVµVµV\16BÿÿÿÿÿÿÿÿÿÿÿÿalalÿÿalalµValÖÚÖÚ\24ãöŞ²Ö²Ö\23ã\24ãÖÚ\16BÿÿÿÿÿÿÿalalÿÿÿÿÿÿÿÿÿÿÿÿÿalÿÿÿÿalÿÿÿÿalalÿalalalalalalalÿalalÿalalÿÿÿalalalalÿÿÿÿÿÿÿÿÿÿÿalalalÿalÿalalalalalalalalalÿÿÿÿÿÿalalalalalalalalalalalalalalalalalalalÿalalalalalalalalÿÿÿÿÿÿÿÿÿalalalalalÿalalalÿÿalalalalalalalalalÿÿµÖÖÚöŞ÷ŞöŞöŞ÷ŞÖÚ÷Şalalÿÿalÿalÿÿÿÿÿÿÿÿÿÿalÿÿÿÿÿÿÿÿÿÿÿÿÿÿalalalalalalalalalalalalalalÿÿÿÿalalÿÿÿalalalalalalalalalalalalÿÿalÿalalalalalalalÿalalÿalÿalÿÿalalalalalalalalalalalalalalalalalalÿÿÿalalalalalalalalalÿÿÿÿÿÿÿÿÿalalalalalalalalalalalalalalalalalalalalÿ\16BÖZÖZalalalalalalalalÿÿÿÿ”RÖZÖZ÷^ÖZµVsN÷^µVµVÿ\16B\16Bÿÿÿÿÿÿ\0\0\0\0\0\0ÿalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalÿÿÿÿalalÿalalalÿalalalalalalalalalÿalalÿalalÿalalÿalÿalalalalal")paddleImg=image.new(".\0\0\0\n\0\0\0\0\0\0\0\\\0\0\0\16\0\1\0alal/„P„Qˆsˆ•Œ•Œ¸Œ¸Œalalalalalalalalalalalalalalalalalalalalalalalalalal¸Œ¸Œ•Œ•ŒtˆQˆP„P„alalal/„P„QˆÖ˜™±\26¾;Â\\Â\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Â;Â\26¾\26¾7¡sˆQˆP„al/„/„Qˆ7¡ß÷ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ¼ÒsˆP„/„/„/„sˆÚâ{û{÷{÷{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{÷{û{û7¡P„0„/„P„tˆsæsòsæsæsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsæsòsòU±QˆP„/„P„sˆÓÌŒåŒåŒÙŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÙŒÙŒåŒåÓ˜QˆP„/„P„sˆtˆÌÌÆä„Ü„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ü„àÈà³¤sˆQˆP„alP„sˆtˆ4¹“å7¡8©úúúÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒúúÙ˜ÙŒµİ“Í•ŒsˆQˆalalalsˆtˆ³¤-åÖ˜ÙŒÙŒÙŒalalalalalalalalalalalalalalalalalalalalalalalalalalÙŒÙŒÙŒÖ˜-å³¤tˆsˆalalalalalalalÌ°‰Ô±¬alalalalalalalalalalalalalalalalalalalalalalalalalalalalalal³¤‰ÔÌ°alalalalal")