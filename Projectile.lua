love = require "love"
function Projectile(start_x,start_y)
    return {
        starting_pos = {x = start_x, y = start_y},
        current_pos = {x, y},
        direction = {x, y},
        color = "",
        speed = 0,
        pieces_index = ""
    }
end

function EnemyProjectile(start_x, start_y)
    local projectile = Projectile(start_x, start_y)
    projectile.damage_dealt = 0
    return projectile
end