local NS={}
local root='addons/ForeverUtilities/'
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Modules.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/TargetContext.lua'))('ForeverUtilities',NS)
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
UIParent=object();UISpecialFrames={}
DEFAULT_CHAT_FRAME={AddMessage=function() end};SlashCmdList={}
ForeverUtilitiesDB={x=70,y=-123,scale=1.3,locked=false,enabled=false}
ForeverSwingDB={x=123,cue=0.7}
local refreshes=0
NS.Range={Create=function(host,db)
 check(db==ForeverUtilitiesDB.modules.distance,'module owns settings')
 return {Refresh=function() refreshes=refreshes+1 end,Status=function() return 'test' end}
end}
assert(loadfile(root..'Distance.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local events=frames[1]
events.scripts.OnEvent(events,'ADDON_LOADED','Unrelated')
check(not NS.Modules.db,'ignores unrelated addon')
events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
check(not events.events.ADDON_LOADED,'initializes once')
local db=ForeverUtilitiesDB.modules.distance
check(db.x==70 and db.y==-123 and db.scale==1.3 and not db.locked and not db.enabled,'legacy preferences preserved')
check(not named.ForeverUtilitiesDistanceFrame,'disabled module not created at login')
local slash=SlashCmdList.FOREVERUTILITIES
slash('')
local panel=named.ForeverUtilitiesToolbox
check(panel and panel.shown,'slash opens shared toolbox')
local section=panel.sections.distance
check(section and not section.enabled.checked,'panel reflects disabled setting')
section.enabled:SetChecked(true);section.enabled.scripts.OnClick(section.enabled)
local host=named.ForeverUtilitiesDistanceFrame
check(db.enabled and host.shown and host.scale==1.3,'panel enables distance utility with preserved scale')
section.controls.locked:SetChecked(true);section.controls.locked.scripts.OnClick(section.controls.locked)
check(db.locked and not host.mouse,'panel lock controls module')
for _,f in ipairs(frames) do
 if rawget(f,'text')=='+' then f.scripts.OnClick(f) end
end
check(math.abs(db.scale-1.4)<0.001,'panel size control')
section.enabled:SetChecked(false);section.enabled.scripts.OnClick(section.enabled)
check(not db.enabled and not host.shown,'panel disable hides module host')
slash('unlock');check(db.enabled and not db.locked and host.mouse,'legacy unlock shortcut retained')
slash('scale 1.6');check(host.scale==1.6,'legacy scale shortcut retained')
slash('scale 99');check(host.scale==1.6,'invalid scale rejected')
slash('off');check(not host.shown,'legacy off shortcut retained')
slash('reset');check(db.scale==1 and db.x==0 and db.enabled and db.locked,'reset applies only distance defaults')
check(ForeverSwingDB.x==123 and ForeverSwingDB.cue==0.7,'unrelated settings untouched')
for _,f in ipairs(frames) do if rawget(f,'text')=='Close' then f.scripts.OnClick(f) end end
check(not panel.shown,'panel closes')
slash('options');check(panel.shown,'panel reopens')
check(UISpecialFrames[1]=='ForeverUtilitiesToolbox','escape closes registered panel')
check(refreshes>1,'module changes refresh display')
print('PASS: '..count..' toolbox UI checks')
