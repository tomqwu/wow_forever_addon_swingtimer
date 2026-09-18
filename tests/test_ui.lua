local NS={}
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local function run(class)
 local frames={}
 local methods={}
 function methods:SetScript(k,v) self.scripts[k]=v end
 function methods:RegisterEvent(e) self.events[e]=true end
 function methods:UnregisterEvent(e) self.events[e]=nil end
 function methods:CreateFontString() return setmetatable({}, {__index=methods}) end
 function methods:SetText(v) self.text=v end
 function methods:SetScale(v) self.scale=v end
 function methods:EnableMouse(v) self.mouse=v end
 function methods:SetPoint(_,_,_,x,y) self.x,self.y=x,y end
 function methods:GetCenter() return 30,40 end
 function methods:GetEffectiveScale() return 1 end
 setmetatable(methods,{__index=function() return function() end end})
 CreateFrame=function(_,name)
  local f=setmetatable({scripts={},events={},name=name},{__index=methods});frames[#frames+1]=f;return f
 end
 UIParent=setmetatable({}, {__index=methods})
 DEFAULT_CHAT_FRAME={AddMessage=function() end}
 UnitClass=function() return class,class end
 SlashCmdList={}
 -- No ForeverSwing globals, modules, or frames are present.
 ForeverUtilitiesDB={x=0/0,scale=999}
 ForeverSwingDB={x=123,cue=0.7}
 local refreshes=0
 NS.Range={Create=function(host,db)
  check(db==ForeverUtilitiesDB,'uses own settings')
  return {Refresh=function() refreshes=refreshes+1 end}
 end}
 assert(loadfile('addons/ForeverUtilities/UI.lua'))('ForeverUtilities',NS)
 frames[1].scripts.OnEvent(frames[1],'ADDON_LOADED','Unrelated')
 check(#frames==1,'ignores unrelated addon loading')
 frames[1].scripts.OnEvent(frames[1],'ADDON_LOADED','ForeverUtilities')
 check(not frames[1].events.ADDON_LOADED,'initializes once')
 check(ForeverUtilitiesDB.x==0 and ForeverUtilitiesDB.scale==2,'normalizes settings')
 local slash=SlashCmdList.FOREVERUTILITIES
 check(frames[2].name=='ForeverUtilitiesFrame','independent utilities frame')
 slash('unlock');check(frames[2].mouse and not ForeverUtilitiesDB.locked,'unlock')
 slash('lock');check(not frames[2].mouse and ForeverUtilitiesDB.locked,'lock')
 slash('off');check(not ForeverUtilitiesDB.enabled,'disable')
 slash('on');check(ForeverUtilitiesDB.enabled,'enable')
 slash('scale 1.3');check(frames[2].scale==1.3,'scale')
 slash('scale 99');check(frames[2].scale==1.3,'reject invalid scale')
 slash('reset');check(ForeverUtilitiesDB.scale==1 and ForeverUtilitiesDB.y==-210,'reset own settings')
 check(ForeverSwingDB.x==123 and ForeverSwingDB.cue==0.7,'swing settings untouched')
 check(refreshes>1,'settings refresh range module')
end
run('HUNTER');run('PALADIN')
print('PASS: '..count..' standalone UI checks')
