
item_transfer.all_faces = {
	{x =  1, y =  0, z =  0},
	{x = -1, y =  0, z =  0},
	{x =  0, y =  1, z =  0},
	{x =  0, y = -1, z =  0},
	{x =  0, y =  0, z =  1},
	{x =  0, y =  0, z = -1},
}

function item_transfer.give_side(pos, node, other_pos) -- todo
end

function item_transfer.turn_sides(pos, node, s)
	return s -- todo
end

function item_transfer.get_callbacks(node_name)
	return minetest.registered_nodes[node_name]._item_transfer
end

function item_transfer.how_many_of_item(wanted_item, inv, listname, exact) -- todo
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

function item_transfer.after_place_node(connections, other_after_place)
	return function(pos, ...)
		local node = minetest.get_node(pos)
		connections = item_transfer.turn_sides(pos, node, connections)
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

function item_transfer.after_dig_node(connections, other_after_dig)
	return function(pos, node, ...)
		connections = item_transfer.turn_sides(pos, node, connections)
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
