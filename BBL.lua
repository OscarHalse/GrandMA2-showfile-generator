-------------------------------------------------------------------------------------
--------------------------------- The BigBoy Library---------------------------------
-------------------------------------------------------------------------------------

-- "includes"
BBL = BBL or {}


-------------------------- DEFINES Start --------------------------
BBL.NEXT_AVAILABLE_GROUP			= "NEXT_AVAILABLE_GROUP"
BBL.NEXT_AVAILABLE_EFFECT			= "NEXT_AVAILABLE_EFFECT"
BBL.NEXT_AVAILABLE_SEQUENCE			= "NEXT_AVAILABLE_SEQUENCE"
BBL.NEXT_AVAILABLE_MACRO			= "NEXT_AVAILABLE_MACRO"
BBL.NEXT_AVAILABLE_REMOTE 			= "NEXT_AVAILABLE_REMOTE"
BBL.NEXT_AVAILABLE_REMOTE_FLIPPED 	= "NEXT_AVAILABLE_REMOTE_FLIPPED"

BBL.FIRST_AVAILABLE_GROUP 		= 101
BBL.FIRST_TEMPLATE_EFFECT 		= 1001
BBL.FIRST_SELECTIVE_EFFECT 		= 1104
BBL.FIRST_AVAILABLE_SEQUENCE	= 1001
BBL.FIRST_AVAILABLE_MACRO 		= 1001
BBL.FIRST_PRESET_DIM 			= 1
BBL.FIRST_PRESET_COLOR 			= 1
BBL.FIRST_PRESET_POS 			= 1
BBL.FIRST_PRESET_GOBO 			= 1001
BBL.FIRST_PRESET_PRISM 			= 1001
BBL.FIRST_REMOTE				= "100.1"
BBL.FIRST_REMOTE_FLIPPED		= "101.1"




BBL.ALL_GROUP 									= 1
BBL.FIRST_GROUP_TO_GENERATE_FROM 				= 2
BBL.GROUP_CONFIG_PAGE_START 					= 2
BBL.TEMPLATE_MIN_GAP 							= 3
BBL.MIN_GAP_BETWEEN_TEMPLATES_AND_SELECTIVES	= 20
BBL.PBG_FIRST_PAGE 								= 10
BBL.GROUP_L3_MASTER_PAGE						= 20



BBL.GROUP					= "GROUP"
BBL.SEQUENCE				= "SEQUENCE"
BBL.EFFECT					= "EFFECT"
BBL.MACRO					= "MACRO"
BBL.EXEC					= "EXECUTOR"
BBL.FADER_REMOTE			= "FADER REMOTE"
BBL.FADER_REMOTE_FLIPPED 	= "FADER REMOTE FLIPPED"

local RECOGNIZED_POOL_OBJECTS = {
	BBL.GROUP,
	BBL.SEQUENCE,
	BBL.EFFECT,
	BBL.MACRO,
	BBL.EXEC
}
BBL.RECOGNIZED_POOL_OBJECTS = RECOGNIZED_POOL_OBJECTS


BBL.DIM_STOMP_TEMPLATE_EFFECT		= "DIM_STOMP_TEMPLATE_EFFECT"

BBL.ALPHBABET_ARRAY					= {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}




BBL.CONFIG_GRID_BUTTON_TYPE 	= "goto"
BBL.CONFIG_GRID_SEQ_OPTIONS 	= table.concat({"/cuezero=off", 	"/cuezeroextract=off", "/forcedpos.mode=none", "/releasefirststep=on", 	"/track=off"}, " ")										-- Seq options
BBL.CONFIG_GRID_BUTTON_OPTIONS 	= table.concat({"/autostart=off", 	"/autostop=off", 		"/offtime=0", 			"/autofix=off", 		"/mastergo=off", 											-- Start
												"/priority=normal",	"/softltp=off", 		"/playbackmaster=0", 	"/wrap=on", 			"/restart=current", "/triggerisgo=off", "/cmddisable=off",	-- Playback
												"/crossfade=off", 																																-- x-fade
												"/autostop=off", 																																-- Tracking
												"/speed=Normal", 	"/speedmaster=speed_individual", 			"/ratemaster=rate_individual", 			"/effectspeed=off",						-- Speed
												"/swopprotect=on", 	"/killprotect=on", 							"/ignoreexectime=on", 					"/ooo=off", 							-- Protect
												"/mibalways=off", 	"/mibnever=off", 							"/prepos=off", 																	-- MIB
												"/chaser=off", 		"/width=1"}, " ")	

----------------------------------------------------------------------
----------------------------- PLAYBACK GRID --------------------------
----------------------------------------------------------------------

BBL.ATTRIBUTE_DIM 		= 'DIM'
BBL.ATTRIBUTE_COLOR 	= 'COLOR'
BBL.ATTRIBUTE_COLORMIX 	= 'COLORMIX'
BBL.ATTRIBUTE_MOV 		= 'MOV'
BBL.ATTRIBUTE_TILT 		= 'TILT'
BBL.ATTRIBUTE_POS 		= 'POS'
BBL.ATTRIBUTE_GOBO 		= 'GOBO'
BBL.ATTRIBUTE_PRISM 	= 'PRISM'

