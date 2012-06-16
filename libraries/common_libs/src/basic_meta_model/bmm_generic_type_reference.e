note
	component:   "openEHR re-usable library"
	description: "Concept of a constraint on a type"
	keywords:    "model, UML"

	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.com>"
	copyright:   "Copyright (c) 2009 The openEHR Foundation <http://www.openEHR.org>"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"

class BMM_GENERIC_TYPE_REFERENCE

inherit
	BMM_TYPE_REFERENCE

create
	make

feature -- Initialisation

	make (a_root_type: BMM_CLASS_DEFINITION)
		do
			root_type := a_root_type
			create generic_parameters.make (0)
		end

feature -- Access

	root_type: attached BMM_CLASS_DEFINITION
			-- root type

	generic_parameters: attached ARRAYED_LIST [BMM_TYPE_SPECIFIER]
			-- generic parameters of the root_type in this type specifier
			-- The order must match the order of the owning class's formal generic parameter declarations

	flattened_type_list: attached ARRAYED_LIST [STRING]
			-- completely flattened list of type names, flattening out all generic parameters
			-- Note: can include repeats, e.g. HASH_TABLE [STRING, STRING] => HASH_TABLE, STRING, STRING
		do
			create Result.make(0)
			Result.compare_objects
			Result.extend (root_type.name)
			from generic_parameters.start until generic_parameters.off loop
				Result.append(generic_parameters.item.flattened_type_list)
				generic_parameters.forth
			end
		end

	type_category: STRING
			-- generate a type category of main target type from Type_cat_xx values
		local
			has_abstract_gen_parms: BOOLEAN
		do
			from generic_parameters.start until generic_parameters.off loop
				if not generic_parameters.item.type_category.is_equal (Type_cat_concrete_class) then
					has_abstract_gen_parms := True
				end
				generic_parameters.forth
			end
			if root_type.is_abstract and has_abstract_gen_parms then
				Result := Type_cat_abstract_class
			elseif has_type_substitutions then
				Result := Type_cat_concrete_class_supertype
			else
				Result := Type_cat_concrete_class
			end
		end

	type_substitutions: ARRAYED_SET [STRING]
			-- FIXME: just generate permutations of one generic parameter for now
		local
			root_sub_type_list, gen_param_sub_type_list: ARRAYED_SET [STRING]
		do
			root_sub_type_list := root_type.type_substitutions
			if root_sub_type_list.is_empty then
				root_sub_type_list.extend (root_type.name)
			end

			gen_param_sub_type_list := generic_parameters.first.type_substitutions
			if gen_param_sub_type_list.is_empty then
				gen_param_sub_type_list.extend (generic_parameters.first.as_type_string)
			end

			create Result.make (0)
			from root_sub_type_list.start until root_sub_type_list.off loop
				from gen_param_sub_type_list.start until gen_param_sub_type_list.off loop
					Result.extend (root_sub_type_list.item + generic_left_delim.out + gen_param_sub_type_list.item + generic_right_delim.out)
					gen_param_sub_type_list.forth
				end
				root_sub_type_list.forth
			end
		end

feature -- Status Report

	has_type_substitutions: BOOLEAN
		do
			Result := root_type.has_type_substitutions or generic_parameters.first.has_type_substitutions
		end

feature -- Modification

	add_generic_parameter (a_gen_parm: attached BMM_TYPE_SPECIFIER)
		do
			generic_parameters.extend (a_gen_parm)
		end

feature -- Output

	as_type_string: STRING
			-- full name of the type including generic parameters
		do
			create Result.make_empty
			Result.append (root_type.name)
			Result.append_character (Generic_left_delim)
			from generic_parameters.start until generic_parameters.off loop
				Result.append (generic_parameters.item.as_type_string)
				if not generic_parameters.islast then
					Result.append_character (generic_separator)
				end
				generic_parameters.forth
			end
			Result.append_character (Generic_right_delim)
		end

	as_flattened_type_string: STRING
		do
			Result := as_type_string
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
--| The Original Code is bmm_model.e.
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
