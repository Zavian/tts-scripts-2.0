--- @class MonsterData
--- @field name string
--- @field hp string
--- @field ac string
--- @field mov string
--- @field size string
--- @field side string
--- @field image string (optional)

local Events = {}

-- Dictionary for possible events
Events.EVENT_NAMES = {
    parse_monster_data = "parse_monster_data",
    create_json_note = "create_json_note",

    -- in development
    player_hp_update = "player_hp_update",
    monster_hp_update = "monster_hp_update",
    monster_stress_update = "monster_stress_update",
    ruin_update = "ruin_update",
    on_roll = "on_roll",
    create_monster = "create_monster"
}



--- Subscribes to an event.
--- @param eventName string The name of the event.
--- @param func string The callback function name.
--- @overload fun(eventName: "parse_monster_data", func: fun(data: MonsterData))
--- @overload fun(eventName: "create_json_note", func: fun(data: MonsterData))
function Events.subscribe(eventName, func)
    Global.call("event_subscribe", {eventName = eventName, guid = self.getGUID(), functionName = func})
end

--- Broadcasts an event.
--- @param eventName string The name of the event.
--- @param ... any The event data.
--- @overload fun(eventName: "parse_monster_data", data: MonsterData)
--- @overload fun(eventName: "create_json_note", data: MonsterData)
function Events.broadcast(eventName, ...)
    Global.call("event_broadcast", {eventName = eventName, args = {...}})
end

return Events