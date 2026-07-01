-----------------------------------------------------------------------------------------
----------------------------------- The BigBoy Script -----------------------------------
-----------------------------------------------------------------------------------------

-- "includes"
local BBL = BBL or {}
if next(BBL) == nil then
	gma.cmd("plugin \"BBL\"")
	BBL.print("BBL was not yet initialized, it is now. Rerun the plugin.")
	return
else
	BBL.print("BBL was initialized, proceeding with execution.")
end

-- State variables
local build_all_is_running = false



---------------------------------------------------------------------
------------------------------- BUILD -------------------------------
---------------------------------------------------------------------

-- Creates a sequence with the labels and commands given in the nesten list goto_options_and_cmds, 
-- assigns that sequence to the executor "exec" with the given name and color.
local function build_config_button(name, exec, color, goto_options_and_cmds)
	local success, return_val = pcall(function()
	
	local exec_handle = gma.show.getobj.handle(string.format("Executor %s", exec)) 
	local exec_exists = gma.show.getobj.verify(exec_handle)
	if exec_exists == false then
		local seq_num = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
		
		BBL.cmd(string.format('BlindEdit ON'))
		BBL.cmd(string.format('ClearAll'))
		for cue, elem in ipairs(goto_options_and_cmds) do
			local cue_text, cmd = elem[1], elem[2]
			cmd = string.gsub(cmd, "'", "\'") 
			BBL.cmd(string.format('Store Sequence %d cue %d', seq_num, cue))
			BBL.cmd(string.format('Label Sequence %d cue %d "%s"', seq_num, cue, cue_text))
			BBL.cmd(string.format('Assign Sequence %d cue %d /cmd=\"%s\" %s /nc', seq_num, cue, cmd, BBL.CONFIG_GRID_SEQ_OPTIONS))
			cue = cue + 1
		end
		BBL.cmd(string.format('BlindEdit OFF'))
		BBL.cmd(string.format('Label Sequence %d "%s"', seq_num, name))
		BBL.cmd(string.format('Assign Sequence %d ExecButton1 %s', seq_num, exec))
		BBL.cmd(string.format('Assign Exec %s %s', exec, BBL.CONFIG_GRID_BUTTON_OPTIONS))
		BBL.cmd(string.format('Assign %s Exec %s', BBL.CONFIG_GRID_BUTTON_TYPE, exec))
		BBL.cmd(string.format('Appearance Sequence %d %s', seq_num, color))
	
		return seq_num
	
	end

	end)
	if success ~= true then
		BBL.error(string.format("ERROR in build_button: %s", return_val))
	end

	return return_val
end

local function build_config_grid()
	local success, error = pcall(function()

	local groups = BBL.get_gen_groups()
	for _, group_num in ipairs(groups) do
		local page, col = BBL.group_to_page_col(group_num)
		
		-- Template options
		local template_options_and_cmds = {
			{"Not", ""},
			{"Yet", ""},
			{"Implemented", ""},
		}
		build_config_button("Template", string.format("%d.%d", page, col), BBL.APPEARANCE.YELLOW, template_options_and_cmds)

		-- Given configuations
		local given_configurations_options_and_cmds = {
			{"Empty", string.format("off exec %d.%d", page, col + BBL.OFFSET.APPLIED_RIGGING_CONFIGS)},
		}
		build_config_button("Riggs", string.format("%d.%d", page, col + 5), BBL.APPEARANCE.YELLOW, given_configurations_options_and_cmds)

		-- Available configurations
		local available_configurations_options_and_cmds = {}
		for type_index, type in ipairs(BBL.RIGGING_TYPES) do
			local option_name = type .. " (TBI)"
			local cmd = string.format("plugin 2 add_to_group_config,%d,rigging,%s", group_num, type_index)
			table.insert(available_configurations_options_and_cmds, {option_name, cmd})
		end
		build_config_button("Add Rigg", string.format("%d.%d", page, col + 10), BBL.APPEARANCE.YELLOW, available_configurations_options_and_cmds)

		 -- Given attributes
		 local given_attributes_options_and_cmds = {
			{"Empty", string.format("off exec %d.%d", page, col + BBL.OFFSET.APPLIED_ATTRIBUTE_CONFIGS)},
		}
		build_config_button("Attr", string.format("%d.%d", page, col + 15), BBL.APPEARANCE.YELLOW, given_attributes_options_and_cmds)

		-- Available attributes
		local available_attributes_options_and_cmds = {}
		for type_index, type in ipairs(BBL.CONFIG_ATTRIBUTE_TYPES) do
			local option_name = type ..  " (TBI)"
			local cmd = string.format("plugin 2 add_to_group_config,%d,attribute,%s", group_num, type_index)
			table.insert(available_attributes_options_and_cmds, {option_name, cmd})
		end
		build_config_button("Add Attr", string.format("%d.%d", page, col + 20), BBL.APPEARANCE.YELLOW, available_attributes_options_and_cmds)
	
		-- Configure
		local configure_options_and_cmds = {
			{"Set long name (TBI)", ""},
			{"Set short name (TBI)", ""},
			{"Set color (TBI)", ""},
		}
		build_config_button("Config", string.format("%d.%d", page, col + 25), BBL.APPEARANCE.YELLOW, configure_options_and_cmds)
	end	

	end)
	if success ~= true then
		BBL.error(string.format("ERROR in build_default_group_config_buttons: %s", error))
	end
end


local function apply_group_config(group_configs)
	local success, err = pcall(function()
	
		-- BBL.print(string.format("Performing action: apply_group_config for group %d with config %s", group_configs.group_number, string.format("%.0f", group_configs)))
		local rigging_config 	= BBL.shallow_copy(group_configs.rigging_config)	-- probably not necessary, but since add_to_group_config
		local attribute_config 	= BBL.shallow_copy(group_configs.attribute_config)  -- also touches group_config.rigging_config, I am doing this to be sure

		for _, rigg in ipairs(rigging_config) do
			-- BBL.print(string.format("Applying rigging config: %s for group %d", rigg, group_configs.group_number))
			BBL.add_to_group_config(group_configs.group_number, "rigging", rigg)
		end

		for _, attr in ipairs(attribute_config) do
			-- BBL.print(string.format("Applying attribute config: %s for group %d", attr, group_configs.group_number))
			BBL.add_to_group_config(group_configs.group_number, "attribute", attr)
		end

	end)
	if success ~= true then
		BBL.error(string.format("ERROR in apply_group_config: %s", err))
	end
end

