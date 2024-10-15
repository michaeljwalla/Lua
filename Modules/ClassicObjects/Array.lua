--the file name will become its callback
--f&r Array to filename

--TODO: make array iterator and improve ArrayNSM.entries


local name = "Array"
local Array = {}
local ArrayNSM = {} --nonstatic object methods.

--Array references/vars/internal methods
local inf = math.huge
local remove = table.remove
local floor = math.floor
local abs = math.abs
local max, min = math.max, math.min
local quickSort = require("Modules.Sorts.QuickSort")
--compares elements lexicographically by converting to strings.
local function defaultCompare(a,b)
    a, b = tostring(a), tostring(b)
    if a < b then return -1
    elseif a > b then return 1
    end

    return 0
end


--Array constructor
Array.new = function(...)
    return setmetatable({...}, ArrayNSM)
end

--Array static methods
local function index(r,b)
    if b < 0 and b > -#r then b = b + #r+1 end --wraps around
    return r[b], b --returns value back to show what it wrapped to
end
local function defaultFromFunc(x) return x end
Array.from = function(toArray, extraFunc)
    extraFunc = extraFunc or defaultFromFunc --in case unspecified
    local list = Array.new()
    if type(toArray) == "string" then
        --toArray:gsub(".", list.push) --populate array
        for i = 1, #toArray do
            list:push( extraFunc(toArray:sub(i)) )
        end
    else
        for i,v in pairs(toArray) do
            list:push( extraFunc(v) )
        end
    end
    return list
end
Array.isArray = function(inpt)
    local pass, ans = pcall(index, inpt, "__type")
    return pass and ans == "Array"
end
Array.of = Array.new

--Array nonstatic methods

--my own methods to accomodate for lua
ArrayNSM.length = function(self) return #self end                                       --<int> length function
ArrayNSM.unpack = function(self) return unpack(self) end
--actual methods
ArrayNSM.at = function(self, indexAt)                                                   --<any> at func is just an indexing func
    local exists, value, indxRetrieved = pcall(index, self, indexAt)
    assert(exists, "Invalid index: "..tostring(indexAt))
    return value, indxRetrieved
end
ArrayNSM.concat = function(self, concatWith)                                            --<Array> concat func combines two lists
    local newArr = Array.from(self)
    for i,v in pairs(concatWith) do
        newArr:push(v)
    end
    return newArr
