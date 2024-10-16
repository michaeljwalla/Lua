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
local insert = table.insert
local function index(r,b)
    return r[b]
end
local quickSort = require("Modules.Sorts.QuickSort")
--Vector constructor
Vector.new = function(...)
    return setmetatable({...}, VectorNSM)
end
Vector.from = function(arr)
    return setmetatable({unpack(arr)}, VectorNSM)
end

--Vector static methods
Vector.isVector = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "Vector"
end


--Vector nonstatic methods
VectorNSM.add = function(self, a1, a2)                                              --<bool>appends item to specified index or end of list
    local len = #self
    local elem, index;
    if not a2 then
        elem, index = a1, len+1 --vector:add(item)
    else
        elem, index = a2, a1    --vector:add(indexAt, item)
    end

    for i = len, index, -1 do --shifting items to right
        rawset(self, i+1, self[i])
    end
    rawset(self, index, elem)
    return true
end

VectorNSM.addAll = function(self, ...)                                              --<bool> adds variant args to vector
    local args = {...}
    if #args == 1 and type(args[1]) == 'table' then --if param was just a table, not a tuple
        args = args[1]
    end
    local len = #self
    for i,v in pairs(args) do
        rawset(self, len+i, v)
    end
    return true
end

VectorNSM.addElement = VectorNSM.add                                                --<bool> lua doesnt have size constraints

VectorNSM.capacity = function(self)                                                 --<int> lua doesn't have size constraints
    return #self
end

VectorNSM.clear = function(self)                                                    --<nil> empties the list
    for i,v in next, self do
        rawset(self, i, nil)
    end
    return
end

VectorNSM.clone = function(self)                                                    --<Vector> returns a shallow copy of itself
    return Vector.from(self)
end

VectorNSM.contains = function(self, item)                                           --<bool> checks if item is present in list
    for i,v in pairs(self) do
        if v == item then return true end
    end
    return false
end

VectorNSM.containsAll = function(self, itemArr)                                     --<bool> checks if all items in itemArr present in list
    if #self < #itemArr then return false end --obviously it cant hold all in this case
    local items = {}
    for i,v in pairs(items) do
        items[v] = (items[v] or 0) + 1 --counts occurrences
    end
    for i,v in pairs(self) do
        if (items[v] or 0) > 0 then --if items[v] exists and not already accounted for
            items[v] = items[v] - 1
        end
    end

    for i,v in pairs(items) do
        if v ~= 0 then return false end
    end
    return true
end

VectorNSM.copyInto = function(self, arr)                                            --<nil> adds items from self into arr
    local len = #arr
    for i,v in pairs(self) do
        rawset(arr, len+i, v)
    end
    return
end

VectorNSM.elementAt = index                                                         --<any> not useful since data is directly accessible

VectorNSM.elements = function(self)                                                 --<enumerator, Vector> enumerator function
    return next, self
end

VectorNSM.ensureCapacity = function(self)                                           --<nil> lua doesnt have size constraints
    return
end

VectorNSM.equals = function(self, vec)                                              --<bool> checks if all elems are equal in array
    if not Vector.isVector(vec) then return false end
    for i,v in pairs(self) do
        if v ~= rawget(vec, i) then return false end --i should have started abstracting from Object... ~= =/= !Object.equals(a,b)...
    end
    return true
end

VectorNSM.firstElement = function(self)                                             --<any> returns the vector's first elem
    return rawget(self, 1)
end

VectorNSM.forEach = function(self, callback)                                        --<nil> performs callback() for each pair
    for i,v in pairs(self) do callback(v, i, self) end
    return
end

VectorNSM.get = index                                                               --<any> self explanatory

VectorNSM.hashCode = function(self)                                                 --<int> only generally attainable through a c closure.
    return 0x0
end

