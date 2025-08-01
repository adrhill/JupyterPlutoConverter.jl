module JupyterPlutoConverter

using JSON
using UUIDs: uuid1
using Pluto: Cell, Notebook, save_notebook

export jupyter2pluto

# Jupyter notebooks are big JSON files containing "cells".
# These cells contain (among other things) a "cell_type" and "source"-content,
# which is all we need to define Pluto Cells. These are then combined into a Notebook.

# Keyword argument defaults
const DEF_FOLD_MD = true
const DEF_WRAP_BLOCK = false
const DEF_OVERWRITE = false
const DEF_VERBOSE = true
const DEF_RECURSIVE = false


const flatmap = collect ∘ Iterators.flatmap

"""
    jupyter2pluto(path)
    jupyter2pluto(path, output_path)

Convert a Jupyter notebook in `.ipynb`-format at `path` to a Pluto Notebook.
A custom output path can optionally be passed.
If `path` is a directory, `jupyter2pluto` will convert all `.ipynb` files in the directory.

# Optional arguments
- `fold_md`: If `true`, Markdown cells are folded, hiding their source. Defaults to `$DEF_FOLD_MD`.
- `wrap_block`: If `true`, code cells with multiple lines of code are wrapped
    in `begin ... end` blocks. Defaults to `$DEF_WRAP_BLOCK`.
- `overwrite`: If `true`, files at the output path will be overwritten. Defaults to `$DEF_OVERWRITE`.
- `recursive`: If `true`, applying `jupyter2pluto` to a directory will recursively look
    for `.ipynb` files in sub-directories. Defaults to `$DEF_RECURSIVE`.
- `verbose`: Toggle verbosity. Defaults to `$DEF_VERBOSE`.
- `transform_code`: Transformation applied to code strings. Defaults to `identity`.
- `transform_md`: Transformation applied to Markdown strings. Defaults to `identity`.
"""
function jupyter2pluto(
    path,
    output_path;
    fold_md::Bool=DEF_FOLD_MD,
    wrap_block::Bool=DEF_WRAP_BLOCK,
    overwrite::Bool=DEF_OVERWRITE,
    verbose::Bool=DEF_VERBOSE,
    recursive::Bool=DEF_RECURSIVE,
    transform_code::Function=identity,
    transform_md::Function=identity,
)
    !is_ipynb(path) && error_not_ipynb()
    if splitext(output_path)[2] ∈ ("", ".", ".ipynb")
        error("File extension of output_path must be .jl or something similar.")
    end
    if !overwrite && isfile(output_path)
        verbose && @warn """Skipping conversion of $path:
            A file already exists at output path $output_path.
            To overwrite files, call jupyter2pluto with the keyword argument overwrite=true."""
        return nothing
    end

    jnb = open(JSON.parse, path, "r")
    cells = flatmap(jnb["cells"]) do cell
        convert_cell(cell; fold_md, wrap_block, transform_code, transform_md)
    end
    pnb = Notebook(cells, output_path, uuid1())

    save_notebook(pnb, output_path)
    verbose && @info "Pluto notebook has been saved to $output_path."
    return nothing
end

_wrap_if_single(vs::AbstractString) = [vs]
_wrap_if_single(vs) = vs

function convert_cell(
    cell::Dict;
    fold_md::Bool,
    wrap_block::Bool,
    transform_code::Function,
    transform_md::Function,
)
    cell_type = get(cell, "cell_type", "cell_type not found")
    cell_type ∉ ("code", "markdown") && error("Unknown cell type: $cell_type")
    source = get(cell, "source", "")

    if cell_type == "code"
        code = if length(source) == 1
            only(source)
        elseif wrap_block
            join(["begin\n", source..., "end"], "    ", "\n")
        else
            join(source, "")
        end
        
        return (Cell(s) for s in _wrap_if_single(transform_code(code)))
    elseif cell_type == "markdown"
        md = if length(source) == 1
            "md\"$(only(source))\""
        else
            "md\"\"\"\n$(join(source, ""))\n\"\"\""
        end
        return (Cell(; code=s, code_folded=fold_md) for s in _wrap_if_single(transform_md(md)))
    end
end

is_ipynb(path) = isfile(path) && endswith(path, ".ipynb")
error_not_ipynb() = error("File extension of Jupyter notebook must be .ipynb.")

#===================#
# Convert directory #
#===================#

function jupyter2pluto(path; recursive=DEF_RECURSIVE, kwargs...)
    notebooks = String[]
    if isfile(path)
        !is_ipynb(path) && error_not_ipynb()
        push!(notebooks, path)
    elseif isdir(path)
        if recursive
            for (root, _dirs, files) in walkdir(path)
                paths = joinpath.(root, files)
                append!(notebooks, filter(is_ipynb, paths))
            end
        else # not recursive
            paths = readdir(path; join=true)
            append!(notebooks, filter(is_ipynb, paths))
        end
    else
        error("$path must be a Jupyter notebook or a directory.")
    end

    isempty(notebooks) && @warn("No Jupyter notebooks found in directory $path.")
    for input_path in notebooks
        output_path = replace(input_path, ".ipynb" => ".jl")
        jupyter2pluto(input_path, output_path; kwargs...)
    end
    return nothing
end
end # module