-- 						 COLUMN TYPE       NUM ENTRIES     	PRESET 	EFFECT
BBL.PBG_COLUMNS     = {	{BBL.ATTRIBUTE_DIM, 	5,  		true, 	true},
						{BBL.ATTRIBUTE_COLOR, 	2,  		true, 	true},
						{BBL.ATTRIBUTE_MOV, 	2,  		false, 	true},
						{BBL.ATTRIBUTE_POS, 	2,  		true, 	false},
						{BBL.ATTRIBUTE_GOBO, 	2,  		true, 	false},
						{BBL.ATTRIBUTE_PRISM, 	2,  		true, 	false}}

BBL.PBG_NUM_COLUMNS = 15

BBL.PBG_FRONTEND_BUTTON_TYPE 	= "goto"
BBL.PBG_FRONTEND_SEQ_OPTIONS 	= table.concat({"/cuezero=off", 	"/cuezeroextract=off", "/forcedpos.mode=none", "/releasefirststep=on", 	"/track=off"}, " ")										-- Seq options
BBL.PBG_FRONTEND_BUTTON_OPTIONS = table.concat({"/autostart=on", 	"/autostop=off", 		"/offtime=0", 			"/autofix=off", 		"/mastergo=off", 											-- Start
												"/priority=normal",	"/softltp=off", 		"/playbackmaster=0", 	"/wrap=on", 			"/restart=current", "/triggerisgo=off", "/cmddisable=off",	-- Playback
												"/crossfade=off", 																																-- x-fade
												"/autostop=off", 																																-- Tracking
												"/speed=Normal", 	"/speedmaster=speed_individual", 			"/ratemaster=rate_individual", 			"/effectspeed=off",						-- Speed
												"/swopprotect=on", 	"/killprotect=on", 							"/ignoreexectime=on", 					"/ooo=off", 							-- Protect
												"/mibalways=off", 	"/mibnever=off", 							"/prepos=off", 																	-- MIB
												"/chaser=off", 		"/width=1"}, " ")																											-- Function
										
BBL.PBG_BACKEND_BUTTON_TYPE 	= "go"
BBL.MULTISEQ_OPTIONS 			= table.concat({"/cuezero=off", 	"/cuezeroextract=off", 	"/forcedpos.mode=none", "/releasefirststep=on", "/track=off"}, " ")									-- Seq options. Remember that the multiseq is also the PBG backend seq
BBL.PBG_BACKEND_BUTTON_OPTIONS 	= table.concat({"/autostart=on", 	"/autostop=off", 		"/offtime=0", 			"/autofix=off", 		"/mastergo=off", 											-- Start
												"/priority=normal",	"/softltp=off", 		"/playbackmaster=0", 	"/wrap=on", 			"/restart=current", "/triggerisgo=off", "/cmddisable=off",	-- Playback
												"/crossfade=off",																																-- x-fade
												"/autostop=off", 																																-- Tracking
												"/speed=Normal", 	"/speedmaster=speed_individual", 			"/ratemaster=rate_individual", 			"/effectspeed=off", 					-- Speed
												"/swopprotect=off", "/killprotect=off", 						"/ignoreexectime=off", 					"/ooo=on", 							-- Protect
												"/mibalways=off", 	"/mibnever=off", 							"/prepos=off", 																	-- MIB
												"/chaser=off", 		"/width=1"}, " ")																											-- Function

----------------------------------------------------------------------
------------------------------- SUBGROUPS ----------------------------
----------------------------------------------------------------------

BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE = "empty"
BBL.GROUP_MASTER_STOMP_EXEC_FADER_TYPE 	= "TempFader"
BBL.GROUP_MASTER_STOMP_SEQ_OPTION 		= table.concat({"/cuezero=off", 	"/cuezeroextract=off", 	"/forcedpos.mode=none", "/releasefirststep=on", "/track=off"}, " ")									-- Seq options. 
BBL.GROUP_MASTER_STOMP_EXEC_OPTION 		= table.concat({"/autostart=on", 	"/autostop=off", 		"/offtime=0", 			"/autofix=off", 		"/mastergo=off", 											-- Start
														"/priority=ltp", 	"/softltp=off", 		"/playbackmaster=0", 	"/wrap=on", 			"/restart=current", "/triggerisgo=off", "/cmddisable=off",	-- Playback
														"/crossfade=off",																																-- x-fade
														"/autostop=off", 																																-- Tracking
														"/speed=Normal", 	"/speedmaster=speed_individual", 			"/ratemaster=rate_individual", 			"/effectspeed=off", 					-- Speed
														"/swopprotect=on", 	"/killprotect=on", 							"/ignoreexectime=on", 					"/ooo=off", 							-- Protect
														"/mibalways=off", 	"/mibnever=off", 							"/prepos=off", 																	-- MIB
														"/chaser=off", 		"/width=1"}, " ")																											-- Function



