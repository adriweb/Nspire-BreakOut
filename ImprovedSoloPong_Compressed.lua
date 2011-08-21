BlockWidth=20
BlockHeight=10
currentLevel={numberOfBlocks,xPositions={},yPositions={},blocksStates={}}possibleStates={"breakable","solid","unbreakable"}bonusTypes={"PaddleGrow","PaddleShrink","BallClone","BallGrow","BallShrink"}level={{1,1,1},{3,5,2},{10,4,3}}function reset()win=false
gameover=false
pause=false
lives=3
score=-1
BonusTable={}BlocksTable={}BallsTable={}FallingBonusTable={}level={{1,1,1},{3,5,2},{10,4,3}}for e=1,35 do
table.insert(level,{math.random(1,14),math.random(1,9),math.random(1,3)})end
end
function fillRoundRect(a,d,n,l,t,e)if e>t/2 then e=t/2 end
a:fillPolygon({(d-l/2),(n-t/2+e),(d+l/2),(n-t/2+e),(d+l/2),(n+t/2-e),(d-l/2),(n+t/2-e),(d-l/2),(n-t/2+e)})a:fillPolygon({(d-l/2-e+1),(n-t/2),(d+l/2-e+1),(n-t/2),(d+l/2-e+1),(n+t/2),(d-l/2+e),(n+t/2),(d-l/2+e),(n-t/2)})d=d-l/2
n=n-t/2
a:fillArc(d+l-(e*2),n+t-(e*2),e*2,e*2,1,-91);a:fillArc(d+l-(e*2),n,e*2,e*2,-2,91);a:fillArc(d,n,e*2,e*2,85,95);a:fillArc(d,n+t-(e*2),e*2,e*2,180,95);end
function clearWindow(e)e:setColorRGB(255,255,255)e:fillRect(0,0,platform.window:width(),platform.window:height())end
function test(e)return e and 1 or 0
end
function screenRefresh()return platform.window:invalidate()end
function pww()return platform.window:width()end
function pwh()return platform.window:height()end
function drawPoint(n,d,e)n:fillRect(x,e,1,1)end
function drawCenteredString(n,e)n:drawString(e,(pww()-n:getStringWidth(e))/2,pwh()/2,"middle")end
function on.create()reset()pause=false
gameover=false
on.resize()timer.start(.01)local e=0
while(math.floor(.5*platform.window:width())+e)%4~=0 do
e=e+1
end
paddle=Paddle(.5*platform.window:width()+e,40,0,"")aBall=Ball(math.random(10,platform.window:width()-10),platform.window:height()-26,-1,-1,#BallsTable+1)table.insert(BallsTable,aBall)for n,e in pairs(level)do
table.insert(BlocksTable,Block(20*e[1],12*e[2],20,12,e[3],#BlocksTable+1))end
end
function on.timer()platform.window:invalidate()end
function on.resize()end
function on.charIn(e)if e=="p"then pause=not pause end
if e=="r"then
on.create()end
if e=="h"then
needHelp=not needHelp
end
end
function on.mouseMove(e,n)if not pause then paddle.x=e end
end
function on.paint(e)e:setColorRGB(0,0,0)if not gameover and not needHelp then
tmpCount=0
if score==-1 then score=0 end
if not pause then score=score+.2 end
ballStuff(e)bonusStuff(e)elseif gameover then
drawCenteredString(e,"Game Over ! Score = "..tostring(math.floor(score)))elseif win then
drawCenteredString(e,"You won ! Score = "..tostring(math.floor(score)))elseif needHelp then
end
end
function on.arrowKey(e)if e=="right"and paddle.x<platform.window:width()-20 then
paddle.dx=8
elseif e=="left"and paddle.x>=25 then
paddle.dx=-8
end
end
function ballStuff(n)for d,e in pairs(BallsTable)do
if e.y+e.radius>platform.window:height()-15 then
if not e:intersectsPaddle()then
table.remove(BallsTable,e.id)if#BallsTable<1 then gameover=true end
else
e:PaddleChock()if not e:touchedEdgesOfPaddle()then paddle:goGlow(12)end
local n=.5*(-1+test(e.speedX>0))*math.abs(e:howFarAwayFromTheCenterOfThePaddle())if e.x>10 and e.x<pww()-10 then e.x=e.x+n end
end
end
for t,d in pairs(BlocksTable)do
if d~=0 then
if d.state==3 then tmpCount=tmpCount+1 end
if e:intersectsBlock(d)then
e:BlockChock(d)d:destroy()end
if pause then
n:setAlpha(127)end
d:paint(n)if pause then
n:setAlpha(255)end
else
tmpCount=tmpCount+1
if tmpCount==#Block then win=true end
end
end
if not pause then
e:update()paddleStuff(n)end
if pause then
n:setAlpha(127)end
e:paint(n)paddle:paint(n)if pause then
n:setAlpha(255)drawCenteredString(n,"... Pause ...")end
if not pause and math.random(1,300)==100 then table.insert(FallingBonusTable,Bonus(math.random(1,pww()),0,bonusTypes[math.random(1,#bonusTypes)]))end
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
function bonusStuff(n)for d,e in pairs(FallingBonusTable)do
if pause then n:setAlpha(127)end
e:paint(n)if pause then n:setAlpha(255)end
if not pause then e:update()end
if e:fallsOnPaddle()then paddle:grabBonus(e);e:destroy()end
if e.y>platform.window:height()-16 and not e:fallsOnPaddle()then e:destroy()end
end
for d,e in pairs(BonusTable)do
n:setColorRGB(0,0,255)if e.timeLeft<666 then n:setColorRGB(0,0,0)end
if e.timeLeft<333 then n:setColorRGB(255,0,0)end
n:drawString(e.bonusType.." : "..tostring(e.timeLeft),0,d*12,"top")if not pause then e.timeLeft=e.timeLeft-1 end
if e.timeLeft<2 then table.remove(BonusTable,1);resetBonus(e)end
end
end
Ball=class()function Ball:init(l,n,t,d,e)self.x=l
self.y=n
self.speedX=t
self.speedY=d
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
function Ball:update()if self.x-self.radius<0 or self.x+self.radius>platform.window:width()then
self.speedX=-self.speedX
end
if self.y-self.radius<0 then
self.speedY=-self.speedY
end
self.x=self.x+self.speedX
self.y=self.y+self.speedY
if self.y+self.radius>pwh()+10 or self.x<-5 or self.x>pww()+5 then gameover=true end
end
Paddle=class()function Paddle:init(t,d,e,n)self.x=t
self.size=d
self.dx=e
self.bonus=n
self.glow=0
end
function Paddle:grabBonus(e)e.timeLeft=1e3
table.insert(BonusTable,e)if e.bonusType=="PaddleGrow"then
self.size=self.size+8
elseif e.bonusType=="PaddleShrink"then
self.size=self.size-8
elseif e.bonusType=="BallClone"then
table.insert(BallsTable,Ball(math.random(1,platform.window:width()),platform.window:height()-26,-1,-1,#BallsTable+1))elseif e.bonusType=="BallGrow"then
for n,e in pairs(BallsTable)do
if e.y-e.radius<5 then
e.y=e.y+6
end
e.radius=e.radius+5
end
elseif e.bonusType=="BallShrink"then
for n,e in pairs(BallsTable)do
if e.y-e.radius<5 then
e.y=e.y+6
end
if e.radius>4 then e.radius=e.radius-4 end
end
end
end
function Paddle:goGlow(e)self.glow=e
end
function Paddle:paint(e)e:setColorRGB(0,0,200)fillRoundRect(e,self.x,platform.window:height()-10,self.size,6,2)if self.glow>0 then
e:setColorRGB(255,100,0)fillRoundRect(e,self.x+2,platform.window:height()-11,self.size-15,3,1)self.glow=self.glow-1
end
if#self.bonus>0 then
end
end
Block=class()function Block:init(t,l,d,e,n,a)self.x=t
self.y=l
self.w=d
self.h=e
self.state=n
self.id=a
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
end
Bonus=class()function Bonus:init(n,d,e)self.x=n
self.y=d
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
for n,e in pairs(BallsTable)do
if e.radius>4 then e.radius=e.radius-5 end
end
elseif e.bonusType=="BallShrink"then
for n,e in pairs(BallsTable)do
if not e.radius==4 then e.radius=e.radius+5 end
end
end
end