local function build_subgroups()
	local success, err = pcall(function()
	
	local gen_groups = BBL.get_gen_groups()
	for _, group_num in ipairs(gen_groups) do

		----------------------------------------- GET REMOTE VARIABLES -----------------------------------------
		
		local L1_group_master_exec 	= BBL.getvar(string.format("GROUP_%.0f_L1_GROUP_MASTER_EXEC", group_num))
		local L2_group_master_exec 	= BBL.getvar(string.format("GROUP_%.0f_L2_GROUP_MASTER_EXEC", group_num))
		local L3_group_master_exec 	= BBL.getvar(string.format("GROUP_%.0f_L3_GROUP_MASTER_EXEC", group_num))
		local L1_stomp_exec  		= BBL.getvar(string.format("GROUP_%.0f_L1_STOMP_EXEC", group_num))
		local L2_stomp_exec  		= BBL.getvar(string.format("GROUP_%.0f_L2_STOMP_EXEC", group_num))
		local L3_stomp_exec  		= BBL.getvar(string.format("GROUP_%.0f_L3_STOMP_EXEC", group_num))
		
		if L1_group_master_exec == nil then
			L1_group_master_exec = BBL.reserve_next_available_remote(BBL.FADER_REMOTE)
			BBL.add_to_nukelist(BBL.EXEC, L1_group_master_exec)
			BBL.setvar(string.format("GROUP_%.0f_L1_GROUP_MASTER_EXEC", group_num), L1_group_master_exec)
		end
		if L2_group_master_exec == nil then
			L2_group_master_exec = BBL.reserve_next_available_remote(BBL.FADER_REMOTE)
			BBL.setvar(string.format("GROUP_%.0f_L2_GROUP_MASTER_EXEC", group_num), L2_group_master_exec)
		end
		if L3_group_master_exec == nil then
			L3_group_master_exec = string.format("%.0f.%.0f", BBL.GROUP_L3_MASTER_PAGE, 1 + group_num - BBL.FIRST_GROUP_TO_GENERATE_FROM)
			BBL.setvar(string.format("GROUP_%.0f_L3_GROUP_MASTER_EXEC", group_num), L3_group_master_exec)
		end
		if L1_stomp_exec == nil then
			L1_stomp_exec = BBL.reserve_next_available_remote(BBL.FADER_REMOTE_FLIPPED)
			BBL.setvar(string.format("GROUP_%.0f_L1_STOMP_EXEC", group_num), L1_stomp_exec)
		end
		if L2_stomp_exec == nil then
			L2_stomp_exec = BBL.reserve_next_available_remote(BBL.FADER_REMOTE_FLIPPED)
			BBL.setvar(string.format("GROUP_%.0f_L2_STOMP_EXEC", group_num), L2_stomp_exec)
		end
		if L3_stomp_exec == nil then
			L3_stomp_exec = BBL.reserve_next_available_remote(BBL.FADER_REMOTE_FLIPPED)
			BBL.setvar(string.format("GROUP_%.0f_L3_STOMP_EXEC", group_num), L3_stomp_exec)
		end
		
		
		----------------------------------------- GET GROUP/FIXTURE VARIABLES -----------------------------------------
		local L1_group 			= string.format("%.0f", group_num)
		local L2_group 			= BBL.getvar(string.format("GROUP_%.0f_L2_GROUP", group_num))
		local L3_group 			= BBL.getvar(string.format("GROUP_%.0f_L3_GROUP", group_num))
		local L1_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L1_stomp_exec)
		local L2_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L2_stomp_exec)
		local L3_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L3_stomp_exec)
		
		if L2_group == nil then
			L2_group = BBL.reserve_next_available_pool_item(BBL.GROUP)
			BBL.setvar(string.format("GROUP_%.0f_L2_GROUP", group_num), string.format("%.0f", L2_group))
		end
		if L3_group == nil then
			L3_group = BBL.reserve_next_available_pool_item(BBL.GROUP)
			BBL.setvar(string.format("GROUP_%.0f_L3_GROUP", group_num), string.format("%.0f", L3_group))
		end
		BBL.setvar(string.format("GROUP_%.0f_L1_STOMP_FIXTURE", group_num), L1_stomp_fixture)
		BBL.setvar(string.format("GROUP_%.0f_L2_STOMP_FIXTURE", group_num), L2_stomp_fixture)
		BBL.setvar(string.format("GROUP_%.0f_L3_STOMP_FIXTURE", group_num), L3_stomp_fixture)
		
		-------------------------------------------------------------------------------------------------------
		------------------------------------------------ BUILD ------------------------------------------------
		-------------------------------------------------------------------------------------------------------
		
		-------------------------------------- Build and assign group masters ---------------------------------
		BBL.cmd("BlindEdit on")
		BBL.cmd("Clear All")
		BBL.cmd(string.format('fixture "%s %s"', BBL.FADER_REMOTE, L1_group_master_exec))
		BBL.cmd(string.format('store group %s /o', L2_group))
		BBL.cmd(string.format('label group %s "%s"', L2_group, string.format("G%.0f_L2", group_num)))
		BBL.cmd("Clear All")
		BBL.cmd(string.format('fixture "%s %s"', BBL.FADER_REMOTE, L2_group_master_exec))
		BBL.cmd(string.format('store group %s /o', L3_group))
		BBL.cmd(string.format('label group %s "%s"', L3_group, string.format("G%.0f_L3", group_num)))
		BBL.cmd("Clear All")
		BBL.cmd("BlindEdit off")
		
		BBL.cmd(string.format('assign group %s exec %s', L1_group, L1_group_master_exec))
		BBL.cmd(string.format('assign group %s exec %s', L2_group, L2_group_master_exec))
		BBL.cmd(string.format('assign group %s exec %s', L3_group, L3_group_master_exec))



		-------------------------------------- GET/BUILD STOMP SEQUENCES --------------------------------------
		local L1_stomp_seq 	= BBL.getvar(string.format("GROUP_%.0f_L1_STOMP_SEQ", group_num))
		local L2_stomp_seq 	= BBL.getvar(string.format("GROUP_%.0f_L2_STOMP_SEQ", group_num))
		local L3_stomp_seq 	= BBL.getvar(string.format("GROUP_%.0f_L3_STOMP_SEQ", group_num))
		
		if L1_stomp_seq == nil then
			L1_stomp_seq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
			BBL.setvar(string.format("GROUP_%.0f_L1_STOMP_SEQ", group_num), string.format("%.0f", L1_stomp_seq))
			BBL.cmd(string.format('store sequence %.0f cue 1 /o /nc', L1_stomp_seq))
			BBL.cmd(string.format('assign sequence %.0f %s', L1_stomp_seq, BBL.GROUP_MASTER_STOMP_SEQ_OPTION))
			BBL.cmd(string.format('label sequence %.0f "%s"', L1_stomp_seq, string.format("GROUP_%.0f L1_STOMP", group_num)))
		end
		if L2_stomp_seq == nil then
			L2_stomp_seq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
			BBL.setvar(string.format("GROUP_%.0f_L2_STOMP_SEQ", group_num), string.format("%.0f", L2_stomp_seq))
			BBL.cmd(string.format('store sequence %.0f cue 1 /o /nc', L2_stomp_seq))
			BBL.cmd(string.format('assign sequence %.0f %s', L2_stomp_seq, BBL.GROUP_MASTER_STOMP_SEQ_OPTION))
			BBL.cmd(string.format('label sequence %.0f "%s"', L2_stomp_seq, string.format("GROUP_%.0f L2_STOMP", group_num)))
		end
		if L3_stomp_seq == nil then
			L3_stomp_seq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
			BBL.setvar(string.format("GROUP_%.0f_L3_STOMP_SEQ", group_num), string.format("%.0f", L3_stomp_seq))
			BBL.cmd(string.format('store sequence %.0f cue 1 /o /nc', L3_stomp_seq))
			BBL.cmd(string.format('assign sequence %.0f %s', L3_stomp_seq, BBL.GROUP_MASTER_STOMP_SEQ_OPTION))
			BBL.cmd(string.format('label sequence %.0f "%s"', L3_stomp_seq, string.format("GROUP_%.0f L3_STOMP", group_num)))
		end


		-------------------------------------- Get/make stomp effect template ------------------------------------
		local stomp_template = BBL.getvar(BBL.DIM_STOMP_TEMPLATE_EFFECT)
		if stomp_template == nil then
			stomp_template = BBL.reserve_next_available_pool_item(BBL.EFFECT)
			BBL.setvar(BBL.DIM_STOMP_TEMPLATE_EFFECT, string.format("%.0f", stomp_template))

			BBL.cmd(string.format("store effect %0.f /o", stomp_template))
			BBL.cmd(string.format("store effect 1.%0.f.1 /o", stomp_template))
			BBL.cmd(string.format("store effect 1.%0.f.1 /o", stomp_template))
			BBL.cmd(string.format('assign form "stomp" at effect 1.%0.f.1 /mode=abs', stomp_template))
			BBL.cmd(string.format('assign attribute "dim" at effect 1.%0.f.1', stomp_template))
			BBL.cmd(string.format('label effect %0.f "DIM_STOMP', stomp_template))
		end
		
		---------------------------------------- Build and assign stomp execs ------------------------------------
		BBL.cmd("BlindEdit on")
		BBL.cmd("Clear All")
		BBL.cmd(string.format('group %s', L1_group))
		BBL.cmd(string.format('at 100'))
		BBL.cmd(string.format('at effect %s', stomp_template))
		BBL.cmd(string.format('store sequence %s cue 1 /o', L1_stomp_seq))
		BBL.cmd(string.format('assign sequence %s exec %s', L1_stomp_seq, L1_stomp_exec))
		BBL.cmd(string.format('assign exec %s %s', L1_stomp_exec, BBL.GROUP_MASTER_STOMP_EXEC_OPTION))
		BBL.cmd(string.format('assign %s exec %s', BBL.GROUP_MASTER_STOMP_EXEC_FADER_TYPE, L1_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton1 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L1_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton2 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L1_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton3 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L1_stomp_exec))
		BBL.cmd("Clear All")

		BBL.cmd(string.format('group %s', L2_group))
		BBL.cmd(string.format('at 100'))
		BBL.cmd(string.format('at effect %s', stomp_template))
		BBL.cmd(string.format('store sequence %s cue 1 /o', L2_stomp_seq))
		BBL.cmd(string.format('assign sequence %s exec %s', L2_stomp_seq, L2_stomp_exec))
		BBL.cmd(string.format('assign exec %s %s', L2_stomp_exec, BBL.GROUP_MASTER_STOMP_EXEC_OPTION))
		BBL.cmd(string.format('assign %s exec %s', BBL.GROUP_MASTER_STOMP_EXEC_FADER_TYPE, L2_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton1 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L2_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton2 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L2_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton3 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L2_stomp_exec))
		BBL.cmd("Clear All")
		
		BBL.cmd(string.format('group %s', L3_group))
		BBL.cmd(string.format('at 100'))
		BBL.cmd(string.format('at effect %s', stomp_template))
		BBL.cmd(string.format('store sequence %s cue 1 /o', L3_stomp_seq))
		BBL.cmd(string.format('assign sequence %s exec %s', L3_stomp_seq, L3_stomp_exec))
		BBL.cmd(string.format('assign exec %s %s', L3_stomp_exec, BBL.GROUP_MASTER_STOMP_EXEC_OPTION))
		BBL.cmd(string.format('assign %s exec %s', BBL.GROUP_MASTER_STOMP_EXEC_FADER_TYPE, L3_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton1 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L3_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton2 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L3_stomp_exec))
		BBL.cmd(string.format('assign %s ExecButton3 %s', BBL.GROUP_MASTER_STOMP_EXEC_BUTTON_TYPE, L3_stomp_exec))
		BBL.cmd("Clear All")
		BBL.cmd("BlindEdit off")

		
		


	end

	end)
	if success ~= true then
		BBL.error(string.format("ERROR in apply_group_config: %s", err))
	end
