-- Main entry point for the TTS script
-- Load config first
require('src.data.config')


-- Laod core modules
local EventDispatcher = require('src.core.event_dispatcher')
local utils = require('src.core.utils')
local updater = require('src.core.updater')
local promise = require('src.core.promise')
local movement_measurement = require('src.core.movement_measurement')

-- Load UI Manager

-- Load Feature Modules

-- Global Variables
local COMPONENTS = {
    npc_commander = nil,
    movement_objects = {},
}
local _SEARCHING = false

-- onload stuff
function onLoad(save_state)
    promise.WaitFrames(35, function()
        initializeTableComponents()

        local newBoss = utils.getObjectByTag(OBJECT_TAGS.boss_token)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.boss_token, newBoss)

        local newMonster = utils.getObjectByTag(OBJECT_TAGS.monster_token)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.monster_token, newMonster)

        local newNote = utils.getObjectByTag(OBJECT_TAGS.clever_notecard)
        utils.replaceObjectInBagByTag(COMPONENTS.npc_commander, OBJECT_TAGS.clever_notecard, newNote)


        COMPONENTS.movementObjects = utils.getObjectsByTag(OBJECT_TAGS.movement_measurement)
        for _, obj in pairs(COMPONENTS.movementObjects) do
            movement_measurement.create(obj)
        end
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


function onObjectPickUp(player_color, pick_obj)
    if pick_obj.hasTag(OBJECT_TAGS.movement_measurement) then
        log(pick_obj, "pick_obj")
        log(pick_obj.guid, "pick_obj.guid")
        if movement_measurement.my_token == nil then
            movement_measurement.create(pick_obj)
            table.insert(COMPONENTS.movementObjects, pick_obj)
        end        
        movement_measurement.onPickUp(pick_obj, player_color)
    end
end

function onObjectDrop(player_color, drop_obj)
    if drop_obj.hasTag(OBJECT_TAGS.movement_measurement) then
        movement_measurement.onDrop(drop)
    end
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