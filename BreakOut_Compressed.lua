BlockWidth=20
BlockHeight=10
totalBlocksToDestroy=0
currentLevel={numberOfBlocks,xPositions={},yPositions={},blocksStates={}}possibleStates={"breakable","solid","unbreakable"}bonusTypes={"PaddleGrow","PaddleShrink","BallClone","BallGrow","BallShrink"}level={{1,1,1},{3,5,2},{10,4,3}}function reset()win=false
gameover=false
pause=false
waitContinue=false
tmpCount=0
lives=3
score=-1
secureNbr=0
BonusTable={}BlocksTable={}BallsTable={}FallingBonusTable={}level={{1,1,1},{3,5,2},{10,4,3}}for e=1,20 do
table.insert(level,{math.random(0,12),math.random(0,10),randomAndCount()})end
for l,e in pairs(level)do
table.insert(BlocksTable,Block(20*e[1],12*e[2],20,12,e[3],#BlocksTable+1))end
totalBlocksToDestroy=#BlocksTable-totalBlocksToDestroy
end
function randomAndCount()theRand=math.random(1,3)if theRand==3 then totalBlocksToDestroy=totalBlocksToDestroy+1 end
if theRand==2 then totalBlocksToDestroy=totalBlocksToDestroy-1 end
return theRand
end
function fillRoundRect(t,l,a,d,n,e)if e>n/2 then e=n/2 end
t:fillPolygon({(l-d/2),(a-n/2+e),(l+d/2),(a-n/2+e),(l+d/2),(a+n/2-e),(l-d/2),(a+n/2-e),(l-d/2),(a-n/2+e)})t:fillPolygon({(l-d/2-e+1),(a-n/2),(l+d/2-e+1),(a-n/2),(l+d/2-e+1),(a+n/2),(l-d/2+e),(a+n/2),(l-d/2+e),(a-n/2)})l=l-d/2
a=a-n/2
t:fillArc(l+d-(e*2),a+n-(e*2),e*2,e*2,1,-91);t:fillArc(l+d-(e*2),a,e*2,e*2,-2,91);t:fillArc(l,a,e*2,e*2,85,95);t:fillArc(l,a+n-(e*2),e*2,e*2,180,95);end
function clearWindow(e)e:setColorRGB(255,255,255)e:fillRect(0,0,platform.window:width(),platform.window:height())end
function test(e)return e and 1 or 0
end
function screenRefresh()return platform.window:invalidate()end
function pww()return platform.window:width()end
function pwh()return platform.window:height()end
function drawPoint(e,a,l)e:fillRect(x,l,1,1)end
function drawCenteredString(l,e)l:drawString(e,(pww()-l:getStringWidth(e))/2,pwh()/2,"middle")end
function on.create()reset()pause=false
gameover=false
on.resize()newPaddleY=0
while(math.floor(.5*platform.window:width()-29)+newPaddleY)%4~=0 do
newPaddleY=newPaddleY+1
end
paddle=Paddle(.5*platform.window:width()-29+newPaddleY,40,0,"")aBall=Ball(math.random(10,platform.window:width()-10-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1)table.insert(BallsTable,aBall)timer.start(.01)end
function on.timer()platform.window:invalidate()end
function on.resize()platform.window:setPreferredSize(0,0)isCalc=(pww()<321)XLimit=isCalc and 58 or math.ceil(58*pww()/320)fixedX1=4+.5*(pww()-XLimit+pww()-platform:gc():getStringWidth("Nspire"))fixedX2=6+.5*(pww()-XLimit+pww()-platform.gc():getStringWidth("BreakOut"))end
function on.charIn(e)if e=="p"then pause=not pause end
if e=="r"then
on.create()end
if e=="h"then
needHelp=not needHelp
end
end
function on.mouseMove(e,l)if not pause and e<platform.window:width()-XLimit-paddle.size*.5 and e>paddle.size*.5 then paddle.x=e end
end
function on.paint(e)e:setColorRGB(0,0,0)if#BallsTable<1 or secureNbr>10 then
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
sideBarStuff(e)if score==-1 then score=0 end
if not pause then score=score+.2 end
ballStuff(e)bonusStuff(e)elseif gameover then
drawCenteredString(e,"Game Over ! Score = "..tostring(math.floor(score)))elseif win then
drawCenteredString(e,"You won ! Score = "..tostring(math.floor(score)))elseif needHelp then
end
end
function on.arrowKey(e)if e=="right"and paddle.x<platform.window:width()-20-XLimit then
paddle.dx=8
elseif e=="left"and paddle.x>=25 then
paddle.dx=-8
end
end
function on.enterKey()print("------------------")print("#BallsTable = "..#BallsTable)for l,e in pairs(BallsTable)do
print("    ball."..e.id.." : x="..e.x.." y="..e.y)end
print("#BonusTable = "..#BonusTable)print("#BlocksTable = "..#BlocksTable)print("tmpCount = "..tmpCount)print("totalBlocksToDestroy = "..totalBlocksToDestroy)print("Lives = "..lives)end
function sideBarStuff(e)e:drawLine(platform.window:width()-XLimit,0,platform.window:width()-XLimit,platform.window:height())e:setFont("serif","r",10)e:drawString("Nspire",fixedX1,pwh()-63,"top")e:drawString("BreakOut",fixedX2,pwh()-49,"top")e:drawString("Adriweb",4+fixedX2,pwh()-22,"top")end
function ballStuff(l)for a,e in pairs(BallsTable)do
if 2*e.radius-2<0 then e.radius=5 end
if e.y+e.radius>platform.window:height()-15 then
if not e:intersectsPaddle()then
table.remove(BallsTable,e.id)else
e:PaddleChock()if not e:touchedEdgesOfPaddle()then paddle:goGlow(12)end
local l=.7*(-1+test(e.speedX>0))*math.abs(e:howFarAwayFromTheCenterOfThePaddle())if e.x>10 and e.x<pww()-10 then e.x=e.x+l end
end
end
for n,a in pairs(BlocksTable)do
if a~=0 then
if e:intersectsBlock(a)then
e:BlockChock(a)a:destroy()end
if pause then
l:setAlpha(127)end
a:paint(l)if pause then
l:setAlpha(255)end
end
end
if not pause then
e:update()paddleStuff(l)end
if pause then
l:setAlpha(127)end
e:paint(l)paddle:paint(l)if pause then
l:setAlpha(255)if waitContinue then
l:drawString(lives.." balls left... (Press 'P')",.5*(pww()-l:getStringWidth(lives.." balls left... (Press 'P')")-26),pwh()/2+25,"top")else
drawCenteredString(l,"... Pause ...")end
end
if not pause and math.random(1,300)==100 then table.insert(FallingBonusTable,Bonus(math.random(5,pww()-70),0,bonusTypes[math.random(1,#bonusTypes)]))end
end
end
function paddleStuff(e)if paddle.dx>0 then
paddle.x=paddle.x+paddle.dx
paddle.dx=paddle.dx-1
elseif paddle.dx<0 then
paddle.x=paddle.x+paddle.dx
paddle.dx=paddle.dx+1
end
end
function bonusStuff(l)for a,e in pairs(FallingBonusTable)do
if pause then l:setAlpha(127)end
e:paint(l)if pause then l:setAlpha(255)end
if not pause then e:update()end
if e:fallsOnPaddle()then paddle:grabBonus(e);e:destroy()end
if e.y>platform.window:height()-16 and not e:fallsOnPaddle()then e:destroy()end
end
for a,e in pairs(BonusTable)do
l:setColorRGB(0,0,255)if e.timeLeft<666 then l:setColorRGB(0,0,0)end
if e.timeLeft<333 then l:setColorRGB(255,0,0)end
l:drawString(e.bonusType.." : "..tostring(e.timeLeft),0,a*12,"top")if not pause then e.timeLeft=e.timeLeft-1 end
if e.timeLeft<2 then table.remove(BonusTable,1);resetBonus(e)end
end
end
Ball=class()function Ball:init(n,a,d,l,e)self.x=n
self.y=a
self.speedX=d
self.speedY=l
self.radius=5
self.id=e
end
function Ball:paint(e)e:setColorRGB(0,0,0)e:drawArc(self.x-self.radius,self.y-self.radius,2*self.radius,2*self.radius,0,360)e:setColorRGB(127,127,0)e:fillArc(self.x-self.radius+1,self.y-self.radius+1,2*self.radius-2,2*self.radius-2,0,360)end
function Ball:intersectsBlock(e)return(self.x>e.x-self.radius-2 and self.x<(e.x+e.w+self.radius+2))and(self.y>e.y+self.radius+2 and self.y<(e.y+e.h+self.radius+2))end
function Ball:intersectsBall(e)return math.sqrt((e.x-self.x)*(e.x-self.x)+(e.y-self.y)*(e.y-self.y))<self.radius+e.radius
end
function Ball:intersectsPaddle()return(self.y+self.radius>platform.window:height()-16)and(self.y+self.radius<platform.window:height()+10)and(self.x>=paddle.x-paddle.size*.5-4 and(self.x<=paddle.x+paddle.size*.5+4))end
function Ball:BlockChock(e)if self.y>e.y+e.h or self.y<e.y then
self.speedY=-self.speedY
end
if self.x>e.x+e.w or self.x<e.x then
self.speedX=-self.speedX
end
if e.state==3 then
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
Paddle=class()function Paddle:init(e,l,a,n)self.x=e
self.size=l
self.dx=a
self.bonus=n
self.glow=0
end
function Paddle:grabBonus(e)e.timeLeft=1e3
table.insert(BonusTable,e)if e.bonusType=="PaddleGrow"then
self.size=self.size+8
elseif e.bonusType=="PaddleShrink"then
self.size=self.size-8
elseif e.bonusType=="BallClone"then
table.insert(BallsTable,Ball(math.random(1,platform.window:width()-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1))elseif e.bonusType=="BallGrow"then
for l,e in pairs(BallsTable)do
if e.y-e.radius<5 then
e.y=e.y+6
end
e.radius=e.radius+5
end
elseif e.bonusType=="BallShrink"then
for l,e in pairs(BallsTable)do
if e.y-e.radius<5 then
e.y=e.y+6
end
if e.radius>4 then e.radius=e.radius-4 end
end
end
end
function Paddle:goGlow(e)self.glow=e
end
function Paddle:paint(e)e:setColorRGB(0,0,200)e:drawImage(image.copy(paddleImg,(self.size/image.width(paddleImg))*image.width(paddleImg)-2,image.height(paddleImg)),self.x-.5*self.size,platform.window:height()-14)if self.glow>0 then
e:setColorRGB(255,100,0)fillRoundRect(e,self.x-1,platform.window:height()-13,self.size-.5*self.size,3,1)self.glow=self.glow-1
end
end
Block=class()function Block:init(a,l,e,n,d,t)self.x=a
self.y=l
self.w=e
self.h=n
self.state=d
self.id=t
end
function Block:paint(e)e:setColorRGB(0,0,0)e:fillRect(self.x,self.y,self.w,self.h)if self.state==1 then
e:setColorRGB(0,255,0)elseif self.state==2 then
e:setColorRGB(0,0,255)elseif self.state==3 then
e:setColorRGB(200,200,200)end
e:fillRect(self.x+1,self.y+1,self.w-2,self.h-2)end
function Block:destroy()if self.state==2 then
self.state=1
table.remove(BlocksTable,self.id)table.insert(BlocksTable,self.id,self)elseif self.state==1 then
table.remove(BlocksTable,self.id)table.insert(BlocksTable,self.id,0)end
if self.state<=2 then
tmpCount=tmpCount+1
end
end
Bonus=class()function Bonus:init(a,l,e)self.x=a
self.y=l
self.bonusType=e
self.timeLeft=9999
end
function Bonus:paint(e)e:setColorRGB(0,0,0)e:fillRect(self.x,self.y,15,15)e:setColorRGB(200,0,200)e:fillRect(self.x+1,self.y+1,13,13)e:setColorRGB(255,0,0)e:fillRect(self.x+2,self.y+2,11,11)end
function Bonus:update()self.y=self.y+1
end
function Bonus:fallsOnPaddle()return(self.y>platform.window:height()-16)and(self.x>=paddle.x-paddle.size*.5-4 and(self.x<=paddle.x+paddle.size*.5+4))end
function Bonus:destroy()self.y=self.y+pwh()table.remove(FallingBonusTable,1)end
function resetBonus(e)if e.bonusType=="PaddleGrow"then
paddle.size=paddle.size-8
elseif e.bonusType=="PaddleShrink"then
paddle.size=paddle.size+8
elseif e.bonusType=="BallClone"then
elseif e.bonusType=="BallGrow"then
for l,e in pairs(BallsTable)do
if e.radius>4 then e.radius=e.radius-5 end
end
elseif e.bonusType=="BallShrink"then
for l,e in pairs(BallsTable)do
if not e.radius==4 then e.radius=e.radius+5 end
end
end
end
paddleImg=image.new(".\0\0\0\n\0\0\0\0\0\0\0\\\0\0\0\16\0\1\0alal/„P„Qˆsˆ•Œ•Œ¸Œ¸Œalalalalalalalalalalalalalalalalalalalalalalalalalal¸Œ¸Œ•Œ•ŒtˆQˆP„P„alalal/„P„QˆÖ˜™±\26¾;Â\\Â\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Æ\\Â;Â\26¾\26¾7¡sˆQˆP„al/„/„Qˆ7¡ß÷ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ¼ÒsˆP„/„/„/„sˆÚâ{û{÷{÷{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{ó{÷{û{û7¡P„0„/„P„tˆsæsòsæsæsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsŞsæsòsòU±QˆP„/„P„sˆÓÌŒåŒåŒÙŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÍŒÙŒÙŒåŒåÓ˜QˆP„/„P„sˆtˆÌÌÆä„Ü„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ô„Ü„àÈà³¤sˆQˆP„alP„sˆtˆ4¹“å7¡8©úúúÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒÙŒúúÙ˜ÙŒµİ“Í•ŒsˆQˆalalalsˆtˆ³¤-åÖ˜ÙŒÙŒÙŒalalalalalalalalalalalalalalalalalalalalalalalalalalÙŒÙŒÙŒÖ˜-å³¤tˆsˆalalalalalalalÌ°‰Ô±¬alalalalalalalalalalalalalalalalalalalalalalalalalalalalalal³¤‰ÔÌ°alalalalal")