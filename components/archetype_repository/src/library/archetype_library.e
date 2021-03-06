note
	component:   "openEHR ADL Tools"
	description: "[
				 Archetype library - a data structure containing archetypes (of any kind) found
				 in one or more physical locations, each of which is on some medium, such as the 
				 file system or a web-accessible repository. 
				 
				 The structure of the library is a list of top-level packages, each containing
				 an inheritance tree of first degree descendants of a class that provides 
				 archetyping capability, such as the openEHR class LOCATABLE or the 13606 class
				 RECORD_COMPONENT (which class it is is marked in the .bmm schema for the relevant
				 reference model).
				 
				 The contents of the structure consist of archetypes found in the reference and
				 working repositories, and are subsequently attached into the structure.
				 Archetypes opened adhoc are also grafted here.
				 
				 The library is populated at startup, using the source repository paths stored in a
				 configuration file or elsewhere.
				 
				 Archetypes can also be explicitly loaded by the user at runtime, outside of the 
				 repositories, e.g. the user wants to look at an archetype sent to him in email and
				 stored in /tmp. These archetypes are remembered on the 'adhoc_repository', and this 
				 is also merged into the directory by 'grafting'.
				 
				 In the resulting library, the archetype descriptors from each repository are marked
				 so that calling routines can distinguish them, e.g. to use different coloured icons on 
				 the screen.
				 ]"
	keywords:    "ADL"
	author:      "Thomas Beale <thomas.beale@OceanInformatics.com>"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2006-2012 Ocean Informatics Pty Ltd <http://www.oceaninfomatics.com>"
	license:     "Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>"

class ARCHETYPE_LIBRARY

inherit
	SHARED_ARCHETYPE_RM_ACCESS
		export
			{NONE} all;
			{ANY} has_rm_schema_for_archetype_id
		end

	ANY_VALIDATOR
		rename
			validate as populate
		end

	BMM_DEFINITIONS
		export
			{NONE} all;
			{ANY} deep_copy, deep_twin, is_deep_equal, standard_is_equal
		end

	ARCHETYPE_STATISTICAL_DEFINITIONS
		export
			{NONE} all
		end

	KL_SHARED_FILE_SYSTEM
		export
			{NONE} all
		end

create
	make

feature -- Definitions

	Archetype_category: IMMUTABLE_STRING_8
		once
			create Result.make_from_string ("archetypes")
		end

	Template_category: IMMUTABLE_STRING_8
		once
			create Result.make_from_string ("templates")
		end

feature {NONE} -- Initialisation

	make (a_lib_access: ARCHETYPE_LIBRARY_INTERFACE)
		do
			library_access := a_lib_access
			clear
			if not semantic_item_tree_prototype.has_children then
				initialise_semantic_item_tree_prototype
				clone_semantic_item_tree_prototype
				schema_load_counter := rm_schemas_access.load_count
			end
		end

