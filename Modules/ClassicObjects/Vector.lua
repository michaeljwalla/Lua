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
    return self[i]
end

VectorNSM.forEach = function(self, callback)                                        --<nil> performs callback() for each pair
    for i,v in pairs(self) do callback(v, i, self) end
    return
end

VectorNSM.get = index                                                               --<any> self explanatory

VectorNSM.hashCode = function(self)
    
end

VectorNSM.indexOf = function(self)

end

VectorNSM.insertElementAt = function(self)

end

VectorNSM.isEmpty = function(self)

end

VectorNSM.lastElement = function(self)

end

VectorNSM.lastIndexOf = function(self)

end

VectorNSM.listIterator = function(self)

end

VectorNSM.remove = function(self)

end

VectorNSM.removeAll = function(self)

end

VectorNSM.removeAllElements = function(self)

end

VectorNSM.removeElement = function(self)

end

VectorNSM.removeIf = function(self)

end

VectorNSM.removeRange = function(self)

end

VectorNSM.replaceAll = function(self)

end

VectorNSM.retainAll = function(self)

end

VectorNSM.set = function(self)

end

VectorNSM.setElementAt = function(self)

end

VectorNSM.setSize = function(self)

end

VectorNSM.size = function(self)
    return #self
end

VectorNSM.sort = function(self)

end

VectorNSM.subList = function(self)

end

VectorNSM.toArray = function(self)

end

VectorNSM.toString = function(self)
    local str = name.." ["
    for i,v in next, self do
        str = str..tostring(v)..", "
    end
    return str:sub(1,-3).."]"
end

VectorNSM.trimToSize = function(self)

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