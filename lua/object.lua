
local setmetatable, rawget = setmetatable, rawget

local _ENV = {}

-- simple object hierarchy system
-- objects double as metatables; construct instance by calling parent

local function genMeta(class)
	return {
		__index = class,
		__call = instance
	}
end
function instance(self, ...)
	self._meta = self._meta or genMeta(self)
	
	local object = setmetatable({}, self._meta)
	object._meta = false
	
	local init = rawget(self, "init")
	if init then
		init(object, ...)
	end
	
	return object
end

Class = setmetatable({}, {
	__call = instance
})

return _ENV

