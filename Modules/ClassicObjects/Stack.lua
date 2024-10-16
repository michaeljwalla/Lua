--the file name will become its callback
--f&r Stack to filename
local name = "Stack"
local Stack = {}
local StackNSM = {} --nonstatic object methods.

local StackAttributesRW = {}
local StackAttributesR = setmetatable({
    __type = true
}, {__index = StackAttributesRW})
--Stack references/vars/internal methods
local function index(r,b)
    return r[b]
end
--Stack constructor
Stack.new = nil

--Stack static methods
Stack.isStack = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "Stack"
end


--Stack nonstatic methods
StackNSM.toString = nil

StackNSM.__eq = nil
StackNSM.__lt = nil
StackNSM.__le = nil
StackNSM.compareTo = nil

--lock metatable
StackNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
StackNSM.__tostring = StackNSM.toString or function() return name end

StackNSM.__index = function(self, index)
    return assert(type(StackNSM[index]) == 'function' or StackAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(StackNSM, index)
end
StackNSM.__newindex = function(self, index, value)
    assert(StackAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return Stack