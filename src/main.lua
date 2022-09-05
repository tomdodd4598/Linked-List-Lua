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

local function insertBefore(val, oth)
    local digitCmp = compareDigits(val, oth.value)
    if digitCmp < 0 then
        return true
    elseif digitCmp > 0 then
        return false
    else
        return val <= oth.value
    end
end

local function valueEquals(item, val)
    return item.value == val
end

local start = nil

local begin = true
local input = nil

while true do
    if not begin then
        print()
    else
        begin = false
    end

    print("Awaiting input...")
    input = tostring(io.read())

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
