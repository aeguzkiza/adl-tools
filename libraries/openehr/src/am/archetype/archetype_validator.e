indexing
	component:   "openEHR Archetype Project"
	description: "[
				 Validator of standalone archetype (i.e. without reference to parent archetypes
				 in the case of specialised archetypes). The validation done here checks the use
				 of codes defined in the ontology against their use in the definition of the 
				 archetype.
		         ]"
	keywords:    "constraint model"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.biz>"
	copyright:   "Copyright (c) 2007 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"

class ARCHETYPE_VALIDATOR

inherit
	AUTHORED_RESOURCE_VALIDATOR
		redefine
			target, validate
		end

	ARCHETYPE_TERM_CODE_TOOLS
		export
			{NONE} all
		end

create
	make

feature -- Access

	target: ARCHETYPE
			-- differential archetype

	ontology: ARCHETYPE_ONTOLOGY is
			-- the ontology of the current archetype
		do
			Result := target.ontology
		end

feature -- Validation

	validate is
		do
			passed := True

			validate_basics

			if passed then
				target.build_xrefs
				find_unused_ontology_codes
				validate_codes
				validate_internal_references
			end

			if passed then
				precursor
				validate_languages
				check_unidentified_nodes
				warnings.append(unidentified_node_finder.warnings)
			end

			if passed then
				-- look for paths that are not at the same level as the specialisation level of the archetype
				validate_paths
				if target.is_specialised then
					-- mark nodes with rolled up status due to inheritance, so that copied subtrees can be found and deleted
					target.build_rolled_up_status
				end
			end
		end

