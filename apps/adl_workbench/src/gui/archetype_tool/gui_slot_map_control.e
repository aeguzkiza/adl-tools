note
	component:   "openEHR Archetype Project"
	description: "Slot map control - Visualise archetype ids matching slots"
	keywords:    "archetype, slot, gui"
	author:      "Thomas Beale"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2008-2012 Ocean Informatics Pty Ltd <http://www.oceaninfomatics.com>"
	license:     "See notice at bottom of class"

class GUI_SLOT_MAP_CONTROL

inherit
	GUI_ARCHETYPE_TARGETTED_TOOL
		redefine
			can_populate, can_repopulate
		end

	SHARED_ARCHETYPE_CATALOGUES
		export
			{NONE} all;
			{ANY} has_current_profile
		end

	STRING_UTILITIES
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialisation

	make (a_visual_update_action: PROCEDURE [ANY, TUPLE [INTEGER, INTEGER]])
		do
			-- create widgets
			create ev_root_container

			create ev_suppliers_tree
			create ev_clients_tree
			create supplier_frame
			create supplier_vbox
			create client_frame
			create client_vbox

			-- connect them together
			ev_root_container.extend (supplier_frame)
			supplier_frame.extend (supplier_vbox)
			supplier_vbox.extend (ev_suppliers_tree)
			ev_root_container.extend (client_frame)
			client_frame.extend (client_vbox)
			client_vbox.extend (ev_clients_tree)

			-- set visual characteristics
			ev_root_container.set_padding (Default_padding_width)
			ev_root_container.set_border_width (Default_border_width)
			supplier_frame.set_text (get_msg ("supplier_frame_text", Void))
			supplier_vbox.set_border_width (Default_border_width)
			client_frame.set_text (get_msg ("client_frame_text", Void))
			client_vbox.set_border_width (Default_border_width)

			visual_update_action := a_visual_update_action

			ev_root_container.set_data (Current)
		end

feature -- Access

	ev_root_container: EV_VERTICAL_BOX

	ev_suppliers_tree, ev_clients_tree: EV_TREE

feature -- Status Report

	can_populate (a_source: attached like source): BOOLEAN
		do
			Result := a_source.is_valid
		end

	can_repopulate: BOOLEAN
		do
			Result := is_populated and source.is_valid
		end

feature -- UI Feedback

	visual_update_action: PROCEDURE [ANY, TUPLE [INTEGER, INTEGER]]
			-- Called after processing each archetype (to perform GUI updates during processing).

feature {NONE} -- Implementation

	supplier_vbox, client_vbox: EV_VERTICAL_BOX

	supplier_frame, client_frame: EV_FRAME

	append_tree (subtree: attached EV_TREE_NODE_LIST; ids: attached ARRAYED_LIST [STRING])
			-- Populate `subtree' from `ids'.
		local
			eti: EV_TREE_ITEM
			ara: ARCH_CAT_ARCHETYPE
		do
			across ids as id_csr loop
				create eti.make_with_text (utf8_to_utf32 (id_csr.item))
				if current_arch_cat.archetype_index.has(id_csr.item) then
					ara := current_arch_cat.archetype_index.item (id_csr.item)
					eti.set_pixmap (get_icon_pixmap ("archetype/" + ara.group_name))
					eti.set_data (ara)
				end
				subtree.extend (eti)
			end
		ensure
			appended: subtree.count = old subtree.count + ids.count
		end

	do_clear
		do
			ev_suppliers_tree.wipe_out
			ev_clients_tree.wipe_out
			call_visual_update_action (0, 0)
		end

	do_populate
			-- populate the ADL tree control by creating it from scratch
		local
			eti: EV_TREE_ITEM
			slots_count: INTEGER
			used_by_count: INTEGER
		do
			if source.has_slots then
				across source.slot_id_index as slots_csr loop
					create eti.make_with_text (utf8_to_utf32 (source.differential_archetype.ontology.physical_to_logical_path (slots_csr.key, selected_language, True)))
					eti.set_pixmap (get_icon_pixmap ("am/added/archetype_slot"))
					ev_suppliers_tree.extend (eti)
					append_tree (eti, slots_csr.item)
					slots_count := slots_count + eti.count
					if eti.is_expandable then
						eti.expand
					end
				end
			end

			if current_arch_cat.compile_attempt_count < current_arch_cat.archetype_count then
				ev_clients_tree.extend (create {EV_TREE_ITEM}.make_with_text (get_msg_line ("slots_incomplete_w1", <<>>)))
			end

			if source.is_supplier then
				append_tree (ev_clients_tree, source.clients_index)
				used_by_count := used_by_count + ev_clients_tree.count
			end

			call_visual_update_action (slots_count, used_by_count)
		end

	call_visual_update_action (val1, val2: INTEGER)
			-- Call `visual_update_action', if it is attached.
		do
			if attached visual_update_action then
				visual_update_action.call ([val1, val2])
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
--| The Original Code is gui_slot_map_control.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2003-2011
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