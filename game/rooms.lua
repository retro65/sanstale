local rooms = { --main room module
    opacity = 0, --room transition opacity thingie
    change_time = 0, --room transition timer counter
    op_inc_val = 2, --opacity change speed
    opacity_increaser = 2
-- +op_inc_val or -op_inc_val, if it darkens or it gets brigther
}

function rooms:load(room) --load function
    local rname
    for _,name in pairs(love.filesystem.getDirectoryItems("game/rooms")) do --load every room
        rname = name:sub(1,#name-4)
        self[rname] = require("game.rooms."..rname)
    end
    self.current = room --set current room
    if self[self.current].noscrollx then --set camera to new room's startx and starty
        camera:setX(self[self.current].start_x)
    end
    if self[self.current].noscrolly then --set camera to new room's startx and starty
        camera:setY(self[self.current].start_y)
    end
end

function rooms:opupdate(dt) --update opacity transition thingie
    if self.changing then
        self.change_time = self.change_time + dt --update timer
        self.opacity = self.opacity+dt*self.opacity_increaser --update opacity

        if self.change_time >= 0.5 and self.opacity_increaser == self.op_inc_val then
            self.opacity_increaser = -self.op_inc_val
            if self[self.nextroom].noscrollx then --set camera to new room's startx and starty
                camera:setX(self[self.nextroom].start_x)
            end
            if self[self.nextroom].noscrolly then --set camera to new room's startx and starty
                camera:setY(self[self.nextroom].start_y)
            end
            if self[self.nextroom].music ~= music.current then
                music:play(self[self.nextroom].music, true)
            end
            sans.x = self.nextx
            sans.y = self.nexty
            self.current = self.nextroom

        elseif self.change_time >= 1 then --done
            self.opacity_increaser = self.op_inc_val
            self.opacity = 0
            self.changing = false
        end
    end
end

function rooms:opdraw() --draw opacity transition thingg
    if self.changing then
        love.graphics.setColor(0,0,0, self.opacity)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1,1,1,1)
    end
end

function rooms:change(room, newx, newy)
    --change room
    print(string.format("Entering room '%s'",room))
    self.nextroom = room
    self.nextx = newx
    self.nexty = newy
    self.changing = true
    self.opacity = 0
    self.change_time = 0
end

local r_template = { --room template
    elements = {},
    element = function(self, x,y,w,h,txt,nocollision,exit) --element constructor
        table.insert(self.elements, {
            x=x,
            y=y,
            width=w,
            height=h,
            text=txt,
            nocollision=nocollision,
            exit=exit
        })
    end,
    draw = function(self)
        if self.animation then
            self.animation:draw(self.sheet,0,0)
        else
            love.graphics.draw(self.img)
        end
    end,
    fgdraw = function(self)
        if not(self.fg_sheet or self.fg_img) then return end
        if self.animation then
            self.animation:draw(self.fg_sheet,0,0)
        else
            love.graphics.draw(self.fg_img)
        end
    end,
    update = function(self, dt)
        if self.animation then
            self.animation:update(dt)
        end
    end
}

function rooms:new(arg) --new room constructor
    local o = setmetatable({}, {__index=r_template})
    o.elements = {}
    o.sheet, o.img, o.animation, o.grid = nil,nil,nil,nil
    o.fg_sheet, o.fg_img = nil,nil
    if arg then
        for k,v in pairs(arg) do
            o[k] = v
        end
    end
    return o
end

return rooms
