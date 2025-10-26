require("src.core.utils")
require("src.data.config")
require("src.data.random_names")


local target_reticle = require('src.modules.target_reticle_context_menu')
local events = require("src.core.events")
local promise = require("src.core.promise")
local utils = require("src.core.utils")

local _states = {
    ["player"] = {color = {0, 0, 0.545098}, state = 1},
    ["enemy"] = {color = {0.517647, 0, 0.098039}, bright = {0.94902, 0.184314, 0.32549}, state = 2},
    ["ally"] = {color = {0.039216, 0.368627, 0.211765}, bright = {0.352941, 0.823529, 0.603922}, state = 3},
    ["neutral"] = {color = {0.764706, 0.560784, 0}, bright = {0.933333, 0.741176, 0.219608}, state = 4}
}

_side = "enemy"

function onload()
    self.setTags({OBJECT_TAGS.npc_commander, OBJECT_TAGS.infinite_container})
    
    initializeSelfUI()

    events.subscribe(events.Event.parse_monster_data, "ParseMonsterData")
    events.subscribe(events.Event.create_json_note, "createNote")


    target_reticle.create("Mob Spawn Reticle", "monsterSpawnData", OBJECT_TAGS.monster_token)
    target_reticle.create("Save Card Reticle", "saveCardData", OBJECT_TAGS.clever_notecard)
end

