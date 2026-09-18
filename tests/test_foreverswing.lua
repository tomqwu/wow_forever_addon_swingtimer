local root = 'ForeverSwing/'
local count = 0
local function check(condition, label)
    assert(condition, label); count = count + 1
end
local secret = setmetatable({}, {__lt=function() error('secret comparison') end,
    __le=function() error('secret comparison') end, __add=function() error('secret arithmetic') end})
issecretvalue = function(v) return rawequal(v, secret) end
local NS = {}
assert(loadfile(root .. 'Core.lua'))('ForeverSwing', NS)
local state = {}
check(NS.Core.Start(state, 3.6, 10), 'valid start')
local left, fraction = NS.Core.Sample(state, 11.8)
check(math.abs(left - 1.8) < 0.001 and math.abs(fraction - 0.5) < 0.001, 'midpoint')
check(NS.Core.Sample(state, 14) == nil and state.finish == nil, 'expiry stops')
for _, value in ipairs({0, -1, 121, math.huge, -math.huge, 0/0, '3', secret}) do
    check(not NS.Core.Start(state, value, 0), 'reject invalid duration')
end
local function run(blocked, saved, initOnly)
    local frames, clock, range = {}, 0, nil
    local methods = {}
    local function object()
        return setmetatable({scripts={}, events={}, shown=true}, {__index=methods})
    end
    function methods:SetScript(key, fn) self.scripts[key] = fn end
    function methods:RegisterEvent(event)
        if blocked and event == 'PLAYER_SWING' then error('blocked') end
        self.events[event] = true
    end
    function methods:IsEventRegistered(e) return self.events[e] end
    function methods:UnregisterEvent(e) self.events[e] = nil end
    function methods:CreateTexture(_, layer, _, sublayer) local t=object(); t.layer=layer; t.sublayer=sublayer; self.textures=rawget(self,'textures') or {}; table.insert(self.textures,t); return t end
    function methods:CreateFontString() return object() end
    function methods:SetText(v) self.text = v end
    function methods:SetFormattedText(fmt, ...) self.text = string.format(fmt, ...) end
    function methods:SetValue(v) self.value = v end
    function methods:SetShown(v) self.shown = v end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    function methods:SetAlpha(v) self.alpha = v end
    function methods:GetCenter() return 0, 0 end
    function methods:GetEffectiveScale() return 1 end
    setmetatable(methods, {__index=function() return function() end end})
    CreateFrame = function(_, name)
        local f = object(); frames[#frames+1] = f
        if name then _G[name] = f end
        return f
    end
    UIParent = object()
    DEFAULT_CHAT_FRAME = {AddMessage=function() end}
    GetTime = function() return clock end
    UnitAffectingCombat = function() return false end
    GetBuildInfo = function() return '1.60.1', '69893', '', 16001 end
    Enum = {PlayerSwingType={MainHand=0, OffHand=1, Ranged=2}}
    C_SwingTimer = {IsTargetWithinSwingRange=function() return range end}
    SlashCmdList = {}
    ForeverSwingDB = saved or {width=0/0, cue=math.huge}
    assert(loadfile(root .. 'ForeverSwing.lua'))('ForeverSwing', NS)
    local eventFrame = frames[1]
    local function event(name, ...) eventFrame.scripts.OnEvent(eventFrame, name, ...) end
    event('ADDON_LOADED', 'ForeverSwing')
    local host, main, off = frames[2], frames[3], frames[4]
    if initOnly then return ForeverSwingDB.cue, ForeverSwingDB.cueConfigured end
    check(ForeverSwingDB.width == 300 and ForeverSwingDB.cue == 0.4, 'sanitize saved values')
    if blocked then
        check(not eventFrame.events.PLAYER_SWING, 'blocked event handled')
        check(host.scripts.OnUpdate == nil, 'blocked API no fake timer')
        SlashCmdList.FOREVERSWING('status')
        return
    end
    local fader = frames[5]
    check(host.alpha == 0.15, 'starts dimmed outside combat')
    event('PLAYER_REGEN_DISABLED')
    check(host.alpha == 1, 'combat restores visibility immediately')
    event('PLAYER_REGEN_ENABLED')
    fader.scripts.OnUpdate(fader, 0.175)
    check(host.alpha < 1 and host.alpha > 0.15, 'smooth intermediate fade')
    event('PLAYER_REGEN_DISABLED')
    check(host.alpha == 1 and fader.scripts.OnUpdate == nil, 'combat interrupts fade')
    event('PLAYER_REGEN_ENABLED')
    fader.scripts.OnUpdate(fader, 0.35)
    check(math.abs(host.alpha - 0.15) < 0.001 and fader.scripts.OnUpdate == nil, 'fade stops at idle opacity')
    SlashCmdList.FOREVERSWING('unlock')
    check(host.alpha == 1, 'unlock restores visibility')
    SlashCmdList.FOREVERSWING('lock')
    fader.scripts.OnUpdate(fader, 0.35)
    SlashCmdList.FOREVERSWING('test')
    check(host.alpha == 1, 'preview restores visibility')
    event('PLAYER_REGEN_ENABLED')
    SlashCmdList.FOREVERSWING('oocalpha 0')
    fader.scripts.OnUpdate(fader, 0.35)
    check(host.alpha == 0, 'optional fully transparent idle')
    SlashCmdList.FOREVERSWING('oocalpha 0.15')
    fader.scripts.OnUpdate(fader, 0.35)
    check(eventFrame.events.PLAYER_SWING, 'native event registered')
    check(not eventFrame.events.COMBAT_LOG_EVENT_UNFILTERED, 'no combat log')
    event('PLAYER_SWING', 3.6, 2)
    check(host.scripts.OnUpdate == nil, 'ranged ignored')
    event('PLAYER_SWING', 3.6, 0)
    check(host.scripts.OnUpdate ~= nil, 'main-hand timer started')
    check(main.textures[2].shown and main.textures[3].shown, 'reference zone and line visible')
    check(main.textures[2].layer == 'OVERLAY' and main.textures[3].sublayer == 1, 'cue renders above fill')
    SlashCmdList.FOREVERSWING('cue 0')
    host.scripts.OnUpdate(host, 0.1)
    check(not main.textures[2].shown and not main.textures[3].shown, 'cue off hides zone and line')
    SlashCmdList.FOREVERSWING('cue 0.4')
    clock = 1.8; host.scripts.OnUpdate(host, 0.2)
    check(math.abs(main.value - 0.5) < 0.001, 'UI follows native duration')
    event('PLAYER_TARGET_CHANGED')
    check(host.scripts.OnUpdate ~= nil, 'target change does not restart timer')
    event('PLAYER_SWING', 2, 1)
    check(off.value == 0, 'offhand ignored by default')
    range = secret; event('PLAYER_TARGET_CHANGED')
    check(main.alpha == 1, 'secret range not inspected')
    range = false; event('PLAYER_TARGET_CHANGED')
    check(main.alpha == 0.45, 'out of range dims')
    range = nil; event('PLAYER_TARGET_CHANGED')
    check(main.alpha == 1, 'unknown range not treated as false')
    event('PLAYER_SWING', secret, 0)
    check(host.scripts.OnUpdate == nil, 'secret duration stops all timers')
    event('PLAYER_SWING', 3, secret)
    check(host.scripts.OnUpdate == nil, 'secret hand stops safely')
    event('PLAYER_SWING', 2, 0)
    clock = 4; host.scripts.OnUpdate(host, 0.2)
    check(host.scripts.OnUpdate == nil, 'no speculative repeated cycles')
    SlashCmdList.FOREVERSWING('offhand on')
    check(off.shown, 'offhand enabled')
    event('PLAYER_SWING', 2.4, 1)
    clock = 5.2; host.scripts.OnUpdate(host, 0.2)
    check(math.abs(off.value - 0.5) < 0.001, 'independent offhand')
    event('PLAYER_EQUIPMENT_CHANGED', 16)
    check(host.scripts.OnUpdate == nil, 'weapon swap clears stale timing')
    SlashCmdList.FOREVERSWING('cue 0.4')
    check(ForeverSwingDB.cue == 0.4, 'optional cue configurable')
    SlashCmdList.FOREVERSWING('test')
    check(host.scripts.OnUpdate ~= nil, 'explicit preview works')
    event('PLAYER_SWING', 2, 0)
    check(off.value == 0, 'real swing clears preview offhand')
    event('PLAYER_DEAD')
    check(host.scripts.OnUpdate == nil, 'death clears')
    SlashCmdList.FOREVERSWING('width 9999')
    check(ForeverSwingDB.width == 300, 'invalid width rejected')
    SlashCmdList.FOREVERSWING('reset')
    check(ForeverSwingDB.cue == 0.4 and not ForeverSwingDB.offhand, 'reset defaults')
end
local cue, configured = run(false, {cue=0}, true)
check(cue == 0.4 and configured, 'legacy disabled default migrates once')
cue = run(false, {cue=0, cueConfigured=true}, true)
check(cue == 0, 'explicit disable survives reload')
cue = run(false, {cue=0.7}, true)
check(cue == 0.7, 'custom nonzero cue preserved')
run(false)
run(true)
print('PASS: ' .. count .. ' checks (model and mocked client integration)')
