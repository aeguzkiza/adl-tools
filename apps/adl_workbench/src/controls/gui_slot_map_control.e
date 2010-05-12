note
	component:   "openEHR Archetype Project"
	description: "Slot map control - Visualise archetype ids matching slots"
	keywords:    "archetype, slot, gui"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.com>"
	copyright:   "Copyright (c) 2008 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL: http://www.openehr.org/svn/ref_impl_eiffel/TRUNK/apps/adl_workbench/src/controls/gui_slot_map_control.e $"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate: 2008-04-07 06:22:44 +0100 (Mon, 07 Apr 2008) $"

class GUI_SLOT_MAP_CONTROL

inherit
	SHARED_KNOWLEDGE_REPOSITORY
		export
			{NONE} all
		end

	SHARED_APPLICATION_CONTEXT
		export
			{NONE} all
		end

	SHARED_UI_RESOURCES
		export
			{NONE} all
		end

	STRING_UTILITIES
		export
			{NONE} all
		end

	SHARED_MESSAGE_DB
		export
			{NONE} all
		end

	EV_KEY_CONSTANTS
		export
			{NONE} all
		end

	EV_SHARED_APPLICATION
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialisation

	make (a_main_window: MAIN_WINDOW)
			-- Create to control `a_main_window.slots_tree' and `a_main_window.used_by_tree'.
		require
			a_main_window /= Void
		do
			gui := a_main_window
			gui.slots_tree.key_press_actions.force_extend (agent on_tree_key_press (gui.slots_tree, ?))
			gui.used_by_tree.key_press_actions.force_extend (agent on_tree_key_press (gui.used_by_tree, ?))
		ensure
			gui_set: gui = a_main_window
		end

feature -- Commands

	clear
		do
			gui.slots_tree.wipe_out
			gui.used_by_tree.wipe_out
			slots_count := 0
			used_by_count := 0
			update_slots_tab_label
		end

	populate
			-- populate the ADL tree control by creating it from scratch
		local
			eti: EV_TREE_ITEM
			ara: ARCH_REP_ARCHETYPE
			slots: HASH_TABLE [ARRAYED_LIST [STRING], STRING]
		do
			clear

			if arch_dir.has_selected_archetype then
				ara := arch_dir.selected_archetype

				if ara.has_slots then
					from
						slots := ara.slot_id_index
						slots.start
					until
						slots.off
					loop
						create eti.make_with_text (utf8 (ara.differential_archetype.ontology.physical_to_logical_path (slots.key_for_iteration, current_language)))
						eti.set_pixmap (pixmaps ["ARCHETYPE_SLOT"])
						gui.slots_tree.extend (eti)
						append_tree (eti, slots.item_for_iteration)
						slots_count := slots_count + eti.count

						if eti.is_expandable then
							eti.expand
						end

						slots.forth
					end
				end

				if arch_dir.parse_attempted_archetype_count < arch_dir.total_archetype_count then
					gui.used_by_tree.extend (create {EV_TREE_ITEM}.make_with_text (create_message ("slots_incomplete_w1", <<>>)))
				end

				if ara.is_used then
					append_tree (gui.used_by_tree, ara.used_by_index)
					used_by_count := used_by_count + gui.used_by_tree.count
				end

				update_slots_tab_label
			end
		end

feature -- Access

	slots_count: INTEGER
			-- Number of slots in the current archetype.

	used_by_count: INTEGER
			-- Number of archetypes that use the current archetype.

feature {NONE} -- Implementation

	gui: MAIN_WINDOW
			-- Main window of system.

	append_tree (subtree: EV_TREE_NODE_LIST; ids: ARRAYED_LIST [STRING])
			-- Populate `subtree' from `ids'.
		require
			subtree_attached: subtree /= Void
			ids_attached: ids /= Void
		local
			eti: EV_TREE_ITEM
			ara: ARCH_REP_ARCHETYPE
		do
			from
				ids.start
			until
				ids.off
			loop
				create eti.make_with_text (utf8 (ids.item))
				ara := arch_dir.archetype_index.item (ids.item)
				eti.set_pixmap (pixmaps [ara.group_name])
				eti.set_data (ara)
				eti.pointer_double_press_actions.force_extend (agent gui.select_archetype_from_gui_data (eti))
				subtree.extend (eti)
				ids.forth
			end
		ensure
			appended: subtree.count = old subtree.count + ids.count
		end

	update_slots_tab_label
			-- On the Slots tab, indicate the numbers of slots and used-by's.
		do
			gui.archetype_notebook.set_item_text (gui.slots_box, "Slots (" + slots_count.out + "/" + used_by_count.out + ")")
		end

	on_tree_key_press (tree: EV_TREE; key: EV_KEY)
			-- When the user presses Enter on an archetype, select it in the main window's explorer tree.
		do
			if not (ev_application.shift_pressed or ev_application.alt_pressed or ev_application.ctrl_pressed) then
				if key /= Void and then key.code = key_enter then
					gui.select_archetype_from_gui_data (tree.selected_item)
				end
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
--| The Original Code is adl_node_map_control.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2003-2004
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
