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
"""
function jupyter2pluto(
    path,
    output_path;
    fold_md=DEF_FOLD_MD,
    wrap_block=DEF_WRAP_BLOCK,
    overwrite=DEF_OVERWRITE,
    verbose=DEF_VERBOSE,
    recursive=DEF_RECURSIVE,
)
    !is_ipynb(path) && error_not_ipynb(path)
    if !overwrite && isfile(output_path)
        verbose && @warn """Skipping conversion of $path:
            A file already exists at output path $output_path.
            To overwrite files, call jupyter2pluto with the keyword argument overwrite=true."""
        return nothing
    end

    jnb = open(JSON.parse, path, "r")
    cells = convert_cell.(jnb["cells"], fold_md, wrap_block)
    pnb = Notebook(cells, output_path, uuid1())

    save_notebook(pnb, output_path)
    return verbose && @info "Pluto notebook has been saved to $output_path."
end

function convert_cell(cell::Dict, fold_md::Bool, wrap_block::Bool)
    cell_type = get(cell, "cell_type", "cell_type not found")
    cell_type ∉ ("code", "markdown") && error("Unknown cell type: $cell_type")
    source = get(cell, "source", "")
    is_oneliner = length(source) == 1

    if cell_type == "code"
        is_oneliner && return Cell(only(source))
        wrap_block && return Cell(join(["begin\n", source...], "    ") * "\nend")
        return Cell(join(source, ""))
    elseif cell_type == "markdown"
        is_oneliner && return Cell(; code="md\"$(only(source))\"", code_folded=fold_md)
        return Cell(; code="md\"\"\"\n$(join(source, ""))\n\"\"\"", code_folded=fold_md)
    end
end

is_ipynb(path) = isfile(path) && length(path) > 6 && path[(end - 5):end] == ".ipynb"
error_not_ipynb(path) = error("File at $path is not a Jupyter notebook.")

#========================#
# Converting directories #
#========================#
function jupyter2pluto(path; recursive=DEF_RECURSIVE, kwargs...)
    if isdir(path)
        paths = joinpath.(path, readdir(path))
        notebooks = filter(is_ipynb, paths)
        !isempty(notebooks) && jupyter2pluto.(notebooks; kwargs...)
        if recursive
            dirs = filter(isdir, paths)
            if !isempty(dirs)
                jupyter2pluto.(dirs; recursive=recursive, kwargs...)
            end
        end
    end
    if isfile(path)
        !is_ipynb(path) && error_not_ipynb(path)
        jupyter2pluto(path, default_output_path(path); kwargs...)
    end
end
function default_output_path(path) # change ".ipynb" file-ending to ".jl"
    !is_ipynb(path) && error_not_ipynb(path)
    return path[1:(end - 6)] * ".jl"
end
end # module
