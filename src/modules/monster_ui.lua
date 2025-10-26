--- Credits
-- Daggerheart [Unofficial]
-- Original Author: Marum
-- Workshop Link: https://steamcommunity.com/sharedfiles/filedetails/?id=3181973858

require("src.data.config")
local utils = require("src.core.utils")

local state = nil
local ready = false
local lastAng = -1
local frame = 0
local data={
    name = "Monster",
    hp = 5,
    maxHp = 5,
    stress = 3,
    maxStress = 3,
    difficulty = 10,
    showing = true,
    height = -1
}

function onUpdate()
    if (ready) then
        frame = frame+1
        if (frame % 8 == 0 or self.isSmoothMoving()) then
            alignPivot()
        end
    end
end

function _starter(params)
    log(params)
    self.setCustomObject(
        {
            image = params.image,
            image_scalar = params.boss_size
        }
    )
end

function _init(params)
    local json
    
    if (params) then
        json = params.data
    else return end

    log(json)

    data.hp = json.hp
    data.maxHp = json.hp
    data.stress = json.stress
    data.maxStress = json.stress
    data.difficulty = json.difficulty
    
    
    data.name = json.name
    data.image = json.image
    data.boss_size = json.boss_size

    self.script_state = JSON.encode(data)

    local n = self.reload()

    local blackHand = Player["Black"].getHandTransform()
    if blackHand then 
        n.setPosition(blackHand.position) 
        n.setRotation(Vector(0,0,0))
    end
end

function onPickUp()
    self.UI.hide("pivot")
end

function onDrop()
    lastAng = -1
    alignPivot()
    if (data.showing) then
        self.UI.show("pivot")
    end
end

function updateSave()
    utils.updateSave(self, data)
end

function alignPivot()
    local p = Player["Black"]
    if (p) then
        local pRot = p.getPointerRotation()
        if (pRot ~=nil and (pRot ~=lastAng or self.isSmoothMoving())) then
            lastAng = pRot
            local rot = self.getRotation()
            local ang = Vector(-rot.x, -rot.z, rot.y-pRot+180)
            local scale = self.getScale()
            local object_type = self.type
            
            if( not data.height or data.height < 0 ) then
                if (object_type == "Figurine") then
                    data.height = 150
                else 
                    data.height = 175
                end
            end
    
            self.UI.setAttributes("scale", {
                scale=1/scale.x.." "..1/scale.z.." "..1/scale.y
            })
            self.UI.setAttributes("pivot", {
                rotation=ang.x.." "..ang.y.." "..ang.z
            })


            self.UI.setAttributes("height", {
                position="0 0 "..tostring(-data.height)
            })
        end
    end
end

function setName(name)
    self.UI.setValue("craeatureName", name)
    data.name = name
    updateSave()
end

function increaseHP()
    changeHP(1)
    callForAllSelected("changeHP", 1)
end

function decreaseHP()
    changeHP(-1)
    callForAllSelected("changeHP", -1)
end

function setMaxHP(amount)
    print("setMaxHP function")
    print("amount:", amount)
    if (data.hp == data.maxHp) then
        print("data.hp equals data.maxHp")
        data.hp = tonumber(amount)
    end
    data.maxHp = tonumber(amount)
    local vals = {
        scale=2.1/amount.." 0.35 0.25",
        width=100*amount
    }
    log(vals, "vals")
    local smallvals = {
        scale=1.45/amount.." 0.25 0.5",
        width=100*amount
    }
    if (tonumber(data.hp) > tonumber(amount)) then
        print("data.hp is greater than amount")
        data.hp = tonumber(amount)
    end
    changeHP(0)
    self.UI.setAttributes("hp", vals)
    self.UI.setAttributes("smallhp", smallvals)
    updateSave()
end
function changeHP(amount)
    data.hp = tonumber(data.hp)+tonumber(amount)
    if (tonumber(data.hp) <= 0) then
        data.hp = 0
        self.UI.setAttribute("hp", "color", "#ff0000ff")
        self.UI.setAttribute("smallHp", "color", "#ff0000ff")
    else
        self.UI.setAttribute("hp", "color", "Black")
        self.UI.setAttribute("smallHp", "color", "Black")
    end
    if (tonumber(data.hp) > tonumber(data.maxHp)) then data.hp = data.maxHp end
    self.UI.setValue("hp", barString("□", "■", data.hp, data.maxHp))
    self.UI.setValue("smallhp", barString("□", "■", data.hp, data.maxHp))
    updateSave()
