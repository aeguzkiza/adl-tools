note
	component:   "openEHR ADL Tools"
	description: "UI visualisation node for any kind of C_OBJECT"
	keywords:    "archetype, editing"
	author:      "Thomas Beale <thomas.beale@oceaninformatics.com>"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2012- Ocean Informatics Pty Ltd <http://www.oceaninfomatics.com>"
	license:     "Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>"

deferred class C_OBJECT_UI_NODE

inherit
	ARCHETYPE_CONSTRAINT_UI_NODE
		rename
			rm_element as rm_type
		redefine
			make, rm_type, arch_node, arch_node_in_ancestor, parent, prepare_display_in_grid, display_in_grid
		end

feature -- Definition

	c_object_colours: HASH_TABLE [EV_COLOR, INTEGER]
			-- foreground colours for RM type representing inheritance status
		once
			create Result.make(0)
			Result.put (archetype_rm_type_color, ss_added)
			Result.put (archetype_rm_type_redefined_color, ss_redefined)
			Result.put (archetype_rm_type_inherited_color, ss_inherited)
		end

feature -- Initialisation

	make (an_arch_node: attached like arch_node; an_ed_context: ARCHETYPE_UI_GRAPH_STATE)
		do
			create internal_ref_for_rm_type.make (0)
			precursor (an_arch_node, an_ed_context)
			set_arch_node_in_ancestor
			rm_type := ui_graph_state.rm_schema.create_bmm_type_from_name (arch_node.rm_type_name)
		end

feature -- Access

	arch_node: detachable C_OBJECT
			-- archetype node being edited

	arch_node_in_ancestor: detachable C_OBJECT
			-- corresponding archetype node in specialisation parent, if applicable

	rm_type: BMM_TYPE
			-- RM class of node being edited

	parent: detachable C_ATTRIBUTE_UI_NODE

	path: STRING
			-- path of this node with respect to top of archetype
		do
			if attached arch_node as an then
				Result := an.path
			else
				Result := parent.path
			end
		end

	rm_depth: INTEGER
			-- depth of this node with respect to its top-most RM (non-constrained) node
			-- note that this will always be intermediate in the structure, since it has
			-- to be the child of some archetyped node
		do
			Result := parent.rm_depth + 1
		end

feature -- Display

	prepare_display_in_grid (a_gui_grid: EVX_GRID)
		local
			visualise_descendants_class: detachable STRING
		do
			precursor (a_gui_grid)
			if not is_rm and attached ev_grid_row as gr then
				a_gui_grid.set_last_row_label_col (Definition_grid_col_rm_name, "", Void, Void, Void, c_pixmap)

				-- add 'power expander' action to logical C_OBJECT leaf nodes
				if attached ui_graph_state.rm_schema.archetype_parent_class as apc then
					visualise_descendants_class := apc
				elseif attached ui_graph_state.rm_schema.archetype_visualise_descendants_of as avdo then
					visualise_descendants_class := avdo
				end
				if attached visualise_descendants_class as vdc and then ui_graph_state.rm_schema.is_descendant_of (arch_node.rm_type_name, vdc) then
					gr.expand_actions.force_extend (agent power_expand)
				end

				-- attach any other node level agents (redefine in descendants)
				attach_other_ui_node_agents
			else
				evx_grid.set_last_row_label_col (Definition_grid_col_rm_name, rm_type_text, path, Void, parent.rm_attribute_colour,
					rm_type_pixmap (rm_type))
			end
			evx_grid.set_last_row_label_col (Definition_grid_col_meaning, "", Void, Void, Void, Void)

			-- add context menu
			build_context_menu
			evx_grid.add_last_row_pointer_button_press_actions (Definition_grid_col_rm_name, agent context_menu_event_handler)
		end

	display_in_grid (ui_settings: GUI_DEFINITION_SETTINGS)
		local
			s: STRING
			c_occ_colour: EV_COLOR
		do
			precursor (ui_settings)

			if attached arch_node as a_n then
				-- RM name & meaning columns
				if display_settings.show_technical_view then
					evx_grid.update_last_row_label_col (Definition_grid_col_rm_name, a_n.rm_type_name, node_tooltip_str, c_node_font, c_object_colour, c_pixmap)
					evx_grid.update_last_row_label_col (Definition_grid_col_meaning, node_id_text, node_tooltip_str, c_node_font, c_meaning_colour, Void)
		 		else
					evx_grid.update_last_row_label_col (Definition_grid_col_rm_name, node_id_text, node_tooltip_str, c_node_font, c_object_colour, c_pixmap)
					evx_grid.update_last_row_label_col (Definition_grid_col_meaning, "", Void, Void, Void, Void)
				end

				-- card/occ column
				create s.make_empty
				c_occ_colour := c_constraint_colour
				if attached a_n.occurrences as att_occ then
					if not att_occ.is_prohibited then
						s.append (att_occ.as_string)
					else
						s.append (get_text (ec_occurrences_removed_text))
					end
				elseif not ui_graph_state.in_differential_view and display_settings.show_rm_multiplicities and not is_root then
					check attached a_n.parent as att_ca then
						s := att_ca.default_child_occurrences.as_string
						c_occ_colour := c_attribute_colour
					end
				end
				evx_grid.set_last_row_label_col (Definition_grid_col_card_occ, s, Void, Void, c_occ_colour, Void)

				-- constraint column
				display_constraint

				-- sibling order column
				if ui_graph_state.in_differential_view and then attached a_n.sibling_order then
					create s.make_empty
					if a_n.sibling_order.is_after then
						s.append ("after")
					else
						s.append ("before")
					end
					s.append ("%N" + local_term_string (a_n.sibling_order.sibling_node_id))
					evx_grid.set_last_row_label_col_multi_line (Definition_grid_col_sibling_order, s, Void, Void, c_constraint_colour, Void)
				end
			end
		end

