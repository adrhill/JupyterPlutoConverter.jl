using JupyterPlutoConverter
using Test

function notebooks_are_equal(out_path, ref_path)
    return all(
        out == ref for (out, ref) in Iterators.zip(readlines(out_path), readlines(ref_path))
        # Ignore Pluto version comment and cell annotations as UUIDs differ
        if length(ref) < 3 || ref[1:3] ∉ ("# v", "# ╔", "# ╠", "# ╟")
    )
end

@testset "JupyterPlutoConverter.jl" begin
    ref_folder = joinpath(@__DIR__, "references")
    input_path = joinpath(ref_folder, "input.ipynb")

    # Run tests with different keyword arguments
    test_cases = Dict(
        :default => (fold_md=true, wrap_block=false),
        :wrap => (fold_md=true, wrap_block=true),
        :no_fold => (fold_md=false, wrap_block=false),
    )

    @testset "Files" begin
        for (test_name, kwargs) in test_cases
            @testset "$(test_name)" begin
                # Write Pluto notebook to a temporary file
                # that will be deleted at the end of the test
                tmp_path = joinpath(ref_folder, "_tmp_$(test_name).jl")
                ref_path = joinpath(ref_folder, "output_$(test_name).jl")
                jupyter2pluto(input_path, tmp_path; kwargs...)
                @test notebooks_are_equal(tmp_path, ref_path)
                rm(tmp_path)
            end
        end
    end
    @testset "Directories" begin
        # File that should be written:
        out_path = joinpath(@__DIR__, "references", "input.jl")
        for (test_name, kwargs) in test_cases
            @testset "$(test_name)" begin
                jupyter2pluto("."; recursive=true, kwargs...)
                @test isfile(out_path)
                ref_path = joinpath(ref_folder, "output_$(test_name).jl")
                @test notebooks_are_equal(out_path, ref_path)
                rm(out_path)
            end
        end
    end
    @testset "Error cases" begin
        @test_throws ErrorException jupyter2pluto("runtests.jl")
    end
end
