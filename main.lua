--Подключение доп.страниц
local Enemy = require "Enemy"
local button = require "Button"

--Дополненый рандом
math.randomseed(os.time())

--Основные игровые настройки
local game = {
    difficulty = 1,
    state = {
        menu = true,
        running = false,
        over = false,
    },
    score = 0,
    levels = {5,15,30,45}
}

--Параметы мишени
target = {}
    target.x = 300
    target.y = 300
    target.radius = 45
    target.sprite = love.graphics.newImage('sprites/target.png')

--Параметрый курсора. прицела
player = {}
    player.x = 20
    player.y = 30
    player.radius = 15
    player.sprite = love.graphics.newImage('sprites/crosshairs.png')

    
--Шрифт для всех надписей
gameFont = love.graphics.newFont(25)
--Фоновая картинка (спрайт)
background = love.graphics.newImage('sprites/sky.png')

--Список противников
local enemies = {}

--Спсиок кнопок
local buttons = {}
    buttons.manu_state = {}

--Функция смены состояния игры
local function ChangeGameState(state)
    if state == "menu" then
        game.state["menu"] = true
    else
        game.state["menu"] = false
    end

    if state == "over" then
        game.state["over"] = true
    else
        game.state["over"] = false
    end

    if state == "running" then
        game.state["running"] = true
    else
        game.state["running"] = false
    end
end

--Функция запуска игры
local function startNewGame()
    game.state["over"] = false
    game.state["menu"] = false
    game.state["running"] = true
    game.score = 0
end

--Звуковое сопровождение
local sounds = {
    shot = love.audio.newSource("sounds/shot.wav", "static"),
    theme = love.audio.newSource("sounds/theme.mp3", "stream"),
    noise = love.audio.newSource("sounds/noise.wav", "static"),
}

--Загрузка данных при запуске
function love.load()
    love.window.setTitle("RADIOACTIVE CLOUD")
    
    buttons.manu_state[1] = button("New Game",startNewGame,150,50)
    buttons.manu_state[2] = button("Quit",love.event.quit,150,50) 
    
    table.insert(enemies, 1 , Enemy())

    sounds.theme:setLooping(true)
    sounds.theme:play()
    
end


--Обновление (постоянное) экрана 60 к\с
function love.update(dt)
    player.x,player.y = love.mouse.getPosition()
    
    if game.state["running"] then
        for i=1, #enemies do
            if not enemies[i]:checkTouched(player.x,player.y,player.radius) then
                enemies[i]:move(player.x,player.y) 
                for i =1, #game.levels do
                    if game.score == game.levels[i] then                      
                        table.insert(enemies, 1 , Enemy(game.difficulty * (i+1)))
                        --костыль
                        game.score = game.score + 1
                    end
                end
            else
                ChangeGameState("over")
            end
        end
    end  
end

--Функция отрисовки на экране
function love.draw()
    love.graphics.setFont(gameFont)
    --Игра в процессе
    if game.state["running"] then
        love.graphics.draw(background, 0, 0)
        love.mouse.setVisible(false)

        --Отрисовка мишени
        love.graphics.draw(target.sprite, target.x, target.y,nil,0.5,0.5,45,45)

        --Отрисовка количества врагов
        for i=1, #enemies do
            enemies[i]:draw()
        end
        
        --Отрисовка кусора\игрока
        love.graphics.draw(player.sprite, player.x, player.y,nil,1,1,45,45)

        --Отрисовка количества очков
        love.graphics.setColor(1,1,1)
        love.graphics.print(game.score,130,0)
        love.graphics.print("score:",0,0)

    end
    --Меню игры
    if game.state["menu"] then
        love.mouse.setVisible(true)
        love.graphics.setColor(1,0,0)
        love.graphics.print("RADIOACTIVE CLOUD",300,155)
        ----Отрисовка кнопок
        buttons.manu_state[1]:draw(350,200,10,10)
        buttons.manu_state[2]:draw(350,275,10,10)
    end
    --Меню конца игры
    if game.state["over"] then
        love.mouse.setVisible(true)
        love.graphics.setColor(1,0,0)
        love.graphics.print("GAME OVER",350,155)
        buttons.manu_state[1]:draw(350,200,10,10)
        buttons.manu_state[2]:draw(350,275,10,10)
        
    end
end

--Проверка нажатия на мышку (левая кнопка)
function love.mousepressed(x,y, button, istouch, presses)
     
    if button == 1 then
        local mouseToTarget = distanceBetween(x,y,target.x,target.y)
        if game.state["menu"] or game.state["over"] then
            for index in pairs(buttons.manu_state) do
                buttons.manu_state[index]:checkPressed(x,y,player.radius)
            end
        end        
        if mouseToTarget < target.radius and game.state["running"] then
            game.score = game.score +1
            sounds.shot:play()
            target.x = math.random(target.radius,love.graphics.getWidth()-target.radius)
            target.y = math.random(target.radius,love.graphics.getHeight()-target.radius)
        end
    end
    
end

--Растояние между обьектами на экране
function distanceBetween(x1,y1,x2,y2)
    return math.sqrt( (x2 -x1)^2 + (y2-y1)^2 )
end