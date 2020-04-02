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
    events = {}
    if love.filesystem.getInfo(save.file) then --if save file exists
        firsttime = false
        for line in love.filesystem.lines(save.file) do --parse each line
            local var, value = save.parse(line)
            if     var == "x" then sans.x = value
            elseif var == "y" then sans.y = value
            elseif var == "lv" then sans.lv = value
            elseif var == "exp" then sans.exp = value
            elseif var == "hp" then sans.hp = value
            elseif var == "gold" then sans.gold = value
            elseif var == "r" then rooms:load(value)
            elseif var == "t" then playtime = tonumber(value)
            elseif var == "events" then
                for k in value:gmatch("(%g+)") do
                    events[k:sub(1,-2)] = true
                end
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
    data = data.."lv: "..tostring(sans.lv).."\n"
    data = data.."exp: "..tostring(sans.exp).."\n"
    data = data.."hp: "..tostring(sans.hp).."\n"
    data = data.."gold: "..tostring(sans.gold).."\n"
    data = data.."r: "..rooms.current.."\n"
    data = data.."t: "..tostring(playtime).."\n"
    data = data.."events: "
    for k,v in pairs(events) do
        data = data..k..", "
    end
    print("Saving: '", data, "'")
    love.filesystem.write(save.file, data)
end

return save
