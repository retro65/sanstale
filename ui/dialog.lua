local dialog = {active = false} --namespace

dialog.faces = { --table that holds all dialog box faces
    papyrus = {},
    sans = {},
    def = {{getWidth = function(self) return 20 end}} --default (blank)
}

dialog.voices = { --all voices
    papyrus = love.audio.newSource("res/aud/voices/papyrus.wav", "static"),
    sans = love.audio.newSource("res/aud/voices/sans.wav", "static"),
    default = love.audio.newSource("res/aud/voices/default.wav", "static")
}

dialog.fonts = { --all fonts
    papyrus = love.graphics.newFont("res/font/papyrus.ttf", 32),
    sans = love.graphics.newFont("res/font/sans.ttf", 34),
    determination = love.graphics.newFont("res/font/determination.ttf", 27)
}

function dialog:load() --loading function
    self.box = love.graphics.newImage("res/img/dialog.png")
    local index
    for name,t in pairs(self.faces) do --loop through dialog.faces
        for _,fname in pairs(love.filesystem.getDirectoryItems("res/img/faces/"..name)) do
            --loop through images in each faces folder
            index = fname:gsub(".png", ""):gsub(".jpg", "")
            self.faces[name][tonumber(index)] = love.graphics.newImage("res/img/faces/"..name.."/"..fname)
        end
    end
end

function dialog:say(face, facenum, text, font, voice)
    face = face or 'def' --def is default
    if face == 'def' then facenum = 1 end 
    local asterisk = "* "

    local text_pointer = 1

    if not font or not voice then
        if face == "papyrus" then --if face is papyrus then voice and font too and text is all uppercase
            voice = "papyrus"
            font = self.fonts.papyrus
            text = text:upper()
            asterisk = ""
        elseif face == "sans" then --same but for sans
            voice = "sans"
            font = self.fonts.sans
            text = text:lower()
        else --default things
            voice = "default"
            font = self.fonts.determination
        end
    else
        if font == "sans" then text = text:lower()
        elseif font == "papyrus" then text = text:upper(); asterisk = ""
        end
        font = self.fonts[font]
    end

    if asterisk == "* " then text = text:gsub("\n","\n  ") end

    local function draw() --drawing function
        camera:set()
        love.draw(false) --draw everyting without updating cameras
        local coords = {x = camera:getX()+30, y = camera:getY()+10}
        if sans.y-camera:getY()+sans.height/2 <= height/2 then
            coords.y = camera:getY()+height-self.box:getHeight()-10
        end
        love.graphics.draw(self.box, coords.x, coords.y) --draw dialog box
        if face ~= 'def' then --draw face
            love.graphics.draw(self.faces[face][facenum], coords.x+10, coords.y+10)
        end
        love.graphics.setFont(font)
        love.graphics.print({{1,1,1}, asterisk..text:sub(1, text_pointer)},
            coords.x+10+self.faces[face][facenum]:getWidth(), coords.y+18) --print text
        love.graphics.present() --tell love to draw everything (you have to do this if you want to draw outside love.draw)
        camera:unset()
    end
    
    sans.canmove = 0 --avoid sans `teleporting` when exiting this function because dt will increase like mad

    local pointer_delay = 0
    local dt
    local loop = true

    while loop do
        dt = love.timer.getDelta()
        pointer_delay = pointer_delay+dt

        love.event.pump()
        for ev, a, b, c in love.event.poll() do --poll events
            if ev == "quit" then
                love.event.quit()
	    elseif ev == "keypressed" then
                if CANCEL[a] then --skip text
                    text_pointer = #text
                elseif CONFIRM[a] and text_pointer >= #text then --if reached end of text then exit lel
                    loop = false
                end
            end
        end
 
        draw() --draw shit
        
        if rooms[rooms.current].update then --update room
            rooms[rooms.current]:update(dt)
        end

        if pointer_delay >= 0.05 then
            pointer_delay = 0
            if text_pointer < #text then
                --soundless symbols table
                local silent = {
                    [" "] = true,
                    ["\n"] = true,
                    [","] = true,
                    ["."] = true,
                    [":"] = true,
                    [";"] = true,
                    ["!"] = true,
                    ["?"] = true,
                    ["'"] = true,
                    ["-"] = true,
                    ["\""] = true,
                    ["("] = true,
                    [")"] = true
                }
                if silent[text:sub(text_pointer,text_pointer)] then
                    self.voices[voice]:seek(0,"seconds")
                else
                    self.voices[voice]:play() --voice sounds
                end
                text_pointer = text_pointer+1
            end
        end
    end
end

return dialog
