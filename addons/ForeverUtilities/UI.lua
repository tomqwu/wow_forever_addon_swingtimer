local addon, NS = ...
local Hunter=NS.Hunter
local events=CreateFrame('Frame')
local panel
local function Say(text) DEFAULT_CHAT_FRAME:AddMessage("|cff66ff88Hunter's Friend:|r "..text) end
local function Text(parent,text,x,y,font)
    local label=parent:CreateFontString(nil,'OVERLAY',font or 'GameFontHighlight')
    label:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);label:SetText(text)
    return label
end
local function Button(parent,text,x,y,width,callback)
    local button=CreateFrame('Button',nil,parent,'UIPanelButtonTemplate')
    button:SetSize(width,26);button:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y)
    button:SetText(text);button:SetScript('OnClick',callback)
    return button
end
local function Check(parent,label,x,y,callback)
    local check=CreateFrame('CheckButton',nil,parent,'UICheckButtonTemplate')
    check:SetSize(28,28);check:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y)
    Text(parent,label,x+34,y-6)
    check:SetScript('OnClick',function(self) callback(self:GetChecked()==true) end)
    return check
end
local function RefreshPanel()
    if not panel then return end
    panel.enabled:SetChecked(Hunter.db.enabled)
    for _,option in ipairs(Hunter.options) do
        local value=Hunter.db[option.key]
        if option.kind=='toggle' then panel.controls[option.key]:SetChecked(value)
        else panel.controls[option.key]:SetText(string.format('%.1fx',value)) end
    end
end
local function OpenPanel()
    if not panel then
        panel=CreateFrame('Frame','ForeverHunterFriendOptions',UIParent)
        panel:SetSize(760,440);panel:SetPoint('CENTER');panel:SetFrameStrata('DIALOG')
        panel:SetClampedToScreen(true);panel:EnableMouse(true)
        panel:SetMovable(true);panel:RegisterForDrag('LeftButton')
        panel:SetScript('OnDragStart',function(self) self:StartMoving() end)
        panel:SetScript('OnDragStop',function(self) self:StopMovingOrSizing() end)
        panel:SetScript('OnHide',function(self) self:StopMovingOrSizing() end)
        local bg=panel:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(0.025,0.03,0.045,0.98)
        Text(panel,"Forever - Hunter's Friend",20,-18,'GameFontNormalLarge')
        Text(panel,'Drag this window to move it.',20,-48,'GameFontHighlightSmall')
        panel.enabled=Check(panel,'Enable hunter bar',20,-78,function(value) Hunter.SetEnabled(value) end)
        panel.controls={}
        local y=-120
        for index,option in ipairs(Hunter.options) do
            local key=option.key
            local x=index<=6 and 20 or 390
            y=-120-((index-1)%6)*42
            if option.kind=='toggle' then
                panel.controls[key]=Check(panel,option.label,x,y,function(value)
                    Hunter.db[key]=value;Hunter.Apply()
                end)
            else
                Text(panel,option.label,x,y-6)
                panel.controls[key]=Text(panel,'',x+210,y-6)
                local function Adjust(delta)
                    Hunter.db[key]=math.max(option.min,math.min(option.max,Hunter.db[key]+delta))
                    Hunter.Apply()
                end
                Button(panel,'-',x+170,y,28,function() Adjust(-option.step) end)
                Button(panel,'+',x+275,y,28,function() Adjust(option.step) end)
            end
            y=y-42
        end
        Button(panel,'Reset settings',20,-390,150,function() Hunter.Reset() end)
        Button(panel,'Close',660,-390,80,function() panel:Hide() end)
        if UISpecialFrames then table.insert(UISpecialFrames,'ForeverHunterFriendOptions') end
    end
    panel:Show();RefreshPanel()
