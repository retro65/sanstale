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

function collision(x1,y1,w1,h1, x2,y2,w2,h2) --simple function to detect collision between two rectangles
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end


function love.load(arg)
    CONFIRM = {z=true, ["return"] = true} --constants
    CANCEL = {x=true,rshift=true}
    width = lg.getWidth()
    height = lg.getHeight()
    --load modules
    dialog:load()
    music:load()
   
    state = "menu"

    debugon = (arg[2] == "debug") --activate debug mode
    if debugon then
        debugtext = lg.newText(dialog.fonts.determination, "DEBUG ON")
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
    if state == "menu" then
        menu:draw()
    elseif state == "overworld" then
        if not rooms[rooms.current].noscrollx then --adjust camera x to sans if room hasn't got the flag noscrollx
            camera:setX(sans.x-width/2+sans.width/2)
        end
        if not rooms[rooms.current].noscrolly then --adjust camera y to sans if room hasn't got the flag noscrolly
            camera:setY(sans.y-height/2+sans.height/2)
        end
        rooms[rooms.current]:draw() --draw room
        sans:draw() --draw sans
        rooms:opdraw() --draw room transition opacity thing
    end
    
    if cameras ~= false and state == "overworld" then
        camera:unset()
    end
    
    if debugon then
        lg.draw(debugtext, 0, height-debugtext:getHeight())
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