function initializeSelfUI() 
    debug = #utils.getSeatedPlayers() == 1

    local inputs = {
        {
            -- name input							[0]
            name = "name",
            function_owner = self,
            label = " ",
            position = {-2.94, 0.4, -0.27},
            scale = {0.5, 0.5, 0.5},
            width = 2900,
            height = 424,
            font_size = 350,
            tooltip = "Name",
            value = debug and "/" or "",
            alignment = 2,
            tab = 2
        },
        {
            -- hp input								[2]
            name = "hp",
            function_owner = self,
            label = " ",
            position = {-3.88, 0.4, 0.55},
            scale = {0.5, 0.5, 0.5},
            width = 1100,
            height = 385,
            font_size = 350,
            tooltip = "Hit Points",
            value = debug and "5" or "",
            alignment = 3,
            tab = 2
        },
        {
            -- stress input								[2]
            name = "stress",
            function_owner = self,
            label = " ",
            position = {-2.7, 0.4, 0.55},
            scale = {0.5, 0.5, 0.5},
            width = 1100,
            height = 385,
            font_size = 350,
            tooltip = "Stress",
            value = debug and "5" or "",
            alignment = 3,
            tab = 2
        },
        {
            --difficulty input								[3]
            name = "difficulty",
            function_owner = self,
            label = "Difficulty",
            position = {-1.76, 0.4, 0.55},
            scale = {0.5, 0.5, 0.5},
            width = 650,
            height = 385,
            font_size = 350,
            tooltip = " ",
            alignment = 3,
            validation = 2,
            tab = 2,
            value = debug and "15" or ""
        },
        {
            -- black name						[4]
            name = "image",
            function_owner = self,
            label = " ",
            position = {2.7, 0.4, 1.38},
            scale = {0.5, 0.5, 0.5},
            width = 3150,
            height = 424,
            font_size = 350,
            tooltip = "Url to image (needs Is Boss to be true)",
            alignment = 2,
            tab = 2,
            value = ""
        },
        {
            -- numberToCreate input					[5]
            name = "number_to_create",
            function_owner = self,
            label = "NMB",
            position = {0.03, 0.4, 0.73},
            scale = {0.5, 0.5, 0.5},
            width = 870,
            height = 495,
            font_size = 320,
            color = {0.4941, 0.4941, 0.4941, 1},
            tooltip = "Number to Create",
            alignment = 3,
            validation = 2,
            tab = 2
        },
        {
            -- jsonImport input                     [6]
            input_function = "none",
            function_owner = self,
            label = "JSON IMPORT",
            position = {-3, 0.4, 1.35},
            scale = {0.5, 0.5, 0.5},
            color = {0.4941, 0.4941, 0.4941, 1},
            width = 2730,
            height = 425,
            font_size = 320,
            tooltip = "Import JSON stuff",
            alignment = 2
        },
        {
            -- boss token size bossSize              [7]
            name = "boss_size",
            function_owner = self,
            label = "Boss Size",
            position = {3.48, 0.4, -1.08},
            scale = {0.5, 0.5, 0.5},
            width = 1830,
            height = 425,
            font_size = 300,
            color = {0.4941, 0.4941, 0.4941, 1},
            tooltip = "Boss Token Size",
            alignment = 3,
            value = "Boss token size",
            validation = 3
        }
    }
    local buttons = {
        {
            -- size button							[0]
            click_function = "switch_size",
            function_owner = self,
            label = "Medium",
            tooltip = "Size",
            position = {3.64, 0.4, 0.62},
            scale = {0.5, 0.5, 0.5},
            width = 1630,
            height = 425,
            font_size = 320,
            color = {0.1921, 0.4431, 0.1921, 1},
            alignment = 2
        },
        {
            -- note button							[1]
            click_function = "create_json_note",
            function_owner = self,
            label = "Make Note",
            position = {1.95, 0.4, -0.24},
            scale = {0.5, 0.5, 0.5},
            width = 1730,
            height = 425,
            font_size = 320,
            color = {0.1921, 0.4431, 0.1921, 1},
            font_color = {0.6353, 0.8902, 0.6353, 1},
            alignment = 2
        },
        {
            -- create button						[2]
            click_function = "create_npc",
            function_owner = self,
            label = "CREATE",
            position = {0.03, 0.4, 0.23},
            scale = {0.5, 0.5, 0.5},
            width = 1620,
            height = 495,
            font_size = 320,
            color = {0.2823, 0.4039, 0.7686, 1},
            font_color = {0.8, 0.8196, 0.8862, 1},
            alignment = 2
        },
        {
            -- isBoss button						[3]
            click_function = "boss_checkbox",
            function_owner = self,
            label = "",
            position = {3.19, 0.4, -0.24},
            scale = {0.5, 0.5, 0.5},
            width = 425,
            height = 425,
            font_size = 320,
            color = {0.6196, 0.2431, 0.2431, 1},
            font_color = {0.6353, 0.8902, 0.6353, 1},
            tooltip = "false",
            alignment = 2
        },
        {
            -- allegiance button					[4]
            click_function = "switch_sides",
            function_owner = self,
            label = "Enemy",
            position = {1.88, 0.4, 0.62},
            scale = {0.5, 0.5, 0.5},
            width = 1630,
            height = 425,
            font_size = 320,
            color = _states["enemy"].color,
            alignment = 2
        },
        {
            -- name question button                      [5]
            click_function = "none",
            function_owner = self,
            label = "?",
            tooltip = "The names of monsters can be variegated, remember of these escape characters:" ..
                "\n- [FF4136]/[-] is for [b][FF4136]r[-][FF851B]a[-][FFDC00]n[-][2ECC40]d[-][0074D9]o[-][B10DC9]m[-] names[/b]" ..
                    "\n- [FF4136]%[-] is for [b]numbered creatures[/b] (only works for a set of monsters)",
            position = {-3.42, 0.4, -0.63},
            scale = {0.5, 0.5, 0.5},
            width = 290,
            height = 290,
            font_size = 270,
            color = {0.8972, 0.8915, 0.3673, 1},
            alignment = 2
        },
        {
            -- boss question button                     [6]
            click_function = "none",
            function_owner = self,
            label = "?",
            tooltip = "A boss is defined by its image, if it has one then it needs to be a boss." ..
                "To have a creature with image simply put the link to the image (hosted wherever, I suggest imgur)" ..
                    "in the [b][FF4136]description of the commander[-][/b] and click the button button to the immediate left" ..
                        "of this tutorial: \n[2ECC40]green[-] = boss\n[FF4136]red[-] = not boss",
            position = {4.25, 0.400000005960464, -0.12},
            scale = {0.5, 0.5, 0.5},
            width = 290,
            height = 290,
            font_size = 270,
            color = {0.8972, 0.8915, 0.3673, 1},
            alignment = 2
        },
        {
            -- clear button                            [7]
            click_function = "clear",
            function_owner = self,
            label = "↺",
            position = {-4, 0.400000005960464, -1.13},
            scale = {0.5, 0.5, 0.5},
            width = 490,
            height = 490,
            font_size = 470,
            color = {0.2823, 0.4039, 0.7686, 1},
            tooltip = "Clear",
            alignment = 2
        },
        {
            -- randomize button                     [8]
            click_function = "randomize",
            function_owner = self,
            label = "↝",
            position = {-3.5, 0.400000005960464, -1.13},
            scale = {0.5, 0.5, 0.5},
            width = 490,
            height = 490,
            font_size = 470,
            color = {0.2823, 0.4039, 0.7686, 1},
            tooltip = "Randomize\nPlease don't use this as an encounter builder",
            alignment = 2
        },
        {
            click_function = "parseJson",
            function_owner = self,
            label = "P",
            tooltip = "Parse JSON",
            -- position = {4.13, 0.400000005960464, 1.12},
            position = {-1.5, 0.400000005960464, 1.35},
            scale = {0.5, 0.5, 0.5},
            width = 640,
            height = 460,
            font_size = 270,
            color = {0.4941, 0.4941, 0.4941, 1},
            alignment = 2
        }
    }

    for i = 1, #inputs do

        if inputs[i].name then
            local funcName = "input_" .. inputs[i].name
            local func = function(_, _, value, stillEditing)
                manageInput(inputs[i].name, value)
            end
            self.setVar(funcName, func)
            inputs[i].input_function = funcName
        end

        self.createInput(inputs[i])
    end
    for i = 1, #buttons do
        self.createButton(buttons[i])
    end
