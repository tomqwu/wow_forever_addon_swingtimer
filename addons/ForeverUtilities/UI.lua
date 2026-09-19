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
        panel:SetSize(420,360);panel:SetPoint('CENTER');panel:SetFrameStrata('DIALOG')
        panel:SetClampedToScreen(true);panel:EnableMouse(true)
        local bg=panel:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(0.025,0.03,0.045,0.98)
        Text(panel,"Forever - Hunter's Friend",20,-18,'GameFontNormalLarge')
        Text(panel,'Range, ammunition, and target awareness.',20,-48,'GameFontHighlightSmall')
        panel.enabled=Check(panel,'Enable hunter bar',20,-78,function(value) Hunter.SetEnabled(value) end)
        panel.controls={}
        local y=-120
        for _,option in ipairs(Hunter.options) do
            local key=option.key
            if option.kind=='toggle' then
                panel.controls[key]=Check(panel,option.label,20,y,function(value)
                    Hunter.db[key]=value;Hunter.Apply()
                end)
            else
                Text(panel,option.label,20,y-6)
                panel.controls[key]=Text(panel,'',230,y-6)
                local function Adjust(delta)
                    Hunter.db[key]=math.max(option.min,math.min(option.max,Hunter.db[key]+delta))
                    Hunter.Apply()
                end
                Button(panel,'-',190,y,28,function() Adjust(-option.step) end)
                Button(panel,'+',295,y,28,function() Adjust(option.step) end)
            end
            y=y-42
        end
        Button(panel,'Reset settings',20,-304,150,function() Hunter.Reset() end)
        Button(panel,'Close',320,-304,80,function() panel:Hide() end)
        if UISpecialFrames then table.insert(UISpecialFrames,'ForeverHunterFriendOptions') end
    end
    panel:Show();RefreshPanel()
end
Hunter.changed=RefreshPanel
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
        Say('v0.8.2 | '..(db.enabled and 'Enabled' or 'Disabled'))
        if db.enabled and Hunter.instance then Say(Hunter.instance.Status()) end
    else Say('/fhunter: unlock | lock | on | off | scale 0.5..2 | reset | status') end
end
