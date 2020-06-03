local sansr = rooms:new{
    noscrollx = true,
    noscrolly = true,
    music = "sans",
    name = "Snowdin-Sans'room",
    sheet = love.graphics.newImage("res/img/sansroom.png"), --load spritesheet
    fg_sheet = love.graphics.newImage("res/img/sansroom_fg.png")
}

sansr.grid = anim8.newGrid(336,398, sansr.sheet:getWidth(),sansr.sheet:getHeight()) --load grid
sansr.animation = anim8.newAnimation(sansr.grid('1-19', 1), 0.05) --create animation
sansr.start_x, sansr.start_y = sansr.animation:getDimensions() --start pos
sansr.start_x = sansr.start_x/2-width/2
sansr.start_y = sansr.start_y/2-height/2

--START ELEMENTS

--treadmill (head and note + base)
local treadmill_msg = {
"(There is a note attached to the treadmill.)",
"\"the truth is that you got owned, nerd......\"",
{"sans", 1, "hey, i wrote that note."}}
sansr:element(174, 170, 24, 54, treadmill_msg)
sansr:element(110, 196, 69, 28, treadmill_msg)

--table
sansr:element(24, 82, 99, 62,
"(Clothes and trombones are shoved in haphazardly.)")

--trash tornado
sansr:element(250, 173, 90, 130,
"(It appears to be a self-sustaining tornado made of trash.)")

--letter on top
sansr:element(149, 109, 34, 20,
"(It's a thank you letter.)\n(It's addressed to Santa.)", true)

--pillow
sansr:element(204, 93, 50, 40, "(It's an uncovered pillow.)", true)
    
--Bed thing
sansr:element(255, 88, 66, 101,
"(It's a worn mattress.)\n(The sheets are bunched up in a weird, creasy ball.)")

--Sock
sansr:element(148, 272, 20, 16, "(It's a dirty sock.)", true)

--Sock pile
sansr:element(14, 260, 52, 52, "(It's a dirty sock pile.)", true)

--Left wall
sansr:element(0, 102, 12, 220)
--Up wall
sansr:element(12, 92, 312, 10)
--Right wall
sansr:element(324, 102, 12, 220)
--Bottom right thingie
sansr:element(148, 322, 186, 76)
--Bottom left thingie
sansr:element(0, 322, 68, 76)
--exit
sansr:element(68, 391, 80, 28, nil,nil,
{new = 'ps_house', newx = 467, newy = 56})

--END ELEMENTS

return sansr
