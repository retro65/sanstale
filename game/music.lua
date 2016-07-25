local mus = {current=nil}

function mus:load()
    for n,filename in ipairs(love.filesystem.getDirectoryItems("res/aud/mus")) do
        print("Loading",filename)
        mus[filename:gsub(".ogg", "")] = love.audio.newSource("res/aud/mus/"..filename, "stream")
    end
end

function mus:play(m, loop)
    if self[self.current] then
        self[self.current]:stop()
    end
    self.current = m
    if loop then self[self.current]:setLooping(true) end
    self[self.current]:play()
end

return mus
