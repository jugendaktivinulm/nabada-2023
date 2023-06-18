#!/usr/bin/env lua5.4

local function ofn(a, b)
	if type(a) == type(b) then
		if type(a) == "boolean" then return (a and 1 or 0) < (b and 1 or 0) end
		if type(a) == "table" then return tostring(a) < tostring(b) end
		return a < b;
	end
	if type(a) == "boolean" then return true end
	if type(b) == "boolean" then return false end
	if type(a) == "string" then return true end
	if type(b) == "string" then return false end
	if type(a) == "number" then return true end
	if type(b) == "number" then return false end
end

local function opairs(t, orderFn)
	assert(type(t) == "table")

	local ks = {}
	orderFn = orderFn or ofn

	for k, v in pairs(t) do
		ks[#ks+1] = k;
	end
	table.sort(ks, orderFn);

	local idx = 0
	local function iter(t)
		idx = idx + 1;
		if ks[idx] ~= nil then
			return ks[idx], t[ks[idx] ];
		end
	end
	return iter, t;
end



function cut_opt(stock_len, parts)
	local parts_ = {}
	for k, v in opairs(parts) do
		for i = 1, v do table.insert(parts_, k) end
	end
	table.sort(parts_, function(a, b) return a > b end)

	local ret = {}
	for _, item in ipairs(parts_) do
		local fit = false
		for _, v in ipairs(ret) do
			if v.len + item <= stock_len then
				table.insert(v, item)
				v.len = v.len + item
				fit = true
				break
			end
		end
		if not fit then
			table.insert(ret, {[1] = item, len = item})
		end
	end

	for _, v in ipairs(ret) do v.waste = stock_len - v.len end

	return ret
end



local function to_m(n)
	return math.floor(tonumber(n) / 10 + 0.5) / 100;
end

local function to_a(n)
	return math.floor(tonumber(n) / 5 + 0.5) * 5;
end



local outdated = not os.execute("test -e bomraw.txt")
if not outdated then
	for l in io.popen("ls *.scad", "r"):lines("l") do
		if not os.execute("test bomraw.txt -nt " .. l) then
			outdated = true
			break
		end
	end
end
if outdated then
	local cmd = [[
	openscad -o - --export-format echo main.scad \
		| tr -d '"' \
		| grep '^ECHO: BOM' \
		| sed 's/^ECHO: BOM, //g' \
		> bomraw.txt
	]]
	assert(os.execute(cmd))
end



local parts  = {Leiste = {}, Leiste_ = {}, Platte = {}, Platte_ = {}, Stoff = {}, Stoff_ = {}}
local totals = {Leiste = 0, Platte = 0, Stoff = 0}

for l in io.lines("bomraw.txt") do

	if l:find("^Leiste,") then
		local d = l:match("[%d.]+")
		d = to_m(d)
		parts.Leiste[d] = (parts.Leiste[d] or 0) + 1
		totals.Leiste = totals.Leiste + d


	elseif l:find("^Leiste schräg,") then
		local d, a = l:match("([%d.]+), ([%d.]+)")
		d = to_m(d)
		a = to_a(a)
		b = 90 - a
		if a < b then b, a = a, b end
		local k = ("%.2fm @ %d°/%d°"):format(d, a, b)
		parts.Leiste_[k] = (parts.Leiste_[k] or 0) + 1
		totals.Leiste = totals.Leiste + d

	elseif l:find("^Platte,") then
		local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
		x = to_m(x)
		y = to_m(y)
		if x < y then y, x = x, y end
		local k = ("%.2fm x %.2fm"):format(x, y)
		parts.Platte[k] = (parts.Platte[k] or 0) + 1
		totals.Platte = totals.Platte + x*y

	elseif l:find("^Platte dreieckig,") then
		local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
		x = to_m(x)
		y = to_m(y)
		if x < y then y, x = x, y end
		local k = ("%.2fm x %.2fm"):format(x, y)
		parts.Platte_[k] = (parts.Platte_[k] or 0) + 1
		totals.Platte = totals.Platte + x*y/2

	elseif l:find("^Stoff,") then
		local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
		x = to_m(x)
		y = to_m(y)
		if x < y then y, x = x, y end
		local k = ("%.2fm x %.2fm"):format(x, y)
		parts.Stoff[k] = (parts.Stoff[k] or 0) + 1
		totals.Stoff = totals.Stoff + x*y

	elseif l:find("^Stoff dreieckig,") then
		local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
		x = to_m(x)
		y = to_m(y)
		if x < y then y, x = x, y end
		local k = ("%.2fm x %.2fm"):format(x, y)
		parts.Stoff_[k] = (parts.Stoff_[k] or 0) + 1
		totals.Stoff = totals.Stoff + x*y/2

	else
		print("Could not match: " .. l)

	end

end



local total_weight = 0
local total_cost   = 0
local cuts

-- Leisten ---------------------------------------------------------------------
do
	local weight_per_m  = 0.5  -- https://www.bauhaus.info/latten-rahmen/holzlatte/p/14416236 | https://www.bauhaus.info/latten-rahmen/rahmenholz/p/14415220
	local unit_m        = 4.5
	local cost_per_unit = 8.9
	local amt_to_buy    = 50

	local l = {}
	for k, v in pairs(parts.Leiste ) do l[k] = (l[k] or 0) + v end
	for k, v in pairs(parts.Leiste_) do local k_ = tonumber(k:match("^[%d.]+")); l[k_] = (l[k_] or 0) + v end
	cuts = cut_opt(unit_m, l)

	amt_to_buy = amt_to_buy or #cuts
	assert(amt_to_buy >= #cuts, ("%d Leisten nötig, aber nur %d bestellt"):format(#cuts, amt_to_buy))

	local weight = totals.Leiste * weight_per_m ; total_weight = total_weight + weight
	local cost   = amt_to_buy    * cost_per_unit; total_cost   = total_cost   + cost

	print("\n\x1b[34m### Leisten ####################################################################\x1b[0m\n")

	print("Teile:")
	for k, v in opairs(parts.Leiste) do print((" - %3d x %.2fm"):format(v, k)) end
	for k, v in opairs(parts.Leiste_) do print((" - %3d x %s"):format(v, k)) end

	print()
	print(("Summe: %.2fm"):format(totals.Leiste))
	print(("Gewicht: %.2fm * 0.5kg/m = \x1b[33m%.2fkg\x1b[0m"):format(totals.Leiste, weight))
	print(("Optimale Stückelung: \x1b[35m%d\x1b[0m x %.2fm"):format(#cuts, unit_m))
	print("  (Aufstellung s.u.)")
	print()
	print(("Bestellung: \x1b[35m%dst\x1b[0m"):format(amt_to_buy))
	print(("Preis: %dst x %.2f€/st = \x1b[31m%.2f€\x1b[0m"):format(amt_to_buy, cost_per_unit, cost))
end

-- Stoff -----------------------------------------------------------------------
do
	local cost_per_m2 = 5
	local amt_to_buy  = 40

	amt_to_buy = amt_to_buy or totals.Stoff
	assert(amt_to_buy >= totals.Stoff, ("%.2fm² Stoff nötig, aber nur %.2fm² bestellt"):format(totals.Stoff, amt_to_buy))

	local cost = amt_to_buy * cost_per_m2; total_cost = total_cost + cost

	print("\n\x1b[34m### Stoff ######################################################################\x1b[0m\n")

	print("Teile:")
	for k, v in opairs(parts.Stoff) do print((" - %3d x %s"):format(v, k)) end
	for k, v in opairs(parts.Stoff_) do print((" - %3d x %s (dreieckig)"):format(v, k)) end

	print()
	print(("Summe: \x1b[35m%.2fm²\x1b[0m"):format(totals.Stoff))
	print()
	print(("Bestellung: \x1b[35m%.2fm²\x1b[0m"):format(amt_to_buy))
	print(("Preis: %.2fm² x %.2f€/m² = \x1b[31m%.2f€\x1b[0m"):format(amt_to_buy, cost_per_m2, cost))
end

-- Platten ---------------------------------------------------------------------
do
	local weight_per_m2 = 3.6 / (0.6*1.2)  -- https://www.bauhaus.info/mdf-platten-spanplatten/rohspanplatte-fixmass/p/22594899
	local cost_per_m2   = 6.9
	local amt_to_buy    = 8

	amt_to_buy = amt_to_buy or totals.Platte
	assert(amt_to_buy >= totals.Platte, ("%.2fm² Platte nötig, aber nur %.2fm² bestellt"):format(totals.Platte, amt_to_buy))

	local weight = totals.Platte * weight_per_m2; total_weight = total_weight + weight
	local cost   = amt_to_buy    * cost_per_m2  ; total_cost   = total_cost   + cost

	print("\n\x1b[34m### Platten ####################################################################\x1b[0m\n")

	print("Teile:")
	for k, v in opairs(parts.Platte) do print((" - %3d x %s"):format(v, k)) end
	for k, v in opairs(parts.Platte_) do print((" - %3d x %s (dreieckig)"):format(v, k)) end

	print()
	print(("Summe: \x1b[35m%.2fm²\x1b[0m"):format(totals.Platte))
	print(("Gewicht: %.2fm² x %.2fkg/m² = \x1b[33m%.2fkg\x1b[0m"):format(totals.Platte, weight_per_m2, weight))
	print()
	print(("Bestellung: \x1b[35m%.2fm²\x1b[0m"):format(amt_to_buy))
	print(("Preis: %.2fm² x %.2f€/m² = \x1b[31m%.2f€\x1b[0m"):format(amt_to_buy, cost_per_m2, cost))
end



print("\n\x1b[34m### Gesamt #####################################################################\x1b[0m\n")
print(("Gewicht: \x1b[33m%.2fkg\x1b[0m"):format(total_weight))
print(("Preis: \x1b[31m%.2f€\x1b[0m"):format(total_cost))


print("\n\x1b[36m### Schnittliste Leisten #######################################################\x1b[0m\n")
local waste = 0
for i, st in ipairs(cuts) do
	print(("Leiste %d: Verschnitt %.2fm"):format(i, st.waste))
	local lparts = {}
	for _, it in ipairs(st) do lparts[it] = (lparts[it] or 0) + 1 end
	for k, v in opairs(lparts) do print((" - %d x %.2fm"):format(v, k)) end
	waste = waste + st.waste
	print()
end
print(("Verschnitt gesamt: \x1b[32m%.2fm\x1b[0m"):format(waste))
