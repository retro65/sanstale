--okay so i did all of this without commenting at first and then i commented it all at once :P

local sans = {
    canmove = 0,
    speed = 120,
    def_speed = 120,
    width = 46,
    height = 60
} --i'm sans. sans the table

sans.x = 100
sans.y = 100

sans.sheet = love.graphics.newImage("res/img/sans.png") --sans' spritesheet
sans.grid = anim8.newGrid(46,60, sans.sheet:getWidth(),sans.sheet:getHeight(),0,0,2,2) --sans' grid

sans.hitbox  = { --sans bounding box (his feet)
    x = 0,
    y = 51,
    width = 46,
    height = 9
}

sans.anim = { --table that holds sans' animations
    current = 'walkdown',
    paused = true,
    --All the animations
    walkdown  = anim8.newAnimation(sans.grid('1-4',1), sans.speed/1000*1.5),
    walkleft  = anim8.newAnimation(sans.grid('1-4',2), sans.speed/1000*1.5),
    walkright = anim8.newAnimation(sans.grid('1-4',3), sans.speed/1000*1.5),
    walkup    = anim8.newAnimation(sans.grid('1-4',4), sans.speed/1000*1.5),
    --dunno how to name this:
    joke      = anim8.newAnimation(sans.grid('1-2',5), sans.speed/1000*1.5),
    winkshrug = anim8.newAnimation(sans.grid('1-2',6), sans.speed/1000*1.5)
}

--stats
sans.lv = 1
sans.exp = 0
sans.hp = 1
sans.gold = 0

function sans:draw() --Function for drawing sans
    self.anim[self.anim.current]:draw(self.sheet, self.x, self.y)
end
function sans:update(dt) --Function for updating sans
    if sans.anim.paused then
        sans.anim[sans.anim.current]:pause()
        sans.anim[sans.anim.current]:gotoFrame(1)
    else
        sans.anim[sans.anim.current]:resume()
    end
    self.anim[self.anim.current]:update(dt)
end

function sans:move(dt)
    --print (dt)
    
    if self.canmove < 2 then --this is to avoid bugs with exiting a pause and things like that
        self.canmove = self.canmove+1
        return 
    end

    self.anim.paused = false
    local newy, newx --create placeholder values
    --move
    if love.keyboard.isDown("down") then
        self.anim.current = "walkdown"
        newy = self.y+self.speed*dt
    elseif love.keyboard.isDown("left") then 
        self.anim.current = "walkleft"
        newx = self.x-self.speed*dt
    elseif love.keyboard.isDown("right") then
        self.anim.current = "walkright"
        newx = self.x+self.speed*dt
    elseif love.keyboard.isDown("up") then
        self.anim.current = "walkup"
        newy = self.y-self.speed*dt
    else
        self.anim.paused = true
    end
    --if nil then revert to old value
    newx = newx or self.x
    newy = newy or self.y

    local collision_count = 0
    for _,e in pairs(rooms[rooms.current].elements) do --loop through all elements in the current room
        if collision(newx+self.hitbox.x, newy+self.hitbox.y, self.hitbox.width, self.hitbox.height,
                     e.x,                e.y,                e.width,           e.height) and not e.nocollision then 
            --sans collides with something on the room
            if e.exit then --handle exits
                rooms:change(e.exit.new, e.exit.newx, e.exit.newy)
                return
            end
            collision_count = collision_count+1 --add to collision count
        end
    end

    if collision_count == 0 or self.speed ~= self.def_speed then
        --if sans hasn't collided with anything and super speed mode is not on, then change coordinates to new ones
        self.x = newx
        self.y = newy
    end
end

function sans:check() --check elements (overworld)
    for _,e in pairs(rooms[rooms.current].elements) do --loop through every element in the current room
        if collision(self.x+self.hitbox.x-1, self.y+self.hitbox.y-1, self.hitbox.width+2, self.hitbox.height+2,
                     e.x-1,                  e.y-1,                  e.width+2,           e.height+2) and
                     (e.oncheck or e.text) then
            --sans collides with something AND the element has a text or an oncheck value
           
            if e.oncheck then
                e.oncheck() --oncheck is a function obv
            end
            if type(e.text) == "table" then
                --loop through the text if it's a table
                for _,txt in pairs(e.text) do
                    if type(txt) == 'table' then --if txt is a table then it is used to use dialog boxes with some face
                        dialog:say(txt.face, txt.facenum, txt.text, txt.font, txt.voice)
                    else --else it's a string just print it without a face
                        dialog:say(nil,nil,txt)
                    end
                end
            elseif type(e.text) == "string" then --if it's a string then print it without a face
                dialog:say(nil, nil, e.text)
            end
            break --this avoids checking multiple objects at once
        end
    end
end

return sans
