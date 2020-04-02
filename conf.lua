function love.conf(t) --Config file
    t.identity = "sanstale"
    t.version = "11.3"

    t.window.width = 640
    t.window.height = 480
    t.window.resizable = false
    t.window.title = "sanstale"
    t.window.icon = "icon.png"
    
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.thread = false
end
