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
--create a frame just for shrugging
local shrugt = {love.graphics.newQuad(
    50,312, 62,60, sans.sheet:getWidth(),sans.sheet:getHeight())}

sans.anim = { --table that holds sans' animations
    current = 'walkdown',
    paused = true,
    --All the animations
    walkdown  = anim8.newAnimation(sans.grid('1-4',1), sans.speed/1000*1.5),
    walkleft  = anim8.newAnimation(sans.grid('1-4',2), sans.speed/1000*1.5),
    walkright = anim8.newAnimation(sans.grid('1-4',3), sans.speed/1000*1.5),
    walkup    = anim8.newAnimation(sans.grid('1-4',4), sans.speed/1000*1.5),
    laugh     = anim8.newAnimation(sans.grid('1-2',5), sans.speed/1000*1.5),
    wink      = anim8.newAnimation(sans.grid('1-1',6), 100),
    shrug     = anim8.newAnimation(shrugt, 100)
}

--stats
sans.lv = 1
sans.exp = 0
sans.hp = 1
sans.gold = 0

function sans:draw() --Function for drawing sans
    local xo = 0
    if self.anim.current == 'shrug' then
        xo = -8
    end
    self.anim[self.anim.current]:draw(self.sheet, self.x+xo, self.y)
end
function sans:update(dt) --Function for updating sans
    if self.anim.paused then
        self.anim[self.anim.current]:pause()
        self.anim[self.anim.current]:gotoFrame(1)
    else
        self.anim[self.anim.current]:resume()
    end
    self.anim[self.anim.current]:update(dt)
end
function sans:animset(name, p) --shortcut 4 animation change
    self.anim.current, self.anim.paused = name,p==1
end

function sans:move(dt)
    --print (dt)
    
    if self.canmove < 2 then --this is to avoid bugs with exiting a pause and things like that
        self.canmove = self.canmove+1
        return 
    end

    self.anim.paused = false
    local newx,newy --create placeholder values
    --move
    if love.keyboard.isDown("left") then 
        self.anim.current = "walkleft"
        newx = self.x-self.speed*dt
    elseif love.keyboard.isDown("right") then
        self.anim.current = "walkright"
        newx = self.x+self.speed*dt
    end
    if love.keyboard.isDown("down") then
        self.anim.current = "walkdown"
        newy = self.y+self.speed*dt
    elseif love.keyboard.isDown("up") then
        self.anim.current = "walkup"
        newy = self.y-self.speed*dt
    end
    if not (newx or newy) then
        self.anim.paused = true
    end
    --use position if nil
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
            if self.speed == self.def_speed then
                newx,newy = uncollide(e.x,                e.y,                e.width,           e.height,
                                      newx+self.hitbox.x, newy+self.hitbox.y, self.hitbox.width, self.hitbox.height)
                newx = newx - self.hitbox.x
                newy = newy - self.hitbox.y
            end
            collision_count = collision_count+1 --add to collision count
        end
    end

    if newx ~= self.x or newy ~= self.y then
        --if Sans has a net movement, then change coordinates to new ones
        self.x = newx
        self.y = newy
    else
        self.anim.paused = true
    end
end

function sans:check() --check elements (overworld)
    for _,e in pairs(rooms[rooms.current].elements) do --loop through every element in the current room
        if collision(self.x+self.hitbox.x-1, self.y+self.hitbox.y-1, self.hitbox.width+2, self.hitbox.height+2,
                     e.x-1,                  e.y-1,                  e.width+2,           e.height+2) and
                     (e.text) then
            --sans collides with something AND the element has dialogue
            self.anim.paused = true --pause animation
            
            if type(e.text) == "table" then
                --loop through the text if it's a table
                for _,txt in pairs(e.text) do
                    if type(txt) == "function" then --if it's a function call it as a method of e
                        txt(e)
                    else --else it's a dialogue line display it as is
                        dialog:say(txt)
                    end
                end
            elseif type(e.text) == "string" then --if it's a string then print it without a face
                dialog:say(e.text)
            elseif type(e.text) == "function" then --if it's a function call it as a method of e
                e:text()
            end
            break --this avoids checking multiple objects at once
        end
    end
end

return sans
