
function item_transfer.give_side(pos, node, other_pos)
end

function item_transfer.how_many_of_item(wanted_item, inv, listname, exact)
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
