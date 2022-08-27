love = require("love")
local Projectile = require("projectile")

function love.load()
    love.window.setTitle("Game")
    love.graphics.setBackgroundColor(255, 255, 255)

    --lock mouse to window
    love.mouse.setGrabbed(true)
    love.mouse.setVisible(true)

    windowHeight = love.graphics.getHeight()
    windowWidth = love.graphics.getWidth()

    centerX = windowWidth/2
	centerY = windowHeight/2

    time_remaining = 15
    score = 5
    level = 1

    --create table of pieces
    pieces = {
        love.graphics.newImage("bishop.png") , 
        love.graphics.newImage("rook.png") , 
        love.graphics.newImage("knight.png") , 
        love.graphics.newImage("pawn.png")
    }

    piece_index = 1

end

-- function Projectile(start_x,start_y)
--     return {
--         starting_pos = {x = start_x, y = start_y},
--         current_pos = {x, y},
--         direction = {x, y},
--         color = "",
--         speed = 0,
--         pieces_index = ""
--     }
-- end

-- function EnemyProjectile(start_x, start_y)
--     local projectile = Projectile(start_x, start_y)
--     projectile.damage_dealt = 0
--     return projectile
-- end
    

function love.wheelmoved(x, y)
    if y > 0 then
        wheel_up = true
    elseif y < 0 then
        wheel_down = true
    end

end

function love.update(dt)
    _G.dt = dt
    --round to two decimal places
    time_remaining = math.floor((time_remaining - dt) * 100) / 100

    if time_remaining < 0 then
        time_remaining = 0
    end

    --close the game if the player presses escape
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    --rotate the outer pointer around the center following the mouse
    angle = math.atan2((love.mouse.getX() - centerX),(centerY - love.mouse.getY()))

    --when the player scrolls, increase or decrease the index of pieces
    if wheel_up and piece_index < 4 then
        piece_index = (piece_index + 1) % 5
        wheel_up = false
    elseif wheel_down and piece_index > 1 then
        piece_index = (piece_index - 1) % 5
        wheel_down = false
    end

    --when the player clicks 1 through 4 on the keyboard, set the piece index to that number
    if love.keyboard.isDown("1") then
        piece_index = 1
    elseif love.keyboard.isDown("2") then
        piece_index = 2
    elseif love.keyboard.isDown("3") then
        piece_index = 3
    elseif love.keyboard.isDown("4") then
        piece_index = 4
    end

end

function love.draw()
    
    --draw board
    love.graphics.setLineWidth(15)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 25, 25, 750, 550)

    --draw timer
    love.graphics.print(time_remaining, 40, 40)

    --draw score
    love.graphics.print(score, windowWidth-50, 40)

    --draw level name
    love.graphics.print("Level: "..level, windowWidth/2, 40)

    --draw player
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", 400, 300, 15)
    --draw outer circle
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", 400, 300, 80)

    --draw piece
    love.graphics.draw(pieces[piece_index], centerX - pieces[piece_index]:getWidth()/2 * .2, centerY - pieces[piece_index]:getHeight()/2 * .2, 0, 0.2, 0.2)


    --rotate around the center
    love.graphics.translate(centerX, centerY)
	love.graphics.rotate(angle)
	love.graphics.translate(-centerX, -centerY)
    --draw outer pointer
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(400, 300, 400, 270)
    love.graphics.rotate(angle)

    love.graphics.origin()

    love.graphics.print("Piece Index: "..piece_index, 40, 60)

    
    -- local testProj = EnemyProjectile(40,80)
    -- love.graphics.print(testProj.damage_dealt, 40, 80)

end