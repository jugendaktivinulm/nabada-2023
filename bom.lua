#!/usr/bin/env lua5.4

local lib = require "libnabada"

assert(os.execute("mkdir -p out tmp"))

local outdated = not os.execute("test -e tmp/bomraw.txt")
if not outdated then
	for l in io.popen("ls *.scad", "r"):lines("l") do
		if not os.execute("test tmp/bomraw.txt -nt " .. l) then
			outdated = true
			break
		end
	end
end
if outdated then lib.bomraw("main.scad", "tmp/bomraw.txt") end

local parts, totals = lib.parts("tmp/bomraw.txt")

local total_weight = 0
local total_cost   = 0
local cuts

local hbom = io.open("tmp/bom.md", "w")

-- Leisten ---------------------------------------------------------------------
do
	local weight_per_m  = 0.5  -- https://www.bauhaus.info/latten-rahmen/holzlatte/p/14416236 | https://www.bauhaus.info/latten-rahmen/rahmenholz/p/14415220
	local unit_m        = 5.0
	local cost_per_unit = 8.9
	local amt_to_buy    = 50

	cuts = lib.cut_opt(unit_m, parts)

	amt_to_buy = amt_to_buy or #cuts
	assert(amt_to_buy >= #cuts, ("%d Leisten nötig, aber nur %d bestellt"):format(#cuts, amt_to_buy))

	local weight = totals.leiste * weight_per_m ; total_weight = total_weight + weight
	local cost   = amt_to_buy    * cost_per_unit; total_cost   = total_cost   + cost

	hbom:write("# Leisten\n\n")

	for k, v in lib.opairs(parts.leiste ) do hbom:write(("- %3d x %.2fm\n"):format(v, k)) end
	for k, v in lib.opairs(parts.leiste_) do hbom:write(("- %3d x %s\n"):format(v, k)) end

	hbom:write("\n")
	hbom:write(("| Summe: %.2fm\n"):format(totals.leiste))
	hbom:write(("| Gewicht: %.2fm * 0.5kg/m = %.2fkg\n"):format(totals.leiste, weight))
	hbom:write(("| Optimale Stückelung: %d x %.2fm\n"):format(#cuts, unit_m))

	hbom:write("\n")
	hbom:write(("| Bestellung: %dst\n"):format(amt_to_buy))
	hbom:write(("| Preis: %dst x %.2f€/st = %.2f€\n"):format(amt_to_buy, cost_per_unit, cost))
	hbom:write("\\newpage")
end

-- Stoff -----------------------------------------------------------------------
do
	local cost_per_m2 = 5
	local amt_to_buy  = 40

	amt_to_buy = amt_to_buy or totals.stoff
	assert(amt_to_buy >= totals.stoff, ("%.2fm² Stoff nötig, aber nur %.2fm² bestellt"):format(totals.stoff, amt_to_buy))

	local cost = amt_to_buy * cost_per_m2; total_cost = total_cost + cost

	hbom:write("\n\n# Stoff\n\n")

	for k, v in lib.opairs(parts.stoff ) do hbom:write(("- %3d x %s\n"):format(v, k)) end
	for k, v in lib.opairs(parts.stoff_) do hbom:write(("- %3d x %s (dreieckig)\n"):format(v, k)) end

	hbom:write("\n")
	hbom:write(("| Summe: %.2fm²\n"):format(totals.stoff))

	hbom:write("\n")
	hbom:write(("| Bestellung: %.2fm²\n"):format(amt_to_buy))
	hbom:write(("| Preis: %.2fm² x %.2f€/m² = %.2f€\n"):format(amt_to_buy, cost_per_m2, cost))
	hbom:write("\\newpage")
end

-- Platten ---------------------------------------------------------------------
do
	local weight_per_m2 = 3.6 / (0.6*1.2)  -- https://www.bauhaus.info/mdf-platten-spanplatten/rohspanplatte-fixmass/p/22594899
	local cost_per_m2   = 6.9
	local amt_to_buy    = 8

	amt_to_buy = amt_to_buy or totals.platte
	assert(amt_to_buy >= totals.platte, ("%.2fm² Platte nötig, aber nur %.2fm² bestellt"):format(totals.platte, amt_to_buy))

	local weight = totals.platte * weight_per_m2; total_weight = total_weight + weight
	local cost   = amt_to_buy    * cost_per_m2  ; total_cost   = total_cost   + cost

	hbom:write("\n\n# Platten\n\n")

	for k, v in lib.opairs(parts.platte ) do hbom:write(("- %3d x %s\n"):format(v, k)) end
	for k, v in lib.opairs(parts.platte_) do hbom:write(("- %3d x %s (dreieckig)\n"):format(v, k)) end

	hbom:write("\n")
	hbom:write(("| Summe: %.2fm²\n"):format(totals.platte))
	hbom:write(("| Gewicht: %.2fm² x %.2fkg/m² = %.2fkg\n"):format(totals.platte, weight_per_m2, weight))

	hbom:write("\n")
	hbom:write(("| Bestellung: %.2fm²\n"):format(amt_to_buy))
	hbom:write(("| Preis: %.2fm² x %.2f€/m² = %.2f€\n"):format(amt_to_buy, cost_per_m2, cost))
	hbom:write("\\newpage")
end



hbom:write("\n\n# Gesamt\n\n")
hbom:write(("| Gewicht: %.2fkg\n"):format(total_weight))
hbom:write(("| Preis: %.2f€\n"):format(total_cost))

hbom:close()
lib.mdpdf("tmp/bom.md", "out/bom.pdf")



local hcut = io.open("tmp/cuts.md", "w")

for i, st in ipairs(cuts) do
	hcut:write(("# Leiste %d\n\n"):format(i))

	local lparts = {}
	for _, it in ipairs(st) do lparts[it] = (lparts[it] or 0) + 1 end
	for k, v in lib.opairs(lparts) do hcut:write(("- %d x %.2fm\n"):format(v, k)) end

	hcut:write(("\nVerschnitt: %.2fm\n"):format(st.waste))
	hcut:write("\\newpage\n\n")
end

hcut:close()
lib.mdpdf_2up("tmp/cuts.md", "out/cuts.pdf")
