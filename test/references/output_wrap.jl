### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ a3e853de-aed0-11ed-2abb-13858edcd433
md"""
# Test Notebook
## Test Header

This notebook is used to test JupyterPlutoConverter.jl.
This is Markdown content with an equation: $x=1$
"""

# ╔═╡ a3e854a6-aed0-11ed-1d68-bde58dad1c80
foo = 1 # a simple code cell

# ╔═╡ a3e854d8-aed0-11ed-00e8-71984da71e37
md"The following code cell is used to test wrapping code in `begin ... end` blocks:"

# ╔═╡ a3e85500-aed0-11ed-0477-d1d4d742588f
begin
	# Code comment
	bar = 2
	bar *= 3
end

# ╔═╡ Cell order:
# ╟─a3e853de-aed0-11ed-2abb-13858edcd433
# ╠═a3e854a6-aed0-11ed-1d68-bde58dad1c80
# ╟─a3e854d8-aed0-11ed-00e8-71984da71e37
# ╠═a3e85500-aed0-11ed-0477-d1d4d742588f
