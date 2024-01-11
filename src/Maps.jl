constant_map = Dict(
    "π" => 3.141592653589793,
    "pi" => 3.141592653589793,
    "e" => 2.718281828459045,
)
supported_constants = keys(constant_map)

operator_map = Dict(
    '+' => Base.(+),
    '-' => Base.(-),
    '*' => Base.(*),
    '/' => Base.(/),
    '^' => Base.(^),
)
supported_operators = keys(operator_map)

function_map = Dict(
    "sin" => Base.sin,
    "cos" => Base.cos,
    "ln" => Base.log,
)
supported_functions = keys(function_map)
