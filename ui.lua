UIDrawTable = {}
UITable = {}
GameUI = {}
local UI = {
    title = "",
    visible = false,
    x = 0,
    y = 0,
    w = 128,
    h = 128,
    alpha = 255,
    color = {255,255,255,255},
    background = {255,255,255,255},
    content = {},
}

function UI:new(o, f)
    o = o or {}
    if f == "content" then o.isContent = true end
    if not f then
        GameUI.uID = (GameUI.uID or 0)+1
        o.uID = GameUI.uID
    end
    setmetatable(o,self)
    self.__index = self
    self:Constructor()
    return o
end
function UI:Constructor()
    self.type = "Blank"
end
function UI:AddContent(cnt)
    cnt.parent = self
    cnt.margin = {}
    cnt.margin.x = 0
    cnt.margin.y = 0
    table.insert(self.content,cnt )
end

function UI:MainDraw()
    love.graphics.reset()
    love.graphics.setColor(self.background[1],self.background[2],self.background[3],self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end
function UI:Draw()
    self:MainDraw()

    if not self.isContent then
      for k,v in pairs(self.content) do
          v:Draw()
      end
    end

end


function UI:SetDimensions(x,y,w,h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function UI:SetVisible(f)
    if f == true then
        table.insert(UIDrawTable, self)
        self.visible = true
    elseif f == false then
        self.visible = false
    end -- needs more work here
end

function UI:isMouseHovering()
    --if love.mouse.getX() >= love.graphics.getWidth()-299 then return false end
    local minX,maxX,minY,maxY,mx,my
    minX=self.x
    maxX=self.x+self.w
    minY=self.y
    maxY=self.y+self.h
    mx = love.mouse.getX()
    my = love.mouse.getY()

    return mx>=minX and mx<=maxX and my>=minY and my<=maxY
end
function UI:Update()
    if self:isMouseHovering() and not self.hovered then
        MouseOnUI = true
        self.hovered = true
    elseif not self:isMouseHovering() and self.wasHovered then
        MouseOnUI = false
        self.hovered = false
    end
    if self.isContent then
        self.x = self.parent.x + self.margin.x
        self.y = self.parent.y + self.margin.y

    else
        for k,v in pairs(self.content) do
            v:Update()
        end
    end
    self:MainUpdate()
    self.wasHovered = self.hovered
end
function UI:MainUpdate()

end

function UI:OnScreenResize(w,h)

end

GameUI.mainClass = UI
-- Loads the UI elements from the path "UI/"
local lfs = love.filesystem
local filesTable = lfs.getDirectoryItems("UI")

for k, v in ipairs(filesTable) do
    local file = "UI/"..v
    if lfs.isFile(file) then
        local _,_,a,b = string.find(v, "(%a+).(%a+)")
        if b == "ui" then
            dofile(file)
        end
    end
end
--

local ui = GameUI.interface:new()
function ui:OnScreenResize(w,h)
    local x = love.graphics.getWidth()-300
    local height = love.graphics.getHeight()
    self:SetDimensions(x,0,300,height)
end
ui:OnScreenResize()
ui.title = "Main Interface"
ui.alpha = 175
ui.background = {0,0,0}

local content = GameUI.interface:new({},"content")
ui:AddContent(content)
-- A working example of content inside a UI element
UITable.MainInterface = ui
UITable["MainInterface"]:SetVisible(true)

UITable["MainInterface"]:AlignContent(1,"right")


local EntityViewer = GameUI.interface:new()













--
