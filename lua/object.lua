
local setmetatable, rawget, select = setmetatable, rawget, select

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
	
	-- constuctor
	self.init(object, ...)
	
	return object
end

Class = setmetatable({
	init = function() end
}, {
	__call = instance
})

return _ENV

