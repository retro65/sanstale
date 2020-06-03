local psk = rooms:new{
    noscrollx = true,
    noscrolly = true,
    music = "sans",
    name = "Snowdin-Skeleton house",
    img = love.graphics.newImage("res/img/ps_kitchen.png"),
} 
psk.start_x = psk.img:getWidth()/2-width/2 --start positions (camera)
psk.start_y = psk.img:getHeight()/2-height/2 

--papyrus and sans' kitchen

--oven
psk:element(337, 191, 41, 58, {"(It's an oven.)",
{"sans", 1, "papyrus always cooks his spaghetti here."}})

--table
psk:element(340, 107, 38, 84, {"(It's a table.)",
{"sans", 1, "papyrus always eats his spaghetti here."}})

--closet
psk:element(384, 7, 66, 130, "(It's a closet.)\n(It's filled with bones.)")

--fridge
psk:element(466, 27, 67, 108,
"(It's a fridge.)\n(It's filled with spaghetti, tomato sauce and ketchup.)")

--right wall
psk:element(532, 132, 25, 123)
--bottom right corner
psk:element(492, 255, 40, 7)
--bottom left corner
psk:element(333, 255, 40, 7)

--trash can
psk:element(496, 207, 34, 40,
"(It's a trash can.)\n(There are some crumpled up papers at the bottom.)")

--exit
psk:element(374, 260, 118, 11, nil, nil, {new = "ps_house", newx = 400, newy = 220})

return psk
