local save = {}

function save.parse(string) --save file parser
    local t = {}
    for i=0,#string,1 do
        if string:sub(i,i) == ":" then
            t[1] = string:sub(1,i-1)
            t[2] = string:sub(i+2,#string)
            break
        end
    end
    return t[1], t[2]
end

function save.load() --load things
    if love.filesystem.exists(save.file) then --if save file exists
        firsttime = false
        for line in love.filesystem.lines(save.file) do --parse each line
            local var, value = save.parse(line)
            if     var == "x" then sans.x = value
            elseif var == "y" then sans.y = value
            elseif var == "r" then rooms:load(value)
            elseif var == "t" then playtime = tonumber(value)
            end
        end
    else
        firsttime = true
        rooms:load('sans') --load the sans room
    end
end

function save.save()
    local data = ""
    data = data.."x: "..tostring(sans.x).."\n"
    data = data.."y: "..tostring(sans.y).."\n"
    data = data.."r: "..rooms.current.."\n"
    data = data.."t: "..tostring(playtime)
    print("Saving: '", data, "'")
    love.filesystem.write(save.file, data)
end

return save
