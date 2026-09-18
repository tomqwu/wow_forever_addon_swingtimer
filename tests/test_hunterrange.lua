local NS={}
local secret={}
issecretvalue=function(v) return rawequal(v,secret) end
assert(loadfile('ForeverSwing/Core.lua'))('ForeverSwing',NS)
assert(loadfile('ForeverSwing/HunterRange.lua'))('ForeverSwing',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local function measure(probes,m,r,state,text)
    local actual,label=NS.HunterRange.Measure(probes,m,r,{min=8,max=35})
    check(actual==state and (not text or label:find(text,1,true)),label)
end
measure({{min=0,max=5,inside=true}},true,false,'melee','<=5 yd')
measure({{min=0,max=5,inside=false},{min=0,max=35,inside=true}},false,false,'close','~5-8 yd')
measure({{min=8,max=35,inside=true}},false,true,'shoot','~8-35 yd')
measure({{min=0,max=35,inside=false}},false,false,'far','>35 yd')
measure({},false,false,'unknown','Range unknown')
measure({{min=8,max=35,inside=false}},false,false,'unknown')
measure({{min=0,max=35,inside=secret}},secret,secret,'unknown')
measure({{min=0,max=5,inside=true},{min=0,max=35,inside=false}},false,false,'unknown')
measure({},nil,nil,'unknown')
-- Mock discovery uses arbitrary IDs, proving it does not depend on Classic spell IDs.
local frames={}
local methods={}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:CreateTexture() return setmetatable({}, {__index=methods}) end
function methods:CreateFontString() local f=setmetatable({}, {__index=methods});self.label=f;return f end
function methods:SetText(t) self.text=t end
function methods:SetShown(v) self.shown=v end
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
local db={hunterrange=true}
local f=NS.HunterRange.Create({},db)
check(f.label.text:find('Shooting',1,true),'discovered auto shot')
distance=6;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('Too close',1,true),'updates without swing events')
distance=50;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('>35 yd',1,true),'far target')
target=false;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not f.scripts.OnUpdate and f.label.text=='No target','no target stops polling')
target=true;dead=true;f.Refresh()
check(not f.scripts.OnUpdate,'dead target stops polling')
dead=false;db.hunterrange=false;f.Refresh()
check(not f.shown and not f.scripts.OnUpdate,'disabled stops polling')
db.hunterrange=true;f.Refresh()
check(f.shown and f.scripts.OnUpdate,'enable starts polling')
f.scripts.OnEvent(f,'PLAYER_LEAVING_WORLD')
check(not f.scripts.OnUpdate,'loading screen stops polling')
class='PALADIN';check(NS.HunterRange.Create({},db)==nil,'hunter only')
class='HUNTER';C_Spell=nil;C_SpellBook=nil
f=NS.HunterRange.Create({},db)
check(f.label.text:find('Range unknown',1,true),'missing APIs degrade safely')
print('PASS: '..count..' hunter range checks')
