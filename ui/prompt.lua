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
    local res = 0 --NOTE: 'res' starts with 0, add a 1 when indexing 'opt'
    local stoplp = false

    function evh(ev,a,b,c)
        if ev == "keypressed" then
            if CONFIRM[a] then
                if not flags.mute then self.select_snd:play() end
                stoplp = true
            elseif not flags.nocancel and CANCEL[a] then --cancel out
                res = nil --return nil if player cancels out
                stoplp = true
            elseif flags.menuC and MENU[a] then --cancel out w/ MENU
                res = false --return false if player cancels out
                stoplp = true
            elseif PREV[a] then
                res = (res-1) % #opt --wrap if OOB
            elseif NEXT[a] then
                res = (res+1) % #opt --wrap if OOB
            end
        end
    end

    function draw()
        local rx,ry = 0,0
        if flags.abs then camera:set() end --if using abs coords, set cam
        if type(obj) == "table" then
            rx,ry = obj:draw() --offset for SOUL coords
        elseif type(obj) == "function" then
            rx,ry = obj() --offset for SOUL coords
        end
        if res then
            souls.souls.sans:draw(opt[res+1][1]+rx, opt[res+1][2]+ry, flags.abs)
        end
        if flags.abs then camera:unset() end
    end

    function cond(dt, t)
        souls:update(dt)
        return stoplp
    end

    wait(cond, evh, draw)
    return res and res+1 --correct it for return value, false/nil if canceled
end

return prompt
