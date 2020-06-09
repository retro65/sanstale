local dog = {}
dog.sheet = love.graphics.newImage("res/img/dog.png")
dog.grid = anim8.newGrid(1150, 950, dog.sheet:getWidth(), dog.sheet:getHeight()) 
dog.anim = anim8.newAnimation(dog.grid('1-2',1), 0.2) 
dog.rot = 0

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
 
function love.errorhandler(msg)
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
    end

    if love.audio then love.audio.stop() end
    love.graphics.reset()
    local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)

    local trace = debug.traceback()

    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()

    local err = {}

    table.insert(err, "\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    local copy_button = love.graphics.newText(love.graphics.newFont("res/font/determination.ttf", 18), "Copy to clipboard")
    local copied_text = love.graphics.newText(love.graphics.newFont("res/font/determination.ttf", 18), "Copied to clipboard")
    local copied = false
    local copied_timer = 0

    local function draw()
        pos = love.window.toPixels(70)
        love.graphics.clear(love.graphics.getBackgroundColor())

        dog.anim:draw(dog.sheet, width-115,height-95, dog.rot, 0.1,0.1, 575, 475)

        if copied then
            love.graphics.draw(copied_text, pos, love.graphics.getHeight()-pos-40)
        end
        love.graphics.print("An error occurred! Send this to the author of this game, so he can fix the bug.", pos,pos)
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)

        love.graphics.rectangle("line", pos-5, love.graphics.getHeight()-pos-5, 200, 30)
        love.graphics.draw(copy_button, pos,love.graphics.getHeight()-pos)
        love.graphics.present()
    end

    while true do
        love.event.pump()

        if copied then
            copied_timer = copied_timer + love.timer.getDelta()
        end

        dog.rot = dog.rot + math.rad(90)*love.timer.getDelta()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return
            elseif e == "keypressed" and a == "escape" then
                return
            elseif e == "mousepressed" then
                if c == 1 then --left click
                    local x,y = a,b
                    if x < pos-5+200 and
                    pos-5 < x+1 and
                    y < love.graphics.getHeight()-pos-5+30 and
                    love.graphics.getHeight()-pos-5 < y+1 then
                        print("Copied to clipboard!")
                        love.system.setClipboardText(p)
                        copied = true
                    end
                end
            end
        end

        if copied_timer >= 2 then 
            copied_timer = 0
            copied = false
        end

        dog.anim:update(love.timer.getDelta())
        draw()
    end
end
