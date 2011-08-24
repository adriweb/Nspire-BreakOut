-- Adriweb (with help from Levak), 2011
-- BreakOut "Casse Brique" Game

gameVersion = "v1.8.5b"                                 
                                 
-------------------------------   
------------Globals------------
------------------------------- 

BlockWidth = 20
BlockHeight = 12

touchEnabled = false

totalBlocksToDestroy = 0 

device = { api, hasColor, isCalc, theType, lang }
device.api = platform.apilevel
device.hasColor = platform.isColorDisplay()
device.lang = locale.name()

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
    BonusTable = {Bonus(-1,-1,"PaddleGrow"), Bonus(-1,-1,"PaddleShrink"), Bonus(-1,-1,"BallClone"), Bonus(-1,-1,"BallGrow"), Bonus(-1,-1,"BallShrink")}
    BlocksTable = {}
    BallsTable = {}
    FallingBonusTable = {}
        
    level = { {1,1,1}, {3,5,2}, {10,4,3} } -- level 1
    -- Random level : 
    for i=1,20 do
       table.insert(level,{math.random(0,12),math.random(0,10),math.random(1,3)})
    end
    for i, blockTable in pairs(level) do
         table.insert(BlocksTable,Block(20*blockTable[1]*XRatio, 12*blockTable[2]*YRatio, BlockWidth*XRatio, BlockHeight*YRatio, blockTable[3], #BlocksTable+1))
    end
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
                         
function drawXCenteredString(myGC,str,y)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, y, "top")
end

-------------------------------   
------------Events-------------
-------------------------------   


function on.create()
    reset()
    pause = false
    gameover = false
    needHelp = true
    on.resize()
    newPaddleY = 0
    while (math.floor(0.5*platform.window:width()-29)+newPaddleY)%4 ~= 0 do
         newPaddleY = newPaddleY+1
    end
    paddle = Paddle(0.5*platform.window:width()-29+newPaddleY,40*XRatio,0,"")
    aBall = Ball(math.random(10,platform.window:width()-10-XLimit),platform.window:height()-26,-1-speedDiff,-1-speedDiff,#BallsTable+1)
    table.insert(BallsTable,aBall)
    timer.start(0.01)
end

function on.timer()
    platform.window:invalidate()
end

function on.resize()
    if device.api == "1.1" then platform.window:setPreferredSize(0,0) end
    device.isCalc = (platform.window:width() < 320)
    device.theType = platform.isDeviceModeRendering() and "handheld" or "software"
    
    if not device.isCalc or device.theType == "software" then touchEnabled = true end
    
    XLimit = device.isCalc and 58 or math.ceil(58*pww()/320)
    fixedX1 = 4+0.5*(pww()-XLimit+pww()-platform:gc():getStringWidth("Nspire"))
    fixedX2 = 6+0.5*(pww()-XLimit+pww()-platform.gc():getStringWidth("BreakOut"))
    XRatio = platform.window:width()/318
    YRatio = platform.window:height()/212
    
    BlocksTable = {}
    for i, blockTable in pairs(level) do
         table.insert(BlocksTable,Block(20*blockTable[1]*XRatio, 12*blockTable[2]*YRatio, BlockWidth*XRatio, BlockHeight*YRatio, blockTable[3], #BlocksTable+1))
    end
    totalBlocksToDestroy = #BlocksTable - totalBlocksToDestroy 
    
    speedDiff = test(device.isCalc and device.theType == "handheld")
end

function on.charIn(ch)
    if ch == "p" then pause = not pause
    elseif ch == "r" then
        on.create()
    elseif ch == "h" then
       needHelp = not needHelp
    elseif ch == "t" then
       touchEnabled = not touchEnabled
    elseif ch == "6" then
       on.arrowKey("right")
    elseif ch == "4" then
       on.arrowKey("left")
    end
end

function on.mouseMove(x,y)
   if touchEnabled and not pause and x+paddle.size*0.5<platform.window:width()-XLimit+5*test(not device.isCalc) and x>paddle.size*0.5 then paddle.x = x end
end

function on.escapeKey()
   needHelp = not needHelp
end
  
function on.paint(gc)
   --------
   if device.api == "1.0" then
       platform.gc():setColorRGB(0,0,0)
       platform.gc():setFont("serif","r",12)
       drawCenteredString(platform.gc(),"The GAME.")
       gc:setColorRGB(255,255,255)
       gc:fillRect(1,1,pww(),pwh())
   end
   -------
   
  gc:setColorRGB(0,0,0)
  if #BallsTable < 1 or secureNbr > 10 then
      lives = lives - 1
      if lives < 1 then
          gameover = true
      else
        paddle.x = 0.5*platform.window:width()-29+newPaddleY
        aBall = Ball(paddle.x,platform.window:height()-26,-1-speedDiff,-1-speedDiff,#BallsTable+1)
        table.insert(BallsTable,aBall)
        pause = true
        waitContinue = true
      end
  end
  if lives < 1 then gameover = true end
  
  for _,v in pairs(BlocksTable) do
     tmpCount = tmpCount + (type(v) == number and 1 or 0)
  end
  
  if tmpCount >= #BlocksTable and tmpCount > 0 then win = true end  -- a revoir
  
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
      helpScreen(gc)
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
    if needHelp then needHelp = not needHelp end
    print("------------------")
    print("tmpCount = " .. tmpCount)
    print("totalBlocksToDestroy = " .. totalBlocksToDestroy)
end

function on.help()
   needHelp = not needHelp
end


-------------------------------   
--------on.paint stuff---------     
------------------------------- 

function sideBarStuff(gc)
    gc:drawLine(platform.window:width()-XLimit,0,platform.window:width()-XLimit,platform.window:height())
    gc:setFont("serif","r",10)
    gc:drawString("______",fixedX1-2,pwh()-89,"top")
    gc:drawString("Nspire",fixedX1,pwh()-68,"top") 
    gc:drawString("BreakOut",fixedX2,pwh()-54,"top")
    gc:drawString("______",fixedX1-2,pwh()-43,"top")
    gc:drawString("Adriweb",4+fixedX2,pwh()-22,"top")
    
    gc:drawString("Balls Left :",fixedX1-9,pwh()*.5-22,"top")
    gc:drawString(lives,fixedX1+14,pwh()*.5-22+14,"top")
end
          
function ballStuff(gc)
    for _, ball in pairs(BallsTable) do
       if 2*ball.radius-2 < 0 then ball.radius = 5 end
       if ball.y+ball.radius > platform.window:height()-15 then
          if not ball:intersectsPaddle() then
             table.remove(BallsTable,ball.id)
          else
             ball:PaddleChock()
             if not ball:touchedEdgesOfPaddle() then paddle.glow = 12 end
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
              for _, bonus in pairs(BonusTable) do
                 resetBonus(bonus)
              end
              gc:drawString(lives .. " ball(s) left... (Press 'P')",0.5*(pww()-gc:getStringWidth(lives .. " ball(s) left... (Press 'P')")-32),pwh()/2+25,"top") 
           else
               drawCenteredString(gc,"... Pause ...")
           end
        end
        
        if not pause and math.random(1,450) == 100 then table.insert(FallingBonusTable,Bonus(math.random(5,pww()-65),0,bonusTypes[math.random(1,#bonusTypes)])) end
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
        if bonus.timeLeft > 2 then gc:drawString(bonus.bonusType .. " : " .. tostring(bonus.timeLeft),0,i*12,"top") end
        if not pause and not (bonus.timeLeft < 1) then bonus.timeLeft = bonus.timeLeft - 1 end
        if bonus.timeLeft < 2 and bonus.timeLeft ~= -10 then resetBonus(bonus) end
   end 
end

function helpScreen(gc)
   gc:setColorRGB(175,175,175) -- grey
   gc:fillRect(pww()*0.10,pwh()*0.15,pww()*0.8,pwh()*0.7)
   gc:setColorRGB(0,0,0) -- black
   gc:drawRect(pww()*0.10,pwh()*0.15,pww()*0.8,pwh()*0.7)
   
   gc:drawImage(gameLogo,.5*(pww()-image.width(gameLogo)), pwh()*.19)
   gc:setColorRGB(0,0,0) -- bugfix to prevent image to update the current color
   
   gc:setFont("serif","r",11)
   drawXCenteredString(gc,"Paddle Control : Arrows or 4/6",pwh()*0.52)
   drawXCenteredString(gc,"'T' to enable touch-controls",pwh()*0.60)
   
   playResume = (score > 10) and "resume" or "play"
   gc:setFont("serif","b",12)
   drawXCenteredString(gc,"Press enter to " .. playResume,pwh()*0.72)
   
   gc:setFont("serif","r",12)
   drawXCenteredString(gc,"Nspire BreakOut " .. gameVersion .. " | Adriweb 2011",pwh()*0.03*YRatio)
   gc:setFont("serif","i",12)
   drawXCenteredString(gc,"Thanks to Levak, Jim Bauwens, Omnimaga...",pwh()*0.87)
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
    if block.state == 3 then
       return (self.x > block.x-self.radius-3 and self.x < (block.x + block.w + self.radius + 3)) and (self.y > block.y+self.radius + 3 and self.y < (block.y + block.h + self.radius + 3))
    end
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
    if self.x - self.radius < 0 or self.x + self.radius > platform.window:width()-XLimit-1 then
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
    
    for _,v in pairs(BonusTable) do
        if v.bonusType == bonus.bonusType then
           v.timeLeft = v.timeLeft + 1000
        end
    end
        
    if bonus.bonusType == "PaddleGrow" then
        self.size = 60*XRatio
    elseif bonus.bonusType == "PaddleShrink" then
        self.size = 20*XRatio
    elseif bonus.bonusType == "BallClone" then
        table.insert(BallsTable,Ball(math.random(1,platform.window:width()-XLimit),platform.window:height()-26,-1-speedDiff,-1-speedDiff,#BallsTable+1))
    elseif bonus.bonusType == "BallGrow" then
        for _, ball in pairs(BallsTable) do 
             if ball.y-ball.radius < 5*XRatio then
                ball.y = ball.y + 6*XRatio
             end
             ball.radius = ball.radius + 5
        end
    elseif bonus.bonusType == "BallShrink" then
        for _, ball in pairs(BallsTable) do 
             if ball.y-ball.radius < 5*XRatio then ball.y = ball.y + 6 end
             if ball.radius > 4*XRatio then ball.radius = ball.radius - 4 end
        end
    end
end

function Paddle:paint(gc)
    gc:setColorRGB(0,0,200)
    --fillRoundRect(gc,self.x,platform.window:height()-10,self.size,6,2)
    gc:drawImage(image.copy(paddleImg, math.abs((self.size/image.width(paddleImg)) * image.width(paddleImg)-2),math.abs(image.height(paddleImg))),self.x-0.5*self.size,platform.window:height()-14)
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
    self.timeLeft = -10
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
    return (self.y+4 > platform.window:height()-16) and (self.x >= paddle.x-paddle.size*0.5-4 and (self.x <= paddle.x+paddle.size*0.5+4))
end

function Bonus:destroy()
    self.y = self.y + pwh() -- go outscreen
    table.remove(FallingBonusTable,1)
end

function resetBonus(bonus)     
    if bonus.bonusType == "PaddleGrow" then
        paddle.size = 40*XRatio
    elseif bonus.bonusType == "PaddleShrink" then
        paddle.size = 40*XRatio
    elseif bonus.bonusType == "BallClone" then
            -- Do nothing
    elseif bonus.bonusType == "BallGrow" then
        for _, ball in pairs(BallsTable) do 
             if ball.radius > 4*XRatio then ball.radius = ball.radius - 5*XRatio end
        end
    elseif bonus.bonusType == "BallShrink" then
        for _, ball in pairs(BallsTable) do 
             if not ball.radius == 4*XRatio then ball.radius = ball.radius + 5*XRatio end
        end
    end
end 


-------------------------------   
------------Images-------------
------------------------------- 

gameLogo = image.new("\156\0\0\0\068\0\0\0\0\0\0\0\056\001\0\0\016\0\001\0alalalalalalalalalalalalalalal\255\127\255\127\247^\214Z\247^\181V\214Z\246\222\247\222\213\218\115\206\214\218\023\227\214\218\214Z\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\016B\255\127\255\127al\213\218\214\218\247\222\023\227\180\214\048\198\213\218\024\227\246\222\213\218al\0\0\255\127alalal\255\127alalal\255\127alalalal\255\127alalalalalalalalalalalal\255\127alalalalalalalalalalalalalalalalalalalalalalalalal\181V\016B\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127alalalalalalal\255\127\255\127alal\181V\214\218\214\218\214\218\246\222\246\222\024\227\180\218\014\198\213\218\023\227\246\222\214\218al\016B\255\127\255\127alal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalal\255\127\255\127alalalalalalal\255\127alalalalalalalalal\255\127\255\127alal\255\127\255\127alalalalalalal\255\127\255\127alalal\016B\255\127alalalalalalal\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127al\255\127alal\255\127alalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127alalalalalal\255\127\255\127\255\127\016B\214Z\214\218\247\222\247\222\214\218\214\218\247\222\024\227\212\218\046\198\213\218\024\227\024\227\214\218\181\214al\181V\255\127alalal\255\127alalalalalal\255\127\255\127\255\127alalalalalalalalalalalalal\255\127al\255\127alalal\255\127\255\127\255\127al\255\127\255\127alal\255\127alalalalalal\255\127\255\127al\214\218\214\218\214\218al\016B\255\127alalalalal\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127alal\255\127alal\255\127\255\127\255\127alal\255\127al\255\127al\255\127\255\127\255\127alalalalalalalalalalalalalal\255\127\255\127alalalalalalalalal\0\0\255\127al\214\218\214\218\247\222\214\218\181\214\214\218\214\218\247\222\056\227\212\218\046\198\213\222\056\231\247\222\246\222\214\218\247\222al\181V\255\127alalalalalalalalalalalalal\255\127\0\0alalalalalalalalalal\255\127\255\127alalalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalal\255\127\255\127\255\127\0\0\214\218\214\218\214\218\214\218\181\214al\255\127alalal\255\127\255\127\255\127al\255\127alal\255\127alalalalalalalalalalalalalalalalal\255\127al\255\127alal\255\127al\255\127alal\255\127\255\127alalal\255\127\255\127alalalalalal\255\127alalalalalalalalalalalalalal\255\127\255\127alalalalalalalalal\255\127\181Val\214\218\214\218\246\222\214\218\181\214\181\218\214\218\246\222\247\222\056\231\212\222\047\202\246\222\056\231\023\227\246\222\214\218\214\218\247\222al\181V\255\127alalalalalalalalal\255\127\255\127\224\127\255\127\255\127\255\127\0\0\255\127alalalalalal\255\127\255\127alalalalal\255\127\255\127alalalal\255\127alalalalalal\255\127alal\214\218\247\222\214\218\213\214\247\222\214\218al\255\127\255\127alal\255\127\255\127alal\255\127alalalalal\255\127alalal\255\127alalal\255\127alalal\255\127\255\127\255\127al\255\127\255\127alal\255\127\255\127alalal\255\127\255\127al\255\127\255\127al\255\127alalalalal\255\127\255\127alalalalalalalalalalalalalal\255\127alalalalalalalalal\255\127\181Val\214\218\214\218\247\222\246\222\214\218\180\214\213\218\247\222\247\222\247\222\056\231\245\222\046\202\213\222\056\231\056\231\247\222\214\218\214\218\214\218\214\218al\181V\255\127alalalalalalalal\0\0al\255\127\255\127\255\127alal\255\127\255\127alalalalalalalalalalalal\255\127\255\127\255\127\255\127alal\255\127alalalalal\255\127\255\127al\214\218\214\218\247\222\148\210\148\210\247\222\246\222\214\218al\255\127alal\255\127\255\127\255\127\0\0\255\127\255\127\255\127alalalal\255\127\255\127alalalalalalalalal\255\127alal\255\127alal\255\127\255\127alalalalal\255\127\255\127alal\255\127\255\127\255\127alalal\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalal\255\127\181Val\214\218\214\218\247\222\214\218\247\222\214\218\148\214\213\218\023\227\247\222\247\222\056\231\022\227\046\202\114\206\023\227\056\231\023\227\213\218\213\218\247\222\214\218\213\218al\255\127alalalalalal\255\127\255\127\255\127\181V\214\218\214\218\214\218\214\218\181\214al\016Balalalalalalalalalalal\255\127alal\255\127al\255\127\255\127alalalalalal\0\0\255\127al\214\218\247\222\247\222\147\206\147\206\246\222\024\227\214\218al\240^al\255\127al\255\127\255\127\255\127\255\127al\255\127\255\127alalalalal\255\127\255\127\255\127alalalal\255\127\255\127\255\127\255\127al\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\181Val\181\214\214\218\246\222\214\218\214\218\023\227\246\222\147\210\214\218\023\227\023\227\247\222\056\231\055\231\078\206\238\189\180\214\056\231\089\235\213\218\181\214\246\222\023\227\214\218\214\218al\016B\255\127alalalal\255\127al\214\218\214\218\246\222\247\222\247\222\214\218\214\218\181\214\255\127\255\127alalalalalalalalalal\255\127al\255\127al\255\127alalalalalalalal\255\127alal\214\218\024\227\246\222\147\206\148\210\247\222\024\231\214\218al\255\127al\255\127\255\127\255\127\255\127alalalalal\255\127\255\127alalalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\016B\255\127al\181\214\214\218\214\218\246\222\246\222\246\222\056\231\246\222\114\210\213\218\056\231\023\227\023\227\056\231\055\231\079\206\205\185\015\194\023\227\122\239\245\222\213\218\247\222\023\227\247\222\214\218\214\218al\016Balalal\255\127al\031~\214\218\056\231\247\222\213\218\213\218\247\222\247\222\214\218al\247^alalalalalalalalalalal\255\127alalalalalalalalalalal\255\127al\181\214\246\222\056\231\246\218\114\206\148\210\023\223\024\227\214\218\181\214al\016B\255\127\255\127alal\214\218\181\214\148\210\214\218\181\214al\016Balal\255\127\181V\181V\255\127\255\127alal\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127\016B\247^\181V\255\127al\255\127\255\127alalalalalalalalalalalal\255\127\255\127alal\214\218\214\218\214\218\214\218\247\222\023\227\246\222\213\218\179\214\048\202\213\218\088\235\023\227\023\227\056\231\055\235\079\206\205\185\238\189\180\214\246\222\147\210\180\214\023\227\056\231\214\218\246\222\214\218\214\218\255\127\255\127alal\255\127al\214\218\246\222\024\227\213\218\014\194\114\206\023\227\024\227\214\218alal\247^alalalalalalalalalalalalalalalalalalalalal\255\127\0\0al\214\218\246\222\024\227\246\222\081\198\114\202\023\223\023\227\214\218\181\214al\181Val\181Val\214\218\214\218\214\218\180\210\214\218\214\218al\255\127\247^\016B\255\127alalalal\247\222\181\214alal\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalal\255\127\0\0\255\127al\255\127alalal\255\127\181V\255\127\255\127alalalalalal\255\127alalalalal\255\127al\214Z\214\218\214\218\247\222\214\218\214\218\023\227\056\231\246\222\048\198\238\189\014\194\213\222\088\235\246\222\055\231\056\231\087\235\079\210\237\189\014\194\014\194\238\189\238\189\147\210\056\231\089\235\246\222\181\214\247\222\214\218\214\218al\255\127\255\127\255\127al\214\218\247\222\024\227\213\218\013\194\146\206\024\227\247\222\214\218\214\218alal\181V\255\127alalalalalalalalalalalalalalalalalalal\255\127\255\127al\214\218\246\222\023\227\023\227\081\198\081\198\023\227\023\227\247\222\214\218al\247^\016B\255\127\181\214\214\218\023\227\181\214\180\214\214\218\214\218\214\218alalalsN\214\218\214\218\214\218\214\218\214\218\214\218\214\218\245\214al\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalal\255\127alsN\255\127al\214\218\214\218\214\218\016Bal\016B\0\0\255\127alalalalal\0\0\255\127alalal\255\127\255\127al\214\218\246\222\246\222\246\222\247\222\246\222\023\227\089\235\245\222\015\194\238\189\014\198\245\222\055\231\179\214\056\231\023\227\055\235\111\210\237\189\014\194\014\194\238\189\237\189\081\202\023\227\089\235\246\222\148\210\214\218\247\222\214\218al\255\127\016Balal\214\218\056\231\056\231\212\218\013\194\146\210\056\231\023\227\247\222\214\218\214\218\214\218al\255\127\0\0alalalalalalalalalalalalalalalalal\255\127\255\127al\181\214\214\218\024\227\024\227\023\227\081\198\113\198\023\227\023\227\023\227\214\218al\247^\181Val\214\218\247\222\246\222\181\214\213\214\246\222\247\222\214\218\214\218\214\218\214\218\214\218\214\218\247\222\247\222\214\218\246\222\247\222\024\227\214\218\214\218al\181V\255\127alalalalalalalalalalalalalalalalalal\0\0al\214\218\214\218al\181\214\214\218\246\222\214\218\214\218\214\218\255\127\255\127\255\127\255\127\255\127alalal\0\0\255\127alal\255\127\181Val\181\214\214\218\023\227\247\222\214\222\213\218\246\222\056\231\121\239\180\214\238\193\014\194\014\202\246\226\023\227\212\218\055\231\180\214\245\222\079\210\237\193\014\194\014\194\238\189\013\194\014\194\213\218\122\239\246\222\114\206\213\218\024\227\214\218\214\218al\247^al\213\218\246\222\056\231\023\227\179\214\012\194\179\210\056\231\023\227\246\222\246\222\247\222\214\218\214\218al\0\0\0\0alalalalalalalalalalalalalalal\255\127\181Valal\214\218\214\218\247\222\056\231\023\227\081\198\114\198\023\227\024\227\023\227\214\218al\247^alal\214\218\024\227\247\222\180\210\180\214\247\222\247\222\246\222\247\222\247\222\247\222\246\222\213\218\246\222\247\222\214\218\246\222\023\227\246\222\023\227\214\218\214\218\255\127\181V\255\127alalalalalalalalalalalalalalalal\016Bal\247\222\214\218\214\218\245\222\213\218\024\227\247\222\214\218\246\222\214\218\214\218al\255\127\255\127\255\127\255\127alal\0\0\255\127alal\255\127al\181\214\214\218\247\222\247\222\024\227\213\218\048\198\180\214\122\239\121\239\146\210\238\193\014\198\046\202\180\218\212\218\212\222\088\231\048\194\047\202\077\206\014\194\046\198\014\194\014\194\014\194\014\194\179\214\122\239\022\227\114\206\213\218\023\227\023\227\214\218alal\016B\214\218\024\227\056\231\023\227\081\206\012\190\179\214\056\231\023\227\247\222\246\222\214\218\246\222\214\218\214\218al\255\127\255\127alalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alal\214\218\214\218\214\218\246\222\056\231\023\227\081\198\114\198\023\227\024\227\023\227\214\218al9gal\214\218\214\218\023\227\023\223\147\206\115\206\023\227\023\227\246\222\246\222\214\218\213\218\214\218\213\218\247\222\056\231\213\218\213\218\246\222\246\222\247\222\024\227\214\218\214\218\255\127\255\127alalalalalalalalalalalal\255\127\0\0\255\127\255\127alal\214\218\247\222\023\227\246\218\213\218\056\231\023\227\246\222\213\218\246\222\214\218\214\218\255\127\255\127\0\0\255\127\255\127\255\127\0\0\255\127\255\127\016Bal\181\214\214\218\214\218\246\222\023\227\056\231\180\214\014\190\179\214\121\239\121\239\146\214\013\194\046\202\046\206\048\206\014\198\245\226\088\235\015\194\013\198\077\210\046\198\046\198\046\198\014\194\014\198\014\198\147\210\122\239\055\231\114\206\246\222\023\227\247\222\214\218\214\218\214\218\214\218\214\218\023\227\089\235\056\231\081\202\011\190\211\214\056\231\056\231\023\227\023\227\213\218\147\210\247\222\246\222\214\218al\016Bal\255\127\255\127\255\127alalalalalalalalalalal\214\218\214\218\214\218\246\218\213\214\023\227\089\235\023\223\048\194\114\198\023\227\024\227\023\227\214\218al\181Val\214\218\214\218\023\227\023\227\147\206\114\202\023\227\023\227\214\218\247\222\246\222\214\218\246\222\246\222\024\227\089\235\213\218\081\202\048\198\147\210\023\227\023\227\247\222\214\218al\255\127\016B\255\127\255\127\0\0\255\127\255\127alalalalal\255\127\255\127alalalal\214\218\246\222\247\222\024\227\213\218\180\214\056\231\056\231\246\222\214\218\247\222\023\227\246\222\214\218\255\127\016B\0\0\255\127\255\127\255\127\255\127\016Balal\214\218\214\218\214\218\247\222\056\231\246\222\081\202\014\194\048\198\022\227\121\239\179\214\013\198\046\206\078\214\014\202\237\193\212\226\023\227\047\194\046\198\077\210\046\202\046\198\046\198\046\198\046\202\013\198\146\210\121\239\246\222\048\198\213\218\056\231\023\227\247\222\214\218\214\218\214\218\023\227\023\227\056\231\056\231\114\206\043\194\211\214\089\235\056\231\056\231\056\231\180\214\147\210\246\222\024\227\214\218\214\218\255\127\255\127\255\127alalal\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\024\227\247\222\246\218\214\218\023\223\089\235\023\227\048\190\146\202\056\227\056\231\024\227\214\218al\214Zal\214\218\214\218\023\227\023\227\147\206\081\198\023\227\023\227\181\214\247\222\246\222\213\218\247\222\246\218\089\235\121\239\179\214\238\189\205\181\081\202\023\227\056\231\023\227\214\218\214\218alalalalalal\255\127\255\127\0\0\255\127alal\255\127alal\148R\181\214\214\218\214\218\247\222\023\227\023\227\180\214\180\214\089\235\089\235\147\210\147\210\023\227\023\227\023\227\214\218\214\218\255\127\255\127\255\127al\255\127\181V\255\127\255\127\214\218\214\218\214\218\214\218\023\227\056\231\246\222\047\198\238\193\238\189\180\214\088\235\179\214\045\202\078\206\079\218\047\210\046\206\112\218\081\202\047\194\046\202\109\214\078\202\079\202\046\202\046\202\078\202\046\198\080\198\023\227\212\218\014\194\246\222\089\235\056\231\023\227\214\218\247\222\247\222\023\227\023\227\022\227\115\206\015\194\043\194\211\218\089\239\121\239\056\231\246\222\114\206\147\210\023\227\023\227\024\227\214\218\255\127al\214\218\214\218\214\218al\214\218\214\218\214\218\181\214\213\214\214\218\214\218\214\218\247\222\023\227\247\222\247\222\024\227\023\227\114\206\180\214\154\243\088\231\080\194\146\202\056\231\056\231\023\227\213\218alalal\214\218\247\222\023\227\056\231\147\206\081\198\055\231\056\231\213\214\023\227\023\227\246\222\056\231\213\218\089\235\121\239\114\206\238\189\238\189\081\202\023\227\089\235\056\231\023\227\214\218\214\218alal\247\222\214\218\181\214\181\214alalal\255\127\016Bal\214\218\246\222\213\218\213\218\247\222\023\227\023\227\056\231\056\231\180\214\180\214\089\235\089\235\113\206\014\194\180\214\056\231\056\231\023\227\214\218\214\218\255\127\255\127\255\127\255\127\255\127\016B\214\218\214\218\247\222\214\218\214\218\024\227\089\235\213\222\047\202\014\194\014\194\048\202\114\206\080\202\078\206\078\210\111\222\079\218\079\210\078\214\014\190\047\198\078\206\109\218\111\206\111\202\079\202\078\206\078\206\078\202\047\194\081\202\080\202\046\198\246\222\154\243\056\231\213\218\213\218\247\222\056\231\056\231\246\222\113\206\206\185\237\185\075\198\244\218\154\243\155\243\023\227\081\202\014\190\114\206\056\231\056\231\024\227\214\218\016Bal\214\218\247\222\214\218al\214\218\024\227\214\218\181\214\213\218\247\222\247\222\214\218\181\214\181\214\246\222\023\227\024\227\023\227\080\198\180\214\154\243\023\227\048\186\146\202\056\231\057\231\247\222\213\218\214\218\246\222\214\218\214\218\247\222\023\227\056\231\179\206\048\194\056\231\056\227\147\206\023\227\056\231\022\227\023\227\147\210\114\202\146\206\047\198\238\189\238\189\048\194\212\218\088\235\056\231\246\222\247\222\214\218\214\218\214\218\214\218\181\214\181\214\214\218\214\218al\181V\255\127al\181\214\214\218\247\222\023\227\023\227\056\231\056\231\056\231\121\239\089\235\146\210\048\198\114\206\114\206\047\198\238\189\179\210\122\239\056\231\023\227\024\227\214\218\213\218al\255\127\0\0\214Z\214\218\214\218\247\222\247\222\246\218\213\218\056\231\121\239\213\222\047\202\046\198\046\198\014\194\238\189\046\198\079\210\111\214\143\230\111\222\111\214\110\222\047\198\080\202\110\210\141\222\143\210\143\206\111\206\110\210\110\210\110\206\079\198\015\194\014\194\013\194\212\218\154\243\023\227\081\202\213\218\088\235\089\235\121\239\245\222\014\194\206\185\013\190\075\198\021\227\055\231\121\239\055\231\014\194\237\189\113\206\056\231\056\231\023\227\246\222\181\214al\214\218\089\235\246\222\114\202\213\218\024\227\246\222\181\214\213\214\247\222\247\222\246\222\213\218\213\218\247\222\056\231\023\227\147\210\015\194\081\202\147\210\082\202\047\182\146\198\055\227\089\235\023\227\246\222\214\218\214\218\214\218\246\222\246\222\023\227\056\231\180\210\047\186\022\223\055\227\081\194\055\231\122\239\212\218\113\202\048\194\239\185\206\185\014\194\014\194\239\189\015\190\080\198\114\206\213\218\023\227\023\227\247\222\247\222\247\222\247\222\213\218\181\214\023\227\214\218\214\218alal\214\218\214\218\023\227\023\227\246\222\023\227\089\235\122\239\023\227\180\214\146\210\047\198\015\194\239\189\238\189\014\194\014\194\080\198\147\210\213\218\056\231\023\227\023\227\214\218\181\214al\181V\214\218\214\218\247\222\247\222\023\227\213\218\212\214\089\235\154\243\212\222\046\202\046\198\046\198\014\198\014\194\078\202\111\210\143\218\176\234\144\226\143\222\143\230\080\202\144\206\175\218\205\222\175\214\176\210\143\214\174\218\142\214\143\210\111\202\047\198\046\198\045\198\081\202\180\214\113\202\015\194\246\222\154\243\089\235\088\235\212\218\014\194\206\185\013\190\107\202\145\210\048\198\022\227\022\227\014\190\013\190\047\198\246\222\056\231\024\227\247\222\181\214\180\214\246\222\057\231\247\222\148\210\213\218\024\227\023\227\181\214\180\210\247\222\024\227\247\222\181\214\214\218\024\227\089\235\246\222\048\198\014\190\014\190\206\185\206\185\047\182\146\198\056\231\154\243\056\231\213\218\214\218\247\222\247\222\214\218\247\222\247\222\056\231\213\214\047\186\213\218\023\223\048\194\056\231\154\243\114\206\238\189\016\190\239\185\238\189\014\194\014\194\015\190\047\194\015\194\238\185\147\210\089\235\056\231\247\222\246\222\247\222\246\222\213\218\213\218\246\222\247\222\214\218al\214\218\214\218\247\222\023\227\056\231\246\222\146\206\179\210\180\214\114\206\015\194\014\190\046\194\048\198\016\198\015\194\046\194\046\194\014\190\238\185\048\198\180\214\023\227\024\227\023\227\214\218al\255\127\247\222\246\222\023\227\056\231\089\235\212\214\146\206\121\239\121\239\114\210\014\206\046\202\046\202\046\202\047\194\111\206\143\218\144\222\208\238\208\230\175\226\175\234\177\206\209\210\207\222\238\226\208\218\208\218\207\222\238\226\206\222\175\214\144\206\112\202\078\202\078\206\046\198\015\190\014\190\014\194\180\214\121\239\022\223\114\206\081\206\014\198\238\189\045\190\107\202\045\194\173\181\113\206\113\206\014\194\013\194\046\194\212\218\089\235\057\231\023\227\213\214\213\218\247\222\024\227\247\222\213\214\213\214\024\227\056\231\180\214\113\202\023\223\056\231\023\227\147\210\213\218\056\231\089\235\245\222\047\194\014\190\014\190\206\185\206\185\047\182\145\194\055\227\187\247\023\227\114\206\213\218\023\227\247\222\246\222\246\222\246\218\056\231\246\214\047\186\113\202\147\206\047\186\213\218\089\235\048\202\014\190\048\190\015\186\238\189\046\198\014\194\015\190\047\194\047\194\014\190\147\210\089\235\089\235\023\227\023\227\023\227\023\227\213\218\213\214\246\222\023\227\214\218\214\218\214\218\247\222\023\227\056\231\023\227\114\206\014\190\014\190\015\194\015\194\015\194\047\194\079\198\080\202\017\198\015\194\046\198\046\198\014\194\238\189\238\189\081\202\022\227\056\231\023\227\247\222\214\218al\214\218\246\222\023\227\056\231\055\227\147\210\047\198\180\214\179\210\047\202\046\206\046\206\078\206\078\210\079\202\111\214\176\222\176\226\241\242\241\238\240\234\240\242\243\214\018\219\016\227\015\231\018\223\018\223\015\227\045\235\013\235\240\222\178\210\145\202\143\210\142\214\111\202\047\190\047\190\045\198\080\202\180\210\114\206\013\190\014\194\013\198\238\189\045\194\139\206\045\194\206\185\013\190\014\190\013\194\045\194\046\198\245\218\154\243\122\239\023\227\180\214\213\218\023\227\024\227\023\227\213\218\180\214\056\231\056\231\147\210\080\198\056\231\122\239\056\231\147\210\179\214\089\235\121\239\179\214\047\194\014\190\014\194\206\189\206\185\080\186\113\190\146\206\246\222\179\210\048\198\246\222\056\231\023\227\247\222\214\218\213\218\088\231\022\219\080\186\014\190\015\190\048\186\081\198\179\210\014\198\014\194\048\190\015\190\014\190\047\198\047\194\015\190\048\194\047\194\014\194\081\202\180\214\246\222\056\231\056\231\089\235\023\227\180\214\179\210\023\223\024\227\247\222\246\222\247\222\023\227\056\231\056\231\180\214\014\190\014\194\014\194\015\194\048\198\048\198\079\198\111\202\113\206\050\202\048\198\079\198\047\198\015\194\014\190\014\190\048\198\180\214\023\227\056\231\023\227\214\218\214\218\181\214\214\218\181\214\114\206\081\202\080\198\014\194\014\190\014\194\014\202\046\210\046\206\079\210\111\214\111\206\144\214\208\230\209\234\017\247\018\247\016\243\016\247\017\231\017\231\014\239\046\239\048\231\048\235\046\239\076\243\044\243\015\231\241\218\209\214\208\218\206\222\174\214\111\206\110\206\109\210\078\206\046\198\046\198\045\202\045\198\045\198\014\194\044\198\139\206\077\198\237\189\012\194\013\194\046\194\045\194\078\198\212\214\121\239\187\247\088\235\114\206\147\210\023\227\056\231\024\227\212\214\180\214\089\235\088\235\114\202\047\194\055\231\154\243\088\235\146\210\179\210\122\239\121\239\113\202\014\190\046\194\014\194\238\189\238\185\112\186\144\186\015\190\238\189\238\189\080\198\246\222\056\231\024\227\023\227\246\222\213\214\088\235\022\219\080\186\014\190\047\190\081\190\015\190\015\194\014\198\047\194\081\194\016\190\014\194\079\198\047\198\048\190\080\194\047\194\047\194\046\194\238\189\048\198\246\222\121\239\154\243\056\231\114\206\147\210\023\227\056\231\056\231\024\227\024\227\089\235\089\235\245\222\080\198\014\190\014\194\014\194\047\198\081\202\080\202\112\202\144\206\147\214\115\210\081\202\111\202\079\202\047\194\014\194\014\194\014\190\080\198\023\227\089\235\023\227\246\222\214\218\214\218\246\222\147\210\048\198\015\194\238\189\014\194\014\198\014\198\046\202\046\214\078\214\079\218\111\226\144\222\176\234\208\246\241\250\241\254\241\254\017\255\206\254\171\250\137\254\136\254\168\254\201\254\009\255\041\255\072\255\072\251\042\247\043\243\044\235\013\231\237\230\204\226\204\222\172\222\140\218\140\218\108\214\108\210\076\210\076\206\076\206\044\202\108\202\170\210\075\202\236\193\012\198\013\194\046\194\078\198\078\198\080\202\180\214\023\227\245\222\047\194\114\206\056\231\089\235\056\231\213\214\180\214\154\243\121\239\113\202\046\190\246\222\187\247\088\235\080\202\179\210\154\243\088\231\080\198\014\194\046\194\046\194\238\189\238\185\112\186\144\186\047\190\238\189\014\190\047\198\245\218\089\235\057\231\056\231\023\227\180\214\088\235\055\223\080\186\046\190\047\190\113\190\047\190\047\194\046\198\047\198\114\194\048\190\014\194\111\202\079\202\080\194\081\194\080\194\047\194\046\194\014\194\238\189\081\202\245\222\023\227\212\218\047\194\113\202\088\235\154\243\121\239\089\235\089\235\023\227\245\218\114\206\014\194\014\194\046\194\046\198\080\202\114\206\145\210\176\210\176\214\083\210\084\210\114\206\112\206\111\202\047\194\015\194\014\194\014\194\047\198\180\214\245\218\246\222\023\227\246\222\247\222\247\226\023\227\023\227\147\210\015\198\014\198\014\202\014\202\046\210\078\214\078\218\111\226\111\230\143\238\176\242\240\250\017\251\175\254\109\254\174\254\074\254\164\253\032\237\032\229\064\225\160\229\225\229\067\238\164\250\004\255\068\255\066\255\035\251\038\243\010\235\235\230\203\226\202\222\137\218\106\214\107\214\108\210\075\210\075\210\044\206\044\202\108\206\170\210\076\202\237\193\013\194\013\194\078\198\110\198\078\198\014\194\238\189\238\189\014\194\014\194\114\206\056\231\121\239\089\235\212\214\113\202\246\222\245\222\080\198\046\194\179\210\023\227\245\222\046\194\080\202\245\222\180\214\047\198\046\194\046\194\046\194\014\194\238\189\112\186\177\186\047\190\014\194\014\194\046\194\179\210\089\235\122\239\089\235\246\222\179\210\088\235\023\223\113\186\047\194\080\194\146\190\080\194\079\198\079\202\080\198\147\194\081\194\047\198\112\202\111\202\080\198\113\194\080\198\079\198\047\198\014\194\014\190\014\190\015\190\015\190\014\194\014\190\047\194\213\218\055\227\246\222\246\222\245\222\113\202\014\194\015\194\015\194\047\194\046\198\078\198\080\206\114\210\177\214\179\214\083\206\051\189\213\201\116\210\112\206\111\202\079\198\047\194\046\194\014\194\014\194\014\194\081\202\213\218\213\218\213\218\247\222\023\227\089\235\122\239\023\227\081\206\014\194\014\194\014\198\046\202\046\206\046\210\111\222\111\226\143\226\176\226\241\226\017\235\076\250\167\253\232\253\035\253\096\224\0\180\0\148\0\148\0\152\0\156\064\180\0\217\0\238\193\250\034\255\065\255\032\251\230\234\202\222\171\218\169\218\137\214\106\210\075\210\075\210\075\206\043\206\044\202\077\198\140\206\202\210\076\202\206\185\238\189\014\194\078\198\142\202\110\202\014\194\238\189\238\189\014\194\014\194\080\202\023\227\154\243\121\239\180\214\014\190\015\194\015\194\046\194\078\194\015\194\015\194\015\194\046\194\014\194\015\194\015\194\046\194\046\194\078\194\079\198\014\194\014\194\144\190\209\186\112\194\015\198\047\198\046\194\113\206\088\235\187\247\154\243\212\214\080\198\213\218\213\210\145\190\079\194\080\194\179\190\081\194\112\198\111\206\145\202\179\198\113\198\079\202\144\206\144\206\145\198\145\198\112\198\080\198\079\198\046\194\015\194\015\190\014\190\014\190\014\190\046\194\014\190\015\194\015\190\015\190\015\194\015\194\014\190\014\190\015\194\015\194\047\198\047\198\079\202\082\206\147\214\179\218\087\218\087\193\018\168\182\201\086\214\081\206\110\202\111\202\047\198\046\194\014\194\014\190\048\198\213\218\246\222\181\214\181\214\246\222\023\227\089\235\155\243\154\243\180\214\014\194\014\190\014\190\046\198\046\202\079\206\079\218\111\218\144\218\209\214\018\215\238\230\231\249\226\252\226\248\096\224\194\188\003\181\035\177\035\173\034\177\067\181\067\181\066\181\033\193\192\225\193\250\065\255\032\251\130\226\103\206\137\214\105\210\074\206\075\202\075\206\075\206\076\202\013\198\013\198\109\202\171\206\202\210\077\198\207\185\238\189\046\194\110\202\142\202\142\202\046\194\238\189\014\190\014\194\046\198\079\198\022\227\155\243\154\243\179\210\014\190\238\189\238\189\046\194\078\194\014\190\238\189\238\189\047\194\014\194\238\189\014\190\046\194\078\198\078\198\111\198\047\198\047\194\209\190\018\187\145\194\047\198\047\198\047\198\080\202\246\222\088\231\023\227\114\206\014\190\015\194\081\194\146\194\080\194\113\194\211\194\145\198\145\202\144\210\210\206\245\202\179\202\144\206\177\210\209\210\211\202\179\198\145\202\112\202\112\202\079\198\047\194\047\194\047\194\046\194\046\194\046\194\046\194\238\189\206\185\206\185\206\185\238\189\014\190\014\194\015\194\047\198\048\198\049\202\082\206\148\214\181\218\151\222\026\214\023\193\017\160\182\201\086\218\048\206\109\202\078\198\046\198\046\194\014\194\014\190\048\198\022\227\056\231\247\222\214\218\246\222\246\222\023\227\056\231\088\235\180\214\014\194\014\190\014\190\046\198\078\202\079\206\079\214\111\218\144\218\209\214\017\219\205\230\133\249\032\252\064\228\097\164\035\177\132\197\132\197\132\189\163\193\195\205\229\201\196\189\163\185\162\197\065\230\0\255\224\250\224\209\164\185\072\202\040\202\010\194\011\194\043\198\043\202\045\198\014\194\046\194\140\206\203\210\203\214\077\198\207\185\238\189\046\194\142\202\174\206\174\202\079\198\014\190\014\190\047\194\046\198\079\198\022\227\187\247\154\243\179\210\046\190\014\190\238\193\046\194\110\194\046\194\014\190\014\194\047\198\046\194\014\194\014\194\078\198\078\198\079\198\111\202\047\198\079\198\242\194\051\191\178\202\080\206\080\202\079\202\079\198\080\198\081\198\048\198\047\194\047\194\238\189\081\194\178\194\112\198\146\198\244\194\211\202\210\206\208\214\243\214\054\211\243\218\207\222\241\222\019\219\020\211\243\206\177\210\176\206\144\206\111\206\079\198\079\194\079\198\046\194\046\194\046\194\046\194\014\190\238\189\238\189\238\189\014\190\014\194\014\194\015\194\047\198\079\202\081\206\114\210\210\218\212\222\152\222\026\214\023\189\017\156\148\197\052\210\046\198\076\198\044\194\013\194\013\190\014\190\237\185\014\194\246\222\089\235\023\227\246\222\213\218\114\206\080\202\081\202\113\202\080\202\046\198\046\194\046\198\078\198\078\202\079\206\079\210\111\214\143\214\209\218\017\219\238\222\166\241\0\252\032\212\097\128\003\173\100\185\100\185\067\177\099\177\131\193\164\193\164\185\195\185\163\181\194\201\192\246\192\242\064\185\226\156\198\185\231\189\201\185\203\185\012\194\045\198\046\198\047\194\078\198\172\210\235\214\203\214\077\202\239\189\014\190\078\194\174\206\206\206\206\206\111\202\047\194\046\194\079\198\079\198\079\198\245\218\089\235\023\227\145\206\046\190\014\194\014\194\078\194\111\194\047\194\015\194\047\194\079\198\047\198\014\194\047\194\079\198\079\202\111\202\112\202\079\206\111\206\018\199\084\191\242\202\112\210\112\206\112\202\080\198\047\194\014\194\014\194\047\194\047\194\046\194\113\194\179\198\145\202\211\202\022\199\020\207\020\215\017\223\053\215\120\211\053\215\017\223\052\219\054\211\055\207\053\211\018\215\242\206\177\206\143\210\144\202\112\198\111\198\078\198\078\198\078\194\046\194\046\194\014\194\014\190\014\190\014\194\014\194\014\194\046\198\079\202\111\202\112\206\177\214\017\223\018\227\182\222\250\213\022\185\015\152\144\189\016\202\236\193\011\190\011\190\236\189\013\190\237\189\238\189\081\202\023\227\056\231\247\222\214\218\246\222\081\202\238\189\238\189\238\189\014\194\014\194\046\198\078\198\046\198\078\198\079\202\111\210\111\210\143\214\208\218\017\219\239\214\167\237\0\252\032\216\096\128\227\160\035\169\035\169\227\160\002\165\066\181\099\181\100\173\132\177\131\177\163\181\161\238\096\234\192\164\065\128\068\169\166\181\136\177\170\177\236\185\045\194\078\202\079\202\110\202\203\214\010\219\235\218\110\202\016\194\015\194\110\198\207\206\239\210\239\210\175\206\111\202\110\198\111\202\079\202\079\198\113\202\114\202\080\202\079\198\078\194\046\194\014\194\079\198\143\198\111\198\047\198\079\198\111\202\079\202\079\198\079\198\079\202\079\202\112\202\144\206\111\210\144\214\052\199\149\171\050\171\175\194\144\206\144\206\112\198\079\198\047\194\046\194\047\194\079\194\078\198\178\198\212\198\178\206\244\206\055\203\087\207\088\211\087\211\156\195\126\179\028\175\219\174\187\174\155\170\186\174\024\191\055\199\023\199\244\202\210\202\178\198\145\198\112\198\111\198\111\198\079\198\079\194\046\198\046\194\046\194\046\194\046\194\046\194\046\198\078\198\111\202\111\206\176\210\208\218\017\223\242\222\117\214\153\205\214\180\013\148\076\177\173\189\138\181\202\181\235\185\204\185\237\189\205\185\081\202\055\227\056\231\023\227\247\222\214\218\056\231\114\206\238\189\206\185\238\189\238\189\238\189\014\194\046\198\014\194\014\194\047\198\079\206\111\206\144\214\209\214\017\219\173\222\100\241\032\252\096\228\096\160\226\160\035\169\003\165\227\160\003\165\068\177\132\185\133\181\165\181\164\181\228\193\193\238\064\222\0\136\097\132\003\161\101\169\071\169\136\173\235\185\077\198\111\206\143\206\174\206\011\219\042\223\010\219\142\210\048\198\047\198\143\202\239\210\015\215\015\215\207\210\175\206\175\206\144\206\112\206\111\202\047\194\238\189\014\194\078\198\078\194\046\194\046\198\111\198\175\202\143\202\079\202\112\206\144\206\144\206\111\202\111\202\111\206\111\206\144\206\176\210\209\210\242\210\085\191\148\155\047\131\206\174\143\206\144\206\112\198\079\198\079\198\046\198\079\198\112\198\111\202\178\202\245\202\243\206\021\207\120\207\122\203\189\187\126\171\062\151\157\130\252\129\155\129\123\129\122\129\154\129\218\145\057\158\183\178\245\194\211\198\178\198\145\198\112\198\112\198\079\198\079\198\079\198\079\198\047\198\046\194\046\194\047\194\079\198\079\202\111\202\111\206\144\206\208\214\209\214\050\202\178\185\116\185\022\185\147\168\010\144\102\148\134\152\134\152\072\169\202\181\172\181\204\185\204\181\114\206\121\239\122\239\023\227\247\222\214\218\089\235\114\206\206\185\206\185\206\189\238\189\238\189\014\190\046\194\014\194\014\194\015\194\079\202\111\206\144\210\209\214\017\219\172\226\100\245\129\252\161\248\096\216\226\168\035\169\035\165\003\165\069\169\134\181\197\189\006\194\006\190\005\198\100\214\034\247\032\214\0\128\161\148\068\165\037\165\038\165\104\173\010\186\109\202\175\210\176\210\206\214\043\223\074\227\042\223\206\214\112\202\079\202\175\206\015\215\048\219\048\219\240\214\239\210\239\210\176\210\144\206\143\202\111\202\047\194\047\198\111\198\111\202\079\198\079\198\143\202\208\206\176\206\144\206\176\210\176\210\176\210\144\206\144\206\144\210\144\206\176\210\208\214\241\210\051\215\117\195\114\151\013\131\206\170\142\202\110\206\111\198\079\194\112\198\112\198\145\198\178\202\177\202\211\202\022\203\054\211\120\207\188\195\190\175\159\147\188\130\114\129\049\133\146\145\113\149\048\141\176\132\116\128\119\128\183\128\148\149\081\182\175\202\176\202\143\202\111\202\111\198\079\198\079\198\079\198\079\198\047\198\047\198\015\194\047\198\079\202\111\202\111\206\144\206\144\206\241\218\177\210\049\173\016\140\049\152\114\160\046\152\006\136\0\128\0\128\0\128\229\156\137\177\139\177\172\181\204\181\048\198\056\231\121\239\023\227\247\222\214\218\024\227\114\206\238\189\238\189\238\189\238\189\014\190\014\194\046\194\014\194\015\194\047\198\079\202\111\206\144\210\209\214\017\219\205\226\166\245\162\252\227\252\160\236\003\173\067\165\068\165\068\161\134\181\007\202\073\202\105\202\105\202\136\214\039\239\100\255\032\210\0\128\226\152\069\165\005\161\005\161\103\169\009\190\141\206\239\218\240\218\014\223\106\231\106\235\075\231\239\218\145\206\144\206\207\210\047\219\080\223\080\223\048\219\048\219\016\219\209\218\177\214\176\210\143\206\079\202\079\198\111\202\143\202\111\202\112\202\176\206\240\206\209\210\177\214\209\218\209\218\209\218\177\214\177\214\176\214\176\210\208\214\209\214\241\218\018\227\083\203\080\131\235\130\140\174\109\198\109\202\078\194\111\194\144\198\145\202\210\206\243\206\244\206\021\207\054\207\088\211\155\199\223\171\159\135\089\130\244\145\115\158\147\158\146\166\113\166\080\158\238\157\110\149\209\132\117\128\052\128\046\149\076\190\141\202\110\202\110\202\111\202\111\202\111\206\111\206\080\202\079\202\079\198\047\194\079\202\111\202\143\206\175\210\176\214\208\214\017\223\177\210\142\156\011\128\011\128\010\140\007\136\002\132\0\128\0\128\0\128\196\152\072\173\073\173\106\177\171\177\238\189\114\202\147\210\023\227\247\222\214\218\246\222\180\214\180\214\180\214\114\206\080\198\014\194\014\194\014\194\047\194\047\198\079\198\079\202\111\206\144\210\209\214\017\219\172\230\133\245\195\252\036\253\226\236\035\181\099\169\100\165\134\161\007\194\169\222\204\218\237\218\014\227\077\239\137\255\067\255\192\205\001\128\067\169\068\169\228\156\229\156\103\169\010\190\205\214\047\227\048\227\078\231\138\239\170\239\107\235\015\223\209\214\177\214\016\219\112\227\112\227\113\227\113\227\112\227\081\227\242\222\211\222\241\218\240\214\144\206\112\206\176\206\208\206\176\206\144\210\240\210\017\215\242\222\242\222\242\226\018\227\018\227\242\222\242\222\242\222\209\218\241\218\241\218\241\222\017\235\049\203\046\131\169\130\074\170\076\194\076\198\076\194\110\198\111\202\143\210\209\214\243\210\020\211\020\211\054\215\121\207\222\179\159\139\218\130\051\150\214\166\089\175\023\167\179\166\113\166\113\162\079\166\011\166\106\153\209\132\084\128\016\128\138\165\107\198\108\198\077\198\110\202\143\206\175\210\176\210\144\210\144\210\111\206\111\202\111\206\144\206\176\210\208\218\240\218\241\218\049\223\241\218\080\202\237\189\234\164\006\132\001\128\001\132\131\144\164\148\131\148\197\156\006\165\040\165\073\169\139\173\139\177\139\173\239\189\023\227\023\227\214\218\214\218\023\227\056\231\121\239\055\231\146\210\014\190\238\189\014\194\014\194\047\194\047\198\079\202\111\202\144\210\209\214\017\219\206\226\166\245\162\252\036\253\226\248\225\228\002\221\034\229\164\225\103\238\009\247\044\243\077\247\141\251\171\255\134\255\192\242\162\197\132\177\196\185\100\173\004\161\037\165\135\173\106\198\078\231\176\243\144\239\141\239\200\243\230\239\199\231\138\223\016\219\210\214\048\223\144\231\145\231\145\231\176\227\174\223\141\215\077\207\045\207\078\215\079\219\016\219\208\214\240\210\240\206\240\210\240\214\018\219\082\219\082\215\050\207\081\203\081\203\048\199\015\195\015\195\240\210\018\223\242\222\018\219\018\227\018\231\048\199\044\131\201\130\106\166\042\186\042\190\042\194\076\198\209\190\053\187\053\187\021\195\019\211\018\223\051\223\154\195\255\143\060\131\241\145\023\171\056\171\179\166\046\158\237\157\203\153\171\153\171\157\200\165\199\165\076\145\113\128\016\128\202\144\233\181\074\194\075\198\109\202\081\198\018\186\017\186\112\206\144\206\144\206\144\210\176\210\176\210\145\210\083\202\050\198\145\206\242\222\018\223\082\227\240\222\140\181\005\128\001\128\001\132\197\156\006\161\228\156\229\156\229\156\231\156\040\165\074\169\139\177\140\177\015\194\023\227\056\231\246\222\246\222\247\222\024\227\089\235\121\239\180\214\238\189\238\189\238\189\014\194\014\194\047\198\079\198\111\202\144\210\209\214\017\219\016\219\200\237\064\252\194\252\128\244\064\220\064\212\128\220\032\233\195\249\069\254\166\254\199\254\006\255\035\255\224\250\0\222\163\189\005\198\196\193\131\181\067\173\100\173\198\181\170\210\173\243\239\255\205\247\201\243\227\239\128\215\096\199\160\211\076\223\241\218\080\223\144\231\176\231\206\227\203\215\168\199\165\183\131\171\099\167\070\179\074\195\077\215\047\215\015\211\016\211\017\215\049\219\081\211\079\191\078\179\044\163\043\147\043\143\043\135\010\131\232\130\170\162\206\194\240\214\241\218\017\223\017\231\048\199\078\131\013\131\139\162\009\182\200\185\009\186\175\182\119\155\184\131\087\131\021\183\018\215\016\223\051\215\156\175\158\131\086\130\014\158\055\175\212\162\236\157\104\153\105\149\073\149\105\149\105\153\103\165\167\165\168\161\238\140\049\128\043\128\039\153\008\186\073\198\109\198\243\177\245\144\145\132\048\194\081\194\112\202\175\210\176\210\208\214\115\202\053\169\018\140\208\181\210\214\209\218\017\223\207\214\107\177\005\132\001\128\001\132\195\152\004\161\228\152\196\148\197\152\198\152\007\161\073\169\106\173\140\177\239\189\023\227\056\231\246\222\214\218\214\218\247\222\056\231\121\239\213\218\238\189\238\189\238\189\238\193\014\194\015\198\047\198\111\202\144\210\209\214\017\219\206\218\134\237\0\252\096\244\032\204\0\148\0\140\0\144\0\164\032\192\096\208\192\216\0\217\064\213\160\217\128\213\032\193\033\177\131\181\132\181\132\177\132\177\132\181\007\194\234\218\203\247\234\255\231\247\162\231\032\211\097\182\032\158\034\203\105\227\045\223\110\223\174\231\237\231\202\219\166\203\132\187\101\183\101\175\067\163\032\139\001\151\008\187\237\210\207\214\208\214\017\219\048\211\043\179\007\139\198\130\197\130\198\142\199\146\233\150\009\147\199\138\098\130\070\142\173\198\206\214\239\218\240\226\016\199\114\135\081\147\172\166\200\177\166\177\140\166\116\147\117\131\210\130\208\166\241\202\208\214\206\218\053\199\190\151\218\130\175\141\212\162\211\162\047\154\137\153\039\149\040\149\040\149\106\149\138\157\104\169\168\169\232\169\077\153\049\128\013\128\199\148\199\177\039\190\043\190\178\169\148\136\014\128\014\186\048\190\110\202\175\210\143\210\208\214\083\198\212\156\015\128\110\173\112\198\144\206\207\214\174\210\075\173\007\132\003\128\001\132\195\148\004\157\195\148\163\148\164\148\198\152\231\160\073\165\106\173\140\177\048\198\023\227\056\231\246\222\214\218\214\218\246\222\024\227\089\235\212\218\238\189\238\189\238\189\238\193\014\194\015\198\047\198\111\202\144\210\209\214\017\219\172\218\067\237\0\252\064\224\032\128\097\128\129\140\129\140\129\128\130\128\194\144\195\156\227\156\194\156\097\148\0\140\128\160\224\168\0\169\066\169\132\173\164\173\005\186\135\206\040\227\199\247\228\251\160\235\128\190\004\186\102\198\037\186\166\202\040\219\042\215\139\223\236\231\202\223\167\211\103\203\038\195\007\195\007\191\230\178\003\159\224\130\098\146\106\194\142\214\175\214\240\218\236\186\195\130\163\134\134\154\169\174\170\178\169\174\137\174\169\166\168\146\068\130\128\129\041\182\140\206\173\210\174\218\015\195\148\147\116\155\141\170\134\177\042\166\048\135\017\131\043\130\232\145\140\194\175\210\174\206\172\214\053\187\190\131\183\130\172\145\021\167\112\158\204\153\072\149\006\149\040\149\073\149\139\149\172\161\169\177\201\181\008\182\140\165\144\128\014\128\200\144\134\173\230\181\010\186\112\165\113\132\011\128\236\181\046\190\077\198\110\206\142\206\207\214\050\194\146\148\012\128\076\169\014\190\078\198\206\210\141\206\108\177\010\140\005\128\001\132\195\152\004\157\195\148\163\148\164\148\198\152\007\161\041\165\106\169\173\181\180\214\056\231\023\227\246\222\181\214\214\218\247\222\023\227\056\231\179\214\206\185\238\189\014\194\014\194\014\194\014\194\079\198\111\202\144\206\209\214\017\219\172\218\067\241\0\252\032\208\064\128\226\160\003\161\035\169\035\169\068\169\165\185\229\193\005\198\037\198\164\181\226\152\192\164\160\201\192\205\096\181\099\169\165\177\070\194\199\210\072\231\197\247\192\247\160\202\227\181\198\210\231\214\167\202\135\198\135\194\231\206\168\223\201\223\168\215\072\215\009\211\200\202\136\194\136\194\072\190\101\170\097\142\160\129\198\169\107\202\141\210\204\202\200\166\162\130\134\150\171\190\172\202\139\194\073\186\041\186\073\182\103\154\228\129\192\128\167\173\074\190\107\198\107\210\238\190\148\147\116\159\141\170\041\166\238\142\205\130\168\133\102\149\106\158\140\186\108\198\108\198\106\206\021\183\191\131\184\130\139\141\178\158\045\154\138\149\039\149\007\149\073\149\106\149\173\149\238\165\236\185\010\194\041\198\204\177\209\128\015\128\168\144\133\169\198\177\201\177\046\157\046\128\008\128\203\177\012\186\043\190\077\198\109\206\206\214\016\190\015\136\009\128\042\165\237\185\013\190\140\206\140\206\108\181\013\148\008\132\001\132\195\152\004\157\195\148\164\148\197\152\230\156\008\165\074\169\107\173\206\185\246\222\089\235\023\227\214\218\181\214\213\218\246\222\246\222\246\222\147\210\048\198\047\198\014\194\014\194\047\198\047\198\079\202\111\206\144\210\209\214\017\219\172\218\067\241\0\248\032\204\064\128\194\156\003\161\003\161\002\161\002\161\068\173\100\177\132\181\164\185\164\177\099\169\097\185\128\234\192\242\192\201\034\169\133\173\006\186\168\206\072\231\196\247\128\235\128\169\068\198\230\214\101\194\038\186\038\186\006\182\229\198\198\219\198\215\134\207\039\203\231\198\134\190\102\182\102\178\038\182\230\173\130\145\192\128\035\149\007\178\074\198\139\198\170\182\168\166\169\178\139\202\042\198\009\190\232\177\232\177\007\170\038\150\131\129\096\128\102\165\008\174\041\186\074\202\204\182\114\143\083\159\239\162\046\147\204\130\102\129\037\149\009\170\041\174\041\178\010\186\042\190\040\202\245\178\191\131\217\130\139\141\144\158\236\153\137\149\039\149\039\149\106\149\139\157\205\169\047\186\078\198\109\206\172\210\014\186\242\132\015\128\167\144\101\165\166\173\136\173\236\148\011\128\038\132\137\173\202\177\234\185\043\194\108\202\173\210\239\185\013\128\007\128\041\161\171\177\203\181\075\198\107\202\140\181\046\152\009\136\002\136\227\152\004\157\195\148\196\148\198\156\231\160\041\165\107\173\107\173\206\185\213\218\056\231\247\222\214\218al\181\214\213\218\213\218\246\222\246\222\246\222\246\222\212\218\113\206\047\198\047\198\079\202\111\206\144\210\209\214\017\219\139\226\066\245\0\248\032\204\064\128\194\156\003\161\226\156\194\152\194\156\003\165\035\165\067\169\100\177\131\177\098\173\129\185\224\234\064\255\0\210\225\160\100\169\230\185\135\202\039\227\163\243\032\219\065\161\036\190\133\202\229\181\197\177\229\177\005\182\036\199\196\215\196\207\131\191\226\170\033\158\225\153\066\154\098\154\034\154\194\149\001\137\064\128\193\136\165\169\008\190\074\194\139\198\139\198\106\194\106\190\040\186\007\178\007\166\039\158\102\150\069\138\098\129\0\128\069\157\199\169\232\173\009\190\171\174\079\135\112\143\079\143\236\130\166\129\131\132\135\157\232\169\167\177\199\177\233\177\233\185\007\194\244\174\191\131\217\130\172\141\110\154\235\153\137\149\071\153\039\157\139\153\204\165\236\193\078\206\143\206\176\210\207\218\080\190\019\137\014\128\166\144\102\165\134\173\135\169\202\144\010\128\037\132\104\169\169\173\200\177\234\185\075\198\140\206\205\181\012\128\006\128\008\157\138\173\169\177\041\190\074\198\108\181\078\152\009\136\002\136\228\156\037\161\228\152\197\152\230\156\008\161\074\169\107\173\205\185\049\198\213\218\024\227\247\222\214\218al\213\218\246\222\246\222\247\222\024\227\089\235\122\239\155\243\022\227\048\198\014\194\047\198\079\202\144\206\209\214\017\219\139\230\066\249\0\252\032\220\064\128\226\156\003\161\227\156\194\152\194\156\003\165\068\169\068\173\132\181\163\185\162\181\129\181\225\234\064\251\192\201\096\136\067\165\196\181\103\198\007\223\163\239\032\223\064\165\228\181\036\190\164\173\164\169\196\173\005\178\036\199\226\203\193\187\0\159\096\133\096\128\160\128\032\133\096\133\064\129\192\128\096\128\0\128\128\132\099\161\230\177\008\186\042\194\106\194\169\178\167\154\101\142\133\138\133\138\133\138\165\134\068\130\066\129\0\128\004\157\133\165\166\169\200\181\105\166\011\131\010\131\136\130\101\129\002\128\065\128\004\145\134\161\134\169\135\169\168\173\200\181\007\194\211\170\158\131\028\131\240\137\044\154\235\153\137\153\071\157\072\169\171\169\013\178\078\202\143\210\176\210\240\218\016\223\115\194\019\129\013\128\164\144\103\165\134\169\102\169\202\144\010\128\037\128\071\165\136\169\168\177\233\185\042\194\139\202\206\181\013\128\006\128\230\156\104\169\136\173\008\186\041\190\108\181\078\156\010\136\003\136\228\156\037\161\228\152\197\152\231\156\040\165\106\169\107\173\048\198\023\227\056\231\247\222\246\222\214\218al\214\218\214\218\214\218\247\222\023\227\056\231\122\239\122\239\213\218\015\194\014\194\047\198\079\198\112\206\209\214\017\219\172\230\100\245\064\252\096\228\096\164\227\160\036\161\003\157\194\152\003\157\036\169\100\177\165\185\229\193\004\194\195\185\226\193\002\239\001\243\032\177\0\128\034\161\164\177\038\190\198\214\163\243\128\235\160\173\164\173\004\186\132\169\132\169\165\169\230\177\036\191\224\191\096\175\0\154\161\140\097\140\129\136\161\136\225\140\193\136\128\136\096\136\064\132\193\140\099\157\165\173\167\181\073\182\234\170\008\151\165\134\099\130\067\130\067\130\068\130\068\134\003\134\002\129\0\128\003\153\068\161\133\165\167\177\104\162\168\130\197\129\194\132\163\140\098\132\0\128\098\132\036\153\134\165\102\165\167\169\200\181\008\194\176\174\124\131\127\131\150\138\234\153\234\157\169\157\136\169\169\177\235\189\077\198\143\206\176\210\209\214\241\222\049\227\085\190\178\128\007\128\196\144\104\165\134\169\102\165\202\144\012\128\039\128\038\161\135\169\167\173\232\181\042\194\139\202\238\185\046\140\007\128\006\157\135\169\135\173\231\181\008\186\108\177\111\156\012\140\005\136\228\156\037\161\228\156\229\156\007\161\040\165\106\173\107\173\049\198\056\231\089\235\247\222\214\218\214\218al\214\218\214\218\247\222\246\222\023\227\056\231\056\231\212\218\048\198\014\194\015\194\047\198\079\198\112\206\209\214\017\219\205\226\165\245\129\252\161\248\128\216\003\161\068\165\036\165\035\161\067\169\133\181\229\193\070\206\135\214\101\210\068\202\163\218\098\251\128\222\0\136\097\132\067\165\132\173\229\181\165\206\163\243\160\239\224\181\132\169\228\181\100\165\132\165\165\173\230\181\036\191\192\179\001\167\034\170\227\169\132\165\035\157\035\157\132\161\131\165\067\157\067\161\100\165\100\161\100\161\101\169\166\173\169\170\073\155\007\147\100\138\004\142\229\149\197\161\198\169\198\165\196\145\034\129\0\128\227\152\036\157\069\161\134\173\071\162\070\130\227\128\228\144\101\157\228\148\001\128\098\128\005\137\069\157\102\165\167\173\233\185\041\194\140\186\056\155\159\131\027\131\014\146\200\157\201\161\168\173\201\181\012\194\110\202\176\210\209\214\241\218\049\227\051\219\245\173\015\128\032\132\005\153\103\165\101\165\101\165\203\144\046\128\074\128\037\161\135\169\167\173\232\181\042\194\138\202\239\189\111\144\007\128\006\157\135\173\135\173\199\177\232\185\107\177\112\156\014\144\007\140\228\156\037\161\005\157\006\157\007\161\073\169\107\173\139\177\048\198\056\231\089\235\247\222\214\218\214\218\247^al\214\218\247\222\214\218\246\222\023\227\212\218\048\198\238\193\014\194\047\194\047\198\079\202\112\206\209\214\017\219\206\222\166\241\128\252\194\252\161\232\035\161\069\161\100\165\131\173\197\181\007\194\103\210\201\226\009\231\230\230\228\226\068\247\066\255\192\201\0\128\161\148\099\165\100\169\164\177\133\202\130\239\128\235\192\177\100\165\196\177\100\165\133\169\166\173\007\190\005\191\032\171\128\158\002\166\003\174\165\169\068\161\068\161\164\169\196\169\100\165\099\161\132\161\132\165\100\165\101\169\230\165\231\154\007\147\134\158\007\174\230\165\198\169\167\173\199\177\199\173\196\145\001\129\0\128\227\148\036\157\036\161\134\173\006\158\164\129\130\128\037\149\134\165\036\157\065\132\196\128\103\129\102\149\101\165\167\173\009\186\074\194\107\202\178\174\027\131\062\131\184\138\200\153\199\165\201\173\234\185\044\194\110\202\208\214\241\218\017\227\082\231\150\198\018\129\006\128\194\148\168\173\135\169\101\169\102\165\203\144\047\128\076\132\070\165\134\173\167\173\200\181\042\194\138\202\239\185\015\136\004\128\229\156\103\169\103\169\199\177\199\181\074\173\078\152\014\148\008\144\228\156\069\165\037\161\006\161\039\165\073\169\139\177\172\177\081\202\056\231\056\231\247\222\214\218\181\214\247^al\214\218\247\222\246\222\024\227\213\218\048\198\238\189\014\194\014\194\015\194\047\194\079\198\112\206\177\214\018\219\016\219\168\237\0\252\129\252\161\236\036\169\101\165\101\165\166\173\008\186\106\202\235\218\043\235\075\243\074\239\103\247\131\255\064\222\0\144\032\132\002\161\099\169\100\165\132\169\100\202\097\231\224\210\032\157\100\169\165\177\100\165\101\169\167\177\041\190\166\190\096\166\160\145\065\149\131\165\100\165\004\161\004\157\100\165\164\169\131\157\033\141\192\136\034\149\100\161\101\169\005\162\131\138\131\130\069\158\232\185\199\181\166\173\166\173\198\173\198\161\099\137\129\128\0\128\227\148\035\157\036\161\134\169\166\157\003\129\098\128\037\149\102\161\036\157\194\148\196\132\104\129\136\133\102\161\199\177\009\186\074\194\140\202\143\186\082\142\121\130\253\130\183\142\233\157\198\177\008\190\107\198\173\210\240\218\049\227\082\231\214\206\149\153\011\128\0\128\038\161\233\181\167\173\135\169\103\165\170\140\013\128\044\128\071\161\134\169\167\173\232\181\073\194\044\194\047\165\011\128\0\128\229\152\103\169\103\169\167\177\199\181\009\169\012\144\012\140\008\140\229\156\069\165\069\161\038\161\071\165\105\173\139\177\172\181\081\202\023\227\023\227\246\222\214\218\213\218sNal\214\218\247\222\023\227\089\235\213\218\238\189\238\189\014\190\014\190\014\194\014\194\047\198\112\206\177\214\018\219\016\219\168\233\0\248\096\244\128\228\194\204\002\213\067\225\197\225\103\230\234\238\043\243\107\251\138\255\135\255\068\255\064\226\096\144\0\128\225\160\098\177\067\169\035\161\100\169\100\198\225\214\224\181\065\132\100\169\165\173\069\165\102\165\168\177\010\190\105\194\004\170\0\133\0\141\129\149\163\157\036\161\005\161\164\165\003\162\162\145\192\128\0\128\002\149\133\165\134\173\164\157\193\129\161\129\163\141\166\165\167\181\166\173\166\165\164\153\099\137\161\128\032\128\0\128\195\148\003\157\036\161\134\169\101\157\130\128\065\128\036\149\102\161\068\161\227\152\195\140\229\128\006\129\038\145\167\169\009\186\041\190\108\198\142\194\045\162\141\129\022\130\188\130\185\142\080\162\075\182\107\206\206\218\017\223\052\215\184\190\150\149\044\128\0\128\197\144\104\161\103\165\102\165\134\169\103\165\232\148\010\128\011\128\138\140\039\157\166\177\232\185\203\181\013\161\011\128\004\128\0\128\229\152\070\165\070\169\166\173\199\181\072\173\040\140\008\132\006\136\100\144\164\152\164\152\006\161\103\169\105\173\171\177\172\181\081\202\023\227\056\231\247\222\214\218\214\218\247^al\214\218\023\227\246\222\056\231\213\218\015\194\238\189\014\194\014\194\047\194\047\198\111\202\144\206\177\214\017\219\239\218\135\217\0\204\064\184\064\176\032\176\064\188\160\212\065\245\194\253\068\250\132\250\132\254\100\242\0\214\096\189\0\144\0\128\001\165\098\177\067\169\003\157\227\156\100\169\068\194\065\198\032\161\001\128\100\165\133\169\037\161\038\161\136\173\234\185\075\198\007\182\064\149\160\128\064\141\225\149\066\154\130\154\098\154\193\145\224\132\0\128\129\140\069\161\134\169\166\173\165\169\034\141\160\128\192\128\226\136\003\149\035\149\035\141\002\129\128\128\032\128\032\128\0\128\162\140\227\152\036\161\134\169\069\157\065\128\065\128\036\149\134\161\069\161\004\157\003\153\196\132\132\128\131\128\102\161\200\181\233\185\043\190\109\190\076\178\168\161\009\133\112\129\246\129\057\130\122\150\153\170\153\178\122\174\025\166\051\129\009\128\0\128\229\152\136\169\103\161\005\157\037\161\069\161\134\169\071\161\038\128\006\128\007\128\071\136\199\148\232\152\137\144\008\128\005\128\001\128\0\128\196\152\070\165\037\161\102\169\199\181\168\181\101\144\003\128\003\132\002\132\002\132\002\132\197\152\104\169\137\173\171\177\172\181\081\202\088\235\089\235\247\222\214\218\214\218\247^al\213\218\246\222\247\222\056\231\212\214\014\190\014\190\014\194\046\194\047\198\079\202\111\206\144\206\176\210\241\218\205\218\101\189\0\128\0\128\0\128\0\128\0\128\0\148\0\184\096\196\160\196\160\192\160\188\0\172\0\128\0\128\225\160\097\177\130\181\067\173\228\152\195\152\228\152\101\169\004\186\161\177\032\132\0\128\036\161\101\169\005\161\006\161\104\169\202\181\011\190\041\190\229\173\064\153\128\128\224\128\128\133\192\133\096\129\160\128\0\128\162\144\068\161\101\165\070\165\134\169\199\177\133\161\162\132\0\128\0\128\0\128\032\128\0\128\0\128\162\140\227\148\097\136\0\128\065\128\195\148\036\161\134\169\036\153\0\128\032\128\004\149\102\161\069\157\004\161\004\157\228\144\098\128\0\128\131\136\102\165\168\177\234\181\076\186\043\186\200\181\102\165\226\148\103\128\239\128\082\129\082\129\049\129\176\128\013\128\004\128\134\128\042\149\202\173\168\177\037\161\005\157\005\157\005\157\102\169\136\169\006\153\002\128\0\128\002\128\003\128\003\128\002\128\196\148\196\152\0\128\0\128\164\144\005\157\005\161\037\165\166\177\200\181\230\156\001\128\0\128\0\128\0\128\0\128\099\144\039\165\072\169\106\173\139\177\015\194\022\227\089\235\023\227\246\222\214\218\181Val\181\214\214\218\247\222\023\227\213\218\048\198\014\190\014\194\046\194\047\198\079\198\111\202\144\206\176\210\208\214\107\214\066\181\162\148\003\161\193\160\194\152\162\148\162\144\194\136\097\128\065\128\161\152\224\168\226\160\003\161\099\177\195\193\226\197\098\177\195\152\163\148\195\148\196\152\069\169\004\190\227\185\033\161\002\157\037\161\037\161\005\157\007\157\071\169\169\177\235\185\010\190\008\186\165\169\003\157\194\148\065\140\001\136\065\140\162\148\196\152\037\161\101\165\101\161\006\161\070\165\135\173\167\173\133\161\003\149\130\140\097\136\129\136\194\148\227\148\069\161\070\165\228\152\162\140\162\144\195\148\004\157\069\165\069\157\195\148\163\148\005\153\070\157\037\157\229\156\005\157\037\157\196\148\131\144\164\144\037\161\103\169\169\173\011\178\010\182\200\181\200\177\135\169\003\153\160\148\128\144\064\140\065\132\096\136\001\161\036\165\074\149\174\157\203\173\069\169\228\156\229\152\229\152\005\157\070\165\136\169\136\169\038\161\163\148\098\140\065\136\130\144\228\156\102\169\102\169\195\152\196\148\196\148\229\152\229\156\005\161\102\169\168\177\135\177\037\161\163\148\066\140\066\136\066\136\131\144\229\156\007\161\040\165\105\173\172\181\081\202\023\227\056\231\247\222\214\218\016Bal\181\214\214\218\247\222\247\222\246\222\213\218\146\210\047\198\014\190\046\194\079\198\079\198\111\202\144\206\176\210\076\206\200\193\167\181\199\181\100\177\067\173\004\165\036\161\036\165\003\157\003\153\099\177\131\189\101\177\134\177\164\185\163\189\098\177\226\156\163\148\163\148\164\148\197\152\101\169\068\194\070\198\166\177\102\169\038\165\005\161\229\156\231\156\072\165\137\177\203\185\235\185\202\181\136\177\134\169\101\165\229\156\228\152\036\157\069\161\038\165\038\161\037\157\037\157\006\157\006\161\070\165\135\169\199\169\167\169\037\161\228\152\004\153\069\161\101\165\102\165\038\165\005\161\036\157\004\153\196\152\196\152\005\157\070\161\070\165\006\161\006\157\038\153\038\153\230\156\229\156\038\157\038\161\038\161\038\161\070\161\038\161\072\169\202\173\202\177\168\177\168\177\167\173\102\165\070\165\037\165\037\157\006\153\038\157\168\177\200\181\135\169\072\157\072\157\005\157\196\152\165\148\197\152\006\157\040\165\105\169\169\177\168\177\103\169\005\157\228\152\037\161\102\169\134\169\070\165\102\169\070\165\229\152\196\148\197\152\005\157\038\165\135\173\200\181\200\177\103\169\229\156\195\152\196\148\196\152\229\152\230\156\007\161\073\169\106\173\205\185\213\218\056\231\023\227\214\218\255\127\255\127al\214\218\247\222\247\222\247\222\023\227\056\231\245\222\114\206\047\198\046\198\079\198\079\198\111\202\111\202\077\198\043\194\234\185\168\173\069\169\035\169\228\156\228\156\227\160\004\157\004\157\036\161\037\161\038\161\037\161\035\165\002\165\226\160\162\148\131\144\164\144\165\148\198\152\101\173\069\198\071\198\105\169\008\161\038\161\005\157\230\156\007\157\040\165\137\173\203\181\203\185\171\181\105\173\103\169\070\165\038\161\038\161\069\161\037\161\229\156\229\152\228\152\228\152\230\156\006\157\039\161\072\165\104\169\104\169\039\165\006\161\005\161\005\157\036\157\037\157\230\156\229\152\228\152\228\152\196\148\196\148\229\152\038\161\038\161\007\161\006\157\006\153\006\153\230\156\230\156\006\161\039\165\039\165\038\161\038\161\006\157\039\161\137\173\170\177\169\177\169\177\136\173\071\165\038\161\070\165\070\165\038\161\038\161\071\169\103\169\037\165\228\156\229\152\197\152\165\148\197\152\230\152\007\161\073\169\106\173\138\173\137\173\103\173\070\165\038\161\037\161\037\161\005\157\229\156\005\161\005\157\196\152\164\148\197\152\229\156\038\161\103\169\136\173\136\173\104\169\038\161\228\156\196\152\196\148\196\148\197\152\231\156\040\165\106\173\140\177\081\202\023\227\023\227\246\222al\255\127al\181\214\214\218\214\218\246\222\023\227\089\235\122\239\023\227\080\202\046\194\046\198\079\198\111\202\079\202\013\194\236\185\202\181\103\169\005\161\228\160\196\152\164\152\195\152\195\148\164\148\164\148\164\144\197\148\196\152\195\152\226\160\193\156\163\148\132\144\165\148\198\152\232\156\104\173\070\198\071\198\074\169\009\161\039\161\231\156\231\156\008\161\073\165\106\173\203\181\204\185\172\181\138\173\072\169\039\161\007\161\006\157\229\156\197\152\197\148\197\148\196\148\196\152\230\156\231\156\040\161\072\169\073\169\040\165\007\161\006\157\230\156\197\152\228\152\229\152\197\152\197\152\197\148\196\148\164\148\197\152\230\156\006\157\006\157\007\161\007\157\230\156\230\156\007\161\007\161\039\165\040\165\040\165\007\161\006\161\006\157\039\161\137\169\137\173\137\177\169\177\168\173\071\165\007\161\006\161\006\157\229\156\229\156\230\156\230\156\197\152\196\152\197\152\198\152\197\152\230\152\007\157\040\165\106\173\139\177\139\177\106\173\072\169\039\161\006\157\229\156\229\152\197\152\197\152\197\152\197\152\165\148\165\148\197\152\230\156\006\161\103\169\105\173\073\169\040\165\007\161\229\152\196\148\164\148\164\148\197\152\231\156\008\161\074\169\107\173\238\189\023\227\023\227\246\222al\255\127\255\127al\247\222\214\218\214\218\247\222\023\227\089\235\056\231\080\202\014\194\046\194\046\194\079\198\079\198\238\189\204\181\170\177\103\169\007\161\230\156\197\152\197\152\196\152\164\148\164\148\164\148\196\148\197\152\197\152\195\156\226\160\195\156\164\148\165\148\231\156\008\161\010\165\106\173\071\198\103\202\106\173\042\165\040\165\008\161\008\161\041\165\074\169\107\173\139\177\172\181\140\177\107\173\105\169\040\165\007\161\230\156\230\152\197\152\197\148\197\148\196\148\197\152\231\156\008\161\041\165\073\169\074\173\073\169\040\165\007\157\230\156\230\152\229\152\229\152\198\152\198\152\197\152\197\148\197\152\230\156\007\161\007\161\039\161\008\161\008\161\007\161\008\161\008\161\040\161\073\165\073\169\073\169\040\165\039\165\007\161\040\161\137\169\138\173\138\177\170\177\169\177\073\169\040\165\007\161\006\157\230\156\198\152\230\156\230\152\197\152\197\152\230\152\230\152\231\156\008\161\041\165\074\169\139\177\172\181\172\181\139\177\105\169\040\165\007\157\230\156\230\156\197\152\197\152\229\152\230\156\198\152\198\152\230\156\007\161\007\161\072\169\106\173\106\173\073\169\007\161\230\156\197\152\197\152\197\152\198\152\231\156\041\165\074\169\107\173\238\189\023\227\056\231\247\222alal\255\127\181ValsN\214\218\247\222\247\222\056\231\056\231\146\210\014\194\014\194\014\194\078\198\046\194\205\185\172\181\170\177\105\173\040\165\008\161\231\156\230\156\230\156\198\152\198\152\197\152\197\152\198\152\198\152\229\156\228\156\197\152\198\152\231\156\008\161\041\165\043\165\139\177\103\202\135\206\140\177\075\169\074\169\041\165\041\165\074\169\074\169\206\185\049\198\081\202\081\202\238\189\106\173\073\169\041\165\007\161\230\156\230\152\198\152\198\152\198\152\231\156\008\161\041\165\074\169\107\173\107\173\106\173\073\169\040\161\007\161\231\156\230\152\230\156\231\156\231\156\230\156\230\152\231\156\008\161\040\165\040\165\040\165\041\165\041\165\041\165\041\165\073\169\073\169\074\169\107\173\107\173\074\169\072\169\072\165\073\165\170\173\139\177\139\177\170\177\169\173\074\169\073\169\040\165\008\161\007\161\231\156\007\157\007\157\230\152\230\152\007\157\008\161\008\165\041\165\074\169\107\173\140\177\172\181\140\181\139\177\106\169\040\165\008\161\008\161\007\157\231\156\230\152\230\156\007\161\231\156\231\156\008\161\041\165\040\165\105\169\138\173\107\173\106\173\073\169\008\161\231\156\230\156\230\156\231\156\008\161\074\169\107\173\140\177\015\194\246\222\247\222\246\222al\255\127al\255\127\181V\255\127\214\218\214\218\247\226\024\227\056\231\179\214\014\194\014\194\014\194\046\198\112\202\081\202\048\198\205\185\106\173\073\169\041\165\040\165\007\161\231\156\007\161\232\156\231\156\198\152\231\156\231\156\231\156\231\156\231\156\232\156\008\161\107\173\239\189\017\194\015\194\136\206\135\206\140\177\076\169\107\173\074\169\074\169\107\173\140\177\213\218\121\239\089\235\121\239\246\222\239\189\074\169\074\169\041\165\008\161\008\161\007\161\007\161\231\156\008\161\041\165\074\169\107\173\139\177\140\177\107\173\074\169\041\165\041\165\008\161\008\161\008\161\008\161\040\165\008\161\231\156\008\161\041\165\073\169\073\165\073\169\074\169\074\169\074\169\074\169\074\169\074\169\107\173\140\177\107\173\107\173\105\173\105\169\106\169\170\173\138\177\172\181\079\198\047\194\048\194\206\185\074\169\041\165\008\161\008\161\040\161\040\161\007\161\008\161\008\161\041\165\042\169\140\177\016\194\048\198\048\198\049\198\048\198\048\198\016\194\239\189\106\173\008\161\008\161\008\161\008\161\007\161\039\161\008\161\008\161\041\165\074\169\074\169\106\173\107\173\107\173\107\173\074\169\041\165\008\161\008\161\231\156\008\161\074\169\074\169\107\173\140\177\206\185\214\218\247\222\246\222al\255\127alalal\255\127al\213\218\214\218\024\227\056\231\180\214\047\194\014\194\014\194\079\198\245\222\121\239\088\235\181\214\239\189\239\189\239\189\238\189\206\185\140\177\074\169\041\165\041\165\140\177\206\185\205\185\173\181\206\185\206\185\206\185\206\185\147\210\056\231\089\235\245\222\171\210\135\206\016\194\240\193\015\194\016\194\015\194\239\189\180\214\089\235\121\239\089\235\089\235\089\235\214\218\016\194\015\194\206\185\041\165\041\165\041\165\041\165\041\165\139\177\239\189\239\189\015\194\016\194\016\194\016\194\015\194\239\189\206\185\074\169\041\165\041\165\074\169\074\169\041\165\139\177\206\185\239\189\239\189\238\189\238\189\239\189\239\189\238\189\015\194\015\194\239\189\016\194\016\194\016\194\016\194\014\194\014\190\015\190\046\194\014\194\114\206\088\235\056\231\088\235\246\222\049\198\238\189\206\185\107\173\074\165\073\165\041\165\041\165\107\173\238\189\239\189\114\206\056\231\056\231\024\227\055\231\055\231\056\231\056\231\056\231\081\202\206\185\206\185\139\177\041\165\106\173\237\189\206\185\206\185\239\189\205\185\107\173\206\185\016\194\016\194\016\194\015\194\239\189\206\185\206\185\206\185\140\177\074\169\140\177\239\189\016\194\049\198\246\222\023\227\246\222alal\255\127alal\255\127alal\214\218\023\227\056\231\023\227\081\202\238\189\238\189\047\198\022\227\122\239\122\239\056\231\246\222\246\222\246\222\247\222\023\227\213\218\016\194\205\185\015\194\213\218\023\227\246\222\246\222\246\222\246\222\246\222\246\222\056\231\122\239\155\243\055\231\172\210\169\210\022\227\056\231\023\227\023\227\246\222\246\222\024\227\056\231\056\231\024\227\056\231\056\231\056\231\246\222\023\227\246\222\016\194\206\185\206\185\206\185\206\185\180\214\056\231\023\227\023\227\023\227\023\227\023\227\023\227\023\227\246\222\016\194\206\185\206\185\239\189\239\189\206\185\148\210\023\227\023\227\023\227\246\222\246\222\247\222\247\222\246\222\023\227\023\227\023\227\023\227\023\227\023\227\023\227\022\227\246\222\022\223\022\223\246\222\023\227\089\235\089\235\089\235\089\235\023\227\023\227\023\227\081\202\206\185\238\185\206\185\206\189\115\206\023\227\247\222\023\227\089\235\057\231\056\231\056\231\056\231\056\231\057\231\089\235\023\227\246\222\023\227\147\210\206\185\082\202\023\227\023\227\023\227\023\227\213\218\048\198\213\218\023\227\023\227\023\227\023\227\246\222\246\222\023\227\023\227\148\210\206\185\082\202\247\222\023\227\246\222\023\227\024\227\247\222alal\255\127\255\127al\255\127\255\127al\214\218\246\222\056\231\023\227\114\206\015\194\016\198\080\202\245\222\056\231\056\231\024\227\024\227\056\231\056\231\056\231\089\235\089\235\247\222\213\218\246\222\089\235\089\235\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\089\235\022\227\171\210\171\210\120\239\154\243\089\235\056\231\056\231\056\231\056\231\247\222\246\222\214\218\214\218\246\222\056\231\057\231\056\231\056\231\246\222\213\218\246\222\214\218\246\222\056\231\089\235\089\235\056\231\056\231\056\231\056\231\056\231\089\235\089\235\246\222\246\222\246\222\246\222\246\222\214\218\056\231\089\235\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\024\227\023\227\023\227\023\227\023\227\056\231\056\231\089\235\023\227\246\218\246\222\246\222\246\222\056\231\089\235\056\231\024\227\023\227\247\222\247\222\247\222\247\222\247\222\247\222\023\227\024\227\056\231\089\235\056\231\213\218\023\227\089\235\089\235\089\235\089\235\056\231\246\222\056\231\089\235\056\231\056\231\056\231\056\231\056\231\089\235\089\235\056\231\213\218\023\227\089\235\057\231\057\231\247\222\214\218\214\218al\255\127\255\127\255\127\255\127al\255\127alal\214\218\024\227\023\227\246\222\213\218\213\218\246\218\247\222\023\227\247\222\246\222\246\222\247\222\023\227\024\227\024\227\056\231\089\235\089\235\089\235\057\231\056\231\056\231\056\231\056\231\024\227\024\227\024\227\247\222\023\227\056\231\246\222\171\210\170\210\055\231\089\235\023\227\247\222\024\227\246\222\214\218\214\218\214\218al\214\218\214\218\214\218\247\222\247\222\057\231\089\235\090\235\090\235\089\235\089\235\057\231\056\231\024\227\024\227\024\227\024\227\024\227\024\227\056\231\057\231\089\235\089\235\122\239\122\239\090\235\089\235\089\235\057\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\056\231\024\227\024\227\024\227\024\227\024\227\024\227\024\227\024\227\056\231\057\231\089\235\090\235\122\239\122\239\090\235\089\235\057\231\056\231\024\227\024\227\024\227\023\227\247\222\247\222\023\227\024\227\024\227\024\227\056\231\057\231\089\235\089\235\089\235\057\231\057\231\057\231\057\231\057\231\057\231\057\231\057\231\056\231\056\231\056\231\056\231\056\231\057\231\057\231\056\231\024\227\023\227\023\227\247\222\246\222\214\218\181\214\181Val\255\127\255\127\255\127\255\127alal\016Bal\214\218\214\218\057\231\056\231\056\231\056\231\024\227\023\227\023\227\024\227\023\227\214\218\214\218\214\218\214\218\214\218\214\218\246\222\247\222\246\222\246\222\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\247\222\056\231\246\222\139\206\170\210\055\231\056\231\247\222\246\222\214\218\214\218alalalalalalal\181\214\214\218\246\222\247\222\247\222\247\222\247\222\247\222\246\222\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\247\222\247\222\247\222\247\222\247\222\247\222\246\222\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\246\222\246\222\247\222\247\222\247\222\247\222\246\222\214\218\214\218\214\218\214\218\214\218\214\218\181\214\213\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\246\222\246\222\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\214\218\246\222\246\222\214\218\214\218\214\218\181\214alalsNalal\255\127\255\127\255\127alal\255\127\255\127al\214\218\214\218\246\222\246\222\247\222\214\218\214\218\214\218\214\218\213\218\214\218\181\214\214\218\214\218\181\214\181V\181VsN\181V\181V\016B\0\0alalalal\181\214\214\218\023\227\056\231\245\222\139\206\138\206\023\227\056\231\246\222\214\218sNalal\0\0\255\127\255\127\255\127\0\0\255\127\255\127\255\127alal\255\127\0\0sNsN\181V\181V\148R\148R\181V\181V\181V\148R\181V\181V\021BU)\0\0\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127\255\127\255\127\255\127al\255\127\016Balal\255\127\255\127\255\127\255\127\255\127al\255\127\255\127\255\127al\214\218\214\218\214\218\214\218\214\218\148R\255\127alalalalalalal\255\127al\255\127alal\255\127\255\127al\255\127al\181\214\214\218\247\222\024\227\213\222\108\202\107\206\022\227\057\231\246\222\247\222al\247^\0\0\255\127alalalal\255\127\255\127\255\127\016B\255\127\255\127\255\127alalalalalalalal\255\127\255\127alalalalalalalalal\255\127\0\0\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\016B\255\127\255\127\255\127\255\127\0\0\255\127\255\127alal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\016B\0\0\255\127\255\127alalalal\016B\181V\181V\255\127\016B\255\127\255\127\255\127\255\127\255\127\255\127\255\127\0\0\0\0\0\0\0\0\0\0\255\127al\214\218\247\222\023\227\213\218\077\202\075\202\246\222\056\231\214\218\247\222al\016Balalalalalal\255\127\255\127\255\127\255\127\255\127\0\0\0\0\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\0\0\0\0\0\0\0\0\0\0\255\127\255\127alalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalal\255\127al\255\127al\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\016B\181V\181V\181V\016B\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alal\255\127\255\127alal\181Val\214\218\214\218\024\227\246\222\178\214\178\214\023\227\024\227\214\218\016B\255\127\255\127\255\127\255\127\255\127\255\127\255\127alal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127al\255\127\255\127\255\127\255\127al\255\127\255\127\255\127\255\127alal\255\127alalalalalalal\255\127alal\255\127alal\255\127\255\127\255\127alalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalal\255\127al\255\127alalalalalalalalal\255\127\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalal\255\127alalalalalalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalalal\255\127alalal\255\127\255\127alalalalalalalalal\255\127\255\127\181\214\214\218\246\222\247\222\246\222\246\222\247\222\214\218\247\222alal\255\127\255\127al\255\127al\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127al\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalal\255\127\255\127\255\127\255\127alal\255\127\255\127\255\127alalalalalalalalalalalal\255\127\255\127al\255\127alalalalalalal\255\127alal\255\127al\255\127al\255\127\255\127alalalalalalalalalalalalalalalalalal\255\127\255\127\255\127alalalalalalalalal\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127\255\127alalalalalalalalalalalalalalalalalalalal\255\127\016B\214Z\214Zalalalalalalalal\255\127\255\127\255\127\255\127\148R\214Z\214Z\247^\214Z\181VsN\247^\181V\181V\255\127\016B\016B\255\127\255\127\255\127\255\127\255\127\255\127\0\0\0\0\0\0\255\127alalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\255\127\255\127\255\127\255\127alal\255\127alalal\255\127alalalalalalalalal\255\127alal\255\127alal\255\127alal\255\127al\255\127alalalalal")
paddleImg = image.new("\046\0\0\0\010\0\0\0\0\0\0\0\092\0\0\0\016\0\001\0alal\047\132\080\132\081\136\115\136\149\140\149\140\184\140\184\140alalalalalalalalalalalalalalalalalalalalalalalalalal\184\140\184\140\149\140\149\140\116\136\081\136\080\132\080\132alalal\047\132\080\132\081\136\214\152\153\177\026\190\059\194\092\194\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\198\092\194\059\194\026\190\026\190\055\161\115\136\081\136\080\132al\047\132\047\132\081\136\055\161\223\247\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\188\210\115\136\080\132\047\132\047\132\047\132\115\136\218\226\123\251\123\247\123\247\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\243\123\247\123\251\123\251\055\161\080\132\048\132\047\132\080\132\116\136\115\230\115\242\115\230\115\230\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\222\115\230\115\242\115\242\085\177\081\136\080\132\047\132\080\132\115\136\211\204\140\229\140\229\140\217\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\205\140\217\140\217\140\229\140\229\211\152\081\136\080\132\047\132\080\132\115\136\116\136\204\204\198\228\132\220\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\212\132\220\132\224\200\224\179\164\115\136\081\136\080\132al\080\132\115\136\116\136\052\185\147\229\055\161\056\169\250\144\250\144\250\144\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\217\140\250\144\250\144\217\152\217\140\181\221\147\205\149\140\115\136\081\136alalal\115\136\116\136\179\164\045\229\214\152\217\140\217\140\217\140alalalalalalalalalalalalalalalalalalalalalalalalalal\217\140\217\140\217\140\214\152\045\229\179\164\116\136\115\136alalalalalalal\204\176\137\212\177\172alalalalalalalalalalalalalalalalalalalalalalalalalalalalalal\179\164\137\212\204\176alalalalal")
