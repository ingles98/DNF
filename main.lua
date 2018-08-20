
require 'init'
function love.update(dt)
    networking(dt)
    GAME:update(dt)

    for i,f in pairs(EVENT.update) do
        f();
    end
end

function love.draw()
    GAME:draw()
    for i,f in pairs(EVENT.draw) do
        f();
    end
end

function love.keypressed(key, scancode, isrepeat)
    GAME:keypressed(key, scancode, isrepeat)
    if key == 'return' then
        if GAME.isOn == false then
            if #ConnectBlock.portField.text == 0 then
                ConnectBlock.portField.text = tostring(DEFAULT_PORT)
            end
            if #ConnectBlock.ipField.text == 0 then
                ConnectBlock.ipField.text = DEFAULT_IP
            end
            if ConnectBlock.ipField.text == "localhost" then
                local ip, port = Client.getIP()
                ConnectBlock.ipField.text = ip
            end
            Client.sockName = {ConnectBlock.ipField.text, tonumber(ConnectBlock.portField.text)}
            GAME:init()
        elseif GAME.isOn==true then
            GAME:kill()
        end
    elseif key == 'f10' then
        for x,v in pairs(TileMap) do
            for y,vv in pairs(TileMap[x]) do
                TileMap[x][y]["id"] = 2
                TileBatch_update()
            end
        end
    end
end

function love.textinput(text)
    for k,v in pairs(EVENT.textinput) do
        --if v.isActive == true then
            v(text)
        --end
    end
end

function love.resize(w, h)
    --for k,v in pairs(UITable) do
    --    v:OnScreenResize(w,h)
    --end
    for k,v in pairs(EVENT.resize) do
        v()
    end
end