end

function increaseStress()
    changeStress(1)
    callForAllSelected("changeStress", 1)
end
function decreaseStress()
    changeStress(-1)
    callForAllSelected("changeStress", -1)
end

function changeStress(amount)
    data.stress = data.stress+amount
    if (tonumber(data.stress) <= 0) then
        data.stress = 0
        self.UI.setAttribute("stress", "color", "#ff6a00ff")
        self.UI.setAttribute("smallstress", "color", "#ff6a00ff")
    else
        self.UI.setAttribute("stress", "color", "Black")
        self.UI.setAttribute("smallstress", "color", "Black")
    end
    if (tonumber(data.stress) > tonumber(data.maxStress)) then data.stress = data.maxStress end
    self.UI.setValue("stress", barString("□", "■", data.stress, data.maxStress))
    self.UI.setValue("smallstress", barString("□", "■", data.stress, data.maxStress))
    updateSave()
end


function toggleUI(player_color)
    if (data.showing) then
        hideUI()
        callForAllSelected("hideUI")
    else
        showUI()
        callForAllSelected("showUI")
    end
end
function hideUI()
    data.showing = false
    self.UI.hide("pivot")
    updateSave()
end
function showUI()
    data.showing = true
    self.UI.show("pivot")
    updateSave()
end
function callForAllSelected(func, param)
    for k, v in pairs(Player["Black"].getSelectedObjects()) do
        if (hasScriptingTags(v) and v ~=self) then
            v.call(func, param)
        end
    end
end

function raiseUI()
    lastAng = -1
    data.height = data.height + 25
    alignPivot()
    updateSave()
end

function lowerUI()
    lastAng = -1
    data.height = data.height - 25
    alignPivot()
    updateSave()
end

function barString(full, empty, amount, max)
    return string.rep(full, amount)..string.rep(empty,math.max(0, max-amount))
end

function onload(saved_data)
    if (saved_data ~= "") then
        data = JSON.decode(saved_data)
    end
    
    local object_type = self.type

    if (object_type == "Figurine") then
        self.setTags({OBJECT_TAGS.monster_token})
    else 
        self.setTags({OBJECT_TAGS.boss_token})
    end

    setupDMUI()
end

