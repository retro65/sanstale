local lg = love.graphics

--require everything
camera = require "lib.camera"
anim8  = require "lib.anim8"
         require "errhand"
dialog = require "ui.dialog"
menu   = require "ui.menu"
sans   = require "game.sans"
music  = require "game.music"
rooms  = require "game.rooms"
save   = require "save"
igmenu = require "ui.igmenu"

function collision(x1,y1,w1,h1, x2,y2,w2,h2) --simple function to detect collision between two rectangles
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end

function clamp(v, min, max) --simple function to clamp a value between a minimum and maximum
    return math.min(math.max(v, min), max)
end

function love.load(arg)
    CONFIRM = {z=true, ["return"] = true} --constants
    CANCEL = {x=true,rshift=true}
    MENU = {c=true,rctrl=true}
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
end

function love.draw(cameras)
    if cameras ~= false and state == "overworld" then
        camera:set()
    end
    lg.setColor(1,1,1,1) --reset color
    if state == "menu" then
        menu:draw()
    elseif state == "overworld" then
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
        rooms[rooms.current]:draw() --draw room
        sans:draw() --draw sans
        rooms[rooms.current]:fgdraw() --draw room foreground
        rooms:opdraw() --draw room transition opacity thing
        if debug_elems then --semi-transparent room element vision (colored)
            lg.setColor(1,1,1,0.5)
            lg.rectangle("fill",
                sans.x+sans.hitbox.x,
                sans.y+sans.hitbox.y,
                sans.hitbox.width, sans.hitbox.height)
            for _,i in pairs(rooms[rooms.current].elements) do
                if i.nocollision then
                    lg.setColor(0,1,0,0.5)
                elseif i.exit then
                    lg.setColor(0,0,1,0.5)
                else
                    lg.setColor(1,0,0,0.5) --regular solid elements are red
                end
                lg.rectangle("fill", i.x, i.y, i.width, i.height)
            end
        end
    end
    lg.setColor(1,1,1,1) --reset color
    if cameras ~= false and state == "overworld" then
        camera:unset()
    end
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
        if state == "overworld" then
            igmenu.popup() --activate in-game menu when c/ctrl is pressed
        end
    
    elseif CONFIRM[k] then
        if state == "overworld" then
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

    elseif k == "right" or k == "left" then --select continue or reset in menu
        if state == "menu" then
            if not menu.resetti then --normal
                menu.selected = k == "left"
            else --reset confirmation screen
                menu.resetsel = k == "left"
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
    if k == "up" or k == "down" or k == "left" or k == "right" then --pause animation
        sans.anim.paused = true

    elseif k == "lshift" and debugon then
        print("super speed off")
        sans.speed = sans.def_speed 
    end
end
