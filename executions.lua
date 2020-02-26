local mod = {}
local globals = require'globals'

function mod.execute_print(line)
    local utils = require'utils'
    local stack = require'stack'
    local arg = utils.get_args(line)
    local value = tonumber(arg)

    if value == nil then
        print(utils.get_var(stack[stack.get_size()].name,arg))
    else
        print(value)
    end
end

function mod.execut_if_else(line)
    local resolvers = require'resolvers'
    local utils = require'utils'

    local logical_expression = string.match(line, "if%s+(.+)%s+then%s*")
    local exp_result = resolvers.resolve_logical_exp(logical_expression)
    local line_number = utils.get_key_from_table(globals.program_table, line)
        

    if exp_result then
        mod.execute_line(line_number + 1)
    else
        mod.execute_line(line_number + 3)
    end

    globals.current_line = globals.current_line + 3
end

function mod.execute_function(line)
    local utils = require'utils'
    local stack = require'stack'
    local arg1, arg2, arg3 = utils.get_args(line)
    local func_name = string.match(line,"(%a+)%(")
    local param1,param2,param3 = utils.get_args(globals.program_table[globals.functions[func_name].function_header])
    -- Save the return line
    stack[stack.get_size()].ret_line = globals.current_line

    -- Change the pointer to the header of the function
    globals.current_line = globals.functions[func_name].function_header

    -- Putting the args as variables in the function table
    if arg1 ~= nil then
        globals.functions[func_name][param1] = arg1
    end
    if arg2 ~= nil then
        globals.functions[func_name][param2] = arg2
    end
    if arg3 ~= nil then
        globals.functions[func_name][param3] = arg3
    end
    
    stack.push(globals.functions[func_name])
    utils.declare_vars(stack[#stack].name, line)
    while not string.match(line,"^%s*end%s*$") do
        mod.execute_line(globals.current_line)
        line = globals.program_table[globals.current_line]
    end

    stack.pop()

    globals.current_line = stack[#stack].ret_line

end

function mod.execute_attr(function_name, line)
    local resolvers = require'resolvers'
    local stack     = require'stack'
    -- Extract the var name from the line
    local var_name = string.match(line, "(%a+)")
    local position = tonumber(string.match(line, "%a+%[(%d+)%]%s*="))
    local expression = string.match(line, ".+%s*=%s*(.+)")

    local exp_result = resolvers.resolve_expression(expression)
    
    if position == nil then
        stack[stack.get_size()][var_name] = exp_result
    else
        stack[stack.get_size()][var_name][position] = exp_result
    end
end

function mod.execute_line(line_number)
    local utils = require'utils'
    local stack = require'stack'
    -- Get what kind of execution the program is trying to do
    local result = utils.separator(line_number)

    if result == 0 then
        return
    elseif result == 1 then
        -- I'll put in the stack all declared variables in the function
        local func_name = stack.get().name
        mod.execute_attr(func_name, globals.program_table[line_number])
    elseif result == 2 then
        mod.execute_print(globals.program_table[line_number])
    elseif result == 3 then
        mod.execut_if_else(globals.program_table[line_number])
    elseif result == 5 then
        mod.execute_function(globals.program_table[line_number])
    end
    globals.current_line = globals.current_line + 1
end

function mod.execute_main() 
    local utils = require'utils'
    globals.current_line = globals.functions['main'].function_header
    utils.declare_vars('main',globals.program_table[globals.current_line])
    
    while globals.current_line <= globals.functions['main'].function_end do
        mod.execute_line(globals.current_line)
    end
end



return mod