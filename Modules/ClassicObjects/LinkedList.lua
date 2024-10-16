--the file name will become its callback
--f&r LinkedList to filename
local name = "LinkedList"
local LinkedList = {}
local LinkedListNSM = {} --nonstatic object methods.

local LinkedListAttributesRW = {}
local LinkedListAttributesR = setmetatable({
    __type = true
}, {__index = LinkedListAttributesRW})
--LinkedList references/vars/internal methods
local ListNode = require("Modules.ClassicObjects.ListNode")
local function index(r,b)
    return r[b]
end
--LinkedList constructor
LinkedList.new = function(...)
    local addData = {...}

    local head = ListNode.wrap(addData[1])
    local cur = head
    for i = 2, #addData do
        cur.next = ListNode.wrap(addData[i])
        cur = cur.next
    end
    return setmetatable({
        head = head
    }, LinkedListNSM)
end

--LinkedList static methods
LinkedList.isLinkedList = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "LinkedList"
end


--LinkedList nonstatic methods
LinkedListNSM.toString = function(self)
    local str = name.." ["

    local cur = self.head
    local antiCyclic = {}
    while cur do
        if antiCyclic[cur] then
            return str.."Cyclic ListNode]"
        end
        str = str..tostring(cur)..", "
        cur = cur.next
    end --concatenation
    return str:sub(1,-3).."]" --clip off extra comma
end

LinkedList.add = function()

LinkedListNSM.__eq = nil
LinkedListNSM.__lt = nil
LinkedListNSM.__le = nil
LinkedListNSM.compareTo = nil

--lock metatable
LinkedListNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
LinkedListNSM.__tostring = LinkedListNSM.toString or function() return name end

LinkedListNSM.__index = function(self, index)
    return assert(LinkedListAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(LinkedListNSM, index)
end
LinkedListNSM.__newindex = function(self, index, value)
    assert(LinkedListAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return LinkedList