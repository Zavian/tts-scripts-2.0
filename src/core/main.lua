-- Main entry point for the TTS script
-- Load config first
require('src.data.config')


-- Laod core modules
local EventDispatcher = require('src.core.event_dispatcher')
local Utils = require('src.core.utils')
local Updater = require('src.core.updater')
local Promise = require('src.core.promise')

-- Load UI Manager

-- Load Feature Modules

-- onload stuff
function onLoad(save_state)
    Promise.WaitFrames(35, function()
        initializeTableComponents()
    end)
end

function initializeTableComponents()
    -- Here we initialize all the table items such as the npc commander or the player trackers

end

function event_subscribe(params)
    local eventName = params.eventName
    local guid = params.guid
    local functionName = params.functionName
    local object = getObjectFromGUID(guid)
    if object ~= nil then
        EventDispatcher.subscribe(eventName, function(...)
            object.call(functionName, {...})
        end)
    end
end

function event_broadcast(params)
    local eventName = params.eventName
    local args = params.args
    if args == nil then
        args = {}
    end
    EventDispatcher.broadcast(eventName, unpack(args))
end

function list()
    EventDispatcher.list()
end