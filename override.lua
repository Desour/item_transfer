
if minetest.get_modpath("default") then
	local furnace_def = minetest.registered_nodes["default:furnace"]
	local old_furnace_after_place_node = furnace_def.after_place_node
	local old_furnace_after_dig_node = furnace_def.after_dig_node
	minetest.override_item("default:furnace", {
		groups = {item_transfering = 1},
		_item_transfer = {
			can_connect = item_transfer.simple_can_connect("facedir", {left = true,
					right = true, back = true, front = false, bottom = true, top = true}),
			--~ can_connect = function(pos, node, other_pos, custom)
				--~ if vector.distance(pos, other_pos) ~= 1 then
					--~ return
				--~ end
				--~ local side = item_transfer.give_side(pos, node, other_pos, "facedir")
				--~ if side == "front" and custom == "tube" then
					--~ return
				--~ end
				--~ return true, true
			--~ end,
			connect = item_transfer.do_nothing,
			is_connected = item_transfer.simple_is_connected,
			--~ can_insert = item_transfer.simple_can_insert("facedir", "src"),
			can_insert = function(pos, node, other_pos, item, item_properties, custom)
				local side = item_transfer.give_side(pos, node, other_pos, "facedir")
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local listname
				if not (side == "bottom" or custom and custom.destination == "fuel") then
					listname = "src"
				else
					listname = "fuel"
				end
				local stack = inv:get_stack(listname, 1)
				if stack:is_empty() or stack:item_fits(item) then
					return true, item:get_count(), 100
				end
				return false, item:get_count() - stack:add_item(item):get_count(), 100
			end,
			insert = function(pos, node, other_pos, item, item_properties, custom)
				local side = item_transfer.give_side(pos, node, other_pos, "facedir")
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local listname
				if not (side == "bottom" or custom and custom.destination == "fuel") then
					listname = "src"
				else
					listname = "fuel"
				end
				item = inv:add_item(listname, item)
				if item:is_empty() then
					return
				end
				-- item could not be fully added, try to send back, else drop
				local other_node = minetest.get_node(other_pos)
				local it = item_transfer.get_callbacks(other_node.name)
				local visited = custom.visited
				local hashed_pos = minetest.hash_node_position(pos)
				if not visited[hashed_pos] and it.can_insert(other_pos, other_node,
						pos, item, item_properties, {overflow = true}) then
					visited[hashed_pos] = true
					it.insert(other_pos, other_node, pos, item, item_properties,
							{overflow = true, visited = table.copy(visited)})
				else
					pos.y = pos.y + 1
					minetest.add_item(pos, item)
				end
			end,
			can_take = item_transfer.simple_can_take("dst"),
			take = item_transfer.simple_take("dst"),
		},
		after_place_node = item_transfer.after_place_node(item_transfer.all_faces,
				old_furnace_after_place_node, "facedir"),
		after_dig_node = item_transfer.after_dig_node(item_transfer.all_faces,
				old_furnace_after_dig_node, "facedir"),
	})
end
