local helpers = {}

local item = require "item"

function helpers.insertItem(start, val, insertBefore)
    print(string.format("Creating item: %s", val))
    local current, previous = start, nil

    while current ~= nil and not insertBefore(val, current) do
        previous = current
        current = current.next
    end
    local item_ = item:New(val, current)

    if previous == nil then
        start = item_
    else
        previous.next = item_
    end

    return start
end

function helpers.removeItem(start, val, valueEquals)
    local current, previous = start, nil

    while current ~= nil and not valueEquals(current, val) do
        previous = current
        current = current.next
    end

    if current == nil then
        print(string.format("Item %s does not exist!", val))
    else
        if previous == nil then
            start = current.next
        else
            previous.next = current.next
        end
        print(string.format("Removed item: %s", val))
    end

    return start
end

function helpers.removeAll(_)
    return nil
end

function helpers.printLoop(start)
    while start ~= nil do
        start = start:PrintGetNext()
    end
end

function helpers.printIterator(start)
    if start ~= nil then
        for item_ in start:Iterator() do
            item_:PrintGetNext()
        end
    end
end

function helpers.printArray(start)
    local item_ = start
    local i = 1
    while item_ ~= nil do
        item_ = start[i]:PrintGetNext()
        i = i + 1
    end
end

function helpers.printRecursive(start)
    if start ~= nil then
        helpers.printRecursive(start:PrintGetNext())
    end
end

function helpers.printFold(start)
    local fSome = function(current, _, accumulator) return string.format("%s%s, ", accumulator, current:ValueToString()) end
    local fLast = function(current, accumulator) return string.format("%s%s\n", accumulator, current:ValueToString()) end
    local fEmpty = function(accumulator) return accumulator end
    io.write(item.fold(fSome, fLast, fEmpty, "", start))
end

function helpers.printFoldback(start)
    local fSome = function(current, _, innerVal) return string.format("%s, %s", current:ValueToString(), innerVal) end
    local fLast = function(current) return string.format("%s\n", current:ValueToString()) end
    local fEmpty = function() return "" end
    io.write(item.foldback(fSome, fLast, fEmpty, function(x) return x end, start))
end

return helpers
