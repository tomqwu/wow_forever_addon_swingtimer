local addon, NS = ...
local Core = NS.Core
local defaults = { x = 0, y = -160, width = 300, height = 24, scale = 1,
    locked = true, offhand = false, cue = 0, oocalpha = 0.15, hunterrange = true }
local db, host, bars, supported, reason, preview
local inCombat, fader, opacity, fadeTarget = false, nil, 1, nil
local eventCount = 0
local hunterRange
local mainHand, offHand
local events = CreateFrame("Frame")
local function Say(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcf66ForeverSwing:|r " .. message)
end
local function Number(value, fallback, low, high)
    if not Core.IsNumber(value) then return fallback end
    return math.max(low, math.min(high, value))
end
local function Normalize()
    if type(ForeverSwingDB) ~= "table" then ForeverSwingDB = {} end
    db = ForeverSwingDB
    -- Forever's Twist of Light uses a next-attack Echo, not a 0.4s catch.
    -- Remove the previously promoted 0.4s cue once, keeping other custom values.
    -- After this migration, even an explicitly chosen 0.4s cue survives reload.
    if db.cuePolicyVersion ~= 1 then
        if db.cue == 0.4 then db.cue = 0 end
        db.cuePolicyVersion = 1
    end
    db.cueConfigured = nil
    for key, value in pairs(defaults) do
        if type(db[key]) ~= type(value) then db[key] = value end
    end
    db.x = Number(db.x, 0, -5000, 5000)
    db.y = Number(db.y, -160, -5000, 5000)
    db.width = Number(db.width, 300, 120, 800)
    db.height = Number(db.height, 24, 16, 60)
    db.scale = Number(db.scale, 1, 0.5, 2)
    db.cue = Number(db.cue, 0, 0, 3)
    db.oocalpha = Number(db.oocalpha, 0.15, 0, 1)
end
-- Separate fade updates from swing updates so leaving combat can clear timing
-- without interrupting the fade. The updater stops once its target is reached.
local function UpdateOpacity(immediate)
    if not fader then return end
    local target = (inCombat or preview or not db.locked) and 1 or db.oocalpha
    if immediate or target == 1 then
        fader:SetScript("OnUpdate", nil)
        fadeTarget, opacity = nil, target
        host:SetAlpha(opacity)
        return
    end
    if fadeTarget == target then return end
    fader:SetScript("OnUpdate", nil)
    fadeTarget = nil
    if opacity == target then return end
    local start, elapsed = opacity, 0
    fadeTarget = target
    fader:SetScript("OnUpdate", function(self, delta)
        elapsed = math.min(0.35, elapsed + delta)
        opacity = start + (target - start) * (elapsed / 0.35)
        host:SetAlpha(opacity)
        if elapsed >= 0.35 then
            fadeTarget = nil
            self:SetScript("OnUpdate", nil)
        end
    end)
end
local function ReadCombatState()
    local ok, value = pcall(UnitAffectingCombat, "player")
    -- If the client restricts this query, stay visible until a combat-end event.
    inCombat = not ok or not Core.IsReadable(value) or value == true
end
local function Idle(bar, text)
    bar.state = {}
    bar.fill:SetValue(0)
    bar.time:SetText(text or "Ready")
    bar.marker:Hide()
    bar.zone:Hide()
    bar.cueLabel:Hide()
    bar.fill:SetStatusBarColor(0.85, 0.66, 0.22)
end
local function Layout()
    host:SetScale(db.scale)
    host:SetSize(db.width, db.height * (db.offhand and 2 or 1) + (db.offhand and 5 or 0))
    host:ClearAllPoints()
    host:SetPoint("CENTER", UIParent, "CENTER", db.x, db.y)
    host:EnableMouse(not db.locked)
    for i, bar in ipairs(bars) do
        bar.fill:SetSize(db.width, db.height)
        bar.fill:ClearAllPoints()
        bar.fill:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -(i - 1) * (db.height + 5))
        bar.fill:SetShown(i == 1 or db.offhand)
    end
    host.hint:SetText(db.locked and "" or "Drag to move  |  /fswing lock")
    UpdateOpacity()
    if hunterRange then hunterRange.Refresh() end
