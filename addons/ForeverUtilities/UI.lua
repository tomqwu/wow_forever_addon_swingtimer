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
local minimapButton
local function RefreshMinimap()
    if not Hunter.IsHunter() or not Minimap then return end
    if not minimapButton then
        minimapButton=CreateFrame('Button','ForeverHunterFriendMinimap',Minimap)
        minimapButton:SetSize(30,30);minimapButton:SetPoint('CENTER',Minimap,'CENTER',54,54)
        minimapButton:SetFrameStrata('MEDIUM');minimapButton:SetFrameLevel(8)
        minimapButton:SetNormalTexture('Interface\\Icons\\Ability_Marksmanship')
        minimapButton:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
        minimapButton:SetScript('OnClick',OpenPanel)
        minimapButton:SetScript('OnEnter',function(self)
            if GameTooltip then
                GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText("Hunter's Friend")
                GameTooltip:AddLine('Click to open settings.',1,1,1);GameTooltip:Show()
            end
        end)
        minimapButton:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
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
        Say('v0.12.1 | '..(db.enabled and 'Enabled' or 'Disabled'))
        if db.enabled and Hunter.instance then Say(Hunter.instance.Status()) end
    else Say('/fhunter: unlock | lock | on | off | scale 0.5..2 | reset | status') end
end
