note
	component:   "openEHR re-usable library"
	description: "Abstraction of a package as a tree structure whose nodes can contain "
	keywords:    "model, UML"

	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.com>"
	copyright:   "Copyright (c) 2010 The openEHR Foundation <http://www.openEHR.org>"
	license:     "See notice at bottom of class"

	file:        "$URL$"
	revision:    "$LastChangedRevision$"
	last_change: "$LastChangedDate$"

class BMM_PACKAGE_DEFINITION

inherit
	BMM_DEFINITIONS
		export
			{NONE} all
		end

	DT_CONVERTIBLE
		redefine
			finalise_dt
		end

create
	make

feature -- Initialisation

	make_dt (make_args: ARRAY[ANY])
			-- make in a safe way for DT building purposes
		do
			create name.make (0)
		end

	make (a_name: attached STRING)
		do
			name := a_name
			create packages.make (0)
		end

	make_from_other (other_pkg: attached BMM_PACKAGE_DEFINITION)
			-- make this package with `packages' and `classes' references to those parts of `other_pkg'
			-- but keeping its own name. The child packages have their parent links reset to point to this
			-- package. This is pretty ugly, but fixing it means making BMM_SCHEMA a BMM_PACKAGE_DEFINITION
			-- as well, which we may do later.
		do
			classes := other_pkg.classes
			if other_pkg.has_packages then
				packages := other_pkg.packages
				from packages.start until packages.off loop
					packages.item_for_iteration.set_parent (Current)
					packages.forth
				end
			end
		end

feature -- Access (attributes from schema)

	name: attached STRING
			-- name of the package FROM SCHEMA; this name may be qualified if it is a top-level
			-- package within the schema, or unqualified.
			-- DO NOT RENAME OR OTHERWISE CHANGE THIS ATTRIBUTE EXCEPT IN SYNC WITH RM SCHEMA

	packages: HASH_TABLE [BMM_PACKAGE_DEFINITION, STRING]
			-- child packages
			-- DO NOT RENAME OR OTHERWISE CHANGE THIS ATTRIBUTE EXCEPT IN SYNC WITH RM SCHEMA

	classes: ARRAYED_SET [STRING]
			-- list of classes in this package
			-- DO NOT RENAME OR OTHERWISE CHANGE THIS ATTRIBUTE EXCEPT IN SYNC WITH RM SCHEMA

	archetype_namespace: STRING
			-- archetype namespace FROM SCHEMA; this is a semantic namespace used in archetype
			-- ids, like 'EHR', 'DEMOGRAPHIC' etc, to avoid long qualified names in archetype ids.
			-- DO NOT RENAME OR OTHERWISE CHANGE THIS ATTRIBUTE EXCEPT IN SYNC WITH RM SCHEMA

feature -- Access (attributes derived in post-schema processing)

	parent: BMM_PACKAGE_DEFINITION
			-- parent package

	all_classes: ARRAYED_SET [STRING]
			-- all classes in this package, recursively

feature -- Access

	bmm_schema: BMM_SCHEMA
			-- reverse reference, set after initialisation from input schema

	qualified_name: attached STRING
			-- generate full package path of this package
		local
			csr: BMM_PACKAGE_DEFINITION
		do
			create Result.make(0)
			from csr := Current until csr = Void loop
				Result.prepend (csr.name)
				csr := csr.parent
				if attached csr then
					Result.prepend_character (Package_name_delimiter)
				end
			end
		end

	globally_qualified_name: attached STRING
			-- fully qualified package name prepended with schema name, of form: 'schema_name::package.package.CLASS'
			-- to enable identification in situation when a given package has been imported into more than
			-- one schema.
		do
			Result := bmm_schema.schema_id + schema_name_delimiter + qualified_name
		end

feature -- Status Report

	has_classes: BOOLEAN
		do
			Result := attached classes
		end

	has_packages: BOOLEAN
		do
			Result := attached packages
		end

