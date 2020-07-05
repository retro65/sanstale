local lg = love.graphics

--require everything
camera = require "lib.camera"
anim8  = require "lib.anim8"
         require "lib.slam"
         require "errhand"
dialog = require "ui.dialog"
menu   = require "ui.menu"
sans   = require "game.sans"
music  = require "game.music"
rooms  = require "game.rooms"
save   = require "save"
souls  = require "game.souls"
prompt = require "ui.prompt"
igmenu = require "ui.igmenu"

function collision(x1,y1,w1,h1, x2,y2,w2,h2) --simple function to detect collision between two rectangles
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end

--receives two rectangles that must intersect, returns x,y offsets for 2nd rect to move it outside of 1st SHORTEST WAY POSSIBLE
function uncollide(x1,y1,w1,h1, x2,y2,w2,h2) --simple function to un-intersect two rectangles
    local x,y = x1 + w1 - x2, y1 + h1 - y2
    local tmp = x2 + w2 - x1 --tmp for comparison
    if tmp < x then --tmp is a shorter way
        x = -tmp
    end
    tmp = y2 + h2 - y1
    if tmp < y then
        y = -tmp
    end
    if math.abs(x) < math.abs(y) then --horizontal offset
        return x2+x,y2
    else
        return x2,y2+y
    end
end

function clamp(v, min, max) --simple function to clamp a value between a minimum and maximum
    return math.min(math.max(v, min), max)
end

function wait(cond, evh, drawf) --function for waiting while updating the animations and etc.
    sans.canmove = 0
    local t = 0
    while true do
        local dt = love.timer.getDelta()
        t = t + dt

        love.event.pump()
        for ev, a, b, c in love.event.poll() do --poll events
            if ev == "quit" then
                love.event.quit()
            elseif ev == "keypressed" then
                love.keypressed(a)
            elseif ev == "keyreleased" then
                love.keyreleased(a)
            end
            if evh then
                evh(ev,a,b,c)
            end
        end

        love.draw() --draw everything without updating cameras
        if drawf then drawf() end --draw shit
        love.graphics.present() --draw outside love.draw

        rooms[rooms.current]:update(dt)
        sans:update(dt) --update Sans animations

        if     type(cond) == 'number' and t >= cond then break
        elseif type(cond) == 'function' and cond(dt, t) then break
        end
    end
    return t
end

function love.load(arg)
    CONFIRM = {z=true, ["return"] = true} --constants
    CANCEL = {x=true,rshift=true}
    MENU = {c=true,rctrl=true}
    NEXT = {down=true,right=true}
    PREV = {up=true,left=true}
    width = lg.getWidth()
    height = lg.getHeight()
    --load modules
    dialog:load()
    music:load()
   
    state = "menu"

    debugon = (arg[1] == "debug") --activate debug mode
    debug_elems = false
    if debugon then
        debugtext = lg.newText(dialog.fonts.determination, "DEBUG ON")
        debug_elems = true
    end

    save.file = ".h€lP_00" --mwahahah
    save.load()
    
    playtime = playtime or 0
   
    music:play("startmenu", true)

end

function love.update(dt)
    if state == "overworld" then
        playtime = playtime+dt
        if not rooms.changing then --update sans only if room is not in changing transition
            sans:move(dt) 
            sans:update(dt)
        end
        rooms:opupdate(dt)
        rooms[rooms.current]:update(dt)
    end
    souls:update(dt)
    if not rooms[rooms.current].noscrollx then --adjust camera x to sans if room hasn't got the flag noscrollx
        camera:setX(clamp(
            sans.x-width/2+sans.width/2, 0, rooms[rooms.current].img:getWidth()-width
        ))
    end
    if not rooms[rooms.current].noscrolly then --adjust camera y to sans if room hasn't got the flag noscrolly
        camera:setY(clamp(
            sans.y-height/2+sans.height/2, 0, rooms[rooms.current].img:getHeight()-height
        ))
    end
end

