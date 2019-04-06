
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

function item_transfer.how_many_of_item(wanted_item, inv, listname, exact)
	local list = inv:get_list(listname)
	local retval = 0
	if not exact then
		local wanted_item_name = wanted_item:get_name()
		for i = 1, #list do
			if list[i]:peek_item():get_name() == wanted_item_name then
				retval = retval + list[i]:get_count()
			end
		end
	else
		local wanted_item_name = wanted_item:to_string()
		for i = 1, #list do
			if list[i]:peek_item():to_string() == wanted_item_name then
				retval = retval + list[i]:get_count()
			end
		end
	end
	return retval
end

function item_transfer.simple_can_connect(connected_sides)
end

function item_transfer.do_nothing()
end

function item_transfer.simple_is_connected(_, _, _, others_in, others_out, _)
	return others_in, others_out
end

function item_transfer.simple_can_take(listname, is_prtotected_f)
	return function(pos, node, other_pos, taker_name, wanted_item, exact, amount, custom)
		local meta = minetest.get_meta(pos)
		if is_prtotected_f and is_prtotected_f(pos, meta, taker_name) then
			return false, 0
		end
		local inv = meta:get_inventory()
		local can = inv:contains_item(listname, wanted_item, exact)
		local c = item_transfer.how_many_of_item(wanted_item, inv, listname, exact)
		return can, c
	end
end

function item_transfer.simple_take(listname)
	return function(pos, node, other_pos, taker_name, wanted_item, exact, amount, custom)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:remove_item(listname, wanted_item:set_count(amount))
	end
end

function item_transfer.after_place_node(connections, other_after_place, pt2)
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

function item_transfer.after_dig_node(connections, other_after_dig, pt2)
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
