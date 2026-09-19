local _, NS = ...
local function Normalize(db)
    for key,default in pairs({x=0,y=-210,scale=1}) do
        if not NS.Core.IsNumber(db[key]) then db[key]=default end
    end
    db.x=math.max(-5000,math.min(5000,db.x))
    db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
NS.Modules.Register({
    id='distance', name='Distance checker',
    description='Distance, target of target, and facing angle when available. Dims with no target.',
    defaults={enabled=true,locked=true,x=0,y=-210,scale=1,showTargetTarget=true,showAngle=true}, normalize=Normalize,
    options={
        {key='locked',label='Lock indicator position',kind='toggle'},
        {key='scale',label='Indicator size',kind='number',min=0.5,max=2,step=0.1},
        {key='showTargetTarget',label='Show target of target',kind='toggle'},
        {key='showAngle',label='Show facing angle',kind='toggle'},
    },
    create=function(db)
        local host=CreateFrame('Frame','ForeverUtilitiesDistanceFrame',UIParent)
        host:SetSize(400,NS.TargetContext.Height(db));host:SetFrameStrata('MEDIUM')
        host:SetMovable(true);host:SetClampedToScreen(true);host:RegisterForDrag('LeftButton')
        host.hint=host:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
        host.hint:SetPoint('BOTTOM',host,'TOP',0,4)
        local indicator=NS.Range.Create(host,db)
        local function Apply()
            host:SetShown(db.enabled)
            host:SetSize(400,NS.TargetContext.Height(db))
            host:SetScale(db.scale);host:ClearAllPoints()
            host:SetPoint('CENTER',UIParent,'CENTER',db.x,db.y)
            host:EnableMouse(db.enabled and not db.locked)
            host.hint:SetText(db.locked and '' or 'Drag to move | /futils lock')
            indicator.Refresh()
        end
        host:SetScript('OnDragStart',function(self) if db.enabled and not db.locked then self:StartMoving() end end)
        host:SetScript('OnDragStop',function(self)
            self:StopMovingOrSizing()
            local x,y=self:GetCenter();local cx,cy=UIParent:GetCenter()
            local ratio=self:GetEffectiveScale()/UIParent:GetEffectiveScale()
            db.x,db.y=x-cx/ratio,y-cy/ratio
            Apply()
        end)
        return {Apply=Apply,Status=indicator.Status}
    end,
})
