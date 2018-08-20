require"TblUtilis"
MouseOnUI = false

require"/Tiles/tiles"
require"/Entities/entities"
bitser = require"bitser-master.bitser"
binser = require"binser-master.binser"
--require"/UI/ui"
-- Init event tables
EVENT = {}
EVENT.draw = {}
EVENT.update = {}
EVENT.resize = {}
EVENT.textinput = {}
EVENT.keypressed = {}

function EVENT:enqueue(str, func)
    table.insert(EVENT[str], func)
end

function EVENT:pop(str, func)
    for i,f in pairs(EVENT[str]) do
        if f == func then
            table.remove(EVENT[str], i)
        end
    end
end

--

require"conn" -- networking init
require"mainScreen"

DEFAULT_IP = "localhost"
DEFAULT_PORT = 63582