BBL.OFFSET = {
	TEMPLATE 					= 0,
	APPLIED_RIGGING_CONFIGS 	= 5,
	UNAPPLIED_RIGGING_CONFIGS 	= 10,
	APPLIED_ATTRIBUTE_CONFIGS 	= 15,
	UNAPPLIED_ATTRIBUTE_CONFIGS = 20,
	CONFIG 						= 25
}

local RIGGING_TYPES = {
	"Point sources in rows",
	"Point sources is circle",
	"Point sources in grid clusters",
	"Bars as X",
	"Bars as icicles",
	"Bars in rows",
	"Bars in columns"
}
BBL.RIGGING_TYPES = RIGGING_TYPES

local CONFIG_ATTRIBUTE_TYPES = {
	"Dim",
	"Pan/Tilt",
	"Tilt only",
	"Colormix",
	"Colorwheel",
	"Gobo",
	"Prism",
	"Zoom"
}
BBL.CONFIG_ATTRIBUTE_TYPES = CONFIG_ATTRIBUTE_TYPES

local APPEARANCE = {
	RED 	= '/r=100 /g=0   /b=0',
	GREEN 	= '/r=0   /g=100 /b=0',
	BLUE 	= '/r=0   /g=50  /b=100',
	YELLOW 	= '/r=100 /g=100 /b=0',
	CYAN 	= '/r=0   /g=100 /b=100',
	MAGENTA = '/r=100 /g=0   /b=100',
	WHITE 	= '/r=100 /g=100 /b=100'
}
BBL.APPEARANCE = APPEARANCE

-------------------------- DEFINES End --------------------------


---------------------------------------------------------------------
----------------------------- GMA WRAPPERS --------------------------
---------------------------------------------------------------------

local function print(str)
	local success, err = pcall(function() gma.feedback(str) end)
	if not success then
		gma.feedback("Error printing: " .. err)
	end
end
BBL.print = print


local function safe_cmd(cmd)
	local return_val = nil
	local success, err = pcall(function() return_val = gma.cmd(cmd) end)
	if not success then
		print("Error executing command: " .. cmd .. " with error: " .. err)
	end
	-- feedback("Return value: " .. tostring(return_val))
end
BBL.cmd = safe_cmd



local function getvar(var)
	local return_val = nil
	local success, err = pcall(function() return_val = gma.user.getvar(var) end)
	if not success then
		print("Error getting variable: " .. var .. " with error: " .. err)
	end

	return return_val
end
BBL.getvar = getvar


local function setvar(var, value)
	local success, err = pcall(function()

	local split_var = BBL.split_string_into_array(var, " ")
	if #split_var ~= 1 then
		error(string.format('ERROR in setvar: Variable names cannot contain spaces. Attempted to set variable with name "%s". Aborting', var))
	end

	local cur_val = BBL.getvar(var)
	if cur_val == nil then
		BBL.add_to_var_nukelist(var)
	end
	gma.user.setvar(var, value)

	end)
	if not success then
		print(string.format("ERROR in setvar: %s", err))
	end
end
BBL.setvar = setvar


BBL.error_log = BBL.error_log or {}
local function custom_error(err_msg)
	BBL.print(err_msg)
	table.insert(BBL.error_log, err_msg)
	-- error(err_msg)
end
BBL.error = custom_error


local function print_error_log()
	for i = 1, #BBL.error_log do
		BBL.print(BBL.error_log[i])
	end
end
BBL.print_error_log = print_error_log


----------------------------------------------------------------------
------------------------------ NUKELIST ------------------------------
----------------------------------------------------------------------

local function add_to_nukelist(item_type, item_number)
	local success, return_val = pcall(function()
	
		if BBL.is_recognized_pool_object(item_type) == false then
			error("Attempted to add unrecognized item type: " .. item_type .. " with number: " .. item_number .. " to nukelist. Aborting.")
			return
		end

		local len_nukelist = BBL.getvar("LEN_NUKELIST")
		if type(item_number) == "string" then
			BBL.setvar(string.format("NUKELIST_%d", len_nukelist + 1), string.format("%s %s", item_type, item_number))
		elseif type(item_number) == "number" then
			BBL.setvar(string.format("NUKELIST_%d", len_nukelist + 1), string.format("%s %.0f", item_type, item_number))
		else
			return "Item number was of an urecognised type"
		end
		BBL.setvar("LEN_NUKELIST", string.format("%d", len_nukelist + 1))


	end)
	if success ~= true then
		BBL.print(string.format("ERROR in add_to_nukelist: %s", return_val))
	end
end
BBL.add_to_nukelist = add_to_nukelist


