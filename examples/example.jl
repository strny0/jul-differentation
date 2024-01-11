using Project

expr = "x + cos(x)^2"
func = simplify(parse_function(expr))
diff = simplify(differentiate(func, "x"))

format_function(func)
diff_str = format_function(diff)

open("test.dot", "w") do f
    write(f, ast_to_dot("∂f/∂x $expr =\n$diff_str", diff));
end