VectorNSM.indexOf = function(self, elem)                                            --<int> index of elem, or -1 if not present
    for i,v in pairs(self) do
        if v == elem then return i end --:( i shouldve done Object...
    end
    return -1
end

VectorNSM.insertElementAt = function(self, elem, index)                             --<void>lua has no size constraints
    self:add(index, elem)
    return
end

VectorNSM.isEmpty = function(self)                                                  --<bool> checks if list has no entries
    return #self == 0
end

VectorNSM.lastElement = function(self)                                              --<elem> returns last elem in list
    return rawget(self, #self)
end

VectorNSM.lastIndexOf = function(self, elem)                                        --<int> returns last occurrence of elem
    for i = #self, 1, -1 do
        if self[i] == elem then return i end --we live and we learn ;(
    end
    return -1
end

VectorNSM.listIterator = VectorNSM.enumerator                                       --<enumerator, vector> lua is a simple language

VectorNSM.remove = function(self, index, isObject)                                  --<any?> removes and returns elem at index
    local x;
    if isObject then
        index = self:indexOf(index)
        if index == -1 then return end
    else
        x = self[index]
    end
    for i = index, #self do
        rawset(self, i, rawget(self, i+1)) --shift left once
    end
    return x --x : any? since it doesnt return objects on :remove(Obj) only :remove(index)
end

VectorNSM.removeAll = function(self, itemArr)                                       --<bool> removes any instances of item in itemArr. returns true if anything changed
    local items = {}
    for i,v in next, itemArr do items[v] = true end --convert to hash set bc lookup is quicker
    local shift = false
    for i,v in pairs(self) do
        if items[v] then rawset(self, i, nil) end
    end
    self:trimtoSize()
    return shift
end

VectorNSM.removeAllElements = VectorNSM.clear                                       --<nil>lua has no size constraints

VectorNSM.removeElement = function(self, elem)                                      --<bool> removes element, if present. t/f if changed
    return self:remove(elem, true) ~= nil
end
VectorNSM.removeElementAt = function(self, index)                                   --<nil> removes element at index
    self:remove(index)
    return
end

VectorNSM.removeIf = function(self, callback)                                       --<bool> removes items satisfying callback(). t/f if changed
    local changed = false
    self:forEach(function(value, index, self)
        if callback(value, index, self) then
            rawset(self, index, nil)
            changed = true
        end
    end)
    self:trimToSize()
    return changed
end

VectorNSM.removeRange = function(self, startIndex, endIndex)                        --<nil> removes range [start, end) from list
    for i = startIndex, endIndex-1 do
        rawset(self, i, nil)
    end
    self:trimToSize()
    return
end

VectorNSM.replaceAll = function(self, callback)                                     --<nil> performs callback() on each item
    self:forEach(function(value, index, self)
        rawset(self, index, callback(value, index, self))
    end)
    return
end

VectorNSM.retainAll = function(self, itemArr)                                       --<bool> retains only items present in itemArr. t/f if changed
    local items = {}
    for i,v in next, itemArr do items[v] = true end

    local changed = false
    for i,v in pairs(self) do
        if not items[v] then rawset(self, i, nil) end
    end
    self:trimToSize()
    return changed
end

VectorNSM.set = function(self, index, item)                                         --<any> replaces item at index, returns old                                     --<
    local old = self[index] --will error from metamethod if invalid
    rawset(self, index, item)
    return old
end

VectorNSM.setElementAt = function(self, item, index)                                --<nil> replaces item at index... again?
    assert(self[index] ~= nil) --will error from metamethod anyways. 
    self:add(index, item)
end

VectorNSM.setSize = function(self)                                                  --<nil> lua has no size constraints
    --nothing
    return
end

VectorNSM.size = function(self)                                                     --<int> returns the num. items present
    return #self
end

VectorNSM.subList = function(self, startIndex, endIndex)                            --<Vector> returns the subset of items in [startIndex, endIndex)
    local subList = Vector.new()
    for i = startIndex, endIndex - 1 do
        sublist:add(i, self[i]) 
    end
    return subList
end

VectorNSM.toArray = function(self)                                                  --<table> returns copy of self as array
    return {unpack(self)}
end

VectorNSM.toString = function(self)                                                 --<string> stringify the data!
    local str = name.." ["
    for i,v in pairs(self) do
        str = str..tostring(v)..", "
    end
    return str:sub(1,-3).."]"
end

VectorNSM.trimToSize = function(self)                                               --<nil> relieve of the empty spaces in the list
    local len = #self
    if len == 0 then return end

    local i = 1
    for j,v in pairs(self) do   --next() skips nil entries rather than following linearly.
        if i ~= j then          --so i will 'lag' behind if the index jumps, indicating a hole
            rawset(self, i, v)  --fill the hole by swapping
            rawset(self, j, nil)
        end
        i = i + 1
    end
    return
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