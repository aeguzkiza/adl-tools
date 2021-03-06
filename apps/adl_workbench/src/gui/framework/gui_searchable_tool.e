note
	component:   "openEHR ADL Tools"
	description: "Abstract idea of a GUI tool that can be searched from the addres bar"
	keywords:    "GUI, searchable"
	author:      "Thomas Beale <thomas.beale@OceanInformatics.com>"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2011 Ocean Informatics Pty Ltd <http://www.oceaninfomatics.com>"
	license:     "Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>"

deferred class GUI_SEARCHABLE_TOOL

feature -- Access

	matching_ids (a_key: STRING): ARRAYED_SET [STRING]
			-- obtain a list of matching ids
		require
			Key_valid: not a_key.is_empty
		deferred
		end

	tool_unique_id: INTEGER
			-- unique id of this tool instance over the session
		deferred
		end

feature -- Status Report

	item_selectable: BOOLEAN
		deferred
		end

	valid_item_id (a_key: STRING): BOOLEAN
			-- key is a valid identifier of an item managed in this tool
		deferred
		end

feature -- Commands

	select_item_by_id (id: STRING)
			-- Select `id' in the tool and go to corresponding widget in GUI visualisation
		require
			item_selectable
		deferred
		end

end