local function add_to_var_nukelist(variable_name)
	local cur_len = tonumber(BBL.getvar("LEN_VAR_NUKE"))
	local new_len = cur_len + 1
	
	if cur_len == nil then
		BBL.print("ERROR in add_to_var_nukelist. Aborting")
		return
	end

	gma.user.setvar(string.format('VAR_NUKE_%d', new_len), variable_name)
	gma.user.setvar(string.format('LEN_VAR_NUKE'), tostring(new_len))
end
BBL.add_to_var_nukelist = add_to_var_nukelist


local function delete_group_config_variables()
	local success, return_val = pcall(function()

	local groups = BBL.get_gen_groups()
	for _, group in ipairs(groups) do
		BBL.cmd(string.format('setuservar GROUP_%.0f_CONFIG = \"\"', group))
	end

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in get_group_config: %s", return_val))
	end
end
BBL.delete_group_config_variables = delete_group_config_variables

---------------------------------------------------------------------
----------------------------- ARRAY/HASHMAP -------------------------
---------------------------------------------------------------------

local function split_string_into_array(inputstr, delimiter)
	-- BBL.print(string.format("Splitting string \"%s\" with delimiter \"%s\"", inputstr, sep))

	if inputstr == "" then
		return {}
	end
    
	local result = {}

    local pattern = "(.-)" .. delimiter
    local next_start = 1
	
    local start, stop, content = string.find(inputstr, pattern, 1)
	-- if start == nil then
	-- 	return result
	-- end
    while start do
        table.insert(result, content)
        next_start = stop + 1
        start, stop, content = string.find(inputstr, pattern, next_start)
    end
	
    -- capture the final segment (even if empty)
    table.insert(result, string.sub(inputstr, next_start))
	-- BBL.print(string.format("Returning {%s}", table.concat(result, ",")))
    return result

end
BBL.split_string_into_array = split_string_into_array


local function shallow_copy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end
BBL.shallow_copy = shallow_copy


local function table_has_value(table_to_check, value)
    for _, v in pairs(table_to_check) do
        if v == value then
            return true
        end
    end
    return false
end
BBL.table_has_value = table_has_value


local function remove_value_from_hashmap(hashmap, val)
    for k, v in pairs(hashmap) do
		if tostring(v) == tostring(val) and v ~= val then
			BBL.print(string.format("Warning: remove_value_from_hashmap found a match for the target value %s, but type %s != %s, so skipping item", val, type(v), type(val)))
	 	elseif v == val then	
            local success, err_msg = pcall(function() hashmap[k] = nil end)
			if success == true then
				-- BBL.print(string.format("Removed {%s, %s} from table", k, v))
				return true -- Successfully removed
			else
				BBL.print(string.format("Error: remove_value_from_hashmap in call to 'hashmap[%s] = nil' for {%s, %s}: %s", k, k, v, err_msg))
				return false
			end
            return true -- Successfully removed
        end
    end
    return false -- Value not found
end
BBL.remove_value_from_hashmap = remove_value_from_hashmap


local function remove_value_from_array(array, val)
    for k, v in pairs(array) do
		if tostring(v) == tostring(val) and v ~= val then
			BBL.print(string.format("Warning: remove_value_from_array found a match for the target value %s, but type %s != %s, so skipping item", val, type(v), type(val)))
	 	elseif v == val then	
            local success, err_msg = pcall(function() table.remove(array, k) end)
			if success == true then
				-- BBL.print(string.format("Removed {%s, %s} from table", k, v))
				return true -- Successfully removed
			else
				BBL.print(string.format("Error: remove_value_from_array in call to 'table.remove(array, %s)' for value %s: %s", k, v, err_msg))
				return false
			end
            return true -- Successfully removed
        end
    end
    return false -- Value not found
end
BBL.remove_value_from_array = remove_value_from_array


local function count_num_entries(table_to_count)
	local count = 0
	for _, _ in pairs(table_to_count) do
		count = count + 1
	end
end
BBL.count_num_entries = count_num_entries


local function count_num_unique_entries(table_to_count)
	local count = 0
	local found = {}
	for _, v in pairs(table_to_count) do
		if BBL.table_has_value(found, v) == false then
			table.insert(found, v)
			count = count + 1
		end
	end
	-- BBL.print(string.format("Number of unique values = %d", count))
	return count
end
BBL.count_num_unique_entries = count_num_unique_entries

local function get_hashmap_size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end
BBL.get_hashmap_size = get_hashmap_size


------------------------------------------------------------------------------------------------
------------------------------------------ MISC HELPERS ----------------------------------------
------------------------------------------------------------------------------------------------

local function rgb_to_color(rgb_string)
	for key, value in pairs(BBL.APPEARANCE) do
		if value == rgb_string then
			return key
		end
	end

end


local function group_to_page_col(group_num)
	local page =  BBL.GROUP_CONFIG_PAGE_START + math.floor((group_num - 1) / 5)
	local col = 101 +((group_num - 1) % 5)
	return page, col
end
BBL.group_to_page_col = group_to_page_col


-----------------------------------------------------------------------------------------------
------------------------------------------ POOL OBJECTS ---------------------------------------
-----------------------------------------------------------------------------------------------


local function is_recognized_pool_object(item_type)
	local item_type_lower = string.upper(item_type)
	for _, recognized_type in ipairs(BBL.RECOGNIZED_POOL_OBJECTS) do
		if item_type_lower == recognized_type then
			return true
		end
	end
	return false
end
BBL.is_recognized_pool_object = is_recognized_pool_object


local function get_contigous_pool_items(type, starting_point)
	local objects = {}
	local break_loop = false
	local index = starting_point
	local first_found = false
	local num_skipped = 0

	while break_loop == false do
		local handle = gma.show.getobj.handle(string.format('%s %.0f', type, index))
		local exists = gma.show.getobj.verify(handle)

		if exists == true then
			table.insert(objects, index)
			first_found = true
		elseif first_found == true then
			break_loop = true
		else
			num_skipped = num_skipped + 1
		end  
		index = index + 1
	end

	return objects, num_skipped
end
BBL.get_contigous_pool_items = get_contigous_pool_items


local function get_gen_groups()
	return get_contigous_pool_items("group", BBL.FIRST_GROUP_TO_GENERATE_FROM)
end
BBL.get_gen_groups = get_gen_groups


local function get_pool_object_name()
end
BBL.get_pool_object_name = get_pool_object_name


local function reserve_next_available_pool_item(type)
	local success, return_val = pcall(function()

	local valid_type = is_recognized_pool_object(type)
	if valid_type == false then
		BBL.print(string.format("Error: reserve_next_available_pool_item received unrecognized type '%s'. Throwing error.", type))
		error(string.format("reserve_next_available_pool_item received unrecognized type '%s'. Throwing error.", type))
	end

	type = string.upper(type)
	
	local assumed_next_item = BBL.getvar(string.format("NEXT_AVAILABLE_%s", type))
	if assumed_next_item == nil then
		error(string.format("ERROR in reserve_next_available_pool_item: Call to getvar() returned nil attempting to get uservar %s", string.format("NEXT_AVAILABLE_%s", type)))
	end

	-- Check if the sequence is actually available, and if not, find the next one that is
	local next_item = assumed_next_item
	local item_occupied = true
	while item_occupied == true do
		local handle = gma.show.getobj.handle(string.format('%s %.0f',type , next_item))
		item_occupied = gma.show.getobj.verify(handle)
		if item_occupied == true then
			next_item = next_item + 1
		end
	end

	BBL.setvar(string.format("NEXT_AVAILABLE_%s", type), string.format("%.0f", next_item + 1))
	BBL.add_to_nukelist(type, next_item)
	return next_item

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in reserve_next_available_pool_item: %s", return_val))
	end

	return return_val
end
BBL.reserve_next_available_pool_item = reserve_next_available_pool_item


local function reserve_next_available_remote(remote_type)
	local success, return_val = pcall(function()

	local next_available = nil
	local remote_handle = nil

	if remote_type == BBL.FADER_REMOTE then
		next_available = BBL.getvar(BBL.NEXT_AVAILABLE_REMOTE)
		remote_handle = gma.show.getobj.handle(string.format('fixture "%s %s"', BBL.FADER_REMOTE, next_available))
	elseif remote_type == BBL.FADER_REMOTE_FLIPPED then
		next_available = BBL.getvar(BBL.NEXT_AVAILABLE_REMOTE_FLIPPED)
		remote_handle = gma.show.getobj.handle(string.format('fixture "%s %s"', BBL.FADER_REMOTE_FLIPPED, next_available))
	else
		error("ERROR in reserve_next_available_remote: Unknown remote type")
		return false, nil
	end

	local remote_exists = gma.show.getobj.verify(remote_handle)
	if remote_exists == false then
		BBL.print(string.format("Hello world:"))
		error(string.format("ERROR in reserve_next_available_remote: %s %s does not appear to exist (probably out of bounds)", remote_type, next_available))
		return false, nil
	end

	-- Compute new next_available
	local next_available_split = BBL.split_string_into_array(next_available, "%.")
	local new_next_available = nil
	if next_available_split[2] == "512" then
		new_next_available = string.format("%.0f.%s", tonumber(next_available_split[1]) + 1, "1")
	else
		new_next_available = string.format("%s.%.0f", next_available_split[1], tonumber(next_available_split[2]) + 1)
	end

	if remote_type == BBL.FADER_REMOTE then
		BBL.setvar(BBL.NEXT_AVAILABLE_REMOTE, new_next_available)
	elseif remote_type == BBL.FADER_REMOTE_FLIPPED then
		BBL.setvar(BBL.NEXT_AVAILABLE_REMOTE_FLIPPED, new_next_available)
	else
		error("ERROR in reserve_next_available_remote: Unknown remote type")
		return false, nil
	end


	return next_available
	
	end)
	if success ~= true then
		BBL.print(string.format("ERROR in reserve_next_available_remote: %s", return_val))
	end

	return return_val
end
BBL.reserve_next_available_remote = reserve_next_available_remote


local function get_sequence_as_hashmap(sequence_number)
	local sequence_hashmap = {}
	
	local sequence_handle = gma.show.getobj.handle(string.format('sequence %d', sequence_number))
	local sequence_exists = gma.show.getobj.verify(sequence_handle)
	if sequence_exists == false then
		error(string.format("get_sequence_as_hashmap was called with sequence number %d, but no such sequence exists. Throwing error.", sequence_number))
	end

	local child_name = ""
	local split_child_name = {}
	local cue_number = ""
	local child_index = 1
	local sequence_child = gma.show.getobj.child(sequence_handle, child_index)
	local child_exists = gma.show.getobj.verify(sequence_child)
	while child_exists == true do
		child_name = gma.show.getobj.name(sequence_child)
		split_child_name = BBL.split_string_into_array(child_name, " ")
		cue_number = split_child_name[#split_child_name]
		child_name = table.concat(split_child_name, " ", 1, #split_child_name - 1)
		sequence_hashmap[cue_number] = child_name

		child_index = child_index + 1
		sequence_child = gma.show.getobj.child(sequence_handle, child_index)
		child_exists = gma.show.getobj.verify(sequence_child)
	end
	return sequence_hashmap
end
BBL.get_sequence_as_hashmap = get_sequence_as_hashmap

local function get_effect_templates(effect_type)
	local dim_templates, gap_from_start 	= BBL.get_contigous_pool_items(BBL.EFFECT, BBL.FIRST_TEMPLATE_EFFECT)
	local mov_templates, gap_from_dim 		= BBL.get_contigous_pool_items(BBL.EFFECT, dim_templates[#dim_templates] + 1)
	local tilt_templates, gap_from_dim 		= BBL.get_contigous_pool_items(BBL.EFFECT, mov_templates[#mov_templates] + 1)
	local colormix_templates, gap_from_mov	= BBL.get_contigous_pool_items(BBL.EFFECT, tilt_templates[#tilt_templates] + 1)

	if effect_type == BBL.ATTRIBUTE_DIM then
		return dim_templates
	elseif effect_type == BBL.ATTRIBUTE_MOV then
		return mov_templates
	elseif effect_type == BBL.ATTRIBUTE_TILT then
		return tilt_templates
	elseif effect_type == BBL.ATTRIBUTE_COLORMIX then
		return colormix_templates	
	else
		BBL.error(string.format("ERROR in get_effect_templates: Unrecognized effect type %s. Returning nil.", effect_type))
		return nil
	end

end
BBL.get_effect_templates = get_effect_templates





---------------------------------------------------------------------------------------------
----------------------------------------- CONFIG TABLES -------------------------------------
---------------------------------------------------------------------------------------------



local function get_group_config(group_num)
	local success, return_val = pcall(function()
	local config_string = BBL.getvar(string.format("GROUP_%d_CONFIG", group_num))

	if config_string == nil then
		local return_val = BBL.group_config.new(group_num)
		BBL.print(string.format("No config found for group %d, returning default config.", group_num))
		-- BBL.print_config(return_val)
		return return_val
	end

	local config_table = BBL.config_string_to_table(config_string, group_num)
	-- BBL.print(string.format("Parsed config table for group %d:", group_num))
	-- BBL.print_config(config_table)
	-- Add some error handling here later

	return config_table

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in get_group_config: %s", return_val))
	end

	return return_val
end
BBL.get_group_config = get_group_config


local function store_group_config(group_config)
	local config_string = BBL.config_table_to_string(group_config)
	gma.user.setvar(string.format("GROUP_%d_CONFIG", group_config.group_number), config_string)
end
BBL.store_group_config = store_group_config


local function config_string_to_table(config_string, group_num)

	local entries = BBL.split_string_into_array(config_string, "-")
	
	local config = BBL.group_config.new(group_num)
	config.group_number = tonumber(group_num)
	config.template = entries[1]
	config.long_name = entries[2]
	config.short_name = entries[3]
	config.color = entries[4]
	
	-- Avoid duplicates in table
	local rigging_config = BBL.split_string_into_array(entries[5], ",")
	local attribute_config = BBL.split_string_into_array(entries[6], ",")
	for _, v in ipairs(rigging_config) do
		if table_has_value(config.rigging_config, v) == false then
			table.insert(config.rigging_config, v) -- Remember that keys and values must be string representation of the number
		end
	end
	for _, v in ipairs(attribute_config) do
		if table_has_value(config.attribute_config, v) == false then
			table.insert(config.attribute_config, v) -- Remember that keys and values must be string representation of the number
		end
	end

	return config
end
BBL.config_string_to_table = config_string_to_table


local function config_table_to_string(config_table)
	local config_string = ""
	config_string = config_string .. config_table.template .. "-"
	config_string = config_string .. config_table.long_name .. "-"
	config_string = config_string .. config_table.short_name .. "-"
	config_string = config_string .. config_table.color .. "-"

	if config_table.rigging_config == nil then
		config_string = config_string .. "-"
	else
		config_string = config_string .. table.concat(config_table.rigging_config, ",") .. "-"
	end
	if config_table.attribute_config == nil then
		config_string = config_string .. "-"
	else
		config_string = config_string .. table.concat(config_table.attribute_config, ",")
	end

	return config_string
end
BBL.config_table_to_string = config_table_to_string


local function add_to_group_config(group_num, type, config_num)
	local success, error = pcall(function()
	
	-- BBL.print(string.format("Add group to config was called for group_num %d, type %s, config_num %d", group_num, type, config_num))

	local page, col = BBL.group_to_page_col(group_num)
	local config = BBL.get_group_config(group_num)
	local src_exec = ""
	local dst_exec = ""
	local num_types_configured = 0
	local max_num_types = 0
	
	if type == "rigging" then
		table.insert(config.rigging_config, config_num)
		num_types_configured 	= BBL.count_num_unique_entries(config.rigging_config)
		max_num_types 			= #BBL.RIGGING_TYPES
		src_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.UNAPPLIED_RIGGING_CONFIGS)
		dst_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.APPLIED_RIGGING_CONFIGS)
	elseif type == "attribute" then
		table.insert(config.attribute_config, config_num)
		num_types_configured	= BBL.count_num_unique_entries(config.attribute_config)
		max_num_types 			= #BBL.CONFIG_ATTRIBUTE_TYPES
		src_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.UNAPPLIED_ATTRIBUTE_CONFIGS)
		dst_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.APPLIED_ATTRIBUTE_CONFIGS)
	else
		BBL.print("ERROR in add_to_group_config, unrecognised type, aborting.")
		return
	end
	BBL.store_group_config(config)
	
	-- Add to remove-exec
	BBL.cmd(string.format('store exec %s cue %s /nc', dst_exec, config_num))
	if num_types_configured == 1 and config_num ~= "1" then
		BBL.cmd(string.format('delete exec %s cue 1 /nc', dst_exec))
	end
	
	-- Delete cue from add-exec
	if num_types_configured == max_num_types then
		if init == false and config_num ~= "1" then
			BBL.cmd(string.format('store exec %s cue 1 /nc', src_exec))
			BBL.cmd(string.format('label exec %s cue 1 "Empty" /nc', src_exec, config_num))
			BBL.cmd(string.format('Assign exec %s cue 1 /cmd="off exec %s" /nc', src_exec, src_exec))
			BBL.cmd(string.format('delete exec %s cue %s /nc', src_exec, config_num))
		elseif init == true and config_num ~= "1" then
			BBL.cmd(string.format('delete exec %s cue %s /nc', src_exec, config_num))
		else
			BBL.cmd(string.format('label exec %s cue 1 "Empty" /nc', src_exec, config_num))
			BBL.cmd(string.format('Assign exec %s cue 1 /cmd="off exec %s" /nc', src_exec, src_exec))
		end
	else
		BBL.cmd(string.format('delete exec %s cue %s /nc', src_exec, config_num))
	end

	if type == "rigging" then
		BBL.cmd(string.format('label exec %s cue %s "%s" /nc', dst_exec, config_num, BBL.RIGGING_TYPES[tonumber(config_num)]))
		BBL.cmd(string.format('Assign exec %s cue %s /cmd="plugin 2 remove_from_group_config,%s,rigging,%s" /nc', dst_exec, config_num, group_num, config_num))
	elseif type == "attribute" then
		BBL.cmd(string.format('label exec %s cue %s "%s" /nc', dst_exec, config_num, BBL.CONFIG_ATTRIBUTE_TYPES[tonumber(config_num)]))
		BBL.cmd(string.format('Assign exec %s cue %s /cmd="plugin 2 remove_from_group_config,%s,attribute,%s" /nc', dst_exec, config_num, group_num, config_num))
	end
	BBL.cmd(string.format('off exec %s', src_exec))

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in add_to_group_config: %s", error))
	end
end
BBL.add_to_group_config = add_to_group_config


local function remove_from_group_config(group_num, type, config_num)
	local success, error = pcall(function()
	
	BBL.print(string.format("Add group to config was called for group_num %d, type %s, config_num %d", group_num, type, config_num))

	local page, col = BBL.group_to_page_col(group_num)
	local config = BBL.get_group_config(group_num)
	local src_exec = ""
	local dst_exec = ""
	local num_types_configured = 0
	local max_num_types = 0
	
	if type == "rigging" then
		BBL.remove_value_from_array(config.rigging_config, config_num)
		num_types_configured 	= BBL.count_num_unique_entries(config.rigging_config)
		max_num_types 			= #BBL.RIGGING_TYPES
		src_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.APPLIED_RIGGING_CONFIGS)
		dst_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.UNAPPLIED_RIGGING_CONFIGS)
	elseif type == "attribute" then
		BBL.remove_value_from_array(config.attribute_config, config_num)
		num_types_configured	= BBL.count_num_unique_entries(config.attribute_config)
		max_num_types 			= #BBL.CONFIG_ATTRIBUTE_TYPES
		src_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.APPLIED_ATTRIBUTE_CONFIGS)
		dst_exec 				= string.format("%d.%d", page, col + BBL.OFFSET.UNAPPLIED_ATTRIBUTE_CONFIGS)
	else
		BBL.print("ERROR in remove_from_group_config, unrecognised type, aborting.")
		return
	end
	BBL.store_group_config(config)
	
	-- Add to add-exec
	BBL.cmd(string.format('store exec %s cue %s /nc', dst_exec, config_num))
	if num_types_configured == max_num_types - 1 and config_num ~= "1" then
		BBL.cmd(string.format('delete exec %s cue 1 /nc', dst_exec))
	end	

	-- Delete cue from remove-exec
	if num_types_configured == 0 then
		BBL.cmd(string.format('store exec %s cue 1 /nc', src_exec))
		BBL.cmd(string.format('label exec %s cue 1 "Empty" /nc', src_exec, config_num))
		BBL.cmd(string.format('Assign exec %s cue 1 /cmd="off exec %s" /nc', src_exec, src_exec))
		if config_num ~= "1" then
			BBL.cmd(string.format('delete exec %s cue %s /nc', src_exec, config_num))
		end
	else
		BBL.cmd(string.format('delete exec %s cue %s /nc', src_exec, config_num))
	end

	if type == "rigging" then
		BBL.cmd(string.format('label exec %s cue %s "%s" /nc', dst_exec, config_num, BBL.RIGGING_TYPES[tonumber(config_num)]))
		BBL.cmd(string.format('Assign exec %s cue %s /cmd="plugin 2 add_to_group_config,%s,rigging,%s" /nc', dst_exec, config_num, group_num, config_num))
	elseif type == "attribute" then
		BBL.cmd(string.format('label exec %s cue %s "%s" /nc', dst_exec, config_num, BBL.CONFIG_ATTRIBUTE_TYPES[tonumber(config_num)]))
		BBL.cmd(string.format('Assign exec %s cue %s /cmd="plugin 2 add_to_group_config,%s,attribute,%s" /nc', dst_exec, config_num, group_num, config_num))
	end
	BBL.cmd(string.format('off exec %s', src_exec))

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in remove_from_group_config: %s", error))
	end
end
BBL.remove_from_group_config = remove_from_group_config


local function print_group_config(config)
	print(string.format("Group number: %d", config.group_number))
	print(string.format("Template: %s", config.template))
	print(string.format("Long name: %s", config.long_name))
	print(string.format("Short name: %s", config.short_name))
	print(string.format("Color: %s", config.color))
	print("Rigging config:")
	for _, rig in ipairs(config.rigging_config) do
		print(string.format("- %s", rig))
	end
	print("Attribute config:")
	for _, attr in ipairs(config.attribute_config) do
		print(string.format("- %s", attr))
	end
end
BBL.print_group_config = print_group_config



------------------------------------------------------------------------------------------
----------------------------------- CLASSES/STRUCTURES -----------------------------------
------------------------------------------------------------------------------------------

local template_config = {
    group_number    = { type = "number", default = 100 },
    template        = { type = "string", default = "N/A" },
    long_name       = { type = "string", default = "N/A" },
    short_name      = { type = "string", default = "N/A" },
    color           = { type = "string", default = rgb_to_color(BBL.APPEARANCE.YELLOW) },
    rigging_config  = { type = "table", default = {} },
    attribute_config= { type = "table", default = {} }
}

BBL.group_config = {}
function BBL.group_config.new(group_num)
	if group_num == nil then
		BBL.print("Error: group_config.new requires a group number to initialize. Throwing error.")
		error("group_config.new requires a group number to initialize.")
	end

    -- real storage (hidden)
    local data = {}

    -- -- apply defaults
    for k, v in pairs(template_config) do
		if type(v.default) == "table" then
			data[k] = {}  -- create a fresh table
		else
			data[k] = v.default
		end
    end

    -- optional: override number immediately
	data.group_number = group_num

    -- proxy object (this is what you return)
    local proxy = {}

    local mt = {}

    -- READ access
    mt.__index = function(_, key)
        return data[key]
    end

    -- WRITE access (this enforces your schema )
    mt.__newindex = function(_, key, value)

        local def = template_config[key]

        if not def then
            BBL.print("Invalid field: " .. tostring(key) .. " throwing error.")
            error("Invalid field: " .. tostring(key))
        end

        if type(value) ~= def.type then
			BBL.print(string.format("Field '%s' expects %s, got %s. Throwing error.", key, def.type, type(value)))
			error(string.format("Field '%s' expects %s, got %s. Throwing error.", key, def.type, type(value)))
        end

        data[key] = value
    end

    return setmetatable(proxy, mt)
end
