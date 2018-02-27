using Suppressor
using Base.Test


# @testset "Suppressor" begin

output = @capture_out begin
    println("should get captured, not printed")
end
@test output == "should get captured, not printed\n"

# test both with and without color
@color_output false begin
    output = @capture_err begin
        warn("should get captured, not printed")
    end
end
@test output == "WARNING: should get captured, not printed\n"

@color_output true begin
    output = @capture_err begin
        warn("should get captured, not printed")
    end
end

if VERSION >= v"0.6.0"
    @test output == "\e[1m\e[33mWARNING: \e[39m\e[22m\e[33mshould get captured, not printed\e[39m\n"
else
    @test output == "\e[1m\e[31mWARNING: should get captured, not printed\e[0m\n"
end

@test @suppress begin
    println("This string doesn't get printed!")
    warn("This warning is ignored.")
    42
end == 42

@test @suppress_out begin
    println("This string doesn't get printed!")
    warn("This warning is important")
    42
end == 42
# WARNING: This warning is important

@test @suppress_err begin
    println("This string gets printed!")
    warn("This warning is unimportant")
    42
end == 42

# This string gets printed!

@test_throws ErrorException @suppress begin
    println("This string doesn't get printed!")
    warn("This warning is ignored.")
    error("errors would normally get printed but are caught here by @test_throws")
end

# test that the macros work inside a function
function f1()
    @suppress println("should not get printed")
    42
end
@test f1() == 42

function f2()
    @suppress_out println("should not get printed")
    42
end
@test f2() == 42

function f3()
    @suppress_err println("should get printed")
    42
end
@test f3() == 42

function f4()
    @capture_out println("should not get printed")
    42
end
@test f4() == 42

function f5()
    @capture_err println("should get printed")
    42
end
@test f5() == 42

@suppress_err Suppressor.eval(:(_jl_generating_output() = true))
    
@test @capture_out(println("should get printed and return empty string")) == ""
@test @capture_err(warn("should get printed and return empty string")) == ""

# end # testset




