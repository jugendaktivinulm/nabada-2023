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


local function to_m(n)
	return math.floor(tonumber(n) / 10 + 0.5) / 100;
end

local function to_a(n)
	return math.floor(tonumber(n) / 5 + 0.5) * 5;
end

local parts  = {Leiste = {}, ["Leiste schräg"] = {}, Platte = {}, ["Platte dreieckig"] = {}, Stoff = {}, ["Stoff dreieckig"] = {}}
local totals = {Leiste = 0, Platte = 0, Stoff = 0}

local cmd = [[
openscad -o - --export-format echo main.scad \
	| tr -d '"' \
	| grep '^ECHO: BOM' \
	| sed 's/^ECHO: BOM, //g'
]]
local h = io.popen(cmd, "r")

for l in h:lines("l") do

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
		parts["Leiste schräg"][k] = (parts["Leiste schräg"][k] or 0) + 1
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
		parts["Platte dreieckig"][k] = (parts["Platte dreieckig"][k] or 0) + 1
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
		parts["Stoff dreieckig"][k] = (parts["Stoff dreieckig"][k] or 0) + 1
		totals.Stoff = totals.Stoff + x*y/2

	else
		print("Could not match: " .. l)

	end

end

print("Leisten:")
for k, v in opairs(parts.Leiste) do print((" %3d x %.2fm"):format(v, k)) end
for k, v in opairs(parts["Leiste schräg"]) do print((" %3d x %s"):format(v, k)) end
print(("Summe: %.2fm"):format(totals.Leiste))
print(("Gewicht: ~%.2fkg"):format(totals.Leiste / 2)) -- https://www.bauhaus.info/latten-rahmen/holzlatte/p/14416236 | https://www.bauhaus.info/latten-rahmen/rahmenholz/p/14415220
print(("Preis: %.2f€"):format(totals.Leiste / 5 * 8.9))

print("\nStoff:")
for k, v in opairs(parts.Stoff) do print((" %3d x %s"):format(v, k)) end
for k, v in opairs(parts["Stoff dreieckig"]) do print((" %3d x %s (dreieckig)"):format(v, k)) end

print(("Summe: %.2fm²"):format(totals.Stoff))
print(("Preis: %.2f€"):format(totals.Stoff * 5))

print("\nPlatten:")
for k, v in opairs(parts.Platte) do print((" %3d x %s"):format(v, k)) end
for k, v in opairs(parts["Platte dreieckig"]) do print((" %3d x %s (dreieckig)"):format(v, k)) end

print(("Summe: %.2fm²"):format(totals.Platte))
print(("Gewicht: ~%.2fkg"):format(3.6 / (0.6*1.2) * totals.Platte)) -- https://www.bauhaus.info/mdf-platten-spanplatten/rohspanplatte-fixmass/p/22594899
print(("Preis: %.2f€"):format(totals.Platte * 6.9))

print("\nGesamt:")
print(("Gewicht: ~%.2fkg"):format(totals.Leiste / 2 + 3.6 / (0.6*1.2) * totals.Platte))
print(("Preis: %.2f€"):format(totals.Leiste / 5 * 8.9 + totals.Stoff * 5 + totals.Platte * 6.9))
