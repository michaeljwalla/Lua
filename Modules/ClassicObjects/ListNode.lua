--the file name will become its callback
--f&r ListNode to filename
local name = "ListNode"
local ListNode = {}
local ListNodeNSM = {} --nonstatic object methods.

local ListNodeAttributesRW = {
    data = true,
    next = true,
}
local ListNodeAttributesR = setmetatable({
    __type = true
}, {__index = ListNodeAttributesRW})
--ListNode variables
local function index(r,b)
    return r[b]
end
local function checkNext(next)
    assert(next==nil or ListNode.isListNode(next), "Expected ListNode or nil for ListNode.next")
    return next
end
--ListNode constructor
ListNode.new = function(data, next)
    return setmetatable({
        data = data,
        next = checkNext(next)
    }, ListNodeNSM)
end
ListNode.wrap = function(data, next) --wraps in a ListNode, if not already one.
    if not ListNode.isListNode(data) then
        return ListNode.new(data, next)
    end
    data.next = checkNext(next)
    return data
end
--ListNode static methods
ListNode.isListNode = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "ListNode"
end
--ListNode nonstatic methods
ListNodeNSM.toString = function(self)
    return name.." ["..tostring(self.data).."]"
end

ListNodeNSM.__eq = nil
ListNodeNSM.__lt = nil
ListNodeNSM.__le = nil
ListNodeNSM.compareTo = nil

--lock metatable
ListNodeNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
ListNodeNSM.__tostring = ListNodeNSM.toString or function() return name end
--jst to ensure toString exists

ListNodeNSM.__index = function(self, index)
    return assert(type(ListNodeNSM[index]) == 'function' or ListNodeAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(ListNodeNSM, index)
end
ListNodeNSM.__newindex = function(self, index, value)
    assert(ListNodeAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return ListNode