SCREEN = {}
SCREEN.mainScreen = {isOn = false}
SCREEN.mainScreen.drawTbl = {}
SCREEN.mainScreen.updateTbl = {}
SCREEN.mainScreen.resizeTbl = {}
SCREEN.mainScreen.textinputTbl = {}

function SCREEN:close(screen)
    if SCREEN[screen].isOn == true then
        SCREEN[screen].isOn = false
        EVENT:pop("draw",SCREEN[screen].draw)
        EVENT:pop("update",SCREEN[screen].update)
        EVENT:pop("textinput",SCREEN[screen].textinput)
        EVENT:pop("resize",SCREEN[screen].onScreenResize)
    end
end

function SCREEN:open(screen)
    if SCREEN[screen].isOn == false then
        SCREEN[screen].isOn = true
        EVENT:enqueue("draw",SCREEN[screen].draw)
        EVENT:enqueue("update",SCREEN[screen].update)
        EVENT:enqueue("textinput",SCREEN[screen].textinput)
        EVENT:enqueue("resize",SCREEN[screen].onScreenResize)
    end
end



function SCREEN.mainScreen.draw()
    love.graphics.print("this works",0,0)

    for i,v in pairs(SCREEN.mainScreen.drawTbl) do
        v()
    end

end

function SCREEN.mainScreen.update()

    for i,v in pairs(SCREEN.mainScreen.updateTbl) do
        v()
    end

end

function SCREEN.mainScreen.textinput(text)

    for i,v in pairs(SCREEN.mainScreen.textinputTbl) do
        v(text)
    end

end

function SCREEN.mainScreen.onScreenResize()
    for i,v in pairs(SCREEN.mainScreen.resizeTbl) do
        v()
    end

end

---------------------------------------------------------------
ConnectBlock = {
    x = 0,
    y = 0,
    w = 450,
    h = 200,

    color = {0.7,0.7,0.7,1},

    ipField = {
        text = "",
        isActive = false,
        color = {0.4,0.4,0.4,1},
        textColor = {1,1,1,1},
        x = 100,
        y = 100,
        w = 240,
        h = 22,

        lastSub = love.timer.getTime()*1000
    },
    portField = {
        text = "",
        isActive = false,
        color = {0.4,0.4,0.4,1},
        textColor = {1,1,1,1},
        x = 350,
        y = 100,
        w = 70,
        h = 22,

        lastSub = love.timer.getTime()*1000
    },
}
ConnectBlock.x = love.graphics.getWidth()/2 - ConnectBlock.w/2
ConnectBlock.y = love.graphics.getHeight()/3

ConnectBlock.draw = function()
    love.graphics.reset()
    love.graphics.setColor(ConnectBlock.color)
    love.graphics.rectangle("fill", ConnectBlock.x, ConnectBlock.y, ConnectBlock.w, ConnectBlock.h)

    ConnectBlock.ipField.draw()
    ConnectBlock.portField.draw()
end
ConnectBlock.update = function()
    ConnectBlock.ipField.update()
    ConnectBlock.portField.update()
end
ConnectBlock.textinput = function(text)
    ConnectBlock.ipField.textinput(text)
    ConnectBlock.portField.textinput(text)
end
ConnectBlock.resize = function()
    ConnectBlock.x = love.graphics.getWidth()/2 - ConnectBlock.w/2
    ConnectBlock.y = love.graphics.getHeight()/3
end

