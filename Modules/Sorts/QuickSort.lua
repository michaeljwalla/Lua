--divide and conquer algo. uses defaultCompare as default(duh)

local defaultCompare = function(a,b) return a-b end

local function swap(arr, ai, bi)
    arr[ai], arr[bi] = arr[bi], arr[ai]
    return
end
local function qs_Revolve(arr, compareFunc, bLow, bHigh)
    local i = bLow
    local pivot = arr[bHigh] -- +1 since indices start at 1...
    
    for j = bLow, bHigh do
        --i increases and "pauses" when value >= pivot until next swap
        --ex 12543 i stops at indx3 when j=indx5
        --then final swap outside loop
            --12345
        if compareFunc(arr[j], pivot) < 0 then
            swap(arr, i, j)
            i = i + 1 
        end
    end
    swap(arr, i, bHigh) --puts pivot in middle
    return i --returns pivot index
end
local function quickSort(arr, compareFunc, bLow, bHigh)
    compareFunc = compareFunc or defaultCompare
    bLow, bHigh = bLow or 1, bHigh or #arr
    if bLow >= bHigh then return end --nothing to do

    local pivotIndx = qs_Revolve(arr, compareFunc, bLow, bHigh)
    --recursively sort around pivot
    quickSort(arr, compareFunc, bLow, pivotIndx-1) --left side
    quickSort(arr, compareFunc, pivotIndx+1, bHigh) --right side
    return
end

return quickSort