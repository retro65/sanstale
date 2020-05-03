local prompt = {
    select_snd = love.audio.newSource("res/aud/sfx/snd_select.wav", "static")
}

--'opt' is a sequence of SEQUENCES with at least the elements "{X, Y}"
---should have at least 1 element
--possible keys in flags (update if more are added):
---abs: use absolute coords for the SOUL and the draw func
---mute: no sound is played by prompt:choice
---menuC: use MENU keys to cancel out
---nocancel: disallow cancelling with CANCEL keys
function prompt:choice(opt, obj, flags)
    sans.canmove = 0 --dt will build up madly, freeze sans until after return

    local dt
    local loop = true
    local res = 0 --NOTE: 'res' starts with 0, add a 1 when indexing 'opt'

    while loop do
        dt = love.timer.getDelta()

        love.event.pump()
        for ev, a, b, c in love.event.poll() do --poll events
            if ev == "quit" then
                love.event.quit()
            elseif ev == "keypressed" then
                if CONFIRM[a] then
                    if not flags.mute then self.select_snd:play() end
                    loop = false
                elseif not flags.nocancel and CANCEL[a] then --cancel out
                    return nil --return nil if player cancels out
                elseif flags.menuC and MENU[a] then --cancel out w/ MENU
                    return false --return false if player cancels out
                elseif PREV[a] then
                    res = (res-1) % #opt --wrap if OOB
                elseif NEXT[a] then
                    res = (res+1) % #opt --wrap if OOB
                end
            end
        end

        love.draw()
        local rx,ry = 0,0
        if flags.abs then camera:set() end --if using abs coords, set cam
        if type(obj) == "table" then
            rx,ry = obj:draw() --offset for SOUL coords
        elseif type(obj) == "function" then
            rx,ry = obj() --offset for SOUL coords
        end
        souls.souls.sans:draw(opt[res+1][1]+rx, opt[res+1][2]+ry, flags.abs)
        love.graphics.present()
        if flags.abs then camera:unset() end

        if rooms[rooms.current].update then --update room
            rooms[rooms.current]:update(dt)
        end
        souls:update(dt)
    end
    return res+1 --correct it for return value
end

return prompt
