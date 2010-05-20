note
	component:   "openEHR Archetype Project"
	description: "[
				 Validator of standalone archetype (i.e. without reference to parent archetypes
				 in the case of specialised archetypes). The validation done here checks the use
				 of codes defined in the ontology against their use in the definition of the 
				 archetype.
		         ]"
	keywords:    "constraint model"
	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.com>"
	copyright:   "Copyright (c) 2007 Ocean Informatics Pty Ltd"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"

class ARCHETYPE_VALIDATOR

inherit
	AUTHORED_RESOURCE_VALIDATOR
		rename
			make as make_authored_resource
		redefine
			target, validate
		end

	ARCHETYPE_TERM_CODE_TOOLS
		export
			{NONE} all
		end

	ADL_SYNTAX_CONVERTER
		export
			{NONE} all
		end

	OPERATOR_TYPES
		export
			{NONE} all
		end

	SHARED_KNOWLEDGE_REPOSITORY
		export
			{NONE} all
		end

	INTERNAL
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialisation

	make (a_target_desc: like target_descriptor; an_rm_schema: SCHEMA_ACCESS)
			-- set target_descriptor
			-- initialise reporting variables
		require
			target_desc_attached: a_target_desc /= Void
			target_desc_valid: a_target_desc.differential_archetype /= Void
			Rm_schema_available: an_rm_schema /= Void
		do
			rm_schema := an_rm_schema
			target_descriptor := a_target_desc
			make_authored_resource(target_descriptor.differential_archetype)
			if target_descriptor.is_specialised then
				if target_descriptor.specialisation_parent = Void then
					add_error("validate_e1", Void)
				elseif not target_descriptor.specialisation_parent.is_valid then
					add_error("validate_e2", Void)
				else
					flat_parent := target_descriptor.specialisation_parent.flat_archetype
	 				target.set_parent_archetype (target_descriptor.specialisation_parent.differential_archetype)
				end
			end
		ensure
			target_descriptor_set: target_descriptor = a_target_desc
			target_set: target = a_target_desc.differential_archetype
			Parent_set: (passed and target_descriptor.is_specialised) implies flat_parent /= Void
		end

feature -- Access

	target_descriptor: ARCH_REP_ARCHETYPE
			-- differential archetype being validated

	target: DIFFERENTIAL_ARCHETYPE
			-- differential archetype being validated

	compressed_definition: attached C_COMPLEX_OBJECT
			-- path-compressed form of definition of target archetype

	flat_parent: FLAT_ARCHETYPE
			-- flat version of parent archetype, if target is specialised

	ontology: attached ARCHETYPE_ONTOLOGY
			-- The ontology of the current archetype.
		do
			Result := target.ontology
		end

	target_flat: FLAT_ARCHETYPE
			-- reference to the flat form of this archetype, once flattened

feature -- Validation

	validate
		do
			reset

			-- validate description section
			if passed then
				Precursor
				validate_languages
			end

			-- reference model validation; validates as well as sets up link between each node and its RM descriptor
			if passed and rm_schema.model_loaded then
				validate_reference_model
			end

			-- basic validation of definition and ontology
			if passed then
				validate_basics
			end

			-- validation requiring the archetype xref tables
			if passed then
				target.build_xrefs
				report_unused_ontology_codes
				validate_definition_codes
				if target.has_slots then
					build_slot_id_index
				end
			end

			-- basic validation of definition and ontology
			if passed then
				validate_ontology_languages
				validate_ontology_code_spec_levels
			end

			-- validation requiring valid specialisation parent
			if passed then
				if target.is_specialised then
					target.build_rolled_up_status
					validate_specialised_definition
				end
				validate_internal_references
				validate_invariants
			end
		end

	validate_flat
			-- validate flat form (some things are too hard to do on the diff form!)
		require
			Flat_exists: target_descriptor.flat_archetype /= Void
		do
			reset
			target_flat := target_descriptor.flat_archetype
--			validate_occurrences
		end