end
local function NewBar(label)
    local fill = CreateFrame("StatusBar", nil, host)
    fill:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    fill:SetMinMaxValues(0, 1)
    local bg = fill:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.035, 0.035, 0.05, 0.88)
    local title = fill:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetDrawLayer("OVERLAY", 3)
    title:SetPoint("LEFT", 7, 0)
    title:SetText(label)
    local time = fill:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    time:SetDrawLayer("OVERLAY", 3)
    time:SetPoint("RIGHT", -7, 0)
    local zone = fill:CreateTexture(nil, "OVERLAY", nil, 0)
    zone:SetColorTexture(0.1, 1, 0.35, 0.5)
    local marker = fill:CreateTexture(nil, "OVERLAY", nil, 1)
    marker:SetColorTexture(0.65, 1, 0.75, 1)
    marker:SetWidth(3)
    local cueLabel = fill:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cueLabel:SetDrawLayer("OVERLAY", 3)
    cueLabel:SetPoint("BOTTOM", marker, "TOP", 0, 2)
    cueLabel:SetTextColor(0.65, 1, 0.75)
    local bar = { fill = fill, time = time, marker = marker, zone = zone, cueLabel = cueLabel, state = {} }
    Idle(bar, "Waiting for swing")
    return bar
end
local function Clear(text)
    if not bars then return end
    preview = false
    UpdateOpacity()
    for _, bar in ipairs(bars) do Idle(bar, text) end
    host:SetScript("OnUpdate", nil)
end
local function Render()
    local now, active = GetTime(), false
    for i, bar in ipairs(bars) do
        local remaining, fraction = Core.Sample(bar.state, now)
        if remaining then
            active = true
            bar.fill:SetValue(fraction)
            bar.time:SetFormattedText(preview and "Demo %.1f" or "%.1f", remaining)
            local cue = db.cue
            if cue > 0 and cue < bar.state.duration then
                bar.marker:ClearAllPoints()
                bar.marker:SetPoint("TOPLEFT", bar.fill, "TOPLEFT", db.width * (1 - cue / bar.state.duration), 0)
                bar.marker:SetHeight(db.height)
                bar.marker:Show()
                bar.zone:ClearAllPoints()
                bar.zone:SetPoint("TOPRIGHT", bar.fill, "TOPRIGHT", 0, 0)
                bar.zone:SetSize(db.width * cue / bar.state.duration, db.height)
                bar.zone:Show()
                bar.cueLabel:SetFormattedText("Cue %.1fs", cue)
                bar.cueLabel:Show()
            else bar.marker:Hide(); bar.zone:Hide(); bar.cueLabel:Hide() end
            if cue > 0 and remaining <= cue then
                bar.fill:SetStatusBarColor(0.2, 0.85, 0.48)
            else bar.fill:SetStatusBarColor(i == 1 and 0.85 or 0.35, 0.66, i == 1 and 0.22 or 0.9) end
        elseif bar.running then
            Idle(bar, "Ready")
        end
        bar.running = remaining ~= nil
    end
    if not active then
        preview = false
        UpdateOpacity()
        host:SetScript("OnUpdate", nil)
    end
end
local function Start(index, duration)
    local bar = bars[index]
    if Core.Start(bar.state, duration, GetTime()) then
        bar.running = true
        host:SetScript("OnUpdate", Render)
        Render()
    else
        Idle(bar, "Timing unavailable")
    end
end
local function UpdateRange()
    if not supported or preview or not C_SwingTimer.IsTargetWithinSwingRange then return end
    for i, bar in ipairs(bars) do
        local ok, inRange = pcall(C_SwingTimer.IsTargetWithinSwingRange, i == 1 and mainHand or offHand)
        -- Nil means unknown, not out of range. Never compare opaque values.
        if ok and Core.IsReadable(inRange) then
            bar.fill:SetAlpha(inRange == false and 0.45 or 1)
        else bar.fill:SetAlpha(1) end
    end
end
local function Initialize()
    Normalize()
    host = CreateFrame("Frame", "ForeverSwingFrame", UIParent)
    host:SetFrameStrata("MEDIUM")
    host:SetMovable(true)
    host:SetClampedToScreen(true)
    host:RegisterForDrag("LeftButton")
    host:SetScript("OnDragStart", function(self)
        if not db.locked then self:StartMoving() end
    end)
    host:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
        local cx, cy = UIParent:GetCenter()
        db.x, db.y = x - cx / scale, y - cy / scale
        Layout()
    end)
    host.hint = host:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    host.hint:SetPoint("BOTTOM", host, "TOP", 0, 5)
    bars = { NewBar("Main hand"), NewBar("Off hand") }
    fader = CreateFrame("Frame", nil, host)
    if NS.HunterRange and UnitClass then hunterRange = NS.HunterRange.Create(host, db) end
    ReadCombatState()
    UpdateOpacity(true)
    Layout()
    local types = Enum and Enum.PlayerSwingType
    if types and C_SwingTimer then
        mainHand, offHand = types.MainHand, types.OffHand
        local ok = pcall(events.RegisterEvent, events, "PLAYER_SWING")
        supported = ok and events:IsEventRegistered("PLAYER_SWING")
    end
    if not supported then
        reason = "Native PLAYER_SWING API unavailable or blocked"
        Clear("API unavailable")
        Say(reason .. ". /fswing status for diagnostics.")
    else
        Say("Loaded. /fswing unlock to move; /fswing for options.")
    end
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:RegisterEvent("PLAYER_DEAD")
    events:RegisterEvent("PLAYER_LEAVING_WORLD")
    events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("PLAYER_REGEN_DISABLED")
    -- Range queries are throttled during active timers; no shared range subscription is changed.
    local elapsed = 0
    local original = Render
    Render = function(self, delta)
        original()
        elapsed = elapsed + (delta or 0)
        if elapsed >= 0.15 then elapsed = 0; UpdateRange() end
    end
