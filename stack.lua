local stack = {}

function stack.push(element)
    stack[#stack + 1] = element
end

function stack.pop()
    return table.remove(stack)
end

function stack.get()
    return stack[#stack]
end

function stack.get_size()
    return #stack
end


return stack