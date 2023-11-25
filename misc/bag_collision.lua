local disable_collision = function(unit)
	for index = 0, unit:num_bodies() - 1, 1 do
		local body = unit:body(index)

		if body then
			body:set_collisions_enabled(false)
			body:set_collides_with_mover(false)
			body:set_enabled(false)
		end
	end
end

if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" then
	local AmmoBagBase = module:hook_class("AmmoBagBase")
	module:post_hook(50, AmmoBagBase, "setup", function(self, ...)
		disable_collision(self._unit)
	end)
end

if RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" then
	local DoctorBagBase = module:hook_class("DoctorBagBase")
	module:post_hook(50, DoctorBagBase, "setup", function(self, ...)
		disable_collision(self._unit)
	end)
end
