local lib = {}

function lib.ofn(a, b)
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

function lib.opairs(t, orderFn)
	assert(type(t) == "table")

	local ks = {}
	orderFn = orderFn or lib.ofn

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

local function to_m(n) return math.floor(tonumber(n) / 10 + 0.5) / 100 end
local function to_a(n) return math.floor(tonumber(n) /  5 + 0.5) *   5 end

function lib.bomraw(i, o)
	print("render bom for " .. i)
	local cmd = [[
		openscad -o - --export-format echo %s \
			| tr -d '"' \
			| grep '^ECHO: BOM' \
			| sed 's/^ECHO: BOM, //g' \
			> %s
	]]
	assert(os.execute(cmd:format(i, o)))
end

function lib.part_bomraw(p, o)
	print("render bom for " .. p)
	local cmd = [[
		( openscad - -o - --export-format echo \
			| tr -d '"' \
			| grep '^ECHO: BOM' \
			| sed 's/^ECHO: BOM, //g' \
			> %s \
		) <<-'EOF'
			include <assemblies.scad>;
			%s();
		EOF
	]]
	assert(os.execute(cmd:format(o, p)))
end

function lib.part(part, o)
	print("render " .. part)
	local cmd = [[
		openscad - -o %s --imgsize=1000,500 --projection=ortho --camera=-1,-1,1,0,0,0 --viewall --colorscheme=Monotone --quiet <<-'EOF'
		$vpr = [45, 0, 315];
		$label = 1;
		include <assemblies.scad>;
		%s();
		EOF
	]]
	assert(os.execute(cmd:format(o, part)))
end

function lib.part_expl(part, o)
	print("render explosion drawing for " .. part)
	local cmd = [[
		openscad - -o %s --imgsize=1000,500 --projection=ortho --camera=-1,-1,1,0,0,0 --viewall --colorscheme=Monotone --quiet <<-'EOF'
		$vpr = [45, 0, 315];
		$label = 2;
		$exploded = 1.5;
		include <assemblies.scad>;
		%s();
		EOF
	]]
	assert(os.execute(cmd:format(o, part)))
end

function lib.parts(f)
	local parts = {leiste = {}, leiste_ = {}, platte = {}, platte_ = {}, stoff = {}, stoff_ = {}}
	local totals = {leiste = 0, platte = 0, stoff = 0}

	for l in io.lines(f) do
		if l:find("^Leiste,") then
			local d = l:match("[%d.]+")
			d = to_m(d)
			parts.leiste[d] = (parts.leiste[d] or 0) + 1
			totals.leiste = totals.leiste + d

		elseif l:find("^Leiste schräg,") then
			local d, a = l:match("([%d.]+), ([%d.]+)")
			d = to_m(d)
			a = to_a(a)
			b = 90 - a
			if a < b then b, a = a, b end
			local k = ("%.2fm @ %d°/%d°"):format(d, a, b)
			parts.leiste_[k] = (parts.leiste_[k] or 0) + 1
			totals.leiste = totals.leiste + d

		elseif l:find("^Platte,") then
			local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
			x = to_m(x)
			y = to_m(y)
			if x < y then y, x = x, y end
			local k = ("%.2fm x %.2fm"):format(x, y)
			parts.platte[k] = (parts.platte[k] or 0) + 1
			totals.platte = totals.platte + x*y

		elseif l:find("^Platte dreieckig,") then
			local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
			x = to_m(x)
			y = to_m(y)
			if x < y then y, x = x, y end
			local k = ("%.2fm x %.2fm"):format(x, y)
			parts.platte_[k] = (parts.platte_[k] or 0) + 1
			totals.platte = totals.platte + x*y/2

		elseif l:find("^Stoff,") then
			local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
			x = to_m(x)
			y = to_m(y)
			if x < y then y, x = x, y end
			local k = ("%.2fm x %.2fm"):format(x, y)
			parts.stoff[k] = (parts.stoff[k] or 0) + 1
			totals.stoff = totals.stoff + x*y

		elseif l:find("^Stoff dreieckig,") then
			local x, y = l:match("%[([%d.]+), ([%d.]+)%]")
			x = to_m(x)
			y = to_m(y)
			if x < y then y, x = x, y end
			local k = ("%.2fm x %.2fm"):format(x, y)
			parts.stoff_[k] = (parts.stoff_[k] or 0) + 1
			totals.stoff = totals.stoff + x*y/2

		else
			print("Could not match: " .. l)

		end
	end

	return parts, totals
end

function lib.cut_opt(stock_len, parts)
	local l = {}
	for k, v in pairs(parts.leiste ) do l[k] = (l[k] or 0) + v end
	for k, v in pairs(parts.leiste_) do local k_ = tonumber(k:match("^[%d.]+")); l[k_] = (l[k_] or 0) + v end

	local parts_ = {}
	for k, v in lib.opairs(l) do
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

function lib.mdpdf(i, o)
	print("create pdf " .. o)

	local cmd = [[
		pandoc \
			-f markdown \
			-t pdf \
			--pdf-engine=xelatex \
			-V geometry:a4paper \
			-V geometry:margin=2cm \
			-V mainfont='Hack' \
			%s -o %s
	]]
	assert(os.execute(cmd:format(i, o)))
end

function lib.mdpdf_2up(i, o)
	print("create pdf " .. o)

	local cmd = [[
		pandoc \
			-f markdown \
			-t pdf \
			--pdf-engine=xelatex \
			-V geometry:a5paper \
			-V geometry:margin=2cm \
			-V mainfont='Hack' \
			%s \
		| pdfjam \
			--quiet \
			--paper a4paper \
			--landscape \
			--nup 2x1 \
			--frame true \
			-o %s
	]]
	assert(os.execute(cmd:format(i, o)))
end

return lib
