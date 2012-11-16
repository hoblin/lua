--~ Before usage:
--~ Make sure you have at least one piece of fuel in the first slot of the turtle.
--~ Preferably, try to refuel it a bit before starting the program, so that it won't have problem.

--~ Usage: there are 3 ways of launching the program:
--~ "mine"    will prompt the size
--~ "mine 16 32"  will make a quarry of 16 width and 32 long
--~ "mine 16 32 10"   will make the quarry start by going 10 times down, skipping the first layers

--~ How to place your base (side view) :
--~ _C
--~ C_T>
--~ 
--~ With C being chests, _ air and T the turtle, facing the > direction
--~ The chest at the top is the one that has to contain fuel, 
--~ of the same type as the one put in the first slot of the turtle,
--~ so that the turtle will be able to refuel automatically.
--~ Charcoal is advised, being a renewable and reliable source of fuel,
--~ but you are free to use any fuel as long as it stays the same kind
--~ and is a valid fuel for turtles.

--~ As for the size (top view) :
--~ CTxxxxxxxxxxxxxxx
--~ _xxxxxxxxxxxxxxxx
--~ _xxxxxxxxxxxxxxxx
--~ _xxxxxxxxxxxxxxxx
--~ 
--~ this is the quarry for inputing "mine 4 16" (see above)

--~ The program is trying to log basic events, as via the function "log(text, alsoPrint)".
--~ If you do not wish for the log, comment (or delete) the log function and uncomment the second one.

--~ NOTE: it is a basic program, doesn't take much into account, and certainly not being shut down.
--~ As such, if the chuck unload, you will have to break the turtle and bring it back to the origin point before restarting it.

local x = 0
local y = 0
local h = 0
local dir = 0
local workX, workY, workH, workDir
local row = 0
local stop = false
local maxX, maxY
local args = {...}

local function log(text, alsoPrint)
  logName = "MiningLog.txt"
  local logFile = io.open(logName, "a")
  if logFile == nil then
    print("Error. Can't create log file.")
  else
    logFile:write(text.."\n")
    logFile:close()
  end
  if alsoPrint then
    print(text)
  end
end

local function clearLog()
  logName = "MiningLog.txt"
  if fs.exists(logName) then
    fs.delete(logName)
  end
end

local function dig()
  local i = 0
  if turtle.detectUp() then
    turtle.digUp()
  end
  if turtle.detect() then
    turtle.dig()
  end
  if turtle.detectDown() then
    turtle.digDown()
  end
end

local function turn(direction)
  if direction == "left" then
    turtle.turnLeft()
    dir = (dir-1)%4
  elseif direction == "right" then
    turtle.turnRight()
    dir = (dir+1)%4
  end
  
  log("TURN "..direction.." x="..x.."  y="..y.." h="..h.." dir="..dir)
end

local function forward()
  local j=0
  while not turtle.forward() do
    if turtle.detect() then
      turtle.dig()
      j = j+1
      if j == 40 then
        stop = true
        return false
      end
    else
      turtle.attack()
    end
  end
  if dir == 0 then
    x = x+1
  elseif dir == 2 then
    x = x-1
  elseif dir == 1 then
    y = y+1
  elseif dir == 3 then
    y = y-1
  end
  return true
end

local function up()
  local j=0
  while not turtle.up() do
    if turtle.detectUp() then
      turtle.digUp()
      j = j+1
      if j == 40 then
        stop = true
        return false
      end
    else
      turtle.attackUp()
    end
  end
  h = h-1
  return true
end

local function down()
  local j=0
  while not turtle.down() do
    if turtle.detectDown() then
      turtle.digDown()
      j = j+1
      if j == 40 then
        stop = true
        return false
      end
    else
      turtle.attackDown()
    end
  end
  h = h+1
  return true
end

local function setDir(newDir)
  while not (newDir == dir) do
    turn("right")
  end
end

