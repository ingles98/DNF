Camera = {
    distX = 0,
    distY = 0,
    scale = 1
}

Entities = {}
mainGrid = {}
gridLength = 30

Entity = {
    x = 0,
    y = 0,
    w = 64,
    h = 64,
    alpha = 0
}

MouseOnUI = false

function Entity:new(o, f)
    if not f then uID = (uID or 0)+1 end
    o = o or {}
    o.uID = uID
    setmetatable(o,self)
    self.__index = self
    self:constructor()
    return o
end

function Entity:constructor()
    self.type = "AIR"
end
function Entity:init()
    self.nb = {}
    local x,y
    local aX = self.x
    local aY = self.y - self.h/2
    for k,v in ipairs(Entities) do
        local minX,maxX,minY,maxY
        minX=v.x +1
        maxX=v.x+v.w -1
        minY=v.y +1
        maxY=v.y+v.h -1

        aX = self.x + self.w/2
        aY = self.y + self.h/2 - self.h
        if aX>=minX and aX<=maxX and aY>=minY and aY<=maxY then
            table.insert(self.nb, v.uID )
        end
        aX = self.x + self.w/2 - self.w
        aY = self.y + self.h/2
        if aX>=minX and aX<=maxX and aY>=minY and aY<=maxY then
            table.insert(self.nb, v.uID )
        end
        aX = self.x + self.w/2 + self.w
        aY = self.y + self.h/2
        if aX>=minX and aX<=maxX and aY>=minY and aY<=maxY then
            table.insert(self.nb, v.uID )
        end
        aX = self.x + self.w/2
        aY = self.y + self.h/2 + self.h
        if aX>=minX and aX<=maxX and aY>=minY and aY<=maxY then
            table.insert(self.nb, v.uID )
        end
    end

end

function Entity:OnMouseOver()
    if MouseOnUI then return false end
    local minX,maxX,minY,maxY,mx,my
    minX=self.x
    maxX=self.x+self.w
    minY=self.y
    maxY=self.y+self.h
    mx = (love.mouse.getX() +Camera.distX)/Camera.scale
    my = (love.mouse.getY() +Camera.distY)/Camera.scale

    return mx>=minX and mx<=maxX and my>=minY and my<=maxY
end

function Entity:MainUpdate()
    -- Main operations goes here (Unique to this class)
end
function Entity:Update()
    if self:OnMouseOver() and not self.hovered then
        print("Hovering: "..self.uID..", "..self.type)
        self.alpha = 155/255
        self.hovered = true
    elseif not self:OnMouseOver() and self.wasHovered then
        self.alpha = 0
        self.hovered = false
    end
    self:MainUpdate()
    self.wasHovered = self.hovered
end

function Entity:DrawHover()
    love.graphics.reset()
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.x + self.w, self.y + self.h)
end
function Entity:MainDraw()
    -- Graphics goes here.
end
function Entity:Draw()
    self:MainDraw()
    self:DrawHover()
end

GameEntity = {}
table.insert(GameEntity,Entity)

local lfs = love.filesystem
local filesTable = lfs.getDirectoryItems("Entities")

for k, v in ipairs(filesTable) do -- Loads any '.ent' and executes in "Entities" folder.
    local file = "Entities/"..v
    if lfs.getInfo(file,"file") then
        local _,_,a,b = string.find(v, "(%a+).(%a+)")
        if b == "ent" then
            dofile(file)
        end
    end
end


for i=1,gridLength -1 do
    mainGrid[i] = {}
    for j=1,gridLength +1 do
        mainGrid[i][j] = 1
        if i == 2 and j == 2 then mainGrid[i][j] = 2 end
        table.insert(Entities, GameEntity[mainGrid[i][j]]:new({x = Entity.w*j, y = Entity.h*i}))
    end
end

for k,v in ipairs(Entities) do
    v:init()
end