end

events:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addon then Initialize(); events:UnregisterEvent("ADDON_LOADED") end
    elseif event == "PLAYER_SWING" then
        local duration, kind = ...
        if not Core.IsReadable(kind) or not Core.IsReadable(duration) then
            reason = "Native swing payload restricted by client"
            Clear("Timing restricted")
            return
        end
        if kind ~= mainHand and kind ~= offHand then return end
        if kind == offHand and not db.offhand then return end
        if preview then Clear("Waiting for swing") end
        preview = false
        eventCount = eventCount + 1
        reason = nil
        Start(kind == mainHand and 1 or 2, duration)
        UpdateRange()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        UpdateOpacity()
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        Clear("Waiting for swing")
    elseif event == "PLAYER_ENTERING_WORLD" then
        ReadCombatState()
        Clear("Waiting for swing")
        UpdateOpacity(true)
        UpdateRange()
    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateRange()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = ...
        if Core.IsReadable(slot) and (slot == 16 or slot == 17) then Clear("Waiting for swing") end
    else
        Clear("Waiting for swing")
        UpdateRange()
    end
end)
events:RegisterEvent("ADDON_LOADED")

SLASH_FOREVERSWING1 = "/fswing"
SlashCmdList.FOREVERSWING = function(message)
    if not db then return end
    local command, arg = message:lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "unlock" then db.locked = false; Layout()
    elseif command == "lock" then db.locked = true; Layout()
    elseif command == "hunterrange" then
        if arg ~= "on" and arg ~= "off" then Say("Use /fswing hunterrange on|off"); return end
        db.hunterrange = arg == "on"; Layout()
    elseif command == "offhand" then
        if arg ~= "on" and arg ~= "off" then Say("Use /fswing offhand on|off"); return end
        db.offhand = arg == "on"; Clear("Waiting for swing"); Layout()
    elseif command == "cue" or command == "width" or command == "scale" or command == "oocalpha" then
        local value = tonumber(arg)
        local low, high = 0, 3
        if command == "width" then low, high = 120, 800
        elseif command == "scale" then low, high = 0.5, 2
        elseif command == "oocalpha" then low, high = 0, 1 end
        if not Core.IsNumber(value) or value < low or value > high then
            Say(command .. " must be between " .. low .. " and " .. high); return
        end
        db[command] = value; Layout()
        if command == "cue" then db.cuePolicyVersion = 1; Say("Personal cue: " .. value .. "s. Optional reference only; Twist of Light does not need a 0.4s catch.") end
    elseif command == "test" then
        Clear(); preview = true; UpdateOpacity()
        Start(1, 3.6)
        if db.offhand then Start(2, 2.4) end
        Say("One-cycle DEMO; real melee events replace it.")
    elseif command == "reset" then
        for key, value in pairs(defaults) do db[key] = value end
        Clear("Waiting for swing"); Layout()
    elseif command == "status" then
        local version, build, _, interface = GetBuildInfo()
        Say("v0.3.0 | client " .. tostring(version) .. " build " .. tostring(build) .. " interface " .. tostring(interface))
        Say("Native event: " .. (supported and "registered" or "unavailable") .. "; melee events: " .. eventCount)
        Say("Cue: " .. db.cue .. "s" .. (db.cue == 0 and " (off; recommended for Forever)" or " (custom reference)"))
        Say(reason or "No API restriction observed. Live combat validation still requires actual swings.")
    else
        Say("/fswing unlock | lock | test | reset | status")
        Say("/fswing hunterrange on|off")
        Say("/fswing offhand on|off | cue 0..3 | width 120..800 | scale 0.5..2 | oocalpha 0..1")
        Say("Cues default OFF. Twist of Light uses a next-attack Echo; no 0.4s catch required.")
    end
end