end

local function build_selectives()
	local success, err = pcall(function()

	-- BBL.print("build_selectives called")
	local gen_groups 			= BBL.get_gen_groups()
	local dim_templates			= BBL.get_effect_templates(BBL.ATTRIBUTE_DIM)
	local mov_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_MOV)
	local tilt_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_TILT)
	local colormix_templates 	= BBL.get_effect_templates(BBL.ATTRIBUTE_COLORMIX)



	BBL.cmd("BlindEdit on")
	for _, group_num in ipairs(gen_groups) do
		local group_config 		= BBL.get_group_config(group_num)
		local has_dimmer 		= BBL.table_has_value(group_config.attribute_config, "1")
		local has_mov    		= BBL.table_has_value(group_config.attribute_config, "2")
		local has_tilt    		= BBL.table_has_value(group_config.attribute_config, "3")
		local has_colormix    	= BBL.table_has_value(group_config.attribute_config, "4")
		
		if has_dimmer == true then
			for _, template in ipairs(dim_templates) do
				local selective = BBL.getvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_DIM, template))
				if selective == nil then
					selective = BBL.reserve_next_available_pool_item(BBL.EFFECT)
					BBL.setvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_DIM, template), string.format("%.0f", selective))
				end

				local L1_group 			= string.format("%.0f", group_num)
				local L2_group 			= BBL.getvar(string.format("GROUP_%.0f_L2_GROUP", group_num))
				local L3_group 			= BBL.getvar(string.format("GROUP_%.0f_L3_GROUP", group_num))
				local L1_stomp_exec  	= BBL.getvar(string.format("GROUP_%.0f_L1_STOMP_EXEC", group_num))
				local L2_stomp_exec  	= BBL.getvar(string.format("GROUP_%.0f_L2_STOMP_EXEC", group_num))
				local L3_stomp_exec  	= BBL.getvar(string.format("GROUP_%.0f_L3_STOMP_EXEC", group_num))
				local L1_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L1_stomp_exec)
				local L2_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L2_stomp_exec)
				local L3_stomp_fixture 	= string.format("%s %s", BBL.FADER_REMOTE_FLIPPED, L3_stomp_exec)


				BBL.cmd("ClearAll")
				BBL.cmd(string.format('copy effect %.0f at %.0f /nc', template, selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('group %s', L1_group))
				BBL.cmd(string.format('store effect 1.%s.1 /o /nc', selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('fixture "%s"', L1_stomp_fixture))
				BBL.cmd(string.format('store effect 1.%s.2 /o /nc', selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('group %s', L2_group))
				BBL.cmd(string.format('store effect 1.%s.3 /o /nc', selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('fixture "%s"', L2_stomp_fixture))
				BBL.cmd(string.format('store effect 1.%s.4 /o /nc', selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('group %s', L3_group))
				BBL.cmd(string.format('store effect 1.%s.5 /o /nc', selective))

				BBL.cmd(string.format('ClearAll'))
				BBL.cmd(string.format('fixture "%s"', L3_stomp_fixture))
				BBL.cmd(string.format('store effect 1.%s.6 /o /nc', selective))

				BBL.cmd(string.format('label effect %.0f "G%.0f D_%.0f"', selective, group_num, template))				
			end
		end

		if has_mov == true then
			for _, template in ipairs(mov_templates) do
				local selective = BBL.getvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_MOV, template))
				if selective == nil then
					selective = BBL.reserve_next_available_pool_item(BBL.EFFECT)
					BBL.setvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_MOV, template), selective)
				end
				
				BBL.cmd("ClearAll")
				BBL.cmd(string.format('copy effect %.0f at %.0f /nc', template, selective))
				BBL.cmd(string.format('group %.0f', group_num))
				BBL.cmd(string.format('store effect 1.%.0f.* /nc', selective))
				BBL.cmd(string.format('Effect 1.%.0f Property "Selective" "Yes"', selective))
				BBL.cmd(string.format('label effect %.0f "G%.0f M_%.0f"', selective, group_num, template))				
			end
		end

		if has_tilt == true then
			for _, template in ipairs(tilt_templates) do
				local selective = BBL.getvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_TILT, template))
				if selective == nil then
					selective = BBL.reserve_next_available_pool_item(BBL.EFFECT)
					BBL.setvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_TILT, template), selective)
				end
				
				BBL.cmd("ClearAll")
				BBL.cmd(string.format('copy effect %.0f at %.0f /nc', template, selective))
				BBL.cmd(string.format('group %.0f', group_num))
				BBL.cmd(string.format('store effect 1.%.0f.* /nc', selective))
				BBL.cmd(string.format('Effect 1.%.0f Property "Selective" "Yes"', selective))
				BBL.cmd(string.format('label effect %.0f "G%.0f T_%.0f"', selective, group_num, template))				
			end
		end

		if has_colormix == true then
			for _, template in ipairs(colormix_templates) do
				local selective = BBL.getvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_COLORMIX, template))
				if selective == nil then
					selective = BBL.reserve_next_available_pool_item(BBL.EFFECT)
					BBL.setvar(string.format('GROUP_%.0f_%s_%.0f_SELECTIVE', group_num, BBL.ATTRIBUTE_COLORMIX, template), selective)
				end
				
				BBL.cmd("ClearAll")
				BBL.cmd(string.format('copy effect %.0f at %.0f /nc', template, selective))
				BBL.cmd(string.format('group %.0f', group_num))
				BBL.cmd(string.format('store effect 1.%.0f.* /nc', selective))
				BBL.cmd(string.format('Effect 1.%.0f Property "Selective" "Yes"', selective))
				BBL.cmd(string.format('label effect %.0f "G%.0f C_%.0f"', selective, group_num, template))				
			end
		end

	end
	BBL.cmd("BlindEdit off")
	
	end)
	if success ~= true then
		BBL.error(string.format("ERROR in build_selectives: %s", err))
	end