ConnectBlock.ipField.update = function()
    local mx,my = love.mouse.getPosition()
    local x = ConnectBlock.x + ConnectBlock.ipField.x
    local y = ConnectBlock.y + ConnectBlock.ipField.y
    local w = ConnectBlock.ipField.w
    local h = ConnectBlock.ipField.h
    local hover = false
    if mx >= x and mx <= x+w and my >= y and my <= y+h then
        hover = true
    end

    if hover and love.mouse.isDown(1) then
        ConnectBlock.ipField.isActive = true
    elseif ConnectBlock.ipField.isActive and not hover and love.mouse.isDown(1) then
        ConnectBlock.ipField.isActive = false
    end

    if ConnectBlock.ipField.isActive and love.keyboard.isDown("backspace") and (love.timer.getTime()*1000) - ConnectBlock.ipField.lastSub >= 110 then
        ConnectBlock.ipField.lastSub = love.timer.getTime()*1000
        ConnectBlock.ipField.text = ConnectBlock.ipField.text:sub( 1, #ConnectBlock.ipField.text - 1 ) -- limits string from the first to the second last character
    end
end
ConnectBlock.ipField.draw = function()
    love.graphics.reset()
    love.graphics.setColor(ConnectBlock.ipField.color)
    local x = ConnectBlock.x + ConnectBlock.ipField.x
    local y = ConnectBlock.y + ConnectBlock.ipField.y
    love.graphics.rectangle("fill", x, y, ConnectBlock.ipField.w, ConnectBlock.ipField.h)
    love.graphics.setColor(ConnectBlock.ipField.textColor)
    love.graphics.printf("Server Address: "..ConnectBlock.ipField.text, x, y, ConnectBlock.ipField.w)
    --love.graphics.printf(ConnectBlock.ipField.text, x, y, ConnectBlock.ipField.w)
end
ConnectBlock.ipField.textinput = function(text)
    if ConnectBlock.ipField.isActive then
        if (type(tonumber(text)) == "number" or text == ".") and #ConnectBlock.ipField.text <= 14 then
            ConnectBlock.ipField.text = ConnectBlock.ipField.text .. text
        end
    end
end
--------------------

ConnectBlock.portField.update = function()
    local mx,my = love.mouse.getPosition()
    local x = ConnectBlock.x + ConnectBlock.portField.x
    local y = ConnectBlock.y + ConnectBlock.portField.y
    local w = ConnectBlock.portField.w
    local h = ConnectBlock.portField.h
    local hover = false
    if mx >= x and mx <= x+w and my >= y and my <= y+h then
        hover = true
    end

    if hover and love.mouse.isDown(1) then
        ConnectBlock.portField.isActive = true
    elseif ConnectBlock.portField.isActive and not hover and love.mouse.isDown(1) then
        ConnectBlock.portField.isActive = false
    end

    if ConnectBlock.portField.isActive and love.keyboard.isDown("backspace") and (love.timer.getTime()*1000) - ConnectBlock.portField.lastSub >= 110 then
        ConnectBlock.portField.lastSub = love.timer.getTime()*1000
        ConnectBlock.portField.text = ConnectBlock.portField.text:sub( 1, #ConnectBlock.portField.text - 1 ) -- limits string from the first to the second last character
    end
end
ConnectBlock.portField.draw = function()
    love.graphics.reset()
    love.graphics.setColor(ConnectBlock.portField.color)
    local x = ConnectBlock.x + ConnectBlock.portField.x
    local y = ConnectBlock.y + ConnectBlock.portField.y
    love.graphics.rectangle("fill", x, y, ConnectBlock.portField.w, ConnectBlock.portField.h)
    love.graphics.setColor(ConnectBlock.portField.textColor)
    love.graphics.printf(" : "..ConnectBlock.portField.text, x, y, ConnectBlock.portField.w)
    --love.graphics.printf(ConnectBlock.ipField.text, x, y, ConnectBlock.ipField.w)
end
ConnectBlock.portField.textinput = function(text)
    if ConnectBlock.portField.isActive then
        if (type(tonumber(text)) == "number") and #ConnectBlock.portField.text <= 4 then
            ConnectBlock.portField.text = ConnectBlock.portField.text .. text
        end
    end
end

-----------------

table.insert(SCREEN.mainScreen.updateTbl, ConnectBlock.update)
table.insert(SCREEN.mainScreen.drawTbl, ConnectBlock.draw)
table.insert(SCREEN.mainScreen.textinputTbl, ConnectBlock.textinput)
table.insert(SCREEN.mainScreen.resizeTbl, ConnectBlock.resize)



SCREEN:open("mainScreen")