feature -- Access

	library_access: ARCHETYPE_LIBRARY_INTERFACE
			-- the repository profile accessor from which this library gets its contents

	archetype_with_id (an_id: STRING): ARCH_LIB_ARCHETYPE_ITEM
			-- get the archetype with physical id `an_id'
		require
			has_archetype_with_id (an_id)
		do
			check attached archetype_index.item (an_id) as aca then
				Result := aca
			end
		end

	semantic_item_index: HASH_TABLE [ARCH_LIB_ITEM, STRING]
			-- Index of archetype & class nodes, keyed by LOWER-CASE semantic id. Used during construction of `directory'
			-- For class nodes, this will be model_publisher-closure_name-class_name, e.g. openehr-demographic-party.
			-- For archetype nodes, this will be the archetype id.
		attribute
			create Result.make (0)
		end

	matching_ids (a_regex: STRING; an_rm_type, an_rm_closure: detachable STRING): ARRAYED_SET [STRING]
			-- generate list of archetype ids that match the regex pattern and optional rm_type. If rm_type is supplied,
			-- we assume that the regex itself does not contain an rm type. Matching using `an_tm_type' and
			-- `an_rm_closure' is done in lower case. Any case may be supplied for these two
		require
			Regex_valid: not a_regex.is_empty
			Rm_type_valid: attached an_rm_type as att_rm_type implies not att_rm_type.is_empty
			Rm_closure_valid: attached an_rm_closure as att_rm_closure implies not att_rm_closure.is_empty
		local
			regex_matcher: RX_PCRE_REGULAR_EXPRESSION
			arch_id: ARCHETYPE_HRID
			is_candidate: BOOLEAN
			rm_type, rm_closure: detachable STRING
		do
			create Result.make (0)
			Result.compare_objects

			if attached an_rm_type as rm_t then
				rm_type := rm_t.as_lower
			end
			if attached an_rm_closure as rm_cl then
				rm_closure := rm_cl.as_lower
			end

			create regex_matcher.make
			regex_matcher.set_case_insensitive (True)
			regex_matcher.compile (a_regex)
			if regex_matcher.is_compiled then
				across archetype_index as archs_csr loop
					if regex_matcher.matches (archs_csr.key) then
						if attached rm_type as rmt then
							create arch_id.make_from_string (archs_csr.key)
							is_candidate := rmt.is_equal (arch_id.rm_class.as_lower)
							if is_candidate and attached rm_closure as rmc then
								is_candidate := rmc.is_equal (arch_id.rm_package.as_lower)
							end
						else
							is_candidate := True
						end
						if is_candidate then
							Result.extend (archs_csr.key)
						end
					end
				end
			else
				Result.extend (get_msg_line ("regex_e1", <<a_regex>>))
			end
		ensure
			across Result as ids_csr all has_item_with_id (ids_csr.item.as_lower) end
		end

	archetype_matching_ref (an_archetype_ref: STRING): detachable ARCH_LIB_ARCHETYPE_ITEM
			-- Return archetype whose id matches `an_archetype_ref'
		do
			-- try for direct match, or else filler id is compatible with available actual ids
			-- e.g. filler id is 'openEHR-EHR-COMPOSITION.discharge.v1' and list contains things
			-- like 'openEHR-EHR-COMPOSITION.discharge.v1.3.28'
			if attached archetype_ref_index.item (an_archetype_ref) as att_aca then
				Result := att_aca
			elseif attached archetype_index.item (an_archetype_ref) as att_aca then
				Result := att_aca
			else
				-- expensive brute force search
				from archetype_index.start until archetype_index.off or attached Result loop
					if archetype_index.key_for_iteration.starts_with (an_archetype_ref) and then
						attached archetype_index.item_for_iteration as att_aca
					then
						Result := att_aca
					end
					archetype_index.forth
				end
			end
		end

	item_matching_ref (a_ref: STRING): detachable ARCH_LIB_ITEM
			-- Return true if, for a slot path that is known in the parent slot index, there are
			-- actually archetypes whose ids match
		local
			ref_as_lower: STRING
		do
			ref_as_lower := a_ref.as_lower
			-- case-insentive match
			if attached semantic_item_index.item (ref_as_lower) as att_aca then
				Result := att_aca
			else
				-- case-sensitive match
				Result := archetype_matching_ref (a_ref)
			end
		end

	last_stats_build_timestamp: DATE_TIME
			-- timestamp of stats build

	last_populate_timestamp: DATE_TIME
			-- timestamp of last populate or repopulate

feature -- Status Report

	adhoc_path_valid (a_full_path: STRING): BOOLEAN
			-- True if path is valid in adhoc repository
		do
			Result := library_access.adhoc_source.is_valid_path (a_full_path)
		end

	has_archetype_with_id (an_archetype_id: STRING): BOOLEAN
			-- True if `an_archetype_id' exists in library
		do
			Result := archetype_index.has (an_archetype_id)
		end

	has_item_with_id (an_id: STRING): BOOLEAN
			-- True if `an_id', which may be for a class, archetype or other tree artefact
			-- exists in semantic index
		do
			Result := semantic_item_index.has (an_id.as_lower)
		end

	valid_candidate (aca: ARCH_LIB_ARCHETYPE_ITEM): BOOLEAN
			-- True if `aca' does not exist in the library, but has a viable parent under
			-- which it can be attached
		do
			Result := has_item_matching_ref (aca.semantic_parent_key) and
				not has_item_with_id (aca.qualified_key)
		end

	has_archetype_matching_ref (an_archetype_ref: STRING): BOOLEAN
			-- Return true if there is an archetype whose id matches
		do
			Result := archetype_index.has (an_archetype_ref) or else archetype_ref_index.has (an_archetype_ref) or else
				attached archetype_matching_ref (an_archetype_ref)
		end

	has_item_matching_ref (a_ref: STRING): BOOLEAN
			-- Return true if, there is a semantic id that matches a_ref
		do
			Result := semantic_item_index.has (a_ref.as_lower) or else has_archetype_matching_ref (a_ref)
		end

feature -- Commands

	clear
			-- reduce to initial state
		do
			reset
			archetype_index.wipe_out
			archetype_ref_index.wipe_out
			semantic_item_index.wipe_out
			filesys_item_index_cache := Void
			semantic_item_tree.wipe_out
			filesys_item_tree_cache := Void
			compile_attempt_count := 0
			create last_populate_timestamp.make_from_epoch (0)
			reset_statistics
		end

	populate
			-- populate all indexes from library source
		do
			library_access.primary_source.populate
			errors.append (library_access.primary_source.errors)

			populate_semantic_indexes
		end

