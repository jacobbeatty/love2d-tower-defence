love = require("love")
local Projectile = require("projectile")
local Pointer = require("playerpointer")

function love.load()
    love.window.setTitle("Game")
    love.graphics.setBackgroundColor(255, 255, 255)

    --lock mouse to window
    love.mouse.setGrabbed(true)
    love.mouse.setVisible(false)

    windowHeight = love.graphics.getHeight()
    windowWidth = love.graphics.getWidth()

    centerX = windowWidth/2
	centerY = windowHeight/2

    time_remaining = 15
    score = 99
    level = 1
    TIMER_START = 2
    spawn_timer = TIMER_START
    


    --create table of pieces
    pieces = {
        love.graphics.newImage("bishop.png") , 
        love.graphics.newImage("rook.png") , 
        love.graphics.newImage("knight.png") , 
        love.graphics.newImage("pawn.png")
    }

    piece_index = love.math.random(1, 4)

    -- CONSTANTS to refer to projectiles instead of using raw numbers
    BISHOP = 1
    ROOK = 2
    KNIGHT = 3
    PAWN = 4

    -- initialize the projectiles table
    projectiles={}
    player_pointer = PlayerPointer(centerX,centerY)
end

-- Draws projectile based on it's current position
function drawProjectile(p)
    love.graphics.draw(pieces[p.pieces_index], p.current_pos.x - pieces[p.pieces_index]:getWidth()/2*.1, p.current_pos.y - pieces[p.pieces_index]:getHeight()/2*.1, 0, 0.1, 0.1)
end

-- Returns euclidean between two objects, assumes two projectiles
function distance(a,b)
    return (math.sqrt((a.current_pos.x-b.current_pos.x)^2 + (a.current_pos.y-b.current_pos.y)^2))
end

-- Returns true if equal within range of error
function equals(val1, val2, err)
    -- print(val1 .. " " .. val2 .. " " .. err)
    if val1 == val2 then
        return true
    elseif val1 <= math.abs(val2 - err) then
        return true
    end
    return false
end

-- Returns normalized direction to the center of the screen from given projectile
function directionToCenter(p)
    -- generating direction towards center
    local directionX=p.current_pos.x - centerX
    local directionY=p.current_pos.y - centerY

    -- calculating magnitude, sqrt(x^2 + y^2)
    magnitude = math.sqrt(directionX*directionX + directionY*directionY);
    -- checking if magnitude is zero
    if magnitude ~= 0 then
        return {x=directionX/magnitude, y=directionY/magnitude}
    end
    -- If magnitude is zero, then return raw direction
    return {x=directionX,y=directionY}
end

function love.wheelmoved(x, y)
    if y > 0 then
        wheel_up = true
    elseif y < 0 then
        wheel_down = true
    end

end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end


-- detect if mouse is clicked
function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        --upper left quadrant
        if love.mouse.getX() < centerX - 40 and love.mouse.getY() < centerY - 40 then
            print("upper left")
            p = EnemyProjectile(centerX - 80, centerY - 80 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = -1, y = 1}
            p.damage_dealt = 0.1
        --horizontal left
        elseif love.mouse.getX() < centerX - 40 and (love.mouse.getY() > centerY - 40) and (love.mouse.getY() < centerY + 40) then
            print("left")
            p = EnemyProjectile(centerX - 100, centerY , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = -1, y = 0}
            p.damage_dealt = 0.1
        --lower left quadrant
        elseif love.mouse.getX() < centerX - 40 and love.mouse.getY() > centerY + 40 then
            p = EnemyProjectile(centerX - 80, centerY + 80 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = -1, y = -1}
            p.damage_dealt = 0.1
        --upper right quadrant
        elseif love.mouse.getX() > centerX + 40 and love.mouse.getY() < centerY - 40 then
            p = EnemyProjectile(centerX + 80, centerY - 80 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = 1, y = 1}
            p.damage_dealt = 0.1
        --horizontal right
        elseif love.mouse.getX() > centerX + 40 and (love.mouse.getY() > centerY - 40) and (love.mouse.getY() < centerY + 40) then
            p = EnemyProjectile(centerX + 100, centerY , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = 1, y = 0}
            p.damage_dealt = 0.1
        --lower right quadrant
        elseif love.mouse.getX() > centerX + 40 and love.mouse.getY() > centerY + 40 then
            p = EnemyProjectile(centerX + 80, centerY + 80 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = 1, y = -1}
            p.damage_dealt = 0.1
        --vertical up
        elseif (love.mouse.getX() > centerX - 40) and (love.mouse.getX() < centerX + 40) and love.mouse.getY() < centerY  then
            print("up")
            p = EnemyProjectile(centerX, centerY - 100 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = 0, y = 1}
            p.damage_dealt = 0.1
        --vertical down
        elseif (love.mouse.getX() > centerX - 40) and (love.mouse.getX() < centerX + 40) and love.mouse.getY() > centerY  then
            print("down")
            p = EnemyProjectile(centerX, centerY + 100 , piece_index)
            table.insert(projectiles, p)
            p.speed = 5
            p.direction = {x = 0, y = -1}
            p.damage_dealt = 0.1
        end
    end
end

