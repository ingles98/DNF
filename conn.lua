socket = require "socket"
Client = {}
Client.time = love.timer.getTime()
Client.incoming = {}
Client.sockName = {"192.168.1.5", 63582}

Client.getIP = function()
    local s = socket.udp()
    s:setpeername( "74.125.115.104", 80 )
    local ip, sock = s:getsockname()
    s:close()
    return ip
end

function Client.connectToServer( ip, port )
    Client.stopClient()
    local sock, err = socket.connect( ip, tonumber(port) )
    print("socket: "..tostring(sock))
    if err then
        print("error: "..err)
        return false
    end
    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    sock:send( "wWE are connected\n" )
    Client.sock = sock
    return true
end

function Client.createClientLoop(ip, port)
    print("Created Client Pulse.")
    local sock = Client.sock
    Client.time = love.timer.getTime()
    Client.buffer = {}

    Client.pulse = function()
        local allData = {}
        local sock = Client.sock
        local data, err
        repeat -- collects data
            data = nil
            s, status,partial = sock:receive()
            data = s or partial
            if data == partial and #data <=2 then data = nil end
            if data then
                --print("received something")
                allData[#allData+1] = data
            end
            if ( err == "closed" and Client.pulse ) then  --try again if connection closed
                print("Reconnecting.")
                Client.connectToServer( Client.sockName[1], Client.sockName[2] )
                s, status,partial = sock:receive()
                data = s or partial
                if data == partial and #data <=2 then data = nil end
                if data then
                    allData[#allData+1] = data
                end
            end
        until not data

        if ( #allData > 0 ) then
            --print("Data incoming: \n\n")
            local passCommand                       -- FOR SEPERATED MESSAGES
            for i, thisData in ipairs( allData ) do -- REACT TO INCOMING DATA
                --print( "Received: ", thisData )
                if thisData == "MAP" then               -- MAP UPDATE COMMAND
                    passCommand = thisData
                elseif passCommand ~= nil and thisData ~= passCommand then
                    if passCommand == "MAP" then                              -- MAP UPDATE ARGUMENT (BINARY DATA)
                        TileMap = assert(binser.deserializeN(thisData))
                        TileBatch_update()
                    end
                    passCommand = nil
                end
                --react to incoming data
            end
        end

        for i, msg in pairs( Client.buffer ) do -- SEND DATA TO SERVER
            print("Sending: "..msg)
            local data, err = Client.sock:send(msg.."\n")
            if ( err == "closed" and Client.pulse ) then  --try to reconnect and resend
                print("Reconnecting.")
                Client.connectToServer(Client.sockName[1], Client.sockName[2] )
                data, err = sock:send( msg.."\n" )
            end
            if not err then Client.buffer[i] = nil end
        end
    end
end

function Client.stopClient()
    Client.pulse = nil  --cancel timer
    if Client.sock then
        local data, err = Client.sock:send("CLOSED\n")
        if err then print("Could not close connection with the server.") end
        Client.sock:close()
        Client.sock = nil
    end
end

function Client.start()
    print("Attempting to Connect.")
    local bool = Client.connectToServer(Client.sockName[1], Client.sockName[2])
    if bool ~= false and bool ~=nil then
        Client.createClientLoop(Client.sock:getsockname())
    else
        print("Could not connect.")
        return false
    end
end
function love.quit()
    Client.stopClient()
end


function networking(dt)
    if (love.timer.getTime() - Client.time)*1000 >= 0 then
        if Client.pulse then
            Client.time = love.timer.getTime()
            Client.pulse()
        end
    end
end

GAME = {isOn = false}
function GAME:draw()
    if self.isOn then
        love.graphics.push()
        Camera.distX = Player.x*Camera.scale - love.graphics.getWidth()/2
        Camera.distY = Player.y*Camera.scale - love.graphics.getHeight()/2
        love.graphics.translate(-Camera.distX,-Camera.distY)
        love.graphics.scale(Camera.scale)
        --love.graphics.rectangle("fill", 64, 64, (gridLength+1)*Entity.w, (gridLength-1)*Entity.h)
        love.graphics.draw(TileBatch)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.circle('fill', Player.x, Player.y, 32)

        love.graphics.reset()
        for k,v in ipairs(Entities) do
            v:Draw()
        end
        love.graphics.pop()
        --for k,v in ipairs(UIDrawTable) do
        --    v:Draw()
        --end
    end
end

function GAME:init()
    local bool = Client.start()
    if bool == false then
        print("\nCould not start client socket.")
        return false
    end
    print("\nConnection established.\n")
    Camera = {
        distX = -10,
        distY = -10,
        scale = 0.5
    }

    Player = {
        x = TILE.w/2,
        y = TILE.h/2,
        w = TILE.w,
        h = TILE.h,
        isMoving = false,
        targetX = 0,
        targetY = 0
    }

    function Player:Move(dx,dy)
            self.oldTargetX = self.targetX
            self.oldTargetY = self.targetY
            self.targetX = self.x + dx*TILE.w
            self.targetY = self.y + dy*TILE.h
            --print( (self.targetX - (TILE.w/2) )/TILE.w)
            local tx = (self.targetX - (TILE.w/2) )/TILE.w
            local ty = (self.targetY - (TILE.h/2) )/TILE.h
            if TileMap[tx] and TileMap[tx][ty] and TileMap[tx][ty]["id"] then
                local id = TileMap[tx][ty]["id"]
                if TILE.list[id]["collide"] == false then
                    local CMD = "MOVE"
                        CMD = CMD.." "
                        CMD = CMD.."("..dx..","..dy..")"
                    table.insert(Client.buffer, CMD)
                    self.isMoving = true
                else
                    self.targetX = self.oldTargetX
                    self.targetY = self.oldTargetY
                end
            end
        --print(self.targetX)
    end
    function Player:getPos()
        local x,y
        x = ( self.x-(TILE.w/2) ) /TILE.w
        y = ( self.y-(TILE.h/2) ) /TILE.h
        return {x=x,y=y}
    end
    function Player:Update()
        if not self.isMoving then
            if love.keyboard.isDown("up") then
                --Camera.distY =Camera.distY - 8
                self:Move(0,-1)
            elseif love.keyboard.isDown("down") then
                --Camera.distY = Camera.distY +8
                self:Move(0,1)
            elseif love.keyboard.isDown("left") then
                --Camera.distX = Camera.distX -8
                self:Move(-1,0)
            elseif love.keyboard.isDown("right") then
                --Camera.distX = Camera.distX +8
                self:Move(1,0)
            end
        else
            local spd = 4
            if self.targetX>self.x then
                self.x = self.x + spd
            elseif self.targetX<self.x then
                self.x = self.x - spd
            end
            if math.sqrt((self.targetX - self.x)^2) <= math.sqrt(spd) then
                self.x = self.targetX
            end

            if self.targetY>self.y then
                self.y = self.y + spd
            elseif self.targetY<self.y then
                self.y = self.y - spd
            end
            if math.sqrt((self.targetY - self.y)^2) <= math.sqrt(spd) then
                self.Y = self.targetY
            end

            if self.x == self.targetX and self.y == self.targetY then self.isMoving = false end


        end
    end

    self.isOn = true
    SCREEN:close("mainScreen")
    print("Game initiated.")
end

function GAME:kill()
    self.isOn = false
    Camera = nil
    Player = nil
    Client.stopClient()
    print("Game killed.")
    SCREEN:open("mainScreen")
end

function GAME:update(dt)
    if self.isOn == true then
        --for k,v in pairs(UITable) do
        --    v:Update()
        --end
        for k,v in pairs(Entities) do
            v:Update()
        end
        Player:Update()

    end
end

function GAME:keypressed(key, scancode, isrepeat)
    if self.isOn then
        if key == '+' and Camera.scale <=3 then
            Camera.scale = Camera.scale+0.1
            Camera.distX = Camera.distX + Camera.distX*0.1
            Camera.distY = Camera.distY + Camera.distY*0.1
        elseif key == '-' and Camera.scale >= 0.2 then
            Camera.scale = Camera.scale-0.1
            Camera.distX = Camera.distX - Camera.distX*0.1
            Camera.distY = Camera.distY - Camera.distY*0.1
        end

    end
end
