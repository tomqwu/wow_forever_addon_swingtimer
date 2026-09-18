local NS={}
local secret={}
issecretvalue=function(v) return rawequal(v,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/Range.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local function measure(probes,m,r,state,text)
    local actual,label=NS.Range.Measure(probes,m,r,{min=8,max=35})
    check(actual==state and (not text or label:find(text,1,true)),label)
end
measure({{min=0,max=5,inside=true}},true,false,'melee','<=5 yd')
measure({{min=0,max=5,inside=false},{min=0,max=35,inside=true}},false,false,'close','~5-8 yd')
measure({{min=8,max=35,inside=true}},false,true,'shoot','~8-35 yd')
measure({{min=0,max=35,inside=false}},false,false,'far','>35 yd')
measure({},false,false,'out','Out of range')
measure({{min=8,max=35,inside=false}},false,false,'out')
measure({{min=0,max=35,inside=secret}},secret,secret,'unknown')
measure({{min=0,max=5,inside=true},{min=0,max=35,inside=false}},false,false,'unknown')
measure({},nil,nil,'unknown')
local function fallback(probes,shot,state,text)
    local actual,label=NS.Range.Measure(probes,nil,nil,shot)
    check(actual==state and label:find(text,1,true),label)
end
fallback({{min=8,max=35,inside=true}},{min=8,max=35,inside=true},'shoot','Shooting')
fallback({{min=0,max=35,inside=false}},{min=8,max=35,inside=false},'far','>35 yd')
fallback({{min=0,max=5,inside=false},{min=0,max=35,inside=true}},
    {min=8,max=35,inside=false},'close','~5-8 yd')
fallback({{min=0,max=100,inside=false}},nil,'beyond','Out of range | >100 yd')
fallback({{min=0,max=35,inside=true}},nil,'distance','<=35 yd')
fallback({}, {min=8,max=35,inside=secret},'unknown','Range unavailable')
-- Never display invalid, restricted, or unchecked distances as real numbers.
for _,value in ipairs({-1,math.huge,0/0,secret}) do
    UnitDistanceSquared=function() return value,true end
    check(NS.Range.ReadDistance('target')==nil,'reject invalid numeric distance')
end
UnitDistanceSquared=function() return 400,false end
check(NS.Range.ReadDistance('target')==nil,'unchecked distance rejected')
UnitDistanceSquared=function() return 400,secret end
check(NS.Range.ReadDistance('target')==nil,'secret validity flag rejected')
UnitDistanceSquared=function() error('restricted') end
check(NS.Range.ReadDistance('target')==nil,'numeric API errors guarded')
UnitDistanceSquared=function() return 0,true end
check(NS.Range.ReadDistance('target')==0,'zero distance valid')
UnitDistanceSquared=function() return 625,true end
check(NS.Range.ReadDistance('target')==25,'squared distance converted to yards')
local numericState,numericLabel=NS.Range.WithDistance('shoot','Shooting | ~8-35 yd',23.4)
check(numericState=='shoot' and numericLabel=='Shooting | 23.4 yd','numeric label retains attack classification')
UnitDistanceSquared=nil
-- Mock discovery uses arbitrary IDs, proving it does not depend on Classic spell IDs.
local frames={}
local methods={}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:UnregisterEvent(e) self.events[e]=nil end
function methods:CreateTexture()
 local texture=setmetatable({}, {__index=methods})
 self.textures=rawget(self,"textures") or {};table.insert(self.textures,texture);return texture
end
function methods:SetColorTexture(r,g,b,a) self.color={r,g,b,a} end
function methods:CreateFontString() local f=setmetatable({}, {__index=methods});self.label=f;return f end
function methods:SetText(t) self.text=t end
function methods:SetShown(v) self.shown=v end
function methods:SetAlpha(v) self.alpha=v end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function() local f=setmetatable({scripts={},events={}},{__index=methods});frames[#frames+1]=f;return f end
local class,target,dead,distance='HUNTER',true,false,20
UnitClass=function() return 'Hunter',class end
UnitExists=function() return target end
UnitCanAttack=function() return true end
UnitIsDead=function() return dead end
Enum={PlayerSwingType={MainHand=0,Ranged=2},SpellBookSpellBank={Player=0}}
C_SwingTimer={IsTargetWithinSwingRange=function(kind) if kind==0 then return distance<=5 end;return distance>=8 and distance<=35 end}
local metadata={{minRange=8,maxRange=35,iconID=123},{minRange=0,maxRange=5},{minRange=0,maxRange=35}}
C_SpellBook={GetNumSpellBookSkillLines=function() return 1 end,
GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=3} end,
GetSpellBookItemInfo=function(slot) return {spellID=9000+slot} end,IsSpellKnown=function() return true end}
C_Spell={GetSpellInfo=function(id) return metadata[id-9000] end,
IsRangedAutoAttackSpell=function(id) return id==9001 end,IsSpellHarmful=function() return true end,
IsSpellInRange=function(id) local s=metadata[id-9000];return distance>=s.minRange and distance<=s.maxRange end}
local db={enabled=true,locked=true}
local f=NS.Range.Create({},db)
check(f.label.text:find('Shooting',1,true),'discovered auto shot')
distance=6;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('Too close',1,true),'updates without swing events')
distance=50;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('>35 yd',1,true),'far target')
target=false;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not f.scripts.OnUpdate and f.label.text=='No target','no target stops polling')
check(f.alpha==0.2,'no target dims indicator')
db.locked=false;f.Refresh()
check(f.alpha==1 and not f.scripts.OnUpdate,'unlock keeps no-target UI visible without polling')
db.locked=true;f.Refresh()
check(f.alpha==0.2,'locking restores no-target dimming')
target=true;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(f.alpha==1,'acquiring target restores full visibility')
target=true;dead=true;f.Refresh()
check(not f.scripts.OnUpdate,'dead target stops polling')
dead=false;db.enabled=false;f.Refresh()
check(not f.shown and not f.scripts.OnUpdate,'disabled stops polling')
check(next(f.events)==nil,'disabled unregisters all range events')
local disabledText=f.label.text
f.scripts.OnEvent(f,'SPELLS_CHANGED')
check(f.label.text==disabledText and not f.scripts.OnUpdate,'disabled ignores queued events')
db.enabled=true;f.Refresh()
check(f.shown and f.scripts.OnUpdate,'enable starts polling')
check(f.events.PLAYER_TARGET_CHANGED and f.events.SPELLS_CHANGED,'enable restores events')
f.scripts.OnEvent(f,'PLAYER_LEAVING_WORLD')
check(not f.scripts.OnUpdate,'loading screen stops polling')
class='PALADIN';check(NS.Range.Create({},db)~=nil,'distance utility supports other classes')
-- Spellbook slot checks must work even when native and spell-ID queries fail.
C_SwingTimer.IsTargetWithinSwingRange=function() return nil end
C_Spell.IsSpellInRange=function() error('unavailable') end
C_SpellBook.IsSpellBookItemInRange=function(slot)
    local data=metadata[slot];return distance>=data.minRange and distance<=data.maxRange