feature -- Modification

	do_remove
			-- remove this node from its parent
			-- with UNDO/REDO
		do
			parent.remove_child (Current)
			ui_graph_state.undo_redo_chain.add_link_simple (evx_grid.ev_grid,
				agent parent.add_child (Current),
				agent parent.remove_child (Current))
		end

	do_convert_to_constraint (co_create_params: C_OBJECT_PROPERTIES)
			-- convert this RM node to a constraint node under its attribute node. We do this
			-- by removing the current node then doing a new node add; this is consistent with
			-- when an 'add new node' request is done on an attribute node, which always requires an 'add'
			-- The steps here are:
			-- 	* convert parent attr context node to constraint form
			-- 	* remove this RM object node from parent
			--	* create and add a new archetype node & object context node to parent
			-- with UNDO/REDO
		require
			is_rm
		local
			added_child: C_OBJECT_UI_NODE
		do
			parent.remove_child (Current)
			if parent.is_rm then
				parent.convert_to_constraint
			end
			parent.add_new_arch_child (co_create_params)
			added_child := parent.children.last

			-- set up undo / redo
			ui_graph_state.undo_redo_chain.add_link_simple (evx_grid.ev_grid,
				agent (an_orig_child, an_added_child: C_OBJECT_UI_NODE)
						-- undo
					do
						parent.remove_child (an_added_child)
						if not parent.has_constraint_children then
							parent.convert_to_rm
						end
						parent.add_child (an_orig_child)
					end (Current, added_child),
				agent (an_orig_child, an_added_child: C_OBJECT_UI_NODE)
						-- redo
					do
						parent.remove_child (an_orig_child)
						if parent.is_rm then
							parent.convert_to_constraint
						end
						parent.add_child (an_added_child)
					end (Current, added_child)
			)
		ensure
			Current_removed_from_parent: not parent.has_child (Current)
		end

	do_refine_constraint (co_create_params: C_OBJECT_PROPERTIES)
			-- refine this Archetye node
		require
			is_specialised and not is_rm
		local
			new_occ: MULTIPLICITY_INTERVAL
		do
			if attached arch_node as a_n and then co_create_params.aom_type.same_string (a_n.generator) then
				-- RM type
				if not a_n.rm_type_name.same_string (co_create_params.rm_type) then
					a_n.set_rm_type_name (co_create_params.rm_type)
					a_n.set_specialisation_status_redefined
				end

				-- occurences
				new_occ := create {MULTIPLICITY_INTERVAL}.make_from_string (co_create_params.occurrences)
				if attached a_n.occurrences as occ and then not
					occ.is_equal (create {MULTIPLICITY_INTERVAL}.make_from_string (co_create_params.occurrences))
				then
					a_n.set_occurrences (new_occ)
					a_n.set_specialisation_status_redefined
				end

				-- node id
				if not co_create_params.node_id_text.same_string (ui_graph_state.flat_terminology.term_definition (display_settings.language, a_n.node_id).text) then
					ui_graph_state.flat_terminology.replace_term_definition_item (display_settings.language, a_n.node_id, {ARCHETYPE_TERM}.text_key, co_create_params.node_id_text)
				end
				if not co_create_params.node_id_description.same_string (ui_graph_state.flat_terminology.term_definition (display_settings.language, a_n.node_id).description) then
					ui_graph_state.flat_terminology.replace_term_definition_item (display_settings.language, a_n.node_id, {ARCHETYPE_TERM}.description_key, co_create_params.node_id_description)
				end
			else -- need to do a remove and add

			end
			-- set up undo / redo
