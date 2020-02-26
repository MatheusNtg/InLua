local mod = {}

function mod.resolve_logical_exp(logical_expression)

    local utils = require'utils'
    local stack = require'stack'

    local left_op, logical_op, right_op = string.match(logical_expression, "(%w+%[?%d*%]?)%s+([>=!<]+)%s+(%w+%[?%d*%]?)")
    if not utils.is_number(left_op) then
        left_op = utils.get_var(stack.get().name, left_op)
    end

    if not utils.is_number(right_op) then
        right_op = utils.get_var(stack.get().name, right_op)
    end

    left_op = tonumber(left_op)
    right_op = tonumber(right_op)

    if logical_op == '==' and left_op == right_op then
        return true
    elseif logical_op == '==' and left_op ~= right_op then
        return false
    elseif logical_op == '>' and left_op > right_op then
        return true
    elseif logical_op == '>' and left_op <= right_op then
        return false
    elseif logical_op == '<' and left_op < right_op then
        return true
    elseif logical_op == '<' and left_op >= right_op then
        return false
    elseif logical_op == '>=' and left_op >= right_op then
        return true
    elseif logical_op == '>=' and left_op < right_op then
        return false
    elseif logical_op == '<=' and left_op <= right_op then
        return true
    elseif logical_op == '<=' and left_op > right_op then
        return false
    elseif logical_op == '!=' and left_op ~= right_op then
        return true
    elseif logical_op == '!=' and left_op == right_op then
        return false
    end
end

function mod.resolve_expression(expression)
    local utils = require'utils'
    local stack = require'stack'

    local left_value,operator,right_value = string.match(expression, "(%w*%[?%d*%]?)%s*([+-/*]?)%s*(%w*%[?%d*%]?)%s*")

    if not utils.is_number(left_value) then
        left_value = utils.get_var(stack[#stack].name, left_value)
    end

    if not utils.is_number(right_value) then
        right_value = utils.get_var(stack[#stack].name, right_value)
    end

    left_value = tonumber(left_value)
    right_value= tonumber(right_value)

    if operator == '+' then
        return left_value + right_value
    elseif operator == '-' then
        return left_value - right_value
    elseif operator == '*' then
        return left_value * right_value
    elseif operator == '/' then
        return left_value / right_value
    elseif operator == nil or operator == '' then
        return left_value
    end

end



return mod