feature -- Modification

	add_new_non_specialised_archetype (accn: ARCH_LIB_CLASS_ITEM; an_archetype_id: ARCHETYPE_HRID; in_dir_path: STRING)
			-- create a new archetype of class represented by `accn' in path `in_dir_path'
		require
			Valid_id: has_rm_schema_for_archetype_id (an_archetype_id)
		do
			put_archetype (create {ARCH_LIB_ARCHETYPE_ITEM}.make_new_archetype (an_archetype_id,
				library_access.primary_source, in_dir_path), in_dir_path)
		ensure
			has_item_with_id (an_archetype_id.physical_id)
		end

	add_new_specialised_archetype (parent_aca: ARCH_LIB_ARCHETYPE_ITEM; an_archetype_id: ARCHETYPE_HRID; in_dir_path: STRING)
			-- create a new specialised archetype as child of archetype represented by `parent_aca' in path `in_dir_path'
		require
			Valid_id: has_rm_schema_for_archetype_id (an_archetype_id)
			Valid_parent: parent_aca.is_valid
		do
			check attached parent_aca.differential_archetype as parent_diff_arch then
				put_archetype (create {ARCH_LIB_ARCHETYPE_ITEM}.make_new_specialised_archetype (an_archetype_id, parent_diff_arch,
					library_access.primary_source, in_dir_path), in_dir_path)
			end
		ensure
			has_item_with_id (an_archetype_id.physical_id)
		end

	add_new_template (parent_aca: ARCH_LIB_ARCHETYPE_ITEM; an_archetype_id: ARCHETYPE_HRID; in_dir_path: STRING)
			-- create a new specialised archetype as child of archetype represented by `parent_aca' in path `in_dir_path'
		require
			Valid_id: has_rm_schema_for_archetype_id (an_archetype_id)
			Valid_parent: parent_aca.is_valid
		do
			check attached parent_aca.differential_archetype as parent_diff_arch then
				put_archetype (create {ARCH_LIB_ARCHETYPE_ITEM}.make_new_template (an_archetype_id, parent_diff_arch,
					library_access.primary_source, in_dir_path), in_dir_path)
			end
		ensure
			has_item_with_id (an_archetype_id.physical_id)
		end

	last_added_archetype: detachable ARCH_LIB_ARCHETYPE_ITEM
			-- archetype added by last call to `add_new_archetype' or `add_new_specialised_archetype'

	add_adhoc_archetype (a_path: STRING)
			-- Add the archetype designated by `a_path' to the ad hoc repository, and graft it into `directory'.
		require
			path_valid: adhoc_path_valid (a_path)
		local
			aca: ARCH_LIB_ARCHETYPE_ITEM
			arch_dir: STRING
		do
			if semantic_item_index.is_empty then
				clone_semantic_item_tree_prototype
			end

			errors.wipe_out
			library_access.adhoc_source.add_item (a_path)
			errors.append (library_access.adhoc_source.errors)
			if library_access.adhoc_source.has_path (a_path) then
				aca := library_access.adhoc_source.item (a_path)
				if valid_candidate (aca) then
					arch_dir := file_system.dirname (a_path)
					if is_filesys_tree_populated and not filesys_item_index.has (arch_dir.as_lower) then
						add_filesys_tree_repo_node (arch_dir)
					end
					put_archetype (aca, a_path)
				elseif not has_item_with_id (aca.semantic_parent_key.as_lower) then
					if aca.is_specialised then
						add_error (ec_arch_cat_orphan_archetype, <<aca.semantic_parent_key, aca.qualified_key>>)
					else
						add_error (ec_arch_cat_orphan_archetype_e2, <<aca.semantic_parent_key, aca.qualified_key>>)
					end
				elseif has_item_with_id (aca.qualified_key) then
					add_error (ec_arch_cat_dup_archetype, <<a_path>>)
				end
			else
				add_error (ec_invalid_filename_e1, <<a_path>>)
			end
		end

	update_archetype_id (aca: ARCH_LIB_ARCHETYPE_ITEM)
			-- move `ara' in tree according to its current and old ids
		require
			old_id_valid: attached aca.old_id as old_id and then has_archetype_with_id (old_id.physical_id) and then archetype_with_id (old_id.physical_id) = aca
			new_id_valid: not has_archetype_with_id (aca.id.physical_id)
			semantic_parent_exists: semantic_item_index.has (aca.semantic_parent_id.as_lower)
		do
			if attached aca.old_id as att_old_id then
				archetype_indexes_remove (att_old_id)
				archetype_indexes_put (aca)

				if is_filesys_tree_populated and not aca.is_specialised then
					remove_arch_from_filesys_tree (att_old_id)
					add_arch_to_filesys_tree (aca)
				end
			end

			aca.parent.remove_child (aca)
			semantic_item_index.item (aca.semantic_parent_key).put_child (aca)
			aca.clear_old_semantic_parent_name
		ensure
			Node_added_to_archetype_index: archetype_index.has (aca.id.physical_id)
			Node_added_to_ontology_index: semantic_item_index.has (aca.id.physical_id)
			Node_parent_set: aca.parent.qualified_name.is_equal (aca.semantic_parent_id)
		end

	remove_artefact (aca: ARCH_LIB_ARCHETYPE_ITEM)
			-- remove `aca' from indexes
		require
			new_id_valid: has_archetype_with_id (aca.id.physical_id)
			Semantic_parent_exists: semantic_item_index.has (aca.id.physical_id.as_lower)
		do
			archetype_indexes_remove (aca.id)
			if is_filesys_tree_populated then
				filesys_item_index.remove (aca.id.physical_id.as_lower)
			end
			aca.parent.remove_child (aca)
		ensure
			Node_removed_from_archetype_index: not archetype_index.has (aca.id.physical_id)
			Node_removed_from_semantic_index: not semantic_item_index.has (aca.id.physical_id)
		end

