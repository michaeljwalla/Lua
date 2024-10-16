--to recreate the javascript commonly used data structures, hopefully to gain a better grasp on their usesfunctionality
local module = require"Modules.ClassicObjectInit"
module.import()

local function test(msg, inpt)
    print("\t"..tostring(msg)..": "..tostring(inpt))
end
do
    local x,y,z;
    local function reset()
        x = Array.new(1,2,3,4,5)
        y = Array.from{6,7,8,9,10}
        z = Array.new("Hello", "World", "Hi", "Git", "Fox")
    end
    local function stringDict(tbl)
        local str = "{ "
        for i,v in pairs(tbl) do
            str = str .. tostring(i) .. ": " .. tostring(v) ..", "
        end
        if #str == 2 then return "{}" end --if no items in list
        return str:sub(1,-2).." }"
    end
    print("Cyclic reference detection")
    do
        local cyclicArr = Array.new(1,2)
        cyclicArr:push(cyclicArr)
        test("Array [1, 2, [1, 2, [...]]].toString() -> Array [1, 2, [Cyclic]]", cyclicArr)
    end
    print("Array Test")
    print("\nStatic function tests")
    reset()
    test("Array.new (x)",x)
    test("Array.from (y)", y)
    test("x is array", Array.isArray(x))
    test("5 is array", Array.isArray(5))
    print("\nMethod Tests")
    test("x.at(1) -> 1", x:at(1))
    test("x.length() -> 5", x:length())
    test("x.copyWithin(2,3,4) -> Array [1, 3, 3, 4, 5]", x:copyWithin(2,3,4))
    reset()
    test("y.entries().next() -> {value: Array [1, 6], done: false}", stringDict(y:entries().next()))
    test("x.every((a) => a > 5) -> false", x:every(function(a) return a > 5 end))
    test("x.every((a) => a <= 5) -> true", x:every(function(a) return a <= 5 end))
    test("y.fill('Hi', 3, 5) -> Array [6, 7, Hi, Hi, 10]", y:fill("Hi", 3, 5))
    reset()
    test("z.filter((str) => str.length > 3) -> Array [Hello, World]", z:filter(function(v) return #v > 3 end))
    test("x.find((n) => n > 2) -> 3", x:find(function(n) return n > 2 end))
    test("x.find((n) => n > 5) -> nil", x:find(function(n) return n > 5 end))
    test("y.findIndex((n) => n > 7) -> 3", y:findIndex(function(n) return n > 7 end))
    test("y.findIndex((n) => n < 6) -> -1", y:findIndex(function(n) return n < 6 end))
    test("x.findLast((n) => n > 2) -> 5", x:findLast(function(n) return n > 2 end))
    test("x.findLast((n) => n > 5) -> nil", x:findLast(function(n) return n > 5 end))
    test("y.findLastIndex((n) => n > 7) -> 5", y:findLastIndex(function(n) return n > 7 end))
    test("y.findLastIndex((n) => n < 6) -> -1", y:findLastIndex(function(n) return n < 6 end))
    --
    print("\nMethod Tests (w/ nested Arrays)")
    local a = Array.new(1,2, Array.new(3, Array.new(4, 5)))
    test(a:toString().."\n\ta.flat() -> Array [1, 2, 3, Array [4,5]]", a:flat())
    test("a.flat() -> Array [1, 2, 3, 4, 5]", a:flat(2))
    a = Array.new(1,2,1)
    test("\n\t"..a:toString().."\n\ta.flatMap((n) => (n == 2 ? [2, 2] : 1 -> Array [1, 2, 2, 1]", a:flatMap(function(n) return n == 2 and Array.new(2,2) or 1 end))
    --
    print("\nMethod Tests contd.")
    test("x.forEach((n) => console.log(n)) -> 1 / 2 / 3 / 4 / 5", "")
    x:forEach(function(n) print("\t", n) end)
    test("x.includes(1) -> true", x:includes(1))
    test("x.indexOf(1) -> 1", x:indexOf(1))
    test("x.join() -> 1,2,3,4,5", x:join())
    test("x.join(\"-\") -> 1-2-3-4-5", x:join("-"))
    test("x.pop() -> 5, Array [1, 2, 3, 4]", x:pop()..", "..x:toString())
    test("x.push(5) -> 5, Array [1, 2, 3, 4, 5]", x:push(5)..", "..x:toString())
    test("x.reduce((accum, cur) => accum * cur)) -> 120 (5 Factorial)", x:reduce(function(accum, cur) return accum * cur end))
    test("x.reduceRight((accum, cur) => accum.toString() + cur.toString()) -> \"54321\"", x:reduceRight(function(accum, cur) return accum..cur end, ""))
    test("y.reverse() -> Array [10,9,8,7,6]", y:reverse())
    test("z.shift() -> Hello, Array [World, Hi, Git, Fox]", z:shift()..", "..tostring(z))
    reset()
    test("z.slice(1, -3) -> Array [Hello, World]", z:slice(1, -3))
    test("x.some((n) => n % 2 == 0) -> true", x:some(function(n) return n % 2 == 0 end))
    --sorting
    test("[5,4,3,2,1,1260].sort() -> Array [1, 1260, 2, 3, 4, 5] (Lexicographic)",
        Array.new(5,4,3,2,1,1260):sort()
    )
    test("[5,4,3,2,1,1260].sort((a,b) => a - b) -> Array [1, 2, 3, 4, 5, 1260] (Numeric)",
        Array.new(5,4,3,2,1,1260):sort(function(a,b) return a - b end)
    )
    test("x.toSpliced(4,2, 2,1) -> Array[1, 2, 3, 2, 1]", x:toSpliced(4,2, 2,1))
    test("x.unshift(-2,-1,0) -> 8, Array [-2, -1, 0, 1, 2, 3, 4, 5]", x:unshift(-2,-1,0)..", "..tostring(x))
    reset()
    test("x.with(1,2) -> Array [2, 2, 3, 4, 5]", x:with(1,2))
    print("\nAll Array-specific functions completed.")
end

--linkedlist
do
    local x;
    local function reset()
        x = LinkedList.new(1,2,3)
    end
    print("Linked List Test")
    reset()
    test("LinkedList.new(1,2,3)", x)
    test("x.pop()", x:pop())
    test("x.push(3, 4) -> 4", x:push(3, 4))
    test("x.at(-1) -> 4", x:at(-1))
    
end