feature -- Modification

	add_package (a_pkg: attached BMM_PACKAGE_DEFINITION)
		do
			packages.put (a_pkg, a_pkg.name)
			a_pkg.set_parent (Current)
		end

	merge (other: attached like Current)
		do
			-- merge the classes at this level
			if has_classes then
				classes.merge (other.classes)
			else
				classes := other.classes
			end

			-- merge the packages
			if other.has_packages then
				if not has_packages then
					create packages.make (0)
				end
				from other.packages.start until other.packages.after loop
					if packages.has (other.packages.key_for_iteration) then
						packages.item (other.packages.key_for_iteration).merge (other.packages.item_for_iteration)
					else
						-- do a safe clone
						add_package (other.packages.item_for_iteration.safe_deep_twin)
					end
					other.packages.forth
				end
			end
		end

	set_parent (a_pkg: attached BMM_PACKAGE_DEFINITION)
		do
			parent := a_pkg
		end

	do_recursive_classes (action: PROCEDURE [ANY, TUPLE [BMM_PACKAGE_DEFINITION, STRING]])
			-- recursively execute `action' procedure, taking package and class name as arguments
		do
			if has_classes then
				from classes.start until classes.off loop
					action.call ([Current, classes.item])
					classes.forth
				end
			end
			if has_packages then
				from packages.start until packages.off loop
					packages.item_for_iteration.do_recursive_classes (action)
					packages.forth
				end
			end
		end

	do_recursive_packages (action: PROCEDURE [ANY, TUPLE [BMM_PACKAGE_DEFINITION]])
			-- recursively execute `action' procedure, taking package as argument
		do
			action.call ([Current])
			if has_packages then
				from packages.start until packages.off loop
					packages.item_for_iteration.do_recursive_packages (action)
					packages.forth
				end
			end
		end

	there_exists_recursive_packages (test: FUNCTION [ANY, TUPLE [BMM_PACKAGE_DEFINITION], BOOLEAN]): BOOLEAN
			-- recursively execute `test' function, taking package as argument
		do
			Result := test.item ([Current])
			if not Result and has_packages then
				from packages.start until packages.off loop
					Result := packages.item_for_iteration.there_exists_recursive_packages (test)
					packages.forth
				end
			end
		end

feature {BMM_SCHEMA, BMM_PACKAGE_DEFINITION} -- Modification

	finalise_build (a_bmm_schema: attached BMM_SCHEMA; errors: ERROR_ACCUMULATOR)
			-- set `parent' links after creation by DT deserialiser
			-- MUST BE CALLED AFTER MERGING because parent links point up through
			-- the expanded hierarchy attached to BMM_SCHEMA.canonical_packages, not
			-- BMM_SCHEMA.packages as originally read in
		do
			bmm_schema := a_bmm_schema

			if has_classes then
				from classes.start until classes.off loop
					bmm_schema.class_definition (classes.item).set_qualified_names (bmm_schema.schema_id, qualified_name)
					classes.forth
				end
			end
			if has_packages then
				from packages.start until packages.off loop
					packages.item_for_iteration.set_parent (Current)
					packages.item_for_iteration.finalise_build (bmm_schema, errors)
					packages.forth
				end
			end
		end

	safe_deep_twin: BMM_PACKAGE_DEFINITION
			-- perform a safe deep_twin
		local
			parent_pkg: BMM_PACKAGE_DEFINITION
			bmm_sch: BMM_SCHEMA
		do
			parent_pkg := parent
			bmm_sch := bmm_schema
			Result := deep_twin
			parent := parent_pkg
			bmm_schema := bmm_sch
		end

feature {DT_OBJECT_CONVERTER} -- Finalisation

	finalise_dt
			-- finalisation routine to guarantee validity on creation from DT form
			-- rewrite `classes' list so that it has object comparison set
		local
			classes_copy: ARRAYED_SET [STRING]
		do
			if has_classes then
				create classes_copy.make (0)
				classes_copy.compare_objects
				from classes.start until classes.off loop
					classes_copy.extend (classes.item)
					classes.forth
				end
				classes := classes_copy
			end
		end

feature {DT_OBJECT_CONVERTER} -- Conversion

	persistent_attributes: ARRAYED_LIST [STRING]
			-- list of attribute names to persist as DT structure
			-- empty structure means all attributes
		do
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
--| The Original Code is bmm_package_definition.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2010
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
