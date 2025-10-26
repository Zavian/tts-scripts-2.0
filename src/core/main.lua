-- Main entry point for the TTS script
-- Load config first
require('src.data.config')


-- Laod core modules
local EventDispatcher = require('src.core.event_dispatcher')
local utils = require('src.core.utils')
local Updater = require('src.core.updater')
local Promise = require('src.core.promise')

-- Load UI Manager

-- Load Feature Modules

-- Global Variables
local COMPONENTS = {
    npc_commander = nil
}
local _SEARCHING = false

-- onload stuff
function onLoad(save_state)
    Promise.WaitFrames(35, function()
        initializeTableComponents()

        local newBoss = utils.getObjectByTag(OBJECT_TAGS.boss_token)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.boss_token, newBoss)

        local newMonster = utils.getObjectByTag(OBJECT_TAGS.monster_token)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.monster_token, newMonster)

        local newNote = utils.getObjectByTag(OBJECT_TAGS.clever_notecard)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.clever_notecard, newNote)
    end)
end

-- Event Handlers for bags
-- Basically pseudo infinite containers that respawn their contents when something is taken out
function onObjectLeaveContainer(container, leave_object)
    if _SEARCHING then return end

    if not container.hasTag(OBJECT_TAGS.infinite_container) then
        return false
    end

    local newObj = leave_object.clone({
        sound = false,
        position = container.getPosition()
    })
    container.putObject(newObj)
end
function tryObjectEnterContainer(container, object)
    if container == COMPONENTS.npc_commander and not _SEARCHING then
        return false
    end
    return true
end

function onObjectSearchStart(object, player_color)
    _SEARCHING = true
end

function onObjectSearchEnd(object, player_color)
    _SEARCHING = false
end

function initializeTableComponents()
    -- Here we initialize all the table items such as the npc commander or the player trackers
    local npc_commander = utils.getObjectByTag(OBJECT_TAGS.npc_commander)
    if npc_commander then
        COMPONENTS.npc_commander = npc_commander
    end
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