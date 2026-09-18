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

function Core.Start(state, duration, now)
    if not Core.IsNumber(duration) or duration <= 0 or duration > 120 then
        state.finish, state.duration = nil, nil
        return false
    end
    state.duration, state.finish = duration, now + duration
    return true
end

function Core.Sample(state, now)
    if not state.finish then return nil end
    local remaining = state.finish - now
    if remaining <= 0 then
        state.finish, state.duration = nil, nil
        return nil
    end
    return remaining, math.max(0, math.min(1, 1 - remaining / state.duration))
end