feature -- Traversal

	do_all_semantic (enter_action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]]; exit_action: detachable PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]])
			-- On all nodes in `semantic_item_tree', execute `enter_action', then recurse into its subnodes, then execute `exit_action'.
		do
			do_subtree (semantic_item_tree, enter_action, exit_action)
		end

	do_all_filesys (enter_action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]]; exit_action: detachable PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]])
			-- On all nodes in `filesys_item_tree', execute `enter_action', then recurse into its subnodes, then execute `exit_action'.
		do
			do_subtree (filesys_item_tree, enter_action, exit_action)
		end

	do_all_archetypes (action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ARCHETYPE_ITEM]])
			-- On all archetype nodes, execute `action'
		do
			do_subtree (semantic_item_tree, agent do_if_archetype (?, action), Void)
		end

	do_archetypes (aci: ARCH_LIB_ITEM; action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ARCHETYPE_ITEM]])
			-- Execute `action' on all archetypes found below `aci' in the tree
		do
			do_subtree (aci, agent do_if_archetype (?, action), Void)
		end

	do_if_archetype (aci: ARCH_LIB_ITEM; action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ARCHETYPE_ITEM]])
			-- If `aci' is an archetype, perform `action' on it.
		do
			if attached {ARCH_LIB_ARCHETYPE_ITEM} aci as aca then
				action.call ([aca])
			end
		end

	do_archetype_lineage (aca: ARCH_LIB_ARCHETYPE_ITEM; action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ARCHETYPE_ITEM]])
			-- On all archetype nodes from top to `aca', execute `action'
		local
			csr: detachable ARCH_LIB_ARCHETYPE_ITEM
			lineage: ARRAYED_LIST [ARCH_LIB_ARCHETYPE_ITEM]
		do
			create lineage.make (1)
			from csr := aca until csr = Void loop
				lineage.put_front (csr)
				csr := csr.specialisation_ancestor
			end
			lineage.do_all (action)
		end

feature -- Metrics

	archetype_count: INTEGER
			-- Count of all archetype descriptors in directory.
		do
			Result := archetype_index.count
		end

	template_count: INTEGER
			-- count of artefacts designated as templates or template_components
		do
			across archetype_index as archs_csr loop
				if archs_csr.item.artefact_type.is_template then
					Result := Result + 1
				end
			end
		end

	compile_attempt_count: INTEGER
			-- Count of archetypes for which compiling has been attempted.

	update_compile_attempt_count
			-- Increment the count of archetypes for which parsing has been attempted.
		require
			can_increment: compile_attempt_count < archetype_count
		do
			compile_attempt_count := compile_attempt_count + 1
		ensure
			incremented: compile_attempt_count = old compile_attempt_count + 1
		end

	decrement_compile_attempt_count
			-- Decrement the count of archetypes for which parsing has been attempted.
		require
			can_decrement: compile_attempt_count > 0
		do
			compile_attempt_count := compile_attempt_count - 1
		ensure
			decremented: compile_attempt_count = old compile_attempt_count - 1
		end