function love.draw(cameras)
    if cameras ~= false and state == "overworld" then
        camera:set()
    end
    lg.setColor(1,1,1,1) --reset color
    if state == "menu" then
        menu:draw()
    elseif state == "overworld" then
        rooms[rooms.current]:draw() --draw room
        sans:draw() --draw sans
        rooms[rooms.current]:fgdraw() --draw room foreground
        if debug_elems then --semi-transparent room element vision (colored)
            lg.setColor(1,1,1,0.4)
            lg.rectangle("fill",
                sans.x+sans.hitbox.x,
                sans.y+sans.hitbox.y,
                sans.hitbox.width, sans.hitbox.height)
            for _,i in pairs(rooms[rooms.current].elements) do
                local r = 0
                local g = 0
                local b = 0
                if i.exit then
                    r,g = 0.5,0.5 --dark-yellow for exits
                end
                if i.nocollision then
                    g = 1
                else
                    r = 1
                end
                if i.text then
                    b = 1
                end
                lg.setColor(r,g,b,0.4)
                lg.rectangle("fill", i.x, i.y, i.width, i.height)
            end
        end
    end
    lg.setColor(1,1,1,1) --reset color
    if cameras ~= false and state == "overworld" then
        camera:unset()
    end
    rooms:opdraw() --draw room transition opacity thing
    if debugon then
        lg.draw(debugtext, 0, height-debugtext:getHeight())
        lg.setFont(dialog.fonts.determination)
        lg.print(
            " Sans: "..(tostring(sans.x):sub(0,10))..","..(tostring(sans.y):sub(0,10)),
            debugtext:getWidth(), height-debugtext:getHeight())
    end
end

function love.keypressed(k)
    if k == "escape" then
        love.event.quit() --quit game
    
    elseif k == "m" then --mute
        if love.audio.getVolume() > 0 then
            love.audio.setVolume(0)
        else
            love.audio.setVolume(1)
        end
    
    elseif MENU[k] then
        if state == "overworld" and sans.canmove >= 2 then
            igmenu:popup() --activate in-game menu when c/ctrl is pressed
        end
    
    elseif CONFIRM[k] then
        if state == "overworld" and sans.canmove >= 2 then
            sans:check() --check when z is pressed
        elseif state == "menu" then
            if not menu.resetti then --normal
                if menu.resetted then
                    menu.resetted = false
                elseif menu.selected then --continue is selected
                    state = "overworld"
                    save.load()
                    music:play(rooms[rooms.current].music, true)
                else --reset is selected
                    menu.resetti = true
                end
            else --reset confirmation
                if menu.resetsel then --NOO!! is selected
                    menu.selected = true
                    menu.resetti = false
                else --yes is selected
                    menu.resetti = false
                    menu.resetted = true
                    print("Reseted")
                    sans.x, sans.y = 100,100
                    sans.lv, sans.exp, sans.hp, sans.gold = 1,0,1,0
                    rooms:load('sans')
                    playtime = 0
                    love.filesystem.remove(save.file) --erase save file
                end
            end
        end

    elseif NEXT[k] or PREV[k] then --select continue or reset in menu
        if state == "menu" then
            if not menu.resetti then --normal
                menu.selected = PREV[k]
            else --reset confirmation screen
                menu.resetsel = PREV[k]
            end
        end
    
    elseif k == "e" and debugon then --cause error
        error("ERROR INVOKED by pressing 'e'")
    
    elseif k == "s" and debugon then
        print("FORCE SAVED") --force save
        save.save()

    elseif k == "v" and debugon then
        debug_elems = not debug_elems
        print("element view:", debug_elems) --debug element vision

    elseif k == "lshift" and debugon then
        print("super speed on")
        sans.speed = 1000
    end
end
function love.keyreleased(k)
    if sans.canmove >= 2 and (k == "up" or k == "down" or k == "left" or k == "right") then --pause animation
        sans.anim.paused = true

    elseif k == "lshift" and debugon then
        print("super speed off")
        sans.speed = sans.def_speed 
    end
end
