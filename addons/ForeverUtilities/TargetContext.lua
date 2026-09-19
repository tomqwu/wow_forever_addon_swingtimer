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
