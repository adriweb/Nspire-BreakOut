
-- Adriweb (with lots of help from Levak), 2011
-- BreakOut "Casse Brique" Game
                           
-- More of a Improved Pong game ... ><
  
------------------ Globals :

BlockWidth = 20
BlockHeight = 10

currentLevel = {numberOfBlocks, xPositions = {}, yPositions = {}, blocksStates = {}}
possibleStates = {"breakable", "solid", "unbreakable"}
bonusTypes = {"PaddleGrow", "PaddleShrink", "BallClone", "BallGrow"}  
    
function reset()
    BonusTable = {}    
    BlocksTable = {}
    BallsTable = {}
    FallingBonusTable = {}
end

--levels = {
 level =   { {1,1,1}, {3,5,2}, {10,4,3} } -- level 1
--    {}, -- level 2
    -- .....
--}

-----------------------------

function fillRoundRect(myGC,x,y,wd,ht,radius)  -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
    if radius > ht/2 then radius = ht/2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    myGC:fillPolygon({(x-wd/2),(y-ht/2+radius), (x+wd/2),(y-ht/2+radius), (x+wd/2),(y+ht/2-radius), (x-wd/2),(y+ht/2-radius), (x-wd/2),(y-ht/2+radius)})
    myGC:fillPolygon({(x-wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y+ht/2), (x-wd/2+radius),(y+ht/2), (x-wd/2+radius),(y-ht/2)})
    x = x-wd/2  -- let the center of the square be the origin (x coord)
    y = y-ht/2 -- same
    myGC:fillArc(x + wd - (radius*2), y + ht - (radius*2), radius*2, radius*2, 1, -91);
    myGC:fillArc(x + wd - (radius*2), y, radius*2, radius*2,-2,91);
    myGC:fillArc(x, y, radius*2, radius*2, 85, 95);
    myGC:fillArc(x, y + ht - (radius*2), radius*2, radius*2, 180, 95);
end

function clearWindow(gc)
    --gc:begin()    -- la ya une utilite, mais tout ton repere est reporte de 28px vers le haut
    -- ok, on verra.
    gc:setColorRGB(255, 255, 255)
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())
end

function test(arg)
	return arg and 1 or 0
end

function screenRefresh()
	return platform.window:invalidate()
end

function pww()
	return platform.window:width()
end

function pwh()
	return platform.window:height()
end

function drawPoint(myGC,vx, y)
	myGC:fillRect(x, y, 1, 1)
end

function drawCenteredString(myGC,str)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, pwh() / 2, "middle")
end

-------------