function love.update(dt)
    -- _G.dt = dt
    --round to two decimal places
    time_remaining = math.floor((time_remaining - dt) * 100) / 100
    if time_remaining < 0 then
        time_remaining = 15

        level = level + 1
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

    -- draw a random projectile every 2 seconds
    spawn_timer = spawn_timer - dt
    if spawn_timer <= 0 then
        random_projectile = math.random(1, 8)
        -- random_projectile = 5
        if random_projectile == 1 then
            ep = EnemyProjectile(0,0,BISHOP)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = 1, y = -1}
            ep.damage_dealt = 1
        elseif random_projectile == 2 then
            ep = EnemyProjectile(windowWidth,0,BISHOP)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = -1, y = -1}
            ep.damage_dealt = 1
        elseif random_projectile == 3 then
            ep = EnemyProjectile(0,windowHeight,BISHOP)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = 1, y = 1}
            ep.damage_dealt = 1
        elseif random_projectile == 4 then
            ep = EnemyProjectile(windowWidth-45,windowHeight-45,BISHOP)
            table.insert(projectiles, ep )
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = -1, y = 1}
            ep.damage_dealt = 1
        elseif random_projectile == 5 then
            ep = EnemyProjectile(0,windowHeight/2,ROOK)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = 1, y = 0}
            ep.damage_dealt = 1
        elseif random_projectile == 6 then
            ep = EnemyProjectile(windowWidth-45,windowHeight/2,ROOK)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = -1, y = 0}
            ep.damage_dealt = 1
        elseif random_projectile == 7 then
            ep = EnemyProjectile(windowWidth/2,0,ROOK)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = 0, y = -1}
            ep.damage_dealt = 1
        elseif random_projectile == 8 then
            ep =EnemyProjectile(windowWidth/2,windowHeight-45,ROOK)
            table.insert(projectiles, ep)
            ep.speed = 3
            -- ep.direction = directionToCenter(ep)
            ep.direction = {x = 0, y = 1}
            ep.damage_dealt = 1
        end
        spawn_timer = TIMER_START - level*.1
    end

    -- Update projectile positions based on their speed and direction
    -- NOTE: for some reason y axis is inverted, accounting for this by subtracting movement
    for i, p in ipairs(projectiles) do
        p.current_pos.x = p.current_pos.x + p.speed * p.direction.x
        p.current_pos.y = p.current_pos.y - p.speed * p.direction.y
    
        -- if projectile hits player deal damage and remove projectile
        -- Finds distance between projectile and center circle, determines if it is in radius distance +- some error
        -- Second argument of distance expects projectile, so putting existing data into projectile format
        if equals(distance(p,{current_pos={x=centerX,y=centerY}}), 80, 170) then
            score = score - p.damage_dealt
            table.remove(projectiles, i)
        end

        --PLEASE FIX ME
        --if a projectile hits another projectile, remove both
        for j, p2 in ipairs(projectiles) do
            if i ~= j and equals(distance(p,p2), 0, 10) then
                --check if pieces are the same
                -- doesnt work for some reason
                if p.pieces_index == p2.pieces_index then
                    --if they are, remove both
                    table.remove(projectiles, i)
                    table.remove(projectiles, j)
                    score = score + 1
                end
            end
        end

        --if projectile goes off screen remove it
        if p.current_pos.x > windowWidth or p.current_pos.x < 0 or p.current_pos.y > windowHeight or p.current_pos.y < 0 then
            table.remove(projectiles, i)
        end

    end 

    --if the health reaches 0, end the game
    if score <= 0 then
        love.event.quit()
    end

    -- Locking player pointer to a circle
    -- https://love2d.org/forums/viewtopic.php?t=82805
    -- NOTE: This math is really messed up, may have to do with angle calculation? Works for now.
    player_pointer.current_pos.y = centerX - 90 * math.cos(angle)
    player_pointer.current_pos.x = centerY + 90 * math.sin(angle)

end

function love.draw()
    -- --draw zones
    -- love.graphics.setLineWidth(1)
    -- love.graphics.setColor(0, 0, 0)
    -- --straight up
    -- love.graphics.line(centerX -40, centerY, centerX-40, 0)
    -- love.graphics.line(centerX +40, centerY, centerX+40, 0)
    -- --straight down
    -- love.graphics.line(centerX -40, centerY, centerX-40, windowHeight)
    -- love.graphics.line(centerX +40, centerY, centerX+40, windowHeight)

    -- --straight left
    -- love.graphics.line(centerX, centerY + 40, 0, centerY + 40)
    -- love.graphics.line(centerX, centerY - 40, 0, centerY - 40)


    -- --straight right
    -- love.graphics.line(centerX, centerY + 40, windowWidth, centerY + 40)
    -- love.graphics.line(centerX, centerY - 40, windowWidth, centerY - 40)




    --draw board
    love.graphics.setLineWidth(45)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, windowWidth, windowHeight)
    --draw timer
    love.graphics.print(time_remaining, 40, 40)
    --draw score
    love.graphics.print(score, windowWidth-40, 40)
    --draw level name
    love.graphics.print("Level: "..level, windowWidth/2-40, 40)
    --draw player
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", centerX, centerY, 15)
    --draw outer circle
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", centerX, centerY, 80)
    --draw character piece
    love.graphics.draw(pieces[piece_index], centerX - pieces[piece_index]:getWidth()/2 * .2, centerY - pieces[piece_index]:getHeight()/2 * .2, 0, 0.2, 0.2)
    --rotate around the center
    love.graphics.translate(centerX + 80, centerY + 80)
	love.graphics.rotate(angle)
	love.graphics.translate(-centerX, -centerY)
    --draw outer pointer
    love.graphics.origin()
    -- love.graphics.setColor(255, 0, 0)
    -- love.graphics.line(centerX, centerY, centerX + 10, centerY - 10)
    -- love.graphics.rotate(angle)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", love.mouse.getX(), love.mouse.getY(), 5)
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", player_pointer.current_pos.x, player_pointer.current_pos.y, 5)

    love.graphics.setColor(0,0,0)
    love.graphics.circle("fill", love.mouse.getX(), love.mouse.getY(), 5)
    love.graphics.origin()
    

    --draw each existing projectile at its current position
    for i, p in ipairs(projectiles) do
        drawProjectile(p)
    end 
end