local data = {
    hp = 5,
    maxHp = 5,
    stress = 3,
    maxStress = 3,
    showing = true,
}

local images = {
    hp = "https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/",
    stress = "https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/"
}


function onLoad()
    self.setTags({"player_token"})
    setupUI()
end

function setupUI()
    local iconSize = 50

    local xml = [[
        <GridLayout id="hp_container" scale="1 1 1" cellSize="]]..iconSize..[[ ]]..iconSize..[[" childAlignment="MiddleCenter" constraint="FixedRowCount" constraintCount="1" position="0 0 -300" rotation="270 0 0">
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/10494050456455959184/B2057166B19BAE387F62C851A6404592248EB3A1/" />
        </GridLayout>
        <GridLayout id="stress_container" scale="1 1 1" cellSize="]]..iconSize..[[ ]]..iconSize..[[" childAlignment="MiddleCenter" constraint="FixedRowCount" constraintCount="1" position="0 0 -250" rotation="270 0 0">
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/" />
            <Image width="100" height="100" image="https://steamusercontent-a.akamaihd.net/ugc/15261052138615878051/6A2F452DCA95EDA5CDD8FD82EC58F4B286AA585B/" />
        </GridLayout>
    ]]


    self.UI.setXml(xml)
end