function on.create()
    reset()
    pause = false
    gameover = false
    on.resize()
    timer.start(0.01)
    local newPaddleY = 0
    while (0.5*platform.window:width()+newPaddleY)%4 ~= 0 do
         newPaddleY = newPaddleY+1
    end
    paddle = Paddle(0.5*platform.window:width()+newPaddleY,40,0,"")
    aBall = Ball(math.random(10,platform.window:width()-10),platform.window:height()-26,-2,-2,#BallsTable+1)
    table.insert(BallsTable,aBall)
    for i, blockTable in pairs(level) do
       table.insert(BlocksTable,Block(blockTable[1], blockTable[2], 20, 12, blockTable[3]))
    end
    
end

function on.timer()
    platform.window:invalidate()
end

function on.resize()
    if tonumber(platform.apilevel) > 1.0 then platform.window:setPreferredSize(0,0) end      -- Check if current OS is 3.0.1/3.0.2 or if it's the next one. -> then size bugfix
end

function on.charIn(ch)
    if ch == "p" then pause = not pause end
    if ch == "r" then
        on.create()
    end
end

function on.paint(gc)
    gc:setColorRGB(0,0,0)
  if not pause and not gameover then

    for _, ball in pairs(BallsTable) do 
       if ball.y > platform.window:height()-15 then --and ball.speedY > 0 then
            if not ball:intersectsPaddle() then
              table.remove(BallsTable,ball.id)
              if #BallsTable < 1 then gameover = true end
            else
               ball:PaddleChock()
               if not ball:touchedEdgesOfPaddle() then paddle:goGlow(12) end
            end
        end
        --[[for _, block in pairs(BlocksTable) do
            if ball:intersectsBlock(block) then
                --block:Destroy()
                ball:BlockChock()
            end
	        --block:update()
            block:paint(gc)
        end
         ]]--   
            ball:update()
            if paddle.dx > 0 then
                paddle.x = paddle.x + paddle.dx
                paddle.dx = paddle.dx - 1 -- a augmenter si on-calc
            elseif paddle.dx < 0 then
                paddle.x = paddle.x + paddle.dx
                paddle.dx = paddle.dx + 1 -- a augmenter si on-calc
            end
        
        ball:paint(gc)
        paddle:paint(gc)
        if math.random(1,300) == 100 then table.insert(FallingBonusTable,Bonus(math.random(1,pww()),0,bonusTypes[math.random(1,#bonusTypes)])) end
    end 
        
        for _, bonus in pairs(FallingBonusTable) do
        
             bonus:paint(gc)
             bonus:update()
             if bonus:fallsOnPaddle() then paddle:grabBonus(bonus) ; bonus:destroy() end
             if bonus.y > platform.window:height() - 16 and not bonus:fallsOnPaddle() then bonus:destroy() end

        end
        for i, bonus in pairs(BonusTable) do
             gc:setColorRGB(0,0,255)
             if bonus.timeLeft < 666 then gc:setColorRGB(0,0,0) end
             if bonus.timeLeft < 333 then gc:setColorRGB(255,0,0) end
             gc:drawString(bonus.bonusType .. " : " .. tostring(bonus.timeLeft),0,i*12,"top")
             bonus.timeLeft = bonus.timeLeft - 1
             if bonus.timeLeft < 2 then table.remove(BonusTable,1) ; resetBonus(bonus) end
        end
   elseif gameover then
      drawCenteredString(gc,"Game Over !")
   elseif pause then
      drawCenteredString(gc,"... Pause ...")
   end  
end

function on.arrowKey(key)
    if key == "right" and paddle.x < platform.window:width()-20 then
        paddle.dx = 8
    elseif key == "left" and paddle.x >= 25 then
        paddle.dx = -8
    end
end

--------------
                         
Ball = class()

function Ball:init(x, y, speedX, speedY, id)
    self.x = x
    self.y = y
    self.speedX = speedX
    self.speedY = speedY
    self.radius = 4 -- radius   <- debug ?
    self.id = id
end

function Ball:paint(gc)
    gc:setColorRGB(0,0,0)
    gc:drawArc(self.x-self.radius, self.y-self.radius, 2*self.radius, 2*self.radius, 0, 360)
    gc:setColorRGB(127,127,0)
    gc:fillArc(self.x-self.radius+1, self.y-self.radius+1, 2*self.radius-2, 2*self.radius-2, 0, 360)
end

function Ball:intersectsBlock(block)
       return (self.x < block.x - self.radius or self.x > block.x + self.radius + block.w)
        and (self.y < block.y - self.radius or self.y > block.y + self.radius + block.h)
end

function Ball:intersectsBall(ball)
    return math.sqrt((ball.x - self.x)*(ball.x - self.x) + (ball.y - self.y)*(ball.y - self.y)) < self.radius + ball.radius
end

function Ball:intersectsPaddle()
    return (self.y > platform.window:height()-16) and (self.x >= paddle.x-paddle.size*0.5-4 and (self.x <= paddle.x+paddle.size*0.5+4))
end

function Ball:BlockChock()
	--TODO
    --self.speedX = 0.95*self.speedX ; self.speedY = 0.95*self.speedY
   	--ball.speedX = 0.95*ball.speedX ; ball.speedY = 0.95*ball.speedY
end  

function Ball:touchedEdgesOfPaddle() 
    return ( self.x >= paddle.x-paddle.size*0.5-4 and self.x <= paddle.x-paddle.size*0.5+4 ) or ( self.x >= paddle.x+paddle.size*0.5-4 and self.x <= paddle.x+paddle.size*0.5+4 )
end

function Ball:PaddleChock()
   print("paddle touched")
   if self:touchedEdgesOfPaddle() then
       print("edge of paddle touched")
       self.speedX = self.speedX * 1.1
       print("speedX is now : ",tostring(self.speedX))
   end
end

function Ball:update()
    -- Si on collisionne sur les bords horizontaux, on change de direction sur X
    if self.x - self.radius < 0 or self.x + self.radius > platform.window:width() then
    self.speedX = -self.speedX
    end
    -- Si on collisionne sur les bords verticaux, on change de direction sur Y
    if self.y - self.radius < 0 or self.y + self.radius > platform.window:height()-12 then
            self.speedY = -self.speedY
        end
    -- Dans tous les cas, on actualise la position
    self.x = self.x + self.speedX
    self.y = self.y + self.speedY
end

-------------

Paddle = class()

function Paddle:init(x,size,dx,bonus)
    self.x = x
    self.size = size
    self.dx = dx
    self.bonus = bonus -- syntax = bonus, time left
    self.glow = 0
end

function Paddle:grabBonus(bonus)
    bonus.timeLeft = 1000
    table.insert(BonusTable,bonus)
    print("I haz bonuss :", bonus.bonusType)
    -- TODO                
    if bonus.bonusType == "PaddleGrow" then
        self.size = self.size + 8
    elseif bonus.bonusType == "PaddleShrink" then
        self.size = self.size - 8
    elseif bonus.bonusType == "BallClone" then
        table.insert(BallsTable,Ball(math.random(1,platform.window:width()),platform.window:height()-26,-2,-2,#BallsTable+1))
    elseif bonus.bonusType == "BallGrow" then
        for _, ball in pairs(BallsTable) do 
             ball.radius = ball.radius + 6
        end
    end
end     

function Paddle:goGlow(number)
    self.glow = number
end

function Paddle:paint(gc)
    gc:setColorRGB(0,0,200)
    fillRoundRect(gc,self.x,platform.window:height()-10,self.size,6,2)
    if self.glow > 0 then 
        gc:setColorRGB(255,100,0)
        fillRoundRect(gc,self.x+2,platform.window:height()-11,self.size-20,3,1)
        self.glow = self.glow - 1
    end
    if #self.bonus > 0 then
    
    end
end

-------------                     

Block = class()

function Block:init(x, y, w, h, state)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.state = state
end
                         
function Block:paint(gc)
    gc:setColorRGB(0,0,0)
    gc:drawRect(self.x, self.y, self.w, self.h)
    if self.state == "breakable" then 
        gc:setColorRGB(0,255,0)
    elseif self.state == "solid" then
        gc:setColorRGB(0,0,255)
    elseif self.state == "unbreakable" then
        gc:setColorRGB(200,200,200)
    end
    gc:drawRect(self.x+1, self.y+1, self.w-2, self.h-2)
end 

function Block:destroy()
   print("BlockDestroy called")
end

---------------

Bonus = class()

function Bonus:init(x, y, bonusType)
    self.x = x
    self.y = y
    self.bonusType = bonusType
    self.timeLeft = 9999
end

function Bonus:paint(gc)
    gc:setColorRGB(0,0,0)
    gc:fillRect(self.x,self.y,15,15) 
    gc:setColorRGB(200,0,200)
    gc:fillRect(self.x+1,self.y+1,13,13)
    gc:setColorRGB(255,0,0)
    gc:fillRect(self.x+2,self.y+2,11,11)
end

function Bonus:update()
    self.y = self.y + 1
end

function Bonus:fallsOnPaddle()
    return (self.y > platform.window:height()-16) and (self.x >= paddle.x-paddle.size*0.5-4 and (self.x <= paddle.x+paddle.size*0.5+4))
end

function Bonus:destroy()
    self.y = self.y + pwh() -- go outscreen
    table.remove(FallingBonusTable,1)

end

function resetBonus(bonus)     
    if bonus.bonusType == "PaddleGrow" then
        paddle.size = paddle.size - 8
    elseif bonus.bonusType == "PaddleShrink" then
        paddle.size = paddle.size + 8
    elseif bonus.bonusType == "BallClone" then
            -- Do nothing
    elseif bonus.bonusType == "BallGrow" then
        for _, ball in pairs(BallsTable) do 
             ball.radius = ball.radius - 3
        end
    end
end
