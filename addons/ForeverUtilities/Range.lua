local _, NS = ...
local Core = NS.Core
local Range = {}
NS.Range = Range
local colors = { melee={1,0.65,0.15}, close={1,0.3,0.1}, shoot={0.2,1,0.35},
    far={1,0.15,0.2}, distance={0.3,0.8,1}, beyond={1,0.15,0.2}, out={1,0.15,0.2}, unknown={0.8,0.8,0.85} }
local function Call(fn, ...)
    if type(fn) ~= 'function' then return nil end
    local ok, value = pcall(fn, ...)
    if ok and Core.IsReadable(value) then return value end
end
-- A numeric result is usable only when the client explicitly validates it.
-- Enemy/instance restrictions commonly make this API unavailable.
function Range.ReadDistance(unit)
    if type(UnitDistanceSquared)~='function' then return nil end
    local ok,squared,checked=pcall(UnitDistanceSquared,unit)
    if not ok or not Core.IsReadable(checked) or checked~=true
        or not Core.IsNumber(squared) or squared<0 then return nil end
    return math.sqrt(squared)
end
function Range.WithDistance(state,text,yards)
    if not Core.IsNumber(yards) or yards<0 then return state,text end
    if state=='unknown' then state='distance' end
    local title=text:match('^(.-) | ')
    if not title then title='Distance' end
    return state,string.format('%s | %.1f yd',title,yards)
end
-- Spell checks supply effective range brackets, not exact center-to-center yards.
function Range.Measure(probes, melee, ranged, shot)
    local low, high, measured = 0, math.huge, false
    for _, p in ipairs(probes) do
        if Core.IsNumber(p.min) and Core.IsNumber(p.max) and p.max > 0
            and Core.IsReadable(p.inside) then
            if p.inside == true then
                low, high, measured = math.max(low,p.min), math.min(high,p.max), true
            elseif p.inside == false and p.min == 0 then
                low, measured = math.max(low,p.max), true
            end
        end
    end
    -- Native attack queries can be unavailable to addons. A readable Auto Shot
    -- check supplies the same classification without guessing from a nil result.
    if (not Core.IsReadable(ranged) or type(ranged)~='boolean') and shot
        and Core.IsReadable(shot.inside) and type(shot.inside)=='boolean' then
        ranged=shot.inside
    end
    local state = 'unknown'
    if Core.IsReadable(ranged) and ranged == true then state = 'shoot'
    elseif Core.IsReadable(melee) and melee == true then state = 'melee'
    elseif Core.IsReadable(ranged) and ranged == false and shot then
        if high <= shot.max and high < math.huge and shot.min > 0 then
            state, high = 'close', math.min(high,shot.min)
        elseif measured and low >= shot.min then
            state, low = 'far', math.max(low,shot.max)
        end
    end
    if low >= high then return 'unknown', 'Range unavailable' end
    -- A negative attack check is out of range even without Auto Shot metadata
    -- or enough information to distinguish too close from too far.
    if state=='unknown' and Core.IsReadable(ranged) and ranged==false then state='out' end
    if state=='unknown' and measured then
        state=high==math.huge and 'beyond' or 'distance'
    end
    local yards = 'yards unavailable'
    if measured then
        if high == math.huge then yards = string.format('>%g yd',low)
        elseif low == 0 then yards = string.format('<=%g yd',high)
        else yards = string.format('~%g-%g yd',low,high) end
    end
    local labels = {melee='Melee',close='Too close',shoot='Shooting',far='Too far',distance='Distance',beyond='Out of range',out='Out of range',unknown='Range unavailable'}
    if state=='unknown' then return state, labels[state] end
    return state, labels[state] .. ' | ' .. yards
