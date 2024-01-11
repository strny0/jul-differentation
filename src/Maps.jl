constant_map = Dict{String,Float64}(
    "π" => 3.141592653589793,
    "pi" => 3.141592653589793,
    "e" => 2.718281828459045,
)
supported_constants = keys(constant_map)

operator_map = Dict{Char,Function}(
    '+' => (+),
    '-' => (-),
    '*' => (*),
    '/' => (/),
    '^' => (^),
)
supported_operators = keys(operator_map)

function_map = Dict{String,Function}(
    "sin" => sin,
    "cos" => cos,
    "ln" => log,
)
supported_functions = keys(function_map)