local function move()
  local locMin, locMax, locDirA, locDirB, directionA, directionB
  
  
  if row%2 == 0 then
    locMin = 0
    locMax = maxY
    directionA = "right"
    directionB = "left"
    locDir = 1
  else
    locMin = maxY
    locMax = 0
    directionA = "left"
    directionB = "right"
    locDir = 3
  end
  
  --Stopping the mining operation
  if x == locMax and y == 0 and turtle.detectDown() then
    stop = true
  --Going down to the next layer
  elseif x == 0 and y == locMax then
    
    for i=1,3 do
      local j=0
      down()
      if stop then
        break
      end
    end
    if not stop then
      row = row +1
    end
    log("DOWN  x="..x.."  y="..y.." h="..h.." dir="..dir)
  --Turning at end of a line
  elseif (x == maxX-1 and dir == 0) or (x == maxX and dir == locDir)then
    forward()
    turn(directionA)
  --Turning at the other end of the line
  elseif ((x == 1 and dir == 2) or (x==0 and dir == locDir)) and y ~= locMin and y ~= locMax  then
    forward()
    turn(directionB)
  elseif x==1 and y==locMax then
    forward()
    turn("right")
    turn("right")
  --In other cases, just go forward once
  else
    forward()
  end
end

local function returnHome()
  local curDir = dir
  local fuelCount
  log("Returning home: x="..x.."  y="..y.."  h="..h)
  
  
  for i=1,h do
    up()
  end
  
  setDir(3)
  for i=1, y do
    forward()
  end
  
  setDir(2)
  for i=1, x do
    forward()
  end
end

local function manageInventory()
  setDir(2)
  forward()

  log("Dropping items")
  for i=2, 16 do
    turtle.select(i)
    turtle.drop()
  end
  
  turtle.select(1)
  setDir(0)
  
  forward()
end

local function returnPosition()

  log("Returning to work from : x="..x.."  y="..y.."  h="..h.." dir:"..dir)
  log("Returning to work to : x="..workX.."  y="..workY.."  h="..workH.." dir:"..workDir)
  setDir(0)
  for i=x, workX-1 do
    forward()
  end
  
  setDir(1)
  for i=y, workY-1 do
    forward()
  end
  
  
  for i=h, workH-1 do
    down()
  end
  setDir(workDir)
end

local function inventoryCheck()
  local fuelLeft = 999
  if turtle.getItemCount(16) >0 or fuelLeft < 10 then
    workX = x
    workY = y
    workH = h
    workDir = dir
    returnHome()
    manageInventory()
    returnPosition()
    if(x == workX and y == workY and h == workH and dir == workDir) then
      log("Sucessfully returned at x="..x.."  y="..y.."  h="..h.."  dir="..dir)
    else
      log("For some reason, couldn't properly return, aborting...")
      stop = true
    end
  end
end

local function digLoop()
  while not stop do
    dig()
    inventoryCheck()
    move()
    if stop then
      returnHome()
      manageInventory()
      log("Your turtle has returned and stopped")
    end
  end
end

clearLog()
x=0
y=0
h=0
dir=0
if args[1] == nil then
  print("Size?")
  write("Width: ")
  maxY = read()
  maxY = maxY -1
  if maxY%2 == 0 then
    log("Width not a multiple of 2, adding 1", true)
    maxY =maxY+ 1
  end
  write("Length: ")
  maxX = read()
  maxX = maxX -1
  if maxX%2 == 0 then
    log("Length not a multiple of 2, adding 1", true)
    maxY =maxX+ 1
  end
else
  local var1, var2
  if args[2] == nil then
    var1 = args[1]-1
    if var1 == 0 then
      log("Not a multiple of 2, adding 1", true)
      var1 =var1+ 1
    end
    log(var1)
    maxX = var1
    maxY = var1
  else    
    maxY = args[1]-1
    if maxY%2 == 0 then
      log("Width not a multiple of 2, adding 1", true)
      maxY =maxY+ 1
    end
    
    maxX = args[2]-1
    if maxX%2 == 0 then
      log("Length not a multiple of 2, adding 1", true)
      maxX =maxX+ 1
    end
    
    if args[3] ~= nill then
      workX = 0
      workY = 0
      workH = args[3]
      workDir = 0
      returnPosition()
    end
  end
end
log("Starting mining operation with dimensions "..(maxY+1).."x"..(maxX+1), true)

digLoop()