feature -- Statistics

	has_statistics: BOOLEAN
			-- True if stats have been computed
		do
			Result := last_stats_build_timestamp > time_epoch
		end

	can_build_statistics: BOOLEAN
		do
			Result := compile_attempt_count = archetype_count
		end

	library_metrics: HASH_TABLE [INTEGER, STRING]

	terminology_bindings_statistics: HASH_TABLE [ARRAYED_LIST [STRING], STRING]
			-- table of archetypes containing terminology bindings, keyed by terminology;
			-- some archetypes have more than one binding, so could appear in more than one list

	reset_statistics
			-- Reset counters to zero.
		do
			create terminology_bindings_statistics.make (0)
			create stats.make (0)
			create library_metrics.make (Library_metric_names.count)
			Library_metric_names.do_all (
				agent (metric_name: STRING)
					do
						library_metrics.put (0, metric_name)
					end
			)
			create last_stats_build_timestamp.make_from_epoch (0)
		end

	build_detailed_statistics
		require
			can_build_statistics
		do
			if last_stats_build_timestamp < last_populate_timestamp then
				reset_statistics
				do_all_archetypes (agent gather_statistics)
				library_metrics.put (archetype_count, Total_archetype_count)
				create last_stats_build_timestamp.make_now
			end
		end

	stats: HASH_TABLE [ARCHETYPE_STATISTICAL_REPORT, STRING]
			-- table of aggregated stats, keyed by BMM_SCHEMA id to which the contributing archetypes relate
			-- (a single logical archetpe repository can contain archetypes of multiple RMs)

