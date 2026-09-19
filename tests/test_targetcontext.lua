local NS={}
local secret={}
issecretvalue=function(v) return rawequal(v,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/TargetContext.lua'))('ForeverUtilities',NS)
local C=NS.TargetContext
local count=0
local function check(v,msg) assert(v,msg);count=count+1 end
local function angle(x,y,f,expected)
    check(math.abs(C.Angle(0,0,x,y,f)-expected)<0.0001,'direction')
end
angle(1,0,0,0);angle(0,1,0,90);angle(0,-1,0,-90);angle(-1,0,0,-180)
angle(0,1,math.pi/2,0);angle(1,0,3*math.pi/2,90)
angle(1,0,2*math.pi-0.1,math.deg(0.1))
check(C.Angle(0,0,0,0,0)==nil,'coincident positions')
for _,bad in ipairs({secret,math.huge,-math.huge,0/0,'1'}) do
    check(C.Angle(bad,0,1,0,0)==nil,'invalid position')
    check(C.Angle(0,0,1,0,bad)==nil,'invalid facing')
end
check(C.Angle(0,0,1,nil,0)==nil,'missing position')
GetPlayerFacing=function() return 0 end
local tx,ty,map=0,5,1
UnitPosition=function(unit) if unit=='player' then return 0,0,0,1 end return tx,ty,0,map end
check(C.AngleText()=='Angle: 90° left','left label')
ty=-5;check(C.AngleText()=='Angle: 90° right','right label')
tx=5;ty=0;check(C.AngleText()=='Angle: 0° (straight ahead)','ahead label')
tx=-5;check(C.AngleText()=='Angle: 180° (behind)','behind label')
map=2;check(C.ReadAngle()==nil,'different map')
map=secret;check(C.ReadAngle()==nil,'restricted map')
map=1;tx=secret;check(C.ReadAngle()==nil,'restricted coordinate')
UnitPosition=function() error('restricted') end
check(C.AngleText()=='Angle unavailable','failed API clears text')
UnitPosition=nil;check(C.ReadAngle()==nil,'missing position API')
GetPlayerFacing=function() return secret end
check(C.ReadAngle()==nil,'restricted facing')
GetPlayerFacing=nil;check(C.ReadAngle()==nil,'missing facing API')
UnitExists=function() return false end
check(C.TargetTarget()=='Target of target: None','no targettarget')
UnitExists=function() return secret end
check(C.TargetTarget()=='Target of target: Unavailable','restricted existence')
UnitExists=function() return true end
UnitIsUnit=function() return true end
check(C.TargetTarget()=='Target of target: YOU','self target')
UnitIsUnit=function() return false end
UnitName=function() return 'Tank' end
check(C.TargetTarget()=='Target of target: Tank','name')
UnitName=function() return secret end
check(C.TargetTarget()=='Target of target: Unavailable','restricted name')
UnitName=function() error('unavailable') end
check(C.TargetTarget()=='Target of target: Unavailable','failed name API')
check(C.Height({})==56 and C.Height({showAngle=false})==56 and C.Height({showAngle=false,showTargetTarget=false})==56,'original height with any context options')
print('PASS: '..count..' target context checks')
