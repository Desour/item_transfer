
item_transfer.all_faces = {
	{x =  1, y =  0, z =  0},
	{x = -1, y =  0, z =  0},
	{x =  0, y =  1, z =  0},
	{x =  0, y = -1, z =  0},
	{x =  0, y =  0, z =  1},
	{x =  0, y =  0, z = -1},
}

function item_transfer.give_side(pos, node, other_pos, pt2)
	local d = vector.subtract(other_pos, pos)
	d = item_transfer.rotate_side_vector(pos, node, d, pt2)
	if vector.length(d) ~= 1 then
		return
	end
	if d.z == -1 then
		return "forward"
	elseif d.z == 1 then
		return "backward"
	elseif d.y == -1 then
		return "downward"
	elseif d.y == 1 then
		return "upward"
	elseif d.x == -1 then
		return "right"
	elseif d.x == 1 then
		return "left"
	end
end

function item_transfer.vector_rotate_right(v)
end

function item_transfer.vector_rotate_left(v)
end
--todo (these function might be found in mesecons)
function item_transfer.vector_rotate_up(v)
end

function item_transfer.vector_rotate_down(v)
end

function item_transfer.rotate_side_vector(pos, node, v, pt2)
	local param2 = node.param2

	if pt2 == "colorfacedir" then
		pt2 = "facedir"
		minetest.strip_param2_color(param2, pt2)
	elseif pt2 == "colorwallmounted" then
		pt2 = "wallmounted"
		minetest.strip_param2_color(param2, pt2)
	end

	if pt2 == "facedir" then
		local dir = minetest.facedir_to_dir(param2)
		-- todo
	elseif pt2 == "wallmounted" then
		local dir = minetest.wallmounted_to_dir(param2)
		-- todo
		--~ if dir.z == -1 then
			--~ v = item_transfer.vector_rotate_right(v)
			--~ v = item_transfer.vector_rotate_right(v)
		--~ elseif dir.x == -1 then
			--~ v = item_transfer.vector_rotate_left(v)
		--~ elseif dir.x == 1 then
			--~ v = item_transfer.vector_rotate_right(v)
		--~ elseif dir.y == -1 then
			--~ v = item_transfer.vector_rotate_up(v)
		--~ elseif dir.y == 1 then
			--~ v = item_transfer.vector_rotate_down(v)
		--~ end
	end
	return v
end

function item_transfer.rotate_side_vectors(pos, node, s, pt2)
	for i = 1, #s do
		s[i] = item_transfer.rotate_side_vector(pos, node, s[i], pt2)
	end
	return s
end

function item_transfer.get_callbacks(node_name)
	return minetest.registered_nodes[node_name]._item_transfer
end

local function give_compare_function(wanted_item, meta_match, wear_match)
	local wanted_item_name = wanted_item:get_name()
	if not meta_match and not wear_match then
		return function(item)
			return item:get_name() == wanted_item_name
		end
	elseif not wear_match then
		local wanted_item_meta = wanted_item:get_meta()
		return function(item)
			return item:get_name() == wanted_item_name and
					item:get_meta():equals(wanted_item_meta)
		end
	elseif not meta_match then
		local wanted_item_wear = wanted_item:get_wear()
		return function(item)
			return item:get_name() == wanted_item_name and
					item:get_wear() == wanted_item_wear
		end
	else
		local wanted_item_wear = wanted_item:get_wear()
		local wanted_item_meta = wanted_item:get_meta()
		return function(item)
			return item:get_name() == wanted_item_name and
					item:get_wear() == wanted_item_wear and
					item:get_meta():equals(wanted_item_meta)
		end
	end
end

function item_transfer.how_many_of_item(wanted_item, inv, listname, meta_match,
		wear_match)
	local list = inv:get_list(listname)
	local retval = 0
	local compare = give_compare_function(wanted_item, meta_match, wear_match)
	for i = 1, #list do
		if compare(list[i]:peek_item()) then
			retval = retval + list[i]:get_count()
		end
	end
	return retval
