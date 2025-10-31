--[[StartXML
<Defaults>
    <Button class="heal" colors="#2ECC40|#55DF65|#43A34E|gray" TextColor="white" textAlignment="MiddleCenter" FontSize="25" />
    <Button class="damage" colors="#FF4136|#FB8881|#C93931|gray" TextColor="black" textAlignment="MiddleCenter" FontSize="25" />
    <InputField textAlignment="MiddleCenter" FontSize="30" placeholder=" " />
    <Button class="condition" width="150" height="150" iconWidth="85" iconColor="White" onclick="UI_AddCondition(id)" onmouseenter="UI_ShowCondition(id)" onmouseexit="UI_DefaultCondition()" />
    <Button class="shape" width="150" height="150" iconWidth="85" iconColor="White" onclick="UI_AddCondition(id)" onmouseenter="UI_ShowCondition(id)" onmouseexit="UI_DefaultCondition()" fontSize="25" fontStyle="Bold" textColor="#353c45" />
    <Button class="reminder" width="150" height="65" fontSize="26" />

    <Image tooltipFontSize="25" tooltipPosition="Below" />
    <Cell dontUseTableCellBackground="true" />
    <Cell class="shield" image="https://steamusercontent-a.akamaihd.net/ugc/2426949702261775967/768DF5E97CB1FBE314C632B9FFDEB2D433A39690/" preserveAspect="true" />
    <Image class="hp" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
    <Image class="stress" image="https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/" />
</Defaults>


<Panel showAnimation="FadeIn" position="440 0 -50" width="650" height="350" rotation="0 0 0" color="#FFFFFF50" id="main">
    <TableLayout cellSpacing="12" cellPadding="16 16 0 0" useGlobalCellPadding="true" columnWidths="140 90 140 90 140"  id="thresholds" width="650" height="100" rectAlignment="UpperCenter">
        <Row height="100">
            <Cell>
                <Text text="Minor Damage" FontSize="25" FontStyle="Bold" />
            </Cell>
            <Cell class="shield">
                <Text id="first_threshold" text="2" FontSize="25" FontStyle="Bold" />
            </Cell>
            <Cell>
                <Text text="Major Damage" FontSize="25" FontStyle="Bold" />
            </Cell>
            <Cell class="shield">
                <Text id="second_threshold" text="5" FontSize="25" FontStyle="Bold" />
            </Cell>
            <Cell>
                <Text text="Severe Damage" FontSize="25" FontStyle="Bold" />
            </Cell>
        </Row>
    </TableLayout>

    <Panel rectAlignment="MiddleCenter" width="650" height="130">
        <Text offsetXY="0 45" rectAlignment="UpperCenter" fontStyle="Bold" fontSize="28" color="#00000FF">Hit Points</Text>
        <Image id="suffer_hp" image="https://img.icons8.com/?size=100&id=Tojai3dG2qCO&format=png&color=000000" width="50" height="50" rectAlignment="MiddleLeft" offsetXY="120 0" />
        <GridLayout rectAlignment="LowerCenter" width="275" height="100" childAlignment="MiddleCenter" spacing="5" childForceExpandHeight="false" cellSize="36 36">
            
        </GridLayout>
        <Image id="recover_hp" image="https://img.icons8.com/?size=100&id=DqbopJbItzS5&format=png&color=000000" width="50" height="50" rectAlignment="MiddleRight" offsetXY="-120 0" />
    </Panel>

    <Panel rectAlignment="LowerCenter" width="650" height="110">
        <Text offsetXY="0 55" rectAlignment="UpperCenter" fontStyle="Bold" fontSize="28" color="#00000FF">Stress Points</Text>
        <Image id="suffer_stress" image="https://img.icons8.com/?size=100&id=Tojai3dG2qCO&format=png&color=000000" width="50" height="50" rectAlignment="MiddleLeft" offsetXY="120 0" />
        <GridLayout rectAlignment="LowerCenter" width="275" height="100" childAlignment="MiddleCenter" spacing="5" childForceExpandHeight="false" cellSize="36 36">
            
        </GridLayout>
        <Image id="recover_stress" image="https://img.icons8.com/?size=100&id=DqbopJbItzS5&format=png&color=000000" width="50" height="50" rectAlignment="MiddleRight" offsetXY="-120 0" />
    </Panel>
</Panel>

<Panel showAnimation="FadeIn" id="ConditionMenu" width="550" height="425" position="-310 0 -50" color="#FFFFFF50" scale=".75 .75 .75">
    
    <Image tooltip="Set data" offsetXY="5 5" rectAlignment="LowerLeft" width="70" height="70" image="https://img.icons8.com/?size=100&id=VYNAObipyf4p&format=png&color=000000">Condition</Image>
</Panel>

<Panel showAnimation="FadeIn" id="ReminderMenu" width="435" height="155" position="0 -280 -50" color="#FFFFFF50" scale=".75 .75 .75">
    <Text offsetXY="0 60" fontStyle="Bold" fontSize="28" color="#00000FF">Manage Reminders</Text>
    <Button class="reminder" offsetXY="-90 0" onClick="UI_ManageStartReminder">Start</Button>
    <Button class="reminder" offsetXY="90 0" onClick="UI_ManageEndReminder">End</Button>
</Panel>
StopXML--xml]]
require("src.data.config")

