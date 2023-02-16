module Jupyter2Pluto

using JSON 
using UUIDs: uuid1
using Pluto: Cell, Notebook, save_notebook   
export jupyter2pluto

function convert_cell(cell::Dict)
    type = get(cell, "cell_type", "missing")
    source = join(get(cell, "source", ""))
    type == "code" && return Cell(source)
    type == "markdown" && return Cell("md\"\"\"\n$(source)\n\"\"\"")
    error("Unknown cell type $(type)")
end

function jupyter2pluto(input_path, output_path)
    jnb = open(JSON.parse, input_path, "r")
    cells = convert_cell.(jnb["cells"])
    pnb = Notebook(cells, output_path, uuid1())
    
    save_notebook(pnb, output_path)
    println("Pluto notebook has been saved to $(output_path).")
end
end # module