end

function item_transfer.remove_item(inv, listname, wanted_item, amount, meta_match,
		wear_match)
	local list = inv:get_list(listname)
	local retval = ItemStack()
	local retval_count = 0
	local compare = give_compare_function(wanted_item, meta_match, wear_match)
	for i = 1, #list do
		local item = list[i]
		if compare(item) then
			retval:add_item(item:take_item(amount - retval_count))
			local retval_count = retval:get_count()
			if retval_count == amount then
				break
			end
		end
	end
	inv:set_list(listname, list)
	return retval
end

function item_transfer.give_exactment_requirements(custom, exact, ...)
	if not custom then
		return true
	end
	local req = {...}
	for i = 1, #can do
		req[i] = custom[req[i]]
		if req[i] then
			exact = exact - 1
		end
	end
	return exact <= 0, unpack(req)
end

function item_transfer.simple_can_connect(paramtype2, connected_sides)
	--todo
end

function item_transfer.do_nothing()
end

function item_transfer.simple_is_connected(_, _, _, others_in, others_out, _)
	return others_in, others_out
end

function item_transfer.simple_can_insert(input_listname, return_input_invref)
	--todo
end

function item_transfer.simple_can_take(listname, is_prtotected_f)
	return function(pos, node, other_pos, wanted_item, amount, exact, custom)
		local exactness_success, meta_match, wear_match = item_transfer.
				give_exactment_requirements(custom, exact, "meta_match", "meta_wear")
		if not exactness_success then
			return false, 0
		end
		local meta = minetest.get_meta(pos)
		if is_prtotected_f and
				is_prtotected_f(pos, meta, custom and custom.taker_name) then
			return false, 0
		end
		local inv = meta:get_inventory()
		if wanted_item then
			local count = item_transfer.how_many_of_item(wanted_item, inv, listname,
					meta_match, wear_match)
			return count >= amount, count
		else
			return true
		end
	end
end

function item_transfer.simple_take(listname, is_prtotected_f)
	return function(pos, node, other_pos, wanted_item, amount, exact, custom)
		local exactness_success, meta_match, wear_match = item_transfer.
				give_exactment_requirements(custom, exact, "meta_match", "meta_wear")
		if not exactness_success then
			return
		end
		local meta = minetest.get_meta(pos)
		if is_prtotected_f and
				is_prtotected_f(pos, meta, custom and custom.taker_name) then
			return false, 0
		end
		local inv = meta:get_inventory()
		if wanted_item then
			return item_transfer.remove_item(inv, listname, wanted_item, amount,
					meta_match, wear_match) -- todo: if cycle is on, use it
		else
			-- todo
		end
	end
end

function item_transfer.after_place_node(connections, other_after_place, pt2) --todo
	return function(pos, ...)
		local node = minetest.get_node(pos)
		connections = item_transfer.rotate_side_vectors(pos, node, connections, pt2)
		for i = 1, #connections do
			local other_pos = vector.add(pos, connections[i])
			local other_node = minetest.get_node(pos)
			local it = item_transfer.get_callbacks(other_node.name)
			if it then
				local into, out, auto = can_connect(other_pos, other_node, pos, "place")
				if auto then
					it.connect(other_pos, other_node, pos, into, out, "place")
				end
			end
		end
		if other_after_place then
			return other_after_place(pos, ...)
		end
	end
end

function item_transfer.after_dig_node(connections, other_after_dig, pt2) --todo
	return function(pos, node, ...)
		connections = item_transfer.rotate_side_vectors(pos, node, connections, pt2)
		for i = 1, #connections do
			local other_pos = vector.add(pos, connections[i])
			local other_node = minetest.get_node(pos)
			local it = item_transfer.get_callbacks(other_node.name)
			if it then
				it.connect(other_pos, other_node, pos, false, false, "dug")
			end
		end
		if other_after_dig then
			return other_after_dig(pos, node, ...)
		end
	end
end
