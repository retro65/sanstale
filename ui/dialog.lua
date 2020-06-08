local dialog = {
    delay = 0.04,
    choiceH = 100,
    silent = {
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
    },
    active = false
} --namespace

dialog.sfx = { --sound effects (for dialogue) (stream because used rarely)
    rimshot = love.audio.newSource("res/aud/sfx/mus_rimshot.ogg", "stream")
}

dialog.faces = { --table that holds all dialog box faces
    papyrus = {},
    sans = {},
    def = {{getWidth = function(self) return 20 end}} --default (blank)
}

dialog.voices = { --all voices
    papyrus = love.audio.newSource("res/aud/voices/papyrus/1.wav", "static"),
    sans = love.audio.newSource("res/aud/voices/sans/1.wav", "static"),
    default = love.audio.newSource("res/aud/voices/default/1.wav", "static")
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
    if not text then --expect face to contain dialogue
        if type(face) == 'table' then
            face, facenum, text, font, voice = face[#face-2], face[2], face[#face], face.font, face.voice
        else --else it's a string (set face to nil)
            text, face = face, nil
        end
    end
    face = face or 'def' --def is default
    if face == 'def' then facenum = 1 end 
    local asterisk = "* "

    local textp = 1
    local opt = {}
    while true do
        local len = #opt
        text = text:gsub("@@([%g ]-)@@",
            function (s)
                table.insert(opt, {0, self.choiceH, txt=s})
                return "@@"
            end,
        1)
        if len == #opt then break end --if gsub no longer changes anything break
    end
    local just_say = #opt == 0
    if just_say then
        opt = {{-999,-999}}
    else
        text = text:sub(1,-3)
    end
    for i = 1, #opt do
        opt[i][1] = math.floor((i/(#opt+1))*self.box:getWidth()-souls.w/2)
    end

    if text == '' then --remove the asterisk for empty text
        asterisk = ''
    end

    if not font or not voice then
        if face == "papyrus" then --if face is papyrus then voice and font too and text is all uppercase
            voice = "papyrus"
            font = self.fonts.papyrus
            text = text:upper()
            asterisk = ""
        elseif face == "sans" then --same but for sans
            voice = "sans"
            font = self.fonts.sans
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

    local wrwidth,wrt = font:getWrap(text,
        556-self.faces[face][facenum]:getWidth()-font:getWidth(asterisk))
    text = text:gsub('\n','')

    local function draw() --drawing function (MEANT FOR UNSET CAMERA!)
        local x,y = 30, 10
        if sans.y-camera:getY()+sans.height/2 <= height/2 then
            y = height-self.box:getHeight()-10
        end
        love.graphics.draw(self.box, x, y) --draw dialog box
        if face ~= 'def' then --draw face
            love.graphics.draw(self.faces[face][facenum], x+10, y+10)
        end
        love.graphics.setFont(font)
        love.graphics.print({{1,1,1}, asterisk},
            x+10+self.faces[face][facenum]:getWidth(), y+18)
        local cc = 0 --count characters already went over
        local x2 = x+10+self.faces[face][facenum]:getWidth()+
            font:getWidth(asterisk)
        for i = 1, #wrt do
            if cc+#(wrt[i]) <= textp then
                love.graphics.print({{1,1,1}, wrt[i]},
                    x2, y+18+font:getHeight()*(i-1))
            else
                love.graphics.print({{1,1,1}, wrt[i]:sub(1,textp-cc)},
                    x2, y+18+font:getHeight()*(i-1))
                break
            end
            cc = cc+#(wrt[i])
        end
        if not just_say and textp >= #text then --display options
            for i = 1, #opt do
                love.graphics.print({{1,1,1}, opt[i].txt},
                    x+opt[i][1]+souls.w+2, y+self.choiceH-souls.h/2)
            end
        end
        return x,y
    end

    local txt_t = 0

    function cond(dt, t)
        txt_t = txt_t + dt
        if txt_t >= self.delay then
            txt_t = txt_t - self.delay
            if textp < #text then
                if not self.silent[text:sub(textp,textp)] then
                    self.voices[voice]:play() --voice sounds
                end
                textp = textp+1
            end
        end
        if textp >= #text then
            return true
        end
    end

    function evh(ev,a,b,c)
        if ev == "keypressed" then
            if CANCEL[a] then --skip text
                textp = #text
            end
        end
    end

    wait(cond, evh, draw)

    return prompt:choice(opt, draw, {nocancel=true,mute=just_say})
end

return dialog
