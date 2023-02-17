module JupyterPlutoConverter

using JSON
using UUIDs: uuid1
using Pluto: Cell, Notebook, save_notebook

export jupyter2pluto

# Jupyter notebooks are big JSON files containing "cells".
# These cells contain (among other things) a "cell_type" and "source"-content,
# which is all we need to define Pluto Cells. These are then combined into a Notebook.

DEF_VERBOSE = true
DEF_RECURSIVE = false

"""
    jupyter2pluto(file)
    jupyter2pluto(file, output_file)
    jupyter2pluto(dir)

Convert a Jupyter notebook `file` in `.ipynb`-format to a Pluto Notebook. A custom output filename can optionally be passed.
When applied to a directory, `jupyter2pluto` will convert all `.ipynb` files in the directory.

# Optional arguments
- `fold_md`: If `true`, Markdown cells are folded, hiding their source. Defaults to `true`.
- `wrap_block`: If `true`, code cells with multiple lines of code are wrapped
    in `begin ... end` blocks. Defaults to `false`.
- `overwrite`: If `true`, files at the output path will be overwritten. Defaults to `false`.
- `recursive`: If `true`, applying `jupyter2pluto` to a directory will recursively look
    for `.ipynb` files in sub-directories. Defaults to `$DEF_RECURSIVE`.
- `verbose`: Toggle verbosity. Defaults to `true`.
"""
function jupyter2pluto(
    file,
    output_file;
    fold_md=true,
    wrap_block=false,
    overwrite=true,
    verbose=DEF_VERBOSE,
    recursive=DEF_RECURSIVE,
)
    !is_ipynb(file) && error("File at $file is not a Jupyter notebook.")
    if !overwrite && isfile(output_file)
        verbose && println("""Skipping conversion of $file since a file already exists at output path $output_file.
            To overwrite files, call jupyter2pluto with the keyword-argument `overwrite=true`.""")
        return nothing
    end

    jnb = open(JSON.parse, file, "r")
    cells = convert_cell_j2p.(jnb["cells"], fold_md, wrap_block)
    pnb = Notebook(cells, output_file, uuid1())

    save_notebook(pnb, output_file)
    return verbose && println("Pluto notebook has been saved to $output_file.")
end

function convert_cell_j2p(cell::Dict, fold_md::Bool, wrap_block::Bool)
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

is_ipynb(path) = isfile(path) && length(path) > 6 && path[end-5:end] == ".ipynb"

#========================#
# Converting directories #
#========================#
function jupyter2pluto(path; recursive=DEF_RECURSIVE, verbose=DEF_VERBOSE, kwargs...)
    if isdir(path)
        paths = joinpath.(path, readdir(path))
        notebooks = filter(is_ipynb, paths)
        !isempty(notebooks) && jupyter2pluto.(notebooks; verbose=verbose, kwargs...)
        if recursive
            dirs = filter(isdir, paths)
            !isempty(dirs) &&
                jupyter2pluto.(dirs; recursive=recursive, verbose=verbose, kwargs...)
        end
    end
    if isfile(path)
        !is_ipynb(path) && error("File at $path is not a Jupyter notebook.")
        output_path = path[1:(end - 6)] * ".jl" # replace .ipynb with .jl
        jupyter2pluto(path, output_path; verbose=verbose, kwargs...)
    end
end
end # module
