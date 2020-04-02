local prompt = {
    select_snd = love.audio.newSource("res/aud/sfx/snd_select.wav", "static")
}

--'opt' is a sequence of SEQUENCES with at least the elements "{X, Y}"
---should have at least 1 element
function prompt:choice(opt, drawfunc, nocancel, mute)
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
                    if not mute then self.select_snd:play() end
                    loop = false
                elseif not nocancel and CANCEL[a] then --cancel out
                    return nil --return nil if player cancels out
                elseif PREV[a] then
                    res = (res-1) % #opt --wrap if OOB
                elseif NEXT[a] then
                    res = (res+1) % #opt --wrap if OOB
                end
            end
        end

        camera:set()
        love.draw(false)
        if drawfunc then
            drawfunc()
        end
        souls.souls.sans:draw(opt[res+1][1], opt[res+1][2])
        love.graphics.present()
        camera:unset()

        if rooms[rooms.current].update then --update room
            rooms[rooms.current]:update(dt)
        end
        for _,e in pairs(souls.souls) do
            e:update(dt)
        end
    end
    return res+1 --correct it for return value
end

return prompt
