local igm = {
    stat_font = love.graphics.newFont("res/font/CryptOfTomorrow.ttf", 16),
    stat_small = love.graphics.newImage("res/img/stat_small.png"),
    select_snd = love.audio.newSource("res/aud/sfx/snd_select.wav", "static")
}

function igm:popup()
    local function draw() --drawing function
        camera:set()
        love.draw(false) --draw everyting without updating cameras
        local coords = {x = camera:getX()+30, y = camera:getY()+30}
        if sans.y-camera:getY()+sans.height/2 <= height/2 then
            coords.y = camera:getY()+height-igm.stat_small:getHeight()-30
        end
        --MAIN STATS
        love.graphics.draw(igm.stat_small, coords.x, coords.y)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(dialog.fonts.sans)
        love.graphics.print("sans", coords.x+14, coords.y+8)
        love.graphics.setFont(igm.stat_font)
        love.graphics.print(tostring(sans.lv), coords.x+50, coords.y+48)
        love.graphics.print(tostring(sans.hp).."/1", coords.x+50, coords.y+66)
        love.graphics.print(tostring(sans.gold), coords.x+50, coords.y+84)

        love.graphics.present() --present (to do that outside love.draw)
        camera:unset()
    end

    sans.canmove = 0 --dt will build up madly, freeze sans until after return

    local submenu = false --sub-menu name (false for main)
    local dt
    local loop = true

    igm.select_snd:play()

    while loop do
        dt = love.timer.getDelta()

        love.event.pump()
        for ev, a, b, c in love.event.poll() do --poll events
            if ev == "quit" then
                love.event.quit()
            elseif ev == "keypressed" then
                if CANCEL[a] then --demote to previous menu
                    if submenu then
                        
                    else
                        loop = false
                    end
                elseif CONFIRM[a] then --advance to next menu / perform action
                    
                elseif MENU[a] then
                    loop = false
                end
            end
        end

        draw() --draw sh*t

        if rooms[rooms.current].update then --update room
            rooms[rooms.current]:update(dt)
        end
    end
end

return igm
