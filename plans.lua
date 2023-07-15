#!/usr/bin/env lua5.4

local lib = require "libnabada"

local assemblies = {
	{name = "wall1r"},
	{name = "wall2r"},
	{name = "wall3r"},
	{name = "wall4r"},
	{name = "wall5r"},
	{name = "wall1l"},
	{name = "wall2l"},
	{name = "wall3l"},
	{name = "wall4l"},
	{name = "wall5l"},
	{name = "bridge_bottom"},
	{name = "bridge_top"},
	{name = "bridge_front"},
	{name = "turret_base"},
	{name = "turret_top1"},
	{name = "turret_top2"},
}

local h = assert(io.open("tmp/plans.md", "w"))

for i, a in ipairs(assemblies) do
	lib.part_bomraw(a.name, "tmp/" .. a.name .. "_bomraw.txt")
	lib.part(a.name, "tmp/" .. a.name .. ".png")
	lib.part_expl(a.name, "tmp/" .. a.name .. "_expl.png")

	local parts = lib.parts("tmp/" .. a.name .. "_bomraw.txt")

	if i > 1 then h:write("\\newpage\n\n") end

	h:write("# Komponente ", a.name, "\n\n")

	h:write("![](tmp/", a.name, ".png)", "\n")
	h:write("![](tmp/", a.name, "_expl.png)", "\n")

	h:write("\n", "## Material", "\n\n")

	for k, v in lib.opairs(parts.leiste ) do h:write(("- %3d x Leiste %.2fm\n"):format(v, k)) end
	for k, v in lib.opairs(parts.leiste_) do h:write(("- %3d x Leiste %s\n"):format(v, k)) end
	for k, v in lib.opairs(parts.stoff  ) do h:write(("- %3d x Stoff %s\n"):format(v, k)) end
	for k, v in lib.opairs(parts.stoff_ ) do h:write(("- %3d x Stoff %s (dreieckig)\n"):format(v, k)) end
	for k, v in lib.opairs(parts.platte ) do h:write(("- %3d x Platte %s\n"):format(v, k)) end
	for k, v in lib.opairs(parts.platte_) do h:write(("- %3d x Platte %s (dreieckig)\n"):format(v, k)) end

	h:write("\n")
end

h:close()

lib.mdpdf("tmp/plans.md", "out/plans.pdf")
