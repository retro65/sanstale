local igm = {
    submenu = "menu",
    menus = {
        menu = {{25,29,'menu'},{25,65,'big'},{25,101,'menu'}},
        big = {{-1000,-1000,'menu'}, back='menu'} --move offscreen in stats
    },
    stat_font = love.graphics.newFont("res/font/CryptOfTomorrow.ttf", 16),
    stat_menu = love.graphics.newImage("res/img/stat_menu.png"),
    stat_big = love.graphics.newImage("res/img/stat_big.png"),
    stat_small = love.graphics.newImage("res/img/stat_small.png")
}

function igm:draw() --drawing function (UNSET CAMERA ONLY)
    local x, y = 30, 30
    if sans.y-camera:getY()+sans.height/2 <= height/2 then
        y = height-self.stat_small:getHeight()-30
    end
    --MAIN STATS
    love.graphics.draw(self.stat_small, x, y)
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(dialog.fonts.sans)
    love.graphics.print("sans", x+14, y+8)
    love.graphics.setFont(self.stat_font)
    love.graphics.print(tostring(sans.lv), x+50, y+48)
    love.graphics.print(tostring(sans.hp).."/1", x+50, y+66)
    love.graphics.print(tostring(sans.gold), x+50, y+84)
    --MENU SELECT
    y = (height-self.stat_menu:getHeight())/2
    love.graphics.draw(self.stat_menu, x, y)
    --CURRENT SUBMENU
    if self.submenu ~= 'menu' then
        x = x+self.stat_small:getWidth()+10
        y = 30
        love.graphics.draw(self['stat_'..self.submenu], x, y)
    end
    if self.submenu == 'big' then
        love.graphics.setFont(dialog.fonts.sans)
        love.graphics.print('"sans"', x+28, y+32)
        love.graphics.setFont(dialog.fonts.determination)
        love.graphics.print(tostring(sans.lv), x+66, y+92)
        love.graphics.print(tostring(sans.hp)..'/1', x+66, y+124)
        love.graphics.print('1(0)', x+66, y+188)
        love.graphics.print('1(0)', x+66, y+220)
        love.graphics.print(tostring(sans.gold), x+94, y+352)
        love.graphics.print(tostring(sans.exp), x+248, y+188)
    end
    return x, y
end

function igm:popup()
    sans.canmove = 0 --dt will build up madly, freeze sans until after return

    prompt.select_snd:play()
    self.submenu = 'menu'

    while true do
        local i = prompt:choice(self.menus[self.submenu],self,{menuC=true})
        if i == nil then
            self.submenu = self.menus[self.submenu].back
        elseif i == false then --quit the entire menu
            break
        else
            self.submenu = self.menus[self.submenu][i][3]
        end
        if not self.submenu then
            break
        end
    end
end

return igm
