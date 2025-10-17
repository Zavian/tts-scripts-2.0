local utils = require("src.core.utils")
local target_reticle = require("src.modules.target_reticle_context_menu")
local promise = require("src.core.promise")
local events = require("src.core.events")
function onload()
    events.subscribe(events.Event.create_json_note, "createNote")
    self.setTags({OBJECT_TAGS.json_note_container})

    target_reticle.create()
end

function createNote(args)
    local json = args[1]
    local data = JSON.decode(json)
    
    local obj = utils.useFromBag(self, function(spawned_object)
        local name = utils.findBlackName(data.name)
        if name == nil then
            name = data.name
        end
        spawned_object.setName(name)
        spawned_object.setDescription(json)
    end)
    promise.WaitUntilResting(obj, function()
        obj.call("setData", {})
    end)
end