end
local minimapButton,positionMinimap
local function RefreshMinimap()
    if not Hunter.IsHunter() or not Minimap then return end
    if not minimapButton then
        minimapButton=CreateFrame('Button','ForeverHunterFriendMinimap',Minimap)
        minimapButton:SetSize(28,28)
        local function Position()
            local width,height=Minimap:GetWidth(),Minimap:GetHeight()
            if not NS.Core.IsNumber(width) or width<=0 then width=140 end
            if not NS.Core.IsNumber(height) or height<=0 then height=140 end
            local angle=math.rad(Hunter.db.minimapAngle)
            minimapButton:ClearAllPoints()
            minimapButton:SetPoint('CENTER',Minimap,'CENTER',math.cos(angle)*(width/2+3),math.sin(angle)*(height/2+3))
        end
        positionMinimap=Position
        Position();Minimap:HookScript('OnSizeChanged',Position)
        minimapButton:RegisterForDrag('LeftButton')
        local dragged=false
        local function FollowCursor()
            local x,y=GetCursorPosition()
            local cx,cy=Minimap:GetCenter()
            local scale=Minimap:GetEffectiveScale()
            if not NS.Core.IsNumber(x) or not NS.Core.IsNumber(y)
                or not NS.Core.IsNumber(cx) or not NS.Core.IsNumber(cy)
                or not NS.Core.IsNumber(scale) or scale<=0 then return end
            local dx,dy=x/scale-cx,y/scale-cy
            if dx==0 and dy==0 then return end
            Hunter.db.minimapAngle=math.deg(math.atan2(dy,dx))%360
            Position()
        end
        minimapButton:SetScript('OnMouseDown',function() dragged=false end)
        minimapButton:SetScript('OnDragStart',function(self)
            dragged=true
            if GameTooltip then GameTooltip:Hide() end
            self:SetScript('OnUpdate',FollowCursor);FollowCursor()
        end)
        minimapButton:SetScript('OnDragStop',function(self)
            self:SetScript('OnUpdate',nil)
        end)
        minimapButton:SetScript('OnHide',function(self) self:SetScript('OnUpdate',nil) end)
        minimapButton:SetScript('OnClick',function() if not dragged then OpenPanel() end end)
        minimapButton:SetFrameStrata('MEDIUM');minimapButton:SetFrameLevel(8)
        local function Circle(size,layer)
            local texture=minimapButton:CreateTexture(nil,layer)
            texture:SetSize(size,size);texture:SetPoint('CENTER')
            local mask=minimapButton:CreateMaskTexture()
            mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask','CLAMPTOBLACKADDITIVE','CLAMPTOBLACKADDITIVE')
            mask:SetSize(size,size);mask:SetPoint('CENTER');texture:AddMaskTexture(mask)
            return texture
        end
        Circle(28,'BACKGROUND'):SetColorTexture(0.08,0.07,0.04,1)
        Circle(26,'BORDER'):SetColorTexture(0.72,0.57,0.25,1)
        Circle(22,'ARTWORK'):SetColorTexture(0.025,0.035,0.025,1)
        local icon=Circle(19,'OVERLAY')
        icon:SetTexture('Interface\\Icons\\Ability_Marksmanship');icon:SetTexCoord(0.08,0.92,0.08,0.92)
        local highlight=Circle(24,'HIGHLIGHT');highlight:SetColorTexture(1,0.85,0.4,0.22)
        minimapButton:SetScript('OnEnter',function(self)
            if GameTooltip then
                GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText("Hunter's Friend")
                GameTooltip:AddLine('Click: settings | Drag: move around minimap',1,1,1);GameTooltip:Show()
            end
        end)
        minimapButton:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
    positionMinimap()
    minimapButton:SetShown(Hunter.db.showMinimap~=false)
end
Hunter.changed=function() RefreshPanel();RefreshMinimap() end
events:RegisterEvent('ADDON_LOADED')
events:SetScript('OnEvent',function(self,_,name)
    if name~=addon then return end
    if type(ForeverUtilitiesDB)~='table' then ForeverUtilitiesDB={} end
    Hunter.Initialize(ForeverUtilitiesDB)
    self:UnregisterEvent('ADDON_LOADED')
    if Hunter.IsHunter() then Say('Loaded. /fhunter opens settings.') end
end)
SLASH_FOREVERUTILITIES1='/fhunter'
SLASH_FOREVERUTILITIES2='/futils'
SlashCmdList.FOREVERUTILITIES=function(message)
    if not Hunter.db then return end
    if not Hunter.IsHunter() then Say('This addon is for hunters.');return end
    local command,arg=message:lower():match('^%s*(%S*)%s*(.-)%s*$')
    local db=Hunter.db
    if command=='' or command=='options' or command=='tools' then OpenPanel()
    elseif command=='unlock' then db.locked=false;Hunter.SetEnabled(true)
    elseif command=='lock' then db.locked=true;Hunter.Apply()
    elseif command=='on' or command=='off' then Hunter.SetEnabled(command=='on')
    elseif command=='scale' then
        local value=tonumber(arg)
        if not NS.Core.IsNumber(value) or value<0.5 or value>2 then Say('Scale must be 0.5 to 2.');return end
        db.scale=value;Hunter.Apply()
    elseif command=='reset' then Hunter.Reset()
    elseif command=='status' then
        Say('v0.13.2 | '..(db.enabled and 'Enabled' or 'Disabled'))
        if db.enabled and Hunter.instance then Say(Hunter.instance.Status()) end
    else Say('/fhunter: unlock | lock | on | off | scale 0.5..2 | reset | status') end
end
