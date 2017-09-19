require 'cairo'
rings = {
    
    outer = {
        name = "clock",
        parameter = "",
        radius = 150,
        x = 150,
        y = 150,
        color = 0x7d7d7d,
        alpha = 0.8,
        start_angle = 0,
        end_angle = 360,
    },
    inner = {
        name = "time",
        parameter = "%s",
        radius = 145,
        x = 150,
        y = 150,
        color = 0xc8cbb4,
        alpha = 0.2,
        start_angle = 0,
        end_angle = 360
    }
}

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end


function draw_ring(cairo_env,properties)

    local command=''
    local seconds=0
    local line_width=5

    if (properties["name"] == "time") then
        command=string.format('${%s %s]', properties["name"], properties["parameter"])
        command=conky_parse(command)
    end

    if (command == '') then
        seconds=tonumber(command)
    end

    local color = properties["color"]
    local alpha = properties["alpha"]
    local radiant_start_angle = properties["start_angle"]*(2*math.pi/360)-math.pi/2
    local radiant_end_angle = properties["end_angle"]*(2*math.pi/360)-math.pi/2
    local ring_x = properties["x"]
    local ring_y = properties["y"]
    local ring_radius = properties["radius"]

    print("x:"..ring_x.." y:"..ring_y .." r:"..ring_radius.." a:"..alpha.." c:"..color.." sa:"..radiant_start_angle.." ea:"..radiant_end_angle)

    cairo_arc(cairo_env,ring_x,ring_y,ring_radius,radiant_start_angle,radiant_end_angle)
    cairo_arc(cairo_env,10,10,100,2*math.pi/3,2*math.pi)
    cairo_set_source_rgba(cairo_env,rgb_to_r_g_b(color,alpha))
    cairo_set_line_width(cairo_env,line_width)
    cairo_stroke(cairo_env)
--]]
end 

function conky_main()
    if conky_window == nil then
        return
    end

    -- initialize cairo
    
    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )

    local ct = cairo_create(cs)
    local updates=tonumber(conky_parse('${updates}'))
    if updates>5 then
        draw_ring(ct,rings["outer"])

        draw_ring(ct,rings["inner"])
    end

    cairo_destroy(ct)
    cairo_surface_destroy(cs)
    ct=nil
end
