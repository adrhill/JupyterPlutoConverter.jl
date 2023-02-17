using JupyterPlutoConverter
using Test

@testset "JupyterPlutoConverter.jl" begin
    ref_folder = joinpath(@__DIR__, "references")
    input_path = joinpath(ref_folder, "input.ipynb")

    # Run tests with different keyword arguments
    for (test_name, kwargs) in Dict(
        :default => (fold_md=true, wrap_block=false),
        :wrap => (fold_md=true, wrap_block=true),
        :no_fold => (fold_md=false, wrap_block=false),
    )
        @testset "$(test_name)" begin
            # Write Pluto notebook to a temporary file
            # that will be deleted at the end of the test
            tmp_path = joinpath(ref_folder, "_tmp_$(test_name).jl")
            ref_path = joinpath(ref_folder, "output_$(test_name).jl")
            jupyter2pluto(input_path, tmp_path; kwargs...)
            @test all(
                out == ref
                for (out, ref) in Iterators.zip(readlines(tmp_path), readlines(ref_path))
                # Ignore Pluto version comment and cell annotations as UUIDs differ
                if length(ref) < 3 || ref[1:3] ∉ ("# v", "# ╔", "# ╠", "# ╟")
            )
            rm(tmp_path)
        end
    end
end
