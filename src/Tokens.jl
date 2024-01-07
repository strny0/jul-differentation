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
