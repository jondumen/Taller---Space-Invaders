-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here :D

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight
local centerX = screenWidth/2
local centerY = screenHeight/2

local player
local playing = false
local spawnEnemy = 0
local enemies = {}
local message

--

local function hasCollided(obj1, obj2)
    if (obj1 == nil) then
        return false
    end

    if (obj2 == nil) then
        return false
    end

    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
 
    return (left or right) and (up or down)
end

local function handleCrash()
    playing = false

    message.text = 'Te moristes XD'

    transition.to(player, {time=50, width=100, height=100, alpha=0})

    for i = 1, #enemies do
        local enemy = enemies[i]

        if enemy ~= nil then
            transition.to(enemy, {time=100, width=0, height=0})
        end
    end
end

local function addEnemy()
    spawnEnemy = 0

    --print('AddEnemy')
    --local enemy = display.newRect(math.random(20, screenWidth - 20), -50, 20, 20)
    local enemy = display.newImageRect('assets/enemy.png', 20, 20)
    enemy.x = math.random(20, screenWidth - 20)
    enemy.y = -50
    enemy.rotation = 180
    --enemy.fill = {0, 1, 0}

    enemies[#enemies+1] = enemy
end

local function enterFrame()
    if playing then
        if player.direction == 'left' then
            player.x = player.x - 1
        elseif player.direction == 'right' then
            player.x = player.x + 1
        end

        if player.x < 0 or player.x > screenWidth then
            handleCrash()
        end
        --

        spawnEnemy = spawnEnemy + 1

        if spawnEnemy >= 60 then
            addEnemy()
        end
        --

        for i = 1, #enemies do 
            local enemy = enemies[i]

            if enemy ~= nil then
                enemy.y = enemy.y + 2

                if hasCollided(enemy, player) then
                    handleCrash()
                end


                if enemy.y > screenHeight then
                    enemy:removeSelf()
                    enemies[i] = nil
                end
            end
        end
    end
end

local function restartGame()
    player.x = centerX
    player.y = screenHeight - 50
    player.width = 40
    player.height = 40
    player.direction = 'left'
    player.alpha = 1

    for i = 1, #enemies do
        local enemy = enemies[i]
        if enemy then
            enemy:removeSelf()
            enemies[i] = nil
        end
    end

    playing = true
    message.text = ''
end

local function handleTouch(event)
    if event.phase == 'began' then
        if playing then
            if player.direction == 'left' then
                player.direction = 'right'
            else
                player.direction = 'left'
            end
        else
            restartGame()
        end
    end
end

--

--local background = display.newRect(centerX, centerY, screenWidth, screenHeight)
--background.fill = {0.1, 0.1, 0.1}
local background = display.newImageRect('assets/background.png', screenWidth, screenHeight)
background.x = centerX
background.y = centerY

--player = display.newRect(centerX, screenHeight - 50, 40, 40)
--player.fill = {0.5, 0, 0}
player = display.newImageRect('assets/player.png', 40, 40)
player.x = centerX
player.y = screenHeight - 50
player.direction = 'left'
player.alpha = 0

message = display.newText('Presiona para Iniciar', centerX, centerY, native.systemFont, 24)

Runtime:addEventListener('enterFrame', enterFrame)
Runtime:addEventListener('touch', handleTouch)