require("src.core.utils")

local EventDispatcher = {}
EventDispatcher.listeners = {}

-- Function to let other scripts subscribe to an event
function EventDispatcher.subscribe(eventName, listenerFunction)
    if EventDispatcher.listeners[eventName] == nil then
        EventDispatcher.listeners[eventName] = {} -- Create a new list for this event
    end
    table.insert(EventDispatcher.listeners[eventName], listenerFunction)
end

-- Function to broadcast an event to all subscribers
function EventDispatcher.broadcast(eventName, ...)
    if EventDispatcher.listeners[eventName] == nil then
        return -- No one is listening, do nothing
    end

    -- Call every function that subscribed to this event
    for _, listener in ipairs(EventDispatcher.listeners[eventName]) do
        listener(...) -- Pass along any arguments
    end
end

function EventDispatcher.list()
    log(EventDispatcher.listeners)
end

return EventDispatcher