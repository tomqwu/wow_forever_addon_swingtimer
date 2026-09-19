local _, NS = ...
local Layout={}
NS.Layout=Layout
-- Stable slots while playing. Only preference changes redistribute space.
function Layout.Compute(db)
    local result={width=400,height=56}
    local right=394
    local function Reserve(key,width,enabled)
        if enabled then
            right=right-width
            result[key]={x=right,width=width}
        end
    end
    Reserve('control',20,db.showLockButton~=false)
    Reserve('pet',48,db.showTargetTarget~=false)
    Reserve('combat',56,db.markWarning~=false or db.showAngle~=false)
    result.range={x=6,width=right-6}
    result.text={x=db.showRange~=false and 66 or 14,width=0}
    result.text.width=right-8-result.text.x
    return result
end
