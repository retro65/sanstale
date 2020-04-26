local souls = {
    w = 16,
    h = 16
}

local s_template = { --soul template
    anim = {
        current = 'dmg'
    },
    mode = "def",
    switch = function(self, a)
        self.anim.current = a
    end,
    kill = function(self)
        self:switch("brk")
        self.anim.brk:resume()
    end,
    damage = function(self)
        self:switch("dmg")
        self.anim.dmg:resume()
    end,
    draw = function(self, x,y, rel)
        if rel then --location is on-screen if rel is true
            x = x + camera:getX()
            y = y + camera:getY()
        end
        --'-2' is to compensate 2 blank columns for the 'brk' animation
        self.anim[self.anim.current]:draw(self.sheets[self.mode],x-2,y)
    end,
    update = function(self, dt)
        self.anim[self.anim.current]:update(dt)
    end
}

local function stop(anim)
    --the names are long & have the title to ensure that "anim8" dev(s) will
    ---not add the same keys to their library, ensuring compatibility
    if anim.sanstale_loop_max then
        anim.sanstale_loop_counter = (anim.sanstale_loop_counter or 0)+1
        if anim.sanstale_loop_counter >= anim.sanstale_loop_max then
            anim.sanstale_loop_counter = 0
            anim:pauseAtStart()
        end
    else
        anim:pauseAtStart()
    end
end

function souls:new(sheets, grid) --constructor
    local o = setmetatable({}, {__index=s_template})
    o.sheets = sheets
    o.anim.dmg = anim8.newAnimation(grid('1-2',1), 0.1, stop)
    o.anim.brk = anim8.newAnimation(grid('1-2',2), 1, stop)
    o.anim.dmg.sanstale_loop_max = 4
    o.anim.dmg:pause()
    return o
end

function souls:update(dt) --update all souls
    for _,e in pairs(self.souls) do
        e:update(dt)
    end
end

local m_sheet = love.graphics.newImage("res/img/souls/m_soul.png")
--the pixel dimensions are here bcs they are independent of the gameplay size
local m_grid = anim8.newGrid(20,16,m_sheet:getDimensions())
local m_sheets = {
    blu=love.graphics.newImage("res/img/souls/mb_soul.png"),
    def=m_sheet
}

souls.souls = {
    sans = souls:new(m_sheets, m_grid),
    papyrus = souls:new(m_sheets, m_grid)
}

return souls
