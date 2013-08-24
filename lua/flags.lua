
-- command-line option parser

local argInterpret

local flag_mt = {}
local FLAG_ORDER = {} --arbitrary key

local function addFlag(parsed, flagOrder, flag, value)
	-- capture minimum position for flag arguments
	if not parsed[flag] then
		parsed[flag] = value or (#parsed + 1)
		flagOrder[#flagOrder + 1] = flag
	end
end

local function argParse(args)
	
	local parsed = setmetatable({}, flag_mt)
	local flagOrder = {}
	local literalMode = false
	
	for i = 1,#args do
		local arg = args[i]
		
		if literalMode or arg:sub(1,1) ~= "-" or arg == "-" then
			-- positional argument
			parsed[#parsed + 1] = arg
		elseif arg == "--" then
			-- end-of-options "--" marker
			literalMode = true
		else
			-- flag
			arg = arg:sub(2)
			
			if arg:sub(1,1) == "-" then
				-- long option
				arg = arg:sub(2)
				
				-- see if arg is of --flag=value form
				local name, value = arg:match("(.-)=(.*)")
				
				if name then
					addFlag(parsed, flagOrder, name, value)
				else
					addFlag(parsed, flagOrder, arg, value)
				end
			else
				-- short option cluster
				
				-- flag clusters ending in "-" make rest of options literal
				if arg:sub(-1) == "-" then
					literalMode = true
					arg = arg:sub(1,-2)
				end
				
				-- break into individual flags
				arg:gsub(".", function(flag)
					addFlag(parsed, flagOrder, flag)
				end)
			end
			
		end
	end
	
	parsed[FLAG_ORDER] = flagOrder
	
	return parsed
end

local function absorbArgument(args, startAt, flagName)
	for i = startAt,#args do
		if args[i] then
			local value = args[i]
			
			-- indicate argument was taken
			args[i] = false
			
			return value
		end
	end
	
	error("no value given for "..flagName)
end

-- function for interpreting a set of flags according to a "schema" table
flag_mt.__call = function(rawValues, schema)
	
	local result = {}
	local flagOrder = rawValues[FLAG_ORDER]
	local helpAvailable = false
	
	--TODO: expand "alias" fields in schema
	
	-- fill in flag values; some may take an argument, indicated by schema[flag].arg
	-- TODO: complain if argument appears multiple times, or handle it if "multiple" type
	for i = 1,#flagOrder do
		local flag = flagOrder[i]
		
		if schema[flag] then
			if type(rawValues[flag]) == "string" then
				-- if value given in --flag=value form, just use it
				result[flag] = rawValues[flag]
			else
				if schema[flag].arg then
					-- fetch argument
					result[flag] = absorbArgument(rawValues, rawValues[flag], flag)
				else
					result[flag] = true
				end
			end
		else
			error("Unknown flag: "..flag)
		end
	end
	
	
	-- fill in default entires for ungiven arguments
	for flag, info in pairs(schema) do
		if not result[flag] then
			result[flag] = info.default or false
		end
	end

	-- fill in positional parameters that weren't taken by flags
	for i = 1,#rawValues do
		if rawValues[i] then
			result[#result + 1] = rawValues[i]
		end
	end
	
	--TODO: auto-handle help text for --help & -h if any was given
	
	return result
end

return argParse

