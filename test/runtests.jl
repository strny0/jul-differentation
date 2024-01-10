using Project
using Test

@testset "Simplifier.jl" begin
    @test subtree_contains_variable(Variable("x"))
end
