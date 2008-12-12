indexing
	component:   "openEHR Archetype Project"
	description: "Descriptor of a folder in a directory of archetypes"
	keywords:    "ADL, archetype"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.biz>"
	copyright:   "Copyright (c) 2006 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"


class ARCHETYPE_REPOSITORY_FOLDER

inherit
	ARCHETYPE_REPOSITORY_ITEM

create
	make

feature -- Access

	base_name: STRING
			-- name of last segment of path - i.e. local dir name or else file-name

feature {NONE} -- Implementation

	make_ontological_paths is
			-- make ontological_path and ontological_parent_path
		local
			pos: INTEGER
		do
			ontological_path := full_path.substring (root_path.count + 1, full_path.count)

			create ontological_parent_path.make(0)
			if not ontological_path.is_empty then
				pos := ontological_path.last_index_of(os_directory_separator, ontological_path.count)
			end
			if pos > 0 then
				ontological_parent_path.append(ontological_path.substring (1, pos - 1))
			end

			if not ontological_path.is_empty then
				pos := ontological_path.last_index_of(os_directory_separator, ontological_path.count)
			end
			if pos > 0 then
				base_name := ontological_path.substring(pos+1, ontological_path.count)
			else
				base_name := ontological_path.twin
			end
		end

invariant
	base_name_attached: base_name /= Void

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
--| The Original Code is archetype_directory_item.e.
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