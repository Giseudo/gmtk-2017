local enemy = {}
enemy.__index = enemy

function enemy:new(behaviour)
	local o = {}

	o.behaviour = behaviour

	return setmetatable(o, enemy)
end

return setmetatable(enemy, {
	__call = enemy.new
})
