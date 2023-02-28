# JupyterPlutoConverter.jl
[![Build Status][ci-url]][ci-badge]
[![Coverage][cov-url]][cov-badge]

Another Jupyter notebook to [Pluto][pluto-url] converter.

By using Pluto's `Notebook` and `Cell` structs, the core functionality of this package
is implemented in around 30 lines of code.

## Installation
To install this package, open the Julia REPL and run:
```julia
julia> ]add JupyterPlutoConverter
```

## Getting started
This package currently supports one-way conversions from Jupyter to Pluto.
A single function `jupyter2pluto` is exported:
```julia
using JupyterPlutoConverter

# Convert notebook:
jupyter2pluto("notebook.ipynb") # use default output filename "notebook.jl"
jupyter2pluto("notebook.ipynb", "my_pluto_notebook.jl") # use custom output filename

# Convert directory:
jupyter2pluto(".") # convert all Jupyter notebooks in current directory
jupyter2pluto(".", recursive=true) # recursively look through subdirectories
```

The following keyword arguments can be specified:

| Name         | Default | Description                                                                                                      |
|:-------------|:--------|:-----------------------------------------------------------------------------------------------------------------|
| `fold_md`    | `true`  | If true, Markdown cells are folded, hiding their source.                                                         |
| `wrap_block` | `false` | If true, code cells with multiple lines of code are wrapped in `begin ... end` blocks.                           |
| `overwrite`  | `false` | If true, files at the specified output path will be overwritten.                                                 |
| `recursive`  | `false` | If true, applying `jupyter2pluto` to a directory will recursively look for Jupyter notebooks in sub-directories. |
| `verbose`    | `true`  | Toggle verbosity.                                                                                                |

## Caveats
As the [Pluto.jl ⇆ Jupyter conversion notebook][obs-conv-url] summarizes,
all automatic conversions from Jupyter to Pluto have caveats:

> Pluto is different from Jupyter in many ways - the conversion will not be perfect.
> Pluto has restrictions on what kind of code you can write (no multiple definitions, for example),
> and it can be frustrating to start out with a notebook that contains a lot of these 'reactivity errors'.
>
> Try it out, but remember that it might be easier to start the Pluto notebook 'from scratch' and copy code cell-by-cell.
> Pluto is designed for a different style of writing - this will be difficult to appreciate when you start out with a Jupyter notebook.
>
> Reactivity makes this process more fun than you might think!

## Related works
- [Pluto.jl ⇆ Jupyter conversion][obs-conv-url]:
    Observable notebook by Fons. Converts both ways.
- [Jupyter2Pluto.jl][j2p-conv-url]:
    Composes strings manually to construct Pluto notebooks. Converts both ways.


[ci-url]: https://github.com/adrhill/JupyterPlutoConverter.jl/actions/workflows/CI.yml/badge.svg?branch=main
[ci-badge]: https://github.com/adrhill/JupyterPlutoConverter.jl/actions/workflows/CI.yml?query=branch%3Amain
[cov-url]: https://codecov.io/gh/adrhill/JupyterPlutoConverter.jl/branch/main/graph/badge.svg
[cov-badge]: https://codecov.io/gh/adrhill/JupyterPlutoConverter.jl

[pluto-url]: https://github.com/fonsp/Pluto.jl
[obs-conv-url]: https://observablehq.com/@olivier_plas/pluto-jl-jupyter-conversion
[j2p-conv-url]: https://github.com/vdayanand/Jupyter2Pluto.jl
