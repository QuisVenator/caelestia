local vars = require("variables")

-- Monitors
hl.config({
    render = {
        cm_auto_hdr = false,
    }
})

hl.add_monitor({ name = vars.leftMon,  resolution = "1920x1080@144",    position = "0x180",    scale = 1 })
hl.add_monitor({ name = vars.mainMon,  resolution = "2560x1440@143.86", position = "1920x0",   scale = 1 })
hl.add_monitor({ name = vars.rightMon, resolution = "1920x1080@60",     position = "4480x180", scale = 1 })

-- Workspaces
for i = 1, 10 do
    hl.add_workspace({ id = i,      monitor = vars.mainMon })
end
for i = 11, 20 do
    hl.add_workspace({ id = i,      monitor = vars.rightMon })
end
for i = 21, 30 do
    hl.add_workspace({ id = i,      monitor = vars.leftMon })
end