function setupDMUI()
    self.addContextMenuItem("Toggle UI", toggleUI, true)
    self.addContextMenuItem("Raise UI", raiseUI, true)
    self.addContextMenuItem("Lower UI", lowerUI, true)
    self.addContextMenuItem("Set Name", function()
        Player["Black"].showInputDialog("Set Name", data.name,
            function (text, player_color)
                setName(text)
            end
        )
    end, true)
    self.UI.setCustomAssets({{
        type=0,
        name="bars",
        url="https://steamusercontent-a.akamaihd.net/ugc/10744411922391955301/63FC0CC8C7BAAF5ED059C3170C5716F67152C8C6/"
    },
    {
        type=0,
        name="full",
        url="https://steamusercontent-a.akamaihd.net/ugc/17575880191213685112/86FE092CB588ED8B9241E28C5F7BC242347A397F/"
    },
    {
        type=0,
        name="cross",
        url="https://steamusercontent-a.akamaihd.net/ugc/2458480429345457547/13A122E49D432AC41893940503983AE71FA6B6DF/"
    }})
    Wait.time(function() 
        ready = true
        
        
        local XMLString = [[
            <Defaults>
                <Button visibility="Black"/>
                <InputField visibility="Black"/>
                <Button tooltipOffset="-25" tooltipBackgroundColor="#000000ff" color="#ffffff00" textColor="#000000ff" textAlignment="MiddleCenter"/>
                <Button class="clickable" color="#ffffffff" colors="#ffffff00|#ffff0040|#00000040|#ffffff00"/>
                <Image class="condition" width="5000" height="5000" scale="1 1 1"/>
            </Defaults>
            <Panel id="scale">
                <Panel id="pivot" visibility="Black" active="]]..tostring(data.showing)..[[" offsetXY="0 0" scale="1 1 1" rotation="0 0 0">
                    <Panel id="height">
                        <Panel id="container" offsetXY="0 0" scale="2 2 2" rotation="-45 0 0">
                            <Image
                                id="bars"
                                image="bars"
                                offsetXY="0 20"
                                width="200"
                                height="85"
                                scale="0.525 0.525 0.525"
                            >
                                <Text
                                    id="smallhp"
                                    color="Black"
                                    fontSize="150"
                                    width="]]..100*data.maxHp..[["
                                    height="200"
                                    offsetXY="17 -2"
                                    scale="]]..1.45/data.maxHp..[[ 0.25 0.25"
                                >]]..barString("□", "■", data.hp, data.maxHp)..[[</Text>

                                <Text
                                    id="smallstress"
                                    color="Black"
                                    fontSize="150"
                                    width="]]..100*data.maxStress..[["
                                    height="200"
                                    offsetXY="17 -29"
                                    scale="]]..1.45/data.maxStress..[[ 0.17 0.25"
                                >]]..barString("□", "■", data.stress, data.maxStress)..[[</Text>

                                <Text
                                    id="smallDifficulty"
                                    color="Black"
                                    fontSize="30"
                                    width="60"
                                    height="60"
                                    offsetXY="0 23"
                                    scale="0.8 0.8 0.8"
                                    alignment="MiddleCenter"
                                >]]..data.difficulty..[[</Text>

                                <Button
                                    id="incHPSmall"
                                    onClick="increaseHP"
                                    class="clickable"
                                    offsetXY="90 -1"
                                    width="40"
                                    height="40"
                                ></Button>
                                <Button
                                    id="decHPSmall"
                                    onClick="decreaseHP"
                                    class="clickable"
                                    offsetXY="-90 -1"
                                    width="40"
                                    height="40"
                                ></Button>

                                <Button
                                    id="incStressSmall"
                                    onClick="increaseStress"
                                    class="clickable"
                                    offsetXY="90 -40"
                                    width="40"
                                    height="40"
                                ></Button>
                                <Button
                                    id="decStressSmall"
                                    onClick="decreaseStress"
                                    class="clickable"
                                    offsetXY="-90 -40"
                                    width="40"
                                    height="40"
                                ></Button>
                            </Image>
                        </Panel>
                    </Panel>
                </Panel>
            </Panel>
        ]]

        -- local scale = self.getScale()
        -- local panelScale = 0.005
        -- local scaleString = tostring(1/scale.x*panelScale).." "..tostring(1/scale.z*panelScale).." "..tostring(1/scale.y*panelScale)

        -- local panelPosY = 0

        -- if (self.type == "Figurine") then
        --     panelPosY = 1150
        -- else 
        --     panelPosY = 400
        -- end

        -- require("src.data.condition_images")

        -- XMLString = XMLString .. [[
        --     <HorizontalLayout height="10000" width="50000" id="conditions" childForceExpandWidth="false" position="0 0 -]]..panelPosY..[[" rotation="90 0 0">
        --         <Image width="5000" height="5000" class="condition" image="]]..CONDITIONS.restrained.url..[["  />
        --         <Image class="condition" image="]]..CONDITIONS.restrained.url..[["  />
        --     </HorizontalLayout>
        -- ]]

        if (self.type == "Figurine") then
            XMLString = XMLString .. [[
                <Text id="BlackName" scale="3 3 3" fontSize="34" visibility="Black" text="Black Name" color="Black" position="0 150 -120" rotation="90 270 90" fontStyle="Bold" outline="White" outlineSize="1 -1" />
                <Text id="creatureName" position="0 200 -50" width="150" rotation="180 180 0" scale="3 3 3" fontSize="34" text="]]..data.name..[[" color="Black" fontStyle="Bold" outline="White" outlineSize="1 -1" />
                
            ]]
        else
            XMLString = XMLString .. [[
                <Text id="BlackName"  scale="1 1 1" fontSize="34" visibility="Black" text="Black Name" color="Black" position="0 40 -50" rotation="90 270 90" fontStyle="Bold" outline="White" outlineSize="1 -1" />
                <Text id="creatureName" position="0 35 -5" width="300" rotation="180 180 0" scale="1 1 1" fontSize="34" text="]]..data.name..[[" color="Black" fontStyle="Bold" outline="White" outlineSize="1 -1" />
                
            ]]
        end

        self.UI.setXml(XMLString)
    end, 0.5)
    Wait.time(function()
        lastAng = -1
        alignPivot()
    end, 0.75)
end

function hasScriptingTags(obj)
    return utils.hasTagsFromList(obj, {OBJECT_TAGS.monster_token, OBJECT_TAGS.boss_token})
end