local mod = {}
local globals = require'globals'


function mod.get_var(function_name, var_name)
    local position = tonumber(string.match(var_name,"%[(%d+)%]"))
    if position == nil then
        return globals.functions[function_name][var_name]
    else
        var_name = string.match(var_name,"(%a+)")
        return globals.functions[function_name][var_name][position]
    end
end

function mod.get_args(line)
    local arg1 = string.match(line,"%a+%((%w*%[?%d*%]?),?%w*%[?%d*%]?,?%w*%[?%d*%]?%)")
    local arg2 = string.match(line,"%a+%(%w*%[?%d*%]?,?(%w*%[?%d*%]?),?%w*%[?%d*%]?%)")
    local arg3 = string.match(line,"%a+%(%w*%[?%d*%]?,?%w*%[?%d*%]?,?(%w*%[?%d*%]?)%)")
    if arg1 == "" then
        arg1,arg2,arg3 = nil
    elseif arg2 == "" then
        arg2,arg3 = nil
    elseif arg3 == "" then
        arg3 = nil
    end 
    return arg1,arg2,arg3
end

function mod.declare_vars(function_name, line)
    --debug_table(functions)
    while not string.match(line,"^%s*begin%s*$") do
        local var_name = string.match(line, "%s*var%s+(%a+)") 
        local size = string.match(line, "%s*var%s+%a+%[(%d+)%]")
        if size == nil and var_name ~= nil then
            globals.functions[function_name][var_name] = 0
        elseif size ~= nil and var_name ~= nil then 
            globals.functions[function_name][var_name] = {}
            local temp = 1
            -- All positions of the array will be zero
            while temp ~= tonumber(size) + 1 do
                globals.functions[function_name][var_name][temp] = 0
                temp = temp + 1
            end
        end
        globals.current_line = globals.current_line + 1
        line = globals.program_table[globals.current_line]
    end
end


function mod.recognize_functions(program)
    local utils = require'utils'
    -- This for put the name and the line where the function begins in the functions table
    for k,v in pairs(program) do
        local name = string.match(v, "function (%w+)")
        
        if name then
            globals.functions[name] = {}
            -- This represents the header of the function
            globals.functions[name].function_header = k

            -- Get the line number where function start and ends
            local line_begin = k + 1
            while not string.match(globals.program_table[line_begin],"begin") do
                line_begin = line_begin + 1
            end

            local line_end = line_begin
            while not string.match(globals.program_table[line_end],"end") do
                line_end = line_end + 1
            end

            -- Put that information in a table of respective function,
            globals.functions[name]['name'] = name
            globals.functions[name].function_begin = line_begin
            globals.functions[name].function_end = line_end

            local arg1, arg2, arg3 = utils.get_args(v)

            if arg1 ~= nil then
                globals.functions[name][arg1] = 0
            end
            if arg2 ~= nil then
                globals.functions[name][arg2] = 0
            end
            if arg3 ~= nil then
                globals.functions[name][arg3] = 0
            end
        end 
    end
    
end

function mod.separator(line_number)
    if line_number > #globals.program_table then 
        return 0
    end
    
    if string.match(globals.program_table[line_number], "%a+%[?%d*%]?%s+=%s+.+") then
        return 1
    elseif string.match(globals.program_table[line_number], "^%s*(print%(.+%))%s*$") then
        return 2
    elseif string.match(globals.program_table[line_number], "^%s*(if%s+.+%s+.+%s+.+%s+then)%s*$") then
        return 3 
    elseif string.match(globals.program_table[line_number], "^%s*(else)%s*$") then
        return 4
    elseif string.match(globals.program_table[line_number], "^%s*%w+%(.*%)%s*$") then
        return 5
    end

end

function mod.is_number(value)
    if string.match(value, "^%d+") then
        return true
    else
        return false
    end
end

function mod.get_key_from_table(table, value)
    for key, val in pairs(table) do
        if val == value then
            return key
        end
    end

    return nil
end

function mod.get_function_id(func_name)
    local i = 1
    while globals.functions[i].name ~= func_name do
        i = i + 1
    end
    return i
end

return mod