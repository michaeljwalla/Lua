--the file name will become its callback
--f&r objName to filename
local name = "objName"
local objName = {}
local objNameNSM = {} --nonstatic object methods.

--objName variables

--objName constructor
objName.new = nil

--objName static methods
objName.XYZ = nil

--objName nonstatic methods
objNameNSM.XYZ = nil
objNameNSM.__eq = nil
objNameNSM.__lt = nil
objNameNSM.__le = nil
objNameNSM.__tostring = nil
objNameNSM.compareTo = nil

--lock metatable
objNameNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
objNameNSM.__tostring = objNameNSM.__tostring or function() return name end
objNameNSM.toString = objNameNSM.__tostring
--jst to ensure toString exists

objNameNSM.__index = function(self, index)
    return rawget(objNameNSM, index) or error("Missing attribute/method of "..name..": "..tostring(index))
end
objNameNSM.__newindex = function(self, index, value)
    error("Attempt to assign value to "..name.." object")
end
--
return objName