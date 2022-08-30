love = require "love"
function PlayerPointer(starting_x, starting_y)
    return {
        current_pos = {x=starting_x, y=starting_y},
        direction = {x=0,y=0}
    }
end