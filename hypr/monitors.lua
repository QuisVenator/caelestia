local vars = require("variables")

-- Monitors
hl.config({
    render = {
        cm_auto_hdr = false,
    }
})

hl.monitor({ output = vars.leftMon,  mode = "1920x1080@144",    position = "0x180",    scale = 1 })
hl.monitor({ output = vars.mainMon,  mode = "2560x1440@144",    position = "1920x0",   scale = 1 })
hl.monitor({ output = vars.rightMon, mode = "1920x1080@60",     position = "4480x180", scale = 1 })

-- Workspaces
for i = 1, 10 do
    hl.workspace_rule({ workspace = i, monitor = vars.mainMon })
end
for i = 11, 20 do
    hl.workspace_rule({ workspace = i, monitor = vars.rightMon })
end
for i = 21, 30 do
    hl.workspace_rule({ workspace = i, monitor = vars.leftMon })
end