feature {NONE} -- Implementation

	rm_schema: SCHEMA_ACCESS

	validate_basics
			-- are basic features of archetype structurally intact and correct?
			-- into account validity with respect to parent archetypes.
		do
			if not target_descriptor.id.as_string.is_equal (target.archetype_id.as_string) then
				add_error("validate_e3", <<target_descriptor.id.as_string, target.archetype_id.as_string>>)
			elseif not target.definition.rm_type_name.is_equal (target.archetype_id.rm_entity) then
				add_error("VARDT", <<target.archetype_id.rm_entity, target.definition.rm_type_name>>)
			elseif specialisation_depth_from_code (target.concept) /= target.specialisation_depth then
				add_error("VACSD", <<specialisation_depth_from_code (target.concept).out, target.specialisation_depth.out>>)
			elseif not target.definition.node_id.is_equal (target.concept) then
				add_error("VACCD", <<target.concept>>)
			end
		end

	validate_languages
			-- check to see that all linguistic items in ontology, description, etc are all coherent
		local
			langs: ARRAYED_SET [STRING]
			err_str: STRING
		do
			-- check that languages defined in translations section are in the archetype ontology
			langs := target.languages_available
			if not langs.is_subset (target.ontology.languages_available) then
				create err_str.make (0)
				from langs.start until langs.off loop
					if not target.ontology.languages_available.has (langs.item) then
						if not err_str.is_empty then
							err_str.append (", ")
						end
						err_str.append (langs.item)
					end
					langs.forth
				end
				add_error("VOTM", <<err_str>>)
			end
		end

	validate_ontology_languages
			-- Are all `term_codes' and `constraint_codes' found in all languages?
		local
			lang: STRING
		do
			from ontology.languages_available.start until ontology.languages_available.off loop
				lang := ontology.languages_available.item
				from ontology.term_codes.start until ontology.term_codes.off loop
					if ontology.term_definition (lang, ontology.term_codes.item) = Void then
						add_error("VONLC", <<ontology.term_codes.item, lang>>)
					end
					ontology.term_codes.forth
				end
				from ontology.constraint_codes.start until ontology.constraint_codes.off loop
					if ontology.constraint_definition (lang, ontology.constraint_codes.item) = Void then
						add_error("VONLC", <<ontology.constraint_codes.item, lang>>)
					end
					ontology.constraint_codes.forth
				end
				ontology.languages_available.forth
			end
		end

	validate_ontology_code_spec_levels
			-- See if there are any codes in the ontology that should not be there - either or lower or higher
			-- level of specialisation.
		do
			from ontology.term_codes.start until ontology.term_codes.off loop
				if specialisation_depth_from_code (ontology.term_codes.item) > ontology.specialisation_depth then
					add_error("VONSD", <<ontology.term_codes.item>>)
				end
				ontology.term_codes.forth
			end
			from ontology.constraint_codes.start until ontology.constraint_codes.off loop
				if specialisation_depth_from_code (ontology.constraint_codes.item) > ontology.specialisation_depth then
					add_error("VONSD", <<ontology.constraint_codes.item>>)
				end
				ontology.constraint_codes.forth
			end
		end

	validate_definition_codes
			-- Check if all at- and ac-codes found in the definition node tree are in the ontology (including inherited items).
			-- Leave `passed' True if all found node_ids are defined in term_definitions,
			-- and term_definitions contains no extras.
		local
			a_codes: HASH_TABLE [ARRAYED_LIST [ARCHETYPE_CONSTRAINT], STRING]
			depth, code_depth: INTEGER
		do
			depth := ontology.specialisation_depth

			a_codes := target.id_atcodes_index
			from a_codes.start until a_codes.off loop
				code_depth := specialisation_depth_from_code (a_codes.key_for_iteration)
				if code_depth > depth then
					add_error("VATCD", <<a_codes.key_for_iteration>>)
				elseif code_depth < depth then
					if not flat_parent.ontology.has_term_code (a_codes.key_for_iteration) then
						add_error("VATDF1", <<a_codes.key_for_iteration>>)
					end
				elseif not ontology.has_term_code (a_codes.key_for_iteration) then
					add_error("VATDF2", <<a_codes.key_for_iteration>>)
				end
				a_codes.forth
			end

			-- see if every found leaf term code (in an ORDINAL or a CODED_TERM) is in ontology
			a_codes := target.data_atcodes_index
			from a_codes.start until a_codes.off loop
				code_depth := specialisation_depth_from_code (a_codes.key_for_iteration)
				if code_depth > depth then
					add_error("VATCD", <<a_codes.key_for_iteration>>)
				elseif code_depth < depth then
					if not flat_parent.ontology.has_term_code (a_codes.key_for_iteration) then
						add_error("VATDF1", <<a_codes.key_for_iteration>>)
					end
				elseif not ontology.has_term_code (a_codes.key_for_iteration) then
					add_error("VATDF2", <<a_codes.key_for_iteration>>)
				end
				a_codes.forth
			end

			-- check if all found constraint_codes are defined in constraint_definitions,
			a_codes := target.accodes_index
			from a_codes.start until a_codes.off loop
				code_depth := specialisation_depth_from_code (a_codes.key_for_iteration)
				if code_depth > depth then
					add_error("VATCD", <<a_codes.key_for_iteration>>)
				elseif code_depth < depth then
					if not flat_parent.ontology.has_constraint_code (a_codes.key_for_iteration) then
						add_error("VACDF1", <<a_codes.key_for_iteration>>)
					end
				elseif not ontology.has_constraint_code (a_codes.key_for_iteration) then
					add_error("VACDF2", <<a_codes.key_for_iteration>>)
				end
				a_codes.forth
			end
		end

	validate_internal_references
			-- Validate items in `found_internal_references'.
		local
			use_refs: HASH_TABLE [ARRAYED_LIST [ARCHETYPE_INTERNAL_REF], STRING]
		do
			use_refs := target.use_node_index

			from use_refs.start until use_refs.off loop
				-- check on paths in the current archetype
				if target.definition.has_path (use_refs.key_for_iteration) then
					convert_use_ref_paths (use_refs.item_for_iteration, use_refs.key_for_iteration, target)
				elseif target.is_specialised and flat_parent.definition.has_path (use_refs.key_for_iteration) then
					convert_use_ref_paths (use_refs.item_for_iteration, use_refs.key_for_iteration, flat_parent)
				else
					add_error("VUNP", <<use_refs.key_for_iteration>>)
				end
				use_refs.forth
			end
		end

	validate_invariants
			-- validate the invariants if any, which entails checking that all path references are valid against
			-- the flat archetype if specialised
			-- FIXME: do the actual validation
		do
			if target.has_invariants then
				from target.invariants_index.start until target.invariants_index.off loop
					convert_invariant_paths (target.invariants_index.item_for_iteration, target)
					target.invariants_index.forth
				end
			end
		end

	report_unused_ontology_codes
			-- populate lists of at-codes and ac-codes found in ontology that
			-- are not referenced anywhere in the archetype definition
		do
			from target.ontology_unused_term_codes.start until target.ontology_unused_term_codes.off loop
				add_warning("WOUC", <<target.ontology_unused_term_codes.item>>)
				target.ontology_unused_term_codes.forth
			end

			from target.ontology_unused_constraint_codes.start until target.ontology_unused_constraint_codes.off loop
				add_warning("WOUC", <<target.ontology_unused_constraint_codes.item>>)
				target.ontology_unused_constraint_codes.forth
			end
		end

	build_slot_id_index
			-- build slot_id_index in ARCH_REP_ARCHETYPE
		require
			target.has_slots
		local
			assn_list: ARRAYED_LIST[ASSERTION]
			a_regex: STRING
			id_list: ARRAYED_LIST[STRING]
			ara: ARCH_REP_ARCHETYPE
		do
			from target.slot_index.start until target.slot_index.off loop
				-- process the includes
				assn_list := target.slot_index.item.includes
				from assn_list.start until assn_list.off loop
					a_regex := extract_regex(assn_list.item)
					if a_regex /= Void then
						target_descriptor.add_slot_ids(arch_dir.matching_ids (a_regex, target.slot_index.item.rm_type_name), target.slot_index.item.path)
					end
					assn_list.forth
				end

				-- if there are still no ids at all for this path, the implication is that all ids match, and that exclusions will remove some
				if not target_descriptor.has_slots or else not target_descriptor.slot_id_index.has (target.slot_index.item.path) then
					target_descriptor.add_slot_ids (arch_dir.matching_ids (".*", target.slot_index.item.rm_type_name), target.slot_index.item.path)
				end

				-- process the excludes
				assn_list := target.slot_index.item.excludes
				from assn_list.start until assn_list.off loop
					a_regex := extract_regex(assn_list.item)
					if a_regex /= Void then
						id_list := arch_dir.matching_ids (a_regex, target.slot_index.item.rm_type_name)

						-- go through existing id list and remove any matched by the exclusion list
						from id_list.start until id_list.off loop
							target_descriptor.slot_id_index.item (target.slot_index.item.path).prune (id_list.item)
							id_list.forth
						end
					end
					assn_list.forth
				end

				-- now post the results in the reverse indexes
				id_list := target_descriptor.slot_id_index.item (target.slot_index.item.path)
				from id_list.start until id_list.off loop
					ara := arch_dir.archetype_index.item (id_list.item)
					if not ara.is_used or else not ara.used_by_index.has (target.archetype_id.as_string) then
						ara.add_used_by_item (target.archetype_id.as_string)
					end
					id_list.forth
				end
				target.slot_index.forth
			end
		end

	extract_regex(an_assertion: ASSERTION): STRING
			-- extract regex from id matches {/regex/} style assertion used in slots
		local
			bin_op: EXPR_BINARY_OPERATOR
			a_leaf: EXPR_LEAF
			c_str: C_STRING
		do
			bin_op ?= an_assertion.expression
			if bin_op /= Void and then bin_op.operator.value = op_matches then
				a_leaf ?= bin_op.right_operand
				if a_leaf /= Void then
					c_str ?= a_leaf.item
					Result := c_str.regexp
				end
			end
		end

	validate_specialised_definition
			-- validate definition of specialised archetype against flat parent
		require
			Target_specialised: target.is_specialised
		local
			def_it: C_ITERATOR
		do
			create def_it.make(target.definition)
			def_it.do_until_surface(agent specialised_node_validate, agent specialised_node_validate_test)
		end

	specialised_node_validate (a_c_node: ARCHETYPE_CONSTRAINT; depth: INTEGER)
			-- validate nodes in differential specialised archetype
			-- SIDE-EFFECT: sets is_mergeable markers on child archetype nodes
		local
			co_parent_flat: attached C_OBJECT
			co_parent_flat_detachable: detachable C_OBJECT
			apa: ARCHETYPE_PATH_ANALYSER
		do
			create apa.make_from_string (a_c_node.path)

			if attached {C_ATTRIBUTE} a_c_node as ca_child_diff then
				if attached {C_ATTRIBUTE} flat_parent.definition.c_attribute_at_path (apa.path_at_level (flat_parent.specialisation_depth)) as ca_parent_flat then
					if not ca_child_diff.node_conforms_to(ca_parent_flat, rm_schema) then
						if ca_child_diff.is_single /= ca_parent_flat.is_single then
							add_error("VSAM", <<ca_child_diff.path>>)
						elseif not ca_child_diff.existence_conforms_to (ca_parent_flat) then
							add_error("VSANCE", <<ca_child_diff.path, ca_child_diff.existence.as_string,
										ca_parent_flat.path, ca_parent_flat.existence.as_string>>)
						elseif not ca_child_diff.cardinality_conforms_to (ca_parent_flat) then
							add_error("VSANCC", <<ca_child_diff.path, ca_child_diff.cardinality.as_string,
										ca_parent_flat.path, ca_parent_flat.cardinality.as_string>>)
						else
							add_error("compiler_unexpected_error", <<"ARCHETYPE_VALIDATOR.specialised_node_validate location 1">>)
						end
					elseif ca_child_diff.node_congruent_to (ca_parent_flat, rm_schema) and ca_child_diff.parent.is_mergeable then
						debug ("validate")
							io.put_string (">>>>> validate: C_ATTRIBUTE in child at " + ca_child_diff.path + " CONGRUENT to parent node " + ca_parent_flat.path + " (setting is_mergeable) %N")
						end
						ca_child_diff.set_is_mergeable
					end
				else
					add_error("compiler_unexpected_error", <<"ARCHETYPE_VALIDATOR.specialised_node_validate location 2">>)
				end
			elseif attached {C_OBJECT} a_c_node as co_child_diff then
				co_parent_flat_detachable := flat_parent.c_object_at_path (apa.path_at_level (flat_parent.specialisation_depth))
				check co_parent_flat_detachable /= Void end
				co_parent_flat := co_parent_flat_detachable

				-- meta-type (i.e. AOM type) checking...
				-- C_CODE_PHRASE conforms to CONSTRAINT_REF, but is not testable in any way; sole exception in ADL/AOM; just warn
				if attached {CONSTRAINT_REF} co_parent_flat as ccr and then not attached {CONSTRAINT_REF} co_child_diff as ccr2 then
					if attached {C_CODE_PHRASE} co_child_diff as ccp then
						add_warning("WCRC", <<co_child_diff.path>>)
					else
						add_error("VSCNR", <<co_parent_flat.generating_type, co_parent_flat.path, co_child_diff.generating_type, co_child_diff.path>>)
					end
				else
					-- if the child is a redefine of a parent use_node, then we have to do the comparison to the use_node target,
					-- unless they both are use_nodes, in which case leave them as is
					if attached {ARCHETYPE_INTERNAL_REF} co_parent_flat as air_p and not attached {ARCHETYPE_INTERNAL_REF} co_child_diff as air_c then
						co_parent_flat_detachable := flat_parent.c_object_at_path (air_p.path)
						check co_parent_flat_detachable /= Void end
						co_parent_flat := co_parent_flat_detachable
						if dynamic_type (co_child_diff) /= dynamic_type (co_parent_flat) then
							add_error("VSUNT", <<co_child_diff.path, co_child_diff.generating_type, co_parent_flat.path, co_parent_flat.generating_type>>)
						end
					end

					-- by here the AOM meta-types must be the same; if not, it is an error
					if dynamic_type (co_child_diff) /= dynamic_type (co_parent_flat) then
						add_error("VSONT", <<co_child_diff.path, co_child_diff.generating_type, co_parent_flat.path, co_parent_flat.generating_type>>)
					-- they should also be conformant as defined by the node_conforms_to() function
					elseif not co_child_diff.node_conforms_to(co_parent_flat, rm_schema) then
						if not co_child_diff.rm_type_conforms_to (co_parent_flat, rm_schema) then
							add_error("VSONCT", <<co_child_diff.path, co_child_diff.rm_type_name, co_parent_flat.path, co_parent_flat.rm_type_name>>)
						elseif not co_child_diff.occurrences_conforms_to (co_parent_flat) then
							if strict_validation then
								add_error("VSONCO", <<co_child_diff.path, co_child_diff.occurrences_as_string, co_parent_flat.path, co_parent_flat.occurrences.as_string>>)
							else
								add_warning("VSONCO", <<co_child_diff.path, co_child_diff.occurrences_as_string, co_parent_flat.path, co_parent_flat.occurrences.as_string>>)
								co_child_diff.remove_occurrences
							end
						elseif co_child_diff.is_addressable then
							if not co_child_diff.node_id_conforms_to (co_parent_flat) then
								add_error("VSONCI", <<co_child_diff.path, co_child_diff.node_id, co_parent_flat.path, co_parent_flat.node_id>>)
