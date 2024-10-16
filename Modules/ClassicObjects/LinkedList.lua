--the file name will become its callback
--f&r LinkedList to filename
local name = "LinkedList"
local LinkedList = {}
local LinkedListNSM = {} --nonstatic object methods.

local LinkedListAttributesRW = {
    head = true
}
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

    local head = nil
    if #addData > 0 then
        head = ListNode.wrap(addData[1])
        local cur = head
        for i = 2, #addData do
            cur.next = ListNode.wrap(addData[i])
            cur = cur.next
        end
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
LinkedList.isCyclic = function(self)                                        --to check if the linked list is cyclic (reduced built-in funcs)
    local cur = self.head
    local nodeTbl = {}
    while cur do
        if nodeTbl[cur] then return true end
        nodeTbl[cur] = true
        cur = cur.next
    end
    return false
end


--LinkedList nonstatic methods
LinkedListNSM.toString = function(self)
    if LinkedList.isCyclic(self) then return "[Cyclic LinkedList]" end
    if not self.head then return "LinkedList []" end
    local str = name.." ["
    self:forEach(function(cur)
        str = str..tostring(cur.data)..", "
    end)
    return str:sub(1,-3).."]" --clip off extra comma
end

LinkedListNSM.forEach = function(self, callback)
    assert( not LinkedList.isCyclic(self), "LinkedList is cyclic")
    local cur = self.head
    while cur do
        callback(cur)
        cur = cur.next
    end
end
LinkedListNSM.getTail = function(self)
    local tail = nil
    self:forEach(function(cur)
        if not cur.next then tail = cur end
    end)
    return tail
end
LinkedListNSM.getLength = function(self)
    local i = 0
    self:forEach(function() i = i + 1 end)
    return i
end
LinkedListNSM.push = function(self, ...)
    local values = {...}
    local tail = self.head and self:getTail()
    local i = 1
    if not tail then                    --is empty
        self.head = ListNode.wrap(values[1])
        tail = self.head
        i = 2
    end
    for i = i, #values do
        tail.next = ListNode.wrap(values[i])
        tail = tail.next
    end
    return self:getLength()
end
LinkedListNSM.pop = function(self, ...)
    if not self.head then return nil end
    assert( not LinkedList.isCyclic(self), "LinkedList is cyclic")

    local cur, next = self.head, nil
    if not cur.next then --if LL is length 1
        rawset(self, "head", nil)
        return cur
    end

    while cur do
        next = cur.next
        if not next.next then
            rawset(cur, "next", nil) --remove last
            return next
        end
        cur = next
    end
    return
end
LinkedListNSM.at = function(self, index)
    local len = self:getLength() --i know it isnt efficient
    if index < 0 then index = len+1 + index end
    assert(index > 0 and index <= len, "Index out of bounds error") --protects from empty list and out-of-bounds
    local cur = self.head
    local i = 1
    while i < index do
        i = i + 1
        cur = cur.next
    end
    return cur
end

LinkedListNSM.__eq = nil
LinkedListNSM.__lt = nil
LinkedListNSM.__le = nil
LinkedListNSM.compareTo = nil
--lock metatable
LinkedListNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
LinkedListNSM.__tostring = LinkedListNSM.toString or function() return name end

LinkedListNSM.__index = function(self, index)
    return assert(type(LinkedListNSM[index]) == 'function' or LinkedListAttributesR[index], "Missing attribute/method of "..name..": "..tostring(index))
    and rawget(LinkedListNSM, index)
end
LinkedListNSM.__newindex = function(self, index, value)
    assert(LinkedListAttributesRW[index], "Attempt to assign value to "..name.." object")
    rawset(self, index, value)
    return
end
--
return LinkedList