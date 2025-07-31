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
    ref_dir = joinpath(@__DIR__, "references")
    input_path = joinpath(ref_dir, "input.ipynb")

    # Run tests with different keyword arguments
    test_cases = Dict(
        :default => (),
        :wrap => (wrap_block=true,),
        :no_fold => (fold_md=false,),
        :transforms => (
            transform_code=code -> replace(code, "bar" => "qux"),
            transform_md=md -> replace(md, "x" => "y"),
        ),
        :split_cells => (
            # Test multiple strings: duplicate the foo cell, remove the qux cell
            transform_code=code -> occursin("foo", code) ? [code, code] : [],
        ),
    )

    @testset "Files" begin
        for (test_name, kwargs) in test_cases
            # These tests write a Pluto notebook to a temporary file
            # that will be deleted at the end of the test
            @testset "$(test_name)" begin

                # Default output path
                @test_logs (:info,) jupyter2pluto(input_path; kwargs...)
                default_output_path = replace(input_path, ".ipynb" => ".jl")
                ref_path = joinpath(ref_dir, "output_$(test_name).jl")
                @test notebooks_are_equal(default_output_path, ref_path)
                rm(default_output_path)

                # Specify output path
                tmp_path = joinpath(ref_dir, "tmp_$(test_name).jl")
                @test_logs (:info,) jupyter2pluto(input_path, tmp_path; kwargs...)
                @test notebooks_are_equal(tmp_path, ref_path)
                rm(tmp_path)
            end
        end
    end
    @testset "Overwrite protection" begin
        output_path = joinpath(ref_dir, "dummy_file.jl")
        file_content = "Lorem ipsum"
        open(output_path, "w") do io
            write(io, file_content)
        end
        # These two calls will run into overwrite protection:
        @test_logs (:warn,) jupyter2pluto(input_path, output_path; overwrite=false)
        @test only(readlines(output_path)) == file_content
        @test_logs (:warn,) jupyter2pluto(input_path, output_path) # overwrite=false is default
        @test only(readlines(output_path)) == file_content
        # # This will overwrite the file:
        @test_logs (:info,) jupyter2pluto(input_path, output_path; overwrite=true)
        @test notebooks_are_equal(output_path, joinpath(ref_dir, "output_default.jl"))
        rm(output_path)
    end
    @testset "Directories" begin
        # File that should be written:
        output_path = joinpath(@__DIR__, "references", "input.jl")
        @testset "Recursive" begin
            for (test_name, kwargs) in test_cases
                @testset "$test_name" begin
                    @test_logs (:info,) jupyter2pluto("."; recursive=true, kwargs...)
                    @test isfile(output_path)
                    ref_path = joinpath(ref_dir, "output_$(test_name).jl")
                    @test notebooks_are_equal(output_path, ref_path)
                    rm(output_path)
                end
            end
        end
        @testset "Non-recursive" begin
            @test_logs (:warn,) jupyter2pluto("."; recursive=false)
            @test !isfile(output_path)
            # If something went wrong and file got created, delete it
            isfile(output_path) && rm(output_path)
        end
        @testset "Empty dir" begin
            @test_logs (:warn,) jupyter2pluto(
                joinpath(ref_dir, "empty_dir"); recursive=false
            )
        end
    end

    @testset "Error cases" begin
        @test_throws ErrorException jupyter2pluto("runtests.jl") # not .ipynb
        @test_throws ErrorException jupyter2pluto("foo.ipynb") # doesn't exist
    end
end
