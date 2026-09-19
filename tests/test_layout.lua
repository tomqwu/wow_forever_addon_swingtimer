local NS={}
assert(loadfile('addons/ForeverUtilities/Layout.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
-- Every combination of visible blocks must fit without overlap.
for mask=0,31 do
    local function on(bit) return math.floor(mask/2^bit)%2==1 end
    local db={showRange=on(0),showAngle=on(1),markWarning=on(2),showTargetTarget=on(3),showLockButton=on(4)}
    local l=NS.Layout.Compute(db)
    check(l.width==400 and l.height==56,'fixed footprint')
    local last=l.range.x+l.range.width
    for _,key in ipairs({'combat','pet','control'}) do
        if l[key] then
            check(l[key].x>=last,'blocks do not overlap')
            last=l[key].x+l[key].width
        end
    end
    check(last<=400 and l.text.width>=196,'bounds and minimum text width')
    check(l.text.x+l.text.width<=l.range.x+l.range.width,'text stays in range block')
end
local full=NS.Layout.Compute({})
local minimal=NS.Layout.Compute({showAngle=false,markWarning=false,showTargetTarget=false,showLockButton=false})
check(minimal.text.width>full.text.width,'hidden blocks return text space')
print('PASS: '..count..' block layout checks')
