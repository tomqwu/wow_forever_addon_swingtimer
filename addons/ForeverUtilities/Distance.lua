local _, NS = ...
local function Normalize(db)
    for key,default in pairs({x=0,y=-210,scale=1}) do
        if not NS.Core.IsNumber(db[key]) then db[key]=default end
    end
    db.x=math.max(-5000,math.min(5000,db.x))
    db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
NS.Hunter = {
    name="Forever - Hunter's Friend",
    description='Hunter range, ammunition, and target awareness.',
    defaults={enabled=true,locked=true,x=0,y=-210,scale=1,showTargetTarget=true,showAngle=true,showRange=true,showAmmo=true,lowAmmoWarning=true,petMendWarning=true,markWarning=true,fadeOutOfCombat=true}, normalize=Normalize,
    options={
        {key='locked',label='Lock indicator position',kind='toggle'},
        {key='scale',label='Indicator size',kind='number',min=0.5,max=2,step=0.1},
        {key='showTargetTarget',label='Show target-of-target portrait',kind='toggle'},
        {key='showAngle',label='Show facing angle',kind='toggle'},
        {key='showRange',label='Show range text and weapon icon',kind='toggle'},
        {key='showAmmo',label='Show ammo count',kind='toggle'},
        {key='lowAmmoWarning',label='Low-ammo warning (200 or fewer)',kind='toggle'},
        {key='petMendWarning',label='Pet portrait health warning (30%)',kind='toggle'},
        {key='markWarning',label="Hunter's Mark reminder icon",kind='toggle'},
        {key='fadeOutOfCombat',label='Dim outside combat',kind='toggle'},
    },
    create=function(db)
        local host=CreateFrame('Frame','ForeverUtilitiesDistanceFrame',UIParent)
        host:SetSize(400,NS.TargetContext.Height(db));host:SetFrameStrata('MEDIUM')
        host:SetMovable(true);host:SetClampedToScreen(true);host:RegisterForDrag('LeftButton')
        host.hint=host:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
        host.hint:SetPoint('BOTTOM',host,'TOP',0,4)
        local indicator=NS.Range.Create(host,db)
        local function Apply()
            host:SetShown(db.enabled)
            host:SetSize(400,NS.TargetContext.Height(db))
            host:SetScale(db.scale);host:ClearAllPoints()
            host:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
            host:EnableMouse(db.enabled and not db.locked)
            host.hint:SetText(db.locked and '' or 'Drag to move | /fhunter lock')
            indicator.Refresh()
        end
        host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then self:StartMoving() end end)
        host:SetScript('OnDragStop',function(self)
            self:StopMovingOrSizing()
            local x,y=self:GetCenter();local cx,cy=UIParent:GetCenter()
            local ratio=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
            db.x,db.y=x-cx/ratio,y-cy/ratio
            Apply()
        end)
        return {Apply=Apply,Status=indicator.Status}
    end,
}

local Hunter=NS.Hunter
function Hunter.Initialize(saved)
    local old=type(saved.modules)=='table' and saved.modules.distance or saved
    if type(saved.hunter)~='table' then
        saved.hunter={}
        if type(old)=='table' then
            for key in pairs(Hunter.defaults) do saved.hunter[key]=old[key] end
        end
    end
    Hunter.db=saved.hunter
    for key,value in pairs(Hunter.defaults) do
        if type(Hunter.db[key])~=type(value) then Hunter.db[key]=value end
    end
    saved.schemaVersion=2
    Hunter.Apply()
end
function Hunter.IsHunter()
    if type(UnitClass)~='function' then return false end
    local ok,_,class=pcall(UnitClass,'player')
    return ok and NS.Core.IsReadable(class) and class=='HUNTER'
end
function Hunter.Apply()
    Normalize(Hunter.db)
    if Hunter.IsHunter() and Hunter.db.enabled and not Hunter.instance then
        Hunter.instance=Hunter.create(Hunter.db)
    end
    if Hunter.instance then Hunter.instance.Apply() end
    if Hunter.changed then Hunter.changed() end
end
function Hunter.SetEnabled(enabled)
    Hunter.db.enabled=enabled;Hunter.Apply()
end
function Hunter.Reset()
    for key,value in pairs(Hunter.defaults) do Hunter.db[key]=value end
    Hunter.Apply()
end