end
distance=20
f=NS.Range.Create({},db)
check(f.label.text:find('Shooting',1,true),'spellbook fallback classifies shooting')
check(f.Status():find('nil/nil',1,true),'diagnostics report missing native checks')
distance=50;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('Too far',1,true),'spellbook fallback classifies far')
-- Regression: a broad spell supplies an upper bound but Auto Shot metadata is absent.
metadata[4]={minRange=0,maxRange=100}
C_SpellBook.GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=4} end
C_Spell.IsRangedAutoAttackSpell=function() return false end
C_SwingTimer.IsTargetWithinSwingRange=function() return false end
distance=50
f=NS.Range.Create({},db)
check(f.label.text:find('Out of range | ~35-100 yd',1,true),'negative attack check overrides blue bracket')
check(f.textures[2].color[1]==1 and f.textures[2].color[2]==0.15,'out-of-range accent is actually red')
check(f.textures[3].color[1]==1 and f.textures[3].color[2]==0.15,'out-of-range icon border is actually red')
C_SwingTimer.IsTargetWithinSwingRange=function() return nil end
f.Refresh()
check(f.label.text:find('Distance',1,true),'unavailable attack check is not invented as false')
check(f.textures[2].color[1]==0.3 and f.textures[2].color[3]==1,'genuinely unclassified bracket remains blue')
UnitDistanceSquared=function() return distance*distance,true end
distance=23.4;f.Refresh()
check(f.label.text:find('23.4 yd',1,true),'live decimal distance displayed')
distance=24.7;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('24.7 yd',1,true),'decimal updates as target moves')
UnitDistanceSquared=function() return 0,false end
f.scripts.OnUpdate(f,0.15)
check(not f.label.text:find('24.7 yd',1,true),'lost distance availability clears stale numeric value')
UnitCanAttack=function() return false end
UnitDistanceSquared=function() return 144,true end
f.Refresh()
check(f.label.text=='Distance | 12.0 yd','friendly target numeric distance supported')
UnitIsFriend=function() return true end
UnitDistanceSquared=function() return 0,false end
f.Refresh()
check(f.label.text=='Friendly target\nDistance unavailable','friendly unavailable message is explicit')
check(f.textures[2].color[1]==0.8,'friendly unavailable remains neutral gray')
UnitIsFriend=function() return secret end
f.Refresh()
check(f.label.text=='Range unavailable','restricted friendliness does not invent friendly status')
UnitCanAttack=function() return true end
UnitDistanceSquared=nil
class='HUNTER';C_Spell=nil;C_SpellBook=nil
f=NS.Range.Create({},db)
check(f.label.text:find('Range unavailable',1,true),'missing APIs degrade safely')
print('PASS: '..count..' distance checks')
