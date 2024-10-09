module Decorators

export @decorator, @decorate

"""
Macro to create a decorator function.
"""
macro decorator(decorator_func)
    return quote
        function (func)
            return (args...; kwargs...) -> begin
                $(esc(decorator_func))(func, args...; kwargs...)
            end
        end
    end
end

"""
Macro to apply decorators to a function.
"""
macro decorate(expr)
    if expr.head != :call
        error("@decorate must be applied to a function call")
    end

    decorators = expr.args[1:end-1]
    func = expr.args[end]

    if func.head == :function || (func.head == :(=) && func.args[1].head == :call)
        # This is a function definition
        func_name = func.head == :function ? func.args[1].args[1] : func.args[1].args[1]
        func_body = func.head == :function ? func.args[2] : func.args[2]

        decorated = Expr(:function, func.args[1], quote
            result = $func_body
            $(foldr((d, ex) -> :($d($ex)), decorators, init=:result))
        end)

        return esc(decorated)
    else
        # This is a function application
        return esc(foldr((d, ex) -> :($d($ex)), decorators, init=func))
    end
end

end # module
