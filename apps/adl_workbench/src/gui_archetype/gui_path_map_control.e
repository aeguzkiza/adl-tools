note
	component:   "openEHR Archetype Project"
	description: "Path map control and logic"
	keywords:    "ADL"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.biz>"
	copyright:   "Copyright (c) 2006 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"


class GUI_PATH_MAP_CONTROL

inherit
	SHARED_KNOWLEDGE_REPOSITORY
		export
			{NONE} all;
			{ANY} has_current_profile
		end

	SHARED_APP_UI_RESOURCES
		export
			{NONE} all
		end

	EV_SHARED_APPLICATION
		export
			{NONE} all
		end

	STRING_UTILITIES
		export
			{NONE} all
		end

create
	make

feature -- Definitions

	path_control_filter_names: ARRAY [STRING]
			-- names of row filters of path control
		once
			Result := <<"All", "Leaf">>
		end

	path_control_column_names: ARRAY [STRING]
			-- names of columns of path view control
		once
			Result := <<"Machine", "Nat lang", "RM Type", "AOM Type">>
		end

feature {NONE} -- Initialisation

	make (a_main_window: attached MAIN_WINDOW)
			-- create tree control repersenting archetype files found in repository_path
		do
			gui := a_main_window
			path_list := gui.path_analysis_multi_column_list
			filter_combo := gui.path_analysis_row_filter_combo_box
			column_check_list := gui.path_analysis_column_view_checkable_list
		end

feature -- Access

	path_list: EV_MULTI_COLUMN_LIST

	filter_combo: EV_COMBO_BOX

	column_check_list: EV_CHECKABLE_LIST

feature -- Commands

	initialise_controls
			-- Initialise widgets associated with the Path Analysis.
		local
			filter_combo_index: INTEGER
			strs: LIST [STRING]
		do
			path_list.enable_multiple_selection
			filter_combo.set_strings (path_control_filter_names)

			if not filter_combo.is_empty then
				from
					filter_combo_index := 1
				until
					filter_combo_index > path_control_filter_names.count or
					path_control_filter_names [filter_combo_index].is_equal (path_filter_combo_selection)
				loop
					filter_combo_index := filter_combo_index + 1
				end

				if filter_combo_index > path_control_filter_names.count then -- non-existent string in session file
					filter_combo_index := 1
				end
			else
				filter_combo_index := 1
			end

			filter_combo [filter_combo_index].enable_select

			column_check_list.set_strings (path_control_column_names)
			strs := path_view_check_list_settings

			if not strs.is_empty then
				from column_check_list.start until column_check_list.off loop
					if strs.has (column_check_list.item.text.as_string_8) then
						column_check_list.check_item (column_check_list.item)
					end

					column_check_list.forth
				end
			else -- default to physical paths
				column_check_list.check_item (column_check_list [2])
				column_check_list.check_item (column_check_list [3])
			end
		end

	clear
			-- wipe out content from controls
		do
			path_list.wipe_out
		end

	populate
			-- Populate `path_list'.
		require
			has_current_profile
		local
			list_row: EV_MULTI_COLUMN_LIST_ROW
			p_paths, l_paths: ARRAYED_LIST[STRING]
		do
			path_list.wipe_out
			path_list.set_column_titles (path_control_column_names)

			-- Add am empty column at the end so the width of the true last column can be set to zero on all platforms.
			path_list.set_column_title ("", path_control_column_names.count + 1)

			if current_arch_cat.has_validated_selected_archetype then
				if filter_combo.text.is_equal ("All") then
					p_paths := target_archetype.physical_paths
					l_paths := target_archetype.logical_paths (current_language, False)
				else
					p_paths := target_archetype.physical_leaf_paths
					l_paths := target_archetype.logical_paths (current_language, True)
				end

				from
					p_paths.start
					l_paths.start
				until
					p_paths.off
				loop
					if attached {C_OBJECT} target_archetype.c_object_at_path (p_paths.item) as c_o then
						create list_row
						list_row.extend (utf8 (p_paths.item))
						list_row.extend (utf8 (l_paths.item))
						list_row.extend (utf8 (c_o.rm_type_name))
						list_row.extend (utf8 (c_o.generating_type))
						path_list.extend (list_row)
					end

					p_paths.forth
					l_paths.forth
				end
			end

			adjust_columns
		end

	adjust_columns
			-- Adjust column view of paths control according to `column_check_list'.
		local
			i: INTEGER
		do
			from i := 1 until i > path_list.column_count loop
				if i > column_check_list.count or else not column_check_list.is_item_checked (column_check_list [i]) then
					path_list.set_column_width (0, i)
				else
					path_list.resize_column_to_content (i)
					if path_list.column_width (i) < 100 then
						path_list.set_column_width (100, i)
					end
				end

				i := i + 1
			end
		end

	set_filter
			-- Called by `select_actions' of `filter_combo'.
		do
			if path_list.is_displayed then
				populate
			end
		end

	copy_path_to_clipboard
			-- copy a selected path row from the paths control to the OS clipboard
		local
			ev_rows: DYNAMIC_LIST[EV_MULTI_COLUMN_LIST_ROW]
			ev_col: EV_MULTI_COLUMN_LIST_ROW
			copy_text: STRING_32
		do
			ev_rows := path_list.selected_items
			create copy_text.make (0)

			if not ev_rows.is_empty then
				from ev_rows.start until ev_rows.off loop
					ev_col := ev_rows.item
					from ev_col.start until ev_col.off loop
						copy_text.append (ev_col.item.string + "%N")
						ev_col.forth
					end
					ev_rows.forth
				end
			end

			ev_application.clipboard.set_text (copy_text)
		end

feature {NONE} -- Implementation

	gui: MAIN_WINDOW
			-- main window of system

	target_archetype: ARCHETYPE
			-- differential or flat version of archetype, depending on setting of `differential_view'
		require
			current_arch_cat.has_selected_archetype
		do
			if differential_view then
				Result := current_arch_cat.selected_archetype.differential_archetype
			else
				Result := current_arch_cat.selected_archetype.flat_archetype
			end
		end

end


--|
--| ***** BEGIN LICENSE BLOCK *****
--| Version: MPL 1.1/GPL 2.0/LGPL 2.1
--|
--| The contents of this file are subject to the Mozilla Public License Version
--| 1.1 (the 'License'); you may not use this file except in compliance with
--| the License. You may obtain a copy of the License at
--| http://www.mozilla.org/MPL/
--|
--| Software distributed under the License is distributed on an 'AS IS' basis,
--| WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
--| for the specific language governing rights and limitations under the
--| License.
--|
--| The Original Code is adl_path_map.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2006
--| the Initial Developer. All Rights Reserved.
--|
--| Contributor(s):
--|
--| Alternatively, the contents of this file may be used under the terms of
--| either the GNU General Public License Version 2 or later (the 'GPL'), or
--| the GNU Lesser General Public License Version 2.1 or later (the 'LGPL'),
--| in which case the provisions of the GPL or the LGPL are applicable instead
--| of those above. If you wish to allow use of your version of this file only
--| under the terms of either the GPL or the LGPL, and not to allow others to
--| use your version of this file under the terms of the MPL, indicate your
--| decision by deleting the provisions above and replace them with the notice
--| and other provisions required by the GPL or the LGPL. If you do not delete
--| the provisions above, a recipient may use your version of this file under
--| the terms of any one of the MPL, the GPL or the LGPL.
--|
--| ***** END LICENSE BLOCK *****
--|