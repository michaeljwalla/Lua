--the file name will become its callback
--f&r objName to filename
local name = "objName"
local objName = {}
local objNameNSM = {} --nonstatic object methods.

local objNameAttributesRW = {}
local objNameAttributesR = setmetatable({
    __type = true
}, {__index = objNameAttributesRW})
--objName references/vars/internal methods
local function index(r,b)
    return r[b]
end
--objName constructor
objName.new = nil

--objName static methods
objName.isobjName = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "objName"
end


--objName nonstatic methods
objNameNSM.toString = nil

objNameNSM.__eq = nil
objNameNSM.__lt = nil
objNameNSM.__le = nil
objNameNSM.compareTo = nil

--lock metatable
objNameNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
objNameNSM.__tostring = objNameNSM.toString or function() return name end

objNameNSM.__index = function(self, index)
    return assert(objNameAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(objNameNSM, index)
end
objNameNSM.__newindex = function(self, index, value)
    assert(objNameAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return objName