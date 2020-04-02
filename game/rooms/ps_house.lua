local pshr = rooms:new{
    music = "sans",
    noscrollx = true,
    noscrolly = true,
    name = "Snowdin-Skeleton house",
    img = love.graphics.newImage("res/img/ps_house.png"), --load image
} --papyrus and sans' house
    
pshr.start_x = pshr.img:getWidth()/2-width/2 --start positions (camera)
pshr.start_y = pshr.img:getHeight()/2-height/2 

--ELEMENTS

--papyrus door
pshr:element(44, 10, 60, 92, { "The labels on the door read:",
{font = "papyrus", voice = "papyrus", text = "no girls allowed!\nno boys allowed!"},
{font = "papyrus", voice = "papyrus", text = "papyrus allowed."}})

--bone frame
pshr:element(252, 14, 94, 96, {"This image reminds you of\nwhat's important in life.",
{face = "sans", facenum = 4, text = "such as..."},
{face = "sans", facenum = 3, text = "...sleeping."},
{face = "sans", facenum = 0, text = "and knowing how to\nopen the door to my\nroom."},
{face = "sans", facenum = 6, text = "...to sleep."}}, true)
--that's a hint on how to go back to sans' room

--door to sans' room
pshr:element(460, 98, 60, 13, nil, true, nil, function() rooms:change("sans", 90, 330) end)

--couch
pshr:element(172, 348, 160, 74, nil, nil, nil,
function()
    if not events.couch then
        dialog:say(nil,nil,"(You touch the couch.)")
        dialog:say(nil,nil,"(It makes a jangling sound.)")
        dialog:say(nil,nil,
            "(You find a bunch of loose coins\ninside the couch...)")
        sans.gold=sans.gold+20
        events.couch=true
        dialog:say(nil,nil,"(You got 20G.)")
    else
        dialog:say(nil,nil,"(It's a saggy old couch.)")
    end
end)

--book
pshr:element(32, 356, 50, 50, {"(It's a joke book.)",
"(Inside the joke book was a\nquantum physics book.)",
"(You look inside...)",
"(Inside the quantum physics\nbook was another joke book.)",
"(You look inside...)",
"(There's another quantum\nphysics book...)",
{text = "I think that's enough.", face = "sans", facenum = 1}})

--tv
pshr:element(202, 194, 103, 93, "(The tv doesn't appear to be\nplugged.)")

--socks
pshr:element(324, 248, 18, 44, {{face = "sans", facenum = 0, text = "i should probably pick up\nmy socks."},
{face = "sans", facenum = 6, text = "just kidding."}})

--kitchen door
pshr:element(374, 250, 118, 11, nil, nil, {new = "ps_kitchen", newx = 400, newy = 198})

--table
pshr:element(496, 284, 74, 136, "(There's some spaghetti here.)\n(It doesn't look very tasty.)")

--door to snowdin
pshr:element(412, 467, 80, 7, nil, nil, {new = "snowtown", newx = 4690, newy = 250})

--middle wall thing 1 (left to kitchen)
pshr:element(136, 162, 241, 102)
--middle wall thing 2 (above kitchen)
pshr:element(372, 162, 122, 10)
--middle wall thing 3 (right to kitchen)
pshr:element(492, 162, 92, 102)
--top wall
pshr:element(12, 0, 560, 100)
--left wall
pshr:element(0, 100, 12, 61)
--left wall (next to stairs)
pshr:element(0, 162, 18, 102)
--right wall next to the door leading to sans' room
pshr:element(572, 100, 30, 62)
--left wall next to the book
pshr:element(0, 264, 12, 160)
--bottom left  wall
pshr:element(12, 420, 400, 40)
--right wall
pshr:element(572, 265, 39, 169)
--bottom left wall
pshr:element(492, 424, 92, 40)

--END ELEMENTS

return pshr