--			ed_context.undo_redo_chain.add_link_simple (evx_grid.ev_grid,
--				agent (an_orig_child, an_added_child: C_OBJECT_ED_CONTEXT)
--						-- undo
--					do
--						parent.remove_child (an_added_child)
--						if not parent.has_constraint_children then
--							parent.convert_to_rm
--						end
--						parent.add_child (an_orig_child)
--					end (Current, added_child),
--				agent (an_orig_child, an_added_child: C_OBJECT_ED_CONTEXT)
--						-- redo
--					do
--						parent.remove_child (an_orig_child)
--						if parent.is_rm then
--							parent.convert_to_constraint
--						end
--						parent.add_child (an_added_child)
--					end (Current, added_child)
--			)
		end

feature {NONE} -- Implementation

	display_constraint
		do
		end

	node_id_text: STRING
			-- show node_id text either as just rubric, or as node_id|rubric|, depending on `show_codes' setting
		local
			node_id_str: STRING
		do
			if attached arch_node as a_n then
				if is_id_code (a_n.node_id) then
					if ui_graph_state.flat_terminology.has_id_code (a_n.node_id) then
						node_id_str := ui_graph_state.flat_terminology.term_definition (display_settings.language, a_n.node_id).text
						if display_settings.show_codes then
							Result := annotated_code (a_n.node_id, node_id_str, " ")
						else
							Result := node_id_str
						end
					elseif display_settings.show_codes then
						Result := a_n.node_id
					else
						create Result.make_empty
					end
				else -- it must be an archetype id in a template structure
					if display_settings.show_technical_view then
						Result := a_n.node_id
					else
						Result := (create {ARCHETYPE_HRID}.make_from_string (a_n.node_id)).concept_id
					end
				end
			else
				create Result.make_empty
			end
		end

	rm_type_text: STRING
		do
			Result := rm_type.base_class.name
		end

	c_object_colour: EV_COLOR
			-- generate a foreground colour for RM type representing inheritance status
		local
			spec_sts: INTEGER
		do
			if display_settings.show_rm_inheritance then
				if ev_grid_row.is_expandable and not ev_grid_row.is_expanded then
					spec_sts := rolled_up_specialisation_status
				else
					spec_sts := specialisation_status
				end
				check attached c_object_colours.item (spec_sts) as obj_col then
					Result := obj_col
				end
			else
				Result := archetype_rm_type_color
			end
		end

	c_pixmap: EV_PIXMAP
			-- find a pixmap for any C_OBJECT node
		local
			pixmap_key, c_type_occ_str: STRING
		do
			create pixmap_key.make_empty
			if attached arch_node as a_n then
				if use_rm_pixmaps then
					pixmap_key := rm_type_pixmap_key (rm_type.base_class)
				end

				if pixmap_key.is_empty then
					c_type_occ_str := a_n.generating_type + a_n.occurrences_key_string
					if has_icon_pixmap (c_type_occ_str) then
						pixmap_key := Icon_am_dir + resource_path_separator + "added" + resource_path_separator + c_type_occ_str
					else
						pixmap_key := Icon_am_dir  + resource_path_separator + "added" + resource_path_separator + a_n.generating_type
					end
				end

				Result := get_icon_pixmap (pixmap_key)
			else
				create Result.default_create
			end
		end

feature {NONE} -- Context menu

	context_menu_event_handler (x,y, button: INTEGER)
			-- creates the context menu for a right click action for class node
		do
			if button = {EV_POINTER_CONSTANTS}.right then
				ev_grid_row.item (1).enable_select
				context_menu.show
			end
		end

	context_menu: detachable EV_MENU

	build_context_menu
			-- create context menu
		local
			an_mi: EV_MENU_ITEM
		do
			create context_menu
			create an_mi.make_with_text_and_action (get_msg (ec_display_class, Void), agent display_context_selected_class_in_new_tool (rm_type.base_class))
			an_mi.set_pixmap (get_icon_pixmap ("tool/class_tool_new"))
			context_menu.extend (an_mi)

			if attached arch_node as a_n then
				-- if this node is addressable, add menu item to show node_id in terminology
				create an_mi.make_with_text_and_action (get_text (ec_menu_option_display_code),
					agent (node_id_str: STRING)
						do
							tool_agents.id_code_select_action_agent.call ([node_id_str])
						end (a_n.node_id)
				)
				context_menu.extend (an_mi)
			end

			if not ui_graph_state.editing_enabled then
				-- add menu item for displaying path in path map
				if attached arch_node as a_n and attached tool_agents.path_select_action_agent then
					create an_mi.make_with_text_and_action (get_text (ec_object_context_menu_display_path),
						agent (path_str: STRING)
							do
								tool_agents.path_select_action_agent.call ([path_str])
							end (a_n.path)
					)
					context_menu.extend (an_mi)
				end
			else
				if attached arch_node as a_n then
					if not a_n.is_root then
						if a_n.specialisation_status /= ss_added then
							-- add menu item to refine constraint
							create an_mi.make_with_text_and_action (get_text (ec_object_context_menu_refine), agent ui_offer_refine_constraint)
							context_menu.extend (an_mi)
						else
							-- add menu item for deleting this node
							create an_mi.make_with_text_and_action (get_text (ec_object_context_menu_delete), agent do_remove)
							context_menu.extend (an_mi)
						end
					end
				elseif not is_root and then not parent.parent.is_rm and parent.is_rm then
					-- add menu item for 'convert to constraint'
					create an_mi.make_with_text_and_action (get_text (ec_object_context_menu_convert), agent ui_offer_convert_to_constraint)
					context_menu.extend (an_mi)
				end
			end
		end

	display_context_selected_class_in_new_tool (a_class_def: BMM_CLASS)
		do
			gui_agents.select_class_in_new_tool_agent.call ([a_class_def])
		end

	ui_offer_refine_constraint
			-- create a dialog with appropriate constraint capture fields and then call the convert_to_constraint routine
		local
			dialog: GUI_C_OBJECT_DIALOG
			rm_type_substitutions: ARRAYED_SET [STRING]
			spec_parent_rm_class: BMM_CLASS
			def_occ: MULTIPLICITY_INTERVAL
			a_term: ARCHETYPE_TERM
		do
			if attached arch_node_in_ancestor as parent_a_n then
				spec_parent_rm_class := ui_graph_state.rm_schema.class_definition (parent_a_n.rm_type_name)
				rm_type_substitutions := spec_parent_rm_class.all_descendants.deep_twin
				rm_type_substitutions.extend (rm_type.base_class.name)

				if attached parent_a_n.occurrences as parent_a_n_occ then
					def_occ := parent_a_n_occ
				else
					def_occ := parent.default_occurrences
				end

				create dialog.make (aom_types_for_rm_type (spec_parent_rm_class), rm_type_substitutions, arch_node_aom_type, rm_type.base_class.name,
					def_occ, ui_graph_state.archetype, display_settings)

				if attached arch_node as a_n and then is_valid_code (a_n.node_id) then
					a_term := ui_graph_state.flat_terminology.term_definition (display_settings.language, a_n.node_id)
					dialog.set_term (a_term.text, a_term.description)
				end

				dialog.show_modal_to_window (proximate_ev_window (evx_grid.ev_grid))
				if dialog.is_valid then
					do_refine_constraint (dialog.new_params)
				end
			end
		end

	ui_offer_convert_to_constraint
			-- create a dialog with appropriate constraint capture fields and then call the refine_constraint routine
		local
			dialog: GUI_C_OBJECT_DIALOG
			rm_type_substitutions: ARRAYED_SET [STRING]
		do
			rm_type_substitutions := rm_type.base_class.all_descendants.deep_twin
			rm_type_substitutions.extend (rm_type.base_class.name)
			create dialog.make (aom_types_for_rm_type (rm_type), rm_type_substitutions, arch_node_aom_type, rm_type.base_class.name,
				parent.default_occurrences, ui_graph_state.archetype, display_settings)
			dialog.show_modal_to_window (proximate_ev_window (evx_grid.ev_grid))
			if dialog.is_valid then
				do_convert_to_constraint (dialog.new_params)
			end
		end

	set_arch_node_in_ancestor
			-- set corresponding archetype node in specialisation parent, if applicable
		local
			apa: ARCHETYPE_PATH_ANALYSER
			co_path_in_flat: STRING
		do
			if attached arch_node as a_n and attached ui_graph_state.parent_archetype as parent_arch then
				create apa.make (a_n.og_path)
				if not apa.is_phantom_path_at_level (parent_arch.specialisation_depth) then
					co_path_in_flat := apa.path_at_level (parent_arch.specialisation_depth)
					if parent_arch.has_object_path (co_path_in_flat) then
						arch_node_in_ancestor := parent_arch.object_at_path (co_path_in_flat)
					end
				end
			end
		end

	power_expand
			-- agent to expand to bottom from a node, and redisplay it, to recolour it properly
		do
			if attached ev_grid_row as gr then
				evx_grid.ev_grid.expand_tree (gr,
					agent (a_row: EV_GRID_ROW): BOOLEAN
						do
							if attached {ARCHETYPE_CONSTRAINT_UI_NODE} a_row.data as ac_ui_node then
								Result := attached ac_ui_node.arch_node
							end
						end
				)
				display_in_grid (display_settings)
			end
		end

	attach_other_ui_node_agents
		do

		end

invariant
	Child_relationship_validity: attached arch_node as a_n implies (attached parent as p implies (p.arch_node.has_child (a_n)))

end