end

function none() end

function manageInput(input_name, value)
    local possibleNames = {
        "name",
        "hp",
        "stress",
        "difficulty",
        "image",
        "number_to_create",
        "boss_size",
        "side"
    }

    if not utils.searchInArray(possibleNames, input_name) then
        return
    end

    utils.appendData(self, {
            [input_name] = value
    }, "exportData")
end

function clear()
    for i = 1, #self.getInputs() do
        self.editInput({index = i - 1, value = ""})
    end
end

function randomize()
    -- name input							[0]
    -- initiative input						[1]
    -- hp input								[2]
    -- ac input								[3]
    -- movement input						[4]
    -- numberToCreate input					[5]
    self.editInput({index = 0, value = "/"})
    self.editInput({index = 1, value = math.random(-2, 5)})
    self.editInput({index = 2, value = "r" .. math.random(1, 50) .. "-" .. math.random(51, 175)})
    self.editInput({index = 3, value = math.random(8, 17)})
    self.editInput({index = 4, value = math.random(1, 5) .. "0 ft"})
    self.editInput({index = 5, value = math.random(1, 9)})
end

-- name functions ---------------------------------------
function getName(number, literal)
    local inputs = self.getInputs()[1]
    local name = inputs.value
    if literal then
        return name
    end

    name = name:gsub("/", random_names[math.random(1, #random_names)])
    if number then
        name = name:gsub("%%", number)
    end
    return name
end

function setName(params)
    if params == nil or params.input == "" then return end
    self.editInput({index = 0, value = params.input})
end

-- hp ------------------------------------------------
function getHP(literal)
    local hp = self.getInputs()[3].value
    if literal then
        return hp
    end

    if string.sub(hp, 1, 1) == "r" then
        hp = string.gsub(hp, "r", "")
        local range = mysplit(hp, "-")
        hp = math.random(range[1], range[2])
    end

    return tonumber(hp)
end
function setHP(params)
    if params == nil or params.input == "" then return end
    self.editInput({index = 2, value = params.input})
end

-- ac ------------------------------------------------
function getAC()
    local input = self.getInputs()[4].value
    return input
end
function setAC(params)
    if params == nil or params.input == "" then return end
    self.editInput({index = 3, value = params.input})
end

-- movement ------------------------------------------
function getMovement()
    local input = self.getInputs()[5].value
    return input
end
function setMovement(params)
    if params == nil or params.input == "" then return end
    self.editInput({index = 4, value = params.input})
end

-- size ----------------------------------------------
function getSize(getData)
    local buttons = self.getButtons()[1]
    if not getData then
        return buttons.label
    else
        if not getBossCheckbox() then
            local scale = {}
            scale["Small"] = 0.17
            scale["Medium"] = 0.30
            scale["Large"] = 0.55
            scale["Huge"] = 0.90
            scale["Gargantuan"] = 1.20
            return scale[buttons.label]
        else
            local scale = {}
            scale["Small"] = 0.53
            scale["Medium"] = 0.78
            scale["Large"] = 1.45
            scale["Huge"] = 2.40
            scale["Gargantuan"] = 3.30
            return scale[buttons.label]
        end
    end
end

function switch_size(obj, player_clicker_color, alt_click)
    local sizes = {}
    sizes[1] = "Small"
    sizes[2] = "Medium"
    sizes[3] = "Large"
    sizes[4] = "Huge"
    sizes[5] = "Gargantuan"

    local currentSize = getSize()
    local c = 1
    for i = 1, #sizes do
        if sizes[i] == currentSize then
            c = alt_click and i - 1 or i + 1
        end
    end
    if c > #sizes then
        c = 1
    elseif c <= 0 then
        c = #sizes
    end
    self.editButton(
        {
            index = 0,
            label = sizes[c]
        }
    )

    utils.appendData(self, {
        exportData = {
            size = sizes[c]
        }
    })
end

function setSize(params)
    if params == nil or params.input == "" then return end
    self.editButton({index = 0, label = params.input})
end

-- boss checkbox -------------------------------------
function boss_checkbox()
    local btn = self.getButtons()[4]
    local isBoss = btn.tooltip == "true"
    local color = {
        red = {0.6196, 0.2431, 0.2431, 1},
        green = {0.1921, 0.4431, 0.1921, 1}
    }
    if not isBoss then
        self.editButton({index = 3, color = color.green})
        self.editButton({index = 3, tooltip = "true"})
    else
        self.editButton({index = 3, color = color.red})
        self.editButton({index = 3, tooltip = "false"})
    end

    utils.appendData(self, {
        boss = not isBoss
    }, "exportData")
end

function getBossCheckbox()
    local btn = self.getButtons()[4]
    return btn.tooltip == "true"
end

function toggleIsBoss(params)
    local btn = self.getButtons()[4]
    local color = {
        red = {0.6196, 0.2431, 0.2431, 1},
        green = {0.1921, 0.4431, 0.1921, 1}
    }

    if params.input then
        self.editButton({index = 3, color = color.green})
        self.editButton({index = 3, tooltip = "true"})
    else
        self.editButton({index = 3, color = color.red})
        self.editButton({index = 3, tooltip = "false"})
    end

    utils.appendData(self, {
        boss = params.input
    }, "exportData")
end

-- side ----------------------------------------------
function switch_sides()
    if _side == "enemy" then
        _side = "ally"
    elseif _side == "ally" then
        _side = "neutral"
    elseif _side == "neutral" then
        _side = "enemy"
    end
    self.editButton({index = 4, color = _states[_side].color})
    self.editButton({index = 4, label = _side:gsub("^%l", string.upper)})

    utils.appendData(self, {
        exportData = {
            side = _side
        }
    })
end

function setSide(params)
    if params == nil or params.input == "" then return end
    local side = string.lower(params.input)

    _side = side
    self.editButton({index = 4, color = _states[_side].color})
    self.editButton({index = 4, label = _side:gsub("^%l", string.upper)})
end

-- numberToCreate -------------------------------------
function setNumberToCreate(params)
    self.editInput({index = 5, value = params.input})
end

function getNumberToCreate()
    local input = self.getInputs()[6]
    if input.value == "" then
        return 1
    else
        return tonumber(input.value)
    end
end

-- boss size -----------------------------------------
function getBossSize()
    local input = self.getInputs()[8]
    if input.value == "" or input.value == nil then
        return 1.0
    end
    return input.value
end

function setBossSize(params)
    self.editInput({index = 7, value = params.input})
end

-- jsonImport ----------------------------------------
function getJsonImport()
    local input = self.getInputs()[7]
    return input.value
end

function lockInputs(toggle)
    for i = 1, #self.getButtons() do
        self.editButton({index = i - 1, enabled = toggle})
    end

    for i = 1, #self.getInputs() do
        self.editInput({index = i - 1, enabled = toggle})
    end
end

-- jsonImport ----------------------------------------
function getJsonImport()
    local input = self.getInputs()[7]
    return input.value
end
function parseJson(params)
    local json = getJsonImport()
    local data = JSON.decode(json)

    setName({input = data.name})
    -- setINI(({input = data.ini}))
    setHP(({input = data.hp}))
    setAC(({input = data.ac}))
    setMovement(({input = data.mov}))
    setSize({input = data.size})
    setSide({input = data.side})
    if data.image then
        toggleIsBoss({input = true})
        self.setDescription(data.image)
    else
        toggleIsBoss({input = false})
    end
end

--- @param args MonsterData
function ParseMonsterData(args) 
    debug("Event: " .. events.Event.parse_monster_data)

    local json = args[1]
    local data = JSON.decode(json)

    setName({input = data.name})
    -- setINI(({input = data.ini}))
    setHP(({input = data.hp}))
    setAC(({input = data.ac}))
    setMovement(({input = data.mov}))
    setSize({input = data.size})
    setSide({input = data.side})

    if data.image then
        toggleIsBoss({input = true})
        self.setDescription(data.image)
    else
        toggleIsBoss({input = false})
    end
end

function create_json_note(obj, player_clicker_color, alt_click)
    local data = utils.getData(self).exportData
    local vars = {
        name = data.name,
        -- ini = getInitiative(),
        hp = data.hp,
        stress = data.stress,
        difficulty = data.difficulty,
        size = data.size or "Medium",
        image = data.image or nil,
        side = data.side or "enemy",
        boss_size = data.boss_size or nil
    }
    local json = JSON.encode(vars)
    events.broadcast(events.Event.create_json_note, json)
end

function create_npc(obj, player_clicker_color, alt_click)
    -- local data = utils.getData(self).exportData

    -- local creation_params
    -- if data.boss then
    --     creation_params = {
    --         object_tag = OBJECT_TAGS.boss_token,
    --         is_boss = true
    --     }
    -- else
    --     creation_params = {
    --         object_tag = OBJECT_TAGS.monster_token,
    --         is_boss = false
    --     }
    -- end
    create_thing()
end

function create_thing()
    startLuaCoroutine(self, "creation_coroutine")
end

function creation_coroutine()
    local data = utils.getData(self).exportData
    local numberToCreate = data.number_to_create or 1
    local object_tag = data.boss and OBJECT_TAGS.boss_token or OBJECT_TAGS.monster_token

    log(object_tag)
    
    math.randomseed(os.time() + os.clock())

    for i = 1, numberToCreate do
        
        utils.useFromBag(self, function(spawned_object)
            promise.WaitUntilResting(spawned_object, function()
                local image = data.image
                spawned_object.use_hands = true

                -- We're making a copy because else the randomness will be the same
                local instanceData = {}
                for k, v in pairs(data) do
                    instanceData[k] = v
                end
                
                instanceData.name = interpretName(data.name, i) 

                if data.boss and data.image then
                    spawned_object.call("_starter", {image = image, boss_size = data.boss_size})
                end

                spawned_object.call("_init", { data = instanceData })
            end)
        end, nil, object_tag, "monsterSpawnData")
        coroutine.yield(0)
    end

    return 1
end

function interpretName(input, number)
    local name = input:gsub("/", random_names[math.random(1, #random_names)])

    if number then
        name = name:gsub("%%", tostring(number))
    end

    return name
end