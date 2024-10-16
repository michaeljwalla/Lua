--the file name will become its callback
--f&r Vector to filename
local name = "Vector"
local Vector = {}
local VectorNSM = {} --nonstatic object methods.

local VectorAttributesRW = {}
local VectorAttributesR = setmetatable({
    __type = true
}, {__index = VectorAttributesRW})
--Vector references/vars/internal methods
local function index(r,b)
    return r[b]
end
--Vector constructor
Vector.new = nil

--Vector static methods
Vector.isVector = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "Vector"
end


--Vector nonstatic methods
Vector.add = function(self)

end

Vector.addAll = function(self)

end

Vector.addElement = function(self)

end

Vector.capacity = function(self)

end

Vector.clear = function(self)

end

Vector.clone = function(self)

end

Vector.contains = function(self)

end

Vector.containsAll = function(self)

end

Vector.copyInto = function(self)

end

Vector.elementAt = function(self)

end

Vector.elements = function(self)

end

Vector.ensureCapacity = function(self)

end

Vector.equals = function(self)

end

Vector.firstElement = function(self)

end

Vector.forEach = function(self)

end

Vector.get = function(self)

end

Vector.hashCode = function(self)

end

Vector.indexOf = function(self)

end

Vector.insertElementAt = function(self)

end

Vector.isEmpty = function(self)

end

Vector.lastElement = function(self)

end

Vector.lastIndexOf = function(self)

end

Vector.listIterator = function(self)

end

Vector.remove = function(self)

end

Vector.removeAll = function(self)

end

Vector.removeAllElements = function(self)

end

Vector.removeElement = function(self)

end

Vector.removeIf = function(self)

end

Vector.removeRange = function(self)

end

Vector.replaceAll = function(self)

end

Vector.retainAll = function(self)

end

Vector.set = function(self)

end

Vector.setElementAt = function(self)

end

Vector.setSize = function(self)

end

Vector.size = function(self)

end

Vector.sort = function(self)

end

Vector.subList = function(self)

end

Vector.toArray = function(self)

end

Vector.toString = function(self)

end

Vector.trimToSize = function(self)

end


VectorNSM.__eq = nil
VectorNSM.__lt = nil
VectorNSM.__le = nil
VectorNSM.compareTo = nil

--lock metatable
VectorNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
VectorNSM.__tostring = VectorNSM.toString or function() return name end

VectorNSM.__index = function(self, index)
    return assert(type(VectorNSM[index]) == 'function' or VectorAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(VectorNSM, index)
end
VectorNSM.__newindex = function(self, index, value)
    assert(VectorAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return Vector