feature {NONE} -- Implementation

	unidentified_node_finder: C_UNIDENTIFIED_NODE_CHECKER
			-- C_OBJECT structure visitor that finds nodes that should have at-code
			-- identifiers on them

	validate_basics is
			-- are basic features of archetype structurally intact and correct?
			-- into account validity with respect to parent archetypes.
		do
			passed := False
			if target.archetype_id = Void then
				errors.append("No archetype_id%N")
			elseif target.definition = Void then
				errors.append("No definition%N")
			elseif target.invariants /= Void and target.invariants.is_empty then
				errors.append("invariants cannot be empty if specified")
			elseif ontology = Void then
				errors.append("No ontology%N")
			elseif not target.definition.rm_type_name.is_equal (target.archetype_id.rm_entity) then
				errors.append("Archetype id type %"" + target.archetype_id.rm_entity +
								"%" does not match type %"" + target.definition.rm_type_name +
								"%" in definition section%N")
			elseif specialisation_depth_from_code (target.concept) /= target.specialisation_depth then
				errors.append("Specialisation depth of concept (root) code is incorrect - should be " + target.specialisation_depth.out + "%N")
			elseif not target.definition.node_id.is_equal(target.concept) then
				errors.append("Concept code " + target.concept + " not used in definition%N")
			elseif not target.definition.is_valid then
				-- FIXME - need to check definition validation; possibly this should be
				-- done using another visitor pattern?
				errors.append(target.definition.invalid_reason + "%N")
			else
				passed := True
			end
		end

	validate_languages is
			-- check to see that all linguistic items in ontology, description, etc
			-- are all coherent
		do
			-- is languages_available list same as languages in description.details?

			-- is languages_available list same as languages in ontology?
		end

	validate_codes is
			-- True if all found node_ids are defined in term_definitions,
			-- and term_definitions contains no extras
		local
			a_codes: HASH_TABLE[ARRAYED_LIST[C_OBJECT], STRING]
		do
			-- see if all found codes are in each language table
			a_codes := target.id_at_codes_xref_table
			from
				a_codes.start
			until
				a_codes.off
			loop
				if not ontology.has_term_code(a_codes.key_for_iteration) then
					passed := False
					errors.append("Node id at-code " + a_codes.key_for_iteration + " not defined in ontology%N")
				end
				a_codes.forth
			end

			-- see if every found leaf term code (in an ORDINAL or a CODED_TERM) is in ontology
			a_codes := target.data_at_codes_xref_table
			from
				a_codes.start
			until
				a_codes.off
			loop
				if not ontology.has_term_code(a_codes.key_for_iteration) then
					passed := False
					errors.append("Leaf at-code " + a_codes.key_for_iteration + " not defined in ontology%N")
				end
				a_codes.forth
			end

			-- check if all found constraint_codes are defined in constraint_definitions,
			a_codes := target.ac_codes_xref_table
			from
				a_codes.start
			until
				a_codes.off
			loop
				if not ontology.has_constraint_code(a_codes.key_for_iteration) then
					passed := False
					errors.append("Found ac-code " + a_codes.key_for_iteration + " not defined in all languages in ontology%N")
				end
				a_codes.forth
			end
		end

	validate_internal_references is
			-- validate items in `found_internal_references'
		local
			use_refs: HASH_TABLE[ARRAYED_LIST[ARCHETYPE_INTERNAL_REF], STRING]
		do
			use_refs := target.use_node_path_xref_table
			from
				use_refs.start
			until
				use_refs.off
			loop
				if not target.definition.has_path(use_refs.key_for_iteration) then
					passed := False
					errors.append("Error: path " + use_refs.key_for_iteration + " not found in archetype%N")
				end
				use_refs.forth
			end
		end

	validate_paths is
			-- find paths that are not of the level of the archetype
		local
			path_analyser: ARCHETYPE_PATH_ANALYSER
			path_list: ARRAYED_LIST [STRING]
			err_str: STRING
		do
			create path_analyser
			path_list := target.physical_paths
			from
				path_list.start
			until
				path_list.off
			loop
				path_analyser.set_from_string(path_list.item)
				if path_analyser.level /= target.specialisation_depth then
					err_str := "specialisation depth of path " + path_list.item + " " + path_analyser.level.out +
						" differs from archetype (" + target.specialisation_depth.out + ")%N"
					if strict then
						passed := False
						errors.append("Error: " + err_str)
					else
						warnings.append("Warning: " + err_str)
					end
				end
				path_list.forth
			end
		end

	find_unused_ontology_codes is
			-- populate lists of at-codes and ac-codes found in ontology that
			-- are not referenced anywhere in the archetype definition
		do
			from
				ontology.term_codes.start
			until
				ontology.term_codes.off
			loop
				if not target.id_at_codes_xref_table.has(ontology.term_codes.item) and not
						target.data_at_codes_xref_table.has(ontology.term_codes.item) then
					target.ontology_unused_term_codes.extend(ontology.term_codes.item)
					warnings.append("Term code " + ontology.term_codes.item + " in ontology not used in archetype definition%N")
				end
				ontology.term_codes.forth
			end
			target.ontology_unused_term_codes.prune(target.concept)

			from
				ontology.constraint_codes.start
			until
				ontology.constraint_codes.off
			loop
				if not target.ac_codes_xref_table.has(ontology.constraint_codes.item) then
					target.ontology_unused_constraint_codes.extend(ontology.constraint_codes.item)
					warnings.append("Constraint code " + ontology.constraint_codes.item + " in ontology not used in archetype definition%N")
				end
				ontology.constraint_codes.forth
			end
		end

	check_unidentified_nodes is
			-- look for attributes that are either multiple or have multiple alternatives, whose
			-- child objects are not identified, but only if the children are not C_PRIMITIVEs or
			-- C_C_Os whose values are C_PRMITIVEs. Record any such nodes as warnings
		local
			a_c_iterator: C_VISITOR_ITERATOR
		do
			create unidentified_node_finder
			unidentified_node_finder.initialise(ontology)
			create a_c_iterator.make(target.definition, unidentified_node_finder)
			a_c_iterator.do_all
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
--| The Original Code is archetype_local_validator.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2007
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
