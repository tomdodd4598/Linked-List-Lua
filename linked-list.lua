do
local _ENV = _ENV
package.preload[ "helpers" ] = function( ... ) local arg = _G.arg;
local helpers = {}

local item = require "item"

function helpers.insertItem(start, val, insertBefore)
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
    local fSome = function(current, _, accumulator) return string.format("%s%s, ", accumulator, tostring(current.value)) end
    local fLast = function(current, accumulator) return string.format("%s%s\n", accumulator, tostring(current.value)) end
    local fEmpty = function(accumulator) return accumulator end
    io.write(item.fold(fSome, fLast, fEmpty, "", start))
end

function helpers.printFoldback(start)
    local fSome = function(current, _, innerVal) return string.format("%s, %s", tostring(current.value), innerVal) end
    local fLast = function(current) return string.format("%s\n", tostring(current.value)) end
    local fEmpty = function() return "" end
    io.write(item.foldback(fSome, fLast, fEmpty, function(x) return x end, start))
end

return helpers
end
end

do
local _ENV = _ENV
package.preload[ "item" ] = function( ... ) local arg = _G.arg;
local item = {}

function item:New(value, next)
    print(string.format("Creating item: %s", value))
    return setmetatable({value = value, next = next}, self)
end

function item:PrintGetNext()
    io.write(string.format("%s%s", self.value, self.next == nil and "\n" or ", "))
    return self.next
end

function item:Iterator()
    local item_ = self
    return function()
        if item_ == nil then
            return nil
        else
            local next = item_
            item_ = item_.next
            return next
        end
    end
end

function item.fold(fSome, fLast, fEmpty, accumulator, item_)
    if item_ ~= nil then
        local next = item_.next
        if next ~= nil then
            return item.fold(fSome, fLast, fEmpty, fSome(item_, next, accumulator), next)
        else
            return fLast(item_, accumulator)
        end
    else
        return fEmpty(accumulator)
    end
end

function item.foldback(fSome, fLast, fEmpty, generator, item_)
    if item_ ~= nil then
        local next = item_.next
        if next ~= nil then
            return item.foldback(fSome, fLast, fEmpty, function(innerVal) return generator(fSome(item_, next, innerVal)) end, next)
        else
            return generator(fLast(item_))
        end
    else
        return generator(fEmpty())
    end
end

local _item = {}

for k, v in pairs(item) do
    _item[k] = v
end

item.__index = function(tab, key)
    if type(key) == "number" then
        for _ = 1, key - 1 do
            tab = tab.next
        end
        return tab
    else
        return _item[key]
    end
end

return item
end
end

local helpers = require "helpers"

local VALID_REGEX = {"^0$", "^-?[1-9][0-9]*$", "^[A-Za-z][0-9A-Z_a-z]*$"}

local function isValidString(str)
    for _, regex in ipairs(VALID_REGEX) do
        if str:match(regex) ~= nil then
            return true
        end
    end
    return false
end

local function compareDigits(str, oth)
    local strLen, othLen = str:len(), oth:len()
    if strLen == 0 or othLen == 0 then
        return -1
    end

    local strChar, othChar = str:sub(1, 1), oth:sub(1, 1)
    local strMinus, othMinus = strChar == "-", othChar == "-"
    if strMinus ~= othMinus then
        return strMinus and -1 or 1
    elseif (not strMinus and (tonumber(strChar, 10) == nil or tonumber(othChar, 10) == nil)) then
        return 0
    elseif strLen > othLen then
        return strMinus and -1 or 1
    elseif strLen < othLen then
        return strMinus and 1 or -1
    end

    for i = (strMinus and 2 or 1), strLen do
        strChar = tonumber(str:sub(i, i), 10)
        othChar = tonumber(oth:sub(i, i), 10)
        if (strChar > othChar) then
            return strMinus and -1 or 1
        elseif (strChar < othChar) then
            return strMinus and 1 or -1
        end
    end

    return -1
end

local function insertBefore(val, item)
    local digitCmp = compareDigits(val, item.value)
    if digitCmp < 0 then
        return true
    elseif digitCmp > 0 then
        return false
    else
        return val <= item.value
    end
end

local function valueEquals(item, val)
    return item.value == val
end

local start = nil

local begin = true

while true do
    if not begin then
        print()
    else
        begin = false
    end

    print("Awaiting input...")
    local input = tostring(io.read())

    if input:len() == 0 then
        print("\nProgram terminated!")
        start = helpers.removeAll(start)
        return

    elseif input:sub(1, 1) == "~" then
        if input:len() == 1 then
            print("\nDeleting list...")
            start = helpers.removeAll(start)
        else
            input = input:sub(2, -1)
            if isValidString(input) then
                print("\nRemoving item...")
                start = helpers.removeItem(start, input, valueEquals)
            else
                print("\nCould not parse input!")
            end
        end

    elseif input == "l" then
        print("\nLoop print...")
        helpers.printLoop(start)

    elseif input == "i" then
        print("\nIterator print...")
        helpers.printIterator(start)

    elseif input == "a" then
        print("\nArray print...")
        helpers.printArray(start)

    elseif input == "r" then
        print("\nRecursive print...")
        helpers.printRecursive(start)

    elseif input == "f" then
        print("\nFold print...")
        helpers.printFold(start)

    elseif input == "b" then
        print("\nFoldback print...")
        helpers.printFoldback(start)

    elseif isValidString(input) then
        print("\nInserting item...")
        start = helpers.insertItem(start, input, insertBefore)

    else
        print("\nCould not parse input!")
    end
end
