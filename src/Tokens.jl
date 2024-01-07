abstract type Token end

struct ConstantToken <: Token
    name::String
end

struct LeftParenToken <: Token end

struct RightParenToken <: Token end

struct VariableToken <: Token
    name::String
end

struct NumberToken <: Token
    value::Float64
end

struct OperatorToken <: Token
    op::Char
end

struct FunctionToken <: Token
    func::String
end

function tokenize(expr::String)
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
            if prev_token == nothing || isa(prev_token, OperatorToken) || isa(prev_token, LeftParenToken) || isa(prev_token, FunctionToken)
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