local utils = require("src.core.utils")

local imageAssets = {
    armor = {
        empty = "https://steamusercontent-a.akamaihd.net/ugc/9694915526965512541/CF069EC63EA00DC557F7F7789824FD2DF7C01967/",
        filled = "https://steamusercontent-a.akamaihd.net/ugc/17986014787525797611/84F0E34394978D49F11687C5B0659314DCDB14AD/"
    },
    hope = {
        empty = "https://steamusercontent-a.akamaihd.net/ugc/12708366135666346318/BB64E4C4F488D80BE6E4F71C3338027600E499AF/",
        filled = "https://steamusercontent-a.akamaihd.net/ugc/12670953746498142696/BE3FF12AC9766F669C026E325E3A14FB21FAC75C/"
    }
}

local linked = nil


function onLoad()
    -- utils.setXML(self, self)

    Wait.frames(function()
        local guid = self.getGUID()

        -- Right Panel
        self.UI.setAttribute("suffer_hp", "onClick", guid .. "/UI_LoseVariable(hp)")
        self.UI.setAttribute("recover_hp", "onClick", guid .. "/UI_GainVariable(hp)")
        self.UI.setAttribute("suffer_stress", "onClick", guid .. "/UI_LoseVariable(stress)")
        self.UI.setAttribute("recover_stress", "onClick", guid .. "/UI_GainVariable(stress)")
        
        self.UI.setAttribute("set_max_hp", "onClick", guid .. "/UI_SetVariable(max_hp)")
        self.UI.setAttribute("set_max_stress", "onClick", guid .. "/UI_SetVariable(max_stress)")
        self.UI.setAttribute("first_threshold", "onClick", guid .. "/UI_SetVariable(first_threshold)")
        self.UI.setAttribute("second_threshold", "onClick", guid .. "/UI_SetVariable(second_threshold)")

        -- Left Panel
        self.UI.setAttribute("lose_hope", "onClick", guid .. "/UI_LoseVariable(hope)")
        self.UI.setAttribute("gain_hope", "onClick", guid .. "/UI_GainVariable(hope)")
        self.UI.setAttribute("lose_armor", "onClick", guid .. "/UI_LoseVariable(armor)")
        self.UI.setAttribute("gain_armor", "onClick", guid .. "/UI_GainVariable(armor)")

        self.UI.setAttribute("set_max_armor", "onClick", guid .. "/UI_SetVariable(max_armor)")
        
        
        -- self.UI.hide("main")
        -- self.UI.hide("ConditionMenu")
        -- self.UI.hide("ReminderMenu")

        hidePanel("RightPanel")
        hidePanel("LeftPanel")
            
    end, 20)


    self.createButton(
    {
        click_function = "InjectMini",
        function_owner = self,
        label = "Link",
        position = {0, 0.4, 0},
        rotation = {180, 0, 180},
        scale = {0.5, 0.5, 0.5},
        width = 1800,
        height = 1200,
        font_size = 400,
        color = CONFIG.palette.green.rgb
    }
)

end

function InjectMini(_, player_color)
    local data = utils.getData(self)
    if data.max_hp == nil or data.max_stress == nil then
        utils.warning("Please set Max HP and Max Stress then click the button again.", player_color)
    end

    showPanel("RightPanel")
    showPanel("LeftPanel")
end

function showPanel(panel)
    self.UI.show(panel)
end

function hidePanel(panel)
    self.UI.hide(panel)
end

function setMaxHP(amount, player_color)
    amount = tonumber(amount)

    if (amount < 1) then
        amount = 1
    end

    if (amount > 12) then
        utils.error("Max HP cannot exceed 12.", player_color)
        return
    end

    local xml_table = self.UI.getXmlTable()
    local grid = utils.UI_findElementById(xml_table, "hp")  

    grid.children = {}

    for i = 1, amount do
        local image = {
            tag = "Image",
            attributes = {
                class = "hp",
                id = "hp_" .. i
            }
        }
        
        table.insert(grid.children, image)
    end

    self.UI.setXmlTable(xml_table)
    utils.appendData(self, {max_hp = amount})
end

function setMaxStress(amount, player_color)
    amount = tonumber(amount)

    if (amount < 1) then
        amount = 1
    end

    if (amount > 12) then
        utils.error("Max Stress cannot exceed 12.", player_color)
        return
    end

    local xml_table = self.UI.getXmlTable()
    local grid = utils.UI_findElementById(xml_table, "stress")

    grid.children = {}    

    for i = 1, amount do
        local image = {
            tag = "Image",
            attributes = {
                class = "stress",
                id = "stress_" .. i
            }
        }
        table.insert(grid.children, image)
    end

    self.UI.setXmlTable(xml_table)
    utils.appendData(self, {max_stress = amount})
