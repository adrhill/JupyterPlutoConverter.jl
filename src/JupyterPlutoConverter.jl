module JupyterPlutoConverter

using JSON
using UUIDs: uuid1
using Pluto: Cell, Notebook, save_notebook

export jupyter2pluto

function _convert_cell_j2p(cell::Dict, fold_md::Bool, wrap_block::Bool)
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

function jupyter2pluto(input_path, output_path; fold_md=true, wrap_block=false)
    jnb = open(JSON.parse, input_path, "r")
    cells = _convert_cell_j2p.(jnb["cells"], fold_md, wrap_block)
    pnb = Notebook(cells, output_path, uuid1())

    save_notebook(pnb, output_path)
    return println("Pluto notebook has been saved to $(output_path).")
end
end # module
