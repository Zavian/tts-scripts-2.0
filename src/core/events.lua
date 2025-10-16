local Events = {}

function Events.subscribe(eventName, func)
    Global.call("event_subscribe", {eventName = eventName, guid = self.getGUID(), functionName = func})
end

function Events.broadcast(eventName, ...)
    Global.call("event_broadcast", {eventName = eventName, args = {...}})
end

return Events
