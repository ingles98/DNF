
require 'init'
function love.update(dt)
    for k,v in pairs(UITable) do
        v:Update()
    end
    for k,v in pairs(Entities) do
        v:Update()
    end

    if love.keyboard.isDown("up") then
        Camera.distY =Camera.distY - 8
    end
    if love.keyboard.isDown("down") then
        Camera.distY = Camera.distY +8
    end
    if love.keyboard.isDown("left") then
        Camera.distX = Camera.distX -8
    end
    if love.keyboard.isDown("right") then
        Camera.distX = Camera.distX +8
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-Camera.distX,-Camera.distY)
    love.graphics.scale(Camera.scale)
    love.graphics.setColor(50/255,175/255,50/255,255/255)
    love.graphics.rectangle("fill", 64, 64, (gridLength+1)*Entity.w, (gridLength-1)*Entity.h)

    for k,v in ipairs(Entities) do
        v:Draw()
    end
    love.graphics.pop()
    for k,v in ipairs(UIDrawTable) do
        v:Draw()
    end

end

function love.keypressed(key, scancode, isrepeat)
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

function love.resize(w, h)
    for k,v in pairs(UITable) do
        v:OnScreenResize(w,h)
    end
end
