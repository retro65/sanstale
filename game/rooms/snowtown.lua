local st = rooms:new{
    music = "snowdintown",
    name = "Snowdin Town",
    img = love.graphics.newImage("res/img/snowtown.png"),
    fg_img = love.graphics.newImage("res/img/snowtown_fg.png"),
    noscrolly = true,
    start_y = 0
}

--START ELEMENTS

--skelebros' house
st:element(4675, 282, 80, 7, nil, nil,
{new = "ps_house", newx = 427, newy = 400})
st:element(4520, 214, 330, 64)
---the gap to the forest is for entrance to Sans' secret lab
--shortcut tunnel, east end
st:element(4864, 0, 100, 266)
st:element(4889, 266, 50, 5, nil, nil,
{new = "snowtown", newx = 1684, newy = 194})
--shortcut tunnel, west end
st:element(1657, 190, 100, 50)
st:element(1682, 240, 50, 5, nil, nil,
{new = "snowtown", newx = 4891, newy = 220})
--the sign next to tunnel
st:element(1769, 198, 41, 10, {
{"sans", 6, "you can also try reading the welcome sign from behind."},
function() events.snowtown_sign_bait = true end
})
st:element(1769, 208, 41, 30, {
"(Don't want to walk to the other side of town?)",
"(Try the undersnow tunnels!)\n(They're efficiently laid out.)",
{"sans", 0,
    "maybe it's best to use this before the shortcut update comes up."}
})
--papyrus' capture zone (as sans calls it, the garage... doghouse shed...)
st:element(4987, 0, 200, 255, {
{"sans", 0, "this is our garage."},
{"sans", 4, "doghouse..."},
{"sans", 0, "shed..."},
{"sans", 3, "garage-house."},
{"sans", 6, "doghouse-shed."},
{"sans", 2, "thingy..."},
{"sans", 2, "..."},
{"sans", 6, "-ish."}
})
--mailbox1
st:element(4406, 217, 22, 54,
"(It's a mailbox overflowing with unread junk mail.)")
--mailbox2
st:element(4446, 217, 22, 53, "(This mailbox is labelled \"PAPYRUS\".)")
--librarBy
st:element(3777, 0, 488, 204, {
{"sans", 0, "welp, here's the librarby."}
})
--east forest
st:element(3544, 0, 1800, 202)
st:element(5226, 202, 150, 39)
--west forest
st:element(0, 0, 3368, 161)
st:element(161, 161, 405, 20)
st:element(181, 181, 365, 20)
st:element(181, 201, 345, 20)
st:element(181, 221, 325, 20)
--snowdin logo
st:element(612, 209, 356, 54, "(Welcome to Snowdin Town!)")
st:element(612, 206, 356, 3, {
function()
    if events.snowtown_sign_bait then
        dialog:say({"sans", 2, "we've been through this."})
        dialog:say({"sans", 0, "but you came here for pun, right?"})
    else
        dialog:say({"sans", 0, "are you expecting me to read the sign?"})
        dialog:say({"sans", 6, "looks like i'm behind on somethin'."})
    end
end,
function()
    sans:animset('laugh')
    dialog.sfx.rimshot:play()
    wait(2)
    sans:animset('walkdown',1)
end,
{"sans", 0, "the sign is large enough to read."},
{"sans", 2, "why do you need me?"}
})
--shop & snowed inn
st:element(1020, 0, 239, 243)
st:element(1380, 0, 239, 243)
st:element(1259, 0, 121, 222)
--dimensional box
st:element(1356, 250, 40, 40,
function()
    if dialog:say("Use the box?@@Yes@@No@@") == 1 then
        dialog:say("Stay determined for an upcoming inventory update.")
    end
end
)
--grillby's
st:element(2538, 0, 412, 217, {
{"sans", 0, "so are you gonna go in or what?"}
})
st:element(2756, 0, 53, 234) --the pot
--christmas tree
st:element(2257, 238, 121, 85, "(It's a carefully decorated tree.)")
--south forest
st:element(0, 361, 5500, 100)
st:element(178, 320, 336, 20)
st:element(158, 340, 376, 21)
--top border
st:element(0, 0, st.img:getWidth(), 1)
--left border
st:element(0, 0, 1, 500)
--right border
st:element(st.img:getWidth(), 0, 1, 500)

--END ELEMENTS

return st
