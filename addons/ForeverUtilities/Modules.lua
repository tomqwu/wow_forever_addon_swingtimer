local _, NS = ...
local Modules = {list={}, definitions={}, instances={}}
NS.Modules = Modules
function Modules.Register(definition)
    assert(type(definition.id)=='string' and not Modules.definitions[definition.id], 'Duplicate module')
    Modules.definitions[definition.id]=definition
    Modules.list[#Modules.list+1]=definition
end
function Modules.Initialize(db)
    Modules.db=db
    if type(db.modules)~='table' then db.modules={} end
    -- Preserve pre-toolbox distance preferences exactly once, without resetting other modules.
    if db.schemaVersion~=1 and type(db.modules.distance)~='table' then
        db.modules.distance={}
        local distance=Modules.definitions.distance
        if distance then
            for key in pairs(distance.defaults) do db.modules.distance[key]=db[key] end
        end
    end
    db.schemaVersion=1
    for _,definition in ipairs(Modules.list) do
        if type(db.modules[definition.id])~='table' then db.modules[definition.id]={} end
        local settings=db.modules[definition.id]
        for key,value in pairs(definition.defaults) do
            if type(settings[key])~=type(value) then settings[key]=value end
        end
        if definition.normalize then definition.normalize(settings) end
    end
    if not Modules.definitions[db.selectedModule] then db.selectedModule=Modules.list[1] and Modules.list[1].id end
    for _,definition in ipairs(Modules.list) do Modules.Apply(definition.id) end
end
function Modules.Settings(id) return Modules.db.modules[id] end
function Modules.Apply(id)
    local definition=assert(Modules.definitions[id], 'Unknown module')
    local settings=Modules.Settings(id)
    if definition.normalize then definition.normalize(settings) end
    local instance=Modules.instances[id]
    if settings.enabled and not instance then
        instance=definition.create(settings)
        Modules.instances[id]=instance
    end
    if instance then instance.Apply() end
    if Modules.changed then Modules.changed(id) end
end
function Modules.SetEnabled(id,enabled)
    assert(type(enabled)=='boolean','Expected boolean')
    Modules.Settings(id).enabled=enabled
    Modules.Apply(id)
end
function Modules.Reset(id)
    local settings=Modules.Settings(id)
    for key,value in pairs(Modules.definitions[id].defaults) do settings[key]=value end
    Modules.Apply(id)
end
