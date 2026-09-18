local addon, NS = ...
local Core = NS.Core
local defaults = {x=0, y=-210, scale=1, locked=true, enabled=true}
local db, host, indicator
local events = CreateFrame('Frame')
local function Say(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff66ff88ForeverUtilities:|r '..text)
end
local function Normalize()
    if type(ForeverUtilitiesDB)~='table' then ForeverUtilitiesDB={} end
    db=ForeverUtilitiesDB
    for key,value in pairs(defaults) do
        if type(db[key])~=type(value) then db[key]=value end
    end
    for _,key in ipairs({'x','y','scale'}) do
        if not Core.IsNumber(db[key]) then db[key]=defaults[key] end
    end
    db.x=math.max(-5000,math.min(5000,db.x))
    db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
local function Layout()
    if not host then return end
    host:SetScale(db.scale)
    host:ClearAllPoints()
    host:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
    host:EnableMouse(not db.locked)
    host.hint:SetText(db.locked and '' or 'Drag to move | /futils lock')
    indicator.Refresh()
end
local function Initialize()
    Normalize()
    host=CreateFrame('Frame','ForeverUtilitiesFrame',UIParent)
    host:SetSize(400,56)
    host:SetFrameStrata('MEDIUM')
    host:SetMovable(true)
    host:SetClampedToScreen(true)
    host:RegisterForDrag('LeftButton')
    host:SetScript('OnDragStart',function(self) if not db.locked then self:StartMoving() end end)
    host:SetScript('OnDragStop',function(self)
        self:StopMovingOrSizing()
        local x,y=self:GetCenter()
        local cx,cy=UIParent:GetCenter()
        local ratio=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
        db.x,db.y=x-cx/ratio,y-cy/ratio
        Layout()
    end)
    host.hint=host:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    host.hint:SetPoint('BOTTOM',host,'TOP',0,4)
    indicator=NS.Range.Create(host,db)
    Layout()
    Say('Loaded. /futils unlock to move; /futils for options.')
end
events:RegisterEvent('ADDON_LOADED')
events:SetScript('OnEvent',function(self,_,name)
    if name==addon then Initialize();self:UnregisterEvent('ADDON_LOADED') end
end)
SLASH_FOREVERUTILITIES1='/futils'
SlashCmdList.FOREVERUTILITIES=function(message)
    if not db then return end
    local command,arg=message:lower():match('^%s*(%S*)%s*(.-)%s*$')
    if command=='unlock' then db.locked=false;db.enabled=true;Layout()
    elseif command=='lock' then db.locked=true;Layout()
    elseif command=='on' or command=='off' then db.enabled=command=='on';Layout()
    elseif command=='scale' then
        local n=tonumber(arg)
        if not Core.IsNumber(n) or n<0.5 or n>2 then Say('Scale must be 0.5 to 2.');return end
        db.scale=n;Layout()
    elseif command=='reset' then
        for key,value in pairs(defaults) do db[key]=value end
        Layout()
    elseif command=='status' then
        Say('v0.2.1 | '..(host and (db.enabled and 'enabled' or 'disabled') or 'unavailable'))
        if indicator and indicator.Status then Say(indicator.Status()) end
        Say('Yards are spell-range brackets, not exact distance. Live game validation pending.')
    else Say('/futils unlock | lock | on | off | scale 0.5..2 | reset | status') end
end
