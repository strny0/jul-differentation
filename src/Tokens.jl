abstract type Token end
const TokenVector = AbstractVector{Token}

struct VariableToken <: Token
    name::String
end
Base.show(io::IO, m::VariableToken) = print(io, m.name)

struct ConstantToken <: Token
    name::String
end
Base.show(io::IO, m::ConstantToken) = print(io, m.name)

struct NumberToken <: Token
    value::Float64
end
Base.show(io::IO, m::NumberToken) = print(io, m.value)

struct LeftParenToken <: Token end
Base.show(io::IO, m::LeftParenToken) = print(io, '(')

struct RightParenToken <: Token end
Base.show(io::IO, m::RightParenToken) = print(io, ')')

struct OperatorToken <: Token
    op::Char
end
Base.show(io::IO, m::OperatorToken) = print(io, m.op)

struct FunctionToken <: Token
    func::String
end
Base.show(io::IO, m::FunctionToken) = print(io, n.func)

"""
    tokenize(expr::String)::TokenVector

Tokenizes a given mathematical expression `expr` into a vector of tokens.

# Arguments
- `expr::String`: The mathematical expression to be tokenized.
# Returns
- `TokenVector`: A vector of tokens representing the parsed components of the expression.

# Token Types
- `VariableToken`: Represents variable names.
- `ConstantToken`: Represents constant names.
- `NumberToken`: Represents numerical values.
- `LeftParenToken`: Represents a left parenthesis '('.
- `RightParenToken`: Represents a right parenthesis ')'.
- `OperatorToken`: Represents an operator (+, -, *, /, ^, unary +, unary -).
- `FunctionToken`: Represents function names.

# Processing
- Numerical values, including those with decimal points and scientific notation (e.g., 1.23, 4e5), are tokenized as `NumberToken`.
- Operators are identified and tokenized as `OperatorToken`. Special handling for unary + and - is included.
- Parentheses are tokenized as `LeftParenToken` and `RightParenToken`.
- Alphabetic strings (and those with underscores or digits) are tokenized as either `VariableToken`, `ConstantToken`, or `FunctionToken` based on their matching in `supported_functions` and `constant_map`.
- The function skips unrecognized characters, including whitespace.

# Examples
```julia
tokenize("3 + x") # => [NumberToken(3.0), OperatorToken('+'), VariableToken("x")]
tokenize("sin(x)") # => [FunctionToken("sin"), LeftParenToken(), VariableToken("x"), RightParenToken()]
```
"""
function tokenize(expr::String)::TokenVector
    tokens = Token[]
    i = 1
    prev_token = nothing

    while i <= length(expr)
        c = expr[i]
        if c in "0123456789."
            start = i
            while i <= length(expr) && (expr[i] in "0123456789." || (i > start && expr[i] == 'e'))
                i += 1
            end
            push!(tokens, NumberToken(parse(Float64, expr[start:i-1])))
        elseif c in "+-"
            if isnothing(prev_token) || isa(prev_token, OperatorToken) || isa(prev_token, LeftParenToken) || isa(prev_token, FunctionToken)
                # Unary +-
                op = c == '+' ? 'p' : 'm'
                push!(tokens, OperatorToken(op))
            else
                # Binary +-
                push!(tokens, OperatorToken(c))
            end
            i += 1
        elseif c in "*/^" # Always binary operators
            push!(tokens, OperatorToken(c))
            i += 1
        elseif c == '('
            push!(tokens, LeftParenToken())
            i += 1
        elseif c == ')'
            push!(tokens, RightParenToken())
            i += 1
        elseif isletter(c) || c == '_'
            start = i
            while i <= length(expr) && (isletter(expr[i]) || isdigit(expr[i]) || expr[i] == '_')
                i += 1
            end
            token_str = expr[start:i-1]
            if token_str in supported_functions
                push!(tokens, FunctionToken(token_str))
            elseif token_str in keys(constant_map)
                push!(tokens, ConstantToken(token_str))
            else
                push!(tokens, VariableToken(token_str))
            end
        else
            i += 1 # Skip unrecognized characters (whitespace)
        end

        if !isempty(tokens)
            prev_token = tokens[end]
        end
    end

    return tokens
end
