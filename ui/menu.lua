local menu = {}

menu.img = love.graphics.newImage("res/img/menu.png")
menu.selected = true --true is continue, false is reset
menu.resetti = false --reset confirmation menu
menu.resetsel = true --reset confirmation: true is no, false is yes
menu.resetted = false --resetted message that shows up when u reset

function menu:draw()
    love.graphics.setFont(dialog.fonts.determination)
    
    if self.resetted then --print resetted thing
        love.graphics.print("Resetted\n(press z)", width/3-30, height/2-60, 0, 2,2)
    elseif not self.resetti then --normal menu
        love.graphics.draw(self.img,0,0)
        local time = string.format("%.2d:%.2d", playtime/(60*60), playtime/60%60) --print time played
        love.graphics.print(time, 420,128)
        
        --Print location
        love.graphics.print(rooms[rooms.current].name, 140, 168)

        if self.selected then --continue selected
            love.graphics.print({{1,1,0},"Continue"}, 170,228)
            love.graphics.print("Reset",                  350,228)
        else --reset selected
            love.graphics.print("Continue",               170,228)
            love.graphics.print({{1,1,0},  "Reset"},  350,228)
        end
        --Print L.O.VE and 'sans'
        love.graphics.print("LV"..tostring(sans.lv), 280, 128)
        love.graphics.setFont(dialog.fonts.sans)
        love.graphics.print("sans", 140, 128)

    else --reset confirmation menu
        love.graphics.print("Are you sure you want to reset?", 80, 158)

        if self.resetsel then --no selected
            love.graphics.print({{1,1,0},"NOO!!"}, 170,228)
            love.graphics.print("Yes",                 380,228)
        else --yes selected
            love.graphics.print("NOO!!",               170,228)
            love.graphics.print({{1,1,0},"Yes"},   380,228)
        end
    end
end

return menu