end


local function build_pbg_multiseqs()
	local success, err = pcall(function()

	local gen_groups 			= BBL.get_gen_groups()
	local dim_templates			= BBL.get_effect_templates(BBL.ATTRIBUTE_DIM)
	local mov_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_MOV)
	local tilt_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_TILT)
	local colormix_templates 	= BBL.get_effect_templates(BBL.ATTRIBUTE_COLORMIX)

	for _, group_num in ipairs(gen_groups) do
		local group_config = BBL.get_group_config(group_num)
		-- BBL.print(string.format("Group %s has attribute config: {%s}", group_num, table.concat(group_config.attribute_config, ", ")))
		
		-- DIM
		if BBL.table_has_value(group_config.attribute_config, "1") then
			-- Check if sequence already exists, if not create a new one.
			local multiseq = BBL.getvar(string.format("MULTISEQ_DIM_GROUP_%.0f", group_num))
			if multiseq == nil then
				multiseq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
				BBL.setvar(string.format("MULTISEQ_DIM_GROUP_%.0f", group_num), string.format("%.0f", multiseq))
			end


			BBL.cmd("BlindEdit on")
			for template_num, template in ipairs(dim_templates) do
				-- Create cue
				local selective = BBL.getvar(string.format('GROUP_%.0f_DIM_%.0f_SELECTIVE', group_num, template))
				BBL.cmd("ClearAll")
				BBL.cmd(string.format('selfix effect %.0f', selective))
				BBL.cmd(string.format('at effect %.0f', selective))
				BBL.cmd(string.format('store cue %.0f sequence %.0f /o', template_num, multiseq))
				-- BBL.cmd(string.format('assign sequence %.0f cue %.0f /cmd="%s"', multiseq, template_num, "Some_command"))
				
				-- Label cue
				local handle = gma.show.getobj.handle(string.format('effect %.0f', template))
				local exists = gma.show.getobj.verify(handle)
				if exists == false then 
					BBL.error(string.format("ERROR in build_multiseq: Effect %.0f does not exist, cannot read name to assign label to cue.", template))
					error(string.format("ERROR in build_multiseq: Effect %.0f does not exist, cannot read name to assign label to cue.", template))
				end
				local template_name = gma.show.getobj.name(handle)
				template_name = BBL.split_string_into_array(template_name, " ")
				table.remove(template_name, #template_name)
				BBL.cmd(string.format('label sequence %.0f cue %.0f "%s"', multiseq, template_num, table.concat(template_name, " ")))
			end	

			local cue_after_last_created_handle = gma.show.getobj.handle(string.format('sequence %.0f cue %.0f', multiseq, #dim_templates + 1))
			local cue_after_last_created_exists = gma.show.getobj.verify(cue_after_last_created_handle)
			if cue_after_last_created_exists == true then
				BBL.cmd(string.format('delete cue %.0f thru sequence %.0f /nc', #dim_templates + 1, multiseq))
			end

			BBL.cmd("BlindEdit off")

			-- Label sequence and apply options
			local handle = gma.show.getobj.handle(string.format('group %.0f', group_num))
			local exists = gma.show.getobj.verify(handle)
			if exists == false then 
				BBL.error(string.format("ERROR in build_multiseq: Group %.0f does not exist, cannot read name to label multiseq.", group_num))
				error(string.format("ERROR in build_multiseq: Group %.0f does not exist, cannot read name to label multiseq.", group_num))
			end
			local group_name = gma.show.getobj.name(handle)
			group_name = BBL.split_string_into_array(group_name, " ")
			table.remove(group_name, #group_name)
			BBL.cmd(string.format('label sequence %.0f "%s (Dim Multi)"', multiseq, table.concat(group_name, " ")))
			BBL.cmd(string.format('assign sequence %.0f %s', multiseq, BBL.MULTISEQ_OPTIONS))
		end

		-- MOV
		if BBL.table_has_value(group_config.attribute_config, "2") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "3") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		end

		-- COLOR
		if BBL.table_has_value(group_config.attribute_config, "4") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "5") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		end

		-- GOBO
		if BBL.table_has_value(group_config.attribute_config, "6") then
			-- BBL.print(string.format("Group %s has attribute GOBO", group_num))
		end

		-- PRISM
		if BBL.table_has_value(group_config.attribute_config, "7") then
			-- BBL.print(string.format("Group %s has attribute PRISM", group_num))
		end

		-- ZOOM
		if BBL.table_has_value(group_config.attribute_config, "8") then
			-- BBL.print(string.format("Group %s has attribute ZOOM", group_num))
		end

		-- local multiseq = BBL.getvar(string.format("GROUP_%s__MULTISEQ", group))
		-- if multiseq == nil then
		-- 	multiseq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
		-- end
	end

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in build_multiseqs: %s", err))
	end
end


local function build_multiseqs()
	local success, err = pcall(function()

	local gen_groups 			= BBL.get_gen_groups()
	local dim_templates			= BBL.get_effect_templates(BBL.ATTRIBUTE_DIM)
	local mov_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_MOV)
	local tilt_templates 		= BBL.get_effect_templates(BBL.ATTRIBUTE_TILT)
	local colormix_templates 	= BBL.get_effect_templates(BBL.ATTRIBUTE_COLORMIX)

	for _, group_num in ipairs(gen_groups) do
		local group_config = BBL.get_group_config(group_num)
		-- BBL.print(string.format("Group %s has attribute config: {%s}", group_num, table.concat(group_config.attribute_config, ", ")))
		
		-- DIM
		if BBL.table_has_value(group_config.attribute_config, "1") then
			-- Check if sequence already exists, if not create a new one.
			local multiseq = BBL.getvar(string.format("MULTISEQ_DIM_GROUP_%.0f", group_num))
			if multiseq == nil then
				multiseq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
				BBL.setvar(string.format("MULTISEQ_DIM_GROUP_%.0f", group_num), string.format("%.0f", multiseq))
			end


			BBL.cmd("BlindEdit on")
			for template_num, template in ipairs(dim_templates) do
				-- Create cue
				local selective = BBL.getvar(string.format('group_%.0f_dim_%.0f_selective', group_num, template))
				BBL.cmd("ClearAll")
				BBL.cmd(string.format('selfix effect %.0f', selective))  
				BBL.cmd(string.format('at effect %.0f', selective))
				BBL.cmd(string.format('store cue %.0f sequence %.0f /o', template_num, multiseq))
				-- BBL.cmd(string.format('assign sequence %.0f cue %.0f /cmd="%s"', multiseq, template_num, "Some_command"))
				
				-- Label cue
				local handle = gma.show.getobj.handle(string.format('effect %.0f', template))
				local exists = gma.show.getobj.verify(handle)
				if exists == false then 
					BBL.error(string.format("ERROR in build_multiseq: Effect %.0f does not exist, cannot read name to assign label to cue.", template))
					error(string.format("ERROR in build_multiseq: Effect %.0f does not exist, cannot read name to assign label to cue.", template))
				end
				local template_name = gma.show.getobj.name(handle)
				template_name = BBL.split_string_into_array(template_name, " ")
				table.remove(template_name, #template_name)
				BBL.cmd(string.format('label sequence %.0f cue %.0f "%s"', multiseq, template_num, table.concat(template_name, " ")))
			end	
			BBL.cmd(string.format('delete cue %.0f thru sequence %.0f /o', #dim_templates + 1, multiseq))
			BBL.cmd("BlindEdit off")

			-- Label sequence and apply options
			local handle = gma.show.getobj.handle(string.format('group %.0f', group_num))
			local exists = gma.show.getobj.verify(handle)
			if exists == false then 
				BBL.error(string.format("ERROR in build_multiseq: Group %.0f does not exist, cannot read name to label multiseq.", group_num))
				error(string.format("ERROR in build_multiseq: Group %.0f does not exist, cannot read name to label multiseq.", group_num))
			end
			local group_name = gma.show.getobj.name(handle)
			group_name = BBL.split_string_into_array(group_name, " ")
			table.remove(group_name, #group_name)
			BBL.cmd(string.format('label sequence %.0f "%s (Dim Multi)"', multiseq, table.concat(group_name, " ")))
			BBL.cmd(string.format('assign sequence %.0f %s', multiseq, BBL.MULTISEQ_OPTIONS))
		end

		-- MOV
		if BBL.table_has_value(group_config.attribute_config, "2") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "3") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		end

		-- COLOR
		if BBL.table_has_value(group_config.attribute_config, "4") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "5") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		end

		-- GOBO
		if BBL.table_has_value(group_config.attribute_config, "6") then
			-- BBL.print(string.format("Group %s has attribute GOBO", group_num))
		end

		-- PRISM
		if BBL.table_has_value(group_config.attribute_config, "7") then
			-- BBL.print(string.format("Group %s has attribute PRISM", group_num))
		end

		-- ZOOM
		if BBL.table_has_value(group_config.attribute_config, "8") then
			-- BBL.print(string.format("Group %s has attribute ZOOM", group_num))
		end

		-- local multiseq = BBL.getvar(string.format("GROUP_%s__MULTISEQ", group))
		-- if multiseq == nil then
		-- 	multiseq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
		-- end
	end

	end)
	if success ~= true then
		BBL.print(string.format("ERROR in build_multiseqs: %s", err))
	end
end



local function build_pbg()
	local success, err = pcall(function()

	local gen_groups					= BBL.get_gen_groups()
	local dim_templates, gap_from_start = BBL.get_contigous_pool_items(BBL.EFFECT, BBL.FIRST_TEMPLATE_EFFECT)
	local mov_templates, gap_from_dim 	= BBL.get_contigous_pool_items(BBL.EFFECT, BBL.FIRST_TEMPLATE_EFFECT + #dim_templates + gap_from_start)

	-- Build PBG selection buttons
	local column_names = {"DIM_A", "DIM_B", "DIM_C", "DIM_D", "DIM_E"}--, "COL_A", "COL_B", "MOV_A", "MOV_B", "POS_A", "POS_B", "PRISM_A", "PRISM_B", "GOBO_A", "GOBO_B"}
	

	for _, group_num in ipairs(gen_groups) do
		local group_config = BBL.get_group_config(group_num)
		local row_offset = 106 + (group_num - BBL.FIRST_GROUP_TO_GENERATE_FROM) * 5
		
		-- DIM
		if BBL.table_has_value(group_config.attribute_config, "1") then
			---------------------------- Build PBG selection_buttons ----------------------------
			
			-- Check if multiseq already exists, if not, error
			local dim_multiseq = BBL.getvar(string.format("MULTISEQ_DIM_GROUP_%.0f", group_num))
			if dim_multiseq == nil then
				BBL.error(string.format("ERROR in build_pbg: Multisequence for group %.0f dimmer does not exists", group_num))
				error(string.format("ERROR in build_pbg: Multisequence for group %.0f dimmer does not exists", group_num))
			end

			-- Get multiseq cue names
			local sequence_handle = gma.show.getobj.handle(string.format("Sequence %.0f", dim_multiseq))
			local sequence_exists = gma.show.getobj.verify(sequence_handle)
			if sequence_exists == false then
				BBL.error(string.format("ERROR in build_pbg: Could not get handle of multisequence for group %.0f ", group_num))
				error(string.format("ERROR in build_pbg: Could not get handle of multisequence for group %.0f ", group_num))
			end
			local sequence_content = BBL.get_sequence_as_hashmap(dim_multiseq)
			
			----------------------------------------- Build PBG FRONTEND AND BACKEND -----------------------------------------
			local backend_page_offset = 3
			for col_num = 1, 5 do
				local column_name = column_names[col_num]
				-- Create PBA frontent button
				local pbg_frontend_button_sequence = BBL.getvar(string.format("PBG_G%.0f_%s_FRONTEND_SEQUENCE", group_num, column_name))
				if pbg_frontend_button_sequence == nil then
					pbg_frontend_button_sequence = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
					BBL.setvar(string.format("PBG_G%.0f_%s_FRONTEND_SEQUENCE", group_num, column_name), string.format('%.0f', pbg_frontend_button_sequence))
				end
				for cue_number, cue_name in pairs(sequence_content) do
					BBL.cmd(string.format('store sequence %.0f cue %s /o /nc', pbg_frontend_button_sequence, cue_number))
					BBL.cmd(string.format('label sequence %.0f cue %s "%s"', pbg_frontend_button_sequence, cue_number, cue_name))
					BBL.cmd(string.format('assign sequence %.0f cue %s /cmd="%s"', 
					pbg_frontend_button_sequence, cue_number, string.format('setuservar PBG_G%.0f_%s_ACTIVE %0.f', 
					group_num, column_name, cue_number)))
				end
				local cue_after_last_created_handle = gma.show.getobj.handle(string.format('sequence %.0f cue %.0f', pbg_frontend_button_sequence, BBL.get_hashmap_size(sequence_content) + 1))
				local cue_after_last_created_exists = gma.show.getobj.verify(cue_after_last_created_handle)
				if cue_after_last_created_exists == true then
					BBL.cmd(string.format('delete sequence %.0f cue %.0f thru /nc', pbg_frontend_button_sequence, BBL.get_hashmap_size(sequence_content) + 1))
				end

				
				local frontend_exec = string.format('%.0f.%.0f', BBL.PBG_FIRST_PAGE, row_offset + col_num - 1)
				BBL.cmd(string.format('assign sequence %.0f exec %s', pbg_frontend_button_sequence, frontend_exec))
				
				-- Apply frontend seq and exec options/labels
				BBL.cmd(string.format('label sequence %.0f "G%.0f - %s%s"', pbg_frontend_button_sequence, group_num, column_name:sub(1,1), column_name:sub(column_name:len(),column_name:len())))
				BBL.cmd(string.format('assign sequence %.0f %s', pbg_frontend_button_sequence, BBL.PBG_FRONTEND_SEQ_OPTIONS))
				BBL.cmd(string.format('assign %s exec %s', BBL.PBG_FRONTEND_BUTTON_TYPE, frontend_exec))
				BBL.cmd(string.format('assign exec %s %s', frontend_exec, BBL.PBG_FRONTEND_BUTTON_OPTIONS))

				-- Assign multiseq in PBG backend
				local backend_exec = string.format('%.0f.%.0f', BBL.PBG_FIRST_PAGE + backend_page_offset, row_offset + col_num - 1)
				BBL.cmd(string.format('Assign sequence %.0f exec %s', dim_multiseq, backend_exec))
				BBL.cmd(string.format('Assign %s exec %s', BBL.PBG_BACKEND_BUTTON_TYPE, backend_exec))
				BBL.cmd(string.format('Assign exec %s %s', backend_exec, BBL.PBG_BACKEND_BUTTON_OPTIONS))
				BBL.setvar(string.format("PBG_G%.0f_%s_BACKEND_EXEC", group_num, column_name), backend_exec)

				local cur_active = BBL.getvar(string.format("PBG_G%.0f_%s_ACTIVE", group_num, column_name))
				if cur_active == nil then
					cur_active = "1"
					BBL.setvar(string.format("PBG_G%.0f_%s_ACTIVE", group_num, column_name), cur_active)
				end

				BBL.cmd(string.format('go exec %s cue %s', frontend_exec, cur_active))
			end

		end

		-- MOV
		if BBL.table_has_value(group_config.attribute_config, "2") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "3") then
			-- BBL.print(string.format("Group %s has attribute MOV", group_num))
		end

		-- COLOR
		if BBL.table_has_value(group_config.attribute_config, "4") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		elseif BBL.table_has_value(group_config.attribute_config, "5") then
			-- BBL.print(string.format("Group %s has attribute COLOR", group_num))
		end

		-- GOBO
		if BBL.table_has_value(group_config.attribute_config, "6") then
			-- BBL.print(string.format("Group %s has attribute GOBO", group_num))
		end

		-- PRISM
		if BBL.table_has_value(group_config.attribute_config, "7") then
			-- BBL.print(string.format("Group %s has attribute PRISM", group_num))
		end

		-- ZOOM
		if BBL.table_has_value(group_config.attribute_config, "8") then
			-- BBL.print(string.format("Group %s has attribute ZOOM", group_num))
		end

		-- local multiseq = BBL.getvar(string.format("GROUP_%s__MULTISEQ", group))
		-- if multiseq == nil then
		-- 	multiseq = BBL.reserve_next_available_pool_item(BBL.SEQUENCE)
		-- end
	end

	----------------------------------------- Build PBG go buttons -----------------------------------------
	for col_num, col_name in ipairs(column_names) do
		
		-------------------------------- Get or create GO macro --------------------------------
		local go_macro = BBL.getvar(string.format("PBG_%s_GO_MACRO", col_name))
		if go_macro == nil then
			go_macro = BBL.reserve_next_available_pool_item(BBL.MACRO)
			BBL.setvar(string.format("PBG_%s_GO_MACRO", col_name), go_macro)
			BBL.cmd(string.format('store macro %0.f', go_macro))
		end
		
		
		-- ----------------------------------- Populate GO macro -----------------------------------
		local next_line_in_macro = 1

		for _, group_num in ipairs(gen_groups) do
			local target_exec = BBL.getvar(string.format("PBG_G%.0f_%s_BACKEND_EXEC", group_num, col_name))
			if target_exec == nil then
				-- Make sure that if the attributes of a group has been changed during use such that a multiseq no longer exists, then make sure to update the macro with empty commands
			else
				BBL.cmd(string.format('store macro 1.%.0f.%.0f ', go_macro, next_line_in_macro))
				BBL.cmd(string.format('assign macro 1.%.0f.%.0f /cmd="%s"', go_macro, next_line_in_macro, 
										string.format('off exec %s', target_exec)))
				
				next_line_in_macro = next_line_in_macro + 1
				BBL.cmd(string.format('store macro 1.%.0f.%.0f ', go_macro, next_line_in_macro))
				BBL.cmd(string.format('assign macro 1.%.0f.%.0f /cmd="%s"', go_macro, next_line_in_macro, 
										string.format('go exec %s cue $PBG_G%.0f_%s_ACTIVE', target_exec, group_num, col_name)))
				
				next_line_in_macro = next_line_in_macro + 1
			end

			-- Purge potential old outdated macro lines, but avoid a warning by making sure to create a new line if there actually are no next macro lines
			BBL.cmd(string.format('store macro 1.%.0f.%.0f ', go_macro, next_line_in_macro))
			BBL.cmd(string.format('delete macro 1.%.0f.%.0f thru', go_macro, next_line_in_macro))  

		end
		
		BBL.cmd(string.format('store macro 1.%.0f.%.0f ', go_macro, next_line_in_macro))
		BBL.cmd(string.format('assign macro 1.%.0f.%.0f /cmd="setuservar ACTIVE_COL_DIM = %s"', go_macro, next_line_in_macro, col_name))
		
		
		--------------------------------- Assign to PBG ---------------------------------
		BBL.cmd(string.format('assign macro %0.f exec %.0f.%.0f', go_macro, BBL.PBG_FIRST_PAGE, 100 + col_num))
	end

	--------------------------------- Go active col on load ---------------------------------
	-- TODO: Add handling for other column types
	BBL.add_to_var_nukelist("ACTIVE_COL_DIM")



	end)
	if success ~= true then
		BBL.error(string.format("ERROR in build_multiseqs: %s", err))
	end
end


local function initialize_variables()
	------- BBL.setvar("LEN_NUKELIST", "0")   THESE MUST BE INITIALIZED MANUALLY
	------- BBL.setvar("LEN_VAR_NUKE", "0")   THESE MUST BE INITIALIZED MANUALLY
	BBL.setvar("FIRST_AVAILABLE_GROUP", BBL.FIRST_AVAILABLE_GROUP)
	BBL.setvar("FIRST_TEMPLATE_EFFECT", BBL.FIRST_TEMPLATE_EFFECT)
	BBL.setvar("FIRST_SELECTIVE_EFFECT", BBL.FIRST_SELECTIVE_EFFECT)
	BBL.setvar("FIRST_AVAILABLE_SEQUENCE", BBL.FIRST_AVAILABLE_SEQUENCE)
	BBL.setvar("FIRST_AVAILABLE_MACRO", BBL.FIRST_AVAILABLE_MACRO)
	BBL.setvar("FIRST_PRESET_DIM", BBL.FIRST_PRESET_DIM)
	BBL.setvar("FIRST_PRESET_COLOR", BBL.FIRST_PRESET_COLOR)
	BBL.setvar("FIRST_PRESET_POS", BBL.FIRST_PRESET_POS)
	BBL.setvar("FIRST_PRESET_GOBO", BBL.FIRST_PRESET_GOBO)
	BBL.setvar("FIRST_PRESET_PRISM", BBL.FIRST_PRESET_PRISM)
	BBL.setvar("FIRST_REMOTE", BBL.FIRST_REMOTE)
	BBL.setvar("FIRST_REMOTE_FLIPPED", BBL.FIRST_REMOTE_FLIPPED)
	BBL.setvar("FIRST_EXEC", BBL.FIRST_EXEC)

	BBL.setvar("NEXT_AVAILABLE_GROUP", BBL.FIRST_AVAILABLE_GROUP)
	BBL.setvar("NEXT_AVAILABLE_EFFECT", BBL.FIRST_SELECTIVE_EFFECT)
	BBL.setvar("NEXT_AVAILABLE_SEQUENCE", BBL.FIRST_AVAILABLE_SEQUENCE)
	BBL.setvar("NEXT_AVAILABLE_MACRO", BBL.FIRST_AVAILABLE_MACRO)
	BBL.setvar("NEXT_AVAILABLE_REMOTE", BBL.FIRST_REMOTE)
	BBL.setvar("NEXT_AVAILABLE_REMOTE_FLIPPED", BBL.FIRST_REMOTE_FLIPPED)
	BBL.setvar("NEXT_AVAILABLE_EXEC", BBL.FIRST_EXEC)
	
	gma.user.setvar(BBL.SCRIPT_VARIABLES_INITIALIZED, "TRUE")
end


local function build_all()
	local success, err = pcall(function()

	local startTime = os.clock()
	build_all_is_running = true

	local vars_initialized = gma.user.getvar(BBL.SCRIPT_VARIABLES_INITIALIZED)
	if vars_initialized == nil or vars_initialized == "FALSE" then
		initialize_variables()
	end

	
	build_config_grid()
	local gen_groups = BBL.get_gen_groups()
	local group_config = {}
	for _, group_num in ipairs(gen_groups) do
		group_config = BBL.get_group_config(group_num)
		apply_group_config(group_config)
		BBL.store_group_config(group_config)
	end
	
	build_subgroups()
	build_selectives()
	build_pbg_multiseqs()
	build_pbg()

	-- Make sure to clear both programmers just in case
	BBL.cmd("BlindEdit on")
	BBL.cmd("ClearAll")
	BBL.cmd("BlindEdit off")
	BBL.cmd("ClearAll")
	BBL.print("Script finished successfully! :)")

	build_all_is_running = false

	-- table.insert(group_config.rigging_config, 2, "1")
	-- group_config.rigging_config[2] = "1"

	-- table.remove(group_config.rigging_config, 2)
	-- group_config.rigging_config[2] = nil

	local endTime = os.clock()
	BBL.print(string.format("Totalt build time: %.3f seconds", endTime - startTime))

	end)
	if success ~= true then
		BBL.error(string.format("ERROR in build_all: %s", err))
	end
end


local function update_all()
	build_selectives()
	build_multiseqs()
	build_pbg()
end


local function nuke_all()
	local success, err = pcall(function()

	local startTime = os.clock()

	-- Go through the nukelist and delete the contents
	local LEN_NUKELIST = BBL.getvar("LEN_NUKELIST")
	if LEN_NUKELIST == nil then
		BBL.error("ERROR in nuke_all for getting LEN_NUKELIST")
	elseif tonumber(LEN_NUKELIST) < 1 then
		BBL.print("Nukelist is empty, nothing to nuke :)")
	else
		for n = LEN_NUKELIST, 1, -1 do
			local item = BBL.getvar(string.format("NUKELIST_%d", n))
			BBL.cmd(string.format("Delete %s /nc", string.lower(item)))
			BBL.setvar("LEN_NUKELIST", string.format("%d", n - 1))
			BBL.cmd(string.format('SetUserVar NUKELIST_%d ""', n)) -- redundant, but I like it so that I can see if something goes wrong and an item doesn't get removed
		
			local deleted_item = BBL.split_string_into_array(item, " ")
			local deleted_type = string.upper(deleted_item[1])
			local deleted_number = deleted_item[2]
			if deleted_type == BBL.SEQUENCE then
				BBL.setvar(string.format("NEXT_AVAILABLE_%s", BBL.SEQUENCE), string.format("%s", deleted_number))
			elseif deleted_type == BBL.MACRO then
				BBL.setvar(string.format("NEXT_AVAILABLE_%s", BBL.MACRO), string.format("%s", deleted_number))
			elseif deleted_type == BBL.GROUP then
				BBL.setvar(string.format("NEXT_AVAILABLE_%s", BBL.GROUP), string.format("%s", deleted_number))
			elseif deleted_type == BBL.EFFECT then
				BBL.setvar(string.format("NEXT_AVAILABLE_%s", BBL.EFFECT), string.format("%s", deleted_number))
			elseif deleted_type == BBL.EXEC then
				BBL.setvar(string.format("NEXT_AVAILABLE_%s", BBL.EXEC), string.format("%s", deleted_number))
			else
				BBL.print(string.format("Requested to delete item of type: %s with number: %d but no logic for handling this type exists.", deleted_type, deleted_number))
			end
		end
	end	

	-- Delete variables used for nuking
	local len_var_nuke = BBL.getvar("LEN_VAR_NUKE")
	if len_var_nuke == nil then
		BBL.error("ERROR in nuke_all for getting LEN_VAR_NUKE")
	elseif tonumber(len_var_nuke) < 1 then
		BBL.print("Variable nukelist is empty, nothing to nuke :)")
	else
		for n = tonumber(len_var_nuke), 1, -1 do
			local var = BBL.getvar(string.format("VAR_NUKE_%s", n))
			BBL.cmd(string.format('setuservar %s ""', var))
			-- BBL.cmd(string.format('setuservar LEN_VAR_NUKE "%s"', n-1))
			BBL.setvar('LEN_VAR_NUKE', n-1)
			BBL.cmd(string.format('setuservar VAR_NUKE_%d ""', n))
		end
	end

	gma.user.setvar(BBL.SCRIPT_VARIABLES_INITIALIZED, "FALSE")


	-- Reset next available remote. This assumes that what is stored in the target exec is 
	-- nuked successfully by being added to the nukelist seperately from the reserve_next_available_remote method. 
	
	local endTime = os.clock()
	BBL.print(string.format("Total nuke time: %.3f seconds", endTime - startTime))


	end)
	if success ~= true then
		BBL.error(string.format("ERROR in nuke_all: %s", err))
	else
		BBL.print("Succesfully nuked file :)")
	end

end


--------------------------------------------------------------------
------------------------------- MAIN -------------------------------
--------------------------------------------------------------------


local function main(args_string)
	local success, err = pcall(function()

	local args = BBL.split_string_into_array(args_string, ",")
	
	if args[1] == "add_to_group_config" then
		BBL.add_to_group_config(args[2], args[3], args[4])
		return
	end
	if args[1] == "remove_from_group_config" then
		BBL.remove_from_group_config(args[2], args[3], args[4])
		return
	end

    local case = {
		build_all 							= build_all,
        nuke_all							= nuke_all,
		build_button 						= build_config_button,
		build_default_group_config_buttons	= build_config_grid,
		delete_group_config_variables		= BBL.delete_group_config_variables,
		build_selectives					= build_selectives,
		build_multiseqs						= build_multiseqs,
		build_pbg							= build_pbg,
		update_all							= update_all,
		reserve_next_available_remote		= BBL.reserve_next_available_remote,
		build_subgroups						= build_subgroups,
		initialize_variables				= initialize_variables
    }

	
    if case[string.lower(args[1])] then
        case[string.lower(args[1])]()
    else
        BBL.print("unknown action: " .. args[1])
    end

end)
if success ~= true then
	BBL.error(string.format("ERROR in main: %s", err))
end

BBL.print_error_log()
BBL.error_log = {}

end  


return main

