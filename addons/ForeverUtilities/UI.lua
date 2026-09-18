local addon, NS = ...
local Modules=NS.Modules
local events=CreateFrame('Frame')
local panel, selected
local function Say(text) DEFAULT_CHAT_FRAME:AddMessage('|cff66ff88ForeverUtilities:|r '..text) end
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
    for _,definition in ipairs(Modules.list) do
        local enabled=Modules.Settings(definition.id).enabled
        panel.rows[definition.id]:SetText((selected==definition.id and '> ' or '')..definition.name..(enabled and ' [On]' or ' [Off]'))
        local section=panel.sections[definition.id]
        if section then
            section:SetShown(selected==definition.id)
            section.enabled:SetChecked(enabled)
            section.state:SetText(enabled and 'Enabled' or 'Disabled — no background updates')
            for _,option in ipairs(definition.options or {}) do
                local control=section.controls[option.key]
                local value=Modules.Settings(definition.id)[option.key]
                if option.kind=='toggle' then control:SetChecked(value)
                else control:SetText(string.format('%.1fx',value)) end
            end
        end
    end
end
local function Select(id)
    selected=id;Modules.db.selectedModule=id
    if not panel.sections[id] then
        local definition=Modules.definitions[id]
        local section=CreateFrame('Frame',nil,panel)
        section:SetPoint('TOPLEFT',panel,'TOPLEFT',235,-62);section:SetSize(340,310)
        section.controls={};panel.sections[id]=section
        Text(section,definition.name,0,0,'GameFontNormalLarge')
        local description=Text(section,definition.description,0,-32)
        description:SetWidth(320);description:SetJustifyH('LEFT')
        section.enabled=Check(section,'Enable this utility',0,-94,function(value) Modules.SetEnabled(id,value) end)
        section.state=Text(section,'',0,-128,'GameFontHighlightSmall')
        local y=-158
        for _,option in ipairs(definition.options or {}) do
            local key=option.key
            if option.kind=='toggle' then
                section.controls[key]=Check(section,option.label,0,y,function(value)
                    Modules.Settings(id)[key]=value;Modules.Apply(id)
                end)
            elseif option.kind=='number' then
                Text(section,option.label,0,y-6)
                section.controls[key]=Text(section,'',210,y-6)
                local function Adjust(delta)
                    local settings=Modules.Settings(id)
                    settings[key]=math.max(option.min,math.min(option.max,settings[key]+delta))
                    Modules.Apply(id)
                end
                Button(section,'-',170,y,28,function() Adjust(-option.step) end)
                Button(section,'+',275,y,28,function() Adjust(option.step) end)
            end
            y=y-42
        end
        Button(section,'Reset this utility',0,y,170,function() Modules.Reset(id) end)
    end
    RefreshPanel()
end
local function OpenPanel()
    if not panel then
        panel=CreateFrame('Frame','ForeverUtilitiesToolbox',UIParent)
        panel:SetSize(600,400);panel:SetPoint('CENTER');panel:SetFrameStrata('DIALOG')
        panel:SetClampedToScreen(true);panel:EnableMouse(true)
        local bg=panel:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(0.025,0.03,0.045,0.98)
        Text(panel,'Forever Utilities',20,-18,'GameFontNormalLarge')
        Text(panel,'Choose the utilities you want to use.',20,-43,'GameFontHighlightSmall')
        Button(panel,'Close',510,-14,70,function() panel:Hide() end)
        panel.rows={};panel.sections={}
        local scroll=CreateFrame('ScrollFrame',nil,panel)
        scroll:SetPoint('TOPLEFT',panel,'TOPLEFT',15,-70);scroll:SetSize(205,270)
        local list=CreateFrame('Frame',nil,scroll);list:SetSize(205,math.max(270,#Modules.list*36))
        scroll:SetScrollChild(list);scroll:EnableMouseWheel(true)
        local offset=0
        scroll:SetScript('OnMouseWheel',function(self,delta)
            offset=math.max(0,math.min(math.max(0,#Modules.list*36-270),offset-delta*36))
            self:SetVerticalScroll(offset)
        end)
        for i,definition in ipairs(Modules.list) do
            local id=definition.id
            panel.rows[id]=Button(list,definition.name,0,-(i-1)*36,200,function() Select(id) end)
        end
        Text(panel,'v0.4.0  |  Settings are saved per utility.',20,-372,'GameFontHighlightSmall')
        if UISpecialFrames then table.insert(UISpecialFrames,'ForeverUtilitiesToolbox') end
    end
    panel:Show();Select(Modules.db.selectedModule)
end
Modules.changed=RefreshPanel
events:RegisterEvent('ADDON_LOADED')
events:SetScript('OnEvent',function(self,_,name)
    if name~=addon then return end
    if type(ForeverUtilitiesDB)~='table' then ForeverUtilitiesDB={} end
    Modules.Initialize(ForeverUtilitiesDB)
    self:UnregisterEvent('ADDON_LOADED')
    Say('Loaded. /futils opens your utilities toolbox.')
end)
SLASH_FOREVERUTILITIES1='/futils'
SlashCmdList.FOREVERUTILITIES=function(message)
    if not Modules.db then return end
    local command,arg=message:lower():match('^%s*(%S*)%s*(.-)%s*$')
    local db=Modules.Settings('distance')
    if command=='' or command=='options' or command=='tools' then OpenPanel()
    elseif command=='unlock' then db.locked=false;Modules.SetEnabled('distance',true)
    elseif command=='lock' then db.locked=true;Modules.Apply('distance')
    elseif command=='on' or command=='off' then Modules.SetEnabled('distance',command=='on')
    elseif command=='scale' then
        local value=tonumber(arg)
        if not NS.Core.IsNumber(value) or value<0.5 or value>2 then Say('Scale must be 0.5 to 2.');return end
        db.scale=value;Modules.Apply('distance')
    elseif command=='reset' then Modules.Reset('distance')
    elseif command=='status' then
        Say('v0.4.0 | Utilities: '..#Modules.list)
        for _,definition in ipairs(Modules.list) do
            Say(definition.name..': '..(Modules.Settings(definition.id).enabled and 'enabled' or 'disabled'))
            local instance=Modules.instances[definition.id]
            if Modules.Settings(definition.id).enabled and instance and instance.Status then Say(instance.Status()) end
        end
    else Say('/futils opens the toolbox. Distance shortcuts: unlock | lock | on | off | scale 0.5..2 | reset | status') end
end
