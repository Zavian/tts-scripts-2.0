local data = {
    hp = 5,
    maxHp = 5,
    stress = 3,
    maxStress = 3,
    ui_table = {}
}

local images = {
    hp = "https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/",
    stress = "https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/"
}

function set_data(params)
    if not params or not params.hp or not params.stress then
        return 
    end

    self.setTags({"player_token", "movement_measurement"})
    data.hp = tonumber(params.hp)
    data.maxHp = tonumber(params.hp)
    data.stress = tonumber(params.stress)
    data.maxStress = tonumber(params.stress)
    setupUI()
end

function setupUI()
    local xmlTable = {
        {
            tag = "GridLayout",
            attributes = {
                scale = "1 1 1",
                childAlignment = "MiddleCenter",
                constraint = "FixedRowCount",
                constraintCount = "1",
                position = "0 0 -300",
                rotation = "270 0 0",
                id = "hp_container"
            },
            children = {}            
        },
        {
            tag = "GridLayout",
            attributes = {
                scale = "1 1 1",
                childAlignment = "MiddleCenter",
                constraint = "FixedRowCount",
                constraintCount = "1",
                position = "0 0 -250",
                rotation = "270 0 0",
                id = "stress_container"
            },
            children = {}
        }
    }

    xmlTable = setMaxHP(data.maxHp, xmlTable)
    xmlTable = setMaxStress(data.maxStress, xmlTable)


    self.UI.setXmlTable(xmlTable)    
end

---Linearly interpolates a value from an input range to an output range.
---@param value number The current input value to convert.
---@param inputStart number The lower bound of the input range.
---@param inputEnd number The upper bound of the input range.
---@param outputStart number The corresponding lower bound of the output range.
---@param outputEnd number The corresponding upper bound of the output range.
---@return number The interpolated value in the output range.
function interpolate(value, inputStart, inputEnd, outputStart, outputEnd)
    -- Calculate how far the value is through the input range (as a percentage from 0.0 to 1.0)
    local t = (value - inputStart) / (inputEnd - inputStart)

    -- Clamp the percentage to be between 0 and 1, ensuring the output stays within the desired range
    t = math.max(0, math.min(1, t))

    -- Apply the clamped percentage to the output range to get the final value
    return outputStart + (outputEnd - outputStart) * t
end

function setMaxHP(amount, t)
    -- Define the range for the amount that will affect the icon size.
    -- For example, let's say the size starts decreasing after 1 icon and stops at 10 icons.
    local min_amount = 6
    local max_amount = 12

    -- Define the corresponding icon size range.
    local max_icon_size = 50
    local min_icon_size = 25

    -- Linearly interpolate to find the icon size.
    local icon_size = interpolate(amount, min_amount, max_amount, max_icon_size, min_icon_size)
    icon_size = math.floor(icon_size) -- It's good practice to use whole numbers for UI element sizes.

    t[1].attributes.cellSize = icon_size .. " " .. icon_size

    t[1].children = {}

    for i = 1, amount do
        local icon = {
            tag = "Image",
            attributes = {
                width = icon_size,
                height = icon_size,
                image = images.hp,
                id = "hp_" .. i
            }
        }
        table.insert(t[1].children, icon)
    end
    return t
end

function setMaxStress(amount, t)
    -- Define the range for the amount that will affect the icon size.
    -- For example, let's say the size starts decreasing after 1 icon and stops at 10 icons.
    local min_amount = 6
    local max_amount = 12

    -- Define the corresponding icon size range.
    local max_icon_size = 50
    local min_icon_size = 25

    -- Linearly interpolate to find the icon size.
    local icon_size = interpolate(amount, min_amount, max_amount, max_icon_size, min_icon_size)
    icon_size = math.floor(icon_size) -- It's good practice to use whole numbers for UI element sizes.

    t[2].attributes.cellSize = icon_size .. " " .. icon_size

    t[2].children = {}

    for i = 1, amount do
        local icon = {
            tag = "Image",
            attributes = {
                width = icon_size,
                height = icon_size,
                image = images.stress,
                id = "stress_" .. i
            }
        }
        table.insert(t[2].children, icon)
    end
    return t
end

function sufferHP()
    local target = self.UI.getXmlTable()[1]
    for i = #target.children, 1, -1 do
        local color = self.UI.getAttribute("hp_"..i, "color")
        if not color or color == "#ffffff" then
            self.UI.setAttribute("hp_"..i, "color", "#000000")
            data.hp = data.hp - 1
            return
        end
    end
end

function healHP()
    local target = self.UI.getXmlTable()[1]
    for i = 1, #target.children do
        local color = self.UI.getAttribute("hp_"..i, "color")
        if color and color == "#000000" then
            self.UI.setAttribute("hp_"..i, "color", "#ffffff")
            data.hp = data.hp + 1
            return
        end
    end
end

function sufferStress()
    local target = self.UI.getXmlTable()[2]
    for i = #target.children, 1, -1 do
        local color = self.UI.getAttribute("stress_"..i, "color")
        if not color or color == "#ffffff" then
            self.UI.setAttribute("stress_"..i, "color", "#000000")
            data.stress = data.stress - 1
            return
        end
    end
end

function healStress()
    local target = self.UI.getXmlTable()[2]
    for i = 1, #target.children do
        local color = self.UI.getAttribute("stress_"..i, "color")
        if color and color == "#000000" then
            self.UI.setAttribute("stress_"..i, "color", "#ffffff")
            data.stress = data.stress + 1
            return
        end
    end
end

function getHP()
    return data.hp
end

function getStress()
    return data.stress
end


