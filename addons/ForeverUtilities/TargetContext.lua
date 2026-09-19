local _, NS = ...
local Core = NS.Core
local Context = {}
NS.TargetContext = Context
local function Call(fn,...)
    if type(fn)~='function' then return nil end
    local ok,value=pcall(fn,...)
    if ok and Core.IsReadable(value) then return value end
end
function Context.TargetTarget()
    local exists=Call(UnitExists,'targettarget')
    if exists==false then return 'Target of target: None' end
    if exists~=true then return 'Target of target: Unavailable' end
    if Call(UnitIsUnit,'targettarget','player')==true then return 'Target of target: YOU' end
    local name=Call(UnitName,'targettarget')
    if type(name)~='string' or name=='' then return 'Target of target: Unavailable' end
    -- Names are plain text, not addon-generated hyperlinks or color escapes.
    name=name:gsub('|','||'):gsub('[\r\n]',' ')
    return 'Target of target: '..name
end
-- UnitPosition axes: +X north, +Y west. Facing increases counterclockwise.
-- Positive difference means turn left. This is horizontal geometry, not cast eligibility.
function Context.Angle(px,py,tx,ty,facing)
    if not Core.IsNumber(px) or not Core.IsNumber(py) or not Core.IsNumber(tx)
        or not Core.IsNumber(ty) or not Core.IsNumber(facing) then return nil end
    local dx,dy=tx-px,ty-py
    if not Core.IsNumber(dx) or not Core.IsNumber(dy) or (dx==0 and dy==0) then return nil end
    local bearing=math.atan2(dy,dx)
    local delta=(bearing-facing+math.pi)%(2*math.pi)-math.pi
    return math.deg(delta)
end
function Context.ReadAngle()
    local facing=Call(GetPlayerFacing)
    if not Core.IsNumber(facing) or type(UnitPosition)~='function' then return nil end
    local ok,px,py,_,map=pcall(UnitPosition,'player')
    local okTarget,tx,ty,_,targetMap=pcall(UnitPosition,'target')
    if not ok or not okTarget or not Core.IsNumber(map) or not Core.IsNumber(targetMap)
        or map<0 or targetMap<0 or map~=targetMap then return nil end
    return Context.Angle(px,py,tx,ty,facing)
end
function Context.AngleText()
    local angle=Context.ReadAngle()
    if not Core.IsNumber(angle) then return 'Angle unavailable' end
    local degrees=math.floor(math.abs(angle)+0.5)
    if degrees==0 then return 'Angle: 0° (straight ahead)' end
    if degrees==180 then return 'Angle: 180° (behind)' end
    return string.format('Angle: %d° %s',degrees,angle>0 and 'left' or 'right')
end
function Context.Height(db)
    return 56
end

-- Count the selected ammo type carried by the player, excluding all bank storage.
function Context.AmmoCount()
    local slot=Call(GetInventorySlotInfo,'AmmoSlot')
    if not Core.IsNumber(slot) or slot<0 then return nil end
    if type(GetInventoryItemID)~='function' then return nil end
    local ok,id=pcall(GetInventoryItemID,'player',slot)
    if not ok or not Core.IsReadable(id) then return nil end
    if id==nil then
        if type(UnitClass)=='function' then
            local classOK,_,class=pcall(UnitClass,'player')
            if classOK and Core.IsReadable(class) and class=='HUNTER' then return 0 end
        end
        return nil
    end
    if not Core.IsNumber(id) or id<=0 then return nil end
    local count=Call(C_Item and C_Item.GetItemCount or GetItemCount,id,false,false,false,false)
    if not Core.IsNumber(count) or count<0 then return nil end
    return math.floor(count)
end

function Context.PetNeedsMend(unit)
    if Call(UnitIsUnit,unit,'pet')~=true or Call(UnitIsDead,'pet')~=false then return false end
    local health=Call(UnitHealth,'pet')
    local maximum=Call(UnitHealthMax,'pet')
    return Core.IsNumber(health) and Core.IsNumber(maximum)
        and maximum>0 and health>0 and health/maximum<=0.30
end

-- A missing result is only trustworthy after a fully readable harmful-aura scan.
function Context.MarkMissing(name)
    if not Core.IsReadable(name) or type(name)~='string' or name=='' then return nil end
    if Call(UnitCanAttack,'player','target')~=true or Call(UnitIsDead,'target')~=false then return false end
    local api=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(api)~='function' then return nil end
    local unknown=false
    for index=1,255 do
        local ok,aura=pcall(api,'target',index,'HARMFUL')
        if not ok or not Core.IsReadable(aura) then return nil end
        if aura==nil then if unknown then return nil end;return true end
        if type(aura)~='table' then return nil end
        if not Core.IsReadable(aura.name) or type(aura.name)~='string' then unknown=true
        elseif aura.name==name then return false end
    end
    return nil
end
