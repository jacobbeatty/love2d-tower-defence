love = require "love"
function Projectile(start_x,start_y, type_index)
    return {
        starting_pos = {x = start_x, y = start_y},
        current_pos = {x = start_x, y = start_y},
        direction = {x, y},
        color = "",
        speed = 0,
        pieces_index = type_index
    }
end

function EnemyProjectile(start_x, start_y, type_index)
    local projectile = Projectile(start_x, start_y, type_index)
    projectile.damage_dealt = 0
    return projectile
end