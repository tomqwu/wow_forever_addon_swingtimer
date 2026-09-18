local _, NS = ...
local Core = NS.Core
local Range = {}
NS.Range = Range
local colors = { melee={1,0.65,0.15}, close={1,0.3,0.1}, shoot={0.2,1,0.35},
    far={1,0.15,0.2}, unknown={0.6,0.6,0.6} }
local function Call(fn, ...)
    if type(fn) ~= 'function' then return nil end
    local ok, value = pcall(fn, ...)
    if ok and Core.IsReadable(value) then return value end
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
    if low >= high then return 'unknown', 'Range unknown' end
    local yards = 'Range unknown'
    if measured then
        if high == math.huge then yards = string.format('>%g yd',low)
        elseif low == 0 then yards = string.format('<=%g yd',high)
        else yards = string.format('~%g-%g yd',low,high) end
    end
    local labels = {melee='Melee',close='Too close',shoot='Shooting',far='Too far',unknown='Uncertain'}
    return state, labels[state] .. ' | ' .. yards
end
function Range.Create(host, db)
    local frame = CreateFrame('Frame', 'ForeverUtilitiesIndicator', host)
    frame:SetSize(300,24)
    frame:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    local icon = frame:CreateTexture(nil,'ARTWORK')
    icon:SetSize(22,22); icon:SetPoint('LEFT')
    icon:SetTexture('Interface\\Icons\\Ability_Marksmanship')
    local label = frame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    label:SetPoint('LEFT',icon,'RIGHT',7,0)
    local spells, shot, elapsed = {}, nil, 0
    local function Discover()
        spells, shot = {}, nil
        if not C_SpellBook or not C_Spell or not Enum.SpellBookSpellBank then return end
        local count = Call(C_SpellBook.GetNumSpellBookSkillLines)
        if not Core.IsNumber(count) then return end
        local seen = {}
        for line=1,count do
            local info = Call(C_SpellBook.GetSpellBookSkillLineInfo,line)
            if type(info)=='table' and Core.IsNumber(info.itemIndexOffset) and Core.IsNumber(info.numSpellBookItems) then
                for slot=info.itemIndexOffset+1,info.itemIndexOffset+info.numSpellBookItems do
                    local item=Call(C_SpellBook.GetSpellBookItemInfo,slot,Enum.SpellBookSpellBank.Player)
                    local id=type(item)=='table' and item.spellID
                    if Core.IsNumber(id) and not seen[id] and Call(C_SpellBook.IsSpellKnown,id)==true then
                        seen[id]=true
                        local data=Call(C_Spell.GetSpellInfo,id)
                        if type(data)=='table' and Core.IsNumber(data.minRange) and Core.IsNumber(data.maxRange)
                            and data.minRange>=0 and data.maxRange>data.minRange then
                            local p={id=id,min=data.minRange,max=data.maxRange}
                            if Call(C_Spell.IsRangedAutoAttackSpell,id)==true then
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
        local c=colors[state]; icon:SetVertexColor(unpack(c)); label:SetTextColor(unpack(c)); label:SetText(text)
    end
    local function Update()
        local probes={}
        for _,p in ipairs(spells) do
            probes[#probes+1]={min=p.min,max=p.max,inside=Call(C_Spell.IsSpellInRange,p.id,'target')}
        end
        local types=Enum and Enum.PlayerSwingType
        local api=C_SwingTimer and C_SwingTimer.IsTargetWithinSwingRange
        local melee=types and Call(api,types.MainHand)
        local ranged=types and Call(api,types.Ranged)
        -- Auto Shot metadata only bounds yards when its own range check succeeds.
        if shot then probes[#probes+1]={min=shot.min,max=shot.max,inside=Call(C_Spell.IsSpellInRange,shot.id,'target')} end
        Paint(Range.Measure(probes,melee,ranged,shot))
    end
    local function Refresh()
        frame:SetScript('OnUpdate',nil)
        frame:SetShown(db.enabled)
        if not db.enabled then return end
        if Call(UnitExists,'target')~=true then Paint('unknown','No target'); return end
        if Call(UnitCanAttack,'player','target')~=true or Call(UnitIsDead,'target')~=false then
            Paint('unknown','No attackable target'); return
        end
        Update(); elapsed=0
        frame:SetScript('OnUpdate',function(_,delta)
            elapsed=elapsed+delta
            if elapsed>=0.15 then
                elapsed=0
                if Call(UnitExists,'target')~=true or Call(UnitCanAttack,'player','target')~=true
                    or Call(UnitIsDead,'target')~=false then Refresh() else Update() end
            end
        end)
    end
    frame:SetScript('OnEvent',function(_,event,unit)
        if event=='UNIT_FLAGS' and (not Core.IsReadable(unit) or unit~='target') then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then
            frame:SetScript('OnUpdate',nil); Paint('unknown','Range inactive'); return
        end
        if event=='SPELLS_CHANGED' or event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_EQUIPMENT_CHANGED' then Discover() end
        Refresh()
    end)
    for _,event in ipairs({'PLAYER_TARGET_CHANGED','SPELLS_CHANGED','PLAYER_ENTERING_WORLD',
        'PLAYER_LEAVING_WORLD','PLAYER_DEAD','PLAYER_EQUIPMENT_CHANGED','UNIT_FLAGS'}) do frame:RegisterEvent(event) end
    frame.Refresh=Refresh
    Discover(); Refresh()
    return frame
end
