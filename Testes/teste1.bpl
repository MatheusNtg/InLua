function main()
    var x[2]
    var a
    var b
begin
    foo(20,30,40)
    print(50)
end


function foo(arg1,arg2,arg3)
    var a
    var b
begin
    a = arg1 + arg2
    print(arg1)
    print(arg2)
    print(arg3)
    if a != 0 then
        print(200)
    else
        print(100)
    fi

    print(a)
end