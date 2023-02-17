# JupyterPlutoConverter.jl

[![Build Status](https://github.com/adrhill/JupyterPlutoConverter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/adrhill/JupyterPlutoConverter.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/adrhill/JupyterPlutoConverter.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/adrhill/JupyterPlutoConverter.jl)


Another Jupyter notebook to Pluto converter.

By using Pluto's `Notebook` and `Cell` structs, the core functionality of this package is implemented in around 30 lines of code. 

## Installation
This package isn't registered. To install it, open the Julia REPL and run:
```julia
julia> ]add https://github.com/adrhill/JupyterPlutoConverter.jl
```

## Getting started
This package currently supports one-way conversions from Jupyter to Pluto. A single function is exported:
```julia
using JupyterPlutoConverter

# Convert Jupyter notebooks:
jupyter2pluto("input.ipynb") # use default output filename 
jupyter2pluto("input.ipynb", "my_pluto_notebook.jl") # use custom output filename

# Convert all Jupyter notebooks in a directory:
jupyter2pluto(".") # convert all notebooks in current directory
jupyter2pluto(".", recursive=true) # recursively look through subdirectories
```

Several keyword arguments can be specified:
- `fold_md`: If true, Markdown cells are folded, hiding their source. Defaults to `true`.
- `wrap_block`: If true, code cells with multiple lines of code are wrapped in `begin ... end` blocks. Defaults to `false`.
- `overwrite`: If true, files at the specified output path will be overwritten. Defaults to `false`.
- `recursive`: If true, applying `jupyter2pluto` to a directory will recursively look for Jupyter notebooks in sub-directories. Defaults to `false`.
- `verbose`: Toggle verbosity. Defaults to `true`.

## Caveat emptor
As the [Pluto.jl ⇆ Jupyter conversion notebook](https://observablehq.com/@olivier_plas/pluto-jl-jupyter-conversion) summarizes, all automatic conversions from Jupyter to Pluto have caveats:

> Pluto is different from Jupyter in many ways - the conversion will not be perfect. Pluto has restrictions on what kind of code you can write (no multiple definitions, for example), and it can be frustrating to start out with a notebook that contains a lot of these 'reactivity errors'.
> 
> Try it out, but remember that it might be easier to start the Pluto notebook 'from scratch' and copy code cell-by-cell. Pluto is designed for a different style of writing - this will be difficult to appreciate when you start out with a Jupyter notebook.
>
> Reactivity makes this process more fun than you might think!

## Related works
- [Pluto.jl ⇆ Jupyter conversion](https://observablehq.com/@olivier_plas/pluto-jl-jupyter-conversion):
    Observable notebook by Fons. Converts both ways.
- [Jupyter2Pluto.jl](https://github.com/vdayanand/Jupyter2Pluto.jl): 
    Composes strings manually to construct Pluto notebooks. Converts both ways.