indexing
	component:   "openEHR Archetype Project"
	description: "Initialisation of the main window's accelerator keys."
	keywords:    "test, ADL"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.biz>"
	copyright:   "Copyright (c) 2003-2007 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"

deferred class
	MAIN_WINDOW_ACCELERATORS

feature {NONE} -- Implementation

	accelerators: EV_ACCELERATOR_LIST
			-- Key combination shortcuts associated with the main window.
		deferred
		end

	add_menu_shortcut (menu_item: EV_MENU_ITEM; key: INTEGER; ctrl, shift: BOOLEAN)
			-- Create a keyboard shortcut for `menu_item', to execute `menu_item.select_actions'.
		require
			menu_item_attached: menu_item /= Void
			valid_key: (create {EV_KEY_CONSTANTS}).valid_key_code (key)
		do
			menu_item.set_text (menu_item.text + "%T" + shortcut_text (key, ctrl, shift))
			menu_item.select_actions.do_all (agent add_shortcut (?, key, ctrl, shift))
		end

	add_menu_shortcut_for_action (menu_item: EV_MENU_ITEM; action: PROCEDURE [ANY, TUPLE]; key: INTEGER; ctrl, shift: BOOLEAN)
			-- Create a keyboard shortcut for `menu_item', to execute `action' rather than `menu_item.select_actions'.
		require
			menu_item_attached: menu_item /= Void
			valid_key: (create {EV_KEY_CONSTANTS}).valid_key_code (key)
		do
			menu_item.set_text (menu_item.text + "%T" + shortcut_text (key, ctrl, shift))
			add_shortcut (action, key, ctrl, shift)
		end

	add_shortcut (action: PROCEDURE [ANY, TUPLE]; key: INTEGER; ctrl, shift: BOOLEAN)
			-- Create a keyboard shortcut to execute `action'.
		require
			action_attached: action /= Void
			valid_key: (create {EV_KEY_CONSTANTS}).valid_key_code (key)
		local
			accelerator: EV_ACCELERATOR
		do
			create accelerator.make_with_key_combination (create {EV_KEY}.make_with_code (key), ctrl, False, shift)
			accelerator.actions.extend (action)
			accelerators.extend (accelerator)
		ensure
			accelerators_extended: accelerators.count = 1 + old accelerators.count
		end

	shortcut_text (key: INTEGER; ctrl, shift: BOOLEAN): STRING
			-- Text describing a keyboard shortcut.
		require
			valid_key: (create {EV_KEY_CONSTANTS}).valid_key_code (key)
		local
			key_constants: EV_KEY_CONSTANTS
		do
			create key_constants
			Result := key_constants.key_strings [key]

			if Result.count = 1 then
				Result.to_upper
			end

			if shift then
				Result := key_constants.key_strings [{EV_KEY_CONSTANTS}.key_shift] + "+" + Result
			end

			if ctrl then
				Result := key_constants.key_strings [{EV_KEY_CONSTANTS}.key_ctrl] + "+" + Result
			end
		ensure
			attached: Result /= Void
			not_empty: not Result.is_empty
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
--| The Original Code is main_window.e.
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