end

function setArmorSlots(amount, player_color)
    amount = tonumber(amount)

    if (amount < 1) then
        amount = 1
    end

    if (amount > 18) then
        utils.error("Armor Slots cannot exceed 18.", player_color)
        return
    end

    local xml_table = self.UI.getXmlTable()
    local grid = utils.UI_findElementById(xml_table, "armor_slots")

    grid.children = {}

    for i = 1, amount do
        local image = {
            tag = "Image",
            attributes = {
                class = "armor-filled",
                id = "armor_" .. i
            }
        }
        table.insert(grid.children, image)
    end

    self.UI.setXmlTable(xml_table)
    utils.appendData(self, {max_armor = amount})
end


function UI_SetVariable(player_color, variable)
    player_color.showInputDialog("Set " .. Utils.capitalize(variable:gsub("_", " ")),
        function (text, player_color)
            if text == "" or text == nil then 
                utils.error("Must input something", player_color.color)
                return 
            end

            local callback = {
                ["max_hp"] = function()
                    setMaxHP(text, player_color.color)
                end,
                ["max_stress"] = function()
                    setMaxStress(text, player_color.color)
                end,
                ["max_armor"] = function()
                    setArmorSlots(text, player_color.color)
                end
            }
            
            if callback[variable] then
                callback[variable]()
            else
                self.UI.setAttribute(variable, "text", text)
                utils.appendData(self, {[variable] = text})
            end
        end
    )
end

function UI_GainVariable(player_color, variable)
    if (variable == "hp") then
        recoverHP()
    elseif (variable == "stress") then
        recoverStress()
    elseif (variable == "armor") then
        gainArmor()
    elseif (variable == "hope") then
        gainHope()
    else
        utils.error("Invalid variable", player_color.color)
    end
end

function UI_LoseVariable(player_color, variable)
    if (variable == "hp") then
        sufferHP()
    elseif (variable == "stress") then
        sufferStress()
    elseif (variable == "armor") then
        loseArmor()
    elseif (variable == "hope") then
        loseHope()
    else
        utils.error("Invalid variable", player_color.color)
    end
end

function sufferHP()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "hp")
    for i = #target.children, 1, -1 do
        local color = self.UI.getAttribute("hp_"..i, "color")
        if not color or color == "#ffffff" then
            self.UI.setAttribute("hp_"..i, "color", "#000000")
            utils.appendData(self, {hp = i - 1})
            return
        end
    end
end

function recoverHP()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "hp")
    for i = 1, #target.children do
        local color = self.UI.getAttribute("hp_"..i, "color")
        if color and color == "#000000" then
            self.UI.setAttribute("hp_"..i, "color", "#ffffff")
            utils.appendData(self, {hp = i })
            return
        end
    end
end

function sufferStress()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "stress")
    for i = #target.children, 1, -1 do
        local color = self.UI.getAttribute("stress_"..i, "color")
        if not color or color == "#ffffff" then
            self.UI.setAttribute("stress_"..i, "color", "#000000")
            utils.appendData(self, {stress = i - 1})
            return
        end
    end
end

function recoverStress()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "stress")
    for i = 1, #target.children do
        local color = self.UI.getAttribute("stress_"..i, "color")
        if color and color == "#000000" then
            self.UI.setAttribute("stress_"..i, "color", "#ffffff")
            utils.appendData(self, {stress = i })
            return
        end
    end
end

function loseArmor()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "armor_slots")
    for i = #target.children, 1, -1 do
        local image = self.UI.getAttribute("armor_"..i, "image")
        if not image or image == imageAssets.armor.filled then
            self.UI.setAttribute("armor_"..i, "image", imageAssets.armor.empty)
            utils.appendData(self, {armor = i - 1})
            return
        end
    end
end

function gainArmor()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "armor_slots")
    for i = 1, #target.children do
        local image = self.UI.getAttribute("armor_"..i, "image")
        print(image)
        if image and image == imageAssets.armor.empty then
            self.UI.setAttribute("armor_"..i, "image", imageAssets.armor.filled)
            utils.appendData(self, {armor = i })
            return
        end
    end
end

function loseHope()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "hope")
    for i = #target.children, 1, -1 do
        local image = self.UI.getAttribute("hope_"..i, "image")
        if not image or image == imageAssets.hope.filled then
            self.UI.setAttribute("hope_"..i, "image", imageAssets.hope.empty)
            utils.appendData(self, {hope = i - 1})
            return
        end
    end
end

function gainHope()
    local xml_table = self.UI.getXmlTable()
    local target = utils.UI_findElementById(xml_table, "hope")
    for i = 1, #target.children do
        local image = self.UI.getAttribute("hope_"..i, "image")
        print(image)
        if image and image == imageAssets.hope.empty then
            self.UI.setAttribute("hope_"..i, "image", imageAssets.hope.filled)
            utils.appendData(self, {hope = i })
            return
        end
    end
end