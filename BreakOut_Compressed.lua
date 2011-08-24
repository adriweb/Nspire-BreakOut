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
gameLogo=image.new("�\0\0\0D\0\0\0\0\0\0\08\1\0\0\16\0\1\0alalalalalalalalalalalalalalal���^�Z�^�V�Z������s���\23����Z��alalalalalalalalalalalalalalalalalalalalalalalalal��alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal��\16B��al������\23��0���\24�����al\0\0�alalal�alalal�alalalal�alalalalalalalalalalalal�alalalalalalalalalalalalalalalalalalalalalalalalal�V\16B��alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal��alalalalalalal��alal�V����������\24��\14���\23�����al\16B��alal����������alalalal��alalalalalalal�alalalalalalalalal��alal��alalalalalalal��alalal\16B�alalalalalalal�alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal���al�alal�alalalalalalalalalalalalalalalalalalalal���alalalalalal���\16B�Z������������\24���.���\24�\24��ڵ�al�V�alalal�alalalalalal���alalalalalalalalalalalalal�al�alalal���al��alal�alalalalalal��al������al\16B�alalalalal��alalalalalalalalalalalalalalalalalalalalalalalalalal���alal�alal���alal�al�al���alalalalalalalalalalalalalal��alalalalalalalalal\0\0�al�������ڵ�������8���.���8���������al�V�alalalalalalalalalalalalal�\0\0alalalalalalalalalal��alalalalal��������alalalal���\0\0�������ڵ�al�alalal���al�alal�alalalalalalalalalalalalalalalalal�al�alal�al�alal��alalal��alalalalalal�alalalalalalalalalalalalalal��alalalalalalalalal��Val�������ڵֵ�������8���/���8�\23���������al�V�alalalalalalalalal������\0\0�alalalalalal��alalalalal��alalalal�alalalalalal�alal������������al��alal��alal�alalalalal�alalal�alalal�alalal���al��alal��alalal��al��al�alalalalal��alalalalalalalalalalalalalal�alalalalalalalalal��Val���������ڴ���������8���.���8�8�����������al�V�alalalalalalalal\0\0al���alal��alalalalalalalalalalalal����alal�alalalalal��al�����ޔҔ�������al�alal���\0\0���alalalal��alalalalalalalalal�alal�alal��alalalalal��alal���alalal��alalalalalalalalalalalalalalalalalalalalalalalalal��Val�����������ڔ���\23�����8�\22�.�r�\23�8�\23�����������al�alalalalalal����V�������ڵ�al\16Balalalalalalalalalalal�alal�al��alalalalalal\0\0�al�����ޓΓ���\24���al�^al�al����al��alalalalal���alalalal����al����alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal��Val����������\23��ޓ���\23�\23���8�7�N��8�Y��ڵ���\23�����al\16B�alalalal�al�������������ڵ���alalalalalalalalalal�al�al�alalalalalalalal�alal��\24��ޓΔ���\24���al�al����alalalalal��alalalalal�����������alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\16B�al������������8���r���8�\23�\23�8�7�O�͹\15�\23�z�������\23�������al\16Balalal�al\31~��8�������������al�^alalalalalalalalalalal�alalalalalalalalalalal�al����8���rΔ�\23�\24��ڵ�al\16B��alal�ڵ֔��ڵ�al\16Balal��V�V��alal����alalalalalalalalalalalalalalalalalalalalalalal���\16B�^�V�al��alalalalalalalalalalalal��alal����������\23����ڳ�0���X�\23�\23�8�7�O�͹��ޓҴ�\23�8�����������alal�al����\24���\14�r�\23�\24���alal�^alalalalalalalalalalalalalalalalalalalalal�\0\0al����\24���Q�r�\23�\23��ڵ�al�Val�Val�����ڴ�����al��^\16B�alalalal�޵�alal���alalalalalalalalalalalalalalalalalalalal�\0\0�al�alalal��V��alalalalalal�alalalalal�al�Z����������\23�8���0��\14���X���7�8�W�O��\14�\14���8�Y��޵�������al���al����\24���\r�\24�������alal�V�alalalalalalalalalalalalalalalalalalal��al����\23�\23�Q�Q�\23�\23�����al�^\16B�����\23�ִ�������alalalsN����������������al���alalalalalalalalalalalalalalalalalalal�alsN�al������\16Bal\16B\0\0�alalalalal\0\0�alalal��al������������\23�Y���\15��\14���7��8�\23�7�o��\14�\14���Q�\23�Y��ޔ�������al�\16Balal��8�8���\r�8�\23���������al�\0\0alalalalalalalalalalalalalalalalal��al����\24�\24�\23�Q�q�\23�\23�\23���al�^�Val�����޵�����������������������������\24�����al�V�alalalalalalalalalalalalalalalalalal\0\0al����al�����������������alalal\0\0�alal��Val����\23���������8�y����\14�\14���\23���7����O���\14�\14��\r�\14���z���r���\24�����al�^al����8�\23��\f³�8�\23�����������al\0\0\0\0alalalalalalalalalalalalalalal��Valal������8�\23�Q�r�\23�\24�\23���al�^alal��\24��޴Ҵ�������������������������\23���\23�������V�alalalalalalalalalalalalalalalal\16Bal����������\24�����������al����alal\0\0�alal�al��������\24���0ƴ�z�y����\14�.ʴ�����X�0�/�M�\14�.�\14�\14�\14�\14³�z�\22�r���\23�\23���alal\16B��\24�8�\23�Q�\f���8�\23�������������al��alalal������������alal��������8�\23�Q�r�\23�\24�\23���al9gal����\23�\23ߓ�s�\23�\23���������������8�����������\24�������alalalalalalalalalalalal�\0\0��alal����\23�����8�\23�������������\0\0���\0\0��\16Bal��������\23�8��\14���y�y��\r�.�.�0�\14���X�\15�\r�M�.�.�.�\14�\14�\14Ɠ�z�7�r���\23�������������\23�Y�8�Q�\v���8�8�\23�\23��ړ�������al\16Bal���alalalalalalalalalalal����������\23�Y�\23�0�r�\23�\24�\23���al�Val����\23�\23��r�\23�\23�������������\24�Y���Q�0Ɠ�\23�\23�����al�\16B��\0\0��alalalalal��alalalal������\24��ڴ�8�8�������\23������\16B\0\0����\16Balal��������8���Q�\14�0�\22�y��\r�.�N�\14�����\23�/�.�M�.�.�.�.�.�\rƒ�y���0���8�\23���������\23�\23�8�8�r�+���Y�8�8�8�֓���\24��������alalal����������������������\24�������\23�Y�\23�0���8�8�\24���al�Zal����\23�\23��Q�\23�\23������������Y�y���͵Q�\23�8�\23�����alalalalalal��\0\0�alal�alal�R��������\23�\23�ִ�Y�Y�ғ�\23�\23�\23��������al��V����������\23�8���/����X��-�N�O�/�.�p�Q�/�.�m�N�O�.�.�N�.�P�\23���\14���Y�8�\23�������\23�\23�\22�s�\15�+���Y�y�8���rΓ�\23�\23�\24����al������al�����ڵ�����������\23�����\24�\23�rδ֚�X�P�8�8�\23���alalal����\23�8��Q�7�8���\23�\23���8���Y�y�r���Q�\23�Y�8�\23�����alal���ڵֵ�alalal�\16Bal����������\23�\23�8�8�ִ�Y�Y�q�\14´�8�8�\23����������\16B����������\24�Y���/�\14�\14�0�r�P�N�N�o�O�O�N�\14�/�N�m�o�o�O�N�N�N�/�Q�P�.��ޚ�8�������8�8���q�ι�K��ښ��\23�Q�\14�r�8�8�\24���\16Bal������al��\24��ڵ��������ڵֵ���\23�\24�\23�Pƴ֚�\23�0���8�9���������������\23�8��0�8�8��\23�8�\22�\23��rʒ�/���0���X�8������������ڵֵ�����al�V�al������\23�\23�8�8�8�y�Y��0�r�r�/��z�8�\23�\24�����al�\0\0�Z������������8�y���/�.�.�\14��.�O�o֏�o�o�n�/�P�nҍޏҏ�o�n�n�n�O�\15�\14�\r��ښ�\23�Q���X�Y�y���\14�ι\r�K�\21�7�y�7�\14��q�8�8�\23��޵�al��Y���r���\24��޵���������������8�\23��\15�Qʓ�R�/���7�Y�\23�������������\23�8��/�\22�7�Q�7�z���q�0��ι\14�\14��\15�P�r���\23�\23����������ڵ�\23�����alal����\23�\23���\23�Y�z�\23�֒�/�\15���\14�\14�PƓ���8�\23�\23��ڵ�al�V��������\23�����Y����.�.�.�\14�\14�N�oҏڰ��ޏ�Pʐί��ޯְҏ֮ڎ֏�o�/�.�-�Qʴ�q�\15��ޚ�Y�X���\14�ι\r�kʑ�0�\22�\22�\14�\r�/���8�\24��޵ִ���9��ޔ���\24�\23�ִ���\24��޵���\24�Y���0�\14�\14�ιι/���8��8���������������8���/���\23�0�8��r��\16���\14�\14�\15�/�\15��Y�8�������������������al������\23�8��ޒγҴ�r�\15�\14�.�0�\16�\15�.�.�\14��0ƴ�\23�\24�\23���al�����\23�8�Y��֒�y�y�r�\14�.�.�.�/�oΏڐ�����������������������ޯ֐�p�N�N�.�\15�\14�\14´�y�\22�r�Q�\14��-�k�-­�q�q�\14�\r�.���Y�9�\23�������\24�������\24�8��q�\23�8�\23����8�Y���/�\14�\14�ιι/���7��\23�r���\23���������8���/�qʓ�/���Y�0�\14�0�\15��.�\14�\15�/�/�\14���Y�Y�\23�\23�\23�\23�������\23���������\23�8�\23�r�\14�\14�\15�\15�\15�/�O�P�\17�\15�.�.�\14���Q�\22�8�\23�����al����\23�8�7��/ƴֳ�/�.�.�N�N�O�oְް�����������\18�\16�\15�\18�\18�\15�-�\r��޲ґʏҎ�o�/�/�-�Pʴ�r�\r�\14�\r��-�-�ι\r�\14�\r�-�.��ښ�z�\23����\23�\24�\23��ڴ�8�8��P�8�z�8�ҳ�Y�y��/�\14�\14�νιP�q����޳�0���8�\23�������X�\22�P�\14�\15�0�QƳ�\14�\14�0�\15�\14�/�/�\15�0�/�\14�Qʴ���8�8�Y�\23�ֳ�\23�\24�������\23�8�8��\14�\14�\14�\15�0�0�O�o�q�2�0�O�/�\15�\14�\14�0ƴ�\23�8�\23����ڵ��ڵ�r�Q�P�\14�\14�\14�\14�.�.�O�o�oΐ�����\17�\18�\16�\16�\17�\17�\14�.�0�0�.�L�,�\15��������ޮ�o�n�m�N�.�.�-�-�-�\14�,Ƌ�M��\f�\r�.�-�N���y��X�rΓ�\23�8�\24��ִ�Y�X�r�/�7��X�ҳ�z�y�q�\14�.�\14���p���\15���P���8�\24�\23�����X�\22�P�\14�/�Q�\15�\15�\14�/�Q�\16�\14�O�/�0�P�/�/�.��0���y��8�rΓ�\23�8�8�\24�\24�Y�Y���P�\14�\14�\14�/�Q�P�pʐΓ�s�Q�o�O�/�\14�\14�\14�P�\23�Y�\23��������ޓ�0�\15��\14�\14�\14�.�.�N�O�o�ް���������\17�������������\t�)�H�H�*�+�,�\r������ެތڌ�l�l�L�L�L�,�lʪ�K���\f�\r�.�N�N�Pʴ�\23���/�r�8�Y�8��ִ֚�y�q�.��޻�X�PʳҚ�X�P�\14�.�.���p���/��\14�/���Y�9�8�\23��X�7�P�.�/�q�/�/�.�/�r�0�\14�o�O�P�Q�P�/�.�\14��Q���\23���/�q�X��y�Y�Y�\23���r�\14�\14�.�.�P�rΑҰҰ�S�T�r�p�o�/�\15�\14�\14�/ƴ�����\23�������\23�\23��\15�\14�\14�\14�.�N�N�o�o�����\17���m���J��� � �@����C��\4�D�B�#�&�\n������މ�j�k�l�K�K�,�,�lΪ�L���\r�\r�N�n�N�\14���\14�\14�r�8�y�Y���q�����P�.³�\23���.�P��޴�/�.�.�.�\14��p���/�\14�\14�.³�Y�z�Y��޳�X�\23�q�/�P�P�O�O�PƓ�Q�/�p�o�P�q�P�O�/�\14�\14�\14�\15�\15�\14�\14�/���7�������q�\14�\15�\15�/�.�N�P�rұֳ�S�3���t�p�o�O�/�.�\14�\14�\14�Q���������\23�Y�z�\23�Q�\14�\14�\14�.�.�.�o�o�����\17�L�����#�`�\0�\0�\0�\0�\0�@�\0�\0���\"�A� ����ޫکډ�j�K�K�K�+�,�Mƌ���L�ι�\14�NƎ�n�\14���\14�\14�P�\23��y��\14�\15�\15�.�N�\15�\15�\15�.�\14�\15�\15�.�.�N�O�\14�\14�Ѻp�\15�/�.�q�X������P����ґ�O�P³�Q�p�oΑʳ�q�OʐΐΑƑ�p�P�O�.�\15�\15�\14�\14�\14�.�\14�\15�\15�\15�\15�\15�\14�\14�\15�\15�/�/�O�RΓֳ�W�W�\18���V�Q�n�o�/�.�\14�\14�0����޵ֵ���\23�Y����\14�\14�\14�.�.�O�O�oڐ���\18���������`�¼\3�#�#�\"�C�C�B�!�����A� ���gΉ�i�J�K�K�K�L�\r�\r�mʫ���M�Ϲ�.�nʎʎ�.��\14�\14�.�O�\22����\14���.�N�\14���/�\14��\14�.�N�N�o�/�/�Ѿ\18���/�/�/�P���X�\23�r�\14�\15�Q�P�q��Ƒʐ����ʳʐα����ʳƑ�p�p�O�/�/�/�.�.�.�.��ιιι�\14�\14�\15�/�0�1�RΔֵڗ�\26�\23�\17���V�0�m�N�.�.�\14�\14�0�\22�8���������\23�8�X��\14�\14�\14�.�N�O�O�oڐ���\17���� �@�a�#��ńń�������Ľ����A�\0����Ѥ�H�(�\n�\v�+�+�-�\14�.�����M�Ϲ�.ʮή�O�\14�\14�/�.�O�\22�����.�\14���.�n�.�\14�\14�/�.�\14�\14�N�N�O�o�/�O���3���P�P�O�O�P�Q�0�/�/��Q²�pƒ�����������6�������\19�\20��αҰΐ�o�O�O�O�.�.�.�.�\14����\14�\14�\14�\15�/�O�Q�r����ޘ�\26�\23�\17���4�.�L�,�\r�\r�\14��\14���Y�\23�����r�P�Q�q�P�.�.�.�N�N�O�O�o֏���\17��ަ�\0� �a�\3�d�d�C�c�������ù��������@��ƹ�ɹ˹\f�-�.�/�NƬ�����M��\14�N®�����o�/�.�O�O�O���Y�\23��.�\14�\14�N�o�/�\15�/�O�/�\14�/�O�O�o�p�O�o�\18�T���p�p�p�P�/�\14�\14�/�/�.�q³Ƒ���\22�\20�\20�\17�5�x�5�\17�4�6�7�5�\18��αΏҐ�p�o�N�N�N�.�.�\14�\14�\14�\14�\14�\14�.�O�o�pα�\17�\18����\22�\15���\16���\v�\v��\r���Q�\23�8�������Q����\14�\14�.�N�.�N�O�o�oҏ���\17��֧�\0� �`��#�#��\2�B�c�d���������`���A�D��������-�N�O�n���\n���n�\16�\15�n������ү�o�n�o�O�O�q�r�P�O�N�.�\14�OƏ�o�/�O�o�O�O�O�O�O�pʐ�oҐ�4Ǖ�2��ΐ�p�O�/�.�/�O�NƲ��Ʋ���7�W�X�WӜ�~�\28�ۮ������\24�7�\23����ʲƑ�p�o�o�O�O�.�.�.�.�.�.�.�N�o�oΰ���\17���u֙�ִ\r�L�����ʵ�̹�͹Q�7�8�\23�����8�r��ι���\14�.�\14�\14�/�O�oΐ���\17ۭ�d� �`�`��#�\3��\3�D�������������@�\0�a�\3�e�G����M�oΏή�\v�*�\nێ�0�/Ə���\15�\15��үίΐ�p�o�/��\14�N�N�.�.�oƯʏ�O�pΐΐ�o�o�o�oΐΰ�����U���/�ή�ΐ�p�O�O�.�O�p�oʲ�����\21�x�z˽�~�>�������{�z���ڑ9������ƲƑ�p�p�O�O�O�O�/�.�.�/�O�O�o�oΐ�����2ʲ�t�\22���\n�f�����H�ʵ��̵̹r�y�z�\23�����Y�r�ιιν��\14�.�\14�\14�\15�O�oΐ���\17۬�d�����`��#�#�\3�E���Ž\6�\6�\5�d�\"� �\0���D�%�&�h�\n�mʯҰ���+�J�*���p�Oʯ�\15�0�0������ҰҐΏ�o�/�/�o�o�O�OƏ��ΰΐΰҰҰҐΐΐҐΰ�����3�u�r�\r�Ϊ��n�o�O�p�pƑƲʱ���\22�6�xϼþ�����r�1���q�0���t�w�����Q��ʰʏ�o�o�O�O�O�O�/�/�\15�/�O�o�oΐΐ��ڱ�1�\16�1�r�.�\6�\0�\0�\0�圉�����̵0�8�y�\23�����\24�r�����\14�\14�.�\14�\15�/�O�oΐ���\17����������\3�C�D�D���\a�I�i�iʈ�'�d� �\0��E�\5�\5�g�\t�������\14�j�j�K��ڑΐ���/�P�P�0�0�\16��ڱְҏ�O�O�oʏ�o�pʰ����ұ������ڱְְֱ�������\18�S�P�낌�m�m�N�oƑ�������\21�6�Xӛ�߫��Y���s�����q�P��n�фu�4�.�L���n�n�o�o�o�o�P�O�O�/�O�oʏίҰ���\17߱Ҏ�\v�\v�\n�\a�\2�\0�\0�\0�ĘH�I�j����rʓ�\23������޴ִִ�r�P�\14�\14�\14�/�/�O�O�oΐ���\17۬����$���#�c�d���\a©�����\14�M��C���\1�C�D���g�\n���/�0�N���k�\15��ֱ�\16�p�p�q�q�p�Q��������֐�pΰ��ΰΐ���\17�������\18�\18���������������\17�1�.���J�L�L�L�n�oʏ�����\20�\20�6�y�޳��ڂ3�֦Y�\23���q�q�O�\v�j�фT�\16���k�l�M�nʏίҰҐҐ�o�o�oΐΰ�������1���P���\6�\1�\1�������Ŝ\6�(�I��������\23�\23�����\23�8�y�7��\14��\14�\14�/�/�O�oʐ���\17������$�����\2�\"��g�\t�,�M���������ń�Ĺd�\4�%���j�N�����������\16���0ߐ����ߍ�M�-�N�O�\16�����������\18�R�R�2�Q�Q�0�\15�\15���\18���\18�\18�\18�0�,�ɂj�*�*�*�L�Ѿ5�5�\21�\19�\18�3ߚ���<��\23�8���.��˙����ȥǥL�q�\16�ʐ�J�K�m�Q�\18�\17�pΐΐΐҰҰґ�S�2Ƒ���\18�R��ތ�\5�\1�\1�Ŝ\6�����(�J�����\15�\23�8�������\24�Y�y�����\14�\14�/�O�oʐ���\17�\16���@�����@�@Ԁ� ���E�����\6�#���\0ޣ�\5�����C�d�Ƶ�ҭ����������`Ǡ�L���Pߐ�����רǥ���c�F�J�M�/�\15�\16�\17�1�Q�O�N�,�+�+�+�\n�肪�������\17�\17�0�N�\r���\t�ȹ\t���w���W�\21�\18�\16�3ל���V�\14�7�Ԣ�h�i�I�i�i�g������1�+�'�\b�I�m������0�Q�pʯҰ���s�5�\18�е����\17���k�\5�\1�\1�Ø\4��ĔŘƘ\a�I�j����\23�8���������8�y��������\14�\15�/�oʐ���\17��چ�\0�`� �\0�\0�\0�\0� �`���\0�@ՠـ� �!�����������\a����������� �a� �\"�i�-�n߮����ۦ˄�e�e�C� �\1�\b�������\17�0�+�\a�ƂłƎǒ�\t�Ǌb�F���������\16�r�Q���ȱ����t�u�҂Ц������5Ǿ�ڂ��ԢӢ/���'�(�(�j���h����M�1�\r�ǔǱ'�+�����\14�\14�0�nʯҏ���S�Ԝ\15�n�pƐ��֮�K�\a�\3�\1�Ô\4�Ô����Ƙ�I�j���0�\23�8���������\24�Y��������\14�\15�/�oʐ���\17۬�C�\0�@� �a���������Ü�a�\0����\0�B�����\5���(������뀾\4�f�%���(�*׋����ߧ�g�&�\a�\a��\3���b�j֯����Â����������������D���)��έҮ�\15Ô�t�����*�0�\17�+�葌¯Үά�5�������\21�p�̙H�\6�(�I�������ɵ\b�����\14�Ȑ���\n�p�q�\v��.�M�nΎ���2�\f�L�\14�N��ҍ�l�\n�\5�\1�Ø\4�Ô����Ƙ\a�)�j�����8�\23��޵�����\23�8��ι�\14�\14�\14�\14�O�oʐ���\17۬�C�\0� �@��\3�#�#�D�����\5�%Ƥ��������`�c���F���H�����������֧ʇƇ��Ψ��ߨ�H�\t��ʈ�H�e�a���Ʃkʍ���Ȧ�������ʋ�I�)�I�g������J�k�k��t���)��͂��f�j���l�l�j�\21���������-���'�\a�I�j�����\n�)�̱р\15�����Ʊɱ.�.�\b�˱\f�+�M�m���\16�\15�\t�*��\r��Ό�l�\r�\b�\1�Ø\4�Ô��Ř�\b�J�k�ι��Y�\23��ڵ��������ޓ�0�/�\14�\14�/�/�O�oΐ���\17۬�C�\0� �@�\3�\3�\2�\2�D�d�������c�a�������\"���\6���H����뀩D���e�&�&�\6������׆�'��Ɔ�f�f�&�歂���#�\a�JƋƪ�������*�\t���\a�&���`�f�\b�)�J�̶r�S��.�̂f�%�\t�)�)�\n�*�(�����ق����왉�'�'�j���ͩ/�N�mά�\14��\15���e������\v�&���ʱ�+�lʭ��\r�\a�)���˵K�kʌ�.�\t�\2��\4�ÔĔƜ�)�k�k�ι��8�����al����������������q�/�/�O�oΐ���\17ۋ�B�\0� �@�\3��\3�#�C�d���b�����@�\0��d�湇�'�� �A�$����ű�\5�$����σ��!��B�b�\"�\1�@�����\b�JƋ�j�j�(�\a�\a�'�f�E�b�\0�E�ǩ�\t���O�p�O�삦�����詧�Ǳ��\a�����ق��n�뙉�G�'���̥��NΏΰ���P�\19�\14���f�����ʐ\n�%�h���ȱ�Kƌ�͵\f�\6�\b�����)�J�l�N�\t�\2��%��Ř�\b�J�k�͹1���\24�����al��������\24�Y�z��\22�0�\14�/�Oʐ���\17ۋ�B�\0� �@��\3��\3�D�D�����������@���`�C�ĵg�\aߣ� �@��$�����ĭ\5�$�����\0�`�`��� �`�@���`�\0���c��\b�*�j©���e���������D�B�\0�\4�����ȵi�\v�\n���e�\2�A�\4���������ȵ\a�Ӫ��\28���,�뙉�G�H���\r�NʏҰ���\16�s�\19�\r���g���f�ʐ\n�%�G������*�ε\r�\6��h���\b�)�l�N�\n�\3��%��Ř�(�j�k�0�\23�8�������al��������\23�8�z�z���\15�\14�/�O�p���\17۬�d�@�`�`��$�\3�\3�$�d�����\4�ù��\2�\1� �\0�\"���&��֣�렭��\4��������$��`�\0���a����������`�@���c�����I��\b���c�C�C�D�D�\3�\2�\0�\3�D�����h���Ł��b�\0�b�$���f���ȵ\b°�|�����ꝩ������MƏΰ�����1�U���\a�Đh���f�ʐ\f�'�&������*��.�\a�\6������\b�l�o�\f�\5��%���\a�(�j�k�1�8�Y�������al��������\23�8�8���0�\14�\15�/�O�p���\17����������\3�D�$�#�C�����F·�e�Dʣ�b���\0�a�C���嵥Σ��ൄ��d������$���\1�\"�㩄�#�#�����C�C�d�d�d�e�����I�\a�d�\4��šƩƥđ\"�\0��$�E���G�F���e��\1�b�\5�E�f����)�8���\27�\14�ȝɡ��ɵ\f�nʰ�����1�3���\15� �\5�g�e�e�ː.�J�%������*��o�\a�\6�����Ǳ�k�p�\14�\a��%�\5�\6�\a�I�k���0�8�Y��������^al��������\23���0���\14�/�/�O�p���\17��ަ������#�E�d���ŵ\a�g���\t�����D�B���\0���c�d����ʂ����d�ıd�����\a�\5� ���\2�\3���D�D���ĩd�c�����d�e���\a���\a��Ʃ��Ǳǭđ\1�\0��$�$���\6�����%���$�A�Āg�f�e���\t�J�kʲ�\27�>���șǥɭ�,�n�����\17�R��\18�\6�����e�f�ː/�L�F�����ȵ*��\15�\4��g�g�ǱǵJ�N�\14�\b��E�%�\6�'�I�����Q�8�8����ڵ��^al������\24���0��\14�\14�\15�/�O�pα�\18�\16ۨ�\0�����$�e�e���\b�j���+�K�J�g���@�\0� �\2�c�d���d�a��� �d���d�e���)���`���A���d�\4�\4�d�����!���\"�d�e�\5�����E��ǵ����ƭơc���\0��#�$�����\3�b�%�f�$�Ąh���f�Ǳ\t�Jʏ�R�y������Ʊ\b�kƭ���1�R��Ε�\v�\0�&�鵧���g���\r�,�G������I�,�/�\v�\0��g�g���ǵ\t�\f�\f�\b��E�E�&�G�i�����Q�\23�\23�������sNal����\23�Y�����\14�\14�\14�\14�/�pα�\18�\16ۨ�\0�`����\2�C���g���+�k�����D�@�`�\0��b�C�#�d�d����A�d���E�f���\n�i�\4�\0�\0�����$�\5���\3�����\0�\2�����������������������c��� �\0�Ô\3�$���e���A�$�f�D��Ì�\6�&���\t�)�lƎ�-���\22�����P�K�k���\17�4׸���,�\0�Őh�g�f���g��\n�\v���'����˵\r�\v�\4�\0��F�F���ǵH�(�\b�\6�d�����\6�g�i�����Q�\23�8��������^al��\23���8���\15��\14�\14�/�/�oʐα�\17��ڇ�\0�@�@� �@���A���D�����d�\0�`�\0�\0�\1�b�C�\3��d�D�A� �\1�d���%�&����K�\a�@���@��B���b�����\0���E�������\"������\3�#�#�\2��� � �\0����$���E�A�A�$���E�\4�\3�Ą����f�ȵ�+�m�L���\t�p���9�z�����z�\25�3�\t�\0�嘈�g�\5�%�E���G�&�\6�\a�G�ǔ蘉�\b�\5�\1�\0�ĘF�%�f�ǵ��e�\3�\3�\2�\2�\2�Řh�������Q�X�Y��������^al������8���\14�\14�\14�.�/�O�oΐΰ�����e�\0�\0�\0�\0�\0�\0�\0�`ĠĠ���\0�\0�\0��a���C��Ø�e�\4��� �\0�$�e�\5�\6�h�ʵ\v�)��@���������`���\0���D�e�F���Ǳ����\0�\0�\0� �\0�\0����a�\0�A�Ô$���$�\0� �\4�f�E�\4�\4��b�\0���f����L�+�ȵf��g��R�R�1���\r�\4���*�ʭ��%�\5�\5�\5�f���\6�\2�\0�\2�\3�\3�\2�ĔĘ\0�\0���\5�\5�%���ȵ�\1�\0�\0�\0�\0�c�'�H�j���\15�\22�Y�\23����ڵVal������\23���0�\14�\14�.�/�O�oʐΰ���k�B���\3�������a�A�����\3�c�����b�Ø��ÔĘE�\4��!�\2�%�%�\5�\a�G����\n�\b���\3�A�\1�A���Ę%�e�e�\6�F�������\3���a����E�F�䘢���Ô\4�E�E�Ô��\5�F�%��\5�%�Ĕ����%�g���\v�\n�ȵȱ��\3�����@�A�`�\1�$�J���˭E����\5�F�����&���b�A����f�f�ØĔĔ��\5�f�����%���B�B�B����\a�(�i���Q�\23�8�����\16Bal�����������ڒ�/�\14�.�O�O�oʐΰ�L�����ǵd�C�\4�$�$�\3�\3�c���e�������b�✣�����Ře�D�FƦ�f�&�\5���H���˹�ʵ����e���$�E�&�&�%�%�\6�\6�F���ǩ��%��\4�E�e�f�&�\5�$�\4�ĘĘ\5�F�F�\6�\6�&�&���&�&�&�&�F�&�H�ʭʱ������f�F�%�%�\6�&���ȵ��H�H�\5�Ę��Ř\6�(�i�����g�\5��%�f���F�f�F��ĔŘ\5�&���ȵȱg��ØĔĘ��\a�I�j�͹��8�\23�����al��������\23�8���r�/�.�O�O�o�o�M�+�깨�E�#����\4�\4�$�%�&�%�#�\2�⠢�������Ƙe�E�G�i�\b�&�\5��\a�(���˵˹��i�g�F�&�&�E�%������\6�'�H�h�h�'�\6�\5�\5�$�%�����ĔĔ�&�&�\a�\6�\6�\6���\6�'�'�&�&�\6�'�����������G�&�F�F�&�&�G�g�%���Ř��Ř�\a�I�j�����g�F�&�%�%�\5��\5�\5�Ę��Ř�&�g�����h�&��ĘĔĔŘ�(�j���Q�\23�\23���al�al��������\23�Y�z�\23�P�.�.�O�o�O�\r��ʵg�\5��Ę��ØÔ������ŔĘØ���������Ƙ�h�F�G�J�\t�'���\b�I�j�˵̹����H�'�\a�\6��ŘŔŔĔĘ��(�H�I�(�\a�\6��Ř��ŘŘŔĔ��Ř�\6�\6�\a�\a���\a�\a�'�(�(�\a�\6�\6�'�����������G�\a�\6�\6�����ŘĘŘƘŘ�\a�(�j�����j�H�'�\6���ŘŘŘŘ����Ř�\6�g�i�I�(�\a��Ĕ����Ř�\b�J�k��\23�\23���al��al��������\23�Y�8�P�\14�.�.�O�O��̵��g�\a��ŘŘĘ������ĔŘŘÜ�Ü�����\b�\n�j�G�g�j�*�(�\b�\b�)�J�k�������k�i�(�\a���ŘŔŔĔŘ�\b�)�I�J�I�(�\a�����ƘƘŘŔŘ�\a�\a�'�\b�\b�\a�\b�\b�(�I�I�I�(�'�\a�(�����������I�(�\a�\6��Ƙ��ŘŘ���\b�)�J���������i�(�\a���ŘŘ��ƘƘ�\a�\a�H�j�j�I�\a��ŘŘŘƘ�)�J�k��\23�8���alal��ValsN������8�8��\14�\14�\14�N�.�͹����i�(�\b����ƘƘŘŘƘƘ��ŘƘ�\b�)�+���gʇΌ�K�J�)�)�J�J�ι1�Q�Q��j�I�)�\a���ƘƘƘ�\b�)�J�k�k�j�I�(�\a���������\b�(�(�(�)�)�)�)�I�I�J�k�k�J�H�H�I�����������J�I�(�\b�\a��\a�\a���\a�\b�\b�)�J�k���������j�(�\b�\b�\a����\a���\b�)�(�i���k�j�I�\b�����\b�J�k���\15�������al�al��V�������\24�8��\14�\14�\14�.�p�Q�0�͹j�I�)�(�\a��\a���Ƙ������\b�k��\17�\15·Ό�L�k�J�J�k�����y�Y�y����J�J�)�\b�\b�\a�\a��\b�)�J�k�����k�J�)�)�\b�\b�\b�\b�(�\b��\b�)�I�I�I�J�J�J�J�J�J�k���k�k�i�i�j�������O�/�0�ιJ�)�\b�\b�(�(�\a�\b�\b�)�*���\16�0�0�1�0�0�\16��j�\b�\b�\b�\b�\a�'�\b�\b�)�J�J�j�k�k�k�J�)�\b�\b��\b�J�J�k���ι������al�alalal�al����\24�8��/�\14�\14�O���y�X������ι��J�)�)���ι͹��ιιιι��8�Y��ޫ҇�\16���\15�\16�\15�ｴ�Y�y�Y�Y�Y���\16�\15�ι)�)�)�)�)�����\15�\16�\16�\16�\15��ιJ�)�)�J�J�)���ι�������\15�\15��\16�\16�\16�\16�\14�\14�\15�.�\14�r�X�8�X���1��ιk�J�I�)�)�k���r�8�8�\24�7�7�8�8�8�Q�ιι��)�j��ιι�͹k�ι\16�\16�\16�\15��ιιι��J����\16�1���\23���alal�alal�alal��\23�8�\23�Q���/�\22�z�z�8���������\23���\16�͹\15���\23�������������8�z��7�ҩ�\22�8�\23�\23�����\24�8�8�\24�8�8�8���\23���\16�ιιιι��8�\23�\23�\23�\23�\23�\23�\23���\16�ιι��ι��\23�\23�\23�����������\23�\23�\23�\23�\23�\23�\23�\22���\22�\22���\23�Y�Y�Y�Y�\23�\23�\23�Q�ι�ινs�\23���\23�Y�9�8�8�8�8�9�Y�\23���\23��ιR�\23�\23�\23�\23���0���\23�\23�\23�\23�����\23�\23��ιR���\23���\23�\24���alal��al��al����8�\23�r�\15�\16�P���8�8�\24�\24�8�8�8�Y�Y�������Y�Y�8�8�8�8�8�8�8�8�Y�\22�ҫ�x��Y�8�8�8�8�����������8�9�8�8�����������8�Y�Y�8�8�8�8�8�Y�Y�������������8�Y�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�\24�\23�\23�\23�\23�8�8�Y�\23���������8�Y�8�\24�\23�������������\23�\24�8�Y�8���\23�Y�Y�Y�Y�8���8�Y�8�8�8�8�8�Y�Y�8���\23�Y�9�9�������al����al�alal��\24�\23�����������\23���������\23�\24�\24�8�Y�Y�Y�9�8�8�8�8�\24�\24�\24���\23�8��ޫҪ�7�Y�\23���\24���������al����������9�Y�Z�Z�Y�Y�9�8�\24�\24�\24�\24�\24�\24�8�9�Y�Y�z�z�Z�Y�Y�9�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�8�\24�\24�\24�\24�\24�\24�\24�\24�8�9�Y�Z�z�z�Z�Y�9�8�\24�\24�\24�\23�����\23�\24�\24�\24�8�9�Y�Y�Y�9�9�9�9�9�9�9�9�8�8�8�8�8�9�9�8�\24�\23�\23������ڵֵVal����alal\16Bal����9�8�8�8�\24�\23�\23�\24�\23���������������������������������������8��ދΪ�7�8���������alalalalalalal���������������������������������������������������������������������������������������������������������������������������������ڵ������������������������������������������������������������ڵ�alalsNalal���alal��al���������������������ڵ����ڵֵV�VsN�V�V\16B\0\0alalalal����\23�8��ދΊ�\23�8�����sNalal\0\0���\0\0���alal�\0\0sNsN�V�V�R�R�V�V�V�R�V�V\21BU)\0\0�����alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal������al�\16Balal�����al���al���������ڔR�alalalalalalal�al�alal��al�al������\24���l�k�\22�9�����al�^\0\0�alalalal���\16B���alalalalalalalal��alalalalalalalalal�\0\0���������\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B\16B����\0\0��alal��������\16B\0\0��alalalal\16B�V�V�\16B�������\0\0\0\0\0\0\0\0\0\0�al����\23���M�K���8�����al\16Balalalalalal�����\0\0\0\0�������������\0\0\0\0\0\0\0\0\0\0��alalalal����������alalalalalalalalalalalalalalalalal�al�al���alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal�������\16B�V�V�V\16B������������alal��alal�Val����\24��޲ֲ�\23�\24���\16B�������alal�������������al����al����alal�alalalalalalal�alal�alal���alalalal�����������alalal�al�alalalalalalalalal������alalalalalalalalalalalalalalalalalalal�alalalalalalalal���������alalalalal�alalal��alalalalalalalalal��������������������alal��al�al����������al��������������alalalalalalalalalalalalalal����alal���alalalalalalalalalalalal��al�alalalalalalal�alal�al�al��alalalalalalalalalalalalalalalalalal���alalalalalalalalal���������alalalalalalalalalalalalalalalalalalalal�\16B�Z�Zalalalalalalalal�����R�Z�Z�^�Z�VsN�^�V�V�\16B\16B������\0\0\0\0\0\0�alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal����alal�alalal�alalalalalalalalal�alal�alal�alal�al�alalalalal")paddleImg=image.new(".\0\0\0\n\0\0\0\0\0\0\0\\\0\0\0\16\0\1\0alal/�P�Q�s���������alalalalalalalalalalalalalalalalalalalalalalalalalal��������t�Q�P�P�alalal/�P�Q�֘��\26�;�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�\\�;�\26�\26�7�s�Q�P�al/�/�Q�7�������������������������������������������������������������������������������s�P�/�/�/�s���{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�{�7�P�0�/�P�t�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�s�U�Q�P�/�P�s��̌��ٌٌٌ͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌͌��ӘQ�P�/�P�s�t�����܄ԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄԄ܄��೤s�Q�P�alP�s�t�4���7�8�������ٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌٌ����ٌ٘�ݓ͕�s�Q�alalals�t���-�ٌٌٌ֘alalalalalalalalalalalalalalalalalalalalalalalalalalٌٌٌ֘-峤t�s�alalalalalalal̰�Ա�alalalalalalalalalalalalalalalalalalalalalalalalalalalalalal����̰alalalalal")