module JupyterPlutoConverter

using JSON
using UUIDs: uuid1
using Pluto: Cell, Notebook, save_notebook

export jupyter2pluto

# Jupyter notebooks are big JSON files containing "cells".
# These cells contain a "cell_type" and "source" content,
# which is all we define Pluto Cells, which are combined into a Notebook.

"""
    jupyter2pluto(input_path, output_path; kwargs...)

Convert a Jupyter notebook in `.ipynb`-format at `input_path`
to a Pluto Notebook, saving it at `output_path`.

**Note:** This currently overwrites the file at `output_path`.

# Optional arguments
- `fold_md`: If `true`, Markdown cells are folded, hiding their source.
    Defaults to `true`.
- `wrap_block`: If `true`, code cells with multiple lines of code are wrapped
    in `begin ... end` blocks. Defaults to `false`.

"""
function jupyter2pluto(input_path, output_path; fold_md=true, wrap_block=false)
    jnb = open(JSON.parse, input_path, "r")
    cells = convert_cell_j2p.(jnb["cells"], fold_md, wrap_block)
    pnb = Notebook(cells, output_path, uuid1())

    save_notebook(pnb, output_path)
    return println("Pluto notebook has been saved to $(output_path).")
end

function convert_cell_j2p(cell::Dict, fold_md::Bool, wrap_block::Bool)
    cell_type = get(cell, "cell_type", "cell_type not found")
    cell_type ∉ ("code", "markdown") && error("Unknown cell type: $(cell_type)")

    source = get(cell, "source", "")
    is_oneliner = length(source) == 1

    if cell_type == "code"
        is_oneliner && return Cell(only(source))
        wrap_block && return Cell("begin\n\t$(join(source, "\t"))\nend")
        return Cell(join(source, ""))
    elseif cell_type == "markdown"
        is_oneliner && return Cell(; code="md\"$(only(source))\"", code_folded=fold_md)
        return Cell(; code="md\"\"\"\n$(join(source, ""))\n\"\"\"", code_folded=fold_md)
    end
end
end # module