--							elseif co_child_diff.node_id.is_equal(co_parent_flat.node_id) then -- id same, something else must be different
--								add_error("VSONIR", <<co_child_diff.path, co_child_diff.rm_type_name, co_parent_flat.rm_type_name, co_child_diff.node_id>>)
							end
						else
							add_error("VSONI", <<co_child_diff.rm_type_name, co_child_diff.path, co_parent_flat.rm_type_name, co_parent_flat.path>>)
						end
					else
						-- nodes are at least conformant; check for congruence for specialisation path replacement
						if attached {C_COMPLEX_OBJECT} co_child_diff as cco and co_child_diff.node_congruent_to (co_parent_flat, rm_schema) and (co_child_diff.is_root or else co_child_diff.parent.is_mergeable) then
							debug ("validate")
								io.put_string (">>>>> validate: C_OBJECT in child at " + co_child_diff.path + " CONGRUENT to parent node " + co_parent_flat.path)
							end
							-- if the parent C_ATTRIBUTE node of the object node in the flat parent has no children, this object can be assumed to be a total
							-- replacement, so don't mark it as an overlay
							if attached {C_COMPLEX_OBJECT} co_parent_flat as cco_pf then
								if co_child_diff.is_root or cco_pf.has_attributes then
									co_child_diff.set_is_mergeable
									debug ("validate")
										io.put_string (" (setting is_mergeable) %N")
									end
								else
									debug ("validate")
										io.put_string ("(not setting is_mergeable, due to being replacement)%N")
									end
								end
							else
								add_error("compiler_unexpected_error", <<"ARCHETYPE_VALIDATOR.specialised_node_validate location 3">>)
							end
						else
							debug ("validate")
								io.put_string (">>>>> validate: C_OBJECT in child at " + co_child_diff.path + " CONFORMANT to parent node " + co_parent_flat.path + " %N")
							end
						end

						if co_child_diff.sibling_order /= Void and then not co_parent_flat.parent.has_child_with_id (co_child_diff.sibling_order.sibling_node_id) then
							add_error("VSSM", <<co_child_diff.path, co_child_diff.sibling_order.sibling_node_id>>)
						end
					end
				end
			end
		end

	specialised_node_validate_test (a_c_node: ARCHETYPE_CONSTRAINT): BOOLEAN
			-- return True if a conformant path of a_c_node within the differential archetype is
			-- found within the flat parent archetype - i.e. a_c_node is inherited or redefined from parent (but not new)
			-- and no previous errors encountered
		local
			apa: ARCHETYPE_PATH_ANALYSER
			accept: BOOLEAN
			ca_parent_flat: attached C_ATTRIBUTE
		do
			-- if check below is True, it means the path is to an object that is new in the current archetype,
			-- and therefore there is nothing in the parent to validate it against. Invalid codes, i.e. the 'unknown' code
			-- (used on non-coded nodes) or else codes that are either the same as the corresponding node in the parent flat,
			-- or else a refinement of that, but not a new code, e.g. at0001.0.2
			if attached {C_OBJECT} a_c_node as a_c_obj then
				accept := not is_valid_code (a_c_obj.node_id) or else
							(specialisation_depth_from_code (a_c_obj.node_id) = 0 or else is_refined_code(a_c_obj.node_id))

				-- special check: if it is a non-overlay node, but it has a sibling order, then we need to check that the
				-- sibling order refers to a valid node in the parent flat. Arguably this should be done in the main
				-- specialised_node_validate routine, but... I will re-engineer the code before contemplating that
				if not accept and a_c_obj.sibling_order /= Void then
					create apa.make_from_string(a_c_node.parent.path)
					ca_parent_flat := flat_parent.definition.c_attribute_at_path (apa.path_at_level (flat_parent.specialisation_depth))
					if not ca_parent_flat.has_child_with_id (a_c_obj.sibling_order.sibling_node_id) then
						add_error("VSSM", <<a_c_obj.path, a_c_obj.sibling_order.sibling_node_id>>)
					end
				end
			else
				accept := True
			end

			if accept then
				create apa.make_from_string(a_c_node.path)
				Result := passed and flat_parent.has_path (apa.path_at_level (flat_parent.specialisation_depth))
			else
				debug ("validate")
					io.put_string ("????? specialised_node_validate_test: a_c_node at " + a_c_node.path + " ignored %N")
				end
			end
		end

	validate_reference_model
			-- validate definition of archetype against reference model
		require
			rm_schema.model_loaded
		local
			def_it: C_ITERATOR
		do
			create invalid_types.make(0)
			invalid_types.compare_objects
			create def_it.make(target.definition)
			def_it.do_until_surface(agent rm_node_validate, agent rm_node_validate_test)
		end

	rm_node_validate (a_c_node: ARCHETYPE_CONSTRAINT; depth: INTEGER)
			-- perform validation of node against reference model
		local
			arch_parent_attr_type, model_attr_class: STRING
			co_parent_flat: C_OBJECT
			apa: ARCHETYPE_PATH_ANALYSER
			rm_prop_def: BMM_PROPERTY_DEFINITION
		do
			if attached {C_OBJECT} a_c_node as co then
				if not co.is_root then -- now check if this object a valid type of its owning attribute
					if target.is_specialised and then co.parent.has_differential_path then
						create apa.make_from_string (co.parent.differential_path)
						co_parent_flat := flat_parent.c_object_at_path (apa.path_at_level (flat_parent.specialisation_depth))
						arch_parent_attr_type := co_parent_flat.rm_type_name
					else
						arch_parent_attr_type := co.parent.parent.rm_type_name
					end

					if not invalid_types.has (arch_parent_attr_type) then
						if rm_schema.has_property (arch_parent_attr_type, co.parent.rm_attribute_name) and not
											rm_schema.valid_property_type (arch_parent_attr_type, co.parent.rm_attribute_name, co.rm_type_name) then
							model_attr_class := rm_schema.property_type (arch_parent_attr_type, co.parent.rm_attribute_name)

							-- flag if constraint is equal to reference model; FUTURE: remove if equal
							if rm_schema.substitutions.has (co.rm_type_name) and then rm_schema.substitutions.item (co.rm_type_name).is_equal (model_attr_class) then
								add_info("ICORMTS", <<co.rm_type_name, co.path, model_attr_class,
									arch_parent_attr_type, co.parent.rm_attribute_name>>)
							else
								add_error("VCORMT", <<co.rm_type_name, co.path, model_attr_class, arch_parent_attr_type, co.parent.rm_attribute_name>>)
								invalid_types.extend (co.rm_type_name)
							end
						end
					end
				end
			elseif attached {C_ATTRIBUTE} a_c_node as ca then
				if target.is_specialised and then ca.has_differential_path then
					create apa.make_from_string (ca.differential_path)
					co_parent_flat := flat_parent.c_object_at_path (apa.path_at_level (flat_parent.specialisation_depth))
					arch_parent_attr_type := co_parent_flat.rm_type_name
				else
					arch_parent_attr_type := ca.parent.rm_type_name -- can be a generic type like DV_INTERVAL <DV_QUANTITY>
				end
				if not rm_schema.has_property(arch_parent_attr_type, ca.rm_attribute_name) then
					add_error("VCARM", <<ca.rm_attribute_name, ca.path, arch_parent_attr_type>>)
				else
					rm_prop_def := rm_schema.property_definition(arch_parent_attr_type, ca.rm_attribute_name)
					if ca.existence /= Void then
						if rm_prop_def.existence.contains(ca.existence) then
							if rm_prop_def.existence.equal_interval(ca.existence) then
								add_warning("WCAEX", <<ca.rm_attribute_name, ca.path, ca.existence.as_string>>)
								if not strict_validation then
									ca.remove_existence
								end
							end
						else
							if strict_validation then
								add_error("VCAEX", <<ca.rm_attribute_name, ca.path, ca.existence.as_string, rm_prop_def.existence.as_string>>)
							else
								add_warning("VCAEX", <<ca.rm_attribute_name, ca.path, ca.existence.as_string, rm_prop_def.existence.as_string>>)
								ca.remove_existence
							end
						end
					end
					if ca.is_multiple then
						if attached {BMM_CONTAINER_PROPERTY} rm_prop_def as cont_prop then
							if ca.cardinality /= Void then
								if cont_prop.type.cardinality.contains(ca.cardinality.interval) then
									if cont_prop.type.cardinality.equal_interval(ca.cardinality.interval) then
										add_warning("WCACA", <<ca.rm_attribute_name, ca.path, ca.cardinality.interval.as_string>>)
										if not strict_validation then
											ca.remove_cardinality
										end
									end
								else -- archetype has cardinality not contained by RM
									if strict_validation then
										add_error("VCACA", <<ca.rm_attribute_name, ca.path, ca.cardinality.interval.as_string, cont_prop.type.cardinality.as_string>>)
									else
										add_warning("VCACA", <<ca.rm_attribute_name, ca.path, ca.cardinality.interval.as_string, cont_prop.type.cardinality.as_string>>)
										ca.remove_cardinality
									end
								end
							end
						else -- archetype has multiple attribute but RM does not
							add_error("VCAM", <<ca.rm_attribute_name, ca.path, ca.cardinality.as_string, "(single-valued)">>)
						end
					elseif attached {BMM_CONTAINER_PROPERTY} rm_prop_def as cont_prop_2 then
						add_error("VCAM", <<ca.rm_attribute_name, ca.path, "(single-valued)", cont_prop_2.type.cardinality.as_string>>)
					end
					if rm_prop_def.is_computed then
						-- flag if this is a computed property constraint (i.e. a constraint on a function from the RM)
						add_warning("ICARMC", <<ca.rm_attribute_name, ca.path, arch_parent_attr_type>>)
					end
				end
			end
		end

	invalid_types: ARRAYED_LIST [STRING]

	rm_node_validate_test (a_c_node: ARCHETYPE_CONSTRAINT): BOOLEAN
			-- return True if node is a C_OBJECT and class is known in RM, or if it is a C_ATTRIBUTE
		do
			Result := True
			if attached {C_OBJECT} a_c_node as co then
				if not rm_schema.has_class_definition(co.rm_type_name) then
					if not invalid_types.has(co.rm_type_name) then
						add_error("VCORM", <<co.rm_type_name, co.path>>)
						invalid_types.extend (co.rm_type_name)
					end
					Result := False
				end
			end
		end


--
-- It doesn't really make sense to do this strict occurrences / cardinality evaluation because it prevents
-- easy redefinition of cardinality in specialised archetypes
--
--	validate_occurrences
--			-- validate occurrences under container attributes, in flat definition
--		require
--			target_flat /= Void
--		local
--			def_it: C_ITERATOR
--		do
--			create def_it.make(target_flat.definition)
--			def_it.do_all(agent flat_node_enter, agent flat_node_exit)
--		end

--	flat_node_enter (a_c_node: ARCHETYPE_CONSTRAINT; depth: INTEGER)
--			-- basic validation of any node
--		do
--			if attached {C_ATTRIBUTE} a_c_node as ca then
--				if ca.is_multiple then
--					if not ca.occurrences_total_range.intersects (ca.cardinality.interval) then
--						add_error("VACMC2", <<ca.path, ca.cardinality.as_string>>)
--					end
--				end
--			end
--		end

--	flat_node_exit (a_c_node: ARCHETYPE_CONSTRAINT; depth: INTEGER)
--		do
--		end

invariant
	target_descriptor_attached: target_descriptor /= Void

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
