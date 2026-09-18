local _, NS = ...
local Core = {}
NS.Core = Core

function Core.IsReadable(value)
    return not (issecretvalue and issecretvalue(value))
end

function Core.IsNumber(value)
    return Core.IsReadable(value) and type(value) == "number"
        and value == value and value > -math.huge and value < math.huge
end

