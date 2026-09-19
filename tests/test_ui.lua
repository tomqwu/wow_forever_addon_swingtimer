local NS={}
local root='addons/ForeverUtilities/'
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/TargetContext.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/Layout.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local frames,named={},{}
local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:UnregisterEvent(e) self.events[e]=nil end
function methods:CreateFontString() return object() end
function methods:CreateTexture() return object() end
function methods:SetText(v) self.text=v end
function methods:SetMovable(v) self.movable=v end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:SetScale(v) self.scale=v end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetShown(v) self.shown=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:SetPoint(_,_,_,x,y) self.x,self.y=x,y end
function methods:GetCenter() return 30,40 end
function methods:GetEffectiveScale() return 1 end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function(_,name,parent)
 local f=object();f.name=name;f.parent=parent;frames[#frames+1]=f
 if name then named[name]=f end;return f
end
UIParent=object();Minimap=object();UISpecialFrames={}
DEFAULT_CHAT_FRAME={AddMessage=function() end};SlashCmdList={}
ForeverUtilitiesDB={x=70,y=-123,scale=1.3,locked=false,enabled=false}
ForeverSwingDB={x=123,cue=0.7}
local refreshes=0
NS.Range={Create=function(host,db)
 check(db==ForeverUtilitiesDB.hunter,'hunter owns migrated settings')
 return {Refresh=function() refreshes=refreshes+1 end,Status=function() return 'test' end}
end}
local class='HUNTER'
UnitClass=function() return 'Hunter',class end
assert(loadfile(root..'Distance.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local events=frames[1]
events.scripts.OnEvent(events,'ADDON_LOADED','Unrelated')
check(not NS.Hunter.db,'ignores unrelated addon')
events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
local db=NS.Hunter.db
check(db.x==70 and db.y==-123 and db.scale==1.3 and not db.enabled,'flat preferences migrated')
check(not NS.Hunter.instance,'disabled bar not created')
local slash=SlashCmdList.FOREVERUTILITIES
slash('');local panel=named.ForeverHunterFriendOptions
check(panel and panel.shown and rawget(panel,'rows')==nil,'single hunter settings panel')
panel.enabled:SetChecked(true);panel.enabled.scripts.OnClick(panel.enabled)
check(db.enabled and NS.Hunter.instance,'settings enable bar')
slash('scale 1.5');check(db.scale==1.5,'scale command')
slash('scale 9');check(db.scale==1.5,'invalid scale rejected')
slash('off');check(not db.enabled and not named.ForeverUtilitiesDistanceFrame.shown,'disable hides bar')
slash('unlock');check(db.enabled and not db.locked,'unlock enables dragging')
slash('lock');check(db.locked,'lock command')
slash('reset');check(db.scale==1 and db.locked,'reset defaults')
for _,key in ipairs({'showRange','showAmmo','lowAmmoWarning','petMendWarning','markWarning','fadeOutOfCombat','showTargetTarget','showAngle'}) do
 local control=panel.controls[key]
 check(control~=nil,'feature has checkbox: '..key)
 control:SetChecked(false);control.scripts.OnClick(control)
 check(db[key]==false,'checkbox saves: '..key)
end
local mini=named.ForeverHunterFriendMinimap
check(mini and mini.shown,'minimap button available even when bar disabled')
mini.scripts.OnClick();check(panel.shown,'minimap opens settings')
local lock=named.ForeverHunterFriendLock
local wasLocked=db.locked;lock.scripts.OnClick()
check(db.locked~=wasLocked and panel.controls.locked.checked==db.locked,'bar lock toggles and syncs settings')
lock.scripts.OnClick();check(db.locked==wasLocked,'bar lock toggles back')
local control=panel.controls.showMinimap;control:SetChecked(false);control.scripts.OnClick(control)
check(not mini.shown,'minimap button setting hides button')
control=panel.controls.showLockButton;control:SetChecked(false);control.scripts.OnClick(control)
check(not lock.shown,'lock button setting hides button')
check(panel.movable,'settings movable by default')
panel.scripts.OnDragStart(panel);check(panel.moving,'settings drag starts without unlock')
panel.scripts.OnDragStop(panel);check(not panel.moving,'settings drag stops')
panel.scripts.OnDragStart(panel);panel.scripts.OnHide(panel)
check(not panel.moving,'closing settings cancels drag')
local saved={modules={distance={enabled=false,x=81,scale=1.2,showAngle=false}},schemaVersion=1}
NS.Hunter.instance=nil;NS.Hunter.Initialize(saved)
check(NS.Hunter.db.x==81 and NS.Hunter.db.scale==1.2 and not NS.Hunter.db.showAngle,'toolbox preferences migrated')
NS.Hunter.db.x=91;NS.Hunter.Initialize(saved)
check(NS.Hunter.db.x==91,'migration is one time')
class='MAGE';NS.Hunter.instance=nil;NS.Hunter.Initialize({})
check(not NS.Hunter.instance,'non hunters never create bar')
slash('on');check(not NS.Hunter.instance,'non hunter commands cannot create bar')
print('PASS: '..count..' hunter UI and migration checks')
