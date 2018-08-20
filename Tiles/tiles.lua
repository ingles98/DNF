TILE = {
    x = 0,
    y = 0,
    color = {1,1,1,1},
    w = 64,
    h = 64,
    collide = false,
    list = {}
}

function TILE:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    self:constructor()
    return o
end

function TILE:constructor()
    self.type = "AIR"
end

sprites = {}

local lfs = love.filesystem
local filesTable = lfs.getDirectoryItems("Tiles")
for k, v in ipairs(filesTable) do
    local file = "Tiles/"..v
    if lfs.getInfo(file,"file") then
        local _,_,a,b = string.find(v, "(%a+).(%a+)")
        if b == "pk" then
            --dofile(file)
            local pk, _ = love.filesystem.newFileData( file )
            love.filesystem.mount(pk,"mount/tiles/"..a.."/")
            currentFile = a
            require("mount/tiles/"..a.."/main")
            currentFile = nil
            --table.insert(sprites, "mount/tiles/"..a.."/tile.png")
            --sprites[ ] = "mount/tiles/"..a.."/tile.png"
        end
    end
end

TileBatchImg = love.graphics.newArrayImage(sprites)
TileBatch = love.graphics.newSpriteBatch(TileBatchImg)

--generate random 10x10 map
TileMap = {}
for x=-5, 5 do
    TileMap[x] = {}
    for y=-5, 5 do
        TileMap[x][y] = {}
        TileMap[x][y]["id"] = 1--1+math.floor(love.math.random()*#sprites)
    end
end


function TileBatch_update()
    TileBatch:clear()
    for x,v in pairs(TileMap) do
        for y,vv in pairs(TileMap[x]) do
            TileBatch:addLayer(TileMap[x][y]["id"],x*TILE.w,y*TILE.h)
        end
    end
end

TileBatch_update()
TileBatch_update()
