
Utils = {}

require("src.data.config")


function _debug(msg, source)
    if not source then source = "DEBUG" end

    if #Utils.getSeatedPlayers() == 1 then
        print("[" .. os.date("%H:%M:%S") .. "][" .. source .. "] " .. msg)
    end
end

-- Updates the save state of the object with the provided data table
function Utils.updateSave(self, data)
    local saved_data = JSON.encode(data)
    self.script_state = saved_data
end

-- Returns the color associated with a player name (case insensitive). Must be defined in CONFIG.playersColors
function Utils.getColorByPlayer(player)
    player = string.lower(player)
    for k, v in pairs(CONFIG.playersColors) do
        if k == player then
            return v
        end
    end
    return nil
end

-- Returns the player name associated with a color. Must be defined in CONFIG.playersColors
function Utils.getPlayerByColor(color)
    for k, v in pairs(CONFIG.playersColors) do
        if v == color then
            return k
        end
    end
    return nil
end

-- Pretty prints a table to the console for debugging purposes
function Utils.printTable(t)
    local printTable_cache = {}

    local function sub_printTable(t, indent)
        if (printTable_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            printTable_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_printTable(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_printTable(t, "  ")
        print("}")
    else
        sub_printTable(t, "  ")
    end
end

-- Prints an error message to either the Black player (if seated) or to all players
function Utils.error(msg, private)
    if private and Utils.isColorSeated("Black") then
        broadcastToColor(msg, "Black", CONFIG.palette.red.rgb)
    else
        broadcastToAll(msg, CONFIG.palette.red.rgb) 
    end
end

function Utils.findBlackName(name)
    if name == nil then return nil end

    local pattern = ".+%((.+)%)"
    local _,
        _,
        found = string.find(name, pattern)
    if found ~= nil then
        return name:gsub("%(" .. found .. "%)", "")
    end

    return nil
end

-- Checks if a player color is currently seated at the table
function Utils.isColorSeated(color)
    return Player[color].seated
end

-- Converts a hex color string (e.g. "#RRGGBB" or "#RRGGBBAA") to a TTS color object
function Utils.hexToRgb(hex)
    hex = hex:gsub("#", "")
    if #hex < 8 then
        hex = hex .. "ff"
    end
    return color(
        tonumber("0x" .. hex:sub(1, 2), 16) / 255,
        tonumber("0x" .. hex:sub(3, 4), 16) / 255,
        tonumber("0x" .. hex:sub(5, 6), 16) / 255,
        tonumber("0x" .. hex:sub(7, 8), 16) / 255
    )
end

-- A safe way to check if a player is the host
function Utils.isHost(color)
    local player = getPlayerByColor(color)
    return player and player.host
end


-- Checks if an object with a given GUID still exists in the world
function objExists(guid)
    return getObjectFromGUID(guid) ~= nil
end

-- Finds the first object with a specific tag
function Utils.getObjectByTag(tag)
    local allObjects = getAllObjects()
    for _, obj in ipairs(allObjects) do
        if obj.hasTag(tag) then
            return obj
        end
    end
    return nil
end

-- Finds ALL objects with a specific tag
function Utils.getObjectsByTag(tag)
    local foundObjects = {}
    local allObjects = getAllObjects()
    for _, obj in ipairs(allObjects) do
        if obj.hasTag(tag) then
            table.insert(foundObjects, obj)
        end
    end
    return foundObjects
end

-- Safely retrieves and decodes a JSON string from an object's GM notes/memo
function Utils.getData(object)
    local dataString = object.getGMNotes()
    if dataString and dataString ~= "" then
        local data = JSON.decode(dataString)
        log(data["spawnData"]['position']['x'], "getData")
        return data
    end
    return {} -- Return an empty table on failure
end

-- Encodes a Lua table to JSON and saves it to an object's GM notes/memo
function Utils.setData(object, dataTable)
    local jsonString = JSON.encode(dataTable)
    object.setGMNotes(jsonString)
end

-- Encodes a Lua table to JSON to save it in the GM notes, appending it
function Utils.appendData(object, dataTable)
    print('hi')
    local data = Utils.getData(object)
    for k, v in pairs(dataTable) do
        data[k] = v
    end
    Utils.setData(object, data)
end

-- Load XML from self
function Utils.setXML(source_xml_obj, destination_obj)
    
    if not source_xml_obj then source_xml_obj = self end
    if not destination_obj then destination_obj = self end

    local script = source_xml_obj.getLuaScript()
    local xml = script:sub(script:find("StartXML")+8, script:find("StopXML")-1)
    destination_obj.UI.setXml(xml)
end

-- Load Lua script from self
function Utils.setLuaScript(source_lua_obj, destination_obj)
    
    if not source_lua_obj then source_lua_obj = self end
    if not destination_obj then destination_obj = self end

    local script = source_lua_obj.getLuaScript()
    local lua = script:sub(script:find("StartLua")+8, script:find("StopLua")-1)
    destination_obj.setLuaScript(lua)
end

function Utils.HighlightObject(obj, color, duration)
    if not obj or obj.isDestroyed() then return end
    if not color then color = {1,1,0} end
    if not duration then duration = 1 end

    obj.highlightOn(color, duration)
end

-- String split
function Utils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Get Seated Players
function Utils.getSeatedPlayers()
    local seated = {}
    for _, color in pairs(CONFIG.colors) do
        if Player[color].seated then
            table.insert(seated, color)
        end
    end
    return seated
end

-- Take something from a bag and use it
function Utils.useFromBag(bag, obj_function, bag_callback_function)
    local targeted_spawn = require("src.modules.target_reticle_context_menu")

    if not bag then return end

    if bag.type == "Infinite" then
        local position = targeted_spawn.getSpawnData("pos")
        local rotation = targeted_spawn.getSpawnData("rot")
        local obj = bag.takeObject({
            position = position,
            rotation = rotation
        })
        obj_function(obj)
        if bag_callback_function then bag_callback_function() end

        return obj
    end

    return nil
end

return Utils

-- Get seated players table
