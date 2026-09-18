local NS={}
assert(loadfile('addons/ForeverUtilities/Modules.lua'))('ForeverUtilities',NS)
local M=NS.Modules
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local created,applied={},{}
local function define(id,enabled)
 M.Register({id=id,defaults={enabled=enabled,scale=1},create=function(settings)
  created[id]=(created[id] or 0)+1
  return {Apply=function() applied[id]=(applied[id] or 0)+1 end}
 end})
end
define('distance',true);define('other',false)
local db={enabled=false,scale=1.4,modules={other={enabled=false,scale=1.7}},selectedModule='missing'}
M.Initialize(db)
check(not created.distance and not created.other,'disabled modules remain unconstructed')
check(db.modules.distance.scale==1.4 and not db.modules.distance.enabled,'legacy enabled and scale migrate')
check(db.modules.other.scale==1.7,'other module settings preserved')
M.SetEnabled('other',true)
check(created.other==1 and not created.distance,'enabling second module does not enable distance')
M.SetEnabled('distance',true)
check(created.distance==1 and db.modules.other.enabled,'modules independently enabled')
M.SetEnabled('distance',false)
check(db.modules.other.enabled and applied.other==1,'disabling distance does not update another module')
M.SetEnabled('distance',true)
check(created.distance==1,'reenable reuses instance')
M.Reset('distance')
check(db.modules.other.scale==1.7,'module reset isolated')
db.scale=9;M.Initialize(db)
check(db.modules.distance.scale==1,'migration not repeated over new settings')
check(db.selectedModule=='distance','invalid selection normalized')
local ok=pcall(function() define('distance',false) end)
check(not ok,'duplicate module rejected')
print('PASS: '..count..' module isolation checks')