end
ArrayNSM.copyWithin = function(self, indxAt, startIndex, endIndex)         
    for i = startIndex, (endIndex or #self)-1 do
        self[indxAt] = self[i]
        indxAt = indxAt + 1
    end
    return self
end
ArrayNSM.entries = function(self)                                                       --<ArrayIterator> entries func returns array iterator object
    local ctr = 0
    return {
        next = function()
            ctr = ctr + 1
            return {
                value = rawget(self, ctr) and Array.new(ctr, self[ctr]) ,
                done = ctr > #self
            }
        end
    }
end
--[[
    function checker(element, index, array/self)
]]
ArrayNSM.every = function(self, callback, thisArg)                                       --<bool> every func checks if every pair passes callback(). thisArg N/A to lua
    for i,v in pairs(self) do
        if not callback(v, i, self) then return false end
    end
    return true
end
ArrayNSM.fill = function(self, value, startIndex, endIndex)                             --<Array> fill func replaces all indices in [start, end) w/ value
    for i = startIndex or 1, (endIndex or #self+1) - 1 do
        self[i] = value
    end
    return self
end
ArrayNSM.filter = function(self, callback, thisArg)                                      --<Array> filter func makes new list of pairs passing callback(). thisArg N/A to lua
    local list = Array.new()
    for i,v in pairs(self) do
        if callback(v, i, self) then
            list:push(v)
        end
    end
    return list
end
ArrayNSM.find = function(self, callback)                                                --<any> returns first value where pair passes callback()
    for i,v in pairs(self) do
        if callback(v, i, self) then return v end
    end
    return nil
end
ArrayNSM.findIndex = function(self, callback)                                           --<int> returns first index where pair passes callback()
    for i,v in pairs(self) do
        if callback(v, i, self) then return i end
    end
    return -1
end
ArrayNSM.findLast = function(self, callback)                                            --<any> ArrayNSM.find but searches backwards
    for i = #self, 1, -1 do
        if callback(self[i], i, self) then return self[i] end
    end
    return nil
end
ArrayNSM.findLastIndex = function(self, callback)                                       --<int> ArrayNSM.findIndex but searches backwards
    for i = #self, 1, -1 do
        if callback(self[i], i, self) then return i end
    end
    return -1
end
ArrayNSM.flat = function(self, depth, repl, antiCyclic)                                 --<Array> recursively unpacks nested Arrays up to depth
    depth = depth or 1
    antiCyclic = antiCyclic or {[self] = true}
    local list = Array.new()

    --
    for i,v in pairs(self) do
        if antiCyclic[v] then    --will not re-flatten a cyclic reference (stack overflow)
            list:push(repl or v) --optionally replace with another object
        elseif depth > 0 and Array.isArray(v) then                        --check if depth is maxed & arr is not cyclic
            antiCyclic[v] = true
            list:push(v:flat(depth-1, repl, antiCyclic):unpack())         --unpack array using recursive call with -1 depth
        else
            list:push(v)
        end
    end
    return list
end
ArrayNSM.flatMap = function(self, callback)                                             --<Array> literally just maps array then flattens it.
    return self:map(callback):flat()
end
ArrayNSM.forEach = function(self, callback)                                             --<nil> performs callback() on each item             
    for i,v in pairs(self) do
        callback(v, i, self)
    end
    return
end
ArrayNSM.includes = function(self, value)                                               --<bool> checks if value is present in array
    return self:indexOf(value) ~= -1
end
ArrayNSM.indexOf = function(self, value)                                                --<int> returns index of value in array, if present
    for i,v in pairs(self) do
        if v == value then return i end
    end
    return -1
end
ArrayNSM.join = function(self, separator)                                               --<string> strings together values
    local str = ""
    separator = tostring(separator ~= nil and separator or ",")

    for i,v in pairs(self) do
        str = str..tostring(v)..separator
    end
    return str:sub(1, -(1+#separator))
end
ArrayNSM.keys = function(self)
    return
end
ArrayNSM.lastIndexOf = function(self)
    return
end
ArrayNSM.map = function(self, callback)                                                 --<Array> applies callback to each pair
    local list = Array.new()
    for i,v in pairs(self) do
        list:push( callback(v,i,self) )
    end
    return list
end
ArrayNSM.pop = function(self)                                                           --<any> removes & returns last item in list
    return rawget(self, #self), remove(self, #self) --returns nil, nil / any, nil either way
end
ArrayNSM.push = function(self, ...)                                                     --<int> returns len, adds args (...) to end of list
    for i,v in next, {...} do
        rawset(self, #self+1, v)
    end
    return #self
end
ArrayNSM.reduce = function(self, callback, initialValue)                                --<any> returns result of executing callback(callback(initial, arr[0]), ...arr[n]) for each item on list
    assert(#self > 0, "Attempt to reduce empty list")
    local accum = initialValue ~= nil and initialValue or self[1]   --default 1st item
    for i,v in pairs(self) do
        accum = callback(accum, v, i, self)
    end
    return accum
end
ArrayNSM.reduceRight = function(self, callback, initialValue)                           --<any> ArrayNSM.reduce but iterates backwards
    local len = #self
    assert(len > 0, "Attempt to reduce empty list")
    local accum = initialValue ~= nil and initialValue or self[len] --default nth item
    for i = len, 1, -1 do
        accum = callback(accum, self[i], i, self)
    end
    return accum
end
ArrayNSM.reverse = function(self)                                                       --<Array> reverses original list and returns it
    local len = #self+1
    for i = 1, len/2 do
        self[i], self[len-i] = self[len-i], self[i]
    end
    return self
end
ArrayNSM.shift = function(self)                                                         --<any> returns & removes 1st elem, basically leftward pop()
    local first = rawget(self, 1)
    for i = 1, #self do
        self[i] = rawget(self, i+1)
    end
    return first
end
ArrayNSM.slice = function(self, startIndex, endIndex)                                   --<Array> returns section of list from [start, end)
    local len = #self+1--since lua starts indexes at 1...
    startIndex = (startIndex and startIndex >= -len and startIndex) or 1 --1 if startIndex == nil or startIndex < -length
    endIndex = (endIndex and endIndex < len and endIndex) or len

    
    if endIndex < -len+1 then endIndex = 1 end
    if startIndex < 0 then startIndex = len + startIndex end
    if endIndex < 0 then endIndex = len + endIndex end

    local list = Array.new()
    for i = startIndex, endIndex-1 do   --exits when end > start
        if i > len then return list end --exits when start > last index
        list:push(self[i])
    end
    return list --note: function errors when startIndex=0 bc lua starts indexes at 1
end
ArrayNSM.some = function(self, callback)                                                --<bool> returns true if at least 1 pair passes callback()
    for i,v in pairs(self) do
        if callback(v, i, self) then return true end
    end
    return false
end
ArrayNSM.sort = function(self, compareFunc)                                             --<Array> default Ascending. sorts itself, not a new arr
    quickSort(self, compareFunc or defaultCompare)
    return self
end
ArrayNSM.splice = function(self, startIndex, deleteCount, ...)
    --setup vars
    local len = #self+1
    local toAdd = {...}
    startIndex = (startIndex and startIndex >= -len and startIndex) or 1 --1 if startIndex == nil or startIndex < -length
    if startIndex < 0 then startIndex = len + startIndex end

    deleteCount = deleteCount and min(max(deleteCount, 0), len-startIndex) or 0 --always stays in bounds
    if not deleteCount then deleteCount = 0 end
    
    --delete items first (includes start)
    for i = 0, deleteCount-1 do
        rawset(self, startIndex + i, nil)
    end

    --shift original entries leftward/rightward by x spaces
    local shiftDifference = #toAdd - deleteCount
    local unshiftedIndex = startIndex - shiftDifference
    if shiftDifference < 0 then                                 --range of [1st unshifted index, end of list]
        for i = startIndex-shiftDifference, len-1 do            --for each item after gap, move left to close it
            rawset(self, i+shiftDifference, rawget(self, i))
            rawset(self, i, nil)                                --so lua can garbage collect it
        end
    elseif shiftDifference > 0 then                             --range of [1st unshifted index, end of list]
        for i = len-1, startIndex+deleteCount, -1 do            --iterate backwards since were moving stuff to right and dont wanna overwrite existing data
            rawset(self, i+shiftDifference, rawget(self, i))    --no nil rawset needed bc we know the spaces will exist.
        end
    end

    --insert given entries after
    for i,v in pairs(toAdd) do
        rawset(self, startIndex+i-1, v)
    end
    
    return self
end
ArrayNSM.toLocaleString = function(self)                                                --dont have locale functionality rn...
    return tostring(self)
end
ArrayNSM.toReversed = function(self)                                                    --<Array> clones array and reverses it
    return Array.from(self):reverse()
end
ArrayNSM.toSorted = function(self, compareFunc)                                         --<Array> clones array and sorts it
    return Array.from(self):sort(compareFunc)
end
ArrayNSM.toSpliced = function(self, startIndex, deleteCount, ...)
    return Array.from(self):splice(startIndex, deleteCount, ...)
end
ArrayNSM.toString = function(self)                                                      --<string> returns stringed form of array, flattened
    local str = ""
    for i,v in ipairs( self:flat(inf, "[Cyclic]") ) do
        str = str..tostring(v)..", "
    end --concatenation
    return "Array ["..str:sub(1,-3).."]" --clip off extra comma
end
ArrayNSM.unshift = function(self, ...)                                                  --<int> adds elems to front of array, returns new len
    local toAdd = {...}
    local numAdded = #toAdd
    --
    for i = #self, 1, -1 do
        rawset(self, i+numAdded, rawget(self, i)) --shifts rightward by n elements
    end
    for i,v in pairs(toAdd) do
        rawset(self, i, v)
    end
    return #self
end
ArrayNSM.values = function(self) --unnecessary in lua due to next(arr) -> v function.
    return nil
end
ArrayNSM.with = function(self, replIndex, replValue)                                    --<Array> clones array with one value changed                  
    local _, replIndex = self:at(replIndex) --will error if value does not exist, returns wrapped index if passed
    local list = Array.from(self)
    rawset(list, replIndex, replValue)
    return list
end
ArrayNSM.__eq = nil --default memory eq check
ArrayNSM.__lt = nil
ArrayNSM.__le = nil

ArrayNSM.__tostring = ArrayNSM.toString
ArrayNSM.compareTo = nil

--lock metatable
ArrayNSM.__type = name --not a real mt value but ig if u wanna typecheck do obj.__type == "xyz"
ArrayNSM.__tostring = ArrayNSM.__tostring or function() return name end
--jst to ensure toString exists

ArrayNSM.__index = function(self, index)
    return rawget(ArrayNSM, index) or error("Missing index/method of "..name..": "..tostring(index))
end
ArrayNSM.__newindex = function(self, index, value)
    error("Attempt to assign value to "..name.." object")
end
--
return Array