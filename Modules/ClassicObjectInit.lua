local defaults = {"Array", "LinkedList", "ListNode"}


if (_ENV) then --getfenv doesn't exist?
    _ENV.getfenv = function() return _ENV end
end

local module = {}

module.import = function(arg) 
    if arg then
        getfenv()[arg] = require("Modules.ClassicObjects."..arg)
        return
    end
    for i,v  in next, defaults do
        module.import(v)
    end
    return
end
return module