feature {NONE} -- Implementation

	Populate_status_not_attempted: INTEGER = 0

	Populate_status_succeeded: INTEGER = -1

	Populate_status_failed: INTEGER = -2

	archetype_index: HASH_TABLE [ARCH_LIB_ARCHETYPE_ITEM, STRING]
			-- index of archetype descriptors keyed by MIXED-CASE archetype id.
		attribute
			create Result.make (0)
		end

	archetype_ref_index: HASH_TABLE [ARCH_LIB_ARCHETYPE_ITEM, STRING]
			-- index of archetype descriptors keyed by MIXED-CASE archetype ref (i.e. id with with .vN),
			-- derived from physical archetype id (i.e. id with full vN.N.N version)
		attribute
			create Result.make (0)
		end

	archetype_indexes_put (ala: ARCH_LIB_ARCHETYPE_ITEM)
		do
			archetype_index.force (ala, ala.qualified_name)
			archetype_ref_index.force (ala, ala.id.semantic_id)
			semantic_item_index.force (ala, ala.qualified_key)
		end

	archetype_indexes_remove (arch_id: ARCHETYPE_HRID)
		do
			archetype_index.remove (arch_id.physical_id)
			archetype_ref_index.remove (arch_id.semantic_id)
			semantic_item_index.remove (arch_id.physical_id.as_lower)
		end

	populate_semantic_indexes
			-- Rebuild `archetype_index' and `item_index' from source repositories.
		local
			archs: ARRAYED_LIST [ARCH_LIB_ARCHETYPE_ITEM]
			parent_key: STRING
			added_during_pass: INTEGER
			status_list: ARRAY[INTEGER]
			i: INTEGER
		do
			if schema_load_counter < rm_schemas_access.load_count then
				initialise_semantic_item_tree_prototype
			end

			clone_semantic_item_tree_prototype

			archs := library_access.primary_source.fast_archetype_list

			-- maintain a list indicating status of each attempted archetype; values:
			-- -1 = succeeded
			-- -2 = failed (duplicate)
			--  0 = not yet tried
			-- +ve number = number of passes attempted with no success
			create status_list.make_filled (0, 1, archs.count)

			from i := 0 until i > 0 and added_during_pass = 0 loop
				added_during_pass := 0
				across archs as archs_csr loop
					if status_list [archs_csr.target_index] >= 0 then
						parent_key := archs_csr.item.semantic_parent_key
						if attached item_matching_ref (parent_key) as att_ala then
							if not semantic_item_index.has (archs_csr.item.qualified_key) then
								att_ala.put_child (archs_csr.item)
								archetype_indexes_put (archs_csr.item)
								added_during_pass := added_during_pass + 1
								status_list [archs_csr.target_index] := Populate_status_succeeded
							else
								add_error (ec_arch_cat_dup_archetype, <<archs_csr.item.source_file_path>>)
								status_list [archs_csr.target_index] := Populate_status_failed
							end
						else
							status_list [archs_csr.target_index] := status_list [archs_csr.target_index] + 1
						end
					end
				end
				i := i + 1
			end

			-- now report on all the archetypes which could not be attached into the hierarchy
			across archs as archs_csr loop
				if status_list [archs_csr.cursor_index] > 0 then
					if archs_csr.item.is_specialised then
						add_error (ec_arch_cat_orphan_archetype, <<archs_csr.item.semantic_parent_key, archs_csr.item.qualified_name>>)
					else
						add_error (ec_arch_cat_orphan_archetype_e2, <<archs_csr.item.semantic_parent_key, archs_csr.item.qualified_name>>)
					end
				end
			end
			create last_populate_timestamp.make_now
		end

	populate_filesys_indexes
		local
			arch_dir: STRING
		do
			-- create top node (never seen in GUI)
			create filesys_item_tree_cache.make (Archetype_category.twin)
			create filesys_item_index_cache.make (0)

			-- add a node representing repository root
			add_filesys_tree_repo_node (library_access.library_path)

			-- now go through archetypes and add them in to tree, adding intermediate
			-- filesystem nodes sa required
			across library_access.primary_source.fast_archetype_list as archs_csr loop
				if not archs_csr.item.is_specialised then
					add_arch_to_filesys_tree (archs_csr.item)
				end
			end

			-- attach any adhoc archetypes
			across library_access.adhoc_source.archetype_id_index as archs_csr loop
				arch_dir := file_system.dirname (archs_csr.key)
				if not filesys_item_index.has (arch_dir.as_lower) then
					add_filesys_tree_repo_node (arch_dir)
				end
				if not archs_csr.item.is_specialised then
					add_arch_to_filesys_tree (archs_csr.item)
				end
			end
		end

	add_filesys_tree_repo_node (a_repo_path: STRING)
			-- add a node directly below the root representing the repository containing the archetype(s)
		require
			not filesys_item_index.has (a_repo_path.as_lower)
		local
			filesys_node: ARCH_LIB_FILESYS_ITEM
		do
			create filesys_node.make (a_repo_path)
			filesys_item_tree_cache.put_child (filesys_node)
			filesys_item_index_cache.force (filesys_node, a_repo_path.as_lower)
		end

	has_filesys_repo_for_path (a_path: STRING): BOOLEAN
			-- True if there is a repo in the `filesys_item_tree' structure that is a
			-- parent of `a_path' on the file system
		do
			if attached filesys_item_tree.children as repo_nodes then
				Result := across repo_nodes as repo_nodes_csr some
					file_system.is_subpathname (repo_nodes_csr.item.qualified_name, a_path)
				end
			end
		end

	add_arch_to_filesys_tree (aca: ARCH_LIB_ARCHETYPE_ITEM)
			-- add top-level archetype to filesys tree. Specialised archetypes will
			-- appear automatically, due to being added to top-level parent node during
			-- semantic tree building
		require
			Filesys_tree_populated: is_filesys_tree_populated
			Archetype_valid: not aca.is_specialised and has_filesys_repo_for_path (aca.source_file_path)
		local
			parent_dir: STRING
		do
			parent_dir := file_system.dirname (aca.source_file_path).as_lower
			if not filesys_item_index.has (parent_dir) then
				add_filesys_dir_node_hierarchy (parent_dir)
			end
			filesys_item_index.item (parent_dir).put_child (aca)
			filesys_item_index.force (aca, aca.qualified_key)
		ensure
			filesys_item_index.has (aca.qualified_key)
		end

	remove_arch_from_filesys_tree (arch_id: ARCHETYPE_HRID)
			-- remove archetype from filesys tree. Specialised archetypes will
			-- appear automatically, due to being added to top-level parent node during
			-- semantic tree building
		require
			Filesys_tree_populated: is_filesys_tree_populated and then filesys_item_index.has (arch_id.physical_id)
		local
			parent_dir: STRING
		do
			if attached {ARCH_LIB_ARCHETYPE_ITEM} filesys_item_index.item (arch_id.physical_id) as ala then
				parent_dir := file_system.dirname (ala.source_file_path).as_lower
				filesys_item_index.item (parent_dir).remove_child (ala)
				filesys_item_index.remove (arch_id.physical_id)
			end
		ensure
			not filesys_item_index.has (arch_id.physical_id)
		end

	add_filesys_dir_node_hierarchy (a_dir_path: STRING)
			-- create intermediate file system nodes in `filesys_item_tree' based on `a_dir_path'
		local
			filesys_node: ARCH_LIB_FILESYS_ITEM
			parent_dir: STRING
		do
			parent_dir := file_system.dirname (a_dir_path)
			if not filesys_item_index.has (parent_dir) then
				add_filesys_dir_node_hierarchy (parent_dir)
			end

			-- now parent node must be there
			create filesys_node.make (a_dir_path)
			filesys_item_index.item (parent_dir).put_child (filesys_node)
			filesys_item_index.force (filesys_node, filesys_node.qualified_key)
		ensure
			filesys_item_index.has (file_system.dirname (a_dir_path))
		end

	filesys_item_index: HASH_TABLE [ARCH_LIB_ITEM, STRING]
			-- Index of archetype & file-system nodes, keyed by relative path of node under repository root path for directory nodes
			-- and for archetype nodes, the archetype id.
		do
			if not attached filesys_item_index_cache then
				populate_filesys_indexes
			end
			check attached filesys_item_index_cache as att_cache then
				Result := att_cache
			end
		end

	filesys_item_tree: ARCH_LIB_ARTEFACT_TYPE_ITEM
			-- The directory of archetypes in the filesystem structure, with specialisation shown
		do
			if not attached filesys_item_tree_cache then
				populate_filesys_indexes
			end
			check attached filesys_item_tree_cache as att_cache then
				Result := att_cache
			end
		end

	is_filesys_tree_populated: BOOLEAN
			-- True if the filesystem tree has been populated
		do
			Result := attached filesys_item_tree_cache
		end

	semantic_item_tree: ARCH_LIB_ARTEFACT_TYPE_ITEM
			-- The logical directory of archetypes, whose structure is derived directly from the
			-- reference model. The structure is a list of top-level packages, each containing
			-- an inheritance tree of first degree descendants of the LOCATABLE class.
			-- The contents of the structure consist of archetypes found in the reference and
			-- working repositories, and are subsequently attached into the structure.
			-- Archetypes opened adhoc are also grafted here.
		attribute
			create Result.make (Archetype_category)
		end

	semantic_item_tree_prototype: ARCH_LIB_ARTEFACT_TYPE_ITEM
			-- pure ontology structure created from RM schemas; to be used to create a copy for each refresh of the repository
			-- We use a CELL here because we only want one of these shared between all instances
		once
			create Result.make (Archetype_category)
		end

	initialise_semantic_item_tree_prototype
			-- rebuild `semantic_item_tree_prototype'
		local
			closure_node: ARCH_LIB_PACKAGE_ITEM
			rm_closure_name, qualified_rm_closure_key: STRING
			supp_list, supp_list_copy: ARRAYED_SET[STRING]
			supp_class_list: ARRAYED_LIST [BMM_CLASS]
			root_classes: ARRAYED_SET [BMM_CLASS]
			removed: BOOLEAN
			bmm_schema: BMM_SCHEMA
		do
			semantic_item_tree_prototype.wipe_out
			across rm_schemas_access.valid_top_level_schemas as top_level_schemas_csr loop
				bmm_schema := top_level_schemas_csr.item
				across bmm_schema.archetype_rm_closure_packages as rm_closure_packages_csr loop
					rm_closure_name := package_base_name (rm_closure_packages_csr.item)
					qualified_rm_closure_key := publisher_qualified_rm_closure_key (bmm_schema.rm_publisher, rm_closure_name)

					-- create new model node if not already in existence
					if semantic_item_tree_prototype.has_child_with_qualified_key (qualified_rm_closure_key) and then
						attached {ARCH_LIB_PACKAGE_ITEM} semantic_item_tree_prototype.child_with_qualified_key (qualified_rm_closure_key) as mn
					then
						closure_node := mn
					else
						create closure_node.make (rm_closure_name, bmm_schema)
						semantic_item_tree_prototype.put_child (closure_node)
					end

					-- obtain the top-most classes from the package structure; they might not always be in the top-most package
					check attached bmm_schema.package_at_path (rm_closure_packages_csr.item) as rm_closure_root_pkg then
						root_classes := rm_closure_root_pkg.root_classes
						if not root_classes.is_empty then
							-- create the list of supplier classes for all the classes in the closure root package
							create supp_list.make (0)
							supp_list.compare_objects
							across root_classes as root_classes_csr loop
								supp_list.merge (root_classes_csr.item.supplier_closure)
								supp_list.extend (root_classes_csr.item.name)
							end

							-- now filter this list to keep only those classes inheriting from the archetype_parent_class
							-- that are among the suppliers of the top-level class of the package; this gives the classes
							-- that could be archetyped in that package
							if attached bmm_schema.archetype_parent_class as apc then
								from supp_list.start until supp_list.off loop
									if not bmm_schema.is_descendant_of (supp_list.item, apc) then
										supp_list.remove
									else
										supp_list.forth
									end
								end
							end

							-- filter list list again so that only highest class in any inheritance subtree remains
							supp_list_copy := supp_list.deep_twin
							from supp_list.start until supp_list.off loop
								removed := False
								from supp_list_copy.start until supp_list_copy.off or removed loop
									if bmm_schema.is_descendant_of (supp_list.item, supp_list_copy.item) then
										supp_list.remove
										removed := True
									end
									supp_list_copy.forth
								end

								if not removed then
									supp_list.forth
								end
							end

							-- convert to BMM_CLASS_DESCRIPTORs
							create supp_class_list.make(0)
							across supp_list as supp_list_csr loop
								supp_class_list.extend (bmm_schema.class_definition (supp_list_csr.item))
							end
							add_child_nodes (rm_closure_name, supp_class_list, closure_node)
						end
					end
				end
			end
		end

	add_child_nodes (an_rm_closure_name: STRING; class_list: ARRAYED_LIST [BMM_CLASS]; a_parent_node: ARCH_LIB_MODEL_ITEM)
			-- populate child nodes of a node in library with immediate descendants of classes in `class_list'
			-- put each node into `item_index', keyed by `an_rm_closure_name' + '-' + `class_list.item.name',
			-- which will match with corresponding part of archetype identifier
		local
			children: ARRAYED_LIST [BMM_CLASS]
			class_node: ARCH_LIB_CLASS_ITEM
		do
			across class_list as class_list_csr loop
				create class_node.make (an_rm_closure_name, class_list_csr.item)
				a_parent_node.put_child (class_node)
				children := class_list_csr.item.immediate_descendants
				add_child_nodes (an_rm_closure_name, children, class_node)
			end
		end

	clone_semantic_item_tree_prototype
			-- clone `semantic_item_tree_prototype' for use in an `semantic_item_tree'
		do
			semantic_item_tree := semantic_item_tree_prototype.deep_twin
			create semantic_item_index.make (0)
			do_all_semantic (agent (ari: attached ARCH_LIB_ITEM) do semantic_item_index.force (ari, ari.qualified_key) end, Void)
		end

	put_archetype (aca: ARCH_LIB_ARCHETYPE_ITEM; in_dir_path: STRING)
			-- put `aca' into the structure
		require
			valid_candidate (aca)
		do
			-- add to semantic index
			check attached item_matching_ref (aca.semantic_parent_key) as att_ala then
				att_ala.put_child (aca)
			end
			-- add to archetype indexes
			archetype_indexes_put (aca)

			-- add to filesys index if top-level archetype (if specialised, the
			-- connection is already made due to semantic tree link
			if is_filesys_tree_populated and then not aca.is_specialised then
				add_arch_to_filesys_tree (aca)
			end

			last_added_archetype := aca
		ensure
			Last_added_archetype_set: last_added_archetype = aca
			Archetype_in_semantic_index: semantic_item_index.item (aca.qualified_key) = aca
			Archetype_in_archetype_index: has_archetype_with_id (aca.id.physical_id)
		end

	schema_load_counter: INTEGER
			-- track loading of schemas; when changed, re-intialise the ontology prototype

	shifter: STRING
			-- debug indenter
		once
			create Result.make_empty
		end

	gather_statistics (aca: ARCH_LIB_ARCHETYPE_ITEM)
			-- Update statistics counters from `aca'
		local
			terminologies: ARRAYED_LIST [STRING]
		do
			if aca.is_specialised then
				library_metrics.force (library_metrics.item (specialised_archetype_count) + 1, specialised_archetype_count)
			end
			if aca.has_slots then
				library_metrics.force (library_metrics.item (client_archetype_count) + 1, client_archetype_count)
			end
			if aca.is_supplier then
				library_metrics.force (library_metrics.item (supplier_archetype_count) + 1, supplier_archetype_count)
			end

			-- RM stats
			if aca.is_valid then
				library_metrics.force (library_metrics.item (valid_archetype_count) + 1, valid_archetype_count)

				terminologies := aca.differential_archetype.terminology.terminologies_available
				across terminologies as terminologies_csr loop
					if not terminology_bindings_statistics.has (terminologies_csr.item) then
						terminology_bindings_statistics.put (create {ARRAYED_LIST[STRING]}.make(0), terminologies_csr.item)
					end
					terminology_bindings_statistics.item (terminologies_csr.item).extend (aca.qualified_name)
				end

				aca.generate_statistics (True)
				if stats.has (aca.rm_schema.schema_id) then
					stats.item (aca.rm_schema.schema_id).merge (aca.statistical_analyser.stats)
				else
					stats.put (aca.statistical_analyser.stats.duplicate, aca.rm_schema.schema_id)
				end
			end
		end

	do_subtree (node: ARCH_LIB_ITEM; enter_action: PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]]; exit_action: detachable PROCEDURE [ANY, TUPLE [ARCH_LIB_ITEM]])
			-- On `node', execute `enter_action', then recurse into its subnodes, then execute `exit_action'.
		do
			if attached node then
				enter_action.call ([node])
				if node.has_children then
					across node as child_csr loop
						do_subtree (child_csr.item, enter_action, exit_action)
					end
				end
				if attached exit_action then
					exit_action.call ([node])
				end
			end
		end

	filesys_item_index_cache: detachable HASH_TABLE [ARCH_LIB_ITEM, STRING]

	filesys_item_tree_cache: detachable ARCH_LIB_ARTEFACT_TYPE_ITEM

invariant
	parse_attempted_archetype_count_valid: compile_attempt_count >= 0 and compile_attempt_count <= archetype_count

end