end
function Range.Create(host, db)
    local frame = CreateFrame('Frame', 'ForeverUtilitiesIndicator', host)
    frame:SetSize(400,56)
    frame:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    -- Keep the readout legible against bright terrain and busy combat effects.
    local background = frame:CreateTexture(nil,'BACKGROUND')
    background:SetAllPoints(frame)
    background:SetColorTexture(0.015,0.02,0.03,0.92)
    local accent = frame:CreateTexture(nil,'ARTWORK',nil,0)
    accent:SetPoint('TOPLEFT',frame,'TOPLEFT',0,0)
    accent:SetPoint('BOTTOMLEFT',frame,'BOTTOMLEFT',0,0)
    accent:SetWidth(4)
    local iconBorder = frame:CreateTexture(nil,'ARTWORK',nil,0)
    iconBorder:SetSize(44,44); iconBorder:SetPoint('LEFT',frame,'LEFT',10,0)
    local icon = frame:CreateTexture(nil,'ARTWORK',nil,1)
    icon:SetSize(38,38); icon:SetPoint('CENTER',iconBorder,'CENTER',0,0)
    icon:SetTexture('Interface\\Icons\\Ability_Marksmanship')
    local label = frame:CreateFontString(nil,'OVERLAY','GameFontNormalLarge')
    label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',18,'OUTLINE')
    label:SetShadowColor(0,0,0,1)
    label:SetShadowOffset(1,-1)
    label:SetPoint('LEFT',iconBorder,'RIGHT',12,0)
    label:SetPoint('RIGHT',frame,'RIGHT',-12,0)
    label:SetJustifyH('LEFT')
    label:SetWordWrap(false)
    local spells, shot, elapsed = {}, nil, 0
    local function Discover()
        spells, shot = {}, nil
        if not C_SpellBook or not C_Spell or not Enum or not Enum.SpellBookSpellBank then return end
        local count = Call(C_SpellBook.GetNumSpellBookSkillLines)
        if not Core.IsNumber(count) then return end
        local seen = {}
        for line=1,count do
            local info = Call(C_SpellBook.GetSpellBookSkillLineInfo,line)
            if type(info)=='table' and Core.IsNumber(info.itemIndexOffset) and Core.IsNumber(info.numSpellBookItems) then
                for slot=info.itemIndexOffset+1,info.itemIndexOffset+info.numSpellBookItems do
                    local item=Call(C_SpellBook.GetSpellBookItemInfo,slot,Enum.SpellBookSpellBank.Player)
                    local id=type(item)=='table' and item.spellID
                    if Core.IsNumber(id) and not seen[id] and Core.IsReadable(item.isPassive)
                        and Core.IsReadable(item.isOffSpec) and not item.isPassive and not item.isOffSpec
                        and Call(C_SpellBook.IsSpellKnown,id)==true then
                        seen[id]=true
                        local data=Call(C_Spell.GetSpellInfo,id)
                        if type(data)=='table' and Core.IsNumber(data.minRange) and Core.IsNumber(data.maxRange)
                            and data.minRange>=0 and data.maxRange>data.minRange then
                            local p={id=id,slot=slot,min=data.minRange,max=data.maxRange}
                            if Call(C_SpellBook.IsRangedAutoAttackSpellBookItem,slot,Enum.SpellBookSpellBank.Player)==true
                                or Call(C_Spell.IsRangedAutoAttackSpell,id)==true then
                                shot=p
                                if Core.IsNumber(data.iconID) then icon:SetTexture(data.iconID) end
                            end
                            if Call(C_Spell.IsSpellHarmful,id)==true then spells[#spells+1]=p end
                        end
                    end
                end
            end
        end
    end
    local function Paint(state,text)
        local c=colors[state]
        icon:SetVertexColor(unpack(c))
        iconBorder:SetColorTexture(c[1],c[2],c[3],1)
        accent:SetColorTexture(c[1],c[2],c[3],1)
        label:SetTextColor(1,1,1,1)
        label:SetText(text)
    end
    local function SpellRange(p)
        local value=Call(C_SpellBook and C_SpellBook.IsSpellBookItemInRange,
            p.slot,Enum.SpellBookSpellBank.Player,'target')
        if type(value)=='boolean' then return value end
        return Call(C_Spell and C_Spell.IsSpellInRange,p.id,'target')
    end
    local lastStatus='Not checked'
    local function Update()
        local yards=Range.ReadDistance('target')
        if Call(UnitCanAttack,'player','target')~=true then
            local state,text=Range.WithDistance('unknown','Range unavailable',yards)
            if yards==nil and Call(UnitIsFriend,'player','target')==true then
                text='Friendly target\nDistance unavailable'
            end
            lastStatus='Numeric distance: '..(yards and 'available' or 'unavailable')..'; '..text
            Paint(state,text); return
        end
        local probes={}
        for _,p in ipairs(spells) do
            probes[#probes+1]={min=p.min,max=p.max,inside=SpellRange(p)}
        end
        local types=Enum and Enum.PlayerSwingType
        local api=C_SwingTimer and C_SwingTimer.IsTargetWithinSwingRange
        local melee=types and Call(api,types.MainHand)
        local ranged=types and Call(api,types.Ranged)
        -- Auto Shot metadata only bounds yards when its own range check succeeds.
        if shot then
            shot.inside=SpellRange(shot)
            probes[#probes+1]={min=shot.min,max=shot.max,inside=shot.inside}
        end
        local state,text=Range.Measure(probes,melee,ranged,shot)
        state,text=Range.WithDistance(state,text,yards)
        lastStatus='Numeric distance: '..(yards and 'available' or 'unavailable')..'; Spells: '..#spells..'; Auto Shot: '..(shot and 'found' or 'not found')
            ..'; native melee/ranged: '..tostring(melee)..'/'..tostring(ranged)..'; '..text
        Paint(state,text)
    end
    local active=false
    local rangeEvents={'PLAYER_TARGET_CHANGED','SPELLS_CHANGED','PLAYER_ENTERING_WORLD',
        'PLAYER_LEAVING_WORLD','PLAYER_DEAD','PLAYER_EQUIPMENT_CHANGED','UNIT_FLAGS'}
    local function Refresh()
        frame:SetScript('OnUpdate',nil)
        frame:SetShown(db.enabled)
        if not db.enabled then
            if active then for _,event in ipairs(rangeEvents) do frame:UnregisterEvent(event) end end
            active=false;lastStatus='Distance checker disabled'
            return
        end
        if not active then
            for _,event in ipairs(rangeEvents) do frame:RegisterEvent(event) end
            active=true;Discover()
        end
        local hasTarget=Call(UnitExists,'target')==true
        frame:SetAlpha((hasTarget or db.locked==false) and 1 or 0.2)
        if not hasTarget then Paint('unknown','No target'); return end
        if Call(UnitIsDead,'target')~=false then
            Paint('unknown','Target dead or unavailable'); return
        end
        Update(); elapsed=0
        frame:SetScript('OnUpdate',function(_,delta)
            elapsed=elapsed+delta
            if elapsed>=0.15 then
                elapsed=0
                if Call(UnitExists,'target')~=true or Call(UnitIsDead,'target')~=false then Refresh() else Update() end
            end
        end)
    end
    frame:SetScript('OnEvent',function(_,event,unit)
        if not db.enabled then return end
        if event=='UNIT_FLAGS' and (not Core.IsReadable(unit) or unit~='target') then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then
            frame:SetScript('OnUpdate',nil); Paint('unknown','Range inactive'); return
        end
        if event=='SPELLS_CHANGED' or event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_EQUIPMENT_CHANGED' then Discover() end
        Refresh()
    end)
    frame.Status=function() return lastStatus end
    frame.Refresh=Refresh
    Refresh()
    return frame
end
