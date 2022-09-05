local item = {}

function item:New(value, next)
    return setmetatable({value = value, next = next}, self)
end

function item:ValueToString()
    return tostring(self.value)
end

function item:PrintGetNext()
    io.write(self:ValueToString())
    io.write(self.next == nil and "\n" or ", ")
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
