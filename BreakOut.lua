-- Adriweb (with help from Levak), 2011
-- BreakOut "Casse Brique" Game
-- v1.6a                                 
                                 
-------------------------------   
------------Globals------------
------------------------------- 

BlockWidth = 20
BlockHeight = 10

totalBlocksToDestroy = 0

currentLevel = {numberOfBlocks, xPositions = {}, yPositions = {}, blocksStates = {}}
possibleStates = {"breakable", "solid", "unbreakable"}
bonusTypes = {"PaddleGrow", "PaddleShrink", "BallClone", "BallGrow", "BallShrink"}  

level =   { {1,1,1}, {3,5,2}, {10,4,3} } -- level 1
--------   {}, -- level 2
--------   .....

function reset()
    win = false
    gameover = false
    pause = false
    waitContinue = false
    tmpCount = 0
    lives = 3
    score = -1
    secureNbr = 0
    BonusTable = {}    
    BlocksTable = {}
    BallsTable = {}
    FallingBonusTable = {}
        
    level = { {1,1,1}, {3,5,2}, {10,4,3} } -- level 1
    -- Random level : 
    for i=1,20 do
       table.insert(level,{math.random(0,12),math.random(0,10),randomAndCount()})
    end
    for i, blockTable in pairs(level) do
         table.insert(BlocksTable,Block(20*blockTable[1], 12*blockTable[2], 20, 12, blockTable[3], #BlocksTable+1))
    end
    totalBlocksToDestroy = #BlocksTable - totalBlocksToDestroy
end

function randomAndCount()
   theRand = math.random(1,3)
   if theRand == 3 then totalBlocksToDestroy = totalBlocksToDestroy + 1 end
   if theRand == 2 then totalBlocksToDestroy = totalBlocksToDestroy - 1 end
   return theRand
end

-------------------------------   
---------BetterLuaAPI----------
------------------------------- 


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
                         
                         
-------------------------------   
------------Events-------------
-------------------------------   


function on.create()
    reset()
    pause = false
    gameover = false
    on.resize()
    newPaddleY = 0
    while (math.floor(0.5*platform.window:width()-29)+newPaddleY)%4 ~= 0 do
         newPaddleY = newPaddleY+1
    end
    paddle = Paddle(0.5*platform.window:width()-29+newPaddleY,40,0,"")
    aBall = Ball(math.random(10,platform.window:width()-10-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1)
    table.insert(BallsTable,aBall)
    timer.start(0.01)
end

function on.timer()
    platform.window:invalidate()
end

function on.resize()
    platform.window:setPreferredSize(0,0)
    --TODO routine to know if running on calc or software/docPlayer
    isCalc = (pww() < 321)
    --print("isCalc = " .. tostring(isCalc) .. " (pww = " .. pww() .. ")")
    XLimit = isCalc and 58 or math.ceil(58*pww()/320)
    fixedX1 = 4+0.5*(pww()-XLimit+pww()-platform:gc():getStringWidth("Nspire"))
    fixedX2 = 6+0.5*(pww()-XLimit+pww()-platform.gc():getStringWidth("BreakOut"))
end

function on.charIn(ch)
    if ch == "p" then pause = not pause end
    if ch == "r" then
        on.create()
    end
    if ch == "h" then
       needHelp = not needHelp
    end
end

function on.mouseMove(x,y)
   if not pause and x<platform.window:width()-XLimit-paddle.size*0.5 and x>paddle.size*0.5 then paddle.x = x end
end

function on.paint(gc)
  gc:setColorRGB(0,0,0)
  if #BallsTable < 1 or secureNbr > 10 then
      lives = lives - 1
      if lives < 1 then
          gameover = true
      else
        paddle.x = 0.5*platform.window:width()-29+newPaddleY
        aBall = Ball(paddle.x,platform.window:height()-26,-1,-1,#BallsTable+1)
        table.insert(BallsTable,aBall)
        pause = true
        waitContinue = true
      end
  end
  if lives < 1 then gameover = true end
  if tmpCount >= totalBlocksToDestroy and tmpCount > 0 and totalBlocksToDestroy > 0 then win = true end  -- a revoir
  if not gameover and not needHelp and not win then
  
    sideBarStuff(gc)
    if score == -1 then score = 0 end
    if not pause then score = score + 0.2 end
        
    ballStuff(gc)
    bonusStuff(gc)
     
  elseif gameover then
      drawCenteredString(gc,"Game Over ! Score = " .. tostring(math.floor(score)))
  elseif win then
      drawCenteredString(gc,"You won ! Score = " .. tostring(math.floor(score)))
  elseif needHelp then
      --todo : help screen
   end
end

function on.arrowKey(key)
    if key == "right" and paddle.x < platform.window:width()-20-XLimit then
        paddle.dx = 8
    elseif key == "left" and paddle.x >= 25 then
        paddle.dx = -8
    end
end

function on.enterKey()
    print("------------------")
    print("#BallsTable = " .. #BallsTable)
    for _, ball in pairs(BallsTable) do
       print("    ball." .. ball.id .. " : x=" .. ball.x .. " y=" .. ball.y)
    end
    print("#BonusTable = " .. #BonusTable)
    print("#BlocksTable = " .. #BlocksTable)
    print("tmpCount = " .. tmpCount)
    print("totalBlocksToDestroy = " .. totalBlocksToDestroy)
    print("Lives = " .. lives)
end


-------------------------------   
--------on.paint stuff---------     
------------------------------- 

function sideBarStuff(gc)
    gc:drawLine(platform.window:width()-XLimit,0,platform.window:width()-XLimit,platform.window:height())
    gc:setFont("serif","r",10)
    gc:drawString("Nspire",fixedX1,pwh()-63,"top") 
    gc:drawString("BreakOut",fixedX2,pwh()-49,"top")
    gc:drawString("Adriweb",4+fixedX2,pwh()-22,"top")
end
          
function ballStuff(gc)
    for _, ball in pairs(BallsTable) do
       if 2*ball.radius-2 < 0 then ball.radius = 5 end
       if ball.y+ball.radius > platform.window:height()-15 then
          if not ball:intersectsPaddle() then
             table.remove(BallsTable,ball.id)
          else
             ball:PaddleChock()
             if not ball:touchedEdgesOfPaddle() then paddle:goGlow(12) end
             local increment = 0.7*(-1+test(ball.speedX > 0))*math.abs(ball:howFarAwayFromTheCenterOfThePaddle())
             if ball.x > 10 and ball.x < pww()-10 then ball.x = ball.x + increment end
          end
       end
        
        for _, block in pairs(BlocksTable) do
          if block ~= 0 then
            if ball:intersectsBlock(block) then
                ball:BlockChock(block)
                block:destroy()
            end
            if pause then 
               gc:setAlpha(127)
            end
            block:paint(gc)
            if pause then 
               gc:setAlpha(255)
            end
          end
        end
         
        if not pause then
           ball:update() 
           paddleStuff(gc)
        end       
        
        if pause then 
           gc:setAlpha(127)
        end
        
        ball:paint(gc)
        paddle:paint(gc)
           
        if pause then
           gc:setAlpha(255)
           if waitContinue then 
              gc:drawString(lives .. " balls left... (Press 'P')",0.5*(pww()-gc:getStringWidth(lives .. " balls left... (Press 'P')")-26),pwh()/2+25,"top") 
           else
               drawCenteredString(gc,"... Pause ...")
           end
        end
        
        if not pause and math.random(1,300) == 100 then table.insert(FallingBonusTable,Bonus(math.random(5,pww()-70),0,bonusTypes[math.random(1,#bonusTypes)])) end
    end
end

function paddleStuff(gc)
   if paddle.dx > 0 then
       paddle.x = paddle.x + paddle.dx
       paddle.dx = paddle.dx - 1 -- a augmenter si on-calc
   elseif paddle.dx < 0 then
       paddle.x = paddle.x + paddle.dx
       paddle.dx = paddle.dx + 1 -- a augmenter si on-calc
   end
end

function bonusStuff(gc)
   for _, bonus in pairs(FallingBonusTable) do
        if pause then gc:setAlpha(127) end
        bonus:paint(gc)
        if pause then gc:setAlpha(255) end
        if not pause then bonus:update() end
        if bonus:fallsOnPaddle() then paddle:grabBonus(bonus) ; bonus:destroy() end
        if bonus.y > platform.window:height() - 16 and not bonus:fallsOnPaddle() then bonus:destroy() end
   end
   for i, bonus in pairs(BonusTable) do
        gc:setColorRGB(0,0,255)
        if bonus.timeLeft < 666 then gc:setColorRGB(0,0,0) end
        if bonus.timeLeft < 333 then gc:setColorRGB(255,0,0) end
        gc:drawString(bonus.bonusType .. " : " .. tostring(bonus.timeLeft),0,i*12,"top")
        if not pause then bonus.timeLeft = bonus.timeLeft - 1 end
        if bonus.timeLeft < 2 then table.remove(BonusTable,1) ; resetBonus(bonus) end
   end 
end
                            
-------------------------------   
----------Ball Class-----------     
-------------------------------    

Ball = class()

function Ball:init(x, y, speedX, speedY, id)
    self.x = x
    self.y = y
    self.speedX = speedX
    self.speedY = speedY
    self.radius = 5 -- radius   <- debug ?
    self.id = id
end

function Ball:paint(gc)
    gc:setColorRGB(0,0,0)
    gc:drawArc(self.x-self.radius, self.y-self.radius, 2*self.radius, 2*self.radius, 0, 360)
    gc:setColorRGB(127,127,0)
    gc:fillArc(self.x-self.radius+1, self.y-self.radius+1, 2*self.radius-2, 2*self.radius-2, 0, 360)
end

function Ball:intersectsBlock(block)         
    return (self.x > block.x-self.radius-2 and self.x < (block.x + block.w + self.radius + 2)) and (self.y > block.y+self.radius + 2 and self.y < (block.y + block.h + self.radius + 2))
end

function Ball:intersectsBall(ball)
    return math.sqrt((ball.x - self.x)*(ball.x - self.x) + (ball.y - self.y)*(ball.y - self.y)) < self.radius + ball.radius
end

function Ball:intersectsPaddle()
    return (self.y+self.radius > platform.window:height()-16) and (self.y+self.radius < platform.window:height()+10) and (self.x >= paddle.x-paddle.size*0.5-4 and (self.x <= paddle.x+paddle.size*0.5+4))
end

function Ball:BlockChock(block)
	--print("ball touched block #" .. block.id)
    
    if self.y > block.y+block.h or self.y < block.y then
        self.speedY = -self.speedY
    end
    if self.x > block.x+block.w or self.x < block.x then
       self.speedX = -self.speedX 
    end
    
    if block.state == 3 then
       if self.speedY > 0 then
          if self.speedX > 0 then 
             self.x = self.x + 1*math.random(0,1)
          end
          self.y = self.y + 1*math.random(0,1)
       else
          if self.speedX > 0 then 
             self.x = self.x + 1*math.random(0,1)
          end
          self.y = self.y + 1*math.random(0,1)
       end
    end
    
end  

function Ball:touchedEdgesOfPaddle() 
    return ( self.x >= paddle.x-paddle.size*0.5-4 and self.x <= paddle.x-paddle.size*0.5+4 ) or ( self.x >= paddle.x+paddle.size*0.5-4 and self.x <= paddle.x+paddle.size*0.5+4 )
end

function Ball:howFarAwayFromTheCenterOfThePaddle()
   return self.x-paddle.x
end

function Ball:PaddleChock()
   self.speedY = -self.speedY
   if self:touchedEdgesOfPaddle() then
       self.speedX = self.speedX * 1.1
       --print("edge of paddle touched ; speedX is now : ",tostring(self.speedX))
   end                                                                                                       
end

function Ball:update()
    -- Si on collisionne sur les bords horizontaux, on change de direction sur X
    if self.x - self.radius < 0 or self.x + self.radius > platform.window:width()-XLimit then
        self.speedX = -self.speedX
    end
    -- Si on collisionne sur les bords verticaux, on change de direction sur Y
    if self.y - self.radius < 0 then -- gestion du haut. Pour le bas, voir le paddleChock
        self.speedY = -self.speedY
    end
    -- Dans tous les cas, on actualise la position
    self.x = self.x + self.speedX
    self.y = self.y + self.speedY 
    
    if self.y > pwh()+5 or self.y < -1 or self.x < -5 or self.x > platform.window:width()-XLimit+2 then secureNbr = secureNbr + 1 ; table.remove(BallsTable,self.id) end    -- just in case ...
end                          


-------------------------------   
---------Paddle Class----------
------------------------------- 

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
    -- TODO                
    if bonus.bonusType == "PaddleGrow" then
        self.size = self.size + 8
    elseif bonus.bonusType == "PaddleShrink" then
        self.size = self.size - 8
    elseif bonus.bonusType == "BallClone" then
        table.insert(BallsTable,Ball(math.random(1,platform.window:width()-XLimit),platform.window:height()-26,-1,-1,#BallsTable+1))
    elseif bonus.bonusType == "BallGrow" then
        for _, ball in pairs(BallsTable) do 
             if ball.y-ball.radius < 5 then
                ball.y = ball.y + 6
             end
             ball.radius = ball.radius + 5
        end
    elseif bonus.bonusType == "BallShrink" then
        for _, ball in pairs(BallsTable) do 
             if ball.y-ball.radius < 5 then
                ball.y = ball.y + 6
             end
             if ball.radius > 4 then ball.radius = ball.radius - 4 end
        end
    end
end     

function Paddle:goGlow(number)
    self.glow = number
end

function Paddle:paint(gc)
    gc:setColorRGB(0,0,200)
    --fillRoundRect(gc,self.x,platform.window:height()-10,self.size,6,2)
    gc:drawImage(image.copy(paddleImg, (self.size/image.width(paddleImg)) * image.width(paddleImg)-2, image.height(paddleImg)),self.x-0.5*self.size,platform.window:height()-14)
    if self.glow > 0 then 
        gc:setColorRGB(255,100,0)
        fillRoundRect(gc,self.x-1,platform.window:height()-13,self.size-0.5*self.size,3,1)
        self.glow = self.glow - 1
    end
end

-------------------------------   
---------Block Class-----------
-------------------------------                     

Block = class()

function Block:init(x, y, w, h, state, id)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.state = state
    self.id = id
end
                         
function Block:paint(gc)
    gc:setColorRGB(0,0,0)
    gc:fillRect(self.x, self.y, self.w, self.h)
    if self.state == 1 then -- "breakable"
        gc:setColorRGB(0,255,0)
    elseif self.state == 2 then-- "solid"
        gc:setColorRGB(0,0,255)
    elseif self.state == 3 then   -- "unbreakable"
        gc:setColorRGB(200,200,200)
    end
    gc:fillRect(self.x+1, self.y+1, self.w-2, self.h-2)
end 

function Block:destroy()  
   if self.state == 2 then
       self.state = 1 
       table.remove(BlocksTable,self.id)
       table.insert(BlocksTable,self.id,self) 
   elseif self.state == 1 then
       table.remove(BlocksTable,self.id)
       table.insert(BlocksTable,self.id,0) 
   end
   if self.state <= 2 then
      tmpCount = tmpCount + 1
   end
end


-------------------------------   
---------Bonus Class-----------
------------------------------- 

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
             if ball.radius > 4 then ball.radius = ball.radius - 5 end
        end
    elseif bonus.bonusType == "BallShrink" then
        for _, ball in pairs(BallsTable) do 
             if not ball.radius == 4 then ball.radius = ball.radius + 5 end
        end
    end
end 


-------------------------------   
------------Images-------------
------------------------------- 

paddleImg = image.new("\046\0\0\0\010\0\0\0\0\0\0\0\092\0\0\0\016\0\001\0alal\047\132\080\132\081\136\115\136\149\140\149\140\184\140\184\140alalalalalalalalalalalalalalalalalalalalalalalalalal\184\140\184\140\149\140\149\140\116\136\081\136\080\132\080\132alalal\047\132\080\132\081\136\214\152\153\177\026\190\059\194\092\194\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\194\059\194\026\190\026\190\055\161\115\136\081\136\080\132al\047\132\047\132\081\136\055\161\223\247\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\188\210\115\136\080\132\047\132\047\132\047\132\115\136\218\226\123\251\123\247\123\247\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\247\123\251\123\251\055\161\080\132\048\132\047\132\080\132\116\136\115\230\115\242\115\230\115\230\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\230\115\242\115\242\085\177\081\136\080\132\047\132\080\132\115\136\211\204\140\229\140\229\140\217\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\217\140\217\140\229\140\229\211\152\081\136\080\132\047\132\080\132\115\136\116\136\204\204\198\228\132\220\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\220\132\224\200\224\179\164\115\136\081\136\080\132al\080\132\115\136\116\136\052\185\147\229\055\161\056\169\250\144\250\144\250\144\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\250\144\250\144\217\152\217\140\181\221\147\205\149\140\115\136\081\136alalal\115\136\116\136\179\164\045\229\214\152\217\140\217\140\217\140alalalalalalalalalalalalalalalalalalalalalalalalalal\217\140\217\140\217\140\214\152\045\229\179\164\116\136\115\136alalalalalalal\204\176\137\212\177\172alalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\179\164\137\212\204\176alalalalal")
