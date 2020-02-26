local globals = require'globals'

-- Runs the program while there is a element in the stack
local function run_program()
    local stack = require'stack'
    local executions = require'executions'

    stack.push(globals.functions['main'])
    executions.execute_main()
    stack.pop()
    while stack.get_size() ~= 0 do
        local func_name = stack.pop().name
        executions.execute_function(func_name)
    end  
end

local function open_program()
    local utils = require'utils'
    -- Get the name of the filename passed as parameter in the command line
    local filename = arg[1]
    if not filename then
        print("Usage: lua interpretador.lua <prog.bpl>")
        os.exit(1)
    end

    -- Try to open the filename passed as parameter
    local file = io.open(filename, "r")
    if not file then
        print(string.format("[ERRO] Cannot open file %q", filename))
        os.exit(1)
    end

    -- Read all lines and put every line of the program in the program_table
    local num_line = 1
    for lines in file:lines() do
        globals.program_table[num_line] = lines
        num_line = num_line + 1
    end

    -- Reconize all functions in the program
    utils.recognize_functions(globals.program_table)

    run_program()
end

open_program()
