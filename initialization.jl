#!/usr/bin/env julia

@info "Installing and precompiling packages"

@time begin
    using Pkg
    Pkg.activate(@__DIR__)

    if isfile("Manifest.toml")
        rm("Manifest.toml")
    end

    Pkg.instantiate()
    Pkg.precompile()

    @info "Finished"
end
