love = require("love")

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
    score = 5
    level = 1
end

function love.update(dt)
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
    angle = math.atan2(love.mouse.getY() - centerY, love.mouse.getX() - centerX)
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
    love.graphics.circle("line", 400, 300, 30)

    --rotate around the center
    love.graphics.translate(centerX, centerY)
	love.graphics.rotate(angle)
	love.graphics.translate(-centerX, -centerY)
    --draw outer pointer
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(400, 300, 400, 270)
    love.graphics.rotate(